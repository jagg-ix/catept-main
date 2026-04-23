/-!
# FeynCalc → Lean 4 Translation Worklog
Source: Wolfram Mathematica package FeynCalc (Rolf Mertig, Frederik Orellana,
  Vladyslav Shtabovenko — 1990–2024; FeynCalc 10)
  https://github.com/FeynCalc/feyncalc
Target: Lean 4 / CATEPTMain  (namespace CATEPTMain.FEYNCALC)
        Lean 4.29 + Mathlib v4.29.0

## Context

FeynCalc is a Wolfram Mathematica package for automated one-loop and
tree-level QFT calculations. It implements:
  - Dirac algebra (γ-matrices, γ^5, chiral projectors)
  - Lorentz index contractions (metric tensor, Levi-Civita tensor)
  - Loop integrals (Passarino-Veltman reduction, dimensional regularisation)
  - Feynman rules (vertices, propagators, S-matrix elements)

This port does NOT reimpliment the CAS. Instead it formalises the
*mathematical substrate*: the algebraic identities and trace theorems
that FeynCalc computes, as Lean 4 theorems.

## Methodology

Follows the AFP→Lean4 bridge methodology in CATEPTMain:
  - Phase 1: opaque types (FCEnd, FCIdx), `axiom` predicates, `sorry`-stubs
  - Phase 2: replace FCEnd → CliffordAlgebra minkowskiQF
              replace spinorTrace → Matrix.trace
              replace axioms with Mathlib theorem references

## File structure

| File                | Content                              | Status  |
|---------------------|--------------------------------------|---------|
| FCPrelude.lean      | Carrier types, eta, leviCivita, etc. | Phase 1 |
| DiracAlgebra.lean   | Anti-commutation, γ^5, projectors    | Phase 1 |
| DiracTrace.lean     | Trace recursion, TR-0..TR-9          | Phase 1 |
| LorentzAlgebra.lean | Metric contractions, ε-ε identity    | Phase 1 |
| FC_WORKLOG.lean     | This file                            | —       |

## Phase 2 upgrade targets

| Record | Phase-1 axiom / sorry         | Phase-2 Mathlib target                              | P1.2 status |
|--------|-------------------------------|------------------------------------------------------|-------------|
| FC-001 | FCEnd opaque                  | CliffordAlgebra minkowskiQF (Mathlib 4.29+)          | —           |
| FC-002 | spinorTrace                   | Matrix.trace (Fin 4)(Fin 4)(ℂ)                       | —           |
| FC-003 | gamma_anticommute sorry       | CliffordAlgebra.ι_sq_scalar + polarization           | sorry       |
| FC-003b| gamma_sq, gamma0_sq, gammaI_sq| derived from FC-003 via smulEnd_cancel               | **proved**  |
| FC-004 | gamma5_sq_one sorry           | explicit product in CliffordAlgebra                  | sorry       |
| FC-004b| chiralP6/7_idempotent         | (1±γ^5)² = 2(1±γ^5) via FC-004 + bimodule axioms    | **proved**  |
| FC-004c| chiralP6/7_zero               | (1+γ^5)(1-γ^5) = 0 via FC-004 + bimodule axioms     | **proved**  |
| FC-005 | spinorTrace_one axiom         | Matrix.trace_one + Fintype.card_fin 4                | —           |
| FC-006 | spinorTrace_two sorry         | anticommute + trace linearity                        | sorry       |
| FC-007 | spinorTrace_four sorry        | Trace4 recursion from FC-006                         | **proved**  |
| FC-007b| spinorTrace_three_zero sorry  | γ^5 parity: Tr(A)=Tr(γ5Aγ5)=-Tr(A)→0               | **proved**  |
| FC-008 | eta_contraction sorry         | concrete matrix arithmetic, Fin 4 decidable          | proved (p1) |
| FC-009 | leviCivita self-contract      | leviCivita_eps_eps_3 + Fin.sum_univ_four + if_neg×12 | **proved**  |
| FC-010 | spinorTrace_slash_slash sorry | expand pSlash → 16 terms via TR-2 + linearity        | **proved**  |

## Source module audit (FeynCalc 10)

Audited modules (Phase 1):
  ✓ Dirac/DiracTrick.m       — L287–1620 (anti-comm, g5, chiral)
  ✓ Dirac/DiracTrace.m       — L606–769 (spurNo5, spur5In4Dim)
  ✓ Lorentz/Contract.m       — L58–376 (PairContract, metric)
  ✓ Lorentz/EpsContract.m    — (ε-ε identity)

Deferred to Phase 2:
  □ LoopIntegrals/            — Passarino-Veltman, dim reg (Feynman param)
  □ Feynman/                  — propagators, vertices (requires spinor fields)
  □ Dirac/DiracSimplify.m    — algorithmic simplifier (beyond scope of p1)
  □ Dirac/DiracOrder.m       — normal ordering (requires permutation groups)

## Phase 1 sorry budget (updated 2026-04-15, Phase 1.5 — all files compile clean)

Total theorems stated: 48 (+1 new in Phase 1.5: spinorTrace_slash_slash proved via pSlash expansion + TR-2)
Total `sorry` stubs:   10 (down from 11; spinorTrace_slash_slash proved in Phase 1.5)
Total `axiom` entries: 32
Build status: `lake build` succeeds on all 5 FEYNCALC files (FCPrelude, DiracAlgebra, LorentzAlgebra, DiracTrace, FC_WORKLOG)
Phase-1 target: compile-safe (all stubs trivially `sorry`)  ✓
Phase-2 target: sorry budget ≤ 5 for Dirac+Lorentz subsystem

NOTE: All `sorry` stubs are GENUINE proof gaps (Phase-2 targets requiring CliffordAlgebra
or Matrix.trace), not axiom-disguised holes. Do NOT convert sorry-stubs to axioms.

### Proved without sorry (Phase 1 + Phase 1.1 + Phase 1.2 + Phase 1.3 + Phase 1.4):
  1. eta_symm                    (LorentzAlgebra)
  2. eta_trace_mink              (LorentzAlgebra)
  3. eta_selfContraction         (LorentzAlgebra)
  4. eta_contraction             (LorentzAlgebra)
  5. leviCivita_diagonal_zero    (LorentzAlgebra)
  6. lorentzProduct_self         (LorentzAlgebra)
  7. lorentzProduct_symm         (LorentzAlgebra)
  8. leviCivita_antisymm_23      (LorentzAlgebra)  [from leviCivita_antisymm_last axiom]
  9. leviCivita_diagonal_12      (LorentzAlgebra)  [from leviCivita_antisymm_12 axiom]
 10. leviCivita_diagonal_23      (LorentzAlgebra)  [from leviCivita_antisymm_last axiom]
 11. spinorTrace_gamma0_sq       (DiracTrace)       [from spinorTrace_two]
 12. spinorTrace_gammaI_sq       (DiracTrace)       [from spinorTrace_two]
 13. spinorTrace_two_symm        (DiracTrace)       [from spinorTrace_two + eta_symm]
 14. chiralP6_add_chiralP7_one   (DiracAlgebra)    [P_R + P_L = 1, uses ℂ-module axioms]
--- Phase 1.2 additions ---
 15. gamma_sq                    (DiracAlgebra)    [(γ^μ)² = g^μμ·1, from gamma_anticommute]
 16. gamma0_sq                   (DiracAlgebra)    [(γ^0)² = 1, from gamma_sq + eta]
 17. gammaI_sq                   (DiracAlgebra)    [(γ^i)² = -1, from gamma_sq + eta]
 18. chiralP6_idempotent         (DiracAlgebra)    [P_R² = P_R, from gamma5_sq_one + bimodule axioms]
 19. chiralP7_idempotent         (DiracAlgebra)    [P_L² = P_L, symmetric to chiralP6_idempotent]
 20. chiralP6_chiralP7_zero      (DiracAlgebra)    [P_R·P_L = 0, from gamma5_sq_one]
 21. chiralP7_chiralP6_zero      (DiracAlgebra)    [P_L·P_R = 0, from gamma5_sq_one]
 22. spinorTrace_four            (DiracTrace)       [TR-4 from TR-6 recursion + TR-2]
--- Phase 1.3 additions ---
 23. gamma5_pass3               (DiracAlgebra)    [γ^5·(γ^μγ^νγ^ρ)·γ^5 = −(γ^μγ^νγ^ρ), from gamma5_anticommute×3 + gamma5_sq_one]
 24. spinorTrace_three_zero     (DiracTrace)       [TR-3: Tr(γ^μγ^νγ^ρ)=0, from gamma5_pass3 + spinorTrace_cyclic + parity]
--- Phase 1.4 additions ---
 25. leviCivita_self_contract   (LorentzAlgebra)   [Σ_{μνρσ}(ε^μνρσ)²=24, from leviCivita_eps_eps_3 + Fin.sum_univ_four + if_neg×12]
 26. gamma5_pass1               (DiracAlgebra)    [γ^5·γ^μ·γ^5 = −γ^μ, from anticomm_left + (γ^5)²=1]
 27. gamma5_pass2               (DiracAlgebra)    [γ^5·γ^μγ^ν·γ^5 = γ^μγ^ν, two anticomms cancel]
 28. spinorTrace_gamma_gamma5_zero (DiracTrace)   [Tr(γ^μγ^5)=0, cyclic + anticomm_left parity trick]
 29. spinorTrace_gamma5_gamma_zero (DiracTrace)   [Tr(γ^5γ^μ)=0, from cyclic + Tr(γ^μγ^5)=0]
--- Phase 1.5 additions ---
 30. spinorTrace_slash_slash    (DiracTrace)       [TR-10: Tr(p̸q̸)=4p·q, expand pSlash→16 terms, apply TR-2+linearity+η eval]

### Remaining sorry stubs (10, all phase2_high):
DiracAlgebra (5):  gamma_anticommute, gamma5_sq_one, gamma5_anticommute,
                   gamma_sandwich_one, gamma_sandwich_two
DiracTrace (4):    spinorTrace_two, spinorTrace_recursion_two,
                   spinorTrace_four_gamma5, spinorTrace_two_gamma5_zero
LorentzAlgebra (1): pSlash_sq

## Connection to catept-main milestones

This port feeds into:
  - lean4port_feyncalc (worklog task): Phase 1 complete on 2026-04-15
  - lean4port_electroweak: FCPrelude eta / gamma definitions shared
  - lean4port_fermion_boson: DiracAlgebra γ^5, projectors reused

## Records

### FC-PRE-001  Carrier type: FCEnd → CliffordAlgebra (P2)
Current: `opaque FCEnd : Type := Unit`
Target:
```lean
-- Define Minkowski quadratic form on ℝ^4
noncomputable def minkowskiQF : QuadraticForm ℝ (Fin 4 → ℝ) :=
  QuadraticForm.ofPolar
    (fun v => v 0^2 - v 1^2 - v 2^2 - v 3^2)
    (fun a v => by ring)
    (fun v w => by ring)
noncomputable def FeynCalcClifford := CliffordAlgebra minkowskiQF
-- gamma μ = ι minkowskiQF (Pi.single μ 1) : FeynCalcClifford
```
Blocker: CliffordAlgebra over ℝ, spinor rep in ℂ^4 requires separate work.

### FC-TH-001  Anti-commutation (P1)
Status: sorry-stub in DiracAlgebra.lean.
Proof sketch:
  Let A = ι Q eμ, B = ι Q eν.
  From CliffordAlgebra.ι_sq_scalar: A*A = Q(eμ) = eta(μ,μ).
  Polarize: A*B + B*A = Q(eμ+eν) - Q(eμ) - Q(eν)
           = (eta(μ,μ)+2eta(μ,ν)+eta(ν,ν)) - eta(μ,μ) - eta(ν,ν)
           = 2 eta(μ,ν).
  In Lean: `CliffordAlgebra.ι_mul_ι_add_swap` or manual polarization.

### FC-TH-002  Trace of four gammas (P1)
Status: sorry-stub in DiracTrace.lean.
Proof sketch:
  Use spinorTrace_recursion_two twice + spinorTrace_two.
  Need: spinorTrace_recursion_two is proved from gamma_anticommute + linearity.

### FC-TH-003  Trace with γ^5 (P1)
Status: sorry-stub in DiracTrace.lean.
Proof sketch: Requires explicit γ^5 = i γ^0 γ^1 γ^2 γ^3 expansion,
  then trace calculation using spinorTrace_four + leviCivita_0123.
  This is the most computation-intensive step; likely needs `decide` with Fin 4.
-/
