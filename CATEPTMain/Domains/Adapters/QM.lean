import CATEPTMain.Domains.TemporalFramework
import CATEPTMain.Domains.Invariants.Conservation
import CATEPTMain.Domains.Invariants.Reduction
import CATEPTMain.Domains.Invariants.Symmetry
import CATEPTMain.Domains.Invariants.QuantumCorrespondence
import CATEPTMain.Domains.UnifiedValidator
import CATEPTMain.Domains.QM.Domain

/-!
# QM Density-Matrix Adapter — `TemporalFramework` for von Neumann Entropy

Wraps `qmSuperiorSlot n` from `Domains/QM/Domain.lean` (which itself
re-exports the authoritative `vonNeumannEntropy` from sibling repo
`catept-domain-quantum`) as a kernel-tier `TemporalFramework`.

Configuration: `DensityMatrix n` (n × n mixed quantum states).
Clock: `S(ρ) = vonNeumannEntropy n ρ` (von Neumann entropy, ℏ = 1).

The adapter is **parameterised by a witness density matrix** `ρ₀`
because `DensityMatrix n` carries Hermitian / PSD / unit-trace proof
obligations that make a free Inhabited instance unavailable. The user
supplies any `ρ₀` (typically `pureDM` of some basis state).

This adapter is intentionally kernel-tier only. The phase-1
`vonNeumannEntropy` is a placeholder returning `0` for every state, so
there is no live witness available — `vonNeumannEntropy_pure` confirms
pure states give `S = 0` and the placeholder makes mixed states give
`S = 0` as well. Phase-2 (when `vonNeumannEntropy` becomes a real
`-Tr(ρ log ρ)`) will let the maximally-mixed state `I/n` give
`S = log n > 0` for `n > 1` and unlock `qmLive`.
-/

set_option autoImplicit false

namespace CATEPTMain.Temporal.Adapter

open CATEPTMain.Integration (cateptConsistencyConstraint)
open CATEPTMain.Quantum.QUANTUM (DensityMatrix vonNeumannEntropy
  vonNeumannEntropy_nonneg)

/-- QM density-matrix temporal framework.

    The witness is supplied externally (any `ρ₀ : DensityMatrix n`)
    because the structure carries Hermitian / PSD / unit-trace
    obligations that prevent a default Inhabited instance. -/
noncomputable def qm (n : ℕ) (ρ₀ : DensityMatrix n) : TemporalFramework where
  Config := DensityMatrix n
  clock := fun ρ => vonNeumannEntropy n ρ
  clock_nonneg := fun ρ => vonNeumannEntropy_nonneg n ρ
  witness := ρ₀

theorem qm_satisfies_spine (n : ℕ) (ρ₀ : DensityMatrix n) :
    cateptConsistencyConstraint (qm n ρ₀).toCATEPTSlot :=
  (qm n ρ₀).coherence_spine

-- ── Per-invariant claims (3/4 — QC deferred to phase-2) ──────────────

noncomputable def qm_conservation (n : ℕ) (ρ₀ : DensityMatrix n) :
    ConservationInvariant (qm n ρ₀) :=
  (qm n ρ₀).vacuumConservation

noncomputable def qm_reduction (n : ℕ) (ρ₀ : DensityMatrix n) :
    ReductionInvariant (qm n ρ₀) where
  classicalProjection := (qm n ρ₀).clock
  target := (qm n ρ₀).clock
  reduces_classically := fun _ => rfl

/-- Trivial (identity) symmetry. The full QM symmetry analysis (clock
    invariance under unitary conjugation `ρ ↦ U ρ U†`) requires a
    unitary-action interface that is not yet exposed at the
    `TemporalFramework` slot level. Kernel tier is satisfied. -/
noncomputable def qm_symmetry (n : ℕ) (ρ₀ : DensityMatrix n) :
    SymmetryInvariant (qm n ρ₀) :=
  (qm n ρ₀).identitySymmetry

theorem qm_validates (n : ℕ) (ρ₀ : DensityMatrix n) :
    UnifiedValidator (qm n ρ₀)
      (some <| qm_conservation n ρ₀)
      (some <| qm_reduction n ρ₀)
      (some <| qm_symmetry n ρ₀)
      none :=
  ⟨(qm n ρ₀).coherence_spine,
   (qm_conservation n ρ₀).divergence_free,
   (qm_reduction n ρ₀).reduces_classically,
   (qm_symmetry n ρ₀).clock_invariant,
   trivial⟩

end CATEPTMain.Temporal.Adapter
