/-!
# FBD WORKLOG — Fermion-Boson Duality Port Status

## Source audit

Repository: `FermionBosonDuality_QFT/FermionBosonDuality_QFT_v1.0/`
Author: Hirokaxzu Maruyama, January 2025

| Notebook                          | Section            | Lean module           | Phase |
|-----------------------------------|--------------------|-----------------------|-------|
| 03_theoretical_foundations/       |                    |                       |       |
|   01_omega_matrix_properties.nb   | ω definitions      | FBDPrelude            | p1    |
|                                   | ω anticommutation  | OmegaMatrices OM-1..5 | p1    |
|                                   | ω-slash invariant  | OmegaMatrices OM-3    | sorry |
| 01_qed_processes/                 |                    |                       |       |
|   01_compton_scattering.nb        | Compton |M|²        | QEDProcesses CS-1,2   | p1*  |
|   02_bhabha_scattering.nb         | Bhabha |M|²         | QEDProcesses BS-1     | axiom|
|   03_moller_scattering.nb         | Möller |M|²         | QEDProcesses MS-1     | axiom|
|   04_muon_pair_production.nb      | Muon pair |M|²      | QEDProcesses MP-1     | axiom|

*CS-1 and CS-2 proved as algebraic identities (Mandelstam arithmetic).

## Phase-2 targets

### FBD-001: omega0_nilpotent (OM-4)
**Goal**: prove `omega0 * omega0 = zeroEnd`
**Strategy**: expand definition, use `gamma_anticommute` from DiracAlgebra:
  ω₀² = ((γ₀+γ₃)/2)² = (γ₀²+γ₃²+{γ₀,γ₃})/4
  = (η₀₀·1 + η₃₃·1 + η₀₃·1)/2 = (1-1+0)/2 = 0 ✓

### FBD-002: omega0_anticomm_self (OM-2c)
**Goal**: `omega0*omega0 + omega0*omega0 = zeroEnd`
**Follows from**: FBD-001 (2*0 = 0)

### FBD-003: omegaSlash_sq (OM-3)
**Goal**: `(ω̸(A))² = (A₀²-A₁²-A₂²-A₃²)·1`
**Strategy**: expand `(Σ_μ A_μ ω_μ)²`, cross terms cancel by anticommutation.
  Diagonal: ω₀²·A₀² + ω₁²·A₁² + ω₂²·A₂² + ω₃²·A₃²
  = 0 + (-1)·A₁² + (-1)·A₂² + 0
  Cross terms: A₀A₁{ω₀,ω₁} + ... = 0
  BUT A₀ and A₃ terms come from ω₀=ω₃; need to account for the sum structure.

### FBD-004: omega0_eq_omega3 (OM-1)
**Goal**: `omega0 = omega3` (definitionally equal after unfolding smulEnd/addEnd)
**Strategy**: unfold definitions, use commutativity of `addEnd` (mul in FCEnd ring)
**Depends on**: `FCEnd` ring axioms (mul commutative? No, FCEnd is non-commutative)
**Revised strategy**: ω₀ = smul(1/2)(γ₀+γ₃), ω₃ = smul(1/2)(γ₃+γ₀)
  These are equal iff addEnd is commutative (i.e., γ₀+γ₃ = γ₃+γ₀ as matrices)
  → matrix addition IS commutative → proved in phase-2 via CliffordAlgebra axioms

### FBD-005: Bhabha full amplitude
**Goal**: state and prove Bhabha |M̄|²/e⁴ = 2[(s²+u²)/t²+(t²+u²)/s²+2u²/(st)]
**Strategy**: explicit trace calculation using TR-4 from DiracTrace.lean
**Depends on**: DiracTrace.spinorTrace_four (TR-4), Ward identity

### FBD-006: JW–omega duality
**Goal**: relate the ω algebra to the Jordan-Wigner isomorphism
**Context**: JW maps spin → fermion operators; ω matrices provide an extended
  Dirac representation — the connection is via the 2-site JW string coinciding
  with the ω₀/ω₃ null-projection structure.
**Strategy**: phase-2 formal statement linking FBD.omega algebra to
  QUANTUM.JordanWigner via a shared 2-site truncation.
**Depends on**: QUANTUM.JordanWigner, FBD.FBDPrelude

## Sorry budget
- FBD Phase-1 total: 6 sorrys + 3 axioms
- 2 theorems proved without sorry (CS-1 algebraic identity, CS-2 trivial)
-/

/-!
## FBD-007: WeakProcesses vacuous-content remediation plan (P1)
Target file:
  - CATEPTMain/AFPBridge/FBD/WeakProcesses.lean
Current stabilization:
  - Build blocker from `Real.pi` resolution fixed via trigonometric import.
  - Core weak-process identities remain phase-1 placeholders/sorries.
Vacuous/placeholder hotspot list:
  - `projLeft_add_projRight`
  - `projLeft_idempotent`
  - `projRight_idempotent`
  - `projLeft_projRight_zero`
  - `vaVertex_eq_chiral`
  - `muonDecayAmplitudeSq_nonneg`
  - `muonDecayRate_mass_scaling`
Phase-2 adjustments:
  1. Replace projector proofs with gamma-algebra lemmas from FEYNCALC (gamma5 square and
     anticommutation) instead of local algebraic placeholders.
  2. Strengthen positivity lemmas by introducing physically admissible momentum hypotheses
     for Minkowski products before proving amplitude nonnegativity.
  3. Retain closed-form decay-rate formula while replacing theorem-level `sorry` with
     inequalities proved through positivity and ring normalization.
Validation target:
  - `lake build CATEPTMain.AFPBridge.FBD.WeakProcesses` EXIT:0 with reduced sorry count.
-/

-- This file contains only documentation; no Lean declarations.
namespace CATEPTMain.AFPBridge.FBD
end CATEPTMain.AFPBridge.FBD
