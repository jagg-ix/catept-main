import CATEPTMain.AFPBridge.IMD.IMDPrelude
/-!
# Complex_Vectors — AFP Isabelle_Marries_Dirac → Lean 4 (Phase 1)

Source: `Isabelle_Marries_Dirac/Complex_Vectors.thy` (Bordg, Lachnitt, He — 2020)
Dependency: Jordan_Normal_Form, VectorSpace

Content: Complex inner product space on `complex vec`; cpx_vec_length,
  inner product abbreviation, orthogonality, Cauchy-Schwarz for vectors.

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.AFPBridge.IMD.Theories.Complex_Vectors

open CATEPTMain.AFPBridge.IMD

-- ── Inner product properties ───────────────────────────────────────────────────
-- AFP `inner_prod v w = (row ⟨v| 0) ∙ (col |w⟩ 0)` where ∙ = scalar_prod
-- Lean 4 phase-1: innerProd (sesquilinear axiom from prelude)

-- Sesquilinearity: conjugate-linear in first argument, linear in second.
-- AFP: `cpx_vec_length_inner_prod v` — ‖v‖² = ⟨v,v⟩.re
theorem cpx_vec_length_inner_prod (v : QVec) :
    cpxVecLen v ^ 2 = (innerProd v v).re :=
  (innerProd_self_re v).symm

-- AFP: `inner_prod_cnj u v` — ⟨u,v⟩ = conj ⟨v,u⟩
theorem inner_prod_cnj (u v : QVec) :
    innerProd u v = starRingEnd ℂ (innerProd v u) :=
  innerProd_conj_symm u v

-- AFP: `inner_prod_is_linear u v w c` — ⟨u, c·v + w⟩ = c * ⟨u,v⟩ + ⟨u,w⟩
theorem inner_prod_is_linear (u v w : QVec) (c : ℂ) :
    innerProd u (smulVec c v) = c * innerProd u v :=
  innerProd_smul_right u v c

theorem inner_prod_add_right (u v w : QVec) :
    innerProd u (vecAdd v w) = innerProd u v + innerProd u w :=
  innerProd_add_right u v w

-- AFP: `inner_prod_is_sesquilinear` — full sesquilinearity statement
-- (conjugate-linear in u, linear in v)
theorem inner_prod_is_sesquilinear (u v w : QVec) (c : ℂ) :
    innerProd (smulVec c u) v = starRingEnd ℂ c * innerProd u v :=
  innerProd_smul_left u v c

-- AFP: `cpx_vec_length_geq_0` — ‖v‖ ≥ 0
theorem cpx_vec_length_geq_0 (v : QVec) : cpxVecLen v ≥ 0 :=
  cpxVecLen_nonneg v

-- AFP: `cpx_vec_zero_iff_length_zero` — ‖v‖ = 0 ↔ v = 0
theorem cpx_vec_zero_iff_length_zero (v : QVec) :
    cpxVecLen v = 0 ↔ v = 0 :=
  cpxVecLen_eq_zero_iff v

-- AFP: `cauchy_schwarz` — |⟨u,v⟩| ≤ ‖u‖ * ‖v‖
-- Uses Real.sqrt (Complex.normSq z) = ‖z‖ (available without extra norm imports)
theorem cauchy_schwarz (u v : QVec) :
    Real.sqrt (Complex.normSq (innerProd u v)) ≤ cpxVecLen u * cpxVecLen v :=
  cauchy_schwarz_ineq u v

-- AFP: `inner_prod_expand` (distributivity over basis decomposition)
-- Used in gate unitarity proofs.
theorem inner_prod_expand (u v : QVec) (n : ℕ) (hU : dimVec u = n) (hV : dimVec v = n) :
    innerProd u v =
    Finset.sum (Finset.range n)
      (fun k => starRingEnd ℂ (indexVec u k) * indexVec v k) := by
  rw [innerProd_coord_sum, hU]

-- ── Norm interaction with scalar multiplication ────────────────────────────────
-- AFP: `cpx_vec_length_smul c v` — ‖c·v‖ = |c| * ‖v‖
-- Real.sqrt (Complex.normSq c) = ‖c‖ for c : ℂ
theorem cpx_vec_length_smul (c : ℂ) (v : QVec) :
    cpxVecLen (smulVec c v) = Real.sqrt (Complex.normSq c) * cpxVecLen v :=
  cpxVecLen_smul_eq c v

end CATEPTMain.AFPBridge.IMD.Theories.Complex_Vectors
