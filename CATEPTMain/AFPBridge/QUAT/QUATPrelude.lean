import CATEPTMain.AFPBridge.Framework.AFPBridgeFramework
import Mathlib.Algebra.Quaternion
import Mathlib.Analysis.Quaternion
/-!
# QUAT Prelude — Quaternions (AFP) → Lean 4

Phase-1 scaffold for `Quaternions` (Lawrence C. Paulson — 2018).
https://www.isa-afp.org/entries/Quaternions.html

AFP dependencies bridged here:
  HOL-Analysis → Mathlib.Analysis.Quaternion

CRITICAL TYPE NOTE:
  AFP `quat` → `Quaternion ℝ` (direct Mathlib type — available in scope).
  All basic algebra (ring, division ring, inner product, norm) is proved
  in Mathlib. This prelude is thus thinner than most: it mostly provides
  AFP-compatible notation and the rotation-related types.

BINDER RULES:
  B80: `(q : quat)` → `(q : Quaternion ℝ)`
  B81: `cnj q` → `star q` (StarRing instance)
  B82: unit quaternion `‖q‖ = 1`
  B83: 3D pure quaternion injection: `quatVec v = ⟨0, v 0, v 1, v 2⟩`

Phase-2 upgrade path:
  Most proofs here are already available in Mathlib. Rotation section
  (unit quaternions → SO(3)) may need additional Mathlib imports.

See: CATEPTMain/AFPBridge/QUAT/QUAT_WORKLOG.lean
-/

set_option autoImplicit false

open CATEPTMain.AFPBridgeFramework.TacticStubs

namespace CATEPTMain.AFPBridge.QUAT

-- ── Quaternion algebra (direct Mathlib) ───────────────────────────────────────
-- AFP `quat` → Lean 4: `Quaternion ℝ`
-- BINDER RULE B80: always emit as `Quaternion ℝ` (concrete Mathlib type).
-- All ring/field axioms come from Mathlib instances.

-- Concrete scalar parts:
def quatRe (q : Quaternion ℝ) : ℝ := q.re
def quatImI (q : Quaternion ℝ) : ℝ := q.imI
def quatImJ (q : Quaternion ℝ) : ℝ := q.imJ
def quatImK (q : Quaternion ℝ) : ℝ := q.imK

-- ── Pure quaternion (3D vector injection) ─────────────────────────────────────
-- AFP: A 3D vector v = (v₁, v₂, v₃) embeds as the pure quaternion v₁i + v₂j + v₃k.
-- BINDER RULE B83: emit as `quatVec v` (0 real part).
def quatVec (v : Fin 3 → ℝ) : Quaternion ℝ :=
  ⟨0, v 0, v 1, v 2⟩

-- quatVec has zero real part:
@[simp] theorem quatVec_re (v : Fin 3 → ℝ) : (quatVec v).re = 0 := rfl

-- ── Conjugate = star ──────────────────────────────────────────────────────────
-- AFP: `cnj q = a - bi - cj - dk`  (quaternion conjugate)
-- BINDER RULE B81: emit as `star q` (Star ring instance).
-- Mathlib: `Quaternion.star_def` is already proved.
axiom quat_conj_def (q : Quaternion ℝ) :
  star q = ⟨q.re, -q.imI, -q.imJ, -q.imK⟩

-- ── Norm squared = q * conj q ─────────────────────────────────────────────────
-- AFP: `norm_sq q = q.re² + q.imI² + q.imJ² + q.imK² = re(q * cnj q)`
-- Mathlib: `Quaternion.normSq_def` (proved by rfl)
theorem quat_normSq_eq_mul_conj (q : Quaternion ℝ) :
    Quaternion.normSq q = (q * star q).re := rfl

-- ── Unit quaternion ───────────────────────────────────────────────────────────
-- AFP: `unit_quat q` ↔ q * cnj q = 1 ↔ ‖q‖ = 1
-- BINDER RULE B82: emit as `(h : ‖q‖ = 1)`.
def IsUnitQuat (q : Quaternion ℝ) : Prop := ‖q‖ = 1

axiom isUnitQuat_iff_normSq (q : Quaternion ℝ) :
  IsUnitQuat q ↔ Quaternion.normSq q = 1

-- ── Inverse of unit quaternion = conjugate ────────────────────────────────────
-- AFP: for unit q, q⁻¹ = cnj q
axiom unitQuat_inv_eq_conj (q : Quaternion ℝ) (h : IsUnitQuat q) :
  q⁻¹ = star q

-- ── i, j, k basis elements ────────────────────────────────────────────────────
-- AFP: `quat_i`, `quat_j`, `quat_k`
def quatI : Quaternion ℝ := ⟨0, 1, 0, 0⟩
def quatJ : Quaternion ℝ := ⟨0, 0, 1, 0⟩
def quatK : Quaternion ℝ := ⟨0, 0, 0, 1⟩

-- i² = j² = k² = ijk = -1  (proved by component-wise computation via Mathlib simp lemmas)

@[simp] theorem quatI_sq : quatI * quatI = (-1 : Quaternion ℝ) := by
  apply Quaternion.ext <;>
    simp [quatI, Quaternion.re_one, Quaternion.imI_one, Quaternion.imJ_one, Quaternion.imK_one]

@[simp] theorem quatJ_sq : quatJ * quatJ = (-1 : Quaternion ℝ) := by
  apply Quaternion.ext <;>
    simp [quatJ, Quaternion.re_one, Quaternion.imI_one, Quaternion.imJ_one, Quaternion.imK_one]

@[simp] theorem quatK_sq : quatK * quatK = (-1 : Quaternion ℝ) := by
  apply Quaternion.ext <;>
    simp [quatK, Quaternion.re_one, Quaternion.imI_one, Quaternion.imJ_one, Quaternion.imK_one]

theorem quatI_mul_J : quatI * quatJ = (quatK : Quaternion ℝ) := by
  apply Quaternion.ext <;> simp [quatI, quatJ, quatK]

theorem quatJ_mul_K : quatJ * quatK = (quatI : Quaternion ℝ) := by
  apply Quaternion.ext <;> simp [quatJ, quatK, quatI]

theorem quatK_mul_I : quatK * quatI = (quatJ : Quaternion ℝ) := by
  apply Quaternion.ext <;> simp [quatK, quatI, quatJ]

end CATEPTMain.AFPBridge.QUAT
