(* ::Package:: *)
(* EntropicHamiltonian.m — Complex Hamiltonian H = H_R - i hbar lambda(t) J *)
(*                                                                           *)
(* The CAT/EPT framework uniquely decomposes the Hamiltonian as:             *)
(*   H = H_R - i H_I,   H_I >= 0                                            *)
(*   H_I = hbar * lambda(t) * J                                              *)
(* where J is a positive-semidefinite dissipative channel operator.           *)
(*                                                                           *)
(* Mazur-Ulam uniqueness theorem forces this decomposition.                  *)
(* Maps to: eq_1 (complex action), eq_2 (complex Hamiltonian)               *)

(* Loaded within CATEPT` context by Init.m *)

Begin["CATEPT`Private`"];

(* ================================================================ *)
(* EntropicHamiltonian constructors                                  *)
(* ================================================================ *)

(* From QuantumOperators + EntropicRate *)
EntropicHamiltonian[hR_ ? QuantumOperatorQ, j_ ? QuantumOperatorQ,
        rate_EntropicRate] :=
    EntropicHamiltonian[<|
        "HR" -> hR,
        "J" -> j,
        "Rate" -> rate,
        "Dimension" -> hR["OutputDimension"]
    |>];

(* From QuantumOperators + constant lambda *)
EntropicHamiltonian[hR_ ? QuantumOperatorQ, j_ ? QuantumOperatorQ,
        lambda_?NumericQ] :=
    EntropicHamiltonian[hR, j, EntropicRate[lambda, "Constant"]];

(* From QuantumOperators + function *)
EntropicHamiltonian[hR_ ? QuantumOperatorQ, j_ ? QuantumOperatorQ,
        fn_Function] :=
    EntropicHamiltonian[hR, j, EntropicRate[fn]];

(* From raw matrices + rate *)
EntropicHamiltonian[hR_?MatrixQ, j_?MatrixQ, rate_] :=
    EntropicHamiltonian[
        QuantumOperator[hR],
        QuantumOperator[j],
        If[MatchQ[rate, _EntropicRate], rate, EntropicRate[rate]]
    ];

(* Hermitian-only (no dissipation): J = 0 *)
EntropicHamiltonian[hR_ ? QuantumOperatorQ] :=
    Module[{dim, zeroJ},
        dim = hR["OutputDimension"];
        zeroJ = QuantumOperator[ConstantArray[0, {dim, dim}]];
        EntropicHamiltonian[hR, zeroJ, EntropicRate[0, "Constant"]]
    ];

(* ================================================================ *)
(* Complex matrix at time t                                          *)
(* H(t) = H_R - i * hbar * lambda(t) * J                            *)
(* ================================================================ *)

EntropicHamiltonian /: ComplexMatrix[
        EntropicHamiltonian[assoc_Association], t_?NumericQ,
        hbar_?NumericQ] :=
    Module[{hRMat, jMat, lambda},
        hRMat = assoc["HR"]["MatrixRepresentation"];
        jMat = assoc["J"]["MatrixRepresentation"];
        lambda = assoc["Rate"]["Evaluate", t];
        hRMat - I * hbar * lambda * jMat
    ];

EntropicHamiltonian /: ComplexMatrix[
        EntropicHamiltonian[assoc_Association], t_?NumericQ] :=
    ComplexMatrix[EntropicHamiltonian[assoc], t, CATEPT`Private`$hbar];

(* Symbolic form *)
EntropicHamiltonian /: ComplexMatrix[
        EntropicHamiltonian[assoc_Association], t_Symbol] :=
    Module[{hRMat, jMat},
        hRMat = assoc["HR"]["MatrixRepresentation"];
        jMat = assoc["J"]["MatrixRepresentation"];
        hRMat - I * \[HBar] * \[Lambda][t] * jMat
    ];

(* ================================================================ *)
(* Convert to time-dependent QuantumOperator                         *)
(* For use with standard QuantumEvolve                               *)
(* ================================================================ *)

EntropicHamiltonian /: ToQuantumOperator[
        EntropicHamiltonian[assoc_Association], t_Symbol,
        hbar_?NumericQ] :=
    Module[{hR, j, rateFn, matrix},
        hR = assoc["HR"];
        j = assoc["J"];
        rateFn = assoc["Rate"]["Function"];
        (* Return time-dependent QuantumOperator *)
        QuantumOperator[
            hR["MatrixRepresentation"] - I * hbar * rateFn[t] * j["MatrixRepresentation"]
        ]
    ];

EntropicHamiltonian /: ToQuantumOperator[
        EntropicHamiltonian[assoc_Association], t_Symbol] :=
    ToQuantumOperator[EntropicHamiltonian[assoc], t, CATEPT`Private`$hbar];

(* ================================================================ *)
(* Decay width: Gamma_n = 2 lambda <n|H_I|n> / hbar                 *)
(* Eq 61: verified in Lean4 eq101, eq022                             *)
(* ================================================================ *)

EntropicHamiltonian /: DecayWidth[
        EntropicHamiltonian[assoc_Association],
        state_ ? QuantumStateQ,
        t_?NumericQ,
        hbar_?NumericQ] :=
    Module[{jMat, lambda, stateVec, hI, expectHI},
        jMat = assoc["J"]["MatrixRepresentation"];
        lambda = assoc["Rate"]["Evaluate", t];
        stateVec = state["StateVector"];
        (* <n|H_I|n> = hbar * lambda * <n|J|n> *)
        expectHI = hbar * lambda * Re[Conjugate[stateVec] . jMat . stateVec];
        (* Gamma = 2 lambda <n|H_I|n> = 2 hbar lambda^2 <n|J|n> *)
        2 * lambda * expectHI
    ];

EntropicHamiltonian /: DecayWidth[
        EntropicHamiltonian[assoc_Association], state_ ? QuantumStateQ,
        t_?NumericQ] :=
    DecayWidth[EntropicHamiltonian[assoc], state, t, CATEPT`Private`$hbar];

EntropicHamiltonian /: DecayWidth[
        EntropicHamiltonian[assoc_Association], state_ ? QuantumStateQ] :=
    DecayWidth[EntropicHamiltonian[assoc], state, 0.0, CATEPT`Private`$hbar];

(* ================================================================ *)
(* Energy cost: DeltaE = hbar * DeltaTauEnt * <H_I>                 *)
(* Eq 14 / eq_146: verified in Lean4 eq146                          *)
(* ================================================================ *)

EntropicHamiltonian /: EnergyCost[
        EntropicHamiltonian[assoc_Association],
        state_ ? QuantumStateQ,
        deltaTauEnt_?NumericQ,
        hbar_?NumericQ] :=
    Module[{jMat, lambda, stateVec, expectHI},
        jMat = assoc["J"]["MatrixRepresentation"];
        lambda = assoc["Rate"]["Evaluate", 0.0];
        stateVec = state["StateVector"];
        expectHI = hbar * lambda * Re[Conjugate[stateVec] . jMat . stateVec];
        hbar * deltaTauEnt * expectHI
    ];

EntropicHamiltonian /: EnergyCost[
        EntropicHamiltonian[assoc_Association],
        state_ ? QuantumStateQ,
        deltaTauEnt_?NumericQ] :=
    EnergyCost[EntropicHamiltonian[assoc], state, deltaTauEnt, CATEPT`Private`$hbar];

(* ================================================================ *)
(* Property access                                                   *)
(* ================================================================ *)

EntropicHamiltonian /: EntropicHamiltonian[assoc_Association][prop_String] :=
    Switch[prop,
        "HR", assoc["HR"],
        "J", assoc["J"],
        "Rate", assoc["Rate"],
        "Dimension", assoc["Dimension"],
        "HermitianPart", assoc["HR"],
        "DissipativePart", assoc["J"],
        _, Lookup[assoc, prop, Missing["Property", prop]]
    ];

(* ================================================================ *)
(* Format                                                            *)
(* ================================================================ *)

Format[EntropicHamiltonian[assoc_Association]] :=
    Interpretation[
        Row[{"EntropicHamiltonian[",
             "dim=", assoc["Dimension"],
             ", \[Lambda]=", assoc["Rate"],
             "]"}],
        EntropicHamiltonian[assoc]
    ];

End[];
