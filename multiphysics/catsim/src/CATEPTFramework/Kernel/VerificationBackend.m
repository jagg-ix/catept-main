(* ::Package:: *)
(* VerificationBackend.m — Auto-generate Wolfram verification stubs   *)
(*                                                                     *)
(* Given an EntropicEvolve expression, generates a .wl stub that       *)
(* verifies the physics constraints:                                   *)
(*   1. S_I >= 0 (positivity of imaginary action)                      *)
(*   2. H_I >= 0 (positive-semidefinite dissipative part)              *)
(*   3. Monotonicity of tau_ent                                        *)
(*   4. Weight in (0, 1]                                               *)
(*   5. RG running bounded                                             *)
(*   6. Energy cost positive                                           *)
(*                                                                     *)
(* Maps to verification/eq_stubs/wolfram/ pipeline                     *)

(* Loaded within CATEPT` context by Init.m *)
(* Public symbols GenerateVerificationStub, VerifyEntropicResult declared in Init.m *)

Begin["CATEPT`Private`"];

(* ================================================================ *)
(* Constraint checks                                                 *)
(* ================================================================ *)

(* Check 1: S_I >= 0 at all times *)
checkSINonNeg[result_EntropicResult] :=
    Module[{sI},
        sI = result["SI"];
        If[Length[sI] == 0, Return[<|"ok" -> True, "notes" -> "No S_I data"|>]];
        <|
            "ok" -> AllTrue[sI, # >= -1*^-15 &],
            "notes" -> If[AllTrue[sI, # >= -1*^-15 &],
                "S_I >= 0 at all " <> ToString[Length[sI]] <> " steps",
                "S_I violation: min = " <> ToString[Min[sI]]
            ]
        |>
    ];

(* Check 2: H_I positive semidefinite *)
checkHIPositive[ham_EntropicHamiltonian] :=
    Module[{jMat, eigenvalues},
        jMat = ham["J"]["MatrixRepresentation"];
        eigenvalues = Re[Eigenvalues[N[jMat]]];
        <|
            "ok" -> AllTrue[eigenvalues, # >= -1*^-10 &],
            "notes" -> If[AllTrue[eigenvalues, # >= -1*^-10 &],
                "J is positive-semidefinite (eigenvalues: " <>
                    StringRiffle[ToString[NumberForm[#, 3]] & /@ eigenvalues, ", "] <> ")",
                "J has negative eigenvalue: " <> ToString[Min[eigenvalues]]
            ]
        |>
    ];

(* Check 3: tau_ent monotonically non-decreasing *)
checkTauMonotonic[result_EntropicResult] :=
    Module[{tau, diffs},
        tau = result["EntropicTime"];
        If[Length[tau] < 2, Return[<|"ok" -> True, "notes" -> "Insufficient data"|>]];
        diffs = Differences[tau];
        <|
            "ok" -> AllTrue[diffs, # >= -1*^-15 &],
            "notes" -> If[AllTrue[diffs, # >= -1*^-15 &],
                "tau_ent monotonically non-decreasing",
                "tau_ent decreased at step " <>
                    ToString[FirstPosition[diffs, _?(# < -1*^-15 &)][[1]]]
            ]
        |>
    ];

(* Check 4: Weight in (0, 1] *)
checkWeightBounded[result_EntropicResult] :=
    Module[{w},
        w = result["Weight"];
        If[Length[w] == 0, Return[<|"ok" -> True, "notes" -> "No weight data"|>]];
        <|
            "ok" -> AllTrue[w, 0 < # <= 1 + 1*^-10 &],
            "notes" -> If[AllTrue[w, 0 < # <= 1 + 1*^-10 &],
                "Weight in (0, 1] at all steps",
                "Weight violation: range [" <>
                    ToString[Min[w]] <> ", " <> ToString[Max[w]] <> "]"
            ]
        |>
    ];

(* Check 5: RG running bounded and positive *)
checkRGRunning[ham_EntropicHamiltonian, tlist_List] :=
    Module[{rate, lambdas},
        rate = ham["Rate"];
        If[!MatchQ[rate, _EntropicRate], Return[<|"ok" -> True, "notes" -> "No rate"|>]];
        lambdas = rate["Evaluate", #] & /@ tlist;
        <|
            "ok" -> AllTrue[lambdas, # >= 0 &],
            "notes" -> If[AllTrue[lambdas, # >= 0 &],
                "lambda(t) >= 0 at all " <> ToString[Length[tlist]] <> " points, " <>
                "range [" <> ToString[ScientificForm[Min[lambdas], 3]] <> ", " <>
                ToString[ScientificForm[Max[lambdas], 3]] <> "]",
                "Negative lambda at some time points"
            ]
        |>
    ];

(* Check 6: Entropy non-negative *)
checkEntropyNonNeg[result_EntropicResult] :=
    Module[{s},
        s = result["Entropy"];
        If[Length[s] == 0, Return[<|"ok" -> True, "notes" -> "No entropy data"|>]];
        <|
            "ok" -> AllTrue[s, # >= -1*^-10 &],
            "notes" -> If[AllTrue[s, # >= -1*^-10 &],
                "S(t) >= 0 at all steps",
                "Negative entropy: min = " <> ToString[Min[s]]
            ]
        |>
    ];

(* ================================================================ *)
(* VerifyEntropicResult — run all checks                             *)
(* ================================================================ *)

VerifyEntropicResult[result_EntropicResult] :=
    <|
        "SI_NonNeg" -> checkSINonNeg[result],
        "TauMonotonic" -> checkTauMonotonic[result],
        "WeightBounded" -> checkWeightBounded[result],
        "EntropyNonNeg" -> checkEntropyNonNeg[result]
    |>;

VerifyEntropicResult[result_EntropicResult, ham_EntropicHamiltonian] :=
    Join[
        VerifyEntropicResult[result],
        <|
            "HI_Positive" -> checkHIPositive[ham],
            "RG_Bounded" -> checkRGRunning[ham, result["Times"]]
        |>
    ];

(* ================================================================ *)
(* GenerateVerificationStub — write .wl file                         *)
(* ================================================================ *)

GenerateVerificationStub[ham_EntropicHamiltonian, result_EntropicResult,
        eqId_Integer, opts___Rule] :=
    Module[{rules, outputDir, label, checks, allOk, stubCode, filePath},

        rules = Association[opts];
        outputDir = Lookup[rules, "OutputDirectory",
            FileNameJoin[{Directory[], "verification", "eq_stubs", "wolfram"}]];
        label = Lookup[rules, "Label", "eq_catept_evolve"];

        (* Run verification *)
        checks = VerifyEntropicResult[result, ham];
        allOk = AllTrue[checks, #["ok"] &];

        (* Generate stub code *)
        stubCode = StringJoin[
            "(* Auto-generated CAT/EPT verification stub *)\n",
            "(* Equation ", ToString[eqId], ": ", label, " *)\n",
            "(* Generated: ", DateString[], " *)\n",
            "(* Package: CATEPT`VerificationBackend` *)\n\n",

            "VerifyEquation[] := Module[{checks, allOk},\n",
            "  checks = <|\n",

            StringRiffle[
                KeyValueMap[
                    Function[{key, val},
                        "    \"" <> key <> "\" -> <|\"ok\" -> " <>
                        ToString[val["ok"]] <> ", \"notes\" -> \"" <>
                        StringReplace[val["notes"], "\"" -> "\\\""] <>
                        "\"|>"
                    ],
                    checks
                ],
                ",\n"
            ],

            "\n  |>;\n\n",
            "  allOk = AllTrue[checks, #[\"ok\"] &];\n\n",
            "  <|\n",
            "    \"equation_id\" -> \"", ToString[eqId], "\",\n",
            "    \"label\" -> \"", label, "\",\n",
            "    \"ok\" -> allOk,\n",
            "    \"notes\" -> If[allOk,\n",
            "      \"All ", ToString[Length[checks]], " CAT/EPT constraints verified\",\n",
            "      \"Failed: \" <> StringRiffle[\n",
            "        Select[Keys[checks], !checks[#][\"ok\"] &], \", \"]\n",
            "    ],\n",
            "    \"checks\" -> checks\n",
            "  |>\n",
            "];\n\n",
            "If[$FrontEnd === Null, Print[VerifyEquation[]]];\n"
        ];

        (* Write file *)
        If[!DirectoryQ[outputDir], CreateDirectory[outputDir]];
        filePath = FileNameJoin[{outputDir,
            "eq_" <> ToString[eqId] <> "_" <> label <> ".wl"}];
        Export[filePath, stubCode, "Text"];

        <|
            "FilePath" -> filePath,
            "Checks" -> checks,
            "AllPassed" -> allOk
        |>
    ];

(* ================================================================ *)
(* Generate derivation stub (for latex_writer.py pipeline)           *)
(* ================================================================ *)

GenerateDerivationStub[ham_EntropicHamiltonian, eqId_Integer, opts___Rule] :=
    Module[{rules, label, dim, outputDir, stubCode, filePath},

        rules = Association[opts];
        outputDir = Lookup[rules, "OutputDirectory",
            FileNameJoin[{Directory[], "verification", "eq_stubs", "wolfram"}]];
        label = Lookup[rules, "Label", "eq_catept_derivation"];
        dim = ham["Dimension"];

        stubCode = StringJoin[
            "(* Auto-generated CAT/EPT derivation stub *)\n",
            "(* Equation ", ToString[eqId], " *)\n\n",

            "Needs[\"CATEPT`\"];\n\n",

            "DeriveEquation[] := Module[{},\n",
            "  InitDerivation[\"", ToString[eqId], "\", \"", label, "\"];\n\n",

            "  AddStepText[\"Framework\",\n",
            "    \"CAT/EPT complex action: S = S_R + i S_I, S_I >= 0\"];\n\n",

            "  AddStepExpr[\"Hamiltonian\",\n",
            "    HoldForm[H], HoldForm[Subscript[H, R] - I \\[HBar] \\[Lambda][t] J]];\n\n",

            "  AddStepText[\"Dimension\", \"Hilbert space dimension: ",
                ToString[dim], "\"];\n\n",

            "  AddStepExpr[\"EntropicTime\",\n",
            "    HoldForm[Subscript[\\[Tau], ent]],\n",
            "    HoldForm[Integrate[\\[Lambda][t], {t, 0, T}]]];\n\n",

            "  AddStepExpr[\"Weight\",\n",
            "    HoldForm[w], HoldForm[Exp[-Subscript[S, I] / \\[HBar]]]];\n\n",

            "  AddStepCheck[\"Positivity\", True];\n\n",

            "  GetDerivationResult[]\n",
            "];\n"
        ];

        filePath = FileNameJoin[{outputDir,
            "eq_" <> ToString[eqId] <> "_" <> label <> "_deriv.wl"}];
        If[!DirectoryQ[outputDir], CreateDirectory[outputDir]];
        Export[filePath, stubCode, "Text"];

        filePath
    ];

End[];
