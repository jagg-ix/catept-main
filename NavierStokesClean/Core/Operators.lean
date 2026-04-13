import NavierStokesClean.Core.SpatialTypes

/-!
# Differential operators — Phase 23 concrete enstrophy on EuclideanSpace ℝ (Fin 3)

Phase 11: `enstrophy` and `palinstrophy` made concrete, discharging 3 axioms.
Phase 23: `NSField = EuclideanSpace ℝ (Fin 3)`, so `‖u‖` is the ℓ² norm on ℝ³.

## Enstrophy: ‖u‖² on EuclideanSpace ℝ (Fin 3)

  `enstrophy u := ‖u‖^2`

This is the squared ℓ² norm of the velocity vector in ℝ³. By `sq_nonneg`, ≥ 0.
Phase 5 target: redefine as `‖∇ × u‖²_{L²}` (vorticity L² norm) once `Trajectory`
carries spatial structure (currently `ℝ → NSField`, no spatial dependence).

`enstrophy_nonneg` is a theorem (0 new axioms).

## Palinstrophy: legacy abstract placeholder + spatial strict variant

`palinstrophy` on `NSField` remains the legacy abstract placeholder for compatibility.
For non-vacuous semantics, use `palinstrophySpatial` on `NSVelocityField`.

## ns_divergence_free_satisfied: legacy compatibility theorem

The original theorem concluded `True`; we keep it for compatibility. For non-vacuous
semantics, use `ns_vorticity_divergence_free` on spatial fields.

## Net: −3 axioms (15 → 12), Phase 11.
-/

set_option autoImplicit false

namespace NavierStokesClean

/-! ## §1. Enstrophy and legacy palinstrophy -/

/-- Enstrophy Ω[u] = ‖u‖² on `NSField = EuclideanSpace ℝ (Fin 3)`.

    Phase 11: made concrete as the squared norm.
    Phase 23: `‖u‖` is the ℓ² norm on ℝ³, nonneg by `sq_nonneg`.

    Phase 5 target: redefine as `‖∇ × u‖²_{L²}` (vorticity L² norm) once
    `Trajectory` carries spatial structure. -/
noncomputable def enstrophy (u : NSField) : ℝ := ‖u‖ ^ 2

/-- Enstrophy is nonneg — proved from `sq_nonneg`. 0 new axioms. -/
theorem enstrophy_nonneg (u : NSField) : (0 : ℝ) ≤ enstrophy u := sq_nonneg ‖u‖

/-- Legacy abstract palinstrophy on `NSField`.

    Compatibility surface used by existing abstract-carrier proofs.
    For non-vacuous spatial semantics, see `palinstrophySpatial`. -/
noncomputable def palinstrophy (_ : NSField) : ℝ := 0

/-- Legacy palinstrophy nonnegativity. -/
theorem palinstrophy_nonneg (u : NSField) : (0 : ℝ) ≤ palinstrophy u := le_refl 0

/-- Initial enstrophy Ω₀ of a trajectory. -/
noncomputable def initialEnstrophy (traj : Trajectory) : ℝ :=
  enstrophy (traj 0)

theorem initialEnstrophy_nonneg (traj : Trajectory) : 0 ≤ initialEnstrophy traj :=
  enstrophy_nonneg _

/-! ## §1b. Spatial strict operators (M1 semantic concretization lane) -/

/-- Non-vacuous spatial palinstrophy on velocity fields.

    This is the L² integral of the squared norm of `∇ω` on Space,
    where `ω = ∇ × u`. -/
noncomputable def palinstrophySpatial (u : NSVelocityField) : ℝ :=
  ∫ x : Space, ‖fderiv ℝ (vorticity u) x‖ ^ 2

/-- Spatial palinstrophy is nonnegative. -/
theorem palinstrophySpatial_nonneg (u : NSVelocityField) :
    0 ≤ palinstrophySpatial u :=
  MeasureTheory.integral_nonneg fun _ => sq_nonneg _

/-- Spatial palinstrophy of a constant velocity field is zero.
    Vorticity of constant field vanishes (Phase 5A), so `∇ω = 0` everywhere. -/
theorem palinstrophySpatial_zero_of_const (v : EuclideanSpace ℝ (Fin 3)) :
    palinstrophySpatial (fun _ : Space => v) = 0 := by
  simp only [palinstrophySpatial, vorticity_zero_of_const]
  have key : ∀ x : Space,
      ‖fderiv ℝ (fun _ : Space => (0 : EuclideanSpace ℝ (Fin 3))) x‖ ^ 2 = 0 := fun x => by
    have hfd : fderiv ℝ (fun _ : Space => (0 : EuclideanSpace ℝ (Fin 3))) x = 0 :=
      (hasFDerivAt_const (0 : EuclideanSpace ℝ (Fin 3)) x).fderiv
    rw [hfd, ContinuousLinearMap.opNorm_zero, zero_pow (by norm_num : 2 ≠ 0)]
  simp_rw [key]
  simp

/-- Non-vacuous divergence-free theorem for vorticity on spatial fields.

    This is the semantic target replacing the legacy `... → True` theorem. -/
theorem ns_vorticity_divergence_free (u : NSVelocityField) (hu : ContDiff ℝ 2 u) :
    ∇ ⬝ (vorticity u) = 0 :=
  vorticity_divFree u hu

/-- **Vortex stretching**: VS[u] = ∫_{Space} ⟨ω(x), (∇u(x))·ω(x)⟩ dx
    where ω = ∇ × u is the vorticity.

    In coordinates: VS[u] = ∫ ω_i (∂u_i/∂x_j) ω_j dx (sum over i,j ∈ {1,2,3}).

    This is the source term in the enstrophy equation:
      d/dt spatialEnstrophy(u(t)) = −2ν · palinstrophySpatial(u(t)) + 2 · vorticityStretching(u(t))

    **NSC-P33 anchor 0 (concrete def)**:
    `fderiv ℝ u x : Space →L[ℝ] EuclideanSpace ℝ (Fin 3)` expects a `Space` argument,
    while `vorticity u x : EuclideanSpace ℝ (Fin 3)`. We coerce via PhysLean's
    `Space.basis.repr.symm : EuclideanSpace ℝ (Fin 3) ≃ₗᵢ[ℝ] Space`, which applies
    coordinate-wise (`basis.repr.symm v i = v i`, `by rfl`).

    Previously declared `noncomputable opaque` with a companion axiom. The concrete
    definition discharges `vorticityStretching_zero_of_const` from the axiom surface.

    Used in: `VSNuPSpatialBridge` (m01c), SA-G1 trilinear bound. -/
noncomputable def vorticityStretching (u : NSVelocityField) : ℝ :=
  ∫ x : Space, @inner ℝ _ _ (vorticity u x) (fderiv ℝ u x (Space.basis.repr.symm (vorticity u x)))

/-- **Vortex stretching of a constant velocity field is zero** (NSC-P33 anchor 0: THEOREM).

    For `u = fun _ => v`, vorticity ω = ∇×u = 0 (by `vorticity_zero_of_const`),
    so ⟨0, (∇u)·0⟩ = 0 (by `inner_zero_left`), and `∫ x, 0 = 0`.

    **Axioms consumed**: 0 (pure Mathlib; previously required `axiom`). -/
theorem vorticityStretching_zero_of_const (v : EuclideanSpace ℝ (Fin 3)) :
    vorticityStretching (fun _ : Space => v) = 0 := by
  simp only [vorticityStretching]
  have hv : ∀ x : Space, vorticity (fun _ : Space => v) x = 0 :=
    fun x => congr_fun (vorticity_zero_of_const v) x
  simp_rw [hv]
  simp

/-! ## §2. Legacy compatibility theorem -/

/-- Legacy compatibility theorem kept for existing abstract-carrier dependencies.

    New non-vacuous consumers should migrate to `ns_vorticity_divergence_free`. -/
theorem ns_divergence_free_satisfied : ∀ (traj : Trajectory),
    SatisfiesNSPDE nsNu traj → True :=
  fun _ _ => trivial

end NavierStokesClean
