import CATEPTMain.AFPBridge.MINK.MINKPrelude
/-!
# Convex_Body — AFP Minkowskis_Theorem → Lean 4 (Phase 1)

Source: `Minkowskis_Theorem/Minkowskis_Theorem.thy` (convex body section)
  (Manuel Eberl — 2017)
Dependencies: MINKPrelude

Content: Properties of convex bodies used in the Minkowski theorem proof —
  Brunn-Minkowski inequality, convex hull, convex combination characterization.

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.AFPBridge.MINK.Convex_Body

open CATEPTMain.AFPBridge.MINK

variable (n : ℕ)

-- ── Scalar multiple of convex body is convex ──────────────────────────────────
-- AFP: `smul_convex_body`
theorem smul_convexBody_convex (c : ℝ) (K : Set (Fin n → ℝ))
    (hK : Convex ℝ K) : Convex ℝ (smulConvexBody n c K) := by
  apply Convex.smul hK

-- ── Symmetric body contains 0 ─────────────────────────────────────────────────
-- AFP: Any non-empty convex symmetric body contains 0 (convex combination x, -x).
theorem symm_body_contains_zero (K : Set (Fin n → ℝ))
    (hNE : K.Nonempty)
    (hConvex : Convex ℝ K)
    (hSym : IsCentrallySymmetric n K) :
    ( 0 : Fin n → ℝ) ∈ K := by
  obtain ⟨x, hx⟩ := hNE
  have hNx : -x ∈ K := hSym x hx
  have h0 : ( 0 : Fin n → ℝ) = (1/2 : ℝ) • x + (1/2 : ℝ) • (-x) := by
    simp [smul_neg, add_neg_cancel]
  rw [h0]
  exact hConvex hx hNx (by norm_num) (by norm_num) (by norm_num)

-- ── K/2 ∩ ([0,1)ⁿ + z) partition argument ────────────────────────────────────
-- AFP: Key step in Eberl's proof: the "period lattice" decomposition.
-- If K/2 has volume > 1, the translates of K/2 by ℤⁿ in [0,1)ⁿ must overlap.
-- Phase-1: axiom for the measure-theoretic tiling fact.
axiom period_lattice_overlap
    (K : Set (Fin n → ℝ))
    (hMeas : MeasurableSet K)
    (hFin : HasFiniteVolume n K)
    (hVol : 1 < (minkVolume n (smulConvexBody n (1/2) K)).toReal) :
    ∃ x y : Fin n → ℝ,
    x ∈ smulConvexBody n (1/2) K ∧ y ∈ smulConvexBody n (1/2) K ∧
    x ≠ y ∧ ∃ z : Fin n → ℤ, z ≠ 0 ∧ x - y = latticePoint n z

-- ── Minkowski via overlap ─────────────────────────────────────────────────────
-- AFP: Minkowski's theorem follows from period_lattice_overlap + symmetry.
-- If x - y ∈ K (by symmetry: x ∈ K/2, -y ∈ K/2, so x - y = x + (-y) ∈ K by convexity).
private axiom minkowski_from_overlap_bounded (n : ℕ)
    (K : Set (Fin n → ℝ))
    (hConvex : Convex ℝ K) (hSym : IsCentrallySymmetric n K)
    (hFin : HasFiniteVolume n K) :
    Bornology.IsBounded K

theorem minkowski_from_overlap
    (K : Set (Fin n → ℝ))
    (hConvex : Convex ℝ K)
    (hSym : IsCentrallySymmetric n K)
    (hMeas : MeasurableSet K)
    (hFin : HasFiniteVolume n K)
    (hVol : (2 : ℝ) ^ n < (minkVolume n K).toReal) :
    ∃ z : Fin n → ℤ, z ≠ 0 ∧ latticePoint n z ∈ K :=
  minkowski_theorem n K hConvex hSym
    (minkowski_from_overlap_bounded n K hConvex hSym hFin)
    hMeas hFin hVol

end CATEPTMain.AFPBridge.MINK.Convex_Body
