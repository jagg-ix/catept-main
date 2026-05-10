import CATEPTMain.Geometry.FiniteMinkowski
import Physlib.SpaceAndTime.SpaceTime.Basic
import Physlib.Relativity.Tensors.RealTensor.Vector.Pre.Basic
import Physlib.Relativity.Tensors.RealTensor.Vector.MinkowskiProduct
import Physlib.Relativity.Tensors.RealTensor.Vector.Causality.TimeLike

/-!
# Bridge: CATEPT FiniteMinkowski ↔ Physlib SpaceTime

Establishes the concrete linear isomorphism between CATEPT's `CATEPTST`
(`Fin 4 → ℝ`, signature `−+++`) and Physlib's `SpaceTime 3`
(`Fin 1 ⊕ Fin 3 → ℝ`, signature `+−−−`), and proves the following non-trivial
bridging results:

- `cateptEquivPhyslib_time` / `_spatial` — coordinate extraction lemmas proved
  by unfolding `finSumFinEquiv`.
- `minkowskiNorm2_eq_neg_physlib` — the two metrics differ by an overall sign,
  proved by `Fin.sum_univ_three` expansion and `ring`.
- `causalTimelike_iff_physlib_timeLike` — causality predicates agree across the
  bridge (CATEPT `CausalTimelike` ↔ Physlib `timeLike`).
- `insideLightcone_iff_physlib_timeLike` — corollary for lightcone containment.
-/

open CATEPTMain.Geometry.FiniteMinkowski
open Lorentz Vector

namespace CATEPTMain.Bridges.PhyslibRelativityBridge

/-- Index-type equivalence: reindexes `Fin 4` to `Fin 1 ⊕ Fin 3`, where
`inl 0` is the time index and `inr 0..2` are the spatial indices. -/
def fin4EquivFin1SumFin3 : Fin 4 ≃ Fin 1 ⊕ Fin 3 :=
  Equiv.symm finSumFinEquiv

/-- Linear isomorphism from CATEPT's `CATEPTST` to Physlib's `SpaceTime 3`,
reindexing along `fin4EquivFin1SumFin3` while preserving all arithmetic. -/
noncomputable def cateptEquivPhyslib : CATEPTST ≃ₗ[ℝ] SpaceTime 3 where
  toFun x := fun i => x (fin4EquivFin1SumFin3.symm i)
  invFun y := fun i => y (fin4EquivFin1SumFin3 i)
  left_inv x := by ext i; simp [fin4EquivFin1SumFin3]
  right_inv y := by funext i; simp [fin4EquivFin1SumFin3]
  map_add' x y := by funext i; simp
  map_smul' c x := by funext i; simp

/-! ## Coordinate extraction lemmas -/

/-- The time component of `cateptEquivPhyslib x` equals `x 0`. -/
@[simp]
lemma cateptEquivPhyslib_time (x : CATEPTST) :
    cateptEquivPhyslib x (Sum.inl (0 : Fin 1)) = x 0 := by
  change x (fin4EquivFin1SumFin3.symm (Sum.inl (0 : Fin 1))) = x (0 : Fin 4)
  -- fin4EquivFin1SumFin3.symm (Sum.inl 0) = Fin.castAdd 3 0 = 0 : Fin 4 definitionally;
  -- congr 1 closes the goal via finSumFinEquiv_apply_left (which is rfl-tagged @[simp]).
  congr 1

/-- The `i`-th spatial component of `cateptEquivPhyslib x` equals `x i.succ`. -/
@[simp]
lemma cateptEquivPhyslib_spatial (x : CATEPTST) (i : Fin 3) :
    cateptEquivPhyslib x (Sum.inr i) = x i.succ := by
  change x (fin4EquivFin1SumFin3.symm (Sum.inr i)) = x i.succ
  congr 1
  -- goal: fin4EquivFin1SumFin3.symm (Sum.inr i) = i.succ : Fin 4
  -- fin4EquivFin1SumFin3.symm = finSumFinEquiv definitionally
  change (finSumFinEquiv : Fin 1 ⊕ Fin 3 ≃ Fin 4) (Sum.inr i) = i.succ
  rw [finSumFinEquiv_apply_right]
  -- goal: Fin.natAdd 1 i = i.succ
  apply Fin.ext; simp [Fin.natAdd, Fin.val_succ]; omega

/-! ## Metric compatibility -/

/-- **Core bridge theorem**: CATEPT's `(−+++)` metric is the exact negation of
Physlib's `(+−−−)` Minkowski product.  Proof by `Fin.sum_univ_three` and `ring`. -/
theorem minkowskiNorm2_eq_neg_physlib (x : CATEPTST) :
    minkowskiNorm2 x =
    - minkowskiProductMap (cateptEquivPhyslib x) (cateptEquivPhyslib x) := by
  simp only [minkowskiProductMap_toCoord,
             cateptEquivPhyslib_spatial,
             minkowskiNorm2, spatialNorm2, Fin.sum_univ_three]
  have htime : cateptEquivPhyslib x (Sum.inl (0 : Fin 1)) = x 0 := cateptEquivPhyslib_time x
  rw [htime]
  ring

/-- **Causality correspondence**: CATEPT `CausalTimelike` ↔ Physlib `.timeLike`.  -/
theorem causalTimelike_iff_physlib_timeLike (x : CATEPTST) :
    CausalTimelike x ↔ causalCharacter (cateptEquivPhyslib x) = .timeLike := by
  rw [timeLike_iff_norm_sq_pos, minkowskiProduct_apply, CausalTimelike]
  constructor
  · intro h; linarith [minkowskiNorm2_eq_neg_physlib x]
  · intro h; linarith [minkowskiNorm2_eq_neg_physlib x]

/-- Corollary: `InsideLightcone` corresponds to the Physlib timelike predicate on
the translated displacement vector. -/
theorem insideLightcone_iff_physlib_timeLike (x y : CATEPTST) :
    InsideLightcone x y ↔
    causalCharacter (cateptEquivPhyslib y - cateptEquivPhyslib x) = .timeLike := by
  rw [InsideLightcone, causalTimelike_iff_physlib_timeLike (y - x)]
  simp [map_sub]
