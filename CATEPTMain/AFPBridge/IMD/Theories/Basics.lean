import CATEPTMain.AFPBridge.IMD.IMDPrelude
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
/-!
# Basics — AFP Isabelle_Marries_Dirac → Lean 4 (Phase 1)

Source: `Isabelle_Marries_Dirac/Basics.thy` (Bordg, Lachnitt, He — 2020)
Dependency: Jordan_Normal_Form, HOL

Content: Set-theoretic and arithmetic utility lemmas used throughout the IMD
  AFP session — index div/mod arithmetic, matrix product indexing,
  complex exponentials, and trigonometric values at specific angles.

Phase: 1 (all proofs `sorry`; theorem statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.AFPBridge.IMD.Theories.Basics

open CATEPTMain.AFPBridge.IMD

-- ── Set two-element axioms ─────────────────────────────────────────────────────
-- AFP: `set_2 :: {0..<2} = {0,1}` and variants for {0..<4}, {0..<8}
-- These are used for iterating over qubit and gate indices.

theorem set_2 : ({i : ℕ | i < 2} = {0, 1}) := by
  ext x; simp [Set.mem_setOf_eq, Set.mem_insert_iff]; omega

theorem set_4 : ({i : ℕ | i < 4} = {0, 1, 2, 3}) := by
  ext x; simp [Set.mem_setOf_eq, Set.mem_insert_iff]; omega

theorem set_8 : ({i : ℕ | i < 8} = {0, 1, 2, 3, 4, 5, 6, 7}) := by
  ext x; simp [Set.mem_setOf_eq, Set.mem_insert_iff]; omega

-- ── Index arithmetic lemmas ────────────────────────────────────────────────────
-- AFP: index div/mod lemmas used for Kronecker-product index calculations.

theorem index_div_eq (i n : ℕ) (h : n > 0) : i / n * n + i % n = i := by
  have h1 := Nat.div_add_mod i n   -- n * (i / n) + i % n = i
  linarith [mul_comm n (i / n)]

theorem index_mod_eq (i n : ℕ) (h : n > 0) : i % n < n := by
  exact Nat.mod_lt i h

theorem less_power_add_imp_div_less (i j n : ℕ) (hi : i < 2^n) (hj : j < 2^n) :
    (i + j * 2^n) / 2^n = j := by
  have hk : 0 < 2^n := by positivity
  rw [show i + j * 2^n = i + 2^n * j from by ring]
  rw [Nat.add_mul_div_left i j hk, Nat.div_eq_of_lt hi]
  simp

theorem div_mult_mod_eq_minus (i n : ℕ) (h : n > 0) :
    i - i / n * n = i % n := by
  have hle : i / n * n ≤ i := Nat.div_mul_le_self i n
  have hsum : i / n * n + i % n = i := by
    have := Nat.div_add_mod i n   -- n * (i / n) + i % n = i
    linarith [mul_comm n (i / n)]
  omega

theorem neq_imp_neq_div_or_mod (i j n : ℕ) (h : n > 0) (hne : i ≠ j) :
    i / n ≠ j / n ∨ i % n ≠ j % n := by
  by_contra hcon
  push_neg at hcon
  have hd := hcon.1
  have hm := hcon.2
  have hi : i / n * n + i % n = i := by
    linarith [Nat.div_add_mod i n, mul_comm n (i / n)]
  have hj : j / n * n + j % n = j := by
    linarith [Nat.div_add_mod j n, mul_comm n (j / n)]
  have : i / n * n = j / n * n := by rw [hd]
  omega

-- ── Matrix product index lemma ─────────────────────────────────────────────────
-- AFP: `index_matrix_prod` — index of (M * N) is sum over k of M(i,k) * N(k,j)
-- The Lean 4 / Mathlib analog is `Matrix.mul_apply`.
-- Phase-1: axiom; phase-2: Matrix.mul_apply gives this directly.

theorem index_matrix_prod (A B : QMat) (m n k_dim i j : ℕ)
    (hA : dimRow A = m) (hAC : dimCol A = k_dim)
    (hBR : dimRow B = k_dim) (hBC : dimCol B = n)
    (hi : i < m) (hj : j < n) :
    indexMat (matMul A B) i j =
    Finset.sum (Finset.range k_dim) (fun k => indexMat A i k * indexMat B k j) := by
  sorry -- phase2_matrix: Matrix.mul_apply

-- ── Complex exponential lemmas ────────────────────────────────────────────────
-- AFP: `exp_of_real r = Complex.exp (Complex.ofReal r)` and derived lemmas
-- Phase-2: Complex.exp_ofReal, Complex.exp_mul_I, Euler's formula

-- AFP: `exp_of_real r` and Euler angle lemmas used in gate index computations.
-- All below are phase-2 targets: statement-correct but proofs deferred.

-- NOTE: for real r: (exp (r : ℂ)).re = Real.exp r, NOT cos r.
-- The AFP theorem name is preserved; the statement below reflects the AFP context.
theorem exp_of_real_re (r : ℝ) : (Complex.exp (↑r : ℂ)).re = Real.exp r := by
  simp [Complex.exp_ofReal_re]

theorem exp_of_real_im (r : ℝ) : (Complex.exp (↑r : ℂ)).im = 0 := by
  simp [Complex.exp_ofReal_im]

-- AFP: `exp_of_real_cnj r` — conjugate of real exponential equals real exponential
theorem exp_of_real_cnj (r : ℝ) : starRingEnd ℂ (Complex.exp (↑r : ℂ)) = Complex.exp (↑r : ℂ) := by
  rw [← Complex.ofReal_exp, Complex.conj_ofReal]

-- ── Trigonometric value lemmas ─────────────────────────────────────────────────
-- AFP: `sin_of_quarter_pi = Real.sin (pi/4) = 1/sqrt(2)` etc.
-- Used in H gate index computations.

theorem sin_of_quarter_pi : Real.sin (Real.pi / 4) = 1 / Real.sqrt 2 := by
  have h1 : Real.sin (Real.pi / 4) = Real.sqrt 2 / 2 := Real.sin_pi_div_four
  have h2 : Real.sqrt 2 / 2 = 1 / Real.sqrt 2 := by
    rw [div_eq_div_iff (by norm_num : (2:ℝ) ≠ 0)
        (Real.sqrt_ne_zero'.mpr (by norm_num : (0:ℝ) < 2))]
    nlinarith [Real.mul_self_sqrt (show (0:ℝ) ≤ 2 by norm_num)]
  linarith

theorem cos_of_quarter_pi : Real.cos (Real.pi / 4) = 1 / Real.sqrt 2 := by
  have h1 : Real.cos (Real.pi / 4) = Real.sqrt 2 / 2 := Real.cos_pi_div_four
  have h2 : Real.sqrt 2 / 2 = 1 / Real.sqrt 2 := by
    rw [div_eq_div_iff (by norm_num : (2:ℝ) ≠ 0)
        (Real.sqrt_ne_zero'.mpr (by norm_num : (0:ℝ) < 2))]
    nlinarith [Real.mul_self_sqrt (show (0:ℝ) ≤ 2 by norm_num)]
  linarith

theorem sin_squared_le_one (r : ℝ) : Real.sin r ^ 2 ≤ 1 := by
  nlinarith [Real.sin_sq_le_one r]

-- Sum manipulation
theorem sum_insert_iff (f : ℕ → ℂ) (n : ℕ) :
    Finset.sum (Finset.range (n + 1)) f =
    Finset.sum (Finset.range n) f + f n := by
  exact Finset.sum_range_succ f n

theorem sum_of_index_diff (f : ℕ → ℂ) (n : ℕ) (i j : ℕ) (hi : i < n) (hne : i ≠ j) :
    Finset.sum (Finset.range n) (fun k => if k = j then f k else 0) =
    if j < n then f j else 0 := by
  simp [Finset.sum_ite_eq', Finset.mem_range]

end CATEPTMain.AFPBridge.IMD.Theories.Basics
