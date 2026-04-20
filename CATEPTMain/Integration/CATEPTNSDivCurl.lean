-- IMPORTANT: This file must be imported before NoFTLPrelude.
-- NoFTLPrelude shadows core tactics (`norm_num`, `ring`, `linarith`, ...) to `sorry`.
-- The P0 `div(curl)=0` closure is proved here in a clean Mathlib environment.
import CATEPTMain.Integration.CATEPTSpaceTime
import Mathlib.Analysis.Calculus.VectorField

set_option autoImplicit false

open CATEPTMain.Integration.CATEPTSpaceTime
open scoped Topology

namespace CATEPTMain.Integration.SelfConsistency

/-- Divergence of a vector field on `Fin 3 → ℝ`. -/
noncomputable def catept_div (u : CATEPTVelocityField) (x : Fin 3 → ℝ) : ℝ :=
  ∑ i : Fin 3, (fderiv ℝ (fun y : Fin 3 → ℝ => u y i) x) (Pi.single i 1)

/-- Curl of a vector field on `Fin 3 → ℝ`. -/
noncomputable def catept_curl (u : CATEPTVelocityField) (x : Fin 3 → ℝ) : Fin 3 → ℝ :=
  fun i =>
    match i with
    | 0 =>
        (fderiv ℝ (fun y : Fin 3 → ℝ => u y 2) x) (Pi.single 1 1) -
        (fderiv ℝ (fun y : Fin 3 → ℝ => u y 1) x) (Pi.single 2 1)
    | 1 =>
        (fderiv ℝ (fun y : Fin 3 → ℝ => u y 0) x) (Pi.single 2 1) -
        (fderiv ℝ (fun y : Fin 3 → ℝ => u y 2) x) (Pi.single 0 1)
    | 2 =>
        (fderiv ℝ (fun y : Fin 3 → ℝ => u y 1) x) (Pi.single 0 1) -
        (fderiv ℝ (fun y : Fin 3 → ℝ => u y 0) x) (Pi.single 1 1)

private def coordVec (i : Fin 3) : (Fin 3 → ℝ) → (Fin 3 → ℝ) :=
  fun _ => Pi.single i (1 : ℝ)

private lemma hfd_const_coord (x : Fin 3 → ℝ) (j : Fin 3) :
    fderiv ℝ (coordVec j) x = 0 := by
  change fderiv ℝ (fun _ : Fin 3 → ℝ => (Pi.single j (1 : ℝ) : Fin 3 → ℝ)) x = 0
  exact fderiv_const_apply (𝕜 := ℝ) (x := x) (c := (Pi.single j (1 : ℝ) : Fin 3 → ℝ))

private lemma mixed_partials_eq
    (f : (Fin 3 → ℝ) → ℝ) (hf : ContDiff ℝ 2 f)
    (x : Fin 3 → ℝ) (i j : Fin 3) :
    fderiv ℝ (fun y => (fderiv ℝ f y) (Pi.single j (1 : ℝ))) x (Pi.single i (1 : ℝ))
      =
    fderiv ℝ (fun y => (fderiv ℝ f y) (Pi.single i (1 : ℝ))) x (Pi.single j (1 : ℝ)) := by
  let V : (Fin 3 → ℝ) → (Fin 3 → ℝ) := coordVec i
  let W : (Fin 3 → ℝ) → (Fin 3 → ℝ) := coordVec j
  have hW : DifferentiableAt ℝ W x := by
    simp [W, coordVec]
  have hV : DifferentiableAt ℝ V x := by
    simp [V, coordVec]
  have hcomm := VectorField.fderiv_apply_lieBracket
      (f := f) (x := x) (n := (2 : WithTop ℕ∞))
      (hf := hf.contDiffAt)
      (hn := by simpa using (show minSmoothness ℝ 2 ≤ (2 : WithTop ℕ∞) from le_rfl))
      (hW := hW) (hV := hV)
  have hlb : VectorField.lieBracket ℝ V W x = 0 := by
    unfold VectorField.lieBracket
    rw [hfd_const_coord x j, hfd_const_coord x i]
    simp
  have hsub :
      fderiv ℝ (fun y => fderiv ℝ f y (W y)) x (V x)
        -
      fderiv ℝ (fun y => fderiv ℝ f y (V y)) x (W x)
        = 0 := by
    simpa [hlb] using hcomm.symm
  simpa [V, W, coordVec] using sub_eq_zero.mp hsub

private lemma partial_differentiableAt
    (u : CATEPTVelocityField) (h_smooth : ContDiff ℝ 2 u)
    (x : Fin 3 → ℝ) (k j : Fin 3) :
    DifferentiableAt ℝ (fun y => (fderiv ℝ (fun z => u z k) y) (Pi.single j (1 : ℝ))) x := by
  let fk : (Fin 3 → ℝ) → ℝ := fun z => u z k
  have hfk2 : ContDiff ℝ 2 fk := by
    simpa [fk] using (contDiff_pi.mp h_smooth) k
  have hfd : ContDiff ℝ 1 (fderiv ℝ fk) :=
    hfk2.fderiv_right (by norm_num)
  have happ : ContDiff ℝ 1 (fun y => (fderiv ℝ fk y) (Pi.single j (1 : ℝ))) :=
    hfd.clm_apply contDiff_const
  exact happ.differentiable_one x

/-- **P0**: `div(curl u) = 0` for `C²` fields on `Fin 3 → ℝ`. -/
theorem catept_ns_p0_vorticity_mean_zero
    (u : CATEPTVelocityField)
    (h_smooth : ContDiff ℝ 2 u) :
    ∀ x, catept_div (fun y => catept_curl u y) x = 0 := by
  intro x
  have h21 := partial_differentiableAt u h_smooth x 2 1
  have h12 := partial_differentiableAt u h_smooth x 1 2
  have h02 := partial_differentiableAt u h_smooth x 0 2
  have h20 := partial_differentiableAt u h_smooth x 2 0
  have h10 := partial_differentiableAt u h_smooth x 1 0
  have h01 := partial_differentiableAt u h_smooth x 0 1
  have hu0 : ContDiff ℝ 2 (fun z => u z 0) := (contDiff_pi.mp h_smooth) 0
  have hu1 : ContDiff ℝ 2 (fun z => u z 1) := (contDiff_pi.mp h_smooth) 1
  have hu2 : ContDiff ℝ 2 (fun z => u z 2) := (contDiff_pi.mp h_smooth) 2
  have hm_u2_01 := mixed_partials_eq (fun z => u z 2) hu2 x 0 1
  have hm_u1_02 := mixed_partials_eq (fun z => u z 1) hu1 x 0 2
  have hm_u0_12 := mixed_partials_eq (fun z => u z 0) hu0 x 1 2
  simp [catept_div, catept_curl, Fin.sum_univ_three]
  rw [fderiv_fun_sub h21 h12, fderiv_fun_sub h02 h20, fderiv_fun_sub h10 h01]
  simp [ContinuousLinearMap.sub_apply, hm_u2_01, hm_u1_02, hm_u0_12]

end CATEPTMain.Integration.SelfConsistency
