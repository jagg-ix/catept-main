(* ::Package:: *)
(* EntropicResult.m — Solver result with entropy and entropic time traces *)
(*                                                                         *)
(* Extends the QuTiP Result pattern:                                       *)
(*   result["Times"]      — coordinate time array                          *)
(*   result["States"]     — list of QuantumState at each time step         *)
(*   result["Expect"]     — expectation value traces                       *)
(*   result["Entropy"]    — S(t) von Neumann entropy trace                 *)
(*   result["LambdaEnt"]  — lambda(t) entropy production rate              *)
(*   result["EntropicTime"] — tau_ent(t) accumulated proper time           *)
(*   result["Weight"]     — exp(-S_I/hbar) path-integral weight            *)
(*                                                                         *)
(* Maps to: eq_3 (tau_ent), eq_54 (weight)                                *)

(* Loaded within CATEPT` context by Init.m *)

Begin["CATEPT`Private`"];

(* ================================================================ *)
(* Constructor helper — ensures all keys present                     *)
(* Note: No DownValue constructor to avoid infinite recursion.       *)
(* Solvers call EntropicResult[<|...|>] directly with all keys.      *)
(* ================================================================ *)

createEntropicResult[assoc_Association] :=
    EntropicResult[
        KeySort @ Join[
            <|
                "Times" -> {},
                "States" -> {},
                "Expect" -> <||>,
                "Entropy" -> {},
                "LambdaEnt" -> {},
                "EntropicTime" -> {},
                "Weight" -> {},
                "SI" -> {},
                "Stats" -> <||>
            |>,
            assoc
        ]
    ];

(* ================================================================ *)
(* Property access                                                   *)
(* ================================================================ *)

EntropicResult /: EntropicResult[assoc_Association]["Times"] := assoc["Times"];
EntropicResult /: EntropicResult[assoc_Association]["States"] := assoc["States"];
EntropicResult /: EntropicResult[assoc_Association]["Expect"] := assoc["Expect"];
EntropicResult /: EntropicResult[assoc_Association]["Entropy"] := assoc["Entropy"];
EntropicResult /: EntropicResult[assoc_Association]["LambdaEnt"] := assoc["LambdaEnt"];
EntropicResult /: EntropicResult[assoc_Association]["EntropicTime"] := assoc["EntropicTime"];
EntropicResult /: EntropicResult[assoc_Association]["Weight"] := assoc["Weight"];
EntropicResult /: EntropicResult[assoc_Association]["SI"] := assoc["SI"];
EntropicResult /: EntropicResult[assoc_Association]["Stats"] := assoc["Stats"];

(* Derived properties *)
EntropicResult /: EntropicResult[assoc_Association]["NumTimes"] :=
    Length[assoc["Times"]];

EntropicResult /: EntropicResult[assoc_Association]["Duration"] :=
    If[Length[assoc["Times"]] > 0,
        Last[assoc["Times"]] - First[assoc["Times"]],
        0.0
    ];

EntropicResult /: EntropicResult[assoc_Association]["FinalEntropy"] :=
    If[Length[assoc["Entropy"]] > 0, Last[assoc["Entropy"]], 0.0];

EntropicResult /: EntropicResult[assoc_Association]["FinalEntropicTime"] :=
    If[Length[assoc["EntropicTime"]] > 0, Last[assoc["EntropicTime"]], 0.0];

EntropicResult /: EntropicResult[assoc_Association]["FinalWeight"] :=
    If[Length[assoc["Weight"]] > 0, Last[assoc["Weight"]], 1.0];

EntropicResult /: EntropicResult[assoc_Association]["TotalSI"] :=
    If[Length[assoc["SI"]] > 0, Last[assoc["SI"]], 0.0];

(* cSF transition amplitude *)
EntropicResult /: EntropicResult[assoc_Association]["CSFWeight"] :=
    CSFWeight[EntropicResult[assoc]["TotalSI"]];

(* Entropy production rate from finite differences *)
EntropicResult /: EntropicResult[assoc_Association]["EntropyProductionRate"] :=
    Module[{s, t, dt, ds},
        s = assoc["Entropy"];
        t = assoc["Times"];
        If[Length[s] < 2, Return[{}]];
        dt = Differences[t];
        ds = Differences[s];
        Prepend[ds / dt, 0.0]
    ];

(* ================================================================ *)
(* Plotting                                                          *)
(* ================================================================ *)

EntropicResult /: EntropicResult[assoc_Association]["EntropyPlot", opts___] :=
    ListLinePlot[
        Transpose[{assoc["Times"], assoc["Entropy"]}],
        PlotLabel -> "Von Neumann Entropy S(t)",
        AxesLabel -> {"t", "S"},
        PlotStyle -> Blue,
        opts
    ];

EntropicResult /: EntropicResult[assoc_Association]["EntropicTimePlot", opts___] :=
    ListLinePlot[
        Transpose[{assoc["Times"], assoc["EntropicTime"]}],
        PlotLabel -> "Entropic Proper Time \!\(\*SubscriptBox[\(\[Tau]\), \(ent\)]\)(t)",
        AxesLabel -> {"t", "\!\(\*SubscriptBox[\(\[Tau]\), \(ent\)]\)"},
        PlotStyle -> Red,
        opts
    ];

EntropicResult /: EntropicResult[assoc_Association]["WeightPlot", opts___] :=
    ListLinePlot[
        Transpose[{assoc["Times"], assoc["Weight"]}],
        PlotLabel -> "Path Integral Weight exp(-\!\(\*SubscriptBox[\(S\), \(I\)]\)/\[HBar])",
        AxesLabel -> {"t", "w"},
        PlotStyle -> Darker[Green],
        PlotRange -> {0, Automatic},
        opts
    ];

EntropicResult /: EntropicResult[assoc_Association]["LambdaPlot", opts___] :=
    ListLinePlot[
        Transpose[{assoc["Times"], assoc["LambdaEnt"]}],
        PlotLabel -> "Entropy Production Rate \[Lambda](t)",
        AxesLabel -> {"t", "\[Lambda]"},
        PlotStyle -> Orange,
        opts
    ];

EntropicResult /: EntropicResult[assoc_Association]["SummaryPlot", opts___] :=
    GraphicsGrid[{{
        EntropicResult[assoc]["EntropyPlot", opts],
        EntropicResult[assoc]["EntropicTimePlot", opts]
    }, {
        EntropicResult[assoc]["WeightPlot", opts],
        EntropicResult[assoc]["LambdaPlot", opts]
    }},
        ImageSize -> Large,
        PlotLabel -> "CAT/EPT Evolution Summary"
    ];

(* Bloch plot for 2-level systems *)
EntropicResult /: EntropicResult[assoc_Association]["BlochPlot", opts___] :=
    Module[{states},
        states = assoc["States"];
        If[Length[states] == 0, Return[$Failed]];
        If[!MatchQ[states[[1]], _?QuantumStateQ], Return[$Failed]];
        Show[
            QuantumState["UniformMixture"]["BlochPlot"],
            ParametricPlot3D[
                Evaluate[Through[states["BlochVector"]]],
                {t, 0, 1},
                PlotStyle -> {Thick, ColorData["Rainbow"]},
                opts
            ]
        ]
    ];

(* ================================================================ *)
(* Decoherence timescale extraction                                  *)
(* ================================================================ *)

EntropicResult /: EntropicResult[assoc_Association]["DecoherenceTimescales"] :=
    Module[{s, t, sMax, halfIdx, t1, t2},
        s = assoc["Entropy"];
        t = assoc["Times"];
        If[Length[s] < 3, Return[<|"T1" -> Infinity, "T2" -> Infinity|>]];
        sMax = Max[s];
        If[sMax == 0, Return[<|"T1" -> Infinity, "T2" -> Infinity|>]];

        (* T1: time to reach 1-1/e of max entropy *)
        halfIdx = FirstPosition[s, _?(# >= sMax (1 - 1/E) &), {Length[s]}][[1]];
        t1 = t[[halfIdx]] - t[[1]];

        (* T2 ~ T1/2 for Markovian; estimate from entropy rate *)
        t2 = t1 / 2;

        <|"T1" -> t1, "T2" -> t2|>
    ];

(* ================================================================ *)
(* Export to Association (for serialization)                          *)
(* ================================================================ *)

EntropicResult /: Normal[EntropicResult[assoc_Association]] := assoc;

EntropicResult /: EntropicResult[assoc_Association]["Association"] := assoc;

(* ================================================================ *)
(* Format                                                            *)
(* ================================================================ *)

Format[EntropicResult[assoc_Association]] :=
    Interpretation[
        Panel[
            Column[{
                Style["EntropicResult", Bold, 14],
                Row[{"Steps: ", Length[assoc["Times"]]}],
                Row[{"Duration: ", If[Length[assoc["Times"]] > 0,
                    ScientificForm[Last[assoc["Times"]] - First[assoc["Times"]], 3],
                    "N/A"]}],
                Row[{"Final S: ", If[Length[assoc["Entropy"]] > 0,
                    NumberForm[Last[assoc["Entropy"]], 4],
                    "N/A"]}],
                Row[{"\!\(\*SubscriptBox[\(\[Tau]\), \(ent\)]\): ",
                    If[Length[assoc["EntropicTime"]] > 0,
                        ScientificForm[Last[assoc["EntropicTime"]], 3],
                        "N/A"]}],
                Row[{"Weight: ", If[Length[assoc["Weight"]] > 0,
                    ScientificForm[Last[assoc["Weight"]], 3],
                    "N/A"]}]
            }],
            FrameMargins -> 5
        ],
        EntropicResult[assoc]
    ];

End[];
