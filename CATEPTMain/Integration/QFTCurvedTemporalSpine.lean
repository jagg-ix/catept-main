import CATEPTMain.Domains.TemporalFramework
import CATEPTMain.Integration.PhyslibCATEPTSpaceTimeAdapter
import NavierStokesClean.CATEPT.CurvedSpacetimePathIntegral

/-!
# QFT-in-Curved-Space → CAT/EPT TemporalFramework

**First-class spine adapter** for QFT in curved spacetime: lifts
`NavierStokesClean.CATEPT.CurvedMeasurePathIntegralModel α` into the
canonical `CATEPTMain.Temporal.TemporalFramework`, so the universal
`coherence_spine` theorem discharges the CAT/EPT identity
`actionIm / ℏ = eptClock` for free.

## Why this PR exists

Per the 2026-04-29 architecture review, the rule should be:

> A theory is "on the same CAT/EPT spine" only if it is exposed as a
> `TemporalFramework`, or projects into one through
> `RelationalInformationSubstrate`.

QM (PR #8 + Domains/Adapters/QM), GR/SR (PR #9 +
Domains/Adapters/Minkowski + PhyslibCATEPTSpaceTimeAdapter), and the
computational substrate (RelationalInformationSubstrate) are already
on the spine.  QFT-in-curved-space had the right mathematical objects
(`CurvedMeasurePathIntegralModel` with `actionRe`, `actionIm`, `hbar`,
`actionIm_nonneg`) but no thin adapter exposing it as a
`TemporalFramework`.  This PR adds that adapter.

## What is honestly proven

* `curvedMTPI_toTemporalFramework`: a `CurvedMeasurePathIntegralModel α`
  + an `α`-witness produces a `TemporalFramework` with
  `Config := α` and `clock x := actionIm x / hbar`.
* `curvedMTPI_clock_nonneg`: the clock is non-negative — a quotient of
  non-negative numerator (`actionIm_nonneg`) by positive denominator
  (`hbar_pos`).
* `curvedMTPI_satisfies_spine`: the lifted framework satisfies the CAT/EPT
  spine identity by `TemporalFramework.coherence_spine`.
* `curvedMTPI_clock_eq_actionImScaled`: the clock is exactly the rescaled
  imaginary action `actionIm x / hbar` (= the entropic-time density
  τ_ent at `x`).
* `qm_classical_sr_qft_curved_joint_satisfies_spine`: the four-way joint
  framework
  `harmonic ⊕ physlib-SR ⊕ qm ⊕ qft-curved`
  (composed via `JointAdapter.joint`) satisfies the same spine identity
  — one composite entropic clock spans QM + classical mechanics + GR/SR
  + QFT-in-curved-space.

## Honest scope

This is the *spine adapter* layer.  It does **not**:

- Derive `CurvedMeasurePathIntegralModel` from microscopic CAT/EPT
  primitives (that would be a P27-style derivation; the Curved-MTPI
  carrier is taken as a structural input).
- Construct a concrete curved-spacetime example (the `α`-witness is
  caller-supplied).
- Project into `RelationalInformationSubstrate` (left as a follow-on:
  `curvedMTPI_to_substrate` would supply
  `irreversibleCost := actionIm`).

What it DOES is make the universal CAT/EPT spine theorem applicable to
*any* curved-MTPI model, the same way PR #9's `LorentzianSpaceTime`
adapter made it applicable to any Physlib-style relativistic spacetime.

## Distribution-lane note

This file is **not** imported by `CATEPTMain.lean` (the root umbrella).
The `NavierStokesClean.CATEPT.CurvedSpacetimePathIntegral` import drags
in the `Mathlib.Analysis.Distribution.*` lane that conflicts with
`Physlib.Mathematics.Distribution.*`; the audit lines live in
`CATEPTMain.Domains.CoherenceShowcase` (itself outside the root umbrella
graph), inheriting the same constraint already established for
`Adapters/SR`, `Domains/SR/Domain`, and the existing
`PhyslibCATEPTSpaceTimeAdapter`.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration

open CATEPTMain.Temporal (TemporalFramework)
open NavierStokesClean.CATEPT (CurvedMeasurePathIntegralModel)

-- ═══════════════════════════════════════════════════════════════════════
-- Adapter: CurvedMeasurePathIntegralModel → TemporalFramework
-- ═══════════════════════════════════════════════════════════════════════

/-- **Adapter** lifting a curved-spacetime CAT/EPT path-integral model
into a `TemporalFramework`.

The carrier `α` is the configuration space; the clock is the rescaled
imaginary action `actionIm x / hbar` (= the entropic-time density
τ_ent at `x`).  The non-negativity of `actionIm` plus positivity of
`hbar` give the kernel-tier `clock_nonneg`. -/
noncomputable def curvedMTPI_toTemporalFramework
    {α : Type} [MeasurableSpace α]
    (c : CurvedMeasurePathIntegralModel α) (witness : α) :
    TemporalFramework where
  Config := α
  clock := fun x => c.actionIm x / c.hbar
  clock_nonneg := fun x =>
    div_nonneg (c.actionIm_nonneg x) c.hbar_pos.le
  witness := witness

/-- **Clock identity**: the lifted framework's clock IS the rescaled
imaginary action `actionIm x / hbar`. -/
theorem curvedMTPI_clock_eq_actionImScaled
    {α : Type} [MeasurableSpace α]
    (c : CurvedMeasurePathIntegralModel α) (witness : α) (x : α) :
    (curvedMTPI_toTemporalFramework c witness).clock x = c.actionIm x / c.hbar :=
  rfl

/-- **Clock non-negativity** (extracted as a named lemma). -/
theorem curvedMTPI_clock_nonneg
    {α : Type} [MeasurableSpace α]
    (c : CurvedMeasurePathIntegralModel α) (witness : α) (x : α) :
    0 ≤ (curvedMTPI_toTemporalFramework c witness).clock x :=
  (curvedMTPI_toTemporalFramework c witness).clock_nonneg x

/-- ★ HEADLINE ★ The QFT-curved-space lift satisfies the CAT/EPT spine
identity `actionIm / ℏ = eptClock`.

Proof: one application of `TemporalFramework.coherence_spine`.  No
per-domain work — the universal theorem carries through. -/
theorem curvedMTPI_satisfies_spine
    {α : Type} [MeasurableSpace α]
    (c : CurvedMeasurePathIntegralModel α) (witness : α) :
    cateptConsistencyConstraint
      (curvedMTPI_toTemporalFramework c witness).toCATEPTSlot :=
  (curvedMTPI_toTemporalFramework c witness).coherence_spine

-- ═══════════════════════════════════════════════════════════════════════
-- Joint demo: QM ⊕ classical ⊕ Physlib-SR ⊕ QFT-curved
-- ═══════════════════════════════════════════════════════════════════════

open CATEPTMain.Temporal.Adapter (joint)
open CATEPTMain.Quantum.QUANTUM (DensityMatrix)

/-- **Four-way joint TemporalFramework** spanning QM, classical mechanics,
Physlib SR, and QFT-in-curved-space — one composite entropic clock.

The joint clock decomposes additively: `clock(x_HO, (q,p), ρ, x_QFT) =
H(x_HO) + properTime q p + vonNeumannEntropy ρ + actionIm(x_QFT)/ℏ`. -/
noncomputable def qm_classical_sr_qft_curved_joint
    {α : Type} [MeasurableSpace α]
    (d n : ℕ) (ρ₀ : DensityMatrix n)
    (c : CurvedMeasurePathIntegralModel α) (witness : α) :
    TemporalFramework :=
  joint (harmonicSRQM d n ρ₀)
        (curvedMTPI_toTemporalFramework c witness)

/-- ★ HEADLINE ★ The four-way **QM ⊕ classical ⊕ Physlib-SR ⊕ QFT-curved**
joint framework satisfies the CAT/EPT spine identity.

Same one-line proof as every other joint adapter — the universal
`coherence_spine` carries through composition.  Confirms that QFT-in-
curved-space is now first-class on the spine: it composes with the
existing three-way joint (PR #9 `harmonicSRQM`) without any new spine
machinery. -/
theorem qm_classical_sr_qft_curved_joint_satisfies_spine
    {α : Type} [MeasurableSpace α]
    (d n : ℕ) (ρ₀ : DensityMatrix n)
    (c : CurvedMeasurePathIntegralModel α) (witness : α) :
    cateptConsistencyConstraint
      (qm_classical_sr_qft_curved_joint d n ρ₀ c witness).toCATEPTSlot :=
  (qm_classical_sr_qft_curved_joint d n ρ₀ c witness).coherence_spine

end CATEPTMain.Integration
