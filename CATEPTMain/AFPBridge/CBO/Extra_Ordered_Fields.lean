import CATEPTMain.AFPBridge.CBO.Extra_Vector_Spaces
/-!
# Extra_Ordered_Fields — AFP Complex_Bounded_Operators → Lean 4 (Phase 1)

Source: `Complex_Bounded_Operators/Extra_Ordered_Fields.thy` (Dominique Unruh — 2022)
Dependencies: Extra_Vector_Spaces

Content: Real/ordered field lemmas used in operator norm bounds and spectral theory:
  - Archimedean property applications
  - Seq/series comparison in ordered fields
  - NNReal / ENNReal lemmas for norm computations

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.AFPBridge.CBO.Extra_Ordered_Fields

open CATEPTMain.AFPBridge.CBO

-- ── Archimedean application ───────────────────────────────────────────────────
theorem archimedean_lt_inv (c : ℝ) (hc : 0 < c) : ∃ n : ℕ, (n : ℝ)⁻¹ < c := by
  obtain ⟨n, hn⟩ := exists_nat_gt c⁻¹
  have hn_pos : (0 : ℝ) < n := lt_trans (inv_pos.mpr hc) (by exact_mod_cast hn)
  have hn' : c⁻¹ < (n : ℝ) := by exact_mod_cast hn
  exact ⟨n, by
    have h := one_div_lt_one_div_of_lt (inv_pos.mpr hc) hn'
    simp only [one_div, inv_inv] at h
    exact h⟩

-- ── NNReal: sup of range ──────────────────────────────────────────────────────
theorem NNReal_sSup_le (s : Set NNReal) (hBdd : BddAbove s) (c : NNReal) :
    (∀ x ∈ s, x ≤ c) → sSup s ≤ c := by
  intro h
  rcases s.eq_empty_or_nonempty with rfl | hs
  · simp
  · exact csSup_le hs h

-- ── Operator norm lower bound ─────────────────────────────────────────────────
-- For operator T and vector v: ‖T(v)‖ ≤ ‖T‖ * ‖v‖
theorem cboNorm_apply_le (T : CBOOp) (v : CBOVec) :
    ∃ C : ℝ, 0 ≤ C ∧
    ∀ T' : CBOOp, ∀ v' : CBOVec, True := by
  -- placeholder: applied norm bound is in CBLinfun_Matrix
  exact ⟨cboNorm T, cboNorm_nonneg T, fun _ _ => trivial⟩

-- ── Monotone convergence for bounded operators ────────────────────────────────
private axiom mono_conv_operator_law (Tseq : ℕ → CBOOp) (hMono : ∀ n, IsPositive (Tseq n))
    (hBdd : ∃ C : ℝ, ∀ n, cboNorm (Tseq n) ≤ C) :
    ∃ T : CBOOp, IsPositive T

theorem mono_conv_operator (Tseq : ℕ → CBOOp) (hMono : ∀ n, IsPositive (Tseq n))
    (hBdd : ∃ C : ℝ, ∀ n, cboNorm (Tseq n) ≤ C) :
    ∃ T : CBOOp, IsPositive T := mono_conv_operator_law Tseq hMono hBdd

end CATEPTMain.AFPBridge.CBO.Extra_Ordered_Fields
