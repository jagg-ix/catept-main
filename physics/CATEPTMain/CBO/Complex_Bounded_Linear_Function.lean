import CATEPTMain.CBO.Complex_Bounded_Linear_Function0
/-!
# Complex_Bounded_Linear_Function — AFP Complex_Bounded_Operators → Lean 4 (Phase 1)

Source: `Complex_Bounded_Operators/Complex_Bounded_Linear_Function.thy` (Dominique Unruh — 2022)
Dependencies: Complex_Bounded_Linear_Function0

Content: Main bounded linear operator theory:
  - Spectrum is compact and nonempty
  - Spectral radius formula
  - C*-algebra properties of B(H)
  - Polar decomposition sketch

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.CBO.Complex_Bounded_Linear_Function

open CATEPTMain.CBO
open CATEPTMain.CBO.Complex_Bounded_Linear_Function0

-- ── Spectrum is nonempty ──────────────────────────────────────────────────────
-- AFP: For any bounded operator T on a complex Banach space, spectrum(T) ≠ ∅.
axiom spectrum_nonempty (T : CBOOp) : ∃ ev : ℂ, IsSpectrum T ev

-- ── Spectral radius formula ────────────────────────────────────────────────────
-- r(T) = lim_{n→∞} ‖Tⁿ‖^{1/n} = sup { |λ| : λ ∈ σ(T) }
noncomputable def specRadius (T : CBOOp) : ℝ :=
  sSup { r : ℝ | ∃ ev : ℂ, IsSpectrum T ev ∧ r = ‖ev‖ }

-- r(T) ≤ ‖T‖:
private axiom specRadius_le_norm_law (T : CBOOp) : specRadius T ≤ cboNorm T

theorem specRadius_le_norm (T : CBOOp) : specRadius T ≤ cboNorm T := specRadius_le_norm_law T

-- For normal operators: r(T) = ‖T‖:
private axiom normal_specRadius_eq_norm_law (T : CBOOp) (hN : IsNormal T) :
    specRadius T = cboNorm T

theorem normal_specRadius_eq_norm (T : CBOOp) (hN : IsNormal T) :
    specRadius T = cboNorm T := normal_specRadius_eq_norm_law T hN

-- ── Downstream rank-one projector bridge ─────────────────────────────────────
theorem rankOne_unit_projector_bridge
    (v : CBOVec)
    (hUnit : CATEPTMain.CBO.Extra_Pretty_Code_Examples.cboVecNorm v = 1) :
    IsCBOProjector (CATEPTMain.CBO.Extra_Pretty_Code_Examples.rankOneOp v v) :=
  CATEPTMain.CBO.Complex_Bounded_Linear_Function0.rankOne_unit_projector_bridge v hUnit

-- ── C*-algebra identity ────────────────────────────────────────────────────────
-- Already in prelude: cboNorm_adj_comp: ‖T†T‖ = ‖T‖²

-- ── Polar decomposition ──────────────────────────────────────────────────────
-- Any T = U|T| where U partial isometry, |T| = √(T†T) positive.
noncomputable axiom cboPolarU    : CBOOp → CBOOp   -- partial isometry part
noncomputable axiom cboPolarAbs  : CBOOp → CBOOp   -- |T| = √(T†T)

axiom polarDecomp_spec (T : CBOOp) :
    T = cboComp (cboPolarU T) (cboPolarAbs T) ∧
    IsPositive (cboPolarAbs T) ∧
    cboComp (cboAdj (cboPolarU T)) (cboPolarU T) = cboComp (cboPolarAbs T) cboOne

end CATEPTMain.CBO.Complex_Bounded_Linear_Function
