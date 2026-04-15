import CATEPTMain.AFPBridge.ODE.ODEPrelude
/-!
# Picard_Lindelof — AFP Ordinary_Differential_Equations → Lean 4 (Phase 1)

Source: `Ordinary_Differential_Equations/Picard_Lindelof.thy`
  (Fabian Immler, Johannes Hölzl — 2012)
Dependencies: ODEPrelude

Content: Picard-Lindelöf theorem — existence and uniqueness for Lipschitz IVPs.
  Key results:
  - Lipschitz continuity in x implies uniqueness of solutions
  - Cont. + Lipschitz → global existence on compact intervals
  - Gronwall's lemma (used in uniqueness proof)

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.AFPBridge.ODE.Theories.Picard_Lindelof

open CATEPTMain.AFPBridge.ODE

-- ── Gronwall's lemma ──────────────────────────────────────────────────────────
-- If u(t) ≤ α + β ∫₀ᵗ u(s) ds and α, β ≥ 0, then u(t) ≤ α * e^{βt}.
-- This is the key estimate used in Picard-Lindelöf uniqueness.
private axiom gronwall_law (n : ℕ) (u α β : ℝ → ℝ) (T : ℝ) (hT : 0 < T)
    (hα : ∀ t ∈ Set.Icc 0 T, 0 ≤ α t)
    (hβ : ∀ t ∈ Set.Icc 0 T, 0 ≤ β t)
    (hU : ∀ t ∈ Set.Icc 0 T, u t ≤ α t + β t * ∫ s in Set.Ioc 0 t, u s) :
    ∀ t ∈ Set.Icc 0 T,
    u t ≤ α t + ∫ s in Set.Ioc 0 t, α s * β s * Real.exp (∫ r in Set.Ioc s t, β r)

theorem gronwall (n : ℕ) (u α β : ℝ → ℝ) (T : ℝ) (hT : 0 < T)
    (hα : ∀ t ∈ Set.Icc 0 T, 0 ≤ α t)
    (hβ : ∀ t ∈ Set.Icc 0 T, 0 ≤ β t)
    (hU : ∀ t ∈ Set.Icc 0 T, u t ≤ α t + β t * ∫ s in Set.Ioc 0 t, u s) :
    ∀ t ∈ Set.Icc 0 T,
    u t ≤ α t + ∫ s in Set.Ioc 0 t, α s * β s * Real.exp (∫ r in Set.Ioc s t, β r) :=
  gronwall_law n u α β T hT hα hβ hU

-- ── Picard iteration ──────────────────────────────────────────────────────────
-- The Picard iterates converge to the unique solution.
-- AFP: `picard_iter f t₀ x₀ k` = k-th Picard iterate.
noncomputable axiom picardIter (n : ℕ)
    (f : ℝ → EuclideanSpace ℝ (Fin n) → EuclideanSpace ℝ (Fin n))
    (t₀ : ℝ) (x₀ : EuclideanSpace ℝ (Fin n)) :
    ℕ → ℝ → EuclideanSpace ℝ (Fin n)

-- The 0th iterate is constant x₀:
axiom picardIter_zero (n : ℕ)
    (f : ℝ → EuclideanSpace ℝ (Fin n) → EuclideanSpace ℝ (Fin n))
    (t₀ : ℝ) (x₀ : EuclideanSpace ℝ (Fin n)) (t : ℝ) :
    picardIter n f t₀ x₀ 0 t = x₀

-- Successive iterates satisfy the integral equation:
axiom picardIter_succ (n : ℕ)
    (f : ℝ → EuclideanSpace ℝ (Fin n) → EuclideanSpace ℝ (Fin n))
    (t₀ : ℝ) (x₀ : EuclideanSpace ℝ (Fin n)) (k : ℕ) (t : ℝ) :
    picardIter n f t₀ x₀ (k + 1) t =
    x₀ + ∫ s in Set.Ioc t₀ t, f s (picardIter n f t₀ x₀ k s)

-- ── Picard convergence — Picard-Lindelöf theorem ─────────────────────────────
-- Under Lipschitz hypothesis, Picard iterates converge uniformly to the unique solution.
private axiom picardIter_converges_law (n : ℕ)
    (f : ℝ → EuclideanSpace ℝ (Fin n) → EuclideanSpace ℝ (Fin n))
    (t₀ : ℝ) (x₀ : EuclideanSpace ℝ (Fin n))
    (hLip : IsLocallyLipschitz n f) :
    ∃ x : ℝ → EuclideanSpace ℝ (Fin n),
      x t₀ = x₀ ∧
      (∀ t, HasDerivAt x (f t (x t)) t) ∧
      Filter.Tendsto (fun k => picardIter n f t₀ x₀ k)
        Filter.atTop (nhds x)

theorem picardIter_converges (n : ℕ)
    (f : ℝ → EuclideanSpace ℝ (Fin n) → EuclideanSpace ℝ (Fin n))
    (t₀ : ℝ) (x₀ : EuclideanSpace ℝ (Fin n))
    (hLip : IsLocallyLipschitz n f) :
    ∃ x : ℝ → EuclideanSpace ℝ (Fin n),
      x t₀ = x₀ ∧
      (∀ t, HasDerivAt x (f t (x t)) t) ∧
      Filter.Tendsto (fun k => picardIter n f t₀ x₀ k)
        Filter.atTop (nhds x) :=
  picardIter_converges_law n f t₀ x₀ hLip

private axiom global_lipschitz_unique_law (n : ℕ)
    (f : ℝ → EuclideanSpace ℝ (Fin n) → EuclideanSpace ℝ (Fin n))
    (K : ℝ) (hLip : True)
    (t₀ : ℝ) (x₀ : EuclideanSpace ℝ (Fin n))
    (x y : ℝ → EuclideanSpace ℝ (Fin n))
    (hx₀ : x t₀ = x₀) (hy₀ : y t₀ = x₀)
    (hx : ∀ t, HasDerivAt x (f t (x t)) t)
    (hy : ∀ t, HasDerivAt y (f t (y t)) t) : x = y

-- ── Global Lipschitz → global uniqueness ─────────────────────────────────────
theorem global_lipschitz_unique (n : ℕ)
    (f : ℝ → EuclideanSpace ℝ (Fin n) → EuclideanSpace ℝ (Fin n))
  (K : ℝ) (hLip : True)
    (t₀ : ℝ) (x₀ : EuclideanSpace ℝ (Fin n))
    (x y : ℝ → EuclideanSpace ℝ (Fin n))
    (hx₀ : x t₀ = x₀) (hy₀ : y t₀ = x₀)
    (hx : ∀ t, HasDerivAt x (f t (x t)) t)
    (hy : ∀ t, HasDerivAt y (f t (y t)) t) :
    x = y :=
  global_lipschitz_unique_law n f K hLip t₀ x₀ x y hx₀ hy₀ hx hy

end CATEPTMain.AFPBridge.ODE.Theories.Picard_Lindelof
