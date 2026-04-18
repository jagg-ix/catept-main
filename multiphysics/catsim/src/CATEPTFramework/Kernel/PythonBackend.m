(* ::Package:: *)
(* PythonBackend.m — Bridge to QuTiP entropic dynamics packages       *)
(*                                                                     *)
(* Compiles EntropicEvolve expressions to Python/QuTiP calls via       *)
(* ExternalEvaluate. Round-trips numpy arrays as packed Wolfram lists.  *)
(*                                                                     *)
(* Requires:                                                           *)
(*   pip install qutip numpy scipy                                     *)
(*   The qutip_entropic_dynamics package on PYTHONPATH                 *)

(* Loaded within CATEPT` context by Init.m *)
(* Public symbols declared in Init.m *)

Begin["CATEPT`Private`"];

(* ================================================================ *)
(* Python session management                                         *)
(* ================================================================ *)

$PythonSessionID = "CATEPT_QuTiP";

getPythonSession[] :=
    Module[{},
        If[!ValueQ[$cateptPythonSession] || $cateptPythonSession === $Failed,
            $cateptPythonSession = StartExternalSession[<|
                "System" -> "Python",
                "Name" -> $PythonSessionID,
                "SessionProlog" -> "
import numpy as np
import sys, os

def _prepend_if_dir(path):
    if os.path.isdir(path) and path not in sys.path:
        sys.path.insert(0, path)

_cwd = os.getcwd()
_candidates = [
    _cwd,
    os.path.join(_cwd, 'multiphysics'),
    os.path.join(_cwd, 'multiphysics', 'catsim', 'src'),
    os.path.abspath(os.path.join(_cwd, '..')),
    os.path.join(os.path.abspath(os.path.join(_cwd, '..')), 'multiphysics'),
    os.path.join(os.path.abspath(os.path.join(_cwd, '..')), 'multiphysics', 'catsim', 'src'),
]

for _p in _candidates:
    _prepend_if_dir(_p)
"
            |>]
        ];
        $cateptPythonSession
    ];

(* ================================================================ *)
(* Matrix serialization: Wolfram matrix -> Python numpy string       *)
(* ================================================================ *)

matrixToPython[mat_?MatrixQ] :=
    Module[{rows},
        rows = StringRiffle[
            Map[
                "[" <> StringRiffle[
                    Map[toPyComplex, #], ", "
                ] <> "]" &,
                mat
            ],
            ", "
        ];
        "np.array([" <> rows <> "], dtype=complex)"
    ];

vectorToPython[vec_?VectorQ] :=
    "np.array([" <> StringRiffle[Map[toPyComplex, vec], ", "] <> "], dtype=complex)";

toPyComplex[z_?NumericQ] :=
    Module[{re, im},
        re = Re[N[z]];
        im = Im[N[z]];
        If[im == 0,
            ToString[CForm[re]],
            "complex(" <> ToString[CForm[re]] <> "," <> ToString[CForm[im]] <> ")"
        ]
    ];

listToPython[lst_List] :=
    "np.array([" <> StringRiffle[ToString[CForm[N[#]]] & /@ lst, ", "] <> "])";

(* ================================================================ *)
(* Generic typed-command bridge                                      *)
(* ================================================================ *)

keyName[k_String] := k;
keyName[k_Symbol] := SymbolName[k];
keyName[k_] := ToString[k, InputForm];

normalizeRules[opts___Rule] :=
    Association @ KeyValueMap[(keyName[#1] -> #2) &, Association[opts]];

renameKeys[assoc_Association, mapping_Association] :=
    Association @ KeyValueMap[(Lookup[mapping, #1, #1] -> #2) &, assoc];

extractGridAndSpacing[assoc_Association] :=
    Module[{out, grid, spacing},
        out = assoc;
        grid = Lookup[out, "Grid", Missing["KeyAbsent", "Grid"]];
        spacing = Lookup[out, "Spacing", Missing["KeyAbsent", "Spacing"]];

        If[ListQ[grid] && Length[grid] == 3,
            out["nx"] = grid[[1]];
            out["ny"] = grid[[2]];
            out["nz"] = grid[[3]];
        ];
        If[ListQ[spacing] && Length[spacing] == 3,
            out["dx"] = spacing[[1]];
            out["dy"] = spacing[[2]];
            out["dz"] = spacing[[3]];
        ];
        KeyDrop[out, {"Grid", "Spacing"}]
    ];

normalizeTransformName[val_] :=
    Module[{s},
        s = ToLowerCase @ ToString[val];
        Which[
            s == "jordanwigner", "jordan_wigner",
            s == "bravyikitaev", "bravyi_kitaev",
            True, s
        ]
    ];

pythonStringLiteral[s_String] :=
    "\"" <> StringReplace[s, {
        "\\" -> "\\\\",
        "\"" -> "\\\"",
        "\n" -> "\\n",
        "\r" -> "\\r",
        "\t" -> "\\t"
    }] <> "\"";

Options[CATEPTExecuteCommand] = {
    "DryRun" -> False,
    "ReturnEnvelope" -> False
};

CATEPTExecuteCommand[commandType_String, params_Association : <||>, opts___Rule] :=
    Module[{rules, payload, jsonPayload, code, session, pyResult},
        rules = normalizeRules[opts];
        payload = <|
            "command_type" -> commandType,
            "params" -> Normal[params]
        |>;

        If[TrueQ[Lookup[rules, "ReturnEnvelope", False]] ||
                TrueQ[Lookup[rules, "DryRun", False]],
            Return[payload]
        ];

        jsonPayload = ExportString[payload, "RawJSON"];
        code = StringJoin[
            "import json\n",
            "from qf_qutip_dsl.compat import make_command, execute_command\n",
            "payload = json.loads(" <> pythonStringLiteral[jsonPayload] <> ")\n",
            "cmd = make_command(payload['command_type'], payload.get('params', {}))\n",
            "execute_command(cmd)\n"
        ];

        session = getPythonSession[];
        pyResult = ExternalEvaluate[session, code];
        If[FailureQ[pyResult],
            Message[CATEPTExecuteCommand::pyerr, pyResult];
            Return[$Failed]
        ];
        pyResult
    ];

CATEPTExecuteCommand::pyerr = "Python typed command evaluation failed: `1`";

bridgeRuleKeys = {"DryRun", "ReturnEnvelope"};

splitBridgeRules[assoc_Association] :=
    <|
        "Bridge" -> KeyTake[assoc, bridgeRuleKeys],
        "Command" -> KeyDrop[assoc, bridgeRuleKeys]
    |>;

couplerToParams[coupler_] :=
    Module[{assoc, out},
        assoc = Replace[coupler, SpacetimeCoupler[a_Association] :> a, {0}];
        out = <|"type" -> "Identity"|>;
        If[AssociationQ[assoc],
            If[KeyExistsQ[assoc, "Type"], out["type"] = ToString[assoc["Type"]]];
            If[KeyExistsQ[assoc, "Mass"], out["mass_kg"] = assoc["Mass"]];
            If[KeyExistsQ[assoc, "Radius"], out["r_m"] = assoc["Radius"]];
            If[KeyExistsQ[assoc, "EFEGain"], out["efe_gain"] = assoc["EFEGain"]];
        ];
        out
    ];

(* ================================================================ *)
(* Generate Python source code for an EntropicEvolve call            *)
(* ================================================================ *)

ToPythonCode[ham_EntropicHamiltonian, initialState_?QuantumStateQ,
        tlist_List, opts___Rule] :=
    Module[{rules, solver, hbar, hRMat, jMat, rateFn, psi0,
            lambdaValues, code},

        rules = Association[opts];
        solver = Lookup[rules, "Solver", "ComplexAction"];
        hbar = Lookup[rules, "hbar", CATEPT`Private`$hbar];

        hRMat = ham["HR"]["MatrixRepresentation"];
        jMat = ham["J"]["MatrixRepresentation"];
        psi0 = initialState["StateVector"];

        (* Evaluate lambda at each time point *)
        lambdaValues = ham["Rate"]["Evaluate", #] & /@ tlist;

        code = StringJoin[
            "import numpy as np\n",
            "from scipy.interpolate import interp1d\n",
            "\n",
            "# Hamiltonian matrices\n",
            "H_R = ", matrixToPython[hRMat], "\n",
            "J = ", matrixToPython[jMat], "\n",
            "psi0 = ", vectorToPython[psi0], "\n",
            "tlist = ", listToPython[tlist], "\n",
            "lambda_values = ", listToPython[lambdaValues], "\n",
            "hbar = ", ToString[CForm[N[hbar]]], "\n",
            "\n",
            "# Lambda interpolation\n",
            "lambda_fn = interp1d(tlist, lambda_values, kind='linear',\n",
            "                     fill_value='extrapolate')\n",
            "\n",
            Switch[solver,
                "ComplexAction",
                StringJoin[
                    "# Complex action evolution\n",
                    "try:\n",
                    "    from qutip_entropic_dynamics import evolve_complex_action\n",
                    "    import qutip as qt\n",
                    "    H_R_qobj = qt.Qobj(H_R)\n",
                    "    J_qobj = qt.Qobj(J)\n",
                    "    psi0_qobj = qt.Qobj(psi0.reshape(-1, 1))\n",
                    "    result = evolve_complex_action(H_R_qobj, J_qobj, psi0_qobj,\n",
                    "                                   tlist, lambda_fn, hbar=hbar)\n",
                    "except ImportError:\n",
                    "    # Fallback: pure numpy solver\n",
                    "    from catept_numpy_solver import evolve_complex_action_numpy\n",
                    "    result = evolve_complex_action_numpy(H_R, J, psi0, tlist,\n",
                    "                                         lambda_fn, hbar=hbar)\n"
                ],
                "Lindblad",
                StringJoin[
                    "# Lindblad master equation\n",
                    "from qutip_entropic_dynamics import entropic_mesolve\n",
                    "import qutip as qt\n",
                    "H_qobj = qt.Qobj(H_R)\n",
                    "psi0_qobj = qt.Qobj(psi0.reshape(-1, 1))\n",
                    "result = entropic_mesolve(H_qobj, psi0_qobj * psi0_qobj.dag(),\n",
                    "                          tlist)\n"
                ],
                _,
                "raise NotImplementedError('Solver: " <> solver <> "')\n"
            ],
            "\n",
            "# Extract results as numpy arrays\n",
            "output = {\n",
            "    'times': result.times.tolist(),\n",
            "    'entropy': result.entropy.tolist() if result.entropy is not None else [],\n",
            "    'lambda_ent': result.lambda_ent.tolist() if result.lambda_ent is not None else [],\n",
            "    'tau_ent': result.tau_ent.tolist() if result.tau_ent is not None else [],\n",
            "}\n",
            "output\n"
        ];

        code
    ];

(* ================================================================ *)
(* Execute via Python                                                *)
(* ================================================================ *)

EntropicEvolvePython[ham_EntropicHamiltonian, initialState_?QuantumStateQ,
        tlist_List, opts___Rule] :=
    Module[{code, session, pyResult, times, entropy, lambdaEnt, tauEnt, weight},

        code = ToPythonCode[ham, initialState, tlist, opts];
        session = getPythonSession[];

        pyResult = ExternalEvaluate[session, code];

        If[FailureQ[pyResult],
            Message[EntropicEvolvePython::pyerr, pyResult];
            Return[$Failed]
        ];

        times = Lookup[pyResult, "times", tlist];
        entropy = Lookup[pyResult, "entropy", {}];
        lambdaEnt = Lookup[pyResult, "lambda_ent", {}];
        tauEnt = Lookup[pyResult, "tau_ent", {}];
        weight = If[Length[tauEnt] > 0,
            Exp[-tauEnt * CATEPT`Private`$hbar / Lookup[Association[opts], "hbar", CATEPT`Private`$hbar]],
            {}
        ];

        EntropicResult[<|
            "Times" -> times,
            "States" -> {},
            "Expect" -> <||>,
            "Entropy" -> entropy,
            "LambdaEnt" -> lambdaEnt,
            "EntropicTime" -> tauEnt,
            "Weight" -> weight,
            "SI" -> If[Length[tauEnt] > 0,
                tauEnt * CATEPT`Private`$hbar, {}],
            "Stats" -> <|
                "Solver" -> "Python/QuTiP",
                "Backend" -> "ExternalEvaluate",
                "Steps" -> Length[times]
            |>
        |>]
    ];

EntropicEvolvePython::pyerr = "Python evaluation failed: `1`";

(* ================================================================ *)
(* Backend dispatch: EntropicEvolve with "Backend" -> "Python"       *)
(* ================================================================ *)

EntropicEvolve[ham_EntropicHamiltonian, initialState_?QuantumStateQ,
        tspec : {t_Symbol, t0_?NumericQ, tf_?NumericQ},
        opts___Rule] /; MemberQ[{opts}, "Backend" -> "Python"] :=
    Module[{nSteps, tlist, rules},
        rules = Association[opts];
        nSteps = Lookup[rules, "Steps", 200];
        tlist = Subdivide[t0, tf, nSteps];
        EntropicEvolvePython[ham, initialState, tlist, opts]
    ];

(* ================================================================ *)
(* Extended typed-command wrappers                                   *)
(* ================================================================ *)

ComplexEFE[metricType_String, opts___Rule] :=
    Module[{raw, split, cmd},
        raw = normalizeRules[opts];
        split = splitBridgeRules[raw];
        cmd = renameKeys[split["Command"], <|
            "LambdaMode" -> "lambda_mode",
            "Kappa" -> "kappa",
            "Mass" -> "mass_kg",
            "Radius" -> "r_m"
        |>];
        cmd = extractGridAndSpacing[cmd];
        cmd["metric_type"] = ToLowerCase[metricType];
        CATEPTExecuteCommand["ComplexEFE", cmd, Sequence @@ Normal[split["Bridge"]]]
    ];

ComplexEFE[opts___Rule] := ComplexEFE["flat", opts];

PathIntegral[opts___Rule] :=
    Module[{raw, split, cmd},
        raw = normalizeRules[opts];
        split = splitBridgeRules[raw];
        cmd = renameKeys[split["Command"], <|
            "NPaths" -> "n_paths",
            "NSteps" -> "n_steps",
            "TFinal" -> "t_final_s",
            "HBar" -> "hbar",
            "Mass" -> "mass",
            "Potential" -> "potential_type",
            "EntropyPotential" -> "entropy_potential_type",
            "Lambda" -> "lambda_val",
            "Seed" -> "seed"
        |>];
        CATEPTExecuteCommand["PathIntegral", cmd, Sequence @@ Normal[split["Bridge"]]]
    ];

SelfConsistentCoupler[coupler_, opts___Rule] :=
    Module[{raw, split, cmd, couplerParams},
        raw = normalizeRules[opts];
        split = splitBridgeRules[raw];
        cmd = renameKeys[split["Command"], <|
            "MaxIterations" -> "max_iterations",
            "Tolerance" -> "tolerance",
            "Relaxation" -> "relaxation",
            "EFEGain" -> "efe_gain",
            "TimeStep" -> "dt",
            "Steps" -> "n_steps"
        |>];
        couplerParams = couplerToParams[coupler];
        cmd["coupler"] = couplerParams;
        CATEPTExecuteCommand["SelfConsistentCoupler", cmd, Sequence @@ Normal[split["Bridge"]]]
    ];

SelfConsistentCoupler[opts___Rule] :=
    SelfConsistentCoupler[SpacetimeCoupler["Identity"], opts];

MEEPCavity[opts___Rule] :=
    Module[{raw, split, cmd},
        raw = normalizeRules[opts];
        split = splitBridgeRules[raw];
        cmd = renameKeys[split["Command"], <|
            "Frequency" -> "frequency",
            "QFactor" -> "Q_factor",
            "ModeVolume" -> "mode_volume",
            "LambdaRate" -> "lambda_rate",
            "Resolution" -> "resolution",
            "RunTime" -> "run_time",
            "Metric" -> "metric_type"
        |>];
        CATEPTExecuteCommand["MEEPCavity", cmd, Sequence @@ Normal[split["Bridge"]]]
    ];

OpenFOAMFlow[solver_String, opts___Rule] :=
    Module[{raw, split, cmd},
        raw = normalizeRules[opts];
        split = splitBridgeRules[raw];
        cmd = renameKeys[split["Command"], <|
            "InletVelocity" -> "inlet_velocity",
            "Nu" -> "nu",
            "Rho" -> "rho",
            "Turbulence" -> "turbulence_model",
            "Metric" -> "metric_type",
            "LambdaRate" -> "lambda_rate"
        |>];
        cmd = extractGridAndSpacing[cmd];
        cmd["solver"] = solver;
        CATEPTExecuteCommand["OpenFOAMFlow", cmd, Sequence @@ Normal[split["Bridge"]]]
    ];

OpenFOAMFlow[opts___Rule] := OpenFOAMFlow["simpleFoam", opts];

QEDVacuum[opts___Rule] :=
    Module[{raw, split, cmd},
        raw = normalizeRules[opts];
        split = splitBridgeRules[raw];
        cmd = renameKeys[split["Command"], <|
            "AlphaEM" -> "alpha_em",
            "ElectronMass" -> "m_electron",
            "MomentumSq" -> "momentum_sq",
            "ElectricField" -> "electric_field",
            "Metric" -> "metric_type",
            "LambdaRate" -> "lambda_rate"
        |>];
        cmd = extractGridAndSpacing[cmd];
        CATEPTExecuteCommand["QEDVacuum", cmd, Sequence @@ Normal[split["Bridge"]]]
    ];

OpenFermionHamiltonian[opts___Rule] :=
    Module[{raw, split, cmd, lattice},
        raw = normalizeRules[opts];
        split = splitBridgeRules[raw];
        cmd = renameKeys[split["Command"], <|
            "Model" -> "model",
            "Geometry" -> "geometry",
            "Basis" -> "basis",
            "Multiplicity" -> "multiplicity",
            "Charge" -> "charge",
            "Tunneling" -> "tunneling",
            "Coulomb" -> "coulomb",
            "Transform" -> "transform",
            "LambdaRate" -> "lambda_rate",
            "Metric" -> "metric_type",
            "Backend" -> "backend",
            "Method" -> "method",
            "DFTFunctional" -> "dft_functional",
            "RunGradient" -> "run_gradient"
        |>];
        lattice = Lookup[cmd, "Lattice", Missing["KeyAbsent", "Lattice"]];
        If[ListQ[lattice] && Length[lattice] == 2,
            cmd["x_dim"] = lattice[[1]];
            cmd["y_dim"] = lattice[[2]];
        ];
        cmd = KeyDrop[cmd, {"Lattice"}];
        If[KeyExistsQ[cmd, "transform"],
            cmd["transform"] = normalizeTransformName[cmd["transform"]]
        ];
        CATEPTExecuteCommand["OpenFermionHamiltonian", cmd, Sequence @@ Normal[split["Bridge"]]]
    ];

PySCFMolecular[opts___Rule] :=
    Module[{raw, split, cmd},
        raw = normalizeRules[opts];
        split = splitBridgeRules[raw];
        cmd = renameKeys[split["Command"], <|
            "Geometry" -> "geometry",
            "Basis" -> "basis",
            "Charge" -> "charge",
            "Spin" -> "spin",
            "Method" -> "method",
            "XCFunctional" -> "xc_functional",
            "LambdaRate" -> "lambda_rate",
            "Metric" -> "metric_type",
            "ComputeDensityMatrix" -> "compute_density_matrix",
            "ComputeFockMatrix" -> "compute_fock_matrix",
            "ComputeDipole" -> "compute_dipole",
            "NActiveOrbitals" -> "n_active_orbitals",
            "NActiveElectrons" -> "n_active_electrons"
        |>];
        CATEPTExecuteCommand["PySCFMolecular", cmd, Sequence @@ Normal[split["Bridge"]]]
    ];

DiracRelativistic[opts___Rule] :=
    Module[{raw, split, cmd},
        raw = normalizeRules[opts];
        split = splitBridgeRules[raw];
        cmd = renameKeys[split["Command"], <|
            "Geometry" -> "geometry",
            "Basis" -> "basis",
            "Charge" -> "charge",
            "Spin" -> "spin",
            "Hamiltonian" -> "hamiltonian_type",
            "Method" -> "method",
            "XCFunctional" -> "xc_functional",
            "SpeedOfLight" -> "speed_of_light",
            "ComputeParityViolation" -> "compute_pv",
            "ComputeNMR" -> "compute_nmr",
            "ComputeEPR" -> "compute_epr",
            "ComputePolarizability" -> "compute_polarizability",
            "LambdaRate" -> "lambda_rate",
            "Metric" -> "metric_type"
        |>];
        CATEPTExecuteCommand["DiracRelativistic", cmd, Sequence @@ Normal[split["Bridge"]]]
    ];

CirqResource[opts___Rule] :=
    Module[{raw, split, cmd},
        raw = normalizeRules[opts];
        split = splitBridgeRules[raw];
        cmd = renameKeys[split["Command"], <|
            "Model" -> "model",
            "Algorithm" -> "algorithm",
            "Transform" -> "transform",
            "Geometry" -> "geometry",
            "Basis" -> "basis",
            "Multiplicity" -> "multiplicity",
            "Charge" -> "charge",
            "XDim" -> "x_dim",
            "YDim" -> "y_dim",
            "Tunneling" -> "tunneling",
            "Coulomb" -> "coulomb",
            "TrotterOrder" -> "trotter_order",
            "TrotterSteps" -> "trotter_steps",
            "TargetPrecision" -> "target_precision",
            "CodeDistance" -> "code_distance",
            "PhysicalErrorRate" -> "physical_error_rate",
            "LambdaRate" -> "lambda_rate",
            "Metric" -> "metric_type"
        |>];
        If[KeyExistsQ[cmd, "transform"],
            cmd["transform"] = normalizeTransformName[cmd["transform"]]
        ];
        CATEPTExecuteCommand["CirqResource", cmd, Sequence @@ Normal[split["Bridge"]]]
    ];

KwantTransport[opts___Rule] :=
    Module[{raw, split, cmd},
        raw = normalizeRules[opts];
        split = splitBridgeRules[raw];
        cmd = renameKeys[split["Command"], <|
            "Lattice" -> "lattice_type",
            "Width" -> "width",
            "Length" -> "length",
            "LambdaEnt" -> "lambda_ent",
            "BField" -> "B_field",
            "Metric" -> "metric_type",
            "NEnergyPoints" -> "n_energy_points",
            "ComputeHall" -> "compute_hall",
            "ComputeDecoherenceLength" -> "compute_decoherence_length",
            "LambdaRate" -> "lambda_rate"
        |>];
        CATEPTExecuteCommand["KwantTransport", cmd, Sequence @@ Normal[split["Bridge"]]]
    ];

PythTBBands[opts___Rule] :=
    Module[{raw, split, cmd},
        raw = normalizeRules[opts];
        split = splitBridgeRules[raw];
        cmd = renameKeys[split["Command"], <|
            "Model" -> "lattice_type",
            "Dimension" -> "dimension",
            "T1" -> "t1",
            "T2" -> "t2",
            "NKPoints" -> "n_k_points",
            "Phi" -> "phi",
            "M" -> "M",
            "ComputeBerry" -> "compute_berry",
            "ComputeChern" -> "compute_chern",
            "LambdaRate" -> "lambda_rate"
        |>];
        CATEPTExecuteCommand["PythTBBands", cmd, Sequence @@ Normal[split["Bridge"]]]
    ];

End[];
