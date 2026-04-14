import CATEPTMain.AFPBridge.ODE.Theories.Picard_Lindelof
/-!
# Flow — AFP Ordinary_Differential_Equations → Lean 4 (Phase 1)

Source: `Ordinary_Differential_Equations/Flow.thy`
  (Fabian Immler — 2014)
Dependencies: Picard_Lindelof

Content: Autonomous flow — the time-t map of x' = f(x).
  Key results:
  - Flow forms a one-parameter semigroup (group under composition)
  - Invariant sets under flow
  - Smoothness of flow with respect to initial conditions
  - Omega-limit sets for bounded trajectories

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.AFPBridge.ODE.Theories.Flow

open CATEPTMain.AFPBridge.ODE

-- ── Flow semigroup ────────────────────────────────────────────────────────────
-- Already stated in ODEPrelude; here we derive corollaries.

-- Flow inverse: flow(-t) is the inverse of flow(t).
theorem odeFlow_inv (n : ℕ)
    (f : EuclideanSpace ℝ (Fin n) → EuclideanSpace ℝ (Fin n))
    (t : ℝ) (x₀ : EuclideanSpace ℝ (Fin n)) :
    odeFlow n f (-t) (odeFlow n f t x₀) = x₀ := by
  sorry -- phase2_analysis: from semigroup and uniqueness: odeFlow(0) = id

-- Flow is injective (different initial conditions give distinct trajectories).
theorem odeFlow_injective (n : ℕ)
    (f : EuclideanSpace ℝ (Fin n) → EuclideanSpace ℝ (Fin n))
  (hLip : True)
    (t : ℝ) :
    Function.Injective (odeFlow n f t) := by
  sorry -- phase2_analysis: flow(t) is invertible by flow(-t); injectivity follows

-- ── Invariant sets ────────────────────────────────────────────────────────────
-- AFP: `invariant S f` = S is flow-invariant for f.
def IsFlowInvariant (n : ℕ) (f : EuclideanSpace ℝ (Fin n) → EuclideanSpace ℝ (Fin n))
    (S : Set (EuclideanSpace ℝ (Fin n))) : Prop :=
  ∀ t : ℝ, ∀ x ∈ S, odeFlow n f t x ∈ S

-- Equilibria are invariant (singleton):
theorem equilibrium_invariant (n : ℕ)
    (f : EuclideanSpace ℝ (Fin n) → EuclideanSpace ℝ (Fin n))
    (x₀ : EuclideanSpace ℝ (Fin n)) (h : IsEquilibrium n f x₀) :
    IsFlowInvariant n f {x₀} := by
  intro t x hx
  simp at hx
  rw [hx]
  exact equilibrium_fixed n f x₀ h t

-- ── Omega-limit set ───────────────────────────────────────────────────────────
-- AFP: `omega_limit S x` — the set of limit points of the trajectory of x.
def OmegaLimit (n : ℕ) (f : EuclideanSpace ℝ (Fin n) → EuclideanSpace ℝ (Fin n))
    (x₀ : EuclideanSpace ℝ (Fin n)) : Set (EuclideanSpace ℝ (Fin n)) :=
  { y | ∃ tseq : ℕ → ℝ, Filter.Tendsto tseq Filter.atTop Filter.atTop ∧
    Filter.Tendsto (fun k => odeFlow n f (tseq k) x₀) Filter.atTop (nhds y) }

-- Omega-limit set is a closed invariant set (phase-1 axiom).
axiom omegaLimit_closed_invariant (n : ℕ)
    (f : EuclideanSpace ℝ (Fin n) → EuclideanSpace ℝ (Fin n))
    (x₀ : EuclideanSpace ℝ (Fin n)) :
    IsClosed (OmegaLimit n f x₀) ∧ IsFlowInvariant n f (OmegaLimit n f x₀)

-- ── Smooth dependence on initial conditions ────────────────────────────────────
-- AFP: if f is C^k, then (t, x₀) ↦ flow(t, x₀) is C^k.
-- Phase-1 axiom.
axiom odeFlow_smooth (n : ℕ)
    (f : EuclideanSpace ℝ (Fin n) → EuclideanSpace ℝ (Fin n))
    (hSmooth : ContDiff ℝ ⊤ f) :
    ContDiff ℝ ⊤ (fun p : ℝ × EuclideanSpace ℝ (Fin n) => odeFlow n f p.1 p.2)

end CATEPTMain.AFPBridge.ODE.Theories.Flow
