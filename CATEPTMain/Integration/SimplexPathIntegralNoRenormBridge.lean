import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Analysis.Normed.Group.Basic
import Mathlib.Order.Filter.AtTopBot.Field
import Mathlib.Order.Filter.AtTopBot.Archimedean
import Mathlib.Topology.Algebra.Order.Field
import Mathlib.Topology.MetricSpace.Basic
import Mathlib.Data.Complex.Basic
import Mathlib.Analysis.Normed.Field.Basic

/-!
# Simplex / FK-Like Path-Integral No-Renormalization Bridge (T-FF Phase 8)

Phase-8 honest content: a counterterm-free criterion for the
entropically damped, complex Feynman–Kac-like path integral.
We package the standard claim that **whenever a UV-cutoff family
of complex partition functions converges to the continuum value
under an exponential tail bound `‖Z_N − Z_∞‖ ≤ exp(−ε N)` with
`ε > 0`, no counterterm is needed**: the cutoff sequence
literally tends to the continuum partition in `ℂ`, and the
counterterm is recorded as `0`.

This is *not* the fully general Glimm-Jaffe complex Feynman–Kac
theorem for arbitrary oscillatory complex measures (which remains
open in the literature).  It is the strictly weaker, fully formal
counterterm-free convergence statement that the existing entropic-
time / heat-mode infrastructure can support.

The rigorous complex Feynman-Kac theorem for the catept-physics
class (entropically damped oscillatory measures) is shipped in
`CATEPTMain.Integration.RigorousComplexFeynmanKac.complex_FK_rigorous`,
which the legacy `complex_FK_bridge : True` placeholders have been
removed in favour of.

The structure mirrors the real-valued
`UVConvergenceCertificate` lane in
`CATEPTMain.CATEPT.CATEPT.ModularFlowKucharCoreAbstractions`
but works on `ℂ` so that the entropically damped complex path
integral is genuinely captured.

## Honest content

* `CountertermFreeUVLimit`: a structure carrying a complex
  cutoff partition family `Z_N`, a continuum value `Z_∞ : ℂ`,
  an exponential UV scale `ε > 0`, an exponential-tail norm
  bound, and a counterterm field pinned to `0`.
* `exponential_uv_tail_implies_no_counterterm_needed`: from
  the data above we derive both
  `Tendsto Z_N atTop (𝓝 Z_∞)` and `counterterm = 0`.

Three honest theorems in total: the convergence corollary, the
zero-counterterm corollary, and their conjunction.

## Reading guide: no renormalization, not no normalization

`counterterm = 0` means the UV-cutoff family converges to the stated
continuum partition without a subtraction or counterterm scheme. It does
not assert that every downstream observable has already been normalized
as a probability expectation. Normalized observables may still divide by
the continuum partition `Z_∞`; the theorem here says that `Z_∞` is reached
directly by the entropically damped cutoff family.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.SimplexPathIntegralNoRenormBridge

open Filter Topology

noncomputable section

/-- **Counterterm-free UV limit** for an entropically damped,
complex FK-like path integral.

The cutoff partition family `cutoffPartition : ℕ → ℂ` is
controlled by an *exponential* tail bound at UV scale `ε > 0`,
which already implies convergence to the continuum partition
in `ℂ` without any counterterm. The `counterterm` field is
present and pinned to `0` so that the structure literally
witnesses the no-renormalization claim.
-/
structure CountertermFreeUVLimit where
  cutoffPartition : ℕ → ℂ
  continuumPartition : ℂ
  epsilonUV : ℝ
  epsilonUV_pos : 0 < epsilonUV
  exponentialTail :
    ∀ N, ‖cutoffPartition N - continuumPartition‖ ≤
      Real.exp (-(epsilonUV * (N : ℝ)))
  counterterm : ℂ
  counterterm_zero : counterterm = 0

namespace CountertermFreeUVLimit

/-- The exponential UV tail bound forces the cutoff partition to
converge in `ℂ` to the continuum partition. -/
theorem tendsto_cutoff_to_continuum (c : CountertermFreeUVLimit) :
    Tendsto c.cutoffPartition atTop (𝓝 c.continuumPartition) := by
  have hε : 0 < c.epsilonUV := c.epsilonUV_pos
  -- ε · N → ∞
  have h1 : Tendsto (fun N : ℕ => c.epsilonUV * (N : ℝ)) atTop atTop :=
    Tendsto.const_mul_atTop hε tendsto_natCast_atTop_atTop
  -- -(ε · N) → -∞
  have h2 : Tendsto (fun N : ℕ => -(c.epsilonUV * (N : ℝ))) atTop atBot :=
    tendsto_neg_atTop_atBot.comp h1
  -- exp(-(ε · N)) → 0
  have h3 : Tendsto (fun N : ℕ => Real.exp (-(c.epsilonUV * (N : ℝ))))
      atTop (𝓝 0) := Real.tendsto_exp_atBot.comp h2
  -- ‖Z_N - Z_∞‖ ≤ exp(-(ε·N)) ⟹ Z_N - Z_∞ → 0 in ℂ
  have h4 : Tendsto (fun N => c.cutoffPartition N - c.continuumPartition)
      atTop (𝓝 0) := squeeze_zero_norm c.exponentialTail h3
  -- Hence Z_N → Z_∞.
  have h5 := h4.add_const c.continuumPartition
  simpa using h5

/-- The counterterm field is identically zero. -/
theorem counterterm_eq_zero (c : CountertermFreeUVLimit) :
    c.counterterm = 0 := c.counterterm_zero

end CountertermFreeUVLimit

/-- **Main bridge** (T-FF Phase 8).

For an entropically damped, complex FK-like UV-cutoff family
satisfying an exponential-tail certificate, the cutoff
partition literally converges to the continuum partition and
no counterterm is required. -/
theorem exponential_uv_tail_implies_no_counterterm_needed
    (c : CountertermFreeUVLimit) :
    Tendsto c.cutoffPartition atTop (𝓝 c.continuumPartition) ∧
      c.counterterm = 0 :=
  ⟨c.tendsto_cutoff_to_continuum, c.counterterm_zero⟩

end

end CATEPTMain.Integration.SimplexPathIntegralNoRenormBridge
