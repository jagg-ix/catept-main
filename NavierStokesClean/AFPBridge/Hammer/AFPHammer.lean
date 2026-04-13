/-!
# AFP Bridge Hammer — Sledgehammer-like tactic for AFP faithful port

## Current activation state

`lean-auto` and `cvc5` packages are physically present in `.lake/packages/` but
are **not** in the lake manifest (they are orphaned — no direct or transitive
`require` reaches them in the current dep chain at toolchain v4.26.0).

To activate this file, choose one of:

**Option A — toolchain upgrade (recommended)**
```
lean-toolchain: leanprover/lean4:v4.27.0
```
Then uncomment the three `require` blocks in `lakefile.lean` and run `lake update`.
Re-pin `PhysLean`, `MaxwellWave`, and `mathlib` to v4.27.0-compatible commits.

**Option B — v4.26.0 direct pins**
The packages are already cached at v4.26.0-compatible commits:
- lean-auto: `leanprover-community/lean-auto` @ `6e66058` (toolchain = v4.26.0 ✓)
- cvc5:      `abdoo8080/lean-cvc5`            @ `0cfacc8` (toolchain = v4.26.0 ✓)
- Duper:     find commit with `lean-toolchain = leanprover/lean4:v4.26.0`
Uncomment the three `require` blocks in `lakefile.lean` and run `lake update`.

## Architecture

```
AFP needs_human goal
       │
   afp_hammer
       │
  ┌────┴──────────────────────────────────────────────────────────────────┐
  │ Fast path (no ATP): omega / decide / norm_num / simp_all              │
  ├───────────────────────────────────────────────────────────────────────┤
  │ lean-auto orchestration (CIC → HOL monomorphization)                  │
  │   Input: goal + LemDB premises                                        │
  │   CIC: full Lean4 dependent/universe-polymorphic types                │
  │   HOL: classical higher-order logic (deep-embedded, with checker)     │
  │                                                                       │
  │   Native backend → Duper (HOL superposition prover, Lean-native)      │
  │   │  Full Lean proof term, no axioms (requires Duper dep)             │
  │   │  This is the "reconstruction" path                                │
  │   │                                                                   │
  │   SMT backend → cvc5 (linear/NL arith + uninterp functions)           │
  │   │  Closes with autoSMTSorry (trust mode) or via cvc5 LFSC proofs   │
  │   │  (LFSC reconstruction is experimental in lean-auto)               │
  │   │                                                                   │
  │   TPTP backend → Zipperposition (portfolio HOL solver)                │
  │      Closes with autoTPTPSorry (trust mode)                           │
  └───────────────────────────────────────────────────────────────────────┘
```

## lean-auto as "LeanHammer" / EvaluateAuto

The `Auto.EvaluateAuto.TestAuto` module implements the sledgehammer batch workflow:

```lean
-- Run the ATP on a specific theorem, selecting premises from its proof deps
runProverOnAutoLemma : Auto.Lemma → (Array Lemma → Array Lemma → MetaM Expr) → CoreM Result

-- Batch: sweep all theorems in an environment matching a name filter
EvalAuto.evalAutoOnConsts : Array Name → EvalAutoConfig → IO Unit
```

This is exactly Isabelle Sledgehammer's workflow:
  1. Collect the theorem's proof obligations as premise candidates
  2. Run premise selection (via LemDB or auto-collected from local context)
  3. Submit to backend ATP (cvc5 / Zipperposition / Duper)
  4. On success: close goal (with reconstruction if Duper is available)

## Backends and reconstruction

| Backend              | Proof term    | Domain                        |
|----------------------|---------------|-------------------------------|
| `omega`              | full (Lean)   | LIA: linear integer arith     |
| `decide`             | full (Lean)   | decidable Prop (finite types) |
| `norm_num`           | full (Lean)   | numeric normalization         |
| lean-auto native     | full (Lean)   | HOL via Duper (requires dep)  |
| lean-auto SMT (cvc5) | autoSMTSorry  | LRA/NIA/UF via cvc5           |
| lean-auto TPTP (Zip) | autoTPTPSorry | HOL via Zipperposition        |

`autoSMTSorry`/`autoTPTPSorry` are axioms — valid for exploring which goals
the ATP can decide, but must be replaced by Duper proofs for soundness.

## Adding Duper for reconstruction

Once Duper is available, wire it as lean-auto's native backend:

```lean
import Duper.Tactic

open Lean Auto in
def Auto.duperBridge
    (lemmas : Array Lemma) (_ : Array Lemma) : MetaM Expr := do
  let lems ← lemmas.mapM fun ⟨⟨proof, ty, _⟩, _⟩ =>
    return (ty, ← Meta.mkAppM ``eq_true #[proof], #[], true)
  Duper.runDuper lems.toList 0

attribute [rebind Auto.Native.solverFunc] Auto.duperBridge
```

After this, `set_option auto.native true` in any lean-auto call will use Duper
for full HOL superposition with Lean proof terms (no sorry, no axioms).

## Premise databases (LemDB)

When lean-auto is activated, these LemDB declarations provide curated premise
pools for AFP-domain goals. Declare via `#declare_lemdb` + `attribute [lemdb ...]`.

### afp_star_proj_db — star projections (ProjMeas, CHSH)
  IsStarProjection.{isIdempotentElem, isSelfAdjoint, zero, one, one_sub, mul_one_sub_self}
  ContinuousLinearMap.{isSelfAdjoint_iff', adjoint_adjoint, apply_norm_sq_eq_inner_adjoint_left}
  isStarProjection_iff_eq_starProjection_range
  Submodule.norm_starProjection_apply_le

### afp_matrix_db — matrix operations (IMD, QFT)
  Matrix.{mul_apply, transpose_apply, conjTranspose_apply, kroneckerProduct_apply,
          mem_unitaryGroup_iff, single_apply, cons_val_zero, cons_val_one,
          head_cons, head_fin_const}
  Fin.{sum_univ_two, sum_univ_four}, Finset.univ_fin2

### afp_norm_db — inner product / Born rule (ProjMeas)
  norm_sq_eq_re_inner, inner_self_eq_norm_sq_to_K, sq_nonneg, norm_nonneg
  inner_add_left, inner_sum_left, RCLike.re_to_complex, sum_inner

### afp_finset_db — Finset arithmetic (Deutsch, DJ)
  Finset.{card_range, card_union_of_disjoint, disjoint_iff_inter_eq_empty, mem_Ico}
  List.mem_reverse, Nat.{div_add_mod, mod_add_div}

### afp_complex_db — complex exponential (QFT)
  Complex.{exp_add, exp_mul_I, exp_eq_exp_iff_exists_int, normSq_apply, normSq_mul,
           normSq_one, normSq_zero, ofReal_re, ofReal_im}
  Real.pi_pos

## Tactics (requires lean-auto dep — see activation above)

Once lean-auto is in the manifest, import this file and use:

  `afp_hammer`                — multi-backend: omega→decide→auto+LemDB→SMT→TPTP
  `afp_hammer_with afp_X_db`  — domain-focused: use specific LemDB as premise pool
  `afp_fin_hammer`            — matrix entry goals: fin_cases+simp+ring (fast)

## Which AFP needs_human stubs afp_hammer can close

| Category                           | Backend          | Count |
|------------------------------------|------------------|-------|
| Finset arithmetic (DJ balanced_*)  | omega/decide     | ~8    |
| Star-proj algebra (ProjMeas)       | auto+star_proj   | ~4    |
| Born-rule norm goals               | auto+norm        | ~3    |
| Complex exp phase (QFT exp_j)      | auto+complex     | ~2    |
| **Total closeable by ATP**         |                  | **~17** |
| Oracle U_f construction            | cannot (dep type) | —    |
| QFT circuit mutual recursion       | cannot (inductn)  | —    |
| Teleportation protocol             | cannot (Bell)     | —    |
| **Total needs manual proof**       |                  | **~161** |

The remaining ~161 are oracle/circuit/teleportation theorems that require
custom Fin-indexed constructions, circuit induction towers, or Bell state
infrastructure — none of which are in the ATP's capability envelope.
-/

-- This file is currently a design document + activation guide.
-- Uncomment the imports and declarations below after activating lean-auto (see above).

-- ── Activation block (uncomment after `lake update` adds lean-auto) ──────────
-- import Auto.Tactic
-- -- optionally after Duper is added:
-- -- import Duper.Tactic
-- -- open Lean Auto in
-- -- def Auto.duperBridge (lemmas : Array Lemma) (_ : Array Lemma) : MetaM Expr := do
-- --   let lems ← lemmas.mapM fun ⟨⟨proof, ty, _⟩, _⟩ =>
-- --     return (ty, ← Meta.mkAppM ``eq_true #[proof], #[], true)
-- --   Duper.runDuper lems.toList 0
-- -- attribute [rebind Auto.Native.solverFunc] Auto.duperBridge
-- ─────────────────────────────────────────────────────────────────────────────

-- ── LemDB declarations (uncomment with import Auto.Tactic) ──────────────────
-- open Lean Auto
--
-- #declare_lemdb afp_star_proj_db
-- attribute [lemdb afp_star_proj_db]
--   IsStarProjection.isIdempotentElem IsStarProjection.isSelfAdjoint
--   IsStarProjection.zero IsStarProjection.one IsStarProjection.one_sub
--   IsStarProjection.mul_one_sub_self isStarProjection_iff_eq_starProjection_range
--   IsIdempotentElem.eq IsSelfAdjoint.adjoint_eq
--   ContinuousLinearMap.isSelfAdjoint_iff' ContinuousLinearMap.adjoint_adjoint
--   Submodule.norm_starProjection_apply_le
--   ContinuousLinearMap.apply_norm_sq_eq_inner_adjoint_left
--
-- #declare_lemdb afp_matrix_db
-- attribute [lemdb afp_matrix_db]
--   Matrix.mul_apply Matrix.transpose_apply Matrix.conjTranspose_apply
--   Matrix.kroneckerProduct_apply Matrix.mem_unitaryGroup_iff Matrix.single_apply
--   Fin.sum_univ_two Fin.sum_univ_four Finset.univ_fin2
--   Matrix.cons_val_zero Matrix.cons_val_one Matrix.head_cons Matrix.head_fin_const
--
-- #declare_lemdb afp_norm_db
-- attribute [lemdb afp_norm_db]
--   norm_sq_eq_re_inner inner_self_eq_norm_sq_to_K sq_nonneg norm_nonneg
--   inner_add_left inner_sum_left RCLike.re_to_complex sum_inner
--
-- #declare_lemdb afp_finset_db
-- attribute [lemdb afp_finset_db]
--   Finset.card_range Finset.card_union_of_disjoint Finset.disjoint_iff_inter_eq_empty
--   Finset.mem_Ico List.mem_reverse Nat.div_add_mod Nat.mod_add_div
--
-- #declare_lemdb afp_complex_db
-- attribute [lemdb afp_complex_db]
--   Complex.exp_add Complex.exp_mul_I Complex.exp_eq_exp_iff_exists_int
--   Complex.normSq_apply Complex.normSq_mul Complex.normSq_one Complex.normSq_zero
--   Complex.ofReal_re Complex.ofReal_im Real.pi_pos
--
-- #declare_lemdb afp_all_db
-- attribute [lemdb afp_all_db]
--   IsStarProjection.isIdempotentElem IsStarProjection.isSelfAdjoint
--   IsStarProjection.zero IsStarProjection.one IsStarProjection.one_sub
--   IsStarProjection.mul_one_sub_self ContinuousLinearMap.isSelfAdjoint_iff'
--   Submodule.norm_starProjection_apply_le
--   ContinuousLinearMap.apply_norm_sq_eq_inner_adjoint_left
--   Matrix.mul_apply Matrix.conjTranspose_apply Matrix.mem_unitaryGroup_iff
--   Fin.sum_univ_two Fin.sum_univ_four norm_sq_eq_re_inner inner_sum_left sq_nonneg
--   Finset.card_range Finset.card_union_of_disjoint Complex.exp_eq_exp_iff_exists_int
--   Complex.normSq_mul
-- ─────────────────────────────────────────────────────────────────────────────

-- ── afp_hammer / afp_hammer_with / afp_fin_hammer (uncomment with lean-auto) ─
--
-- macro "afp_hammer" : tactic => `(tactic|
--   first
--   | omega
--   | decide
--   | norm_num
--   | (set_option auto.native true in auto [* afp_all_db])
--   | (set_option auto.smt true in set_option auto.smt.trust true in
--      set_option auto.mono.mode "fol" in auto [*])
--   | (set_option auto.tptp true in set_option auto.tptp.trust true in auto [*])
--   | (simp_all; omega)
--   | fail "afp_hammer: all backends exhausted")
--
-- macro "afp_hammer_with" db:ident : tactic => `(tactic|
--   first
--   | omega
--   | decide
--   | norm_num
--   | (set_option auto.native true in auto [* $db])
--   | (set_option auto.smt true in set_option auto.smt.trust true in auto [* $db])
--   | fail "afp_hammer_with: all backends exhausted")
--
-- macro "afp_fin_hammer" : tactic => `(tactic|
--   first
--   | (fin_cases ‹_› <;> simp_all <;> ring)
--   | (fin_cases ‹_› <;> fin_cases ‹_› <;> simp_all <;> ring)
--   | (fin_cases ‹_› <;> fin_cases ‹_› <;>
--      simp only [Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons,
--                 Matrix.head_fin_const, Matrix.mul_apply,
--                 Fin.sum_univ_two, Fin.sum_univ_four] <;>
--      (try push_cast) <;> ring)
--   | fail "afp_fin_hammer: decomposition failed")
-- ─────────────────────────────────────────────────────────────────────────────
