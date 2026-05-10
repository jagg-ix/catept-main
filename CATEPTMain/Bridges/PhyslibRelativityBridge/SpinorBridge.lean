import CATEPTMain.Bridges.PhyslibRelativityBridge.MinkowskiBridge
import Physlib.Relativity.PauliMatrices.Basic
import Physlib.Relativity.PauliMatrices.SelfAdjoint
import Physlib.Relativity.Tensors.RealTensor.Vector.Pre.Modules
import Physlib.Relativity.Tensors.RealTensor.Vector.Pre.Contraction
import Physlib.Relativity.SL2C.Basic

/-!
# Bridge: CATEPT Spacetime ↔ Physlib Spinors & SL(2,ℂ)

This module connects the CATEPT spacetime to Physlib's spinor/Lorentz
formalism via the self-adjoint 2×2 matrix representation.

## Construction

The core map is:

  `cateptToSelfAdjoint : CATEPTST →ₗ[ℝ] selfAdjoint (Matrix (Fin 2) (Fin 2) ℂ)`

defined by composing:

  CATEPTST --[cateptEquivPhyslib]--> SpaceTime 3 --[toFin1dℝEquiv.symm]--> ContrMod 3
           --[ContrMod.toSelfAdjoint]--> selfAdjoint (Matrix (Fin 2) (Fin 2) ℂ)

Physlib already proves that `ContrMod.toSelfAdjoint` is a `LinearEquiv`, that
the Pauli matrices are self-adjoint, and that the determinant of the image equals
the `contrContrContractField` contraction (the `+−−−` Minkowski inner product).

## Key results

- `cateptToSelfAdjoint` — the concrete linear map to self-adjoint matrices,
  defined by composing Physlib's `ContrMod.toSelfAdjoint` with the CATEPT bridge.
  Self-adjointness is automatic (built into the subtype).

- `cateptToSelfAdjoint_det` — `det (cateptToSelfAdjoint x).1 = −minkowskiNorm2 x`.
  This is the spinor-to-metric compatibility theorem, derived from
  `contrContrContractField.same_eq_det_toSelfAdjoint` and
  `minkowskiNorm2_eq_neg_physlib`.

- `cateptToSelfAdjoint_intertwines_sl2c` — the SL(2,ℂ) action `M A M†` on
  `cateptToSelfAdjoint x` equals `cateptToSelfAdjoint` of the Lorentz-transformed
  source.  Proof: reduces to Physlib's `SL2C.toMatrix_apply_contrMod` which is
  already proved in the library.

## Sign conventions

The CATEPT metric is `(−+++)` and `cateptToSelfAdjoint` passes through
`cateptEquivPhyslib` (the `(−+++) ↔ (+−−−)` bridge) before entering Physlib's
`ContrMod.toSelfAdjoint`, which uses the `(+−−−)` Pauli basis.  The resulting
self-adjoint matrix is `x⁰·σ₀ − x¹·σ₁ − x²·σ₂ − x³·σ₃` in CATEPT coordinates,
with determinant `(x⁰)² − (x¹)² − (x²)² − (x³)² = −minkowskiNorm2 x`.

## What this does NOT yet claim

The time coordinate `x⁰` here is the *Lorentz time component* transported
through the bridge, not yet an entropic-proper-time.  The identification
`τ_ent(q,p) = √(−minkowskiNorm2 (p−q))` is proved separately in `ProperTimeBridge`.
-/

open CATEPTMain.Geometry.FiniteMinkowski
open Lorentz PauliMatrix MatrixGroups

namespace CATEPTMain.Bridges.PhyslibRelativityBridge

/-! ## Definition -/

/-- The CATEPT-to-self-adjoint-matrix map.

Defined as the composition
  `CATEPTST → SpaceTime 3 → ContrMod 3 → selfAdjoint (Matrix (Fin 2) (Fin 2) ℂ)`
where the last step is Physlib's `ContrMod.toSelfAdjoint` (a `LinearEquiv`).

This is the canonical Weyl / Pauli-basis embedding of CATEPT spacetime into
the `selfAdjoint` subtype.  Self-adjointness of the image is automatic because
`ContrMod.toSelfAdjoint` targets the self-adjoint subtype directly. -/
noncomputable def cateptToSelfAdjoint : CATEPTST →ₗ[ℝ] selfAdjoint (Matrix (Fin 2) (Fin 2) ℂ) :=
  ContrMod.toSelfAdjoint.toLinearMap ∘ₗ
  ContrMod.toFin1dℝEquiv.symm.toLinearMap ∘ₗ
  cateptEquivPhyslib.toLinearMap

/-- Unfolding lemma: `cateptToSelfAdjoint x = ContrMod.toSelfAdjoint (⟨cateptEquivPhyslib x⟩)`. -/
@[simp]
lemma cateptToSelfAdjoint_apply (x : CATEPTST) :
    cateptToSelfAdjoint x =
    ContrMod.toSelfAdjoint ⟨cateptEquivPhyslib x⟩ := by
  -- Both sides reduce definitionally via:
  --   (f ∘ₗ g) x = f (g x), ContrMod.toFin1dℝEquiv.symm f = ⟨f⟩ (rfl, cf. toFin1dℝ_eq_val)
  simp only [cateptToSelfAdjoint, LinearMap.coe_comp, Function.comp_apply,
             LinearEquiv.coe_toLinearMap]
  rfl

/-! ## Determinant = Minkowski norm -/

/-- **Spinor-to-metric compatibility**: The determinant of `cateptToSelfAdjoint x`
equals `−minkowskiNorm2 x`.

*Proof*: by `contrContrContractField.same_eq_det_toSelfAdjoint`, the determinant
of `ContrMod.toSelfAdjoint v` equals the contrContrContractField contraction
`⟪v, v⟫ₘ`, which (by `as_sum`) equals `minkowskiProductMap v.val v.val`.
Since `v.val = cateptEquivPhyslib x`, this equals
`minkowskiProductMap (cateptEquivPhyslib x) (cateptEquivPhyslib x) = −minkowskiNorm2 x`
by `minkowskiNorm2_eq_neg_physlib`. -/
theorem cateptToSelfAdjoint_det (x : CATEPTST) :
    (cateptToSelfAdjoint x).1.det = (-(minkowskiNorm2 x) : ℂ) := by
  rw [cateptToSelfAdjoint_apply]
  rw [← Lorentz.contrContrContractField.same_eq_det_toSelfAdjoint]
  rw [Lorentz.contrContrContractField.as_sum]
  -- v.val = cateptEquivPhyslib x
  simp only [ContrMod.toFin1dℝEquiv, LinearEquiv.coe_mk, Fin.sum_univ_three]
  -- match with minkowskiNorm2 x = -(x⁰² - x¹² - x²² - x³²)
  simp only [cateptEquivPhyslib_time, cateptEquivPhyslib_spatial,
             minkowskiNorm2, spatialNorm2, Fin.sum_univ_three]
  -- Goal is in ℂ due to det; push coercions inside then close by ring.
  push_cast; ring

/-! ## SL(2,ℂ) intertwining -/

/-- **Spin double cover**: The SL(2,ℂ) conjugation action `M A M†` on the
self-adjoint matrix `cateptToSelfAdjoint x` equals `cateptToSelfAdjoint` of
the Lorentz-transformed CATEPT vector.

The Lorentz transformation is expressed via `SL2C.toMatrix M`, which is
related to `SL2C.toLorentzGroup M` by `(SL2C.toLorentzGroup M).1 = SL2C.toMatrix M`.

*Proof*: The goal reduces (by unfolding `cateptToSelfAdjoint` on both sides)
to the purely Physlib fact `SL2C.toMatrix_apply_contrMod`:

    `(SL2C.toMatrix M) *ᵥ v = ContrMod.toSelfAdjoint.symm (SL2C.toSelfAdjointMap M (ContrMod.toSelfAdjoint v))`

Applying `ContrMod.toSelfAdjoint` to both sides gives the intertwining directly.
-/
theorem cateptToSelfAdjoint_intertwines_sl2c (M : SL(2, ℂ)) (x : CATEPTST) :
    SL2C.toSelfAdjointMap M (cateptToSelfAdjoint x) =
    cateptToSelfAdjoint
      (cateptEquivPhyslib.symm (ContrMod.toFin1dℝEquiv
        (SL2C.toMatrix M *ᵥ ⟨cateptEquivPhyslib x⟩))) := by
  -- Helper: cateptToSelfAdjoint ∘ (cateptEquivPhyslib.symm ∘ toFin1dℝEquiv) = ContrMod.toSelfAdjoint
  -- Proof: apply_apply collapses φ⁻¹∘φ; ⟨toFin1dℝEquiv v⟩ = v since toFin1dℝEquiv v = v.val (rfl).
  have key : ∀ (v : ContrMod 3),
      cateptToSelfAdjoint (cateptEquivPhyslib.symm (ContrMod.toFin1dℝEquiv v)) =
      ContrMod.toSelfAdjoint v := fun v => by
    rw [cateptToSelfAdjoint_apply, LinearEquiv.apply_symm_apply]; rfl
  -- Apply key to collapse the RHS first, then unfold the LHS.
  rw [key, cateptToSelfAdjoint_apply]
  -- Goal: toSelfAdjointMap M (toSelfAdjoint ⟨cateptEquivPhyslib x⟩)
  --      = toSelfAdjoint (toMatrix M *ᵥ ⟨cateptEquivPhyslib x⟩)
  -- Use toMatrix_apply_contrMod explicitly to avoid conv_rhs fragility.
  have h := SL2C.toMatrix_apply_contrMod M (⟨cateptEquivPhyslib x⟩ : ContrMod 3)
  change
    SL2C.toSelfAdjointMap M
        (ContrMod.toSelfAdjoint ⟨cateptEquivPhyslib x⟩)
    =
    ContrMod.toSelfAdjoint
        (SL2C.toMatrix M *ᵥ (⟨cateptEquivPhyslib x⟩ : ContrMod 3))
  rw [h]
  rw [LinearEquiv.apply_symm_apply]

end CATEPTMain.Bridges.PhyslibRelativityBridge
