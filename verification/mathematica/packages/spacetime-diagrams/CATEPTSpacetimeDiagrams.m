(* ============================================================================ *)
(* CATEPTSpacetimeDiagrams.m                                                  *)
(*                                                                            *)
(* Interactive spacetime diagrams for Complex Action Theory (CAT) and         *)
(* Entropic Proper Time (EPT) visualization.                                  *)
(*                                                                            *)
(* Extension of SpacetimeDiagrams by Barak Shoshany, adding:                  *)
(*   1. Entropic Time Reparameterization  (Eqs 57-62)                        *)
(*   2. Schwarzschild Spacetime           (Eq 90)                            *)
(*   3. Corrected Black Hole              (Eqs 92-93)                        *)
(*   4. Penrose Diagram                   (conformal structure)              *)
(*   5. BH Thermodynamics                 (Eqs 130-134)                      *)
(*   6. CFL Stability                     (Eqs 57-62)                        *)
(*                                                                            *)
(* Uses natural units c = G = hbar = kB = 1 throughout.                       *)
(*                                                                            *)
(* Repository: github.com/jagg-ix/entropic-time                               *)
(* ============================================================================ *)

DynamicModule[
    {
        (* ============================================================ *)
        (* Display parameters                                           *)
        (* ============================================================ *)
        ArrowSize = 0.025,
        DiagramRange = 5,
        DiagramSize = 720,
        GridNumber = 10,
        GridOpacity = 0.3,
        LabelMultiplier = 1.04,
        LegendSize = 25,
        LetterSize = 14,

        (* ============================================================ *)
        (* CAT/EPT physics parameters                                   *)
        (* ============================================================ *)
        (* Entropic production rate lambda (Eq 2: dtau_ent = lambda dt) *)
        lambdaRate = 1.0,
        (* Entropic metric correction parameter (Eq 92) *)
        lambdaCorr = 0.0,
        (* Black hole mass in natural units *)
        massParam = 1.0,
        (* Lorentz boost velocity for flat spacetime demos *)
        boostV = 0.0,
        (* Variable entropic rate: lambda(t) = lambdaRate * Exp[-t/tauDecay] *)
        tauDecay = 5.0,
        (* Whether to use variable (exponential) entropic rate *)
        useVariableLambda = False,

        (* ============================================================ *)
        (* Demo selection                                                *)
        (* ============================================================ *)
        WhichDemo = "Entropic Time",

        (* ============================================================ *)
        (* Visual toggles                                                *)
        (* ============================================================ *)
        showCoordGrid = True,
        showEntropicGrid = True,
        showLightCones = True,
        showHorizon = True,
        showGeodesics = True,
        showWorldlines = True,
        showComparison = True,

        (* ============================================================ *)
        (* Colors                                                        *)
        (* ============================================================ *)
        coordColor = GrayLevel[0.5],
        entropicColor = RGBColor[0.85, 0.2, 0.2],
        horizonColor = RGBColor[0.9, 0.6, 0.0],
        geodesicColor = RGBColor[0.0, 0.55, 0.0],
        lightConeColor = RGBColor[1.0, 0.85, 0.0],
        correctedColor = RGBColor[0.2, 0.5, 0.9],
        singularityColor = RGBColor[0.6, 0.0, 0.0],
        futureColor = RGBColor[1.0, 1.0, 0.6],

        (* ============================================================ *)
        (* Helper functions (defined in module body)                     *)
        (* ============================================================ *)
        ColorButton,
        PadNum,

        (* ============================================================ *)
        (* Schwarzschild helper functions                                *)
        (* ============================================================ *)
        (* f(r) = 1 - 2M/r *)
        fSchw,
        (* Corrected: f(r) = 1 - 2M/r + lambda*M^2/r^2 *)
        fCorr,
        (* Tortoise coordinate: r* = r + 2M ln|r/(2M) - 1| *)
        rStar,
        (* Horizon radius *)
        rHorizon,
        rHorizonCorr,
        (* Surface gravity *)
        surfaceGravity,
        surfaceGravityCorr,
        (* Hawking temperature *)
        hawkingTemp,
        (* Entropic rate at horizon *)
        entropicRateH,
        (* BH entropy *)
        bhEntropy,
        (* Entropic time mapping: tau = integral of lambda dt *)
        entropicTimeMap,
        (* Inverse: t from tau *)
        coordTimeFromEntropic
    },

    (* ================================================================ *)
    (* Helper: colored toggle button (same pattern as SpacetimeDiagrams) *)
    (* ================================================================ *)
    ColorButton[val_, color_, text_] := Row[{
        Toggler[
            Dynamic[val],
            {
                False -> Graphics[{White, Disk[{0, 0}, 1], EdgeForm[Thickness[0.03]], Disk[{0, 0}, 0.9]}],
                True -> If[Head[color] =!= List,
                    Graphics[{color, Disk[{0, 0}, 1], EdgeForm[Thickness[0.03]], Disk[{0, 0}, 0.9]}],
                    Graphics[{{color[[1]], Disk[{0, 0}, 1, {Pi/2, 3 Pi/2}], EdgeForm[Thickness[0.03]], Disk[{0, 0}, 0.9, {Pi/2, 3 Pi/2}]}, {color[[2]], Disk[{0, 0}, 1, {3 Pi/2, 5 Pi/2}], EdgeForm[Thickness[0.03]], Disk[{0, 0}, 0.9, {3 Pi/2, 5 Pi/2}]}}]
                ]
            },
            ImageSize -> LegendSize
        ], " ", text
    }];
    SetAttributes[ColorButton, HoldFirst];

    (* Number formatting *)
    PadNum[n_] := PaddedForm[N[n], {5, 3}, NumberPadding -> {"", "0"}];

    (* ================================================================ *)
    (* Physics functions                                                 *)
    (* ================================================================ *)

    (* Schwarzschild lapse function *)
    fSchw[r_] := 1 - 2 massParam / r;

    (* Entropic-corrected lapse (Eq 92) *)
    fCorr[r_] := 1 - 2 massParam / r + lambdaCorr massParam^2 / r^2;

    (* Tortoise coordinate *)
    rStar[r_] := r + 2 massParam Log[Abs[r / (2 massParam) - 1]];

    (* Horizon radii *)
    rHorizon[] := 2 massParam;
    rHorizonCorr[] := If[lambdaCorr < 1, massParam (1 + Sqrt[1 - lambdaCorr]), 2 massParam];

    (* Surface gravity: kappa = (1/2)|f'(r_h)| *)
    surfaceGravity[] := 1 / (4 massParam);
    surfaceGravityCorr[] := Module[{rh = rHorizonCorr[]},
        (1/2) Abs[2 massParam / rh^2 - 2 lambdaCorr massParam^2 / rh^3]
    ];

    (* Hawking temperature: T_H = kappa / (2 pi) in natural units *)
    hawkingTemp[] := surfaceGravity[] / (2 Pi);

    (* Entropic rate at horizon: lambda_H = kappa / (2 pi) = 1/(8 pi M) *)
    entropicRateH[] := 1 / (8 Pi massParam);

    (* BH entropy: S = 4 pi M^2 in natural units (G=hbar=kB=c=1) *)
    bhEntropy[] := 4 Pi massParam^2;

    (* Entropic time mapping *)
    entropicTimeMap[t_] := If[useVariableLambda,
        lambdaRate tauDecay (1 - Exp[-t / tauDecay]),
        lambdaRate t
    ];
    coordTimeFromEntropic[tau_] := If[useVariableLambda,
        -tauDecay Log[1 - tau / (lambdaRate tauDecay)],
        tau / lambdaRate
    ];

    (* ================================================================ *)
    (* Main interface                                                    *)
    (* ================================================================ *)
    Deploy[Column[{
        Dynamic[Style[Grid[{
            (* -------------------------------------------------------- *)
            (* Row 1: Demo selector                                      *)
            (* -------------------------------------------------------- *)
            {Row[{
                Style["CAT/EPT Spacetime Diagrams", Bold, FontSize -> 14],
                "     ",
                Setter[Dynamic[WhichDemo], "Entropic Time"],
                " ",
                Setter[Dynamic[WhichDemo], "Schwarzschild"],
                " ",
                Setter[Dynamic[WhichDemo], "Corrected BH"],
                " ",
                Setter[Dynamic[WhichDemo], "Penrose"],
                " ",
                Setter[Dynamic[WhichDemo], "Thermodynamics"],
                " ",
                Setter[Dynamic[WhichDemo], "CFL Stability"]
            }]},

            (* -------------------------------------------------------- *)
            (* Row 2: Visual toggles                                     *)
            (* -------------------------------------------------------- *)
            {Row[{
                ColorButton[showCoordGrid, coordColor, "Coord grid"],
                "  ",
                ColorButton[showEntropicGrid, entropicColor, "Entropic grid"],
                "  ",
                ColorButton[showLightCones, lightConeColor, "Light cones"],
                "  ",
                ColorButton[showHorizon, horizonColor, "Horizon"],
                "  ",
                ColorButton[showGeodesics, geodesicColor, "Geodesics"],
                "  ",
                ColorButton[showWorldlines, correctedColor, "Worldlines"],
                "  ",
                ColorButton[showComparison, RGBColor[0.6, 0.3, 0.8], "Comparison"]
            }]},

            (* -------------------------------------------------------- *)
            (* Row 3: Physics parameter sliders                          *)
            (* -------------------------------------------------------- *)
            {Row[{
                (* Lambda rate - all demos *)
                "\[Lambda] = ",
                Slider[Dynamic[lambdaRate], {0.1, 3.0, 0.01}, ImageSize -> 100],
                " ",
                Dynamic[PadNum[lambdaRate]],
                "     ",
                (* Mass - BH demos *)
                If[MemberQ[{"Schwarzschild", "Corrected BH", "Penrose", "Thermodynamics"}, WhichDemo],
                    Row[{
                        "M = ",
                        Slider[Dynamic[massParam], {0.3, 3.0, 0.01}, ImageSize -> 100],
                        " ",
                        Dynamic[PadNum[massParam]]
                    }],
                    Nothing
                ],
                "     ",
                (* Lambda correction - corrected BH demos *)
                If[MemberQ[{"Corrected BH", "Penrose", "Thermodynamics"}, WhichDemo],
                    Row[{
                        "\[Lambda]c = ",
                        Slider[Dynamic[lambdaCorr], {0.0, 0.99, 0.01}, ImageSize -> 100],
                        " ",
                        Dynamic[PadNum[lambdaCorr]]
                    }],
                    Nothing
                ]
            }]},

            (* -------------------------------------------------------- *)
            (* Row 4: Demo-specific info panel                           *)
            (* -------------------------------------------------------- *)
            If[WhichDemo == "Entropic Time",
                {Style[Row[{
                    "Eq 2: \[Tau]_ent = \[Integral]\[Lambda]dt",
                    "     ",
                    If[useVariableLambda,
                        Row[{"\[Lambda](t) = ", Dynamic[PadNum[lambdaRate]], " exp(-t/", Dynamic[PadNum[tauDecay]], ")"}],
                        Row[{"\[Lambda] = ", Dynamic[PadNum[lambdaRate]], " (constant)"}]
                    ],
                    "     ",
                    Checkbox[Dynamic[useVariableLambda]], " Variable \[Lambda](t)",
                    If[useVariableLambda,
                        Row[{"  \[Tau]decay = ", Slider[Dynamic[tauDecay], {1.0, 20.0, 0.1}, ImageSize -> 80], " ", Dynamic[PadNum[tauDecay]]}],
                        Nothing
                    ]
                }], FontColor -> entropicColor]},
                Nothing
            ],
            If[WhichDemo == "Schwarzschild",
                {Style[Row[{
                    "Eq 90: ds\[ThinSpace]\[Superscript]2 = -(1-2M/r)dt\[ThinSpace]\[Superscript]2 + dr\[ThinSpace]\[Superscript]2/(1-2M/r) + r\[ThinSpace]\[Superscript]2 d\[CapitalOmega]\[ThinSpace]\[Superscript]2",
                    "     ",
                    "r_h = ", Dynamic[PadNum[rHorizon[]]],
                    "     ",
                    "\[Kappa] = ", Dynamic[PadNum[surfaceGravity[]]]
                }], FontColor -> horizonColor]},
                Nothing
            ],
            If[WhichDemo == "Corrected BH",
                {Style[Row[{
                    "Eq 92: f(r) = 1 - 2M/r + \[Lambda]_c M\[ThinSpace]\[Superscript]2/r\[ThinSpace]\[Superscript]2",
                    "     ",
                    "r_h = ", Dynamic[PadNum[rHorizonCorr[]]],
                    " (std: ", Dynamic[PadNum[rHorizon[]]], ")",
                    "     ",
                    "\[Kappa]_corr = ", Dynamic[PadNum[surfaceGravityCorr[]]]
                }], FontColor -> correctedColor]},
                Nothing
            ],
            If[WhichDemo == "Penrose",
                {Style[Row[{
                    "Conformal diagram: compactified null coordinates (U, V)",
                    "     ",
                    If[lambdaCorr > 0,
                        Row[{"Corrected horizon at r_h = ", Dynamic[PadNum[rHorizonCorr[]]]}],
                        Row[{"Standard horizon at r_h = ", Dynamic[PadNum[rHorizon[]]]}]
                    ]
                }], FontColor -> RGBColor[0.4, 0.2, 0.6]]},
                Nothing
            ],
            If[WhichDemo == "Thermodynamics",
                {Style[Row[{
                    "Eqs 130-134: T_H = ", Dynamic[PadNum[hawkingTemp[]]],
                    "  \[Lambda]_H = ", Dynamic[PadNum[entropicRateH[]]],
                    "  S_BH = ", Dynamic[PadNum[bhEntropy[]]]
                }], FontColor -> RGBColor[0.7, 0.3, 0.0]]},
                Nothing
            ],
            If[WhichDemo == "CFL Stability",
                {Style[Row[{
                    "Eqs 57-62: Standard CFL: \[CapitalDelta]t \[LessEqual] \[CapitalDelta]x/a",
                    "     ",
                    "Entropic CFL: \[CapitalDelta]\[Tau] \[LessEqual] \[Lambda]\[CapitalDelta]x/a",
                    "     ",
                    "Equivalence: \[Lambda] > 0 \[DoubleRightArrow] CFL_t \[DoubleLeftRightArrow] CFL_\[Tau]"
                }], FontColor -> RGBColor[0.0, 0.5, 0.0]]},
                Nothing
            ]
        }, Alignment -> Left], FontSize -> 12]],

        (* ============================================================ *)
        (* THE DIAGRAM                                                   *)
        (* ============================================================ *)
        Dynamic[Switch[WhichDemo,

            (* ======================================================== *)
            (* DEMO 1: Entropic Time Reparameterization                  *)
            (* Shows Minkowski (x,t) with overlaid entropic time grid    *)
            (* ======================================================== *)
            "Entropic Time",
            Graphics[{
                (* Coordinate time grid *)
                If[showCoordGrid, {
                    Opacity[GridOpacity],
                    coordColor,
                    Thickness[0.001],
                    (* Vertical lines: x = const *)
                    Table[Line[{{x, -DiagramRange}, {x, DiagramRange}}],
                        {x, -DiagramRange, DiagramRange, DiagramRange / GridNumber}],
                    (* Horizontal lines: t = const *)
                    Table[Line[{{-DiagramRange, t}, {DiagramRange, t}}],
                        {t, -DiagramRange, DiagramRange, DiagramRange / GridNumber}]
                }],
                (* Entropic time grid: tau = const lines mapped back to coordinate time *)
                If[showEntropicGrid, {
                    Opacity[0.5],
                    entropicColor,
                    Thickness[0.0015],
                    Dashing[{0.01, 0.005}],
                    (* tau = const => t = tau/lambda (constant lambda) *)
                    (* tau = const => t = -tauDecay ln(1 - tau/(lambda*tauDecay)) (variable) *)
                    Table[
                        Module[{tVal = coordTimeFromEntropic[tau]},
                            If[NumericQ[tVal] && Abs[tVal] <= DiagramRange,
                                Line[{{-DiagramRange, tVal}, {DiagramRange, tVal}}],
                                Nothing
                            ]
                        ],
                        {tau, -DiagramRange, DiagramRange, DiagramRange / GridNumber}
                    ],
                    (* Vertical entropic grid (same as coordinate x) *)
                    Table[Line[{{x, -DiagramRange}, {x, DiagramRange}}],
                        {x, -DiagramRange, DiagramRange, DiagramRange / GridNumber}]
                }],
                (* Light cones at origin (invariant under reparameterization!) *)
                If[showLightCones, {
                    Thickness[0.002],
                    lightConeColor,
                    Line[{{-DiagramRange, -DiagramRange}, {DiagramRange, DiagramRange}}],
                    Line[{{-DiagramRange, DiagramRange}, {DiagramRange, -DiagramRange}}],
                    Opacity[0.15],
                    Triangle[{{-DiagramRange, DiagramRange}, {0, 0}, {DiagramRange, DiagramRange}}],
                    Triangle[{{-DiagramRange, -DiagramRange}, {0, 0}, {DiagramRange, -DiagramRange}}]
                }],
                (* Worldline showing entropic time ticks *)
                If[showWorldlines, {
                    correctedColor,
                    Thickness[0.003],
                    Line[{{0, -DiagramRange}, {0, DiagramRange}}],
                    (* Tick marks: entropic time intervals *)
                    Thickness[0.002],
                    Table[
                        Module[{tVal = coordTimeFromEntropic[tau]},
                            If[NumericQ[tVal] && Abs[tVal] <= DiagramRange,
                                {Line[{{-DiagramRange / GridNumber * 0.3, tVal}, {DiagramRange / GridNumber * 0.3, tVal}}],
                                 Text[Style[ToString[Round[tau, 0.1]], FontSize -> 8, entropicColor],
                                      {DiagramRange / GridNumber * 0.6, tVal}]},
                                Nothing
                            ]
                        ],
                        {tau, -DiagramRange + DiagramRange / GridNumber,
                              DiagramRange - DiagramRange / GridNumber,
                              DiagramRange / GridNumber}
                    ]
                }],
                (* Second worldline at x = 2 showing entropic time effect *)
                If[showGeodesics, {
                    geodesicColor,
                    Thickness[0.003],
                    Line[{{DiagramRange * 0.4, -DiagramRange}, {DiagramRange * 0.4, DiagramRange}}],
                    Thickness[0.002],
                    Table[
                        Module[{tVal = coordTimeFromEntropic[tau]},
                            If[NumericQ[tVal] && Abs[tVal] <= DiagramRange,
                                Line[{{DiagramRange * 0.4 - DiagramRange / GridNumber * 0.2, tVal},
                                      {DiagramRange * 0.4 + DiagramRange / GridNumber * 0.2, tVal}}],
                                Nothing
                            ]
                        ],
                        {tau, -DiagramRange + DiagramRange / GridNumber,
                              DiagramRange - DiagramRange / GridNumber,
                              DiagramRange / GridNumber}
                    ]
                }],
                (* Axes *)
                {Black, Arrowheads[{-ArrowSize, ArrowSize}],
                 Arrow[{{-DiagramRange, 0}, {DiagramRange, 0}}],
                 Arrow[{{0, -DiagramRange}, {0, DiagramRange}}]},
                (* Labels *)
                {Text[Style["x", FontSize -> LetterSize], {DiagramRange * LabelMultiplier, 0}],
                 Text[Style["t", FontSize -> LetterSize], {0, DiagramRange * LabelMultiplier}],
                 Text[Style["\[Tau]_ent", FontSize -> LetterSize, entropicColor],
                      {DiagramRange / GridNumber * 1.5, DiagramRange * LabelMultiplier}]},
                (* Legend *)
                {Text[Style["Gray: coordinate time t", FontSize -> 9, coordColor], {-DiagramRange * 0.7, -DiagramRange * 0.92}],
                 Text[Style["Red dashed: entropic time \[Tau]", FontSize -> 9, entropicColor], {-DiagramRange * 0.7, -DiagramRange * 0.97}]}
            },
            ImageSize -> {DiagramSize, DiagramSize},
            PlotRange -> {{-DiagramRange, DiagramRange}, {-DiagramRange, DiagramRange}} * LabelMultiplier^2],

            (* ======================================================== *)
            (* DEMO 2: Schwarzschild (t, r) Diagram                      *)
            (* ======================================================== *)
            "Schwarzschild",
            Module[{rMin = 0.5, rMax = DiagramRange, tRange = DiagramRange, rH = rHorizon[]},
            Graphics[{
                (* Coordinate grid *)
                If[showCoordGrid, {
                    Opacity[GridOpacity], coordColor, Thickness[0.001],
                    Table[Line[{{r, -tRange}, {r, tRange}}], {r, 0, rMax, rMax / GridNumber}],
                    Table[Line[{{0, t}, {rMax, t}}], {t, -tRange, tRange, tRange / GridNumber}]
                }],
                (* Event horizon *)
                If[showHorizon, {
                    horizonColor, Thickness[0.004], Dashing[{0.015, 0.008}],
                    Line[{{rH, -tRange}, {rH, tRange}}],
                    Text[Style[Row[{"r_h = ", PadNum[rH]}], FontSize -> 10, horizonColor],
                         {rH, tRange * 0.95}, {-1.2, 0}]
                }],
                (* Light cones at several radii *)
                If[showLightCones, {
                    lightConeColor, Thickness[0.0015], Opacity[0.8],
                    Table[
                        Module[{fr = fSchw[r0], dt = tRange / GridNumber},
                            If[r0 > rH + 0.1 && fr > 0,
                                (* Outgoing and ingoing null directions: dr/dt = +/- f(r) *)
                                {Line[{{r0, 0}, {r0 + fr * dt, dt}}],
                                 Line[{{r0, 0}, {r0 - fr * dt, dt}}],
                                 Line[{{r0, 0}, {r0 + fr * dt, -dt}}],
                                 Line[{{r0, 0}, {r0 - fr * dt, -dt}}]},
                                Nothing
                            ]
                        ],
                        {r0, rH + 0.5, rMax - 0.5, (rMax - rH) / 6}
                    ]
                }],
                (* Null geodesics: ingoing and outgoing *)
                If[showGeodesics, {
                    geodesicColor, Thickness[0.002],
                    (* Outgoing null geodesics: t = r* + const *)
                    Table[
                        Line[Table[{r, rStar[r] + c}, {r, rH + 0.05, rMax, 0.05}]],
                        {c, -2 tRange, 2 tRange, tRange / 3}
                    ],
                    (* Ingoing null geodesics: t = -r* + const *)
                    Dashing[{0.008, 0.005}],
                    Table[
                        Line[Table[{r, -rStar[r] + c}, {r, rH + 0.05, rMax, 0.05}]],
                        {c, -2 tRange, 2 tRange, tRange / 3}
                    ]
                }],
                (* Timelike geodesic (radial infall from rest at r0) *)
                If[showWorldlines, Module[{r0 = rMax * 0.8, nPts = 200},
                    {correctedColor, Thickness[0.003],
                     Line[Table[
                         Module[{r = r0 - (r0 - rH - 0.05) s, tVal},
                             tVal = -NIntegrate[1 / fSchw[rr] Sqrt[(r0 / rr - 1) / (r0 / (2 massParam) - 1)] // Abs,
                                 {rr, r0, r}, Method -> "LocalAdaptive", MaxRecursion -> 5] // Quiet;
                             {r, tVal}
                         ],
                         {s, 0, 1, 1 / nPts}
                     ] // Select[And @@ (NumericQ /@ #) &]]
                    }
                ]],
                (* Singularity *)
                {singularityColor, Thickness[0.005],
                 Line[{{0, -tRange}, {0, tRange}}]},
                (* Axes *)
                {Black, Arrowheads[ArrowSize],
                 Arrow[{{0, 0}, {rMax, 0}}],
                 Arrow[{{0, -tRange}, {0, tRange}}]},
                {Text[Style["r", FontSize -> LetterSize], {rMax * LabelMultiplier, 0}],
                 Text[Style["t", FontSize -> LetterSize], {0, tRange * LabelMultiplier}],
                 Text[Style["singularity", FontSize -> 9, singularityColor], {0.15, -tRange * 0.92}, {-1, 0}]}
            },
            ImageSize -> {DiagramSize, DiagramSize},
            PlotRange -> {{-0.3, rMax}, {-tRange, tRange}} * LabelMultiplier^2
            ]],

            (* ======================================================== *)
            (* DEMO 3: Corrected Black Hole (Eq 92-93)                   *)
            (* ======================================================== *)
            "Corrected BH",
            Module[{rMin = 0.3, rMax = DiagramRange, tRange = DiagramRange,
                    rH = rHorizon[], rHC = rHorizonCorr[]},
            Graphics[{
                (* Coordinate grid *)
                If[showCoordGrid, {
                    Opacity[GridOpacity], coordColor, Thickness[0.001],
                    Table[Line[{{r, -tRange}, {r, tRange}}], {r, 0, rMax, rMax / GridNumber}],
                    Table[Line[{{0, t}, {rMax, t}}], {t, -tRange, tRange, tRange / GridNumber}]
                }],
                (* Standard horizon *)
                If[showHorizon, {
                    horizonColor, Thickness[0.003], Dashing[{0.015, 0.008}],
                    Line[{{rH, -tRange}, {rH, tRange}}],
                    Text[Style[Row[{"r_h = 2M = ", PadNum[rH]}], FontSize -> 9, horizonColor],
                         {rH, tRange * 0.92}, {-1.2, 0}]
                }],
                (* Corrected horizon *)
                If[showComparison && lambdaCorr > 0, {
                    correctedColor, Thickness[0.004],
                    Line[{{rHC, -tRange}, {rHC, tRange}}],
                    Text[Style[Row[{"r_h^corr = ", PadNum[rHC]}], FontSize -> 9, correctedColor],
                         {rHC, tRange * 0.85}, {-1.2, 0}]
                }],
                (* Standard null geodesics *)
                If[showGeodesics, {
                    Opacity[0.5], geodesicColor, Thickness[0.0015],
                    Table[
                        Line[Table[{r, rStar[r] + c}, {r, rH + 0.05, rMax, 0.05}]],
                        {c, -2 tRange, 2 tRange, tRange / 2}
                    ]
                }],
                (* Corrected null geodesics *)
                If[showGeodesics && lambdaCorr > 0, {
                    correctedColor, Thickness[0.002], Opacity[0.7],
                    Table[
                        Line[Table[
                            Module[{fc = fCorr[r]},
                                If[fc > 0 && r > rHC + 0.02,
                                    {r, NIntegrate[1 / fCorr[rr], {rr, rHC + 0.05, r},
                                        Method -> "LocalAdaptive", MaxRecursion -> 5] + c // Quiet},
                                    Nothing
                                ]
                            ],
                            {r, rHC + 0.05, rMax, 0.08}
                        ] // Select[And @@ (NumericQ /@ Flatten[{#}]) &]],
                        {c, -2 tRange, 2 tRange, tRange / 2}
                    ]
                }],
                (* Lapse function comparison plot (inset) *)
                If[showComparison, {
                    Inset[
                        Plot[{fSchw[r] /. massParam -> massParam, fCorr[r] /. {massParam -> massParam, lambdaCorr -> lambdaCorr}},
                            {r, 0.5, rMax},
                            PlotStyle -> {{horizonColor, Thickness[0.003]}, {correctedColor, Thickness[0.003]}},
                            PlotRange -> {{0.5, rMax}, {-0.5, 1.2}},
                            Epilog -> {Dashed, GrayLevel[0.5], Line[{{0, 0}, {rMax, 0}}]},
                            AxesLabel -> {"r", "f(r)"},
                            PlotLabel -> Style["Lapse function", FontSize -> 9],
                            ImageSize -> {DiagramSize * 0.3, DiagramSize * 0.2},
                            PlotLegends -> Placed[{"Standard", "Corrected"}, Below]
                        ],
                        {rMax * 0.75, -tRange * 0.7}
                    ]
                }],
                (* Singularity *)
                {singularityColor, Thickness[0.005],
                 Line[{{0, -tRange}, {0, tRange}}]},
                (* Axes *)
                {Black, Arrowheads[ArrowSize],
                 Arrow[{{0, 0}, {rMax, 0}}],
                 Arrow[{{0, -tRange}, {0, tRange}}]},
                {Text[Style["r", FontSize -> LetterSize], {rMax * LabelMultiplier, 0}],
                 Text[Style["t", FontSize -> LetterSize], {0, tRange * LabelMultiplier}]}
            },
            ImageSize -> {DiagramSize, DiagramSize},
            PlotRange -> {{-0.3, rMax}, {-tRange, tRange}} * LabelMultiplier^2
            ]],

            (* ======================================================== *)
            (* DEMO 4: Penrose Diagram                                   *)
            (* ======================================================== *)
            "Penrose",
            Module[{rH = If[lambdaCorr > 0, rHorizonCorr[], rHorizon[]],
                    rHStd = rHorizon[], penroseSize = DiagramRange * 0.9},
            Graphics[{
                (* Region I: exterior (right diamond) *)
                {Opacity[0.08], futureColor,
                 Polygon[{{0, 0}, {penroseSize, penroseSize}, {0, 2 penroseSize}, {-penroseSize, penroseSize}}]},

                (* Region II: black hole interior (top triangle) *)
                {Opacity[0.1], RGBColor[0.9, 0.8, 0.8],
                 Polygon[{{-penroseSize, penroseSize}, {0, 2 penroseSize}, {penroseSize, penroseSize}}]},

                (* Region III: white hole interior (bottom triangle) *)
                {Opacity[0.1], RGBColor[0.8, 0.8, 0.95],
                 Polygon[{{-penroseSize, penroseSize}, {0, 0}, {penroseSize, penroseSize}}]},

                (* Region IV: parallel exterior (left diamond - optional) *)

                (* Singularity (future): wavy line *)
                {singularityColor, Thickness[0.004],
                 Line[Table[{x, 2 penroseSize + 0.08 penroseSize Sin[12 Pi x / penroseSize]},
                     {x, -penroseSize, penroseSize, penroseSize / 50}]]},
                (* Singularity (past): wavy line *)
                {singularityColor, Thickness[0.004],
                 Line[Table[{x, 0.08 penroseSize Sin[12 Pi x / penroseSize]},
                     {x, -penroseSize, penroseSize, penroseSize / 50}]]},

                (* Event horizon *)
                If[showHorizon, {
                    horizonColor, Thickness[0.003], Dashing[{0.015, 0.008}],
                    (* Future horizon *)
                    Line[{{0, 2 penroseSize}, {penroseSize, penroseSize}}],
                    (* Past horizon *)
                    Line[{{0, 0}, {penroseSize, penroseSize}}],
                    (* Antihorizon *)
                    Line[{{0, 2 penroseSize}, {-penroseSize, penroseSize}}],
                    Line[{{0, 0}, {-penroseSize, penroseSize}}]
                }],

                (* Corrected horizon (shifted) *)
                If[showComparison && lambdaCorr > 0,
                    Module[{shift = (rHStd - rH) / rHStd * penroseSize * 0.15},
                        {correctedColor, Thickness[0.003],
                         Line[{{0 + shift, 2 penroseSize}, {penroseSize - shift, penroseSize}}],
                         Line[{{0 + shift, 0}, {penroseSize - shift, penroseSize}}],
                         Text[Style["corrected horizon", FontSize -> 9, correctedColor],
                              {penroseSize * 0.6, penroseSize * 1.55}, {-1, 0}]
                        }
                    ]
                ],

                (* Null infinity *)
                {Black, Thickness[0.002],
                 (* i+ (future timelike infinity) *)
                 Line[{{0, 2 penroseSize}, {penroseSize, penroseSize}}],
                 Line[{{0, 2 penroseSize}, {-penroseSize, penroseSize}}],
                 (* i- (past timelike infinity) *)
                 Line[{{0, 0}, {penroseSize, penroseSize}}],
                 Line[{{0, 0}, {-penroseSize, penroseSize}}]
                },

                (* Sample timelike worldlines *)
                If[showWorldlines, {
                    correctedColor, Thickness[0.002],
                    (* Worldline of infalling observer *)
                    Line[Table[
                        {penroseSize * 0.6 (1 - s), penroseSize * (0.3 + 1.5 s)},
                        {s, 0, 1, 0.02}
                    ]],
                    (* Static observer worldline *)
                    geodesicColor, Thickness[0.002],
                    Line[Table[
                        {penroseSize * 0.7, penroseSize * (0.5 + s)},
                        {s, 0, 1, 0.02}
                    ]]
                }],

                (* Light cones at sample points *)
                If[showLightCones, {
                    lightConeColor, Thickness[0.001], Opacity[0.6],
                    Table[
                        Module[{x0 = penroseSize * xf, t0 = penroseSize * tf, sz = penroseSize * 0.08},
                            {Line[{{x0, t0}, {x0 + sz, t0 + sz}}],
                             Line[{{x0, t0}, {x0 - sz, t0 + sz}}],
                             Line[{{x0, t0}, {x0 + sz, t0 - sz}}],
                             Line[{{x0, t0}, {x0 - sz, t0 - sz}}]}
                        ],
                        {xf, {0.3, 0.5, 0.7}}, {tf, {0.7, 1.0, 1.3}}
                    ]
                }],

                (* Labels *)
                {Text[Style["r = 0 (singularity)", FontSize -> 10, singularityColor],
                      {0, 2 penroseSize * 1.05}],
                 Text[Style["r = 0", FontSize -> 10, singularityColor],
                      {0, -penroseSize * 0.08}],
                 Text[Style["\[ScriptCapitalI]\[Superscript]+", FontSize -> 14],
                      {penroseSize * 1.08, penroseSize * 1.5}],
                 Text[Style["\[ScriptCapitalI]\[Superscript]-", FontSize -> 14],
                      {penroseSize * 1.08, penroseSize * 0.5}],
                 Text[Style["i\[Superscript]+", FontSize -> 12],
                      {0, 2 penroseSize * 1.1}],
                 Text[Style["i\[Superscript]0", FontSize -> 12],
                      {penroseSize * 1.1, penroseSize}],
                 Text[Style["i\[Superscript]-", FontSize -> 12],
                      {0, -penroseSize * 0.12}],
                 Text[Style["I", FontSize -> 14, Bold], {penroseSize * 0.5, penroseSize}],
                 Text[Style["II", FontSize -> 14, Bold], {0, penroseSize * 1.5}],
                 Text[Style["III", FontSize -> 14, Bold], {0, penroseSize * 0.5}],
                 If[showHorizon,
                     Text[Style["horizon", FontSize -> 9, horizonColor],
                          {penroseSize * 0.65, penroseSize * 1.45}, {-1, 0}],
                     Nothing
                 ]
                }
            },
            ImageSize -> {DiagramSize, DiagramSize},
            PlotRange -> {{-penroseSize * 1.3, penroseSize * 1.3},
                          {-penroseSize * 0.3, 2 penroseSize * 1.2}}
            ]],

            (* ======================================================== *)
            (* DEMO 5: Black Hole Thermodynamics (Eqs 130-134)           *)
            (* ======================================================== *)
            "Thermodynamics",
            Module[{mRange = {0.3, 5.0}},
            GraphicsGrid[{
                (* Row 1: T_H and lambda_H vs M *)
                {
                    (* Hawking temperature vs mass *)
                    Plot[1 / (8 Pi m), {m, mRange[[1]], mRange[[2]]},
                        PlotStyle -> {{horizonColor, Thickness[0.003]}},
                        AxesLabel -> {"M", Subscript["T", "H"]},
                        PlotLabel -> Style["Eq 133: Hawking Temperature", FontSize -> 11],
                        Epilog -> {
                            Red, PointSize[0.015],
                            Point[{massParam, 1 / (8 Pi massParam)}],
                            Dashed, GrayLevel[0.5],
                            Line[{{massParam, 0}, {massParam, 1 / (8 Pi massParam)}}],
                            Line[{{0, 1 / (8 Pi massParam)}, {massParam, 1 / (8 Pi massParam)}}]
                        },
                        PlotRange -> {All, {0, 0.15}},
                        ImageSize -> {DiagramSize * 0.48, DiagramSize * 0.45}
                    ],
                    (* Entropic rate vs mass *)
                    Plot[1 / (8 Pi m), {m, mRange[[1]], mRange[[2]]},
                        PlotStyle -> {{entropicColor, Thickness[0.003]}},
                        AxesLabel -> {"M", Subscript["\[Lambda]", "H"]},
                        PlotLabel -> Style["Eq 131: Entropic Rate at Horizon", FontSize -> 11],
                        Epilog -> {
                            Red, PointSize[0.015],
                            Point[{massParam, 1 / (8 Pi massParam)}],
                            Dashed, GrayLevel[0.5],
                            Line[{{massParam, 0}, {massParam, 1 / (8 Pi massParam)}}]
                        },
                        PlotRange -> {All, {0, 0.15}},
                        ImageSize -> {DiagramSize * 0.48, DiagramSize * 0.45}
                    ]
                },
                (* Row 2: Entropy and Surface gravity *)
                {
                    (* BH entropy vs mass *)
                    Plot[4 Pi m^2, {m, mRange[[1]], mRange[[2]]},
                        PlotStyle -> {{correctedColor, Thickness[0.003]}},
                        AxesLabel -> {"M", Subscript["S", "BH"]},
                        PlotLabel -> Style["Eq 134: Bekenstein-Hawking Entropy", FontSize -> 11],
                        Epilog -> {
                            Red, PointSize[0.015],
                            Point[{massParam, 4 Pi massParam^2}],
                            Dashed, GrayLevel[0.5],
                            Line[{{massParam, 0}, {massParam, 4 Pi massParam^2}}]
                        },
                        PlotRange -> All,
                        ImageSize -> {DiagramSize * 0.48, DiagramSize * 0.45}
                    ],
                    (* Surface gravity: standard vs corrected *)
                    Plot[{
                        1 / (4 m),
                        If[lambdaCorr > 0 && lambdaCorr < 1,
                            Module[{rh = m (1 + Sqrt[1 - lambdaCorr])},
                                (1/2) Abs[2 m / rh^2 - 2 lambdaCorr m^2 / rh^3]
                            ],
                            1 / (4 m)
                        ]
                    }, {m, mRange[[1]], mRange[[2]]},
                        PlotStyle -> {{horizonColor, Thickness[0.003]}, {correctedColor, Thickness[0.003], Dashing[{0.015, 0.008}]}},
                        AxesLabel -> {"M", "\[Kappa]"},
                        PlotLabel -> Style["Eq 130/93: Surface Gravity", FontSize -> 11],
                        PlotLegends -> Placed[{"Standard", "Corrected"}, Below],
                        Epilog -> {
                            Red, PointSize[0.015],
                            Point[{massParam, surfaceGravity[]}]
                        },
                        PlotRange -> {All, {0, 1.0}},
                        ImageSize -> {DiagramSize * 0.48, DiagramSize * 0.45}
                    ]
                },
                (* Row 3: First law and consistency *)
                {
                    (* T dS/dM = 1 in natural units *)
                    Plot[{
                        1 / (8 Pi m) * 8 Pi m,  (* T_H * dS/dM = 1 *)
                        1  (* Expected *)
                    }, {m, mRange[[1]], mRange[[2]]},
                        PlotStyle -> {{geodesicColor, Thickness[0.003]}, {GrayLevel[0.5], Dashing[{0.01, 0.005}]}},
                        AxesLabel -> {"M", "T dS/dM"},
                        PlotLabel -> Style["First Law: T dS = dE (= 1 in nat. units)", FontSize -> 11],
                        PlotRange -> {All, {0, 2}},
                        ImageSize -> {DiagramSize * 0.48, DiagramSize * 0.45}
                    ],
                    (* Consistency: T = lambda_H (in natural units) *)
                    Plot[{
                        1 / (8 Pi m),   (* T_H *)
                        1 / (8 Pi m)    (* lambda_H (same in natural units) *)
                    }, {m, mRange[[1]], mRange[[2]]},
                        PlotStyle -> {{horizonColor, Thickness[0.003]}, {entropicColor, Thickness[0.003], Dashing[{0.01, 0.005}]}},
                        AxesLabel -> {"M", ""},
                        PlotLabel -> Style["Consistency: T_H \[Proportional] \[Lambda]_H", FontSize -> 11],
                        PlotLegends -> Placed[{Subscript["T", "H"], Subscript["\[Lambda]", "H"]}, Below],
                        PlotRange -> {All, {0, 0.15}},
                        ImageSize -> {DiagramSize * 0.48, DiagramSize * 0.45}
                    ]
                }
            },
            ImageSize -> {DiagramSize, DiagramSize * 1.4}
            ]],

            (* ======================================================== *)
            (* DEMO 6: CFL Stability (Eqs 57-62)                        *)
            (* ======================================================== *)
            "CFL Stability",
            Module[{aSpeed = 1.5, dxVal = 1.0, maxCourant = 2.5},
            Graphics[{
                (* Background regions *)
                (* Stable region (green) *)
                {Opacity[0.12], RGBColor[0.2, 0.8, 0.2],
                 Polygon[{{0, 0}, {maxCourant, 0}, {maxCourant, dxVal / aSpeed},
                           {0, dxVal / aSpeed}}]},
                (* Unstable region (red) *)
                {Opacity[0.08], RGBColor[0.8, 0.2, 0.2],
                 Polygon[{{0, dxVal / aSpeed}, {maxCourant, dxVal / aSpeed},
                           {maxCourant, maxCourant}, {0, maxCourant}}]},

                (* CFL boundary: dt = dx/a *)
                {Black, Thickness[0.003],
                 Line[{{0, dxVal / aSpeed}, {maxCourant, dxVal / aSpeed}}]},

                (* Entropic CFL boundary: dtau = lambda * dx/a *)
                {entropicColor, Thickness[0.003], Dashing[{0.015, 0.008}],
                 Line[{{0, lambdaRate * dxVal / aSpeed}, {maxCourant, lambdaRate * dxVal / aSpeed}}]},

                (* Coordinate grid *)
                If[showCoordGrid, {
                    Opacity[GridOpacity * 0.5], coordColor, Thickness[0.0005],
                    Table[Line[{{x, 0}, {x, maxCourant}}], {x, 0, maxCourant, maxCourant / 10}],
                    Table[Line[{{0, y}, {maxCourant, y}}], {y, 0, maxCourant, maxCourant / 10}]
                }],

                (* Arrow showing the mapping dt <-> dtau *)
                If[showWorldlines, {
                    correctedColor, Thickness[0.002],
                    Arrowheads[0.03],
                    Arrow[{{maxCourant * 0.8, dxVal / aSpeed}, {maxCourant * 0.8, lambdaRate * dxVal / aSpeed}}],
                    Text[Style["\[Times]\[Lambda]", FontSize -> 12, correctedColor],
                         {maxCourant * 0.85, (dxVal / aSpeed + lambdaRate * dxVal / aSpeed) / 2}]
                }],

                (* Courant number illustration *)
                If[showGeodesics, {
                    geodesicColor, Thickness[0.003],
                    PointSize[0.01],
                    (* Point at C = a*dt/dx = 0.5 (stable) *)
                    Point[{0.5, 0.5 * dxVal / aSpeed}],
                    Text[Style["C = 0.5 (stable)", FontSize -> 9, geodesicColor],
                         {0.5, 0.5 * dxVal / aSpeed + maxCourant * 0.04}],
                    (* Point at C = 1.5 (unstable) *)
                    Red, Point[{1.5, 1.5 * dxVal / aSpeed}],
                    Text[Style["C = 1.5 (unstable)", FontSize -> 9, Red],
                         {1.5, 1.5 * dxVal / aSpeed + maxCourant * 0.04}]
                }],

                (* Labels *)
                {Text[Style["CFL STABLE", FontSize -> 14, Bold, RGBColor[0.1, 0.6, 0.1]],
                      {maxCourant * 0.5, dxVal / aSpeed * 0.4}],
                 Text[Style["CFL UNSTABLE", FontSize -> 14, Bold, RGBColor[0.7, 0.1, 0.1]],
                      {maxCourant * 0.5, dxVal / aSpeed * 2.0}]},

                (* Axes *)
                {Black, Arrowheads[ArrowSize],
                 Arrow[{{0, 0}, {maxCourant, 0}}],
                 Arrow[{{0, 0}, {0, maxCourant}}]},
                {Text[Style["Courant number C = a\[CapitalDelta]t/\[CapitalDelta]x", FontSize -> 12],
                      {maxCourant * 0.5, -maxCourant * 0.08}],
                 Text[Style["\[CapitalDelta]t", FontSize -> LetterSize],
                      {-maxCourant * 0.05, maxCourant * LabelMultiplier}]},

                (* Legend *)
                {Text[Style["Solid: CFL boundary (\[CapitalDelta]t = \[CapitalDelta]x/a)", FontSize -> 10],
                      {maxCourant * 0.5, maxCourant * 0.93}],
                 Text[Style[Row[{"Dashed: Entropic CFL (\[CapitalDelta]\[Tau] = \[Lambda]\[CapitalDelta]x/a, \[Lambda] = ", PadNum[lambdaRate], ")"}],
                      FontSize -> 10, entropicColor],
                      {maxCourant * 0.5, maxCourant * 0.88}],
                 Text[Style["Equivalence: \[Lambda] > 0 \[DoubleRightArrow] both conditions identical", FontSize -> 10,
                      RGBColor[0.3, 0.3, 0.8]],
                      {maxCourant * 0.5, maxCourant * 0.83}]}
            },
            ImageSize -> {DiagramSize, DiagramSize},
            PlotRange -> {{-maxCourant * 0.1, maxCourant}, {-maxCourant * 0.1, maxCourant}} * 1.05
            ]],

            (* Default fallback *)
            _,
            Graphics[{
                Text[Style["Select a demo above", FontSize -> 16], {0, 0}]
            }, ImageSize -> {DiagramSize, DiagramSize}]

        ]] (* end Dynamic[Switch[...]] *)
    }, Alignment -> Center]] (* end Deploy[Column[...]] *)
] (* end DynamicModule *)
