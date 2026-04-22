import CATEPTMain.CATEPT.MeasurePathIntegral
import CATEPTMain.CATEPT.FeynmanKacBridge
import CATEPTMain.CATEPT.InfluenceFunctionalBridge

set_option autoImplicit false

/-!
# Example 3: Feynman-Kac Damping — ‖w(Φ)‖ ≤ 1

## What makes this unique to CAT/EPT

In standard QFT, the path integral weight exp(iS/ℏ) has unit norm —
every path contributes equally in magnitude. UV finiteness requires
separate renormalization machinery.

In CAT/EPT, the weight factorizes as:

  w(Φ) = exp(i S_R/ℏ) · exp(-S_I/ℏ)
         ↑ oscillatory    ↑ damping
         (unit norm)      (≤ 1)

Since S_I ≥ 0, the damping factor exp(-S_I/ℏ) ≤ 1 automatically.
Paths that produce more entropy get exponentially suppressed.

This is the Feynman-Kac correspondence: the imaginary action plays the
role of a potential in the FK formula, and the damping factor is the
FK weight. The path integral is automatically UV-finite when S_I grows
sufficiently fast (coercivity).

## Key results

1. ‖w(Φ)‖ = exp(-S_I/ℏ) ≤ 1 (global weight bound)
2. Weight factorizes into phase × damping
3. Phase has unit norm
4. Damping is in (0, 1]
5. FK damping satisfies the ODE w' = -V·w
-/

noncomputable section

namespace CATEPT.Examples

open CATEPT MeasureTheory

variable {α : Type*} [MeasurableSpace α] (m : MeasurePathIntegralModel α)

-- The weight norm is exactly the damping
example (x : α) : ‖m.weight x‖ = Real.exp (-(m.actionImScaled x)) :=
  m.weight_norm_is_damping x

-- Global bound: ‖w‖ ≤ 1
example (x : α) : ‖m.weight x‖ ≤ 1 :=
  m.weight_bochner_bounded x

-- Damping is strictly positive (no path is fully suppressed)
example (x : α) : 0 < m.damping x :=
  m.damping_pos x

-- Damping is at most 1
example (x : α) : m.damping x ≤ 1 :=
  m.damping_le_one x

-- Phase has unit norm (oscillatory part doesn't affect magnitude)
example (x : α) : ‖m.phase x‖ = 1 :=
  m.phase_norm_one x

-- Euclidean sector: when S_R = 0, weight is purely real damping
example (hRe : ∀ x, m.actionRe x = 0) (x : α) :
    m.weight x = (m.damping x : ℂ) :=
  m.weight_eq_damping_of_actionRe_zero hRe x

-- FK path weight bounded by 1 when potential is non-negative
example (V : ℝ → ℝ) (x : ℝ → ℝ) (t : ℝ)
    (hV : ∀ y, 0 ≤ V y) (ht : 0 ≤ t) :
    fkPathWeight V x t ≤ 1 :=
  fkPathWeight_le_one V x t hV ht

-- FK damping satisfies ODE: w'(t) = -V · w(t)
example (V : ℝ) (hV : 0 ≤ V) (t : ℝ) :
    HasDerivAt (fun t => Real.exp (-V * t)) (-V * Real.exp (-V * t)) t :=
  damping_satisfies_decay_ODE V hV t

-- From influence functional: damping ∈ (0, 1] without axioms
example (ifm : InfluenceFunctionalModel) :
    Real.exp (-(ifm.actionIm / ifm.hbar)) ∈ Set.Ioc 0 1 :=
  damping_mem_Ioc_from_influence_functional ifm

end CATEPT.Examples
