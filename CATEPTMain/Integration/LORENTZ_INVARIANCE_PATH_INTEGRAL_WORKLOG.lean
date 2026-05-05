/-!
# Lorentz Invariance Path-Integral Worklog

REPLYID: CAT-EPT-20260505-02
Scope: FEYNCALC Lorentz algebra + LIPS invariant machinery leverage for
       Lorentz-invariant path-integral implementations.

Conventions:
  - LI-* records in this worklog
  - Status: TODO | IN-PROGRESS | DONE | BLOCKED
  - Priority: P1 (required), P2 (next), P3 (optional)

-/

/-!
## LI-001  Lorentz-invariant proper-time kernel (P1)
Goal:
  Define a proper-time kernel using FEYNCALC `lorentzProduct p p` and
  prove the damping depends only on the invariant `p^2 + m^2`.
Bridge:
  - CATEPTMain.GaugeTheory.FEYNCALC.LorentzAlgebra.lorentzProduct
  - CATEPTMain.GaugeTheory.FEYNCALC.pSlash_sq
  - CATEPTMain.Integration.ProperTimeFeynCalcBridge
Status: IN-PROGRESS
Record:
  - Added `CATEPTMain/Integration/LorentzInvariantProperTimeBridge.lean`.

-/

/-!
## LI-002  Invariant carrier for Mandelstam/Gram/Sigma5/tr5 (P1)
Goal:
  Introduce a Lean carrier for invariants:
    s_ij, s_ijk, Delta_ij|kl|mn, Sigma5, tr5
  and add mapping lemmas to FEYNCALC Lorentz products.
Source evidence: LIPS invariant grammar in `lips/invariants.py`.
Status: IN-PROGRESS
Record:
  - Added `CATEPTMain/Integration/LorentzInvariantInvariants.lean` with
    Mandelstam and Gram/tr5 carriers.

-/

/-!
## LI-003  Symmetry action on invariants (P2)
Goal:
  Add permutation + parity action on invariant lists and prove
  invariance of Lorentz-scalar kernels under the action.
Source evidence: `lips/symmetries.py`.
Status: DONE
Record:
  - Added `LorentzInvariantSymmetryActions.lean` with permutation/parity actions
    and Lorentz-scalar kernel invariance carrier.

-/

/-!
## LI-004  Invariant-slice constraint carrier (P2)
Goal:
  Model a constraint system for momentum conservation and on-shell
  constraints, and expose a "slice" witness for invariant variables.
Source evidence: LIPS covariant/invariant ideals and slicing.
Status: DONE
Record:
  - Added `LorentzInvariantSliceConstraints.lean` with constraint and slice
    witness carriers.

-/

/-!
## LI-005  Collinear/soft limit stability (P2)
Goal:
  Add a lemma that CAT/EPT damping remains stable under collinear
  or soft limits expressed in invariant variables.
Source evidence: LIPS hardcoded limits and set/set-pair tests.
Status: DONE
Record:
  - Added `LorentzInvariantLimitStability.lean` with collinear/soft
    limit stability carriers.

-/

/-!
## LI-006  Lorentz-invariant phase-space measure (P3)
Goal:
  Add a carrier for a Lorentz-invariant measure and show the path
  integral depends only on invariants for scalar integrands.
Status: DONE
Record:
  - Added `LorentzInvariantPhaseSpaceMeasure.lean` with a phase-space
    measure carrier on invariant integrands.

-/

/-!
## LI-007  tr5 / Levi-Civita invariant carrier (P2)
Goal:
  Add a `tr5_ijkl` carrier defined from Levi-Civita contraction of four
  momenta and connect it to FEYNCALC `leviCivita` identities.
Source evidence: LIPS `test_particles_compute_tr5_1234`.
Status: DONE
Record:
  - `tr5` carrier in `LorentzInvariantInvariants.lean`.
  - Added `LorentzInvariantTr5LeviCivitaBridge.lean` with the explicit
    Levi-Civita expansion lemma.

-/

/-!
## LI-008  Gram determinant invariants (P2)
Goal:
  Define `Delta` invariants as determinants of Lorentz products and
  add basic symmetry/positivity lemmas.
Source evidence: LIPS `test_particles_compute_three_mass_gram` and
  `test_particles_compute_four_mass_box_gram`.
Status: DONE
Record:
  - `gramDet2` carrier in `LorentzInvariantInvariants.lean`.
  - Added `LorentzInvariantGramDetLemmas.lean` with symmetry/positivity claims.

-/

/-!
## LI-009  Sigma5 invariant (P2)
Goal:
  Add a carrier for `Sigma5` and the alternate polynomial identity
  used in LIPS for 6-point kinematics.
Source evidence: LIPS `test_particles_compute_Sigma5`.
Status: IN-PROGRESS
Record:
  - Sigma5 carrier and identity stub in `LorentzInvariantInvariants.lean`.

-/

/-!
## LI-010  Spinor-bracket grammar carrier (P2)
Goal:
  Introduce a minimal notation layer for angle/square brackets and
  mixed strings like `<i|p+q|j]` with a parsing/expansion lemma.
Source evidence: LIPS `Particles_Compute` parser tests.
Status: IN-PROGRESS
Record:
  - Added `LorentzInvariantSpinorBrackets.lean` with bracket AST and expansion.

-/
