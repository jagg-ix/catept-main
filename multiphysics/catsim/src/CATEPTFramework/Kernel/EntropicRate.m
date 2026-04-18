(* ::Package:: *)
(* EntropicRate.m — Entropy production rate lambda(t)                *)
(*                                                                   *)
(* Supports:                                                         *)
(*   Constant rate:    EntropicRate[value, "Constant"]               *)
(*   Thermal rate:     EntropicRate["Thermal" -> T]                  *)
(*   RG running:       EntropicRate[base, "RG" -> {b, c2, lt0, mu0}]*)
(*   ENZ-enhanced:     EntropicRate[mat, "ENZ" -> True]              *)
(*   From function:    EntropicRate[fn]                              *)
(*   From track data:  EntropicRate[trackData, "Interpolation" -> m] *)
(*   Composed:         EntropicRate[base, "Coupler" -> coupler]      *)
(*                                                                   *)
(* Maps to: eq_3 (entropic time), eq_82 (RG running)                *)

(* Loaded within CATEPT` context by Init.m *)

Begin["CATEPT`Private`"];

(* ================================================================ *)
(* LambdaTildeRunning — one-loop RG running coupling                 *)
(* Eq 82: lambda~(mu) = lambda~_0 / (1 + b lambda~_0 ln(mu/mu_0))  *)
(* ================================================================ *)

LambdaTildeRunning[mu_?NumericQ, {b_?NumericQ, c2_?NumericQ,
        lambdaTilde0_?NumericQ, mu0_?NumericQ}] :=
    Module[{denom},
        If[lambdaTilde0 == 0, Return[0.0]];
        If[mu <= 0 || mu0 <= 0, Return[lambdaTilde0]];
        denom = 1 + b * lambdaTilde0 * Log[mu / mu0];
        If[denom <= 0, 0.0, lambdaTilde0 / denom]
    ];

(* Symbolic form *)
LambdaTildeRunning[mu_Symbol, {b_, c2_, lambdaTilde0_, mu0_}] :=
    lambdaTilde0 / (1 + b * lambdaTilde0 * Log[mu / mu0]);

(* ================================================================ *)
(* EntropicRate constructors                                         *)
(* ================================================================ *)

(* Constant rate *)
EntropicRate[value_?NumericQ, "Constant"] :=
    EntropicRate[<|
        "Type" -> "Constant",
        "Value" -> value,
        "Function" -> Function[{t}, value]
    |>];

EntropicRate[value_?NumericQ] := EntropicRate[value, "Constant"];

(* Thermal rate: lambda = k_B T / hbar *)
EntropicRate["Thermal" -> temperature_?NumericQ] :=
    Module[{lambda0},
        lambda0 = CATEPT`Private`$kB * temperature / CATEPT`Private`$hbar;
        EntropicRate[<|
            "Type" -> "Thermal",
            "Temperature" -> temperature,
            "Value" -> lambda0,
            "Function" -> Function[{t}, lambda0]
        |>]
    ];

(* From a pure function *)
EntropicRate[fn_Function] :=
    EntropicRate[<|
        "Type" -> "Function",
        "Function" -> fn
    |>];

(* ENZ material rate with optional RG running *)
EntropicRate[mat_ENZMaterial, opts___Rule] :=
    Module[{rules, temp, rgParams, useENZ, omega0, lambdaBase, rgFactor, fn},
        rules = Association[opts];
        temp = Lookup[rules, "Temperature", 300.0];
        rgParams = Lookup[rules, "RG", None];
        useENZ = Lookup[rules, "ENZ", True];

        omega0 = ENZFrequency[mat];
        lambdaBase = If[useENZ,
            ENZDecoherenceRate[mat, omega0, temp],
            CATEPT`Private`$kB * temp / CATEPT`Private`$hbar
        ];

        (* Apply RG running factor if provided *)
        rgFactor = If[rgParams =!= None && ListQ[rgParams] && Length[rgParams] >= 4,
            Module[{b, c2, lt0, mu0, muGeV, ltMu},
                {b, c2, lt0, mu0} = rgParams;
                muGeV = CATEPT`Private`$hbar * omega0 / (1.602176634`*^-19 * 1*^9);
                ltMu = LambdaTildeRunning[muGeV, rgParams];
                If[lt0 > 0, ltMu / lt0, 1.0]
            ],
            1.0
        ];

        fn = Function[{t}, lambdaBase * rgFactor];

        EntropicRate[<|
            "Type" -> "ENZ",
            "Material" -> mat,
            "Temperature" -> temp,
            "RGParams" -> rgParams,
            "ENZEnhanced" -> useENZ,
            "BaseRate" -> lambdaBase,
            "RGFactor" -> rgFactor,
            "Value" -> lambdaBase * rgFactor,
            "Function" -> fn
        |>]
    ];

(* With spacetime coupler *)
EntropicRate[base_, "Coupler" -> coupler_SpacetimeCoupler] :=
    Module[{baseRate, fn},
        baseRate = If[MatchQ[base, _EntropicRate],
            base,
            EntropicRate[base]
        ];
        fn = Function[{t},
            baseRate["Evaluate", t] * SpacetimeCouplerFactor[coupler, t]
        ];
        EntropicRate[<|
            "Type" -> "Coupled",
            "BaseRate" -> baseRate,
            "Coupler" -> coupler,
            "Function" -> fn
        |>]
    ];

(* From interpolation data (e.g. Geant4 track) *)
EntropicRate[times_List, lambdas_List, opts___Rule] /;
        Length[times] == Length[lambdas] :=
    Module[{rules, method, ifn},
        rules = Association[opts];
        method = Lookup[rules, "Interpolation", "Linear"];
        ifn = Interpolation[
            Transpose[{times, lambdas}],
            InterpolationOrder -> Switch[method,
                "Linear", 1,
                "Cubic", 3,
                _, 1
            ]
        ];
        EntropicRate[<|
            "Type" -> "Interpolated",
            "Times" -> times,
            "Lambdas" -> lambdas,
            "Method" -> method,
            "Function" -> Function[{t}, ifn[t]]
        |>]
    ];

(* ================================================================ *)
(* Property access                                                   *)
(* ================================================================ *)

EntropicRate /: EntropicRate[assoc_Association]["Evaluate", t_] :=
    assoc["Function"][t];

EntropicRate /: EntropicRate[assoc_Association]["Function"] :=
    assoc["Function"];

EntropicRate /: EntropicRate[assoc_Association]["Type"] :=
    assoc["Type"];

EntropicRate /: EntropicRate[assoc_Association]["Value"] :=
    Lookup[assoc, "Value", Indeterminate];

EntropicRate /: EntropicRate[assoc_Association][prop_String] :=
    Lookup[assoc, prop, Missing["Property", prop]];

(* Callable: rate[t] evaluates at time t *)
EntropicRate /: EntropicRate[assoc_Association][t_?NumericQ] :=
    assoc["Function"][t];

(* ================================================================ *)
(* Entropic time integration                                         *)
(* tau_ent(t) = Integrate[lambda(t'), {t', 0, t}]                   *)
(* ================================================================ *)

EntropicTime[tlist_List, lambdaValues_List] /;
        Length[tlist] == Length[lambdaValues] :=
    Module[{dt, midLambda, cumulative},
        If[Length[tlist] <= 1, Return[ConstantArray[0.0, Length[tlist]]]];
        dt = Differences[tlist];
        midLambda = MovingAverage[lambdaValues, 2];
        cumulative = FoldList[Plus, 0.0, dt * midLambda];
        cumulative
    ];

EntropicTime[tlist_List, rate_EntropicRate] :=
    EntropicTime[tlist, rate["Evaluate", #] & /@ tlist];

(* ================================================================ *)
(* cSF weight                                                        *)
(* Eq 54: weight = exp(-S_I / hbar)                                  *)
(* ================================================================ *)

CSFWeight[sI_?NumericQ] := Exp[-sI / CATEPT`Private`$hbar];
CSFWeight[sI_?NumericQ, hbar_?NumericQ] := Exp[-sI / hbar];

(* ================================================================ *)
(* Format                                                            *)
(* ================================================================ *)

Format[EntropicRate[assoc_Association]] :=
    Interpretation[
        Row[{"EntropicRate[", Style[assoc["Type"], Bold],
             If[KeyExistsQ[assoc, "Value"],
                Row[{", \[Lambda]=", ScientificForm[assoc["Value"], 3]}],
                ""
             ],
             "]"}],
        EntropicRate[assoc]
    ];

End[];
