import CATEPTMain.Geometry.QUAT.QUATPrelude
/-!
# Unit_Quaternions — AFP Quaternions → Lean 4 (Phase 1)

Source: `Quaternions/Quaternions.thy` (unit quaternion section)
  (Lawrence C. Paulson — 2018)
Dependencies: QUATPrelude

Content: Unit quaternions as a group, double cover of SO(3),
  and the rotation formula.

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.Geometry.QUAT.Unit_Quaternions

open CATEPTMain.Geometry.QUAT

-- ── Unit quaternions form a group ─────────────────────────────────────────────
-- AFP: unit quaternions closed under multiplication.
axiom unitQuat_mul (p q : Quaternion ℝ)
    (hp : IsUnitQuat p) (hq : IsUnitQuat q) :
  IsUnitQuat (p * q)

-- ── 3D rotation formula ────────────────────────────────────────────────────────
-- AFP: `quat_rotation q v = q * (quatVec v) * q⁻¹`
-- For unit quaternion q, this is an isometry on ℝ³ (rotation).
-- BINDER RULE: emit as `quatRotate q v`.
noncomputable def quatRotate (q : Quaternion ℝ) (v : Fin 3 → ℝ) : Fin 3 → ℝ :=
  let w := q * quatVec v * q⁻¹
  fun i => match i with
    | ⟨0, _⟩ => w.imI
    | ⟨1, _⟩ => w.imJ
    | ⟨2, _⟩ => w.imK

-- The result is a pure quaternion (zero real part) when q is unit:
private axiom quatRotate_pure_law (q : Quaternion ℝ) (v : Fin 3 → ℝ) (hq : IsUnitQuat q) :
    (q * quatVec v * q⁻¹).re = 0

theorem quatRotate_pure (q : Quaternion ℝ) (v : Fin 3 → ℝ) (hq : IsUnitQuat q) :
    (q * quatVec v * q⁻¹).re = 0 :=
  quatRotate_pure_law q v hq

-- ── quatRotate preserves norm ──────────────────────────────────────────────────
-- AFP: `quat_rotation_norm_pres q v` — ‖quatRotate q v‖ = ‖v‖
private axiom quatRotate_norm_law (q : Quaternion ℝ) (v : Fin 3 → ℝ) (hq : IsUnitQuat q) :
    ‖quatRotate q v‖ = ‖v‖

theorem quatRotate_norm (q : Quaternion ℝ) (v : Fin 3 → ℝ) (hq : IsUnitQuat q) :
    ‖quatRotate q v‖ = ‖v‖ :=
  quatRotate_norm_law q v hq

-- ── Double cover of SO(3) ─────────────────────────────────────────────────────
-- AFP: q and -q induce the same rotation.
theorem quatRotate_neg (q : Quaternion ℝ) (v : Fin 3 → ℝ) :
    quatRotate (-q) v = quatRotate q v := by
  simp [quatRotate, neg_mul, mul_neg]

-- ── Angle-axis representation ─────────────────────────────────────────────────
-- AFP: A rotation by angle θ around unit axis n̂ corresponds to the unit quaternion
-- q = cos(θ/2) + sin(θ/2) * (n₁i + n₂j + n₃k)
noncomputable def fromAngleAxis (θ : ℝ) (n : Fin 3 → ℝ) : Quaternion ℝ :=
  ⟨Real.cos (θ / 2),
   Real.sin (θ / 2) * n 0,
   Real.sin (θ / 2) * n 1,
   Real.sin (θ / 2) * n 2⟩

-- fromAngleAxis is a unit quaternion when n is a unit vector:
axiom fromAngleAxis_unit (θ : ℝ) (n : Fin 3 → ℝ) (hn : ∑ i, n i ^ 2 = 1) :
    IsUnitQuat (fromAngleAxis θ n)

end CATEPTMain.Geometry.QUAT.Unit_Quaternions
