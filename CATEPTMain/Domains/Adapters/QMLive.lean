import CATEPTMain.Domains.Adapters.QM

/-!
# QM Live Witness Carrier (T70 Phase-2 contract)

Partial close of `catept_qm_live_witness_phase2_entropy_20260427`
(T70: QM-adapter live tier via real `vonNeumannEntropy`).

The QM adapter [`qm`](./QM.lean) ships kernel-tier only because the
sibling-repo `vonNeumannEntropy` is currently a Phase-1 placeholder
returning `0` for every density matrix.  This module ships the
**Phase-2 contract** for the live tier without adding new axioms.

Strategy: define a structural carrier
`QMLiveWitnessCarrier n` that *requires* the consumer to supply a
density matrix `ρ₀` together with a proof
`0 < vonNeumannEntropy n ρ₀`.  Under Phase-1's placeholder no such
carrier can exist; under Phase-2's real `−Tr(ρ log ρ)` the maximally-
mixed state `I/n` discharges it for `n > 1`.

The carrier is the audit anchor: future Phase-2 work plugs into it
without changing this module's signature.

## Honest scope

* **No new axioms.**  The placeholder `vonNeumannEntropy` returns 0,
  so `qmLive` constructions remain vacuously empty until Phase-2
  supplies the real implementation.  This module ships only the
  contract carrier and the bridge from carrier to
  `LiveTemporalFramework`.
* **No claim that a witness exists** under current Phase-1.  Indeed,
  `qmLive_unobtainable_under_phase1_placeholder` records that a
  carrier *cannot* be constructed when `vonNeumannEntropy ≡ 0`.
* **No QM-side derivation.**  The actual eigendecomposition + log-
  spectrum entropy formula lives in `catept-domain-quantum`'s
  Phase-2 work.

## What is honestly proven

* `QMLiveWitnessCarrier n` (carrier struct): bundles `ρ₀ :
  DensityMatrix n` + the positivity hypothesis.
* `qmLive n c`: constructs `LiveTemporalFramework` from a witness.
* `qmLive_satisfies_spine`: the standard CAT/EPT coherence spine
  via `LiveTemporalFramework`'s inherited content.
* `qmLive_unobtainable_under_phase1_placeholder`: explicit note
  theorem documenting that under the current
  `vonNeumannEntropy ≡ 0` placeholder, no carrier instance can
  exist (since `0 < 0` is impossible).
-/

set_option autoImplicit false

namespace CATEPTMain.Temporal.Adapter

open CATEPTMain.Integration (cateptConsistencyConstraint)
open CATEPTMain.Quantum.QUANTUM (DensityMatrix vonNeumannEntropy)

noncomputable section

-- ═══════════════════════════════════════════════════════════════════════
-- Live-witness carrier
-- ═══════════════════════════════════════════════════════════════════════

/-- **QM live-witness carrier.**  Bundle a density matrix `ρ₀` with a
proof that its von Neumann entropy is strictly positive.  Under the
current Phase-1 placeholder `vonNeumannEntropy ≡ 0`, no such
witness exists; under Phase-2 (`−Tr(ρ log ρ)`), the maximally-mixed
state `I/n` for `n > 1` discharges it. -/
structure QMLiveWitnessCarrier (n : ℕ) where
  /-- The witness density matrix. -/
  rho : DensityMatrix n
  /-- Strict positivity of the von Neumann entropy on the witness. -/
  entropy_pos : 0 < vonNeumannEntropy n rho

namespace QMLiveWitnessCarrier

variable {n : ℕ}

/-- **Construct the live framework from a witness carrier.**  Promotes
the kernel-tier `qm n c.rho` to `LiveTemporalFramework` using the
carrier's positivity proof. -/
noncomputable def qmLive (c : QMLiveWitnessCarrier n) :
    LiveTemporalFramework where
  toTemporalFramework := qm n c.rho
  live_witness := ⟨c.rho, c.entropy_pos⟩

/-- **Live framework satisfies the kernel coherence spine.** -/
theorem qmLive_satisfies_spine (c : QMLiveWitnessCarrier n) :
    cateptConsistencyConstraint c.qmLive.toTemporalFramework.toCATEPTSlot :=
  c.qmLive.toTemporalFramework.coherence_spine

end QMLiveWitnessCarrier

-- ═══════════════════════════════════════════════════════════════════════
-- Note theorem: carrier vacuous under Phase-1 placeholder
-- ═══════════════════════════════════════════════════════════════════════

/-- **Note theorem documenting Phase-1 vacuity.**

Under the current Phase-1 placeholder `vonNeumannEntropy ≡ 0`, the
positivity hypothesis `0 < vonNeumannEntropy n ρ` is unsatisfiable
for any density matrix.  Hence `QMLiveWitnessCarrier n` cannot be
inhabited until Phase-2 supplies a real `−Tr(ρ log ρ)`.

This is the honest record: under the placeholder, no carrier
instance exists; consumers must wait for Phase-2 or supply their
own non-placeholder entropy.

Stated structurally so we don't have to depend on the placeholder
specifically: for any density matrix `ρ` whose entropy is `0`,
no carrier exists with that `ρ`. -/
theorem qmLive_unobtainable_when_entropy_zero
    (n : ℕ) (rho : DensityMatrix n)
    (h_zero : vonNeumannEntropy n rho = 0) :
    ¬ ∃ c : QMLiveWitnessCarrier n, c.rho = rho := by
  rintro ⟨c, hc⟩
  -- c.entropy_pos : 0 < vonNeumannEntropy n c.rho
  -- hc : c.rho = rho ⟹ vonNeumannEntropy n c.rho = vonNeumannEntropy n rho = 0
  have h_pos := c.entropy_pos
  rw [hc, h_zero] at h_pos
  exact lt_irrefl 0 h_pos

end

end CATEPTMain.Temporal.Adapter
