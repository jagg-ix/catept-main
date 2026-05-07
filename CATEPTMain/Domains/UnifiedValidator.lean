import CATEPTMain.Domains.TemporalFramework
import CATEPTMain.Domains.Invariants.Conservation
import CATEPTMain.Domains.Invariants.Reduction
import CATEPTMain.Domains.Invariants.Symmetry
import CATEPTMain.Domains.Invariants.QuantumCorrespondence

/-!
# UnifiedValidator — Per-Adapter Coverage of the CAT/EPT Invariant Suite

T66f. Composes the kernel coherence-spine theorem with four opt-in
invariants (Conservation, Reduction, Symmetry, QuantumCorrespondence)
into a single Prop a `TemporalFramework` instance can claim.

Each invariant is `Option`-wrapped so adapters declare exactly which
invariants they witness; non-claimed invariants are vacuously `True`.
The validator records, on a single Prop, whether the spine constraint
holds AND whether each claimed invariant's content is satisfied.

## Pattern

```lean
example (μ₀ : ℝ) (hμ₀ : 0 < μ₀) :
    UnifiedValidator (em μ₀ hμ₀)
      (some <| em_conservation μ₀ hμ₀)
      (some <| em_reduction μ₀ hμ₀)
      (some <| em_symmetry μ₀ hμ₀)
      none := ⟨…⟩
```

The `none` for `QuantumCorrespondence` says "this adapter does not
claim that invariant" — the Prop stays True for that slot.
-/

set_option autoImplicit false

namespace CATEPTMain.Temporal

/-- Per-invariant content extractor (the Prop the invariant asserts). -/
def ConservationInvariant.content {T : TemporalFramework}
    (C : ConservationInvariant T) : Prop :=
  ∀ (cfg : T.Config) (ν : Fin 4), C.divergence cfg ν = 0

def ReductionInvariant.content {T : TemporalFramework}
    (R : ReductionInvariant T) : Prop :=
  ∀ x, R.classicalProjection x = R.target x

def SymmetryInvariant.content {T : TemporalFramework}
    (S : SymmetryInvariant T) : Prop :=
  ∀ x, T.clock (S.sigma x) = T.clock x

def QuantumCorrespondenceInvariant.content {T : TemporalFramework}
    (Q : QuantumCorrespondenceInvariant T) : Prop :=
  ∀ x, Q.curvature x = 8 * Real.pi * Q.G * Q.expectationValue x

/-- ★ THE UNIFIED VALIDATOR ★

    A `TemporalFramework` instance, together with optional invariant
    claims, satisfies `UnifiedValidator` iff:

      • the kernel CAT/EPT spine constraint holds (always required), AND
      • each `some`-claimed invariant's content holds.

    Non-claimed invariants (`none`) are vacuously `True`. -/
def UnifiedValidator (T : TemporalFramework)
    (cons : Option (ConservationInvariant T))
    (red  : Option (ReductionInvariant T))
    (sym  : Option (SymmetryInvariant T))
    (qc   : Option (QuantumCorrespondenceInvariant T)) : Prop :=
  CATEPTMain.Integration.cateptConsistencyConstraint T.toCATEPTSlot ∧
  (cons.elim True ConservationInvariant.content) ∧
  (red.elim True ReductionInvariant.content) ∧
  (sym.elim True SymmetryInvariant.content) ∧
  (qc.elim True QuantumCorrespondenceInvariant.content)

/-- A `TemporalFramework` with no extra invariant claims still passes
    the validator (the spine constraint is the kernel default). -/
theorem UnifiedValidator.spine_only (T : TemporalFramework) :
    UnifiedValidator T none none none none :=
  ⟨T.coherence_spine, trivial, trivial, trivial, trivial⟩

/-- A framework that claims all four invariants passes the validator
    by aggregating each claim's content. -/
theorem UnifiedValidator.full
    (T : TemporalFramework)
    (cons : ConservationInvariant T)
    (red  : ReductionInvariant T)
    (sym  : SymmetryInvariant T)
    (qc   : QuantumCorrespondenceInvariant T) :
    UnifiedValidator T (some cons) (some red) (some sym) (some qc) :=
  ⟨T.coherence_spine,
   cons.divergence_free,
   red.reduces_classically,
   sym.clock_invariant,
   qc.bridges⟩

end CATEPTMain.Temporal
