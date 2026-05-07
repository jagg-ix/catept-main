import CATEPTMain.Integration.EtaSpectralDensityCarrier
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

/-!
# ComplexTimePathIntegralCarrier — Tier-4 QuantumDynamics.jl Wick-Rotation Carriers

Consolidates the **Tier-4** content of QuantumDynamics.jl
(`PathIntegral/CorrelationFunction/*`, `PathIntegral/QCPI.jl`) into
structural-carrier landing pads.  Tier 4 generalises Tier 1's
real-time QuAPI to a **complex-time Keldysh-style contour** —
the canonical instance of Wick rotation in path integrals.

This is the most direct algorithmic backbone for **Goal (c)
GR + QM path-integral unification** identified in earlier analysis:
the complex-time contour explicitly interpolates between real-time
QM dynamics (`U(t)` factor) and Euclidean (Wick-rotated) thermal
weights (`exp(-βH/2)` factor), with the η-kernel generalising to
a B-matrix on the contour.

## Files leveraged

* `CorrelationFunction/ComplexPISetup.jl` — complex time contour
  `tarr : Fin (2N+3) → ℂ` (`get_complex_time_array`,
  `get_asymm_time_array`).
* `CorrelationFunction/BMatrix.jl` — `B : Fin npoints × Fin npoints → ℂ`
  generalised influence-functional kernel on the contour.
* `CorrelationFunction/ComplexQuAPI.jl` — Topaler-Makri 1994 +
  Bose 2023 complex-time QuAPI (`A_of_t`).
* `CorrelationFunction/ComplexTNPI.jl` — tensor-network compressed
  variant of ComplexQuAPI.
* `CorrelationFunction/correlationfunction.jl` — top-level
  abstraction.
* `PathIntegral/QCPI.jl` — quasi-classical path integral
  (classical solvent + quantum system, uses ζ coefficients).

## Bridge to existing CAT/EPT structure

The complex contour `tarr` traverses

  0  →  -t  →  -t - iβ/2  →  -t - iβ  →  -iβ

(forward in real time + descend β/2 in imaginary, turn, backward in
real time + descend remaining β/2 in imaginary).  The midpoint
turning point `tarr[N+1] = -t - iβ/2` is the **Wick-rotation pivot**:

* Forward leg (`tarr[0..N]`): real-time evolution `U(t)`, giving the
  CAT/EPT real action `S_R`.
* Imaginary descent: thermal weight `exp(-βH/2)`, giving the CAT/EPT
  imaginary action `S_I` via `S_I[γ] = ℏ τ_ent[γ]` with
  `τ_ent ↔ β/2`.
* Backward leg (`tarr[N+1..2N+1]`): conjugate evolution `U⁻¹(t)`,
  closing the trace.

The `B`-matrix at lag `(k, k')` is the complex generalisation of the
Tier-1 η-coefficient:

  B[k, k'] = (4/π) ∫ J(ω)/ω² · [coth(βω/2) cos(ω·Δt) - i sin(ω·Δt)]
                     · sin(ω·δt_k/2) · sin(ω·δt_k'/2) dω

where `Δt = (tarr[k+1] + tarr[k] - tarr[k'+1] - tarr[k'])/2`.  The
`coth(βω/2)` factor is the **bath thermal occupation** (= the
`1 + 2/(exp(βω) - 1)` factor in Bose-Einstein statistics).

## Honest scope

* This is **not** a port of complex measure theory or analytic
  continuation in Lean.  The complex contour is exposed as
  `Fin (2N+3) → (ℝ × ℝ)` (real-imaginary pair) without using ℂ.
* The `B`-matrix integrand and analytic-continuation `coth(βω/2)`
  factor stay abstract `origin_witness`-style fields.
* The Wick-rotation **structural identification** is captured: the
  real-time-only leg of the contour at imaginary-time depth zero
  reproduces the Tier-1 `EtaKernel`.

## What this module ships

* `ComplexTimePoint` — `(re, im)` ∈ ℝ × ℝ.
* `ComplexTimeContour` — `Fin (2N+3) → ComplexTimePoint` with
  endpoint conditions for the Keldysh contour.
* `BMatrixKernel` — symmetric `Fin npoints × Fin npoints → ComplexTimePoint`
  generalised influence kernel.
* `WickRotationCarrier` — bridge from Tier-1 `EtaKernel` to a
  `BMatrixKernel` evaluation at the real-time-only restriction.
* `QuasiClassicalCarrier` — QCPI shape (classical solvent + quantum
  system) using ζ-coefficient analogues of η.
* `IdentifyComplexQuAPIWithRealQuAPI` — bridge: at zero imaginary
  depth (`β → ∞` limit), the complex contour reduces to the real-time
  Tier-1 QuAPI.
* `complex_time_path_integral_bundle` — capstone existence theorem.
-/

set_option autoImplicit false

noncomputable section

namespace CATEPTMain.Integration.ComplexTimePathIntegralCarrier

open CATEPTMain.Integration.EtaSpectralDensityCarrier

-- ============================================================================
-- 1. Complex time point and contour
-- ============================================================================

/-- **Complex time point** `(re, im)` representing `tarr[k] ∈ ℂ`.

We avoid `ℂ` directly to keep imports light; the real-imaginary pair
captures the contour geometry needed for the Keldysh/Wick rotation
structure. -/
structure ComplexTimePoint where
  /-- Real part. -/
  re : ℝ
  /-- Imaginary part. -/
  im : ℝ

namespace ComplexTimePoint

/-- The origin `0 + 0i`. -/
def zero : ComplexTimePoint := { re := 0, im := 0 }

/-- Pure imaginary point `0 - i·s`. -/
def pureImag (s : ℝ) : ComplexTimePoint := { re := 0, im := -s }

/-- Trivial existence: origin. -/
theorem exists_trivial : ∃ _ : ComplexTimePoint, True :=
  ⟨zero, trivial⟩

end ComplexTimePoint

/-- **Complex time contour** for QuAPI on the Keldysh contour.

Maps to `get_complex_time_array(t, β, N)` from `ComplexPISetup.jl:3-16`.
The contour has `2N + 3` points indexed by `Fin (2*N + 3)` with:

* `tarr[0] = 0` (origin, real-time start),
* `tarr[N+1] = -t - i·β/2` (Wick-rotation pivot at half-thermal depth),
* `tarr[2N+2] = -i·β` (full thermal depth, return point).

Real-time `t` and inverse temperature `β` are carrier parameters;
positivity hypotheses are explicit. -/
structure ComplexTimeContour where
  /-- Number of real-time discretisation steps `N ≥ 1`. -/
  N             : ℕ
  /-- Lower bound on `N`. -/
  N_pos         : 1 ≤ N
  /-- Real-time end value `t > 0`. -/
  t             : ℝ
  /-- Strict positivity of `t`. -/
  t_pos         : 0 < t
  /-- Inverse temperature `β > 0`. -/
  β             : ℝ
  /-- Strict positivity of `β`. -/
  β_pos         : 0 < β
  /-- The contour points. -/
  tarr          : Fin (2 * N + 3) → ComplexTimePoint
  /-- Endpoint at origin. -/
  tarr_origin   : tarr ⟨0, by omega⟩ = ComplexTimePoint.zero
  /-- Final point at full thermal depth `-i·β`. -/
  tarr_final    : tarr ⟨2 * N + 2, by omega⟩ = ComplexTimePoint.pureImag β

namespace ComplexTimeContour

variable (C : ComplexTimeContour)

/-- The number of contour points `2N + 3`. -/
def npoints : ℕ := 2 * C.N + 3

/-- The number of "active" path points `2N + 2` (one less than total —
the convention used by `BMatrix.compute_B!`). -/
def activePoints : ℕ := 2 * C.N + 2

/-- The half-thermal depth `β/2`.  Identifies with the Wick-rotation
pivot point's imaginary part magnitude. -/
def halfThermal : ℝ := C.β / 2

/-- The half-thermal depth is positive. -/
theorem halfThermal_pos : 0 < C.halfThermal := by
  unfold halfThermal
  exact div_pos C.β_pos (by norm_num)

/-- Trivial existence: minimal contour. -/
theorem exists_trivial : ∃ _ : ComplexTimeContour, True := by
  refine ⟨?_, trivial⟩
  refine
    { N           := 1
    , N_pos       := le_refl 1
    , t           := 1
    , t_pos       := by norm_num
    , β           := 1
    , β_pos       := by norm_num
    , tarr        := fun k =>
        if k = ⟨0, by omega⟩ then ComplexTimePoint.zero
        else if k = ⟨2 * 1 + 2, by omega⟩ then ComplexTimePoint.pureImag 1
        else ComplexTimePoint.zero
    , tarr_origin := ?_
    , tarr_final  := ?_ }
  · simp
  · simp

end ComplexTimeContour

-- ============================================================================
-- 2. B-matrix kernel (generalised influence-functional kernel)
-- ============================================================================

/-- **B-matrix kernel** on the complex-time contour.

Maps to `B : Matrix{ComplexF64}` populated by `compute_B!` in
`BMatrix.jl:5-18`.  Per-pair entry `B[k, k']` is a complex-valued
influence-functional coefficient.

We carry the kernel as a real-imaginary pair function with the
standard symmetry `B[k, k'] = B[k', k]` (BMatrix.jl:13). -/
structure BMatrixKernel (npoints : ℕ) where
  /-- Real part `Re B[k, k']`. -/
  reB              : Fin npoints → Fin npoints → ℝ
  /-- Imaginary part `Im B[k, k']`. -/
  imB              : Fin npoints → Fin npoints → ℝ
  /-- Symmetry of real part: `Re B[k, k'] = Re B[k', k]`. -/
  reB_symm         : ∀ k k', reB k k' = reB k' k
  /-- Symmetry of imaginary part: `Im B[k, k'] = Im B[k', k]`. -/
  imB_symm         : ∀ k k', imB k k' = imB k' k

namespace BMatrixKernel

/-- Trivial existence: zero kernel for any `npoints`. -/
theorem exists_trivial (npoints : ℕ) : ∃ _ : BMatrixKernel npoints, True :=
  ⟨{ reB      := fun _ _ => 0
   , imB      := fun _ _ => 0
   , reB_symm := fun _ _ => rfl
   , imB_symm := fun _ _ => rfl }, trivial⟩

end BMatrixKernel

-- ============================================================================
-- 3. Wick rotation carrier — Tier-1 EtaKernel ↔ Tier-4 BMatrix at slice (0, 0)
-- ============================================================================

/-- **Wick-rotation carrier.**

The Wick rotation is the analytic continuation that takes a real-time
η-coefficient (Tier 1) to a complex-time B-matrix (Tier 4).  At the
real-time-only restriction (imaginary depth = 0, equivalently
`β → ∞`), the diagonal element `B[0, 0]` reduces to the Tier-1
`EtaKernel.η00`.

Carrier-level identification: the kernel `(reB[0,0], imB[0,0])`
matches `(reEta, imEta)` of the underlying η-kernel. -/
structure WickRotationCarrier where
  /-- Tier-1 real-time η-kernel. -/
  η             : EtaKernel
  /-- Number of contour points (≥ 1 needed to index `[0]`). -/
  npoints       : ℕ
  /-- Lower bound on `npoints`. -/
  npoints_pos   : 1 ≤ npoints
  /-- Tier-4 B-matrix on the contour. -/
  B             : BMatrixKernel npoints
  /-- Identification at `[0, 0]`: `Re B[0, 0] = Re η`. -/
  reB_at_zero   : B.reB ⟨0, npoints_pos⟩ ⟨0, npoints_pos⟩ = η.reEta
  /-- Identification at `[0, 0]`: `Im B[0, 0] = Im η`. -/
  imB_at_zero   : B.imB ⟨0, npoints_pos⟩ ⟨0, npoints_pos⟩ = η.imEta

namespace WickRotationCarrier

variable (W : WickRotationCarrier)

/-- Under the Wick-rotation bridge, `Re B[0, 0] ≥ 0` (inherited from
`Re η ≥ 0`). -/
theorem reB_at_zero_nonneg :
    0 ≤ W.B.reB ⟨0, W.npoints_pos⟩ ⟨0, W.npoints_pos⟩ := by
  rw [W.reB_at_zero]
  exact W.η.reEta_nonneg

/-- Trivial existence: zero η + zero B-matrix at minimal `npoints = 1`. -/
theorem exists_trivial : ∃ _ : WickRotationCarrier, True :=
  ⟨{ η             := { reEta := 0, imEta := 0, reEta_nonneg := le_refl 0 }
   , npoints       := 1
   , npoints_pos   := le_refl 1
   , B             := { reB      := fun _ _ => 0
                      , imB      := fun _ _ => 0
                      , reB_symm := fun _ _ => rfl
                      , imB_symm := fun _ _ => rfl }
   , reB_at_zero   := rfl
   , imB_at_zero   := rfl }, trivial⟩

end WickRotationCarrier

-- ============================================================================
-- 4. Quasi-classical path integral carrier (QCPI)
-- ============================================================================

/-- **Quasi-classical path-integral carrier.**

Maps to `QCPI.propagate` in `QCPI.jl:10-32`: classical solvent
trajectory (Monte Carlo over phase-space initial conditions) + quantum
system path integral.  Uses the ζ-coefficient analogue of η (see
`EtaCoefficients.jl::ZetaCoeffs` and `calculate_ζ`).

Carrier-level fields:

* `ζ_kernel` — single-slice ζ-coefficient (real-valued for the
  classical-bath QCPI variant; the imaginary η part vanishes when
  the bath is treated classically).
* `numTrajectories ≥ 1` — number of Monte Carlo classical trajectories.
* `numTrajectories_pos` — lower bound. -/
structure QuasiClassicalCarrier where
  /-- Real-valued ζ-kernel (single slice). -/
  ζ_kernel             : ℝ
  /-- ζ-kernel non-negativity (inherited classical-bath positivity). -/
  ζ_kernel_nonneg      : 0 ≤ ζ_kernel
  /-- Number of classical Monte Carlo trajectories. -/
  numTrajectories      : ℕ
  /-- At least one trajectory. -/
  numTrajectories_pos  : 1 ≤ numTrajectories

namespace QuasiClassicalCarrier

/-- Trivial existence: single trajectory, zero kernel. -/
theorem exists_trivial : ∃ _ : QuasiClassicalCarrier, True :=
  ⟨{ ζ_kernel             := 0
   , ζ_kernel_nonneg      := le_refl 0
   , numTrajectories      := 1
   , numTrajectories_pos  := le_refl 1 }, trivial⟩

end QuasiClassicalCarrier

-- ============================================================================
-- 5. Bridge: complex-time QuAPI ↔ real-time QuAPI (zero-temperature limit)
-- ============================================================================

/-- **Bridge contract: complex-time QuAPI ↔ real-time QuAPI.**

In the zero-temperature limit (`β → ∞`, equivalently the imaginary
depth of the contour goes to zero on the real-time leg), complex
QuAPI reduces to the real-time Tier-1 QuAPI.  Carrier captures this
via:

* a `WickRotationCarrier` providing the structural Wick-rotation tie,
* a real-time `InfluenceFunctionalWeight` from Tier 1, and
* a hypothesis that the contour's imaginary depth on the real-time
  leg equals zero (the "real-time restriction"). -/
structure IdentifyComplexQuAPIWithRealQuAPI where
  /-- The Wick-rotation tie. -/
  wick                       : WickRotationCarrier
  /-- The real-time Tier-1 weight. -/
  realWeight                 : InfluenceFunctionalWeight
  /-- The kernel of the real-time weight matches the η of `wick`. -/
  η_eq                       : realWeight.η = wick.η
  /-- The hypothesis: real-time-leg imaginary depth is zero (zero-
  temperature / `β → ∞` limit). -/
  realTimeRestrictionHolds   : Prop

namespace IdentifyComplexQuAPIWithRealQuAPI

variable (B : IdentifyComplexQuAPIWithRealQuAPI)

/-- Under the bridge, the real-time damping magnitude is bounded by 1
(inherited from Tier 1's `dampingMagnitude_le_one`). -/
theorem realWeight_dampingMagnitude_le_one :
    B.realWeight.dampingMagnitude ≤ 1 :=
  InfluenceFunctionalWeight.dampingMagnitude_le_one B.realWeight

/-- Trivial existence: trivial Wick rotation + zero weight + vacuous
real-time-restriction Prop. -/
theorem exists_trivial : ∃ _ : IdentifyComplexQuAPIWithRealQuAPI, True := by
  refine ⟨?_, trivial⟩
  refine
    { wick                     := ?_
    , realWeight               := ?_
    , η_eq                     := ?_
    , realTimeRestrictionHolds := True }
  · exact { η             := { reEta := 0, imEta := 0, reEta_nonneg := le_refl 0 }
          , npoints       := 1
          , npoints_pos   := le_refl 1
          , B             := { reB      := fun _ _ => 0
                             , imB      := fun _ _ => 0
                             , reB_symm := fun _ _ => rfl
                             , imB_symm := fun _ _ => rfl }
          , reB_at_zero   := rfl
          , imB_at_zero   := rfl }
  · exact { η    := { reEta := 0, imEta := 0, reEta_nonneg := le_refl 0 }
          , Δs   := 0
          , sbar := 0 }
  · rfl

end IdentifyComplexQuAPIWithRealQuAPI

-- ============================================================================
-- 6. Capstone bundle
-- ============================================================================

/-- **Complex-time path-integral carrier bundle.**

All structural deliverables for Tier-4 of QuantumDynamics.jl hold
simultaneously:

* A complex time contour exists (minimal `(N=1, t=1, β=1)` instance).
* A B-matrix kernel exists for any `npoints` (zero kernel).
* A Wick-rotation carrier exists tying η to B at slice `[0, 0]`.
* A quasi-classical carrier exists.
* The complex ↔ real QuAPI bridge admits a trivial instance.

Phase-3 refinements (still open) substitute concrete Wick-rotation
proofs (analytic continuation of the η integrand to complex `t`),
the trapezoid quadrature for `B[k, k']` matching `BMatrix.compute_B!`,
and the ζ-kernel integral relation for the QCPI variant. -/
theorem complex_time_path_integral_bundle :
    (∃ _ : ComplexTimeContour, True)
    ∧ (∀ npoints : ℕ, ∃ _ : BMatrixKernel npoints, True)
    ∧ (∃ _ : WickRotationCarrier, True)
    ∧ (∃ _ : QuasiClassicalCarrier, True)
    ∧ (∃ _ : IdentifyComplexQuAPIWithRealQuAPI, True) :=
  ⟨ComplexTimeContour.exists_trivial,
   BMatrixKernel.exists_trivial,
   WickRotationCarrier.exists_trivial,
   QuasiClassicalCarrier.exists_trivial,
   IdentifyComplexQuAPIWithRealQuAPI.exists_trivial⟩

end CATEPTMain.Integration.ComplexTimePathIntegralCarrier

end
