import CATEPTMain.AFPBridge.MINK.Theories.Convex_Body
/-!
# Lattice_Points — AFP Minkowskis_Theorem → Lean 4 (Phase 1)

Source: `Minkowskis_Theorem/Minkowskis_Theorem.thy` (lattice theory section)
  (Manuel Eberl — 2017)
Dependencies: Convex_Body

Content: Integer lattice embedding, parity of lattice points, and
  the Blichfeldt theorem (intermediate step in Minkowski's proof).

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.AFPBridge.MINK.Theories.Lattice_Points

open CATEPTMain.AFPBridge.MINK

variable (n : ℕ)

-- ── Integer lattice is a discrete subgroup ─────────────────────────────────────
-- AFP: ℤⁿ is a discrete additive subgroup of ℝⁿ.
theorem lattice_discrete (z₁ z₂ : Fin n → ℤ) (h : latticePoint n z₁ = latticePoint n z₂) :
    z₁ = z₂ := by
  funext i
  have := congr_fun h i
  simp [latticePoint] at this
  exact_mod_cast this

-- ── Blichfeldt's Theorem ──────────────────────────────────────────────────────
-- AFP: `Blichfeldt's_Theorem`:
-- If S ⊆ ℝⁿ is measurable and vol(S) > 1, then ∃ x ≠ y ∈ S with x - y ∈ ℤⁿ.
-- (This is the key lemma Eberl uses; Minkowski follows by applying it to S = K/2.)
axiom blichfeldt_theorem
    (S : Set (Fin n → ℝ))
    (hMeas : MeasurableSet S)
    (hFin : minkVolume n S < ⊤)
    (hVol : 1 < (minkVolume n S).toReal) :
    ∃ x y : Fin n → ℝ,
    x ∈ S ∧ y ∈ S ∧ x ≠ y ∧
    ∃ z : Fin n → ℤ, latticePoint n z = x - y

-- ── Minkowski from Blichfeldt ─────────────────────────────────────────────────
-- AFP: Eberl's proof chain: apply Blichfeldt to K/2, then use symmetric convexity.
-- x, y ∈ K/2 with x − y = z ∈ ℤⁿ
-- ⟹ 2x ∈ K, -2y ∈ K (by symmetry), so z = x − y = (2x + (−2y))/2 ∈ K.
theorem minkowski_via_blichfeldt
    (K : Set (Fin n → ℝ))
    (hConvex : Convex ℝ K)
    (hSym : IsCentrallySymmetric n K)
    (hMeas : MeasurableSet K)
    (hFin : HasFiniteVolume n K)
    (hVol : (2 : ℝ) ^ n < (minkVolume n K).toReal) :
    ∃ z : Fin n → ℤ, z ≠ 0 ∧ latticePoint n z ∈ K := by
  -- Step 1: half-body K/2 has vol(K/2) = vol(K)/2ⁿ > 1 by hypothesis.
  -- Step 2: apply Blichfeldt to S = K/2.
  -- Step 3: x - y = z integer vector; show z ∈ K by convexity + symmetry.
  sorry -- phase2_geometry: formal chain above

-- ── Lattice parity lemma ──────────────────────────────────────────────────────
-- AFP: used internally; if z has all even coordinates, z/2 is also a lattice point.
def isEvenLattice (z : Fin n → ℤ) : Prop := ∀ i, 2 ∣ z i

theorem evenLattice_half (z : Fin n → ℤ) (h : isEvenLattice n z) :
    ∃ w : Fin n → ℤ, latticePoint n z = 2 • latticePoint n w := by
  refine ⟨fun i => z i / 2, ?_⟩
  simp [latticePoint, isEvenLattice] at *
  sorry -- phase2_lattice: z i = 2 * (z i / 2) since 2 | z i

end CATEPTMain.AFPBridge.MINK.Theories.Lattice_Points
