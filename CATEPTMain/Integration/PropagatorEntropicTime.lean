/-
  T-R Phase 1: Off-diagonal propagator vanishing + entropic-proper-time
  identification of the connected two-point function.

  Two compositions of the T-P scalar / T-Q multimode propagators with
  the CATEPT entropic-proper-time scale:

      Entropic proper time of a Gaussian mode (action `a x²`):
          τ(a) := 1 / (2 a)   --   the inverse kinetic coefficient.

      Per-mode reading (T-P, recast):
          ∂²_b W |_{b=0}        =  τ(a)            (= 1/(2 a))

      Off-diagonal vanishing (separable multimode action):
          ∂_s ( ∂_t [W(s,t)] |_{t=0} ) |_{s=0}     =  0
          for two distinct modes; their entropic clocks are independent.

  In CATEPT, identifying `a ↔ 1/(2τ)` recasts the propagator
  `G = 1/(2 a)` as the entropic proper time `τ` of that mode. The
  off-diagonal vanishing then says: independent Gaussian modes have
  decoupled entropic clocks — there is no cross-mode "time mixing"
  at the level of the connected two-point function.

  Both theorems are direct corollaries of `hasDerivAt_residual` and
  `hasDerivAt_propagator` from `PropagatorScalar`; positivity of the
  action coefficients is *not* required for the kinetic-side identity
  (it only matters for the well-formedness of `τ` as a physical scale).
-/
import CATEPTMain.Integration.PropagatorScalar
import CATEPTMain.Integration.PropagatorMultimode

set_option autoImplicit false

namespace CATEPTMain.Integration.PropagatorEntropicTime

open CATEPTMain.Integration.GaussianCompletion
open CATEPTMain.Integration.PropagatorScalar
open CATEPTMain.Integration.PropagatorMultimode

noncomputable section

/-- **Entropic proper time of a Gaussian mode**.

    For a one-mode Gaussian action `S = a x²` (action coefficient `a`),
    the entropic-proper-time scale is

        τ(a)  :=  1 / (2 a)

    i.e. the inverse kinetic coefficient. This is exactly the value of
    the connected propagator `G = ∂²_J W[J] |_{J=0}` (T-P
    `propagator_scalar`); the definition makes that physical reading
    explicit. -/
def entropicProperTime (a : ℝ) : ℝ := 1 / (2 * a)

/-- **Connected propagator equals entropic proper time** (T-R Phase 1).

    The per-mode connected two-point function `∂²_b W |_{b=0}` of the
    Gaussian generating functional `W[J] = J² / (4 a)` equals the
    entropic-proper-time scale `τ(a) = 1/(2 a)` of that mode. Direct
    repackaging of T-P's `propagator_scalar`. -/
theorem propagator_eq_entropicProperTime (a : ℝ) :
    deriv (fun b => deriv (fun b' => completionResidual a b') b) 0
      = entropicProperTime a := by
  unfold entropicProperTime
  exact propagator_scalar a

/-- **Off-diagonal propagator vanishes** (T-R Phase 1).

    For two Gaussian modes with action coefficients `aᵢ`, `aⱼ`, the
    *cross* second derivative of the separable two-mode generating
    functional

        W₂(s, t)  :=  W(aᵢ, s) + W(aⱼ, t)
                  =   completionResidual aᵢ s  +  completionResidual aⱼ t

    at `(s, t) = (0, 0)` vanishes:

        ∂_s ( ∂_t W₂(s, t) |_{t=0} ) |_{s=0}  =  0.

    Physically: independent Gaussian modes have decoupled entropic
    clocks — `G_{ij} = 0` for `i ≠ j` — and the multimode propagator
    kernel collapses to a *diagonal* matrix of entropic proper times. -/
theorem propagator_off_diagonal (ai aj : ℝ) :
    deriv (fun s : ℝ =>
      deriv (fun t : ℝ =>
        completionResidual ai s + completionResidual aj t) 0) 0
      = 0 := by
  -- Step 1: compute the inner derivative.
  -- For each fixed `s`, `t ↦ R(aᵢ, s) + R(aⱼ, t)` has derivative
  -- `0 + t/(2 aⱼ)` at `t`, hence equals `0/(2 aⱼ) = 0` at `t = 0`.
  have hinner : ∀ s,
      deriv (fun t : ℝ =>
        completionResidual ai s + completionResidual aj t) 0 = 0 := by
    intro s
    have hres : HasDerivAt
        (fun t : ℝ => completionResidual ai s + completionResidual aj t)
        (0 + 0 / (2 * aj)) 0 := by
      have h1 : HasDerivAt
          (fun _ : ℝ => completionResidual ai s) 0 0 :=
        hasDerivAt_const 0 (completionResidual ai s)
      have h2 : HasDerivAt
          (fun t : ℝ => completionResidual aj t) (0 / (2 * aj)) 0 :=
        hasDerivAt_residual aj 0
      exact h1.add h2
    have hd := hres.deriv
    -- `hd : deriv (...) 0 = 0 + 0 / (2 * aj)`. The RHS is 0.
    have hrhs : (0 : ℝ) + 0 / (2 * aj) = 0 := by ring
    rw [hrhs] at hd
    exact hd
  -- Step 2: outer derivative of a constant-zero function is 0.
  have hzero :
      (fun s : ℝ => deriv (fun t : ℝ =>
        completionResidual ai s + completionResidual aj t) 0)
        = fun _ => 0 := by
    funext s; exact hinner s
  rw [hzero]
  simp

/-- **Multimode propagator kernel equals diagonal entropic-proper-time
    matrix** (T-R Phase 1, multimode reading).

    Combining T-Q's `propagatorKernel` with `entropicProperTime`:

        G_{ij}  =  δ_{ij} · τ(aᵢ)   --   diagonal of per-mode τ values.

    Off-diagonal entries vanish (independent clocks); on the diagonal,
    each entry is the entropic proper time of that mode. -/
theorem propagatorKernel_eq_entropicProperTime
    {ι : Type*} [DecidableEq ι] (a : ι → ℝ) (i j : ι) :
    propagatorKernel a i j
      = if i = j then entropicProperTime (a i) else 0 := by
  unfold propagatorKernel entropicProperTime
  -- Both branches match definitionally; `rfl` closes it.
  rfl

end

end CATEPTMain.Integration.PropagatorEntropicTime
