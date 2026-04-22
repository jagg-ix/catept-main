import CATEPTMain.AFPBridge.QuantumOps.IsabelleMarresDirac.Definitions
import CATEPTMain.AFPBridge.QuantumOps.ProjectiveMeasurements.ProjMeasSubset01

/-!
# AFP Hammer Demo — What afp_hammer can and cannot close

This file demonstrates manually which AFP needs_human stubs are closeable
by the afp_hammer backends (omega / decide / auto+LemDB / smt / tptp),
and which require manual proof. The actual `afp_hammer` tactic is in
AFPHammer.lean (requires lean-auto dep to be activated first).

Once lean-auto is in the manifest, replace `by <proof>` below with
`by afp_hammer` or `by afp_hammer_with afp_X_db` to verify automation.

## Status key
  ✓ auto:omega      — closeable by omega after simp
  ✓ auto:decide     — closeable by decide
  ✓ auto:star_proj  — closeable by auto + afp_star_proj_db
  ✓ auto:norm       — closeable by auto + afp_norm_db
  ✗ manual:oracle   — requires dependent type construction
  ✗ manual:circuit  — requires circuit induction tower
-/

set_option autoImplicit false

open CATEPTMain.AFPBridge.QuantumOps.IsabelleMarresDirac
open IMD

namespace CATEPTMain.AFPBridge.Hammer.Demo

-- ── ✓ auto:omega — Finset arithmetic (AFP Deutsch_Jozsa) ─────────────────────

-- AFP: is_balanced_union cardinality — closeable by omega after simp
-- When lean-auto active: `afp_hammer_with afp_finset_db`
theorem demo_balanced_card (n : ℕ) :
    2 ^ (n - 1) + 2 ^ (n - 1) = 2 ^ n ∨ n = 0 := by
  cases n with
  | zero => right; rfl
  | succ n => left; simp [Nat.succ_sub_one]; ring

-- AFP: is_balanced_inter — omega after linarith
-- When lean-auto active: `afp_hammer`
theorem demo_balanced_inter (A B : Finset ℕ) (f : ℕ → ℕ)
    (hA : ∀ x ∈ A, f x = 0) (hB : ∀ x ∈ B, f x = 1) :
    A ∩ B = ∅ := by
  ext x; simp only [Finset.mem_inter, Finset.not_mem_empty, iff_false, not_and]
  intro hxA hxB; linarith [hA x hxA, hB x hxB]

-- AFP: exp_j arithmetic core — omega
-- When lean-auto active: `afp_hammer`
theorem demo_exp_j_arith (j n : ℕ) :
    j % 2 ^ n + 2 ^ n * (j / 2 ^ n) = j := Nat.mod_add_div j (2 ^ n)

-- ── ✓ auto:star_proj — IsStarProjection (AFP ProjMeas) ───────────────────────

-- AFP: is_proj_idempotent — auto finds isIdempotentElem.eq
-- When lean-auto active: `afp_hammer_with afp_star_proj_db`
theorem demo_star_idem {R : Type*} [Mul R] [Star R] {P : R}
    (hP : IsStarProjection P) : P * P = P :=
  hP.isIdempotentElem.eq

-- AFP: is_proj_compl — auto finds one_sub
-- When lean-auto active: `afp_hammer_with afp_star_proj_db`
theorem demo_star_compl {R : Type*} [NonAssocRing R] [StarRing R] {P : R}
    (hP : IsStarProjection P) : IsStarProjection (1 - P) :=
  hP.one_sub

-- AFP: is_proj_mul_compl_zero — auto finds mul_one_sub_self
-- When lean-auto active: `afp_hammer_with afp_star_proj_db`
theorem demo_star_mul_compl {R : Type*} [NonAssocRing R] [Star R] {P : R}
    (hP : IsStarProjection P) : P * (1 - P) = 0 :=
  hP.mul_one_sub_self

-- ── ✓ auto:norm — Born-rule norm bounds (AFP ProjMeas) ───────────────────────

-- AFP: born_rule_nonneg — sq_nonneg is direct
-- When lean-auto active: `afp_hammer`
theorem demo_born_nonneg {E : Type*} [SeminormedAddCommGroup E]
    {P : E → E} (ψ : E) : 0 ≤ ‖P ψ‖ ^ 2 := sq_nonneg _

-- ── ✓ afp_fin_hammer — fixed-dim matrix entry (AFP IMD, QFT) ─────────────────

-- AFP: H_on_ket_zero, H_on_ket_one — already proved in Subset02 by:
--   simp [IMD.H_gate, IMD.ket_zero, IMD.ket_one]
-- This is the afp_fin_hammer pattern: ext + fin_cases + simp + ring
-- When lean-auto active: `afp_fin_hammer` (always faster than ATP for this)
theorem demo_H_mul_entry : IMD.H_gate 0 0 = (Real.sqrt 2 : ℂ)⁻¹ := by
  simp [IMD.H_gate]

-- ── ✗ manual:oracle — Oracle U_f cannot be produced by ATP ───────────────────

-- AFP: Deutsch_Jozsa oracle U_f — requires:
--   Matrix (Fin (2^n)) (Fin (2^n)) ℂ := Matrix.of fun i j => ...
-- where the Boolean function f : Fin (2^n) → Bool determines entries.
-- ATPs (cvc5, Zipperposition, Duper) cannot construct this: it requires
-- a dependent Fin arithmetic construction that is outside HOL encoding.
--
-- Manual approach (sketched):
--   def deutschOracleMatrix (n : ℕ) (f : Fin (2^n) → Fin 2) :
--       Matrix (Fin (2^(n+1))) (Fin (2^(n+1))) ℂ :=
--     Matrix.of fun i j =>
--       let x := i.val / 2  -- top n qubits (input)
--       let y := i.val % 2  -- bottom qubit (output)
--       let y' := (y + (f ⟨x, ...⟩).val) % 2  -- XOR with f(x)
--       if j.val = x * 2 + y' then 1 else 0

-- ── ✗ manual:circuit — QFT circuit recursion cannot be done by ATP ────────────

-- AFP: QFT_is_correct — requires:
--   induction on n with:
--     controlled_rotations_on_first_qubit lemma
--     SWAP_down_kron lemma
--     reverse_qubits_kron lemma
-- This is a multi-step induction tower — ATP has no induction strategy.
-- lean-auto's monomorphization handles parametric polymorphism but not
-- structural induction over circuit depth.

end CATEPTMain.AFPBridge.Hammer.Demo
