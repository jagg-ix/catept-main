-- IMPORTANT: This file must NOT import NoFTLPrelude.
-- NoFTLPrelude shadows `norm_num` → `sorry`, which would contaminate real proofs.
-- This file provides the only sorry-free theorem in the GN cluster.
import CATEPTMain.Integration.CATEPTSpaceTime
import Mathlib.Analysis.FunctionalSpaces.SobolevInequality
import Mathlib.MeasureTheory.Measure.Lebesgue.EqHaar

set_option autoImplicit false

open MeasureTheory
open CATEPTMain.Integration.CATEPTSpaceTime

namespace CATEPTMain.Integration.SelfConsistency

/-- Bump function type for periodization (T³ → R³).
    Declared as `abbrev` so the type is transparent to the elaborator — necessary
    for `exact eLpNorm_le_eLpNorm_fderiv_of_le` to unify without coercions. -/
abbrev BumpFunction3D := (Fin 3 → ℝ) → ℝ

/-- **P2** (Gagliardo-Nirenberg H¹ ↪ L⁴ embedding on a bounded domain).

    For a C¹ velocity field `u` and a C¹ bump function `χ` with `(χ·u).support ⊆ s`,
    the L⁴ norm of `χ·u` is bounded by the GN constant times the L² norm of
    `∇(χ·u)`.

    Parameters: `p = 2`, `q = 4`, `n = dim(Fin 3 → ℝ) = 3`.
    GN checks:
    - `1 ≤ p = 2` ✓
    - `p = 2 < n = 3` ✓
    - `p⁻¹ − n⁻¹ = ½ − ⅓ = ⅙ ≤ ¼ = q⁻¹` ✓ -/
theorem catept_ns_p2_gn_h1_l4_embedding
    (u : CATEPTVelocityField)
    (χ : BumpFunction3D)
    (s : Set (Fin 3 → ℝ))
    (h_bound : Bornology.IsBounded s)
    (hu : ContDiff ℝ 1 u)
    (hχ : ContDiff ℝ 1 χ)
    (h_supp : (fun x => χ x • u x).support ⊆ s) :
    eLpNorm (fun x => χ x • u x) 4 volume ≤
    eLpNormLESNormFDerivOfLeConst ((Fin 3 → ℝ)) volume s 2 4 *
    eLpNorm (fderiv ℝ (fun x => χ x • u x)) 2 volume := by
  -- Both BumpFunction3D and CATEPTVelocityField are `abbrev`, so Lean's elaboration
  -- unifier sees through them without explicit type coercions.
  haveI : Measure.IsAddHaarMeasure (volume : Measure (Fin 3 → ℝ)) :=
    MeasureTheory.isAddHaarMeasure_volume_pi (Fin 3)
  have hfr : Module.finrank ℝ (Fin 3 → ℝ) = 3 := by
    simp [Module.finrank_fintype_fun_eq_card, Fintype.card_fin]
  have hfr_real : (Module.finrank ℝ (Fin 3 → ℝ) : ℝ) = 3 := by exact_mod_cast hfr
  exact eLpNorm_le_eLpNorm_fderiv_of_le (μ := volume) (F := Fin 3 → ℝ) (p := 2) (q := 4)
    (hχ.smul hu) h_supp
    (by norm_num)
    (by rw [hfr]; norm_cast)
    (by rw [hfr_real]; push_cast; norm_num)
    h_bound

end CATEPTMain.Integration.SelfConsistency
