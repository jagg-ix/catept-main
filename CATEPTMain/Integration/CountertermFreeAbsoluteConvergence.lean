import CATEPTMain.Integration.SimplexPathIntegralNoRenormBridge
import Mathlib.Analysis.SpecialFunctions.Exp

/-!
# Counterterm-Free Absolute Convergence (T-FF Phase 13)

Honest realization of the user's plan target

  `counterterm_free_because_absolute_convergence`

For a Phase-8 `CountertermFreeUVLimit`, the cutoff partitions
converge to the continuum partition **absolutely**: the series
of distances `∑_N ‖Z_N − Z_∞‖` is summable, dominated termwise
by the geometric series `∑_N exp(−ε · N)`. Combined with the
Phase-8 `counterterm_eq_zero`, this records that no
subtraction renormalization is needed — the ℂ-valued series
itself is absolutely convergent.

Honest content:

* `geometric_uv_tail_summable` — `∑_N exp(−ε · N)` is summable
  for `ε > 0`.
* `cutoffPartition_absolutely_convergent` — `∑_N ‖Z_N − Z_∞‖`
  is summable.
* `counterterm_free_because_absolute_convergence` — the
  Phase-8 conjunction `counterterm = 0 ∧ Summable ‖Z_N − Z_∞‖`,
  i.e. the limit is reached by absolute convergence rather
  than by counterterm subtraction.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.CountertermFreeAbsoluteConvergence

open CATEPTMain.Integration.SimplexPathIntegralNoRenormBridge

noncomputable section

/-- For any positive `ε`, the geometric series `∑_N exp(−ε·N)`
is summable. -/
theorem geometric_uv_tail_summable {ε : ℝ} (hε : 0 < ε) :
    Summable (fun N : ℕ => Real.exp (-(ε * (N : ℝ)))) := by
  have h := Real.summable_exp_nat_mul_iff (a := -ε) |>.mpr (neg_lt_zero.mpr hε)
  -- `h : Summable fun n : ℕ ↦ Real.exp (n * (-ε))`
  refine h.congr ?_
  intro N
  ring_nf

/-- **Absolute convergence** of the Phase-8 cutoff family:
the norm differences `‖Z_N − Z_∞‖` are summable, dominated by
the geometric tail `exp(−ε · N)`. -/
theorem cutoffPartition_absolutely_convergent
    (lim : CountertermFreeUVLimit) :
    Summable (fun N : ℕ =>
      ‖lim.cutoffPartition N - lim.continuumPartition‖) := by
  refine Summable.of_nonneg_of_le
    (fun _ => norm_nonneg _) lim.exponentialTail
    (geometric_uv_tail_summable lim.epsilonUV_pos)

/-- **Plan target #9** packaged: the counterterm is zero
*and* the sequence of cutoff-to-continuum distances is
absolutely summable, so convergence is dominated by the
entropic damping rather than achieved by subtraction. -/
theorem counterterm_free_because_absolute_convergence
    (lim : CountertermFreeUVLimit) :
    lim.counterterm = 0 ∧
      Summable (fun N : ℕ =>
        ‖lim.cutoffPartition N - lim.continuumPartition‖) :=
  ⟨lim.counterterm_zero, cutoffPartition_absolutely_convergent lim⟩

end

end CATEPTMain.Integration.CountertermFreeAbsoluteConvergence
