import Mathlib.Data.Matrix.Basic
import Mathlib.Data.Complex.Basic
import Mathlib.Data.Fin.Tuple.Basic
/-!
# Minkowski Clifford Algebra — Concrete Dirac Representation

Concrete 4×4 complex gamma matrices satisfying `{γ^μ, γ^ν} = 2η^{μν}·1₄`
with signature (+,−,−,−).

These are the Dirac-representation matrices, identical to those in
`Physlib.Relativity.CliffordAlgebra` (Tooby-Smith 2024), reproduced here
to avoid a full Physlib compile dependency.

## CATEPTSpace connection

The input space is `CATEPTST = Fin 4 → ℝ` (from CATEPTSpaceTime).
The Minkowski quadratic form `Q(v) = v₀² − v₁² − v₂² − v₃²` lives on
this type.  The CliffordAlgebra `Cl(Q)` surjects onto `diracAlgebra`
(Physlib, `ofCliffordAlgebra_surjective`); we work with the concrete image.

## References

- mink.txt: Minkowski vacuum |0_M⟩, Unruh effect, CAT/EPT entropic time
  The Dirac algebra is the spinor sector of QFT on Minkowski spacetime.
  CATEPTSpaceTime provides the carrier (`CATEPTST = Fin 4 → ℝ`);
  this file provides the spinor algebra that acts on it.
- Physlib.Relativity.CliffordAlgebra (Tooby-Smith 2024) — same matrices
-/

set_option autoImplicit false
open Complex

namespace CATEPTMain.AFPBridge.FEYNCALC

-- ── Concrete gamma matrices (Dirac representation, +−−− signature) ───────────

/-- γ⁰ in the Dirac representation. Diagonal: diag(1,1,−1,−1).
    Source: Physlib.Relativity.CliffordAlgebra `γ0`. -/
def diracGamma0 : Matrix (Fin 4) (Fin 4) ℂ :=
  !![1, 0, 0, 0; 0, 1, 0, 0; 0, 0, -1, 0; 0, 0, 0, -1]

/-- γ¹ in the Dirac representation.
    Source: Physlib.Relativity.CliffordAlgebra `γ1`. -/
def diracGamma1 : Matrix (Fin 4) (Fin 4) ℂ :=
  !![0, 0, 0, 1; 0, 0, 1, 0; 0, -1, 0, 0; -1, 0, 0, 0]

/-- γ² in the Dirac representation (contains imaginary unit i).
    Source: Physlib.Relativity.CliffordAlgebra `γ2`. -/
def diracGamma2 : Matrix (Fin 4) (Fin 4) ℂ :=
  !![0, 0, 0, -I; 0, 0, I, 0; 0, I, 0, 0; -I, 0, 0, 0]

/-- γ³ in the Dirac representation.
    Source: Physlib.Relativity.CliffordAlgebra `γ3`. -/
def diracGamma3 : Matrix (Fin 4) (Fin 4) ℂ :=
  !![0, 0, 1, 0; 0, 0, 0, -1; -1, 0, 0, 0; 0, 1, 0, 0]

/-- Indexed gamma matrix function: `diracGamma μ` for μ ∈ {0,1,2,3}.
    Source: Physlib.Relativity.CliffordAlgebra `γ`. -/
def diracGamma : Fin 4 → Matrix (Fin 4) (Fin 4) ℂ :=
  ![diracGamma0, diracGamma1, diracGamma2, diracGamma3]

/-- γ⁵ = i γ⁰γ¹γ²γ³ in the Dirac representation.
    Source: Physlib.Relativity.CliffordAlgebra `γ5`. -/
noncomputable def diracGamma5 : Matrix (Fin 4) (Fin 4) ℂ :=
  I • (diracGamma0 * diracGamma1 * diracGamma2 * diracGamma3)

-- ── Helper: identity matrix as explicit !![...] ─────────────────────────────

private theorem mat4_one_eq :
    (1 : Matrix (Fin 4) (Fin 4) ℂ) = !![1, 0, 0, 0; 0, 1, 0, 0; 0, 0, 1, 0; 0, 0, 0, 1] := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [Matrix.one_apply]

-- ── Diagonal products (γ^μ)² ────────────────────────────────────────────────

@[simp] lemma diracGamma0_mul_self : diracGamma0 * diracGamma0 = 1 := by
  simp [diracGamma0, mat4_one_eq]

@[simp] lemma diracGamma1_mul_self : diracGamma1 * diracGamma1 = -1 := by
  simp [diracGamma1, mat4_one_eq]; norm_num

@[simp] lemma diracGamma2_mul_self : diracGamma2 * diracGamma2 = -1 := by
  simp [diracGamma2, mat4_one_eq, I_sq]

@[simp] lemma diracGamma3_mul_self : diracGamma3 * diracGamma3 = -1 := by
  simp [diracGamma3, mat4_one_eq]; norm_num

-- ── Off-diagonal anticommutation: γ^ν γ^μ = −(γ^μ γ^ν) for μ ≠ ν ──────────

@[simp] lemma diracGamma1_mul_diracGamma0 :
    diracGamma1 * diracGamma0 = -(diracGamma0 * diracGamma1) := by
  simp [diracGamma0, diracGamma1]

@[simp] lemma diracGamma2_mul_diracGamma0 :
    diracGamma2 * diracGamma0 = -(diracGamma0 * diracGamma2) := by
  simp [diracGamma0, diracGamma2, I_sq]

@[simp] lemma diracGamma3_mul_diracGamma0 :
    diracGamma3 * diracGamma0 = -(diracGamma0 * diracGamma3) := by
  simp [diracGamma0, diracGamma3]

@[simp] lemma diracGamma2_mul_diracGamma1 :
    diracGamma2 * diracGamma1 = -(diracGamma1 * diracGamma2) := by
  simp [diracGamma1, diracGamma2, I_sq]

@[simp] lemma diracGamma3_mul_diracGamma1 :
    diracGamma3 * diracGamma1 = -(diracGamma1 * diracGamma3) := by
  simp [diracGamma1, diracGamma3]

@[simp] lemma diracGamma3_mul_diracGamma2 :
    diracGamma3 * diracGamma2 = -(diracGamma2 * diracGamma3) := by
  simp [diracGamma2, diracGamma3, I_sq]

-- ── Minkowski metric (local copy matching FCPrelude.eta, +−−− signature) ─────

/-- Minkowski η^{μν}: +1 for μ=ν=0, −1 for μ=ν∈{1,2,3}, 0 otherwise. -/
def minkEta (μ ν : Fin 4) : ℝ :=
  if μ = ν then (if μ.val = 0 then 1 else -1) else 0

-- ── Main theorem: anticommutation relation ───────────────────────────────────

/-- **Clifford anticommutation** for the Dirac gamma matrices:
    `γ^μ γ^ν + γ^ν γ^μ = 2η^{μν} · 1₄`  (signature +−−−).

  This is the defining relation of the Clifford algebra Cl(3,1;ℂ).
  In Physlib, this follows from `CliffordAlgebra.ι_sq_scalar` + polarization
  via `ofCliffordAlgebra_surjective`. Here we verify it concretely. -/
theorem diracGamma_anticommute (μ ν : Fin 4) :
    diracGamma μ * diracGamma ν + diracGamma ν * diracGamma μ =
    (2 * (minkEta μ ν : ℂ)) • (1 : Matrix (Fin 4) (Fin 4) ℂ) := by
  fin_cases μ <;> fin_cases ν <;>
    simp only [diracGamma, Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons,
               Matrix.head_fin_const,
               diracGamma0_mul_self, diracGamma1_mul_self,
               diracGamma2_mul_self, diracGamma3_mul_self,
               diracGamma1_mul_diracGamma0, diracGamma2_mul_diracGamma0,
               diracGamma3_mul_diracGamma0, diracGamma2_mul_diracGamma1,
               diracGamma3_mul_diracGamma1, diracGamma3_mul_diracGamma2,
               minkEta, Fin.val] <;>
    simp only [show (0 : Fin 4).val = 0 from rfl,
               show (1 : Fin 4).val = 1 from rfl,
               show (2 : Fin 4).val = 2 from rfl,
               show (3 : Fin 4).val = 3 from rfl,
               if_true, if_false, ↓reduceIte] <;>
    norm_num [Matrix.smul_apply, Matrix.one_apply] <;>
    ring

-- ── γ⁵ properties ─────────────────────────────────────────────────────────

/-- `(γ⁵)² = 1₄` — follows from γ⁵ = iγ⁰γ¹γ²γ³ + Clifford relations. -/
theorem diracGamma5_sq : diracGamma5 * diracGamma5 = 1 := by
  simp only [diracGamma5, Matrix.smul_mul, Matrix.mul_smul, ← mul_smul_comm, smul_smul]
  norm_num [I_sq, diracGamma0, diracGamma1, diracGamma2, diracGamma3, mat4_one_eq, I_sq]

/-- γ⁵ anticommutes with each γ^μ: `γ⁵γ^μ + γ^μγ⁵ = 0`. -/
theorem diracGamma5_anticommute (μ : Fin 4) :
    diracGamma5 * diracGamma μ + diracGamma μ * diracGamma5 = 0 := by
  fin_cases μ <;>
    simp [diracGamma5, diracGamma, diracGamma0, diracGamma1,
          diracGamma2, diracGamma3, I_sq, mul_comm I (-I)] <;>
    ext i j <;> fin_cases i <;> fin_cases j <;>
    simp [Matrix.smul_apply, Matrix.mul_apply, Fin.sum_univ_four,
          Matrix.add_apply] <;>
    ring

end CATEPTMain.AFPBridge.FEYNCALC
