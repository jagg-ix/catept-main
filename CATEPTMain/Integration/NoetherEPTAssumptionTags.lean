import CATEPTMain.Core.Assumptions
import CATEPTMain.CATEPT.CATEPT.NoetherEPT

/-!
# NoetherEPT assumption tags (T100) — physics-Noether retrofit

Retrofits the new `noetherInvariantUnderEPT` AssumptionId by wrapping
the substantive Noether-invariant theorems from
`CATEPTMain/CATEPT/CATEPT/NoetherEPT.lean`. Unlike T99 (which used
abstract Phase-1 placeholder Props), THIS retrofit wraps fully-proved
theorems — the wrapped Props are concrete IsConstant statements with
real `HasDerivAt` proof chains underlying them.

## Background

The Mathlib file `Mathlib/FieldTheory/JacobsonNoether.lean` is about
Emmy Noether's 1933 ALGEBRA theorem (division algebras), NOT her 1918
PHYSICS theorem (symmetry → conservation). Mathlib has no
formalization of the 1918 physics theorem.

However, `CATEPTMain/CATEPT/CATEPT/NoetherEPT.lean` already contains
the CAT/EPT-flavored physics-Noether content with real proofs:

  * `cat_decay_implies_invariant_constant`
      Under CAT decay `dE/dt = -(γ/ℏ)·E`, the dressed energy
      `J_CAT(t) = E(t)·exp(γ t/ℏ)` is constant.
      Proof: `cat_decay_implies_invariant_deriv_zero` →
             `deriv_zero_implies_constant`.

  * `ept_decay_implies_invariant_constant`
      Under EPT decay `dE/dt = -(T_exp(t)/ℏ)·E` and accumulation
      `T_acc' = T_exp`, the dressed `J_EPT(t) = E(t)·exp(T_acc(t)/ℏ)`
      is constant.

Both are Noether-theorem-flavored: a conserved quantity associated
with the exponential-decay symmetry that emerges from time-translation
under damping. T100 wraps each under `noetherInvariantUnderEPT`.

## Effect on the registry audit

  Before T100:
    Total ids: 30
    Referenced: 24
    Dead: 6
  After T100:
    Total ids: 31 (added noetherInvariantUnderEPT)
    Referenced: 25 (new id immediately referenced)
    Dead: 6 (unchanged)

## Why this is more substantive than the T99 retrofit pattern

T99 wrapped `Prop := True` placeholders. T100 wraps fully-proved
`IsConstant` predicates whose proofs use real Lean tactics
(`HasDerivAt`, `deriv_const_mul`, `add_left_neg`, etc.). The audit
gate sees actual proof content here, not a tracking marker.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.NoetherEPTAssumptionTags

open CATEPTMain (CATEPTAssumption)
open CATEPTMain.AssumptionId
open CATEPTMain.CATEPT.CATEPT
  (PhysicalConstants
   SatisfiesCATExponentialDecay SatisfiesEPTDecay IsAccumulationOf
   CATDecayInvariant EPTInvariant IsConstant
   cat_decay_implies_invariant_constant
   ept_decay_implies_invariant_constant)

/-- **CAT-side Noether invariant tag.**

    The dressed-energy invariant `J_CAT(t) = E(t)·exp(γ t/ℏ)` is
    constant under CAT exponential decay, tagged with
    `noetherInvariantUnderEPT`. Proof is the existing
    `cat_decay_implies_invariant_constant` theorem in
    `NoetherEPT.lean`. -/
theorem cat_noether_invariant_tag
    (c : PhysicalConstants) (γ : ℝ) (E : ℝ → ℝ)
    (hE_diff : Differentiable ℝ E)
    (hE : SatisfiesCATExponentialDecay c γ E) :
    CATEPTAssumption noetherInvariantUnderEPT
      (IsConstant (fun t => CATDecayInvariant c γ E t)) :=
  cat_decay_implies_invariant_constant c γ E hE_diff hE

/-- **EPT-side Noether invariant tag.**

    The accumulated-dressed-energy invariant
    `J_EPT(t) = E(t)·exp(T_acc(t)/ℏ)` is constant under EPT decay
    plus accumulation `T_acc' = T_exp`, tagged with
    `noetherInvariantUnderEPT`. Proof is the existing
    `ept_decay_implies_invariant_constant` theorem. -/
theorem ept_noether_invariant_tag
    (c : PhysicalConstants) (Tacc Texp : ℝ → ℝ) (E : ℝ → ℝ)
    (hE_diff : Differentiable ℝ E) (hTacc_diff : Differentiable ℝ Tacc)
    (hacc : IsAccumulationOf Tacc Texp)
    (hE : SatisfiesEPTDecay c Texp E) :
    CATEPTAssumption noetherInvariantUnderEPT
      (IsConstant (fun t => EPTInvariant c Tacc E t)) :=
  ept_decay_implies_invariant_constant c Tacc Texp E hE_diff hTacc_diff hacc hE

/-- **Bundled Noether-invariant discharge.** Both CAT-side and
    EPT-side Noether invariants tagged with the same registry id,
    documenting that the EPT-accumulated form is the natural
    generalisation of the CAT exponential form. -/
theorem noether_invariants_under_ept_discharged
    (c : PhysicalConstants) (γ : ℝ) (E : ℝ → ℝ)
    (hE_diff : Differentiable ℝ E)
    (hE : SatisfiesCATExponentialDecay c γ E)
    (Tacc Texp : ℝ → ℝ)
    (hTacc_diff : Differentiable ℝ Tacc)
    (hacc : IsAccumulationOf Tacc Texp)
    (hE_ept : SatisfiesEPTDecay c Texp E) :
    CATEPTAssumption noetherInvariantUnderEPT
      (IsConstant (fun t => CATDecayInvariant c γ E t))
    ∧ CATEPTAssumption noetherInvariantUnderEPT
      (IsConstant (fun t => EPTInvariant c Tacc E t)) :=
  ⟨cat_noether_invariant_tag c γ E hE_diff hE,
   ept_noether_invariant_tag c Tacc Texp E hE_diff hTacc_diff hacc hE_ept⟩

end CATEPTMain.Integration.NoetherEPTAssumptionTags
