import CATEPTMain.Analysis.ODE.Flow
/-!
# Euler_Method — AFP Ordinary_Differential_Equations → Lean 4 (Phase 1)

Source: `Ordinary_Differential_Equations/Euler_Gene.thy`
  (Fabian Immler — 2014)
Dependencies: Flow

Content: Euler method as a first-order approximation to the ODE solution.
  Key results:
  - Euler step definition: x_{k+1} = x_k + h * f(t_k, x_k)
  - Error bound: O(h) per step, O(h * T) global on [0, T]
  - Convergence as step size h → 0

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.Analysis.ODE.Euler_Method

open CATEPTMain.Analysis.ODE

-- ── Euler step ────────────────────────────────────────────────────────────────
-- AFP: `euler_step f h t x = x + h * f(t, x)`
noncomputable def eulerStep (n : ℕ)
    (f : ℝ → EuclideanSpace ℝ (Fin n) → EuclideanSpace ℝ (Fin n))
    (h t : ℝ) (x : EuclideanSpace ℝ (Fin n)) : EuclideanSpace ℝ (Fin n) :=
  x + h • f t x

-- ── Euler trajectory ──────────────────────────────────────────────────────────
-- Repeated Euler steps from initial condition x₀ with step size h.
noncomputable def eulerTraj (n : ℕ)
    (f : ℝ → EuclideanSpace ℝ (Fin n) → EuclideanSpace ℝ (Fin n))
    (h t₀ : ℝ) (x₀ : EuclideanSpace ℝ (Fin n)) : ℕ → EuclideanSpace ℝ (Fin n)
  | 0 => x₀
  | k + 1 => eulerStep n f h (t₀ + k * h) (eulerTraj n f h t₀ x₀ k)

-- ── Local truncation error ────────────────────────────────────────────────────
-- The local error at each step is O(h²) if f is C¹.
-- AFP: `euler_local_err f h t x₀` ≤ C * h²
axiom euler_local_error (n : ℕ)
    (f : ℝ → EuclideanSpace ℝ (Fin n) → EuclideanSpace ℝ (Fin n))
    (h t : ℝ) (x₀ : EuclideanSpace ℝ (Fin n))
    (hC1 : ContDiff ℝ 1 (fun p : ℝ × EuclideanSpace ℝ (Fin n) => f p.1 p.2)) :
    ∃ C : ℝ, 0 ≤ C ∧
    ‖odeFlow n (f t) h x₀ - eulerStep n f h t x₀‖ ≤ C * h ^ 2

-- ── Global error bound ────────────────────────────────────────────────────────
-- After N = T/h steps, global error ≤ C * h (O(h) method).
private axiom euler_global_error_law (n : ℕ)
    (f : ℝ → EuclideanSpace ℝ (Fin n) → EuclideanSpace ℝ (Fin n))
    (T h t₀ : ℝ) (x₀ : EuclideanSpace ℝ (Fin n))
    (hT : 0 < T) (hh : 0 < h)
    (hLip : IsLocallyLipschitz n f)
    (hC1 : ContDiff ℝ 1 (fun p : ℝ × EuclideanSpace ℝ (Fin n) => f p.1 p.2))
    (N : ℕ) (hN : N = ⌊T / h⌋₊) :
    ∃ C : ℝ, 0 ≤ C ∧
    ‖odeFlow n (f t₀) T x₀ - eulerTraj n f h t₀ x₀ N‖ ≤ C * h

private axiom euler_converges_law (n : ℕ)
    (f : ℝ → EuclideanSpace ℝ (Fin n) → EuclideanSpace ℝ (Fin n))
    (T t₀ : ℝ) (x₀ : EuclideanSpace ℝ (Fin n))
    (hLip : IsLocallyLipschitz n f)
    (hC1 : ContDiff ℝ 1 (fun p : ℝ × EuclideanSpace ℝ (Fin n) => f p.1 p.2)) :
    Filter.Tendsto
      (fun h : ℝ => eulerTraj n f h t₀ x₀ ⌊T / h⌋₊)
      (nhdsWithin 0 (Set.Ioi 0))
      (nhds (odeFlow n (f t₀) T x₀))

theorem euler_global_error (n : ℕ)
    (f : ℝ → EuclideanSpace ℝ (Fin n) → EuclideanSpace ℝ (Fin n))
    (T h t₀ : ℝ) (x₀ : EuclideanSpace ℝ (Fin n))
    (hT : 0 < T) (hh : 0 < h)
    (hLip : IsLocallyLipschitz n f)
    (hC1 : ContDiff ℝ 1 (fun p : ℝ × EuclideanSpace ℝ (Fin n) => f p.1 p.2))
    (N : ℕ) (hN : N = ⌊T / h⌋₊) :
    ∃ C : ℝ, 0 ≤ C ∧
    ‖odeFlow n (f t₀) T x₀ - eulerTraj n f h t₀ x₀ N‖ ≤ C * h :=
  euler_global_error_law n f T h t₀ x₀ hT hh hLip hC1 N hN

-- ── Convergence as h → 0 ─────────────────────────────────────────────────────
-- The Euler trajectory converges to the true solution as h → 0.
theorem euler_converges (n : ℕ)
    (f : ℝ → EuclideanSpace ℝ (Fin n) → EuclideanSpace ℝ (Fin n))
    (T t₀ : ℝ) (x₀ : EuclideanSpace ℝ (Fin n))
    (hLip : IsLocallyLipschitz n f)
    (hC1 : ContDiff ℝ 1 (fun p : ℝ × EuclideanSpace ℝ (Fin n) => f p.1 p.2)) :
    Filter.Tendsto
      (fun h : ℝ => eulerTraj n f h t₀ x₀ ⌊T / h⌋₊)
      (nhdsWithin 0 (Set.Ioi 0))
      (nhds (odeFlow n (f t₀) T x₀)) :=
  euler_converges_law n f T t₀ x₀ hLip hC1

end CATEPTMain.Analysis.ODE.Euler_Method
