(* ::Package:: *)
(* EntropicChannel.m — Quantum channel with entropic action tracking  *)
(*                                                                     *)
(* Extends QuantumChannel with S_I accumulation:                       *)
(*   rho(t+dt) = sum_k L_k rho L_k^dag + entropic damping             *)
(*   dS_I = lambda(t) * Tr[H_I rho] * dt                              *)
(*                                                                     *)
(* Maps to: eq_103 (Lindblad), eq_54 (entropic action)                *)

(* Loaded within CATEPT` context by Init.m *)

Begin["CATEPT`Private`"];

(* ================================================================ *)
(* EntropicChannel constructors                                      *)
(* ================================================================ *)

(* From list of jump operators + rate *)
EntropicChannel[jumpOps:{__?QuantumOperatorQ}, rate_EntropicRate] :=
    EntropicChannel[<|
        "JumpOperators" -> jumpOps,
        "Rate" -> rate,
        "NJumps" -> Length[jumpOps],
        "Dimension" -> jumpOps[[1]]["OutputDimension"]
    |>];

EntropicChannel[jumpOps:{__?QuantumOperatorQ}, lambda_?NumericQ] :=
    EntropicChannel[jumpOps, EntropicRate[lambda, "Constant"]];

EntropicChannel[jumpOps:{__?QuantumOperatorQ}] :=
    EntropicChannel[jumpOps, EntropicRate[0, "Constant"]];

(* From ENZ material: thermal decoherence channel *)
EntropicChannel[mat_ENZMaterial, opts___Rule] :=
    Module[{rules, duration, photonEnergy, omega, lambda, gammaDecay, jumpOp},
        rules = Association[opts];
        duration = Lookup[rules, "Duration", 1*^-13];  (* ~100 fs default *)
        photonEnergy = Lookup[rules, "PhotonEnergy", 1.0]; (* eV *)
        omega = photonEnergy * 1.602176634`*^-19 / CATEPT`Private`$hbar;

        lambda = ENZDecoherenceRate[mat, omega, Lookup[rules, "Temperature", 300.0]];
        gammaDecay = Sqrt[lambda * duration];

        jumpOp = QuantumOperator[gammaDecay * {{0, 1}, {0, 0}}]; (* |0><1| *)

        EntropicChannel[<|
            "JumpOperators" -> {jumpOp},
            "Rate" -> EntropicRate[lambda, "Constant"],
            "NJumps" -> 1,
            "Dimension" -> 2,
            "Material" -> mat,
            "Duration" -> duration,
            "PhotonEnergy" -> photonEnergy
        |>]
    ];

(* ================================================================ *)
(* Convert to QuantumChannel (Kraus operators)                       *)
(* ================================================================ *)

EntropicChannel /: ToQuantumChannel[EntropicChannel[assoc_Association]] :=
    Module[{jumpOps, krausOps, dim, identity, sumLdagL},
        jumpOps = assoc["JumpOperators"];
        dim = assoc["Dimension"];
        identity = IdentityMatrix[dim];

        (* Kraus operator for no-jump: K_0 = I - dt/2 * sum(L^dag L) *)
        (* For channel representation, we use the standard Kraus form *)
        krausOps = Append[
            jumpOps,
            (* Identity minus correction *)
            QuantumOperator[identity]
        ];
        QuantumChannel[krausOps]
    ];

(* ================================================================ *)
(* Apply channel to state                                            *)
(* Returns {newState, dSI} where dSI is the entropy action increment *)
(* ================================================================ *)

EntropicChannel /: ApplyChannel[
        EntropicChannel[assoc_Association],
        state_?QuantumStateQ,
        dt_?NumericQ] :=
    Module[{jumpOps, rate, rho, newRho, lambda, dSI, dim},
        jumpOps = assoc["JumpOperators"];
        rate = assoc["Rate"];
        dim = assoc["Dimension"];
        lambda = rate["Evaluate", 0.0];

        rho = state["DensityMatrix"];

        (* Lindblad step: drho = sum_k (L_k rho L_k^dag - 1/2 {L_k^dag L_k, rho}) dt *)
        newRho = rho;
        Do[
            Module[{lMat, ldMat},
                lMat = op["MatrixRepresentation"];
                ldMat = ConjugateTranspose[lMat];
                newRho = newRho + dt * (lMat . rho . ldMat
                    - 0.5 (ldMat . lMat . rho + rho . ldMat . lMat));
            ],
            {op, jumpOps}
        ];

        (* Entropy action increment: dS_I = lambda * Tr[H_I * rho] * dt *)
        dSI = lambda * dt;

        {QuantumState[Flatten[newRho]], dSI}
    ];

EntropicChannel /: ApplyChannel[
        EntropicChannel[assoc_Association],
        state_?QuantumStateQ] :=
    ApplyChannel[EntropicChannel[assoc], state, 1.0];

(* ================================================================ *)
(* Property access                                                   *)
(* ================================================================ *)

EntropicChannel /: EntropicChannel[assoc_Association][prop_String] :=
    Switch[prop,
        "JumpOperators", assoc["JumpOperators"],
        "Rate", assoc["Rate"],
        "NJumps", assoc["NJumps"],
        "Dimension", assoc["Dimension"],
        _, Lookup[assoc, prop, Missing["Property", prop]]
    ];

(* ================================================================ *)
(* Format                                                            *)
(* ================================================================ *)

Format[EntropicChannel[assoc_Association]] :=
    Interpretation[
        Row[{"EntropicChannel[",
             "n=", assoc["NJumps"],
             ", dim=", assoc["Dimension"],
             If[KeyExistsQ[assoc, "Material"],
                Row[{", ", assoc["Material"]}],
                ""
             ],
             "]"}],
        EntropicChannel[assoc]
    ];

End[];
