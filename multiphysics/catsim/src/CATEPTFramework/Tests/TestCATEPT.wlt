(* ::Package:: *)
(* TestCATEPT.wlt — Wolfram Testing Framework tests for CAT/EPT DSL   *)
(*                                                                     *)
(* Run with:                                                           *)
(*   << CATEPT`                                                        *)
(*   TestReport["TestCATEPT.wlt"]                                      *)
(*                                                                     *)
(* Or from command line:                                                *)
(*   wolframscript -file TestCATEPT.wlt                                *)

BeginTestSection["CAT/EPT Quantum Framework DSL"];

(* Load package *)
Needs["CATEPT`"];

(* ================================================================ *)
(* Section 1: Physical Constants                                     *)
(* ================================================================ *)

BeginTestSection["Physical Constants"];

VerificationTest[
    $CATEPTVersion,
    "0.1.0",
    TestID -> "Version"
];

VerificationTest[
    NumericQ[CATEPT`Private`$hbar],
    True,
    TestID -> "hbar-defined"
];

VerificationTest[
    NumericQ[CATEPT`Private`$kB],
    True,
    TestID -> "kB-defined"
];

EndTestSection[];

(* ================================================================ *)
(* Section 2: ENZ Material                                           *)
(* ================================================================ *)

BeginTestSection["ENZ Material"];

VerificationTest[
    MemberQ[$ENZMaterials, "ITO"],
    True,
    TestID -> "ITO-in-database"
];

VerificationTest[
    MatchQ[ENZMaterial["ITO"], _ENZMaterial],
    True,
    TestID -> "ITO-constructor"
];

(* Drude permittivity at ENZ frequency should have Re[eps] ~ 0 *)
VerificationTest[
    Module[{mat, wENZ, eps},
        mat = ENZMaterial["ITO"];
        wENZ = ENZFrequency[mat];
        eps = EpsilonDrude[mat, wENZ];
        Abs[Re[eps]] < 0.1
    ],
    True,
    TestID -> "ENZ-frequency-ReEps-near-zero"
];

(* Enhancement factor should be large at ENZ *)
VerificationTest[
    Module[{mat, wENZ},
        mat = ENZMaterial["ITO"];
        wENZ = ENZFrequency[mat];
        EnhancementFactor[mat, wENZ] > 2
    ],
    True,
    TestID -> "ENZ-enhancement-large"
];

(* ENZ wavelength should be near 1240 nm for ITO *)
VerificationTest[
    Module[{mat, wlM},
        mat = ENZMaterial["ITO"];
        wlM = ENZWavelength[mat];
        1100*^-9 < wlM < 1500*^-9
    ],
    True,
    TestID -> "ITO-wavelength-range"
];

(* Decoherence rate should be positive *)
VerificationTest[
    Module[{mat, wENZ},
        mat = ENZMaterial["ITO"];
        wENZ = ENZFrequency[mat];
        ENZDecoherenceRate[mat, wENZ, 300.0] > 0
    ],
    True,
    TestID -> "ENZ-decoherence-positive"
];

EndTestSection[];

(* ================================================================ *)
(* Section 3: EntropicRate                                           *)
(* ================================================================ *)

BeginTestSection["EntropicRate"];

(* Constant rate *)
VerificationTest[
    Module[{rate},
        rate = EntropicRate[42.0, "Constant"];
        rate["Evaluate", 0.0]
    ],
    42.0,
    TestID -> "constant-rate-value"
];

VerificationTest[
    Module[{rate},
        rate = EntropicRate[42.0];
        rate[0.5]
    ],
    42.0,
    TestID -> "constant-rate-callable"
];

(* Thermal rate: lambda = k_B T / hbar *)
VerificationTest[
    Module[{rate},
        rate = EntropicRate["Thermal" -> 300.0];
        rate["Value"] > 0
    ],
    True,
    TestID -> "thermal-rate-positive"
];

(* RG running: at reference scale, lambda = lambda_0 *)
VerificationTest[
    Abs[LambdaTildeRunning[1*^-9, {0.1, 0.05, 1*^-3, 1*^-9}] - 1*^-3] < 1*^-10,
    True,
    TestID -> "RG-reference-scale"
];

(* RG running: UV weakening *)
VerificationTest[
    Module[{low, high},
        low = LambdaTildeRunning[1*^-9, {0.1, 0.05, 1*^-3, 1*^-9}];
        high = LambdaTildeRunning[1*^3, {0.1, 0.05, 1*^-3, 1*^-9}];
        high < low
    ],
    True,
    TestID -> "RG-UV-weakening"
];

(* RG running: always positive *)
VerificationTest[
    AllTrue[
        {1*^-15, 1*^-9, 1.0, 1*^3, 1*^6},
        LambdaTildeRunning[#, {0.1, 0.05, 1*^-3, 1*^-9}] >= 0 &
    ],
    True,
    TestID -> "RG-always-positive"
];

(* Zero coupling stays zero *)
VerificationTest[
    LambdaTildeRunning[1.0, {0.1, 0.05, 0.0, 1*^-9}],
    0.0,
    TestID -> "RG-zero-stays-zero"
];

EndTestSection[];

(* ================================================================ *)
(* Section 4: Entropic Time Integration                              *)
(* ================================================================ *)

BeginTestSection["Entropic Time"];

(* Constant lambda: tau = lambda * T *)
VerificationTest[
    Module[{tlist, lambdas, tau},
        tlist = Subdivide[0.0, 1.0, 100];
        lambdas = ConstantArray[5.0, 101];
        tau = EntropicTime[tlist, lambdas];
        Abs[Last[tau] - 5.0] < 0.01
    ],
    True,
    TestID -> "entropic-time-constant"
];

(* Zero lambda: tau stays zero *)
VerificationTest[
    Module[{tlist, lambdas, tau},
        tlist = Subdivide[0.0, 1.0, 50];
        lambdas = ConstantArray[0.0, 51];
        tau = EntropicTime[tlist, lambdas];
        Last[tau] == 0.0
    ],
    True,
    TestID -> "entropic-time-zero"
];

(* Monotonicity *)
VerificationTest[
    Module[{tlist, lambdas, tau, diffs},
        tlist = Subdivide[0.0, 1.0, 100];
        lambdas = Table[Abs[Sin[2 Pi t] + 1], {t, tlist}];
        tau = EntropicTime[tlist, lambdas];
        diffs = Differences[tau];
        AllTrue[diffs, # >= -1*^-15 &]
    ],
    True,
    TestID -> "entropic-time-monotonic"
];

(* cSF weight *)
VerificationTest[
    CSFWeight[0.0] == 1.0,
    True,
    TestID -> "csf-weight-zero-SI"
];

VerificationTest[
    Module[{w},
        w = CSFWeight[CATEPT`Private`$hbar];  (* exp(-1) ~ 0.368 *)
        0 < w < 1
    ],
    True,
    TestID -> "csf-weight-positive-SI"
];

EndTestSection[];

(* ================================================================ *)
(* Section 5: SpacetimeCoupler                                       *)
(* ================================================================ *)

BeginTestSection["Spacetime Coupler"];

(* Hawking temperature positive *)
VerificationTest[
    HawkingTemperature[CATEPT`Private`$SolarMass] > 0,
    True,
    TestID -> "hawking-temperature-positive"
];

(* Hawking temperature inversely proportional to mass *)
VerificationTest[
    HawkingTemperature[CATEPT`Private`$SolarMass] >
    HawkingTemperature[10 CATEPT`Private`$SolarMass],
    True,
    TestID -> "hawking-temperature-inverse-mass"
];

(* Unruh temperature positive *)
VerificationTest[
    UnruhTemperature[9.8] > 0,
    True,
    TestID -> "unruh-temperature-positive"
];

(* Identity coupler: factor = 1 *)
VerificationTest[
    Module[{coupler},
        coupler = SpacetimeCoupler["Identity"];
        SpacetimeCouplerFactor[coupler, 0.0]
    ],
    1.0,
    TestID -> "identity-coupler-factor"
];

(* Schwarzschild: redshift < 1 *)
VerificationTest[
    Module[{coupler},
        coupler = SpacetimeCoupler["Schwarzschild",
            "Mass" -> 10 CATEPT`Private`$SolarMass,
            "Radius" -> 1*^8];
        SpacetimeCouplerFactor[coupler, 0.0] < 1.0
    ],
    True,
    TestID -> "schwarzschild-redshift-less-than-1"
];

EndTestSection[];

(* ================================================================ *)
(* Section 6: EntropicHamiltonian                                    *)
(* ================================================================ *)

BeginTestSection["EntropicHamiltonian"];

(* Construction *)
VerificationTest[
    Module[{ham},
        ham = EntropicHamiltonian[
            QuantumOperator[{{1, 0}, {0, -1}}],
            QuantumOperator[{{0, 0}, {0, 1}}],
            1.0
        ];
        ham["Dimension"]
    ],
    2,
    TestID -> "hamiltonian-dimension"
];

(* Named preset *)
VerificationTest[
    Module[{ham},
        ham = EntropicHamiltonian["Qubit", 2 Pi * 5*^9, 1*^6];
        ham["Dimension"]
    ],
    2,
    TestID -> "named-qubit-hamiltonian"
];

(* Complex matrix *)
VerificationTest[
    Module[{ham, hMat},
        ham = EntropicHamiltonian[
            QuantumOperator[{{1, 0}, {0, -1}}],
            QuantumOperator[{{0, 0}, {0, 1}}],
            EntropicRate[0.5, "Constant"]
        ];
        hMat = ComplexMatrix[ham, 0.0, 1.0];
        (* H = {{1,0},{0,-1}} - i*1.0*0.5*{{0,0},{0,1}}
             = {{1,0},{0,-1-0.5i}} *)
        Abs[hMat[[2, 2]] - (-1 - 0.5 I)] < 1*^-10
    ],
    True,
    TestID -> "complex-matrix-value"
];

EndTestSection[];

(* ================================================================ *)
(* Section 7: EntropicEvolve                                         *)
(* ================================================================ *)

BeginTestSection["EntropicEvolve"];

(* Basic evolution returns EntropicResult *)
VerificationTest[
    Module[{ham, result},
        ham = EntropicHamiltonian[
            QuantumOperator[{{1, 0}, {0, -1}}],
            QuantumOperator[{{0, 0}, {0, 1}}],
            EntropicRate[0.01, "Constant"]
        ];
        result = EntropicEvolve[ham, QuantumState["0"],
            {t, 0, 1.0}, "Steps" -> 50, "hbar" -> 1.0];
        MatchQ[result, _EntropicResult]
    ],
    True,
    TestID -> "evolve-returns-result"
];

(* Result has correct number of time steps *)
VerificationTest[
    Module[{ham, result},
        ham = EntropicHamiltonian[
            QuantumOperator[{{1, 0}, {0, -1}}],
            QuantumOperator[{{0, 0}, {0, 1}}],
            0.01
        ];
        result = EntropicEvolve[ham, QuantumState["0"],
            {t, 0, 1.0}, "Steps" -> 50, "hbar" -> 1.0];
        result["NumTimes"]
    ],
    51,  (* 50 intervals = 51 points *)
    TestID -> "evolve-num-steps"
];

(* Entropy trace exists and is non-negative *)
VerificationTest[
    Module[{ham, result},
        ham = EntropicHamiltonian[
            QuantumOperator[{{1, 0}, {0, -1}}],
            QuantumOperator[{{0, 0}, {0, 1}}],
            0.01
        ];
        result = EntropicEvolve[ham, QuantumState["0"],
            {t, 0, 1.0}, "Steps" -> 50, "hbar" -> 1.0];
        AllTrue[result["Entropy"], # >= -1*^-10 &]
    ],
    True,
    TestID -> "evolve-entropy-nonneg"
];

(* Entropic time monotonically increasing *)
VerificationTest[
    Module[{ham, result, diffs},
        ham = EntropicHamiltonian[
            QuantumOperator[{{1, 0}, {0, -1}}],
            QuantumOperator[{{0, 0}, {0, 1}}],
            0.1
        ];
        result = EntropicEvolve[ham, QuantumState["0"],
            {t, 0, 1.0}, "Steps" -> 100, "hbar" -> 1.0];
        diffs = Differences[result["EntropicTime"]];
        AllTrue[diffs, # >= -1*^-15 &]
    ],
    True,
    TestID -> "evolve-tau-monotonic"
];

(* Weight in (0, 1] *)
VerificationTest[
    Module[{ham, result},
        ham = EntropicHamiltonian[
            QuantumOperator[{{1, 0}, {0, -1}}],
            QuantumOperator[{{0, 0}, {0, 1}}],
            0.1
        ];
        result = EntropicEvolve[ham, QuantumState["0"],
            {t, 0, 1.0}, "Steps" -> 100, "hbar" -> 1.0];
        AllTrue[result["Weight"], 0 < # <= 1 + 1*^-10 &]
    ],
    True,
    TestID -> "evolve-weight-bounded"
];

(* Zero lambda: no dissipation *)
VerificationTest[
    Module[{ham, result},
        ham = EntropicHamiltonian[
            QuantumOperator[{{1, 0}, {0, -1}}],
            QuantumOperator[{{0, 0}, {0, 1}}],
            0.0
        ];
        result = EntropicEvolve[ham, QuantumState["0"],
            {t, 0, 1.0}, "Steps" -> 50, "hbar" -> 1.0];
        (* Weight should stay at 1 *)
        Abs[result["FinalWeight"] - 1.0] < 1*^-10
    ],
    True,
    TestID -> "evolve-zero-lambda-no-decay"
];

(* S_I non-negative *)
VerificationTest[
    Module[{ham, result},
        ham = EntropicHamiltonian[
            QuantumOperator[{{1, 0}, {0, -1}}],
            QuantumOperator[{{0, 0}, {0, 1}}],
            0.5
        ];
        result = EntropicEvolve[ham, QuantumState["0"],
            {t, 0, 1.0}, "Steps" -> 100, "hbar" -> 1.0];
        AllTrue[result["SI"], # >= -1*^-10 &]
    ],
    True,
    TestID -> "evolve-SI-nonneg"
];

EndTestSection[];

(* ================================================================ *)
(* Section 8: Verification Backend                                   *)
(* ================================================================ *)

BeginTestSection["Verification"];

(* VerifyEntropicResult passes for valid evolution *)
VerificationTest[
    Module[{ham, result, checks},
        ham = EntropicHamiltonian[
            QuantumOperator[{{1, 0}, {0, -1}}],
            QuantumOperator[{{0, 0}, {0, 1}}],
            0.01
        ];
        result = EntropicEvolve[ham, QuantumState["0"],
            {t, 0, 1.0}, "Steps" -> 50, "hbar" -> 1.0];
        checks = VerifyEntropicResult[result, ham];
        AllTrue[checks, #["ok"] &]
    ],
    True,
    TestID -> "verification-all-pass"
];

EndTestSection[];

(* ================================================================ *)
(* Section 9: EntropicChannel                                        *)
(* ================================================================ *)

BeginTestSection["EntropicChannel"];

(* Basic construction *)
VerificationTest[
    Module[{ch},
        ch = EntropicChannel[
            {QuantumOperator[{{0, 1}, {0, 0}}]},
            EntropicRate[1.0, "Constant"]
        ];
        ch["NJumps"]
    ],
    1,
    TestID -> "channel-njumps"
];

(* ENZ channel *)
VerificationTest[
    Module[{ch},
        ch = EntropicChannel[ENZMaterial["ITO"],
            "Duration" -> 1*^-13,
            "PhotonEnergy" -> 1.0
        ];
        ch["Dimension"]
    ],
    2,
    TestID -> "enz-channel-dimension"
];

EndTestSection[];

(* ================================================================ *)
(* Section 10: Typed command wrappers (bridge smoke tests)           *)
(* ================================================================ *)

BeginTestSection["TypedCommandBridge"];

VerificationTest[
    Module[{payload},
        payload = ComplexEFE[
            "flat",
            "Grid" -> {2, 3, 4},
            "Spacing" -> {0.1, 0.2, 0.3},
            "LambdaMode" -> "trace_adjusted",
            "DryRun" -> True
        ];
        payload["command_type"] == "ComplexEFE" &&
        payload["params"]["metric_type"] == "flat" &&
        payload["params"]["nx"] == 2 &&
        payload["params"]["ny"] == 3 &&
        payload["params"]["nz"] == 4 &&
        payload["params"]["dx"] == 0.1 &&
        payload["params"]["dy"] == 0.2 &&
        payload["params"]["dz"] == 0.3
    ],
    True,
    TestID -> "bridge-complex-efe-mapping"
];

VerificationTest[
    Module[{payload},
        payload = PathIntegral[
            "NPaths" -> 256,
            "NSteps" -> 32,
            "TFinal" -> 2.5,
            "Lambda" -> 0.125,
            "DryRun" -> True
        ];
        payload["command_type"] == "PathIntegral" &&
        payload["params"]["n_paths"] == 256 &&
        payload["params"]["n_steps"] == 32 &&
        payload["params"]["t_final_s"] == 2.5 &&
        payload["params"]["lambda_val"] == 0.125
    ],
    True,
    TestID -> "bridge-path-integral-mapping"
];

VerificationTest[
    Module[{payload, coupler},
        coupler = SpacetimeCoupler["Schwarzschild",
            "Mass" -> 2.5 CATEPT`Private`$SolarMass,
            "Radius" -> 2.0*^7,
            "EFEGain" -> 0.2
        ];
        payload = SelfConsistentCoupler[
            coupler,
            "MaxIterations" -> 12,
            "TimeStep" -> 0.02,
            "DryRun" -> True
        ];
        payload["command_type"] == "SelfConsistentCoupler" &&
        payload["params"]["max_iterations"] == 12 &&
        payload["params"]["dt"] == 0.02 &&
        payload["params"]["coupler"]["type"] == "Schwarzschild" &&
        NumericQ[payload["params"]["coupler"]["mass_kg"]] &&
        NumericQ[payload["params"]["coupler"]["r_m"]]
    ],
    True,
    TestID -> "bridge-self-consistent-coupler-mapping"
];

VerificationTest[
    Module[{payload},
        payload = OpenFermionHamiltonian[
            "Model" -> "hubbard",
            "Lattice" -> {4, 5},
            "Transform" -> "JordanWigner",
            "DryRun" -> True
        ];
        payload["command_type"] == "OpenFermionHamiltonian" &&
        payload["params"]["x_dim"] == 4 &&
        payload["params"]["y_dim"] == 5 &&
        payload["params"]["transform"] == "jordan_wigner"
    ],
    True,
    TestID -> "bridge-openfermion-transform-normalization"
];

VerificationTest[
    Module[{payload},
        payload = OpenFOAMFlow[
            "pisoFoam",
            "Grid" -> {12, 8, 6},
            "LambdaRate" -> 0.05,
            "DryRun" -> True
        ];
        payload["command_type"] == "OpenFOAMFlow" &&
        payload["params"]["solver"] == "pisoFoam" &&
        payload["params"]["nx"] == 12 &&
        payload["params"]["ny"] == 8 &&
        payload["params"]["nz"] == 6 &&
        payload["params"]["lambda_rate"] == 0.05
    ],
    True,
    TestID -> "bridge-openfoam-mapping"
];

EndTestSection[];

EndTestSection[];  (* Close top-level *)
