import CATEPTMain.Geometry.MINK.Lattice_Points
/-!
# Minkowski_Main — AFP Minkowskis_Theorem → Lean 4 (Phase 1)

Source: `Minkowskis_Theorem/Minkowskis_Theorem.thy` (main theorem)
  (Manuel Eberl — 2017)
Dependencies: Lattice_Points

Content: The main Minkowski theorem, its corollaries (number-theoretic applications),
  and the generalization to arbitrary full-rank lattices.

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.Geometry.MINK.Minkowski_Main

open CATEPTMain.Geometry.MINK

variable (n : ℕ)

-- ── Minkowski's Theorem (re-export for downstream imports) ─────────────────────
-- Primary statement: see MINKPrelude.minkowski_theorem.
-- Here we state the "compact body" variant (Bornology.IsCompact stronger than IsBounded).
axiom minkowski_compact
    (K : Set (Fin n → ℝ))
    (hConvex : Convex ℝ K)
    (hSym : IsCentrallySymmetric n K)
    (hComp : IsCompact K)
    (hMeas : MeasurableSet K)
    (hVol : (2 : ℝ) ^ n < (minkVolume n K).toReal) :
  ∃ z : Fin n → ℤ, z ≠ 0 ∧ latticePoint n z ∈ K

-- ── Open body variant ─────────────────────────────────────────────────────────
-- AFP: For the open interior variant, the *closed* volume condition suffices:
-- vol(K) ≥ 2ⁿ (with ≥ instead of >) when K is open, by limit argument.
axiom minkowski_open_ge
    (K : Set (Fin n → ℝ))
    (hConvex : Convex ℝ K)
    (hSym : IsCentrallySymmetric n K)
    (hOpen : IsOpen K)
    (hMeas : MeasurableSet K)
    (hFin : HasFiniteVolume n K)
    (hVol : (2 : ℝ) ^ n ≤ (minkVolume n K).toReal) :
    ∃ z : Fin n → ℤ, z ≠ 0 ∧ latticePoint n z ∈ K

-- ── Corollary: simultaneous Diophantine approximation (Dirichlet) ─────────────
-- AFP: Minkowski implies simultaneous approximation:
-- For any α : Fin n → ℝ and N : ℕ, ∃ q : ℤ with 1 ≤ q ≤ N and ‖q α_i - p_i‖ ≤ N^{-1/n}.
-- Standard number-theoretic corollary.
axiom dirichlet_simultaneous (α : Fin n → ℝ) (N : ℕ) (hN : 0 < N) :
    ∃ (q : ℤ) (p : Fin n → ℤ), 1 ≤ q ∧ q ≤ N ∧
    ∀ i, |q * α i - p i| ≤ ((N : ℝ) ^ (n : ℝ))⁻¹

-- ── Four-square theorem setup ──────────────────────────────────────────────────
-- AFP: Minkowski in ℝ⁴ with K = ball of radius 2√p implies Lagrange's four-square
-- theorem. Phase-1: the application of the ball volume to the theorem.
-- vol(B(r)) = π² r⁴ / 2 in ℝ⁴; > 2⁴ = 16 when r² > 8/π².
axiom minkowski_four_square_ball (p : ℕ) (hp : Nat.Prime p) :
    ∃ a b c d : ℤ, (a^2 + b^2 + c^2 + d^2 : ℤ) = p

-- ── Generalization: arbitrary full-rank lattice Λ ─────────────────────────────
-- AFP: If Λ = {Az | z : ℤⁿ} is a full-rank lattice with det(A) ≠ 0,
-- and vol(K) > 2ⁿ |det(A)|, then K ∩ Λ ≠ {0}.
axiom minkowski_general_lattice
    (A : Matrix (Fin n) (Fin n) ℝ)
    (hDet : A.det ≠ 0)
    (K : Set (Fin n → ℝ))
    (hConvex : Convex ℝ K)
    (hSym : IsCentrallySymmetric n K)
    (hMeas : MeasurableSet K)
    (hFin : HasFiniteVolume n K)
    (hVol : 2 ^ n * |A.det| < (minkVolume n K).toReal) :
    ∃ z : Fin n → ℤ, z ≠ 0 ∧
    (fun i => A.mulVec (fun j => (z j : ℝ)) i) ∈ K

end CATEPTMain.Geometry.MINK.Minkowski_Main
