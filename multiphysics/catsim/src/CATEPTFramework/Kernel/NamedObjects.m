(* ::Package:: *)
(* NamedObjects.m — Preset configurations for common CAT/EPT scenarios *)
(*                                                                      *)
(* Provides named constructors for frequently-used configurations:      *)
(*   ENZ materials, spacetime geometries, qubit models, cavity models   *)

(* Loaded within CATEPT` context by Init.m *)

Begin["CATEPT`Private`"];

(* ================================================================ *)
(* Named EntropicHamiltonian presets                                 *)
(* ================================================================ *)

(* Qubit with amplitude damping *)
EntropicHamiltonian["Qubit", omega_?NumericQ, lambda_?NumericQ] :=
    EntropicHamiltonian[
        QuantumOperator[omega / 2 * {{1, 0}, {0, -1}}],   (* H_R = omega/2 sigma_z *)
        QuantumOperator[{{0, 0}, {0, 1}}],                  (* J = |1><1| *)
        EntropicRate[lambda, "Constant"]
    ];

(* Rabi-driven qubit *)
EntropicHamiltonian["RabiQubit", omega_?NumericQ, omegaR_?NumericQ,
        lambda_?NumericQ] :=
    EntropicHamiltonian[
        QuantumOperator[
            omega / 2 * {{1, 0}, {0, -1}} +
            omegaR / 2 * {{0, 1}, {1, 0}}
        ],
        QuantumOperator[{{0, 0}, {0, 1}}],
        EntropicRate[lambda, "Constant"]
    ];

(* Two-level system with ENZ-enhanced decoherence *)
EntropicHamiltonian["ENZQubit", omega_?NumericQ,
        materialName_String, temperature_?NumericQ] :=
    Module[{mat, rate},
        mat = ENZMaterial[materialName];
        rate = EntropicRate[mat, "Temperature" -> temperature];
        EntropicHamiltonian[
            QuantumOperator[omega / 2 * {{1, 0}, {0, -1}}],
            QuantumOperator[{{0, 0}, {0, 1}}],
            rate
        ]
    ];

EntropicHamiltonian["ENZQubit", omega_?NumericQ, materialName_String] :=
    EntropicHamiltonian["ENZQubit", omega, materialName, 300.0];

EntropicHamiltonian["ENZQubit", omega_?NumericQ] :=
    EntropicHamiltonian["ENZQubit", omega, "ITO", 300.0];

(* Jaynes-Cummings: qubit coupled to cavity mode *)
EntropicHamiltonian["JaynesCummings", omegaQ_?NumericQ,
        omegaC_?NumericQ, g_?NumericQ, lambda_?NumericQ,
        nFock_Integer] :=
    Module[{dim, sigmaZ, sigmaPlus, sigmaMinus, a, adag, hR, j, id2, idN},
        dim = 2 * nFock;
        id2 = IdentityMatrix[2];
        idN = IdentityMatrix[nFock];

        (* Qubit operators in full space *)
        sigmaZ = KroneckerProduct[{{1, 0}, {0, -1}}, idN];
        sigmaPlus = KroneckerProduct[{{0, 1}, {0, 0}}, idN];
        sigmaMinus = KroneckerProduct[{{0, 0}, {1, 0}}, idN];

        (* Cavity operators *)
        a = KroneckerProduct[id2,
            SparseArray[
                Band[{1, 2}] -> Table[Sqrt[n], {n, 1, nFock - 1}],
                {nFock, nFock}
            ]
        ];
        adag = ConjugateTranspose[a];

        (* Jaynes-Cummings Hamiltonian *)
        hR = omegaQ / 2 * sigmaZ + omegaC * adag . a +
             g * (sigmaPlus . a + sigmaMinus . adag);

        (* Dissipation: cavity decay *)
        j = adag . a / nFock;  (* normalized number operator *)

        EntropicHamiltonian[
            QuantumOperator[hR],
            QuantumOperator[j],
            EntropicRate[lambda, "Constant"]
        ]
    ];

EntropicHamiltonian["JaynesCummings", omegaQ_?NumericQ,
        omegaC_?NumericQ, g_?NumericQ, lambda_?NumericQ] :=
    EntropicHamiltonian["JaynesCummings", omegaQ, omegaC, g, lambda, 4];

(* ================================================================ *)
(* Named SpacetimeCoupler presets                                    *)
(* ================================================================ *)

(* Solar system test *)
SpacetimeCoupler["Sun"] :=
    SpacetimeCoupler["Schwarzschild",
        "Mass" -> CATEPT`Private`$SolarMass,
        "Radius" -> 1.496*^11  (* 1 AU *)
    ];

(* Near a stellar-mass black hole *)
SpacetimeCoupler["StellarBH", nSolarMasses_?NumericQ,
        nSchwarzschildRadii_?NumericQ] :=
    Module[{mass, rS, radius},
        mass = nSolarMasses * CATEPT`Private`$SolarMass;
        rS = SchwarzschildRadius[mass];
        radius = nSchwarzschildRadii * rS;
        SpacetimeCoupler["Schwarzschild",
            "Mass" -> mass,
            "Radius" -> radius
        ]
    ];

SpacetimeCoupler["StellarBH", nSolarMasses_?NumericQ] :=
    SpacetimeCoupler["StellarBH", nSolarMasses, 100];

SpacetimeCoupler["StellarBH"] :=
    SpacetimeCoupler["StellarBH", 10, 100];

(* Supermassive black hole, e.g. Sgr A-star *)
SpacetimeCoupler["SgrAStar"] :=
    SpacetimeCoupler["Schwarzschild",
        "Mass" -> 4.0*^6 * CATEPT`Private`$SolarMass,
        "Radius" -> 1*^13
    ];

(* ================================================================ *)
(* Named EntropicChannel presets                                     *)
(* ================================================================ *)

(* Thermal amplitude damping with entropic tracking *)
EntropicChannel["ThermalDamping", gamma_?NumericQ, nBar_?NumericQ,
        lambda_?NumericQ] :=
    Module[{lDown, lUp},
        lDown = QuantumOperator[Sqrt[gamma * (nBar + 1)] * {{0, 1}, {0, 0}}];
        lUp = QuantumOperator[Sqrt[gamma * nBar] * {{0, 0}, {1, 0}}];
        EntropicChannel[{lDown, lUp}, EntropicRate[lambda, "Constant"]]
    ];

(* Pure dephasing *)
EntropicChannel["Dephasing", gammaPhi_?NumericQ, lambda_?NumericQ] :=
    Module[{lPhi},
        lPhi = QuantumOperator[Sqrt[gammaPhi] * {{1, 0}, {0, -1}}];
        EntropicChannel[{lPhi}, EntropicRate[lambda, "Constant"]]
    ];

(* ================================================================ *)
(* Convenience: common initial states                                *)
(* ================================================================ *)

(* These delegate to QuantumFramework's QuantumState — lazy init *)
$CATEPTStates := If[TrueQ[$CATEPTQuantumFrameworkAvailable],
    $CATEPTStates = <|
        "QubitUp" -> QuantumState["0"],
        "QubitDown" -> QuantumState["1"],
        "QubitPlus" -> QuantumState["Plus"],
        "QubitMinus" -> QuantumState["Minus"],
        "Bell" -> QuantumState["Bell"],
        "GHZ3" -> QuantumState["GHZ"]
    |>,
    <||>
];

End[];
