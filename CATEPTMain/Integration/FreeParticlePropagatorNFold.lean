/-
  T-AA / Tier-2 #4 Phase 1.5: Uniform n-fold Trotter splitting of the
  free-particle propagator phase.

  Companion to `FreeParticlePropagator` (T-Z): given an arbitrary
  positive integer `n`, partition the time interval `[0, T]` into
  `n` equal slices of width `δ = T/n`, and the spatial interval
  `[xa, xb]` into `n` equal segments via the uniform grid

      x_i  :=  xa + (i / n) · (xb − xa),    i = 0, …, n,

  with `x_0 = xa` and `x_n = xb`. Then on this uniform grid the
  WKB phase additively splits:

      ∑_{i=0}^{n−1}  Φ(x_i, x_{i+1}, T/n)   =   Φ(xa, xb, T).

  This is a strict consequence of the per-summand identity

      Φ(x_i, x_{i+1}, T/n)   =   Φ(xa, xb, T) / n,

  which holds because the displacement is `(xb − xa)/n` and the
  time slice is `T/n`, so the squared displacement contributes
  `1/n²` while the time slice contributes `n` in the denominator
  cancellation, leaving an overall `1/n`. Summing `n` copies of
  `Φ_total / n` recovers `Φ_total`.

  Algebraic content of the iterated Trotter slicing on a uniform
  grid: the closed-form intermediate points coincide with the
  successive saddles of the geometrically-pointwise classical
  trajectory of the free particle. Phase 2 (deferred) will lift
  this to non-uniform partitions via the recursive list-based
  saddle path and to the full complex propagator with the
  `√(m / (2π·iℏ·T))` Gaussian-convolution prefactor.
-/
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp
import CATEPTMain.Integration.FreeParticleAction
import CATEPTMain.Integration.FreeParticlePropagator

set_option autoImplicit false

namespace CATEPTMain.Integration.FreeParticlePropagatorNFold

open CATEPTMain.Integration.FreeParticleAction
open CATEPTMain.Integration.FreeParticlePropagator

noncomputable section

/-- Uniform `n`-point grid: `x_i = xa + (i/n)·(xb − xa)`. The
    closed-form `i`-th intermediate position of the iterated
    Trotter slicing of the free trajectory from `xa` to `xb`. -/
def uniformGridPoint (xa xb : ℝ) (n i : ℕ) : ℝ :=
  xa + (i : ℝ) / n * (xb - xa)

/-- Endpoint at `i = 0`: the grid starts at `xa`. -/
theorem uniformGridPoint_zero (xa xb : ℝ) (n : ℕ) :
    uniformGridPoint xa xb n 0 = xa := by
  unfold uniformGridPoint
  simp

/-- Endpoint at `i = n`: the grid ends at `xb` (for `n ≠ 0`). -/
theorem uniformGridPoint_self (xa xb : ℝ) (n : ℕ) (hn : (n : ℝ) ≠ 0) :
    uniformGridPoint xa xb n n = xb := by
  unfold uniformGridPoint
  field_simp
  ring

/-- Per-slice phase identity: each of the `n` uniform slices
    carries exactly `1/n`-th of the total WKB phase. -/
theorem freePropagatorPhase_uniformGrid_summand
    (m hbar xa xb T : ℝ) (hhbar : hbar ≠ 0) (hT : T ≠ 0)
    (n : ℕ) (hn : (n : ℝ) ≠ 0) (i : ℕ) :
    freePropagatorPhase m hbar
        (uniformGridPoint xa xb n i)
        (uniformGridPoint xa xb n (i + 1))
        (T / n)
      = freePropagatorPhase m hbar xa xb T / n := by
  unfold freePropagatorPhase uniformGridPoint
  push_cast
  field_simp
  ring

/-- Uniform `n`-fold Trotter splitting of the free-particle WKB phase:

      ∑_{i=0}^{n−1}  Φ(x_i, x_{i+1}, T/n)  =  Φ(xa, xb, T)

    on the uniform grid `x_i = xa + (i/n)·(xb − xa)`. -/
theorem freePropagatorPhase_uniform_n_fold_split
    (m hbar xa xb T : ℝ) (hhbar : hbar ≠ 0) (hT : T ≠ 0)
    (n : ℕ) (hn : (n : ℝ) ≠ 0) :
    ∑ i ∈ Finset.range n,
        freePropagatorPhase m hbar
          (uniformGridPoint xa xb n i)
          (uniformGridPoint xa xb n (i + 1))
          (T / n)
      = freePropagatorPhase m hbar xa xb T := by
  have hcong :
      ∀ i ∈ Finset.range n,
        freePropagatorPhase m hbar
            (uniformGridPoint xa xb n i)
            (uniformGridPoint xa xb n (i + 1))
            (T / n)
          = freePropagatorPhase m hbar xa xb T / n := by
    intro i _
    exact freePropagatorPhase_uniformGrid_summand m hbar xa xb T hhbar hT n hn i
  rw [Finset.sum_congr rfl hcong, Finset.sum_const, Finset.card_range,
      nsmul_eq_mul]
  field_simp

end

end CATEPTMain.Integration.FreeParticlePropagatorNFold
