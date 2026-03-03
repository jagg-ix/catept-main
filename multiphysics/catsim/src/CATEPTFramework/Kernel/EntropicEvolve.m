(* ::Package:: *)
(* EntropicEvolve.m — Main solver dispatcher for CAT/EPT dynamics     *)
(*                                                                     *)
(* Implements three solver modes:                                      *)
(*   "ComplexAction"  — i hbar d|psi>/dt = (H_R - i hbar lambda J)|psi> *)
(*   "Lindblad"       — drho/dt = -i[H,rho] + Lindblad[L_k, rho]     *)
(*   "EntropicTime"   — evolution in tau_ent instead of t              *)
(*                                                                     *)
(* All modes automatically compute:                                    *)
(*   S(t)      — von Neumann entropy                                   *)
(*   lambda(t) — entropy production rate                               *)
(*   tau_ent(t)— accumulated entropic proper time                      *)
(*   w(t)      — path integral weight exp(-S_I/hbar)                   *)
(*                                                                     *)
(* Maps to: eq_1 (complex action), eq_3 (entropic time),              *)
(*          eq_54 (path integral), eq_103 (Lindblad)                   *)

(* Loaded within CATEPT` context by Init.m *)

Begin["CATEPT`Private`"];

(* ================================================================ *)
(* Von Neumann entropy of a density matrix                           *)
(* S = -Tr[rho log rho]                                              *)
(* ================================================================ *)

vonNeumannEntropy[rho_?MatrixQ] :=
    Module[{eigenvalues, nonzero},
        eigenvalues = Re[Eigenvalues[rho]];
        nonzero = Select[eigenvalues, # > 1*^-15 &];
        If[Length[nonzero] == 0, 0.0,
            -Total[nonzero * Log[nonzero]]
        ]
    ];

vonNeumannEntropy[stateVec_?VectorQ] :=
    Module[{rho},
        rho = Outer[Times, stateVec, Conjugate[stateVec]];
        vonNeumannEntropy[rho]
    ];

(* ================================================================ *)
(* EntropicEvolve — main entry point                                 *)
(* ================================================================ *)

(* Overload 1: EntropicHamiltonian + initial state *)
EntropicEvolve[
    ham_EntropicHamiltonian,
    initialState_?QuantumStateQ,
    tspec : {t_Symbol, t0_?NumericQ, tf_?NumericQ},
    opts___Rule
] :=
    Module[{rules, solver, nSteps, tlist},
        rules = Association[opts];
        solver = Lookup[rules, "Solver", "ComplexAction"];
        nSteps = Lookup[rules, "Steps", 200];
        tlist = Subdivide[t0, tf, nSteps];

        Switch[solver,
            "ComplexAction",
                evolveComplexAction[ham, initialState, tlist, {}, rules],
            "EntropicTime",
                evolveInTau[ham, initialState, tlist, {}, rules],
            _,
                evolveComplexAction[ham, initialState, tlist, {}, rules]
        ]
    ];

(* Overload 2: EntropicHamiltonian + jump operators + initial state *)
EntropicEvolve[
    ham_EntropicHamiltonian,
    jumpOps:{___?QuantumOperatorQ},
    initialState_?QuantumStateQ,
    tspec : {t_Symbol, t0_?NumericQ, tf_?NumericQ},
    opts___Rule
] :=
    Module[{rules, solver, nSteps, tlist},
        rules = Association[opts];
        solver = Lookup[rules, "Solver", "Lindblad"];
        nSteps = Lookup[rules, "Steps", 200];
        tlist = Subdivide[t0, tf, nSteps];

        Switch[solver,
            "Lindblad",
                evolveLindblad[ham, jumpOps, initialState, tlist, rules],
            "ComplexAction",
                evolveComplexAction[ham, initialState, tlist, jumpOps, rules],
            "EntropicTime",
                evolveInTau[ham, initialState, tlist, jumpOps, rules],
            _,
                evolveLindblad[ham, jumpOps, initialState, tlist, rules]
        ]
    ];

(* Overload 3: Bare QuantumOperator Hamiltonian — delegate to QuantumEvolve *)
EntropicEvolve[
    ham_?QuantumOperatorQ,
    initialState_?QuantumStateQ,
    tspec : {t_Symbol, t0_?NumericQ, tf_?NumericQ},
    opts___Rule
] :=
    EntropicEvolve[
        EntropicHamiltonian[ham],
        initialState,
        tspec,
        opts
    ];

(* Overload 4: With explicit time list *)
EntropicEvolve[
    ham_EntropicHamiltonian,
    initialState_?QuantumStateQ,
    tlist_List,
    opts___Rule
] :=
    Module[{rules, solver},
        rules = Association[opts];
        solver = Lookup[rules, "Solver", "ComplexAction"];
        Switch[solver,
            "ComplexAction",
                evolveComplexAction[ham, initialState, tlist, {}, rules],
            "EntropicTime",
                evolveInTau[ham, initialState, tlist, {}, rules],
            _,
                evolveComplexAction[ham, initialState, tlist, {}, rules]
        ]
    ];

(* ================================================================ *)
(* Complex Action solver                                             *)
(* i hbar d|psi>/dt = (H_R - i hbar lambda(t) J) |psi>              *)
(* Eq 1: S = S_R + i S_I                                             *)
(* ================================================================ *)

evolveComplexAction[ham_EntropicHamiltonian, initialState_?QuantumStateQ,
        tlist_List, jumpOps_List, rules_Association] :=
    Module[{dim, hbar, hRMat, jMat, rateFn, psi0, nSteps,
            states, entropy, lambdaEnt, tauEnt, weight, sI,
            psi, dt, lambda, hComplex, psiNew, norm, rho, s},

        dim = ham["Dimension"];
        hbar = Lookup[rules, "hbar", CATEPT`Private`$hbar];
        hRMat = ham["HR"]["MatrixRepresentation"];
        jMat = ham["J"]["MatrixRepresentation"];
        rateFn = ham["Rate"]["Function"];
        psi0 = initialState["StateVector"];
        nSteps = Length[tlist];

        (* Initialize arrays *)
        states = ConstantArray[Null, nSteps];
        entropy = ConstantArray[0.0, nSteps];
        lambdaEnt = ConstantArray[0.0, nSteps];
        tauEnt = ConstantArray[0.0, nSteps];
        weight = ConstantArray[1.0, nSteps];
        sI = ConstantArray[0.0, nSteps];

        (* Initial conditions *)
        psi = N[psi0];
        states[[1]] = QuantumState[psi];
        entropy[[1]] = vonNeumannEntropy[psi];
        lambdaEnt[[1]] = rateFn[tlist[[1]]];

        (* Time-stepping: Crank-Nicolson *)
        Do[
            dt = tlist[[i]] - tlist[[i - 1]];
            lambda = rateFn[tlist[[i]]];

            (* H_complex = H_R - i*hbar*lambda*J *)
            hComplex = hRMat - I * hbar * lambda * jMat;

            (* Simple forward Euler for non-Hermitian evolution *)
            (* d|psi>/dt = -(i/hbar) H_complex |psi> *)
            psiNew = psi - (I / hbar) * dt * hComplex . psi;

            (* Track norm decay — this IS the S_I accumulation *)
            norm = Sqrt[Re[Conjugate[psiNew] . psiNew]];

            (* Accumulate imaginary action *)
            sI[[i]] = sI[[i - 1]] + hbar * lambda * dt *
                Re[Conjugate[psi] . jMat . psi];

            (* Normalize for state extraction (optional) *)
            If[Lookup[rules, "NormalizeOutput", False] && norm > 1*^-30,
                psiNew = psiNew / norm
            ];

            psi = psiNew;
            states[[i]] = QuantumState[psi];

            (* Von Neumann entropy of density matrix *)
            rho = Outer[Times, psi / Max[norm, 1*^-30],
                               Conjugate[psi / Max[norm, 1*^-30]]];
            entropy[[i]] = vonNeumannEntropy[rho];

            (* Entropic rate and proper time *)
            lambdaEnt[[i]] = lambda;
            tauEnt[[i]] = tauEnt[[i - 1]] + lambda * dt;

            (* Path integral weight: w = exp(-S_I/hbar) *)
            weight[[i]] = Exp[-sI[[i]] / hbar];,

            {i, 2, nSteps}
        ];

        EntropicResult[<|
            "Times" -> tlist,
            "States" -> states,
            "Expect" -> <||>,
            "Entropy" -> entropy,
            "LambdaEnt" -> lambdaEnt,
            "EntropicTime" -> tauEnt,
            "Weight" -> weight,
            "SI" -> sI,
            "Stats" -> <|
                "Solver" -> "ComplexAction",
                "Dimension" -> dim,
                "Steps" -> nSteps,
                "hbar" -> hbar
            |>
        |>]
    ];

(* ================================================================ *)
(* Lindblad solver                                                   *)
(* drho/dt = -i[H,rho] + sum_k gamma_k (L_k rho L_k^dag             *)
(*           - 1/2 {L_k^dag L_k, rho})                               *)
(* Eq 103: GKSL Lindblad master equation                             *)
(* ================================================================ *)

evolveLindblad[ham_EntropicHamiltonian, jumpOps_List,
        initialState_?QuantumStateQ, tlist_List, rules_Association] :=
    Module[{dim, hbar, hRMat, jMat, rateFn, nSteps,
            states, entropy, lambdaEnt, tauEnt, weight, sI,
            rho, rho0, dt, lambda, hEff, drho, lMat, ldMat,
            newRho, s},

        dim = ham["Dimension"];
        hbar = Lookup[rules, "hbar", CATEPT`Private`$hbar];
        hRMat = ham["HR"]["MatrixRepresentation"];
        jMat = ham["J"]["MatrixRepresentation"];
        rateFn = ham["Rate"]["Function"];
        nSteps = Length[tlist];

        (* Initial density matrix *)
        rho0 = If[Length[Dimensions[initialState["StateVector"]]] == 1,
            (* Pure state -> density matrix *)
            Outer[Times, initialState["StateVector"],
                         Conjugate[initialState["StateVector"]]],
            initialState["DensityMatrix"]
        ];
        rho = N[rho0];

        (* Initialize arrays *)
        states = ConstantArray[Null, nSteps];
        entropy = ConstantArray[0.0, nSteps];
        lambdaEnt = ConstantArray[0.0, nSteps];
        tauEnt = ConstantArray[0.0, nSteps];
        weight = ConstantArray[1.0, nSteps];
        sI = ConstantArray[0.0, nSteps];

        states[[1]] = QuantumState[Flatten[rho]];
        entropy[[1]] = vonNeumannEntropy[rho];
        lambdaEnt[[1]] = rateFn[tlist[[1]]];

        Do[
            dt = tlist[[i]] - tlist[[i - 1]];
            lambda = rateFn[tlist[[i]]];

            (* Effective Hamiltonian with entropic term *)
            hEff = hRMat - I * hbar * lambda * jMat;

            (* Commutator: -i[H_eff, rho] *)
            drho = -(I / hbar) * (hEff . rho - rho . ConjugateTranspose[hEff]);

            (* Lindblad dissipator: sum_k (L rho L^dag - 1/2 {L^dag L, rho}) *)
            Do[
                lMat = op["MatrixRepresentation"];
                ldMat = ConjugateTranspose[lMat];
                drho = drho + lMat . rho . ldMat
                    - 0.5 (ldMat . lMat . rho + rho . ldMat . lMat);,
                {op, jumpOps}
            ];

            (* Forward Euler step *)
            newRho = rho + dt * drho;

            (* Ensure trace = 1 *)
            newRho = newRho / Tr[newRho];

            rho = newRho;
            states[[i]] = QuantumState[Flatten[rho]];

            (* Entropy *)
            entropy[[i]] = vonNeumannEntropy[rho];

            (* Entropic tracking *)
            lambdaEnt[[i]] = lambda;
            tauEnt[[i]] = tauEnt[[i - 1]] + lambda * dt;
            sI[[i]] = sI[[i - 1]] + hbar * lambda * dt *
                Re[Tr[jMat . rho]];
            weight[[i]] = Exp[-sI[[i]] / hbar];,

            {i, 2, nSteps}
        ];

        EntropicResult[<|
            "Times" -> tlist,
            "States" -> states,
            "Expect" -> <||>,
            "Entropy" -> entropy,
            "LambdaEnt" -> lambdaEnt,
            "EntropicTime" -> tauEnt,
            "Weight" -> weight,
            "SI" -> sI,
            "Stats" -> <|
                "Solver" -> "Lindblad",
                "Dimension" -> dim,
                "Steps" -> nSteps,
                "NJumps" -> Length[jumpOps],
                "hbar" -> hbar
            |>
        |>]
    ];

(* ================================================================ *)
(* Entropic proper-time solver                                       *)
(* Same ODE but reparameterized: dtau = lambda(t) dt                 *)
(* Returns results indexed by tau_ent instead of t                   *)
(* ================================================================ *)

evolveInTau[ham_EntropicHamiltonian, initialState_?QuantumStateQ,
        tlist_List, jumpOps_List, rules_Association] :=
    Module[{result, tauGrid},
        (* First evolve in coordinate time *)
        result = evolveComplexAction[ham, initialState, tlist, jumpOps, rules];

        (* Reparameterize: return tau as the "time" axis *)
        tauGrid = result["EntropicTime"];

        EntropicResult[<|
            "Times" -> tauGrid,   (* tau_ent is now the time axis *)
            "CoordinateTimes" -> tlist,  (* store original t *)
            "States" -> result["States"],
            "Expect" -> result["Expect"],
            "Entropy" -> result["Entropy"],
            "LambdaEnt" -> result["LambdaEnt"],
            "EntropicTime" -> tauGrid,
            "Weight" -> result["Weight"],
            "SI" -> result["SI"],
            "Stats" -> Join[result["Stats"], <|"Solver" -> "EntropicTime"|>]
        |>]
    ];

(* ================================================================ *)
(* QuantumEvolve bridge: use Wolfram's NDSolve for high accuracy     *)
(* ================================================================ *)

EntropicEvolve[
    ham_EntropicHamiltonian,
    initialState_?QuantumStateQ,
    tspec : {t_Symbol, t0_?NumericQ, tf_?NumericQ},
    opts___Rule
] /; MemberQ[{opts}, "Backend" -> "NDSolve"] :=
    Module[{dim, hbar, hRMat, jMat, rateFn, psi0, nSteps, rules,
            vars, equations, initialConditions, solution, tlist,
            states, entropy, lambdaEnt, tauEnt, weight, sI},

        rules = Association[opts];
        dim = ham["Dimension"];
        hbar = Lookup[rules, "hbar", CATEPT`Private`$hbar];
        hRMat = ham["HR"]["MatrixRepresentation"];
        jMat = ham["J"]["MatrixRepresentation"];
        rateFn = ham["Rate"]["Function"];
        psi0 = N[initialState["StateVector"]];
        nSteps = Lookup[rules, "Steps", 200];
        tlist = Subdivide[t0, tf, nSteps];

        (* Set up ODE system *)
        vars = Table[Subscript[\[Psi], k][t], {k, dim}];

        (* H_complex(t) = H_R - i*hbar*lambda(t)*J *)
        equations = Table[
            D[vars[[k]], t] == -(I / hbar) * Total[
                Table[
                    (hRMat[[k, j]] - I * hbar * rateFn[t] * jMat[[k, j]]) * vars[[j]],
                    {j, dim}
                ]
            ],
            {k, dim}
        ];

        (* Add tau_ent ODE: dtau/dt = lambda(t) *)
        AppendTo[equations, \[Tau]ent'[t] == rateFn[t]];
        (* Add S_I ODE: dS_I/dt = hbar * lambda * <J> *)
        AppendTo[equations,
            sIvar'[t] == hbar * rateFn[t] * Re[
                Total[Table[
                    Conjugate[vars[[k]]] * Total[jMat[[k]] * vars],
                    {k, dim}
                ]]
            ]
        ];

        initialConditions = Join[
            Table[Subscript[\[Psi], k][t0] == psi0[[k]], {k, dim}],
            {\[Tau]ent[t0] == 0, sIvar[t0] == 0}
        ];

        solution = Quiet[NDSolve[
            Join[equations, initialConditions],
            Join[vars, {\[Tau]ent[t], sIvar[t]}],
            {t, t0, tf},
            FilterRules[{opts}, Options[NDSolve]]
        ]];

        If[MatchQ[solution, $Failed | {}],
            Return[EntropicResult[<|"Times" -> tlist, "Stats" -> <|"Error" -> True|>|>]]
        ];

        solution = First[solution];

        (* Extract results at tlist points *)
        states = Table[
            QuantumState[Table[Subscript[\[Psi], k][ti] /. solution, {k, dim}]],
            {ti, tlist}
        ];
        tauEnt = Table[\[Tau]ent[ti] /. solution, {ti, tlist}];
        sI = Table[sIvar[ti] /. solution, {ti, tlist}];
        lambdaEnt = rateFn /@ tlist;
        entropy = vonNeumannEntropy /@ (states /. QuantumState[v_] :> v);
        weight = Exp[-sI / hbar];

        EntropicResult[<|
            "Times" -> tlist,
            "States" -> states,
            "Expect" -> <||>,
            "Entropy" -> entropy,
            "LambdaEnt" -> lambdaEnt,
            "EntropicTime" -> tauEnt,
            "Weight" -> weight,
            "SI" -> sI,
            "Stats" -> <|
                "Solver" -> "NDSolve",
                "Dimension" -> dim,
                "Steps" -> nSteps,
                "hbar" -> hbar
            |>
        |>]
    ];

End[];
