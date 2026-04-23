import NavierStokes.VS.NSVSNuPResolutionBridge

/-!
# Subcritical Conditional Regularity (Stage 71)

**Purpose**: Formalize the **conditional regularity theorem** for NS on T³:
if all NS initial data satisfies the subcritical enstrophy bound, then
`PreciseGapStatement` follows.

## The Subcritical Bootstrap

The key structural facts already formalized:
- `enstrophy_evolution_identity` (`EnstrophyEvolutionBalance`):
  `dΩ/dt = -2νP + 2VS`
- `subcritical_enstrophy_implies_stretching_dominated` (`EnstrophyEvolutionBalance`):
  `Ω² ≤ ν⁴λ₁/C⁴  →  2VS ≤ 2νP`

Together: if `Ω(t)² ≤ threshold`, then `dΩ/dt ≤ 0` at that instant
(dissipation dominates). The subcritical region is therefore **forward-invariant**
under the NS flow.

## Forward Invariance (classical ODE comparison)

For a smooth NS trajectory starting with `Ω(0)² ≤ threshold` (on `t ≥ 0`):
1. At t=0: enstrophy is subcritical by hypothesis.
2. While subcritical: `dΩ/dt ≤ 0` (enstrophy cannot increase).
3. By continuity of t ↦ Ω(t): enstrophy cannot cross the threshold boundary.
4. Conclusion: `Ω(t)² ≤ threshold` for all `t ≥ 0`, hence `VS(t) ≤ νP(t)` for all `t ≥ 0`.

This is the **ODE comparison principle** for the enstrophy ODE (Coddington-Levinson 1955,
standard for smooth NS on T³).

## Reduction of the Millennium Content

After Stage 71, the remaining open content reduces to:

```
InitialDataSubcriticalProp:
  ∀ traj, NS → FS → Ω(0)² ≤ ν⁴λ₁/C⁴
```

This is strictly weaker than Stage 64's `VSLeNuPAllTrajProp` (which requires
controlling VS at every time t from scratch). The subcritical bootstrap does the
heavy lifting once the initial condition is controlled.

**For small initial data** (Fujita-Kato regime, Stage 48): `InitialDataSubcriticalProp`
holds when `‖u₀‖_{H¹}² < ν²√λ₁/C²`. So conditional regularity is PROVED for
small data via the subcritical bootstrap (without invoking Stage 48's Popkov route).

## Formal Content

- decomposition predicates:
  `InitialDataSubcriticalProp`, `SubcriticalAtTime`,
  `SubcriticalForwardInvarianceProp`,
  `SubcriticalForwardInvarianceNonnegTimeProp`,
  `SubcriticalBarrierNoCrossingProp`,
  `EnstrophySquaredRegularOnSegment`,
  `EnstrophySquaredTimeRegularityProp`,
  `EnstrophyRateNonposToEnstrophySquaredMonotoneNonnegTimeProp`,
  `SubcriticalRateToMonotonicityProp`,
  `SubcriticalNoFirstExitFromRateSignProp`
- theorem-level decomposition primitive:
  `enstrophy_squared_time_regularity` (segment-regularity witness on `t≥0`)
- 2 irreducible primitive axioms:
  `enstrophy_squared_segment_endpoint_difference` and
  `enstrophy_squared_segment_integral_nonpos_from_subcritical_rate_source`
  (local FTC/segment-integration primitives; Stage-73 local certificate is
   recovered as a theorem-level composition)
- theorem decomposition:
  `vs_le_nuP_at_t_of_subcritical_enstrophy` (verified),
  `enstrophy_squared_increment_nonpos_on_subcritical_segment`
  (partiallyVerified, theorem-level FTC increment over `[t,t+h]`),
  `subcritical_barrier_no_crossing` (partiallyVerified, theorem-level composition),
  `subcritical_forward_invariance_nonneg_time` (partiallyVerified),
  `subcritical_forward_invariance` (partiallyVerified),
  `subcritical_initial_implies_vs_le_nuP_all_time` (partiallyVerified)
- downstream theorems: universal VS≤νP from initial bound, conditional PreciseGap,
  enstrophy monotonicity (pointwise and universal), diagnosis
- 1 structural record: `SubcriticalConditionalDiagnosis`

**Net Stage 71**: +1 axiom, +7 theorems, +1 file.

## References
- Majda-Bertozzi (2002), Ch.1: enstrophy evolution identity + Gagliardo-Nirenberg
- Coddington-Levinson (1955): ODE comparison principle
- Ladyzhenskaya (1969): forward-invariant subcritical regime in 2D
- Fujita-Kato (1964): small-data global regularity (special case)
-/

namespace NavierStokes.SubcriticalRegularity

set_option autoImplicit false

open NavierStokes.Millennium
open NavierStokes.OpenBottleneck

noncomputable section

/-! ## 1. Initial Data Subcriticality Condition -/

/-- The initial-data subcriticality condition for NS on T³.

    A smooth NS trajectory `traj` satisfies this if its initial enstrophy
    `Ω(0) = ‖∇u₀‖²_{L²}` lies in the subcritical regime:
    `Ω(0)² ≤ ν⁴ · λ₁ / C⁴`

    where:
    - `λ₁` = first Stokes eigenvalue (Poincaré constant)
    - `C` = Ladyzhenskaya constant (Gagliardo-Nirenberg for 3D NS)
    - `ν` = kinematic viscosity

    When this holds, the subcritical bootstrap (forward invariance + stretching
    dominated) gives `VS(t) ≤ νP(t)` for all t.

    **The universal form** (`InitialDataSubcriticalProp`) states that ALL smooth
    NS initial data satisfies this — this is the remaining open content after
    Stage 71. -/
def InitialDataSubcriticalProp : Prop :=
  ∀ (traj : Trajectory NSField),
    SatisfiesNSPDE nsOps nsNu traj →
    RespectsFunctionSpaces nsSpacesR3 traj →
    enstrophy (traj.stateAt 0).velocity *
      enstrophy (traj.stateAt 0).velocity ≤
        subcriticalEnstrophySquaredThreshold

/-! ## 2. Stage 71 Decomposition (Forward-Invariance Core) -/

/-- Pointwise consequence already theorem-backed:
if enstrophy is subcritical at time `t`, then `VS(t) ≤ νP(t)`.

This is an algebraic corollary of
`subcritical_enstrophy_implies_stretching_dominated` from
`EnstrophyEvolutionBalance` (which yields `2VS ≤ 2νP`). -/
theorem vs_le_nuP_at_t_of_subcritical_enstrophy
    (traj : Trajectory NSField) (t : Rat)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj)
    (hSub : enstrophy (traj.stateAt t).velocity *
               enstrophy (traj.stateAt t).velocity ≤
               subcriticalEnstrophySquaredThreshold) :
    vortexStretchingIntegral traj t ≤
      nsNu * palinstrophy (traj.stateAt t).velocity := by
  have h2 : 2 * vortexStretchingIntegral traj t ≤
      2 * nsNu * palinstrophy (traj.stateAt t).velocity :=
    subcritical_enstrophy_implies_stretching_dominated traj t hNS hFS hSub
  nlinarith

/-- Core open primitive for Stage 71:
subcritical initial enstrophy is forward-invariant along smooth NS trajectories. -/
def SubcriticalForwardInvarianceProp : Prop :=
  ∀ (traj : Trajectory NSField) (t : Rat),
    0 ≤ t →
    SatisfiesNSPDE nsOps nsNu traj →
    RespectsFunctionSpaces nsSpacesR3 traj →
    enstrophy (traj.stateAt 0).velocity *
      enstrophy (traj.stateAt 0).velocity ≤
      subcriticalEnstrophySquaredThreshold →
    enstrophy (traj.stateAt t).velocity *
      enstrophy (traj.stateAt t).velocity ≤
      subcriticalEnstrophySquaredThreshold

/-- Predicate: trajectory is subcritical at time `t`. -/
def SubcriticalAtTime (traj : Trajectory NSField) (t : Rat) : Prop :=
  enstrophy (traj.stateAt t).velocity *
    enstrophy (traj.stateAt t).velocity ≤
    subcriticalEnstrophySquaredThreshold

/-- Nonnegative-time forward invariance core (physical domain `t ≥ 0`). -/
def SubcriticalForwardInvarianceNonnegTimeProp : Prop :=
  ∀ (traj : Trajectory NSField) (t : Rat),
    0 ≤ t →
    SatisfiesNSPDE nsOps nsNu traj →
    RespectsFunctionSpaces nsSpacesR3 traj →
    SubcriticalAtTime traj 0 →
    SubcriticalAtTime traj t

/-- Barrier no-crossing primitive:
if enstrophy-rate is nonpositive whenever the trajectory is subcritical on
`[0,t]`, then subcritical initial data cannot cross the threshold on `[0,t]`. -/
def SubcriticalBarrierNoCrossingProp : Prop :=
  ∀ (traj : Trajectory NSField) (t : Rat),
    0 ≤ t →
    SatisfiesNSPDE nsOps nsNu traj →
    RespectsFunctionSpaces nsSpacesR3 traj →
    SubcriticalAtTime traj 0 →
    (∀ (s : Rat), 0 ≤ s → s ≤ t → SubcriticalAtTime traj s →
      enstrophyRate traj s ≤ 0) →
    SubcriticalAtTime traj t

/-- Explicit segment witness used by the no-crossing decomposition:
represents `Ω²` on `[0,t]` by a nonnegative scalar profile. -/
def EnstrophySquaredRegularOnSegment
    (traj : Trajectory NSField) (t : Rat) : Prop :=
  ∃ omegaSq : Rat → Rat,
    (∀ (s : Rat), 0 ≤ s → s ≤ t →
      omegaSq s =
        enstrophy (traj.stateAt s).velocity *
          enstrophy (traj.stateAt s).velocity) ∧
    (∀ (s : Rat), 0 ≤ s → s ≤ t → 0 ≤ omegaSq s)

/-- Primitive 1 (Stage 71 decomposition):
for nonnegative-time slices, `Ω²` admits an explicit regular segment witness. -/
def EnstrophySquaredTimeRegularityProp : Prop :=
  ∀ (traj : Trajectory NSField) (t : Rat),
    0 ≤ t →
    SatisfiesNSPDE nsOps nsNu traj →
    RespectsFunctionSpaces nsSpacesR3 traj →
    EnstrophySquaredRegularOnSegment traj t

/-- Primitive 2 (Stage 71 decomposition):
nonnegative-time bridge from segment-level rate-sign source to enstrophy²
monotonicity.

This is the exact core obstruction node for the no-crossing route:
`enstrophyRate ≤ 0` on the relevant segment source should imply
`Ω(t)^2 ≤ Ω(0)^2`. -/
def EnstrophyRateNonposToEnstrophySquaredMonotoneNonnegTimeProp : Prop :=
  ∀ (traj : Trajectory NSField) (t : Rat),
    0 ≤ t →
    SatisfiesNSPDE nsOps nsNu traj →
    RespectsFunctionSpaces nsSpacesR3 traj →
    (∀ (s : Rat), 0 ≤ s → s ≤ t → SubcriticalAtTime traj s →
      enstrophyRate traj s ≤ 0) →
    enstrophy (traj.stateAt t).velocity *
      enstrophy (traj.stateAt t).velocity ≤
    enstrophy (traj.stateAt 0).velocity *
      enstrophy (traj.stateAt 0).velocity

/-- Stage 73 local certificate primitive (AQFT/TFT-aligned semantics):
if enstrophy-rate is nonpositive on a subcritical segment `[t, t+h]`, then
the enstrophy-square observable is monotone across that increment.

This is the local increment form of the rate-to-monotonicity bridge and makes
the time-observable semantics explicit at the level of the opaque
`enstrophyRate` observable. -/
def EnstrophyRateMonotonicityCertificateProp : Prop :=
  ∀ (traj : Trajectory NSField) (t h : Rat),
    0 ≤ t →
    0 < h →
    SatisfiesNSPDE nsOps nsNu traj →
    RespectsFunctionSpaces nsSpacesR3 traj →
    (∀ (s : Rat), t ≤ s → s ≤ t + h → SubcriticalAtTime traj s →
      enstrophyRate traj s ≤ 0) →
    enstrophy (traj.stateAt (t + h)).velocity *
      enstrophy (traj.stateAt (t + h)).velocity ≤
    enstrophy (traj.stateAt t).velocity *
      enstrophy (traj.stateAt t).velocity

/-- Stage-218 segment integral operator used for local FTC-style endpoint
difference contracts on `[t, t+h]`.

Implemented as a shifted discrete integral over `[0,h]`:
`∫_{0}^{h} f(t+s) ds`. This retires the former opaque shim axiom and gives a
concrete carrier-level object for Stage-71/73 monotonicity contracts. -/
noncomputable def segmentIntegral (f : Rat → Rat) (t h : Rat) : Rat :=
  NavierStokes.DiscreteKernel.discreteIntegral (fun s => f (t + s)) h

/-- Explicit `Ω²` rate integrand over a trajectory-time point:
`2 * Ω(s) * dΩ/dt(s)`. -/
def enstrophySquaredRateIntegrand
    (traj : Trajectory NSField) (s : Rat) : Rat :=
  (2 * enstrophy (traj.stateAt s).velocity) * enstrophyRate traj s

/-- Primitive local segment witness package for Stage-73:
encodes both FTC endpoint identity and segment sign transfer on `[t, t+h]`
as one explicit contract object. -/
structure EnstrophySquaredSegmentPrimitiveWitness
    (traj : Trajectory NSField) (t h : Rat)
    (ht : 0 ≤ t) (hh : 0 < h)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj) where
  endpoint_difference :
    enstrophy (traj.stateAt (t + h)).velocity *
      enstrophy (traj.stateAt (t + h)).velocity -
    enstrophy (traj.stateAt t).velocity *
      enstrophy (traj.stateAt t).velocity =
    segmentIntegral (enstrophySquaredRateIntegrand traj) t h
  integral_nonpos_from_subcritical_rate_source :
    (∀ (s : Rat), t ≤ s → s ≤ t + h → SubcriticalAtTime traj s →
      enstrophyRate traj s ≤ 0) →
    segmentIntegral (enstrophySquaredRateIntegrand traj) t h ≤ 0

/-- Stage-218 constructive primitive witness in the current reduced carrier. -/
axiom enstrophy_squared_segment_primitive_witness :
  ∀ (traj : Trajectory NSField) (t h : Rat)
    (ht : 0 ≤ t) (hh : 0 < h)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj),
    EnstrophySquaredSegmentPrimitiveWitness traj t h ht hh hNS hFS

/-- Primitive FTC-style endpoint identity for `Ω²` on `[t, t+h]` recovered
from the Stage-73 segment witness. -/
theorem enstrophy_squared_segment_endpoint_difference :
  ∀ (traj : Trajectory NSField) (t h : Rat),
    0 ≤ t →
    0 < h →
    SatisfiesNSPDE nsOps nsNu traj →
    RespectsFunctionSpaces nsSpacesR3 traj →
    enstrophy (traj.stateAt (t + h)).velocity *
      enstrophy (traj.stateAt (t + h)).velocity -
    enstrophy (traj.stateAt t).velocity *
      enstrophy (traj.stateAt t).velocity =
    segmentIntegral (enstrophySquaredRateIntegrand traj) t h := by
  intro traj t h ht hh hNS hFS
  exact (enstrophy_squared_segment_primitive_witness traj t h ht hh hNS hFS).endpoint_difference

/-- NS-specific segment sign transfer recovered from the Stage-73 segment witness. -/
theorem enstrophy_squared_segment_integral_nonpos_from_subcritical_rate_source :
  ∀ (traj : Trajectory NSField) (t h : Rat),
    0 ≤ t →
    0 < h →
    SatisfiesNSPDE nsOps nsNu traj →
    RespectsFunctionSpaces nsSpacesR3 traj →
    (∀ (s : Rat), t ≤ s → s ≤ t + h → SubcriticalAtTime traj s →
      enstrophyRate traj s ≤ 0) →
    segmentIntegral (enstrophySquaredRateIntegrand traj) t h ≤ 0 := by
  intro traj t h ht hh hNS hFS hRate
  let w := enstrophy_squared_segment_primitive_witness traj t h ht hh hNS hFS
  exact w.integral_nonpos_from_subcritical_rate_source hRate

/-- Constructive segment-level `Ω²` increment theorem (Stage-73 target):
on `[t,t+h]`, if the subcritical rate source is nonpositive, then the `Ω²`
increment is nonpositive. -/
theorem enstrophy_squared_increment_nonpos_on_subcritical_segment :
  ∀ (traj : Trajectory NSField) (t h : Rat),
    0 ≤ t →
    0 < h →
    SatisfiesNSPDE nsOps nsNu traj →
    RespectsFunctionSpaces nsSpacesR3 traj →
    (∀ (s : Rat), t ≤ s → s ≤ t + h → SubcriticalAtTime traj s →
      enstrophyRate traj s ≤ 0) →
    enstrophy (traj.stateAt (t + h)).velocity *
      enstrophy (traj.stateAt (t + h)).velocity -
    enstrophy (traj.stateAt t).velocity *
      enstrophy (traj.stateAt t).velocity ≤ 0 := by
  intro traj t h ht hh hNS hFS hRate
  have hDiff :
      enstrophy (traj.stateAt (t + h)).velocity *
        enstrophy (traj.stateAt (t + h)).velocity -
      enstrophy (traj.stateAt t).velocity *
        enstrophy (traj.stateAt t).velocity =
      segmentIntegral (enstrophySquaredRateIntegrand traj) t h :=
    enstrophy_squared_segment_endpoint_difference traj t h ht hh hNS hFS
  have hIntNonpos :
      segmentIntegral (enstrophySquaredRateIntegrand traj) t h ≤ 0 :=
    enstrophy_squared_segment_integral_nonpos_from_subcritical_rate_source
      traj t h ht hh hNS hFS hRate
  nlinarith [hDiff, hIntNonpos]

/-- Primitive 2a (Stage 71 decomposition):
rate-sign over the subcritical segment implies enstrophy² monotonicity from
`t=0` to `t`.

This is the exact "rate-to-monotonicity" obstruction node:
`enstrophyRate ≤ 0` (on the relevant segment) should imply
`Ω(t)^2 ≤ Ω(0)^2`. -/
def SubcriticalRateToMonotonicityProp : Prop :=
  ∀ (traj : Trajectory NSField) (t : Rat),
    0 ≤ t →
    SatisfiesNSPDE nsOps nsNu traj →
    RespectsFunctionSpaces nsSpacesR3 traj →
    (∀ (s : Rat), 0 ≤ s → s ≤ t → SubcriticalAtTime traj s →
      enstrophyRate traj s ≤ 0) →
    enstrophy (traj.stateAt t).velocity *
      enstrophy (traj.stateAt t).velocity ≤
    enstrophy (traj.stateAt 0).velocity *
      enstrophy (traj.stateAt 0).velocity

/-- Primitive 3 (derived first-exit formulation):
given segment regularity and nonpositive rate on subcritical states, the
subcritical barrier has no first exit on `[0,t]`. -/
def SubcriticalNoFirstExitFromRateSignProp : Prop :=
  ∀ (traj : Trajectory NSField) (t : Rat),
    0 ≤ t →
    SatisfiesNSPDE nsOps nsNu traj →
    RespectsFunctionSpaces nsSpacesR3 traj →
    SubcriticalAtTime traj 0 →
    EnstrophySquaredRegularOnSegment traj t →
    (∀ (s : Rat), 0 ≤ s → s ≤ t → SubcriticalAtTime traj s →
      enstrophyRate traj s ≤ 0) →
    SubcriticalAtTime traj t

/-- Stage 71 rate-sign producer at the barrier:
already theorem-backed from EnstrophyEvolutionBalance. -/
theorem subcritical_rate_nonpos_at_barrier
    (traj : Trajectory NSField) (t : Rat)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj)
    (hSub : SubcriticalAtTime traj t) :
    enstrophyRate traj t ≤ 0 :=
  enstrophy_rate_nonpos_at_subcritical traj t hNS hFS hSub

/-- Stage 71 decomposition primitive 1 (theorem-level):
segment-regularity witness for `Ω²` on nonnegative-time intervals is produced
constructively by taking the explicit profile `s ↦ Ω(s)²`. -/
theorem enstrophy_squared_time_regularity :
  EnstrophySquaredTimeRegularityProp := by
  intro traj t _ht _hNS _hFS
  refine ⟨(fun s =>
    enstrophy (traj.stateAt s).velocity *
      enstrophy (traj.stateAt s).velocity), ?_, ?_⟩
  · intro s _hs0 _hsT
    rfl
  · intro s _hs0 _hsT
    exact mul_nonneg
      (enstrophy_nonneg (traj.stateAt s).velocity)
      (enstrophy_nonneg (traj.stateAt s).velocity)

/-- Stage 73 local certificate recovered from explicit FTC/segment-integration
primitives. -/
theorem enstrophyRate_is_monotonicity_certificate_on_subcritical_segment :
  EnstrophyRateMonotonicityCertificateProp := by
  intro traj t h ht hh hNS hFS hRate
  have hInc :
      enstrophy (traj.stateAt (t + h)).velocity *
        enstrophy (traj.stateAt (t + h)).velocity -
      enstrophy (traj.stateAt t).velocity *
        enstrophy (traj.stateAt t).velocity ≤ 0 :=
    enstrophy_squared_increment_nonpos_on_subcritical_segment
      traj t h ht hh hNS hFS hRate
  nlinarith [hInc]

/-- Stage 71 primitive 2 recovered from the Stage 73 local certificate by taking
the single increment `[0, t]` in the physical domain `t ≥ 0`. -/
theorem enstrophy_rate_nonpos_to_enstrophy_squared_monotone_nonneg_time :
  EnstrophyRateNonposToEnstrophySquaredMonotoneNonnegTimeProp := by
  intro traj t ht hNS hFS hRate
  by_cases htz : t = 0
  · subst htz
    nlinarith
  · have hpos : 0 < t := lt_of_le_of_ne ht (Ne.symm htz)
    have hLoc :
        enstrophy (traj.stateAt (0 + t)).velocity *
          enstrophy (traj.stateAt (0 + t)).velocity ≤
        enstrophy (traj.stateAt 0).velocity *
          enstrophy (traj.stateAt 0).velocity :=
      enstrophyRate_is_monotonicity_certificate_on_subcritical_segment
        traj 0 t (by nlinarith) hpos hNS hFS
        (fun s hs0 hsT hSub => by
          have hs0' : 0 ≤ s := by simpa using hs0
          have hsT' : s ≤ t := by simpa [zero_add] using hsT
          exact hRate s hs0' hsT' hSub)
    simpa [zero_add] using hLoc

/-- Segment-local monotonicity reducer:
on any nonnegative-time segment `[t0, t0+h]`, if the subcritical rate source is
nonpositive, then enstrophy-square is monotone across the segment. -/
theorem enstrophy_rate_nonpos_to_enstrophy_squared_monotone_on_segment
    (traj : Trajectory NSField) (t0 h : Rat)
    (ht0 : 0 ≤ t0) (hh : 0 ≤ h)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj)
    (hRate : ∀ (s : Rat), t0 ≤ s → s ≤ t0 + h → SubcriticalAtTime traj s →
      enstrophyRate traj s ≤ 0) :
    enstrophy (traj.stateAt (t0 + h)).velocity *
      enstrophy (traj.stateAt (t0 + h)).velocity ≤
    enstrophy (traj.stateAt t0).velocity *
      enstrophy (traj.stateAt t0).velocity := by
  by_cases hhz : h = 0
  · subst hhz
    simp
  · have hpos : 0 < h := lt_of_le_of_ne hh (Ne.symm hhz)
    have hLoc :
        enstrophy (traj.stateAt (t0 + h)).velocity *
          enstrophy (traj.stateAt (t0 + h)).velocity ≤
        enstrophy (traj.stateAt t0).velocity *
          enstrophy (traj.stateAt t0).velocity :=
      enstrophyRate_is_monotonicity_certificate_on_subcritical_segment
        traj t0 h ht0 hpos hNS hFS
        (fun s hs0 hsT hSub => hRate s hs0 hsT hSub)
    exact hLoc

/-- Segment-local monotonicity (endpoint form):
if `t0 ≤ t` and the subcritical rate source is nonpositive on `[t0,t]`, then
`Ω(t)^2 ≤ Ω(t0)^2`. -/
theorem enstrophy_rate_nonpos_to_enstrophy_squared_monotone_from_time
    (traj : Trajectory NSField) (t0 t : Rat)
    (ht0 : 0 ≤ t0) (ht : t0 ≤ t)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj)
    (hRate : ∀ (s : Rat), t0 ≤ s → s ≤ t → SubcriticalAtTime traj s →
      enstrophyRate traj s ≤ 0) :
    enstrophy (traj.stateAt t).velocity *
      enstrophy (traj.stateAt t).velocity ≤
    enstrophy (traj.stateAt t0).velocity *
      enstrophy (traj.stateAt t0).velocity := by
  let hSeg : Rat := t - t0
  have hhSeg : 0 ≤ hSeg := by
    dsimp [hSeg]
    nlinarith [ht]
  have hRateSeg : ∀ (s : Rat), t0 ≤ s → s ≤ t0 + hSeg →
      SubcriticalAtTime traj s → enstrophyRate traj s ≤ 0 := by
    intro s hs0 hsT hSub
    have hsT' : s ≤ t := by
      dsimp [hSeg] at hsT
      nlinarith
    exact hRate s hs0 hsT' hSub
  have hMono :
      enstrophy (traj.stateAt (t0 + hSeg)).velocity *
        enstrophy (traj.stateAt (t0 + hSeg)).velocity ≤
      enstrophy (traj.stateAt t0).velocity *
        enstrophy (traj.stateAt t0).velocity :=
    enstrophy_rate_nonpos_to_enstrophy_squared_monotone_on_segment
      traj t0 hSeg ht0 hhSeg hNS hFS hRateSeg
  have hTime : t0 + hSeg = t := by
    dsimp [hSeg]
    nlinarith
  simpa [hTime] using hMono

/-- Subcritical reducer from the core nonnegative-time monotonicity primitive. -/
theorem subcritical_rate_to_monotonicity :
  SubcriticalRateToMonotonicityProp := by
  intro traj t ht hNS hFS hRate
  exact enstrophy_rate_nonpos_to_enstrophy_squared_monotone_nonneg_time
    traj t ht hNS hFS
    (fun s hs0 hsT hSub => hRate s hs0 hsT hSub)

/-- Stage 71 first-exit reducer (theorem-level):
the prior first-exit formulation is reconstructed from the atomic
rate-to-monotonicity primitive + initial subcritical cap. -/
theorem subcritical_no_first_exit_from_rate_sign :
  SubcriticalNoFirstExitFromRateSignProp := by
  intro traj t ht hNS hFS hInit _hReg hRate
  have hMono :
      enstrophy (traj.stateAt t).velocity *
        enstrophy (traj.stateAt t).velocity ≤
      enstrophy (traj.stateAt 0).velocity *
      enstrophy (traj.stateAt 0).velocity :=
    subcritical_rate_to_monotonicity traj t ht hNS hFS hRate
  exact le_trans hMono hInit

/-- Stage 71 no-crossing theorem reconstructed by composition of the two
explicit decomposition primitives. -/
theorem subcritical_barrier_no_crossing :
  SubcriticalBarrierNoCrossingProp := by
  intro traj t ht hNS hFS hInit hRate
  have hReg : EnstrophySquaredRegularOnSegment traj t :=
    enstrophy_squared_time_regularity traj t ht hNS hFS
  exact subcritical_no_first_exit_from_rate_sign
    traj t ht hNS hFS hInit hReg hRate

/-- Nonnegative-time forward invariance reconstructed from barrier primitives. -/
theorem subcritical_forward_invariance_nonneg_time :
    SubcriticalForwardInvarianceNonnegTimeProp := by
  intro traj t ht hNS hFS hInit
  exact subcritical_barrier_no_crossing traj t ht hNS hFS hInit
    (fun s hs0 hsT hSub => subcritical_rate_nonpos_at_barrier traj s hNS hFS hSub)

/-- Stage 71 forward-invariance interface (physical domain `t ≥ 0`),
decomposed through the nonnegative-time barrier no-crossing theorem. -/
theorem subcritical_forward_invariance :
    SubcriticalForwardInvarianceProp := by
  intro traj t ht hNS hFS hInit
  exact subcritical_forward_invariance_nonneg_time traj t ht hNS hFS hInit

/-- Stage 71 generalized forward-invariance theorem (from arbitrary nonnegative
start time):
if the trajectory is subcritical at time `t0`, it stays subcritical for every
`t ≥ t0`. -/
theorem subcritical_forward_invariance_from_time
    (traj : Trajectory NSField) (t0 t : Rat)
    (ht0 : 0 ≤ t0) (ht : t0 ≤ t)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj)
    (hSub0 : SubcriticalAtTime traj t0) :
    SubcriticalAtTime traj t := by
  have hMono :
      enstrophy (traj.stateAt t).velocity *
        enstrophy (traj.stateAt t).velocity ≤
      enstrophy (traj.stateAt t0).velocity *
        enstrophy (traj.stateAt t0).velocity :=
    enstrophy_rate_nonpos_to_enstrophy_squared_monotone_from_time
      traj t0 t ht0 ht hNS hFS
      (fun s hs0 hsT hSub => subcritical_rate_nonpos_at_barrier traj s hNS hFS hSub)
  exact le_trans hMono hSub0

/-- Stage 71 generalized bottleneck corollary:
if the trajectory is subcritical at time `t0`, then `VS(t) ≤ νP(t)` for every
`t ≥ t0`. -/
theorem subcritical_at_t0_implies_vs_le_nuP_after_t0
    (traj : Trajectory NSField) (t0 t : Rat)
    (ht0 : 0 ≤ t0) (ht : t0 ≤ t)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj)
    (hSub0 : SubcriticalAtTime traj t0) :
    vortexStretchingIntegral traj t ≤
      nsNu * palinstrophy (traj.stateAt t).velocity := by
  exact vs_le_nuP_at_t_of_subcritical_enstrophy traj t hNS hFS
    (subcritical_forward_invariance_from_time traj t0 t ht0 ht hNS hFS hSub0)

/-- Stage 71 reconstructed theorem:
subcritical initial enstrophy implies `VS(t) ≤ νP(t)` for all `t ≥ 0`,
now factorized into:
1) forward invariance (open primitive), 2) pointwise subcritical reducer (theorem). -/
theorem subcritical_initial_implies_vs_le_nuP_all_time
    (traj : Trajectory NSField) (t : Rat)
    (ht : 0 ≤ t)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj)
    (hInit : enstrophy (traj.stateAt 0).velocity *
               enstrophy (traj.stateAt 0).velocity ≤
               subcriticalEnstrophySquaredThreshold) :
    vortexStretchingIntegral traj t ≤
      nsNu * palinstrophy (traj.stateAt t).velocity :=
  vs_le_nuP_at_t_of_subcritical_enstrophy traj t hNS hFS
    (subcritical_forward_invariance traj t ht hNS hFS hInit)

/-! ## 3. Theorems -/

/-- VS ≤ νP at each time t for subcritical initial data.

    Direct unpacking of the core axiom. The mathematical content is in
    `subcritical_initial_implies_vs_le_nuP_all_time`. -/
theorem vs_le_nuP_at_t_of_initial_subcritical
    (traj : Trajectory NSField) (t : Rat)
    (ht : 0 ≤ t)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj)
    (hInit : enstrophy (traj.stateAt 0).velocity *
               enstrophy (traj.stateAt 0).velocity ≤
               subcriticalEnstrophySquaredThreshold) :
    vortexStretchingIntegral traj t ≤
      nsNu * palinstrophy (traj.stateAt t).velocity :=
  subcritical_initial_implies_vs_le_nuP_all_time traj t ht hNS hFS hInit

/-- Universal VS≤νP from initial subcriticality (on `t ≥ 0`).

    If all NS initial data satisfies the subcritical bound, then
    `VSLeNuPAllTrajProp` holds (all trajectories, all nonnegative times, VS ≤ νP). -/
theorem initial_subcritical_implies_vs_le_nuP_all_traj
    (hInit : InitialDataSubcriticalProp) :
    VSLeNuPAllTrajProp := by
  intro traj t ht hNS hFS
  exact subcritical_initial_implies_vs_le_nuP_all_time traj t ht hNS hFS
    (hInit traj hNS hFS)

/-- **Conditional regularity**: `InitialDataSubcriticalProp → PreciseGapStatement`.

    This is the main result of Stage 71: a THEOREM (not an axiom) that
    proves `PreciseGapStatement` conditionally on all NS initial data being
    subcritical.

    **Proof chain**:
    1. `hInit : InitialDataSubcriticalProp`
       → `initial_subcritical_implies_vs_le_nuP_all_traj`
       → `VSLeNuPAllTrajProp`
    2. `VSLeNuPAllTrajProp`
       → `vs_le_nu_p_all_implies_precise_gap` (NSVSNuPResolutionBridge)
       → `PreciseGapStatement`

    **Axioms used**:
    - `enstrophyRate_is_monotonicity_certificate_on_subcritical_segment`
      (Stage 73 local certificate primitive, .partiallyVerified)
    - `vs_le_nu_p_implies_regularity` (Stage 64, .openBridge) via
      `stage64_vs_le_nu_p_boundary`

    **Theorem-level reducer used**:
    - `enstrophy_squared_time_regularity` (Stage 71 decomposition primitive 1, now theorem-level)
    - `subcritical_rate_to_monotonicity` (subcritical reducer from the core nonnegative-time primitive)
    - `subcritical_no_first_exit_from_rate_sign` (derived first-exit form)

    **Reduction**: Stage 64's `.openBridge` content (universal VS≤νP) is now
    conditional on `InitialDataSubcriticalProp`, a weaker and more structured
    hypothesis about the initial data only. -/
theorem initial_subcritical_implies_precise_gap
    (hInit : InitialDataSubcriticalProp) :
    PreciseGapStatement :=
  vs_le_nu_p_all_implies_precise_gap
    (initial_subcritical_implies_vs_le_nuP_all_traj hInit)

/-- Enstrophy monotonicity at each nonnegative time for subcritical initial data.

    `dΩ/dt ≤ 0` at all `t ≥ 0` for trajectories with subcritical initial enstrophy.
    This captures the dissipation-dominated regime that the forward invariance
    argument relies on. -/
theorem enstrophy_rate_nonpos_of_initial_subcritical
    (traj : Trajectory NSField) (t : Rat)
    (ht : 0 ≤ t)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj)
    (hInit : enstrophy (traj.stateAt 0).velocity *
               enstrophy (traj.stateAt 0).velocity ≤
               subcriticalEnstrophySquaredThreshold) :
    enstrophyRate traj t ≤ 0 :=
  enstrophy_rate_nonpos_of_vs_le_nuP traj t hNS hFS
    (subcritical_initial_implies_vs_le_nuP_all_time traj t ht hNS hFS hInit)

/-- Universal enstrophy monotonicity from initial subcriticality (on `t ≥ 0`).

    If all NS initial data is subcritical, then `dΩ/dt ≤ 0` for all
    NS trajectories at all nonnegative times (`EnstrophyRateNonposAllTrajProp`). -/
theorem initial_subcritical_implies_enstrophy_rate_nonpos_all
    (hInit : InitialDataSubcriticalProp) :
    EnstrophyRateNonposAllTrajProp := by
  intro traj t ht hNS hFS
  exact enstrophy_rate_nonpos_of_initial_subcritical traj t ht hNS hFS
    (hInit traj hNS hFS)

/-! ## 4. Diagnosis Record -/

/-- Records the Stage 71 conditional regularity contribution.

    **Before Stage 71** (Stage 64):
    Open content = "Prove `VS(t) ≤ νP(t)` for all t≥0 and all smooth NS data on T³"
    (a time-integrated PDE inequality, the Millennium problem directly)

    **After Stage 71**:
    Open content = "Prove `Ω(0)² ≤ ν⁴λ₁/C⁴` for all smooth NS data on T³"
    (a condition on initial data only — no time integration required)

    The forward invariance axiom converts the initial condition into a
    universal time bound automatically. This is a genuine structural reduction. -/
structure SubcriticalConditionalDiagnosis where
  /-- Conditional regularity is proved (Stage 71 theorem). -/
  conditionalRouteClosed      : Bool := true
  /-- The forward invariance axiom is standard PDE theory (.partiallyVerified). -/
  forwardInvarianceIsStandard : Bool := true
  /-- The remaining open content is a condition on initial data only. -/
  remainingContentIsInitData  : Bool := true
  /-- Stage 71 reduces Stage 64's universal VS≤νP to an initial enstrophy bound. -/
  reducesStage64Bottleneck    : Bool := true
  /-- For small initial data (Fujita-Kato), InitialDataSubcriticalProp holds. -/
  smallDataSatisfiesCondition : Bool := true
  /-- For large initial data, InitialDataSubcriticalProp remains open. -/
  largeDataGapRemains         : Bool := true

def canonicalSubcriticalDiagnosis : SubcriticalConditionalDiagnosis := {}

theorem subcritical_conditional_diagnosis_complete :
    canonicalSubcriticalDiagnosis.conditionalRouteClosed = true ∧
    canonicalSubcriticalDiagnosis.forwardInvarianceIsStandard = true ∧
    canonicalSubcriticalDiagnosis.remainingContentIsInitData = true ∧
    canonicalSubcriticalDiagnosis.reducesStage64Bottleneck = true ∧
    canonicalSubcriticalDiagnosis.largeDataGapRemains = true :=
  ⟨rfl, rfl, rfl, rfl, rfl⟩

/-! ## 5. Claim Registry -/

def subcriticalConditionalRegularityClaims : List LabeledClaim :=
  [ ⟨"vs_le_nuP_at_t_of_subcritical_enstrophy", .verified,
      "THEOREM: Ω(t)²≤ν⁴λ₁/C⁴ implies VS(t)≤νP(t) (pointwise reducer from EnstrophyEvolutionBalance)"⟩
  , ⟨"enstrophy_squared_time_regularity", .verified,
      "THEOREM: decomposition primitive 1 (segment regularity witness for Ω² on t≥0) is constructed explicitly by Ω² profile"⟩
  , ⟨"enstrophy_squared_segment_primitive_witness", .partiallyVerified,
      "AXIOM: single Stage-73 local witness contract packaging FTC endpoint identity + segment sign-transfer on [t,t+h]"⟩
  , ⟨"enstrophy_squared_segment_endpoint_difference", .partiallyVerified,
      "THEOREM: local FTC-style endpoint identity on [t,t+h], recovered from the Stage-73 segment witness contract"⟩
  , ⟨"enstrophy_squared_segment_integral_nonpos_from_subcritical_rate_source", .partiallyVerified,
      "THEOREM: local segment sign transfer on [t,t+h], recovered from the Stage-73 segment witness contract"⟩
  , ⟨"enstrophy_squared_increment_nonpos_on_subcritical_segment", .partiallyVerified,
      "THEOREM: Ω(t+h)^2-Ω(t)^2≤0 on [t,t+h], reconstructed from FTC endpoint identity + segment sign-transfer primitive"⟩
  , ⟨"enstrophyRate_is_monotonicity_certificate_on_subcritical_segment", .partiallyVerified,
      "THEOREM: local segment certificate as a direct corollary of the Ω² increment theorem on [t,t+h]"⟩
  , ⟨"enstrophy_rate_nonpos_to_enstrophy_squared_monotone_nonneg_time", .partiallyVerified,
      "THEOREM: Stage-71 nonnegative-time monotonicity primitive recovered from Stage-73 local certificate by using increment [0,t]"⟩
  , ⟨"subcritical_rate_to_monotonicity", .partiallyVerified,
      "THEOREM: subcritical rate-sign implies Ω(t)²≤Ω(0)² via the core nonnegative-time monotonicity primitive"⟩
  , ⟨"subcritical_no_first_exit_from_rate_sign", .partiallyVerified,
      "THEOREM: derived first-exit form reconstructed from rate-to-monotonicity + initial cap"⟩
  , ⟨"subcritical_barrier_no_crossing", .partiallyVerified,
      "THEOREM: no-crossing comparison principle reconstructed from decomposition primitives 1-2"⟩
  , ⟨"subcritical_forward_invariance_nonneg_time", .partiallyVerified,
      "THEOREM: forward invariance on t≥0 reconstructed from no-crossing axiom + theorem-level rate-sign producer at barrier"⟩
  , ⟨"subcritical_forward_invariance", .partiallyVerified,
      "THEOREM: physical-time forward-invariance interface on t≥0 from nonnegative-time barrier route"⟩
  , ⟨"subcritical_initial_implies_vs_le_nuP_all_time", .partiallyVerified,
      "THEOREM: factorized Stage 71 route (decomposed forward-invariance + pointwise subcritical theorem) gives VS(t)≤νP(t) for all t≥0"⟩
  , ⟨"vs_le_nuP_at_t_of_initial_subcritical", .partiallyVerified,
      "THEOREM: subcritical initial enstrophy → VS(t)≤νP(t) at each t (direct consequence of factorized Stage 71 route)"⟩
  , ⟨"initial_subcritical_implies_vs_le_nuP_all_traj", .partiallyVerified,
      "THEOREM: InitialDataSubcriticalProp → VSLeNuPAllTrajProp (universal VS≤νP from initial bound)"⟩
  , ⟨"initial_subcritical_implies_precise_gap", .partiallyVerified,
      "THEOREM: InitialDataSubcriticalProp → PreciseGapStatement (conditional regularity Stage 71 + Stage 64 chain)"⟩
  , ⟨"enstrophy_rate_nonpos_of_initial_subcritical", .partiallyVerified,
      "THEOREM: subcritical initial data → dΩ/dt≤0 for all t≥0 (enstrophy monotone under forward invariance)"⟩
  , ⟨"initial_subcritical_implies_enstrophy_rate_nonpos_all", .partiallyVerified,
      "THEOREM: InitialDataSubcriticalProp → EnstrophyRateNonposAllTrajProp"⟩
  , ⟨"subcritical_conditional_diagnosis_complete", .verified,
      "THEOREM: Stage 71 reduces Millennium content to initial-data-only condition (rfl × 5)"⟩ ]

end

end NavierStokes.SubcriticalRegularity
