import Mathlib.Data.Complex.Basic

/-!
# AFP Bridge Framework — Generic Lean 4 Scaffold

This file provides infrastructure shared by ALL AFP module preludes under
`CATEPTMain.*`.

## Usage

A module-specific prelude (e.g. `IMDPrelude.lean`) should:
```lean
import CATEPTMain.Core.Framework.AFPBridgeFramework
-- then `open AFPBridgeFramework.TacticStubs` for phase-1 sorry macros
-- then add only module-specific carrier types and predicates
```

## What lives here vs. in module preludes

| Concern                         | Here (generic)           | Module prelude (specific)       |
|---------------------------------|--------------------------|---------------------------------|
| Phase-1 tactic stubs            | ✓ scoped macros          | open this namespace             |
| Notation conflict documentation | ✓ comments + tokens set  | do not redeclare listed tokens  |
| Carrier type pattern            | ✓ `AFPObj`/`AFPSet`/`AFPMat`/`AFPVec` opaque scaffold | extend or alias |
| Typeclass instance axiom pattern | ✓ template              | copy/adapt for module types     |
| Locale injection rule           | ✓ documented             | apply per theory                |
| Module-specific predicates      | ✗                        | ✓ axioms added in prelude       |
| Module-specific notations       | ✗                        | ✓ (avoid conflict list)         |

## Upgrade path (phase 1 → phase 2)

Phase 1: import this file; use opaque `AFPMat`/`AFPVec`; all proofs `sorry`.
Phase 2: replace opaque types with `Matrix (Fin n) (Fin m) ℂ` and prove lemmas
  from Mathlib. The interface (axiom names, structure field names) stays the same
  so that theory files require no changes — only the prelude changes.

See `integration/afp_type_map.yaml` for the full type/operator correspondence table.
-/

set_option autoImplicit false

namespace CATEPTMain.Core.Framework

-- ── Phase tag ─────────────────────────────────────────────────────────────────
/-- Documents the translation phase of a prelude or theory file. -/
inductive AFPTranslationPhase
  /-- Phase 1: opaque axiom scaffold; proofs are `sorry`; compiles without Mathlib import tree. -/
  | Phase1
  /-- Phase 2: Mathlib-concrete types; real tactic proofs replacing `sorry`. -/
  | Phase2

-- ── Scoped phase-1 tactic stubs ───────────────────────────────────────────────
-- Phase-1 tactic stubs. Open this namespace in a module prelude to replace all
-- Mathlib-dependent tactics with `sorry` fallbacks, so the prelude file compiles
-- without requiring the full Mathlib import graph.
--
-- Usage in a module prelude (before any `open Mathlib`):
--   open CATEPTMain.Core.Framework.TacticStubs
--
-- In phase 2: remove the `open` line and enable real Mathlib tactics.
namespace TacticStubs

scoped macro "linarith"   : tactic => `(tactic| sorry)
scoped macro "nlinarith"  : tactic => `(tactic| sorry)
scoped macro "ring"       : tactic => `(tactic| sorry)
scoped macro "ring_nf"    : tactic => `(tactic| sorry)
scoped macro "norm_num"   : tactic => `(tactic| sorry)
scoped macro "tauto"      : tactic => `(tactic| sorry)
scoped macro "field_simp" : tactic => `(tactic| sorry)
scoped macro "positivity" : tactic => `(tactic| sorry)
scoped macro "gcongr"     : tactic => `(tactic| sorry)
scoped macro "simp"       : tactic => `(tactic| sorry)
scoped macro "decide"     : tactic => `(tactic| sorry)
scoped macro "norm_cast"  : tactic => `(tactic| sorry)
scoped macro "push_cast"  : tactic => `(tactic| sorry)
scoped macro "exact??"    : tactic => `(tactic| sorry)
scoped macro "fun_prop"   : tactic => `(tactic| sorry)

end TacticStubs

-- ── Generic opaque carrier types ──────────────────────────────────────────────
/-!
## Generic phase-1 opaque types

These four types (AFPObj, AFPSet, AFPMat, AFPVec) are the universal
phase-1 scaffolds for AFP carrier types:

| AFP carrier               | Use        | Phase-2 Mathlib form                    |
|---------------------------|------------|-----------------------------------------|
| many-sorted 'a Point      | AFPObj     | Fin 4 → ℝ, or ℝ × ℝ × ℝ × ℝ          |
| sets of 'a Point          | AFPSet     | Set (Fin 4 → ℝ)                        |
| complex mat / real mat    | AFPMat     | Matrix (Fin m) (Fin n) ℂ (or ℝ)       |
| complex vec / real vec    | AFPVec     | Matrix (Fin n) (Fin 1) ℂ (or Fin n→ℂ) |

Module-specific preludes may either:
  (a) Use these types directly by importing this file, or
  (b) Declare their own opaque types with module-local names (e.g. `QMat`)
      and note that they are AFP_framework aliases.

Do NOT declare two separate opaque types for the same AFP carrier within
one module. Pick one and use it consistently throughout the prelude.
-/

-- Generic scalar/relation carrier (No_FTL_observers_Gen_Rel style, also usable
-- as a catch-all for any AFP module with many-sorted types).
opaque AFPObj : Type := Unit
opaque AFPSet : Type := Unit

-- Matrix and vector carriers (Jordan_Normal_Form / Quantum style).
-- Phase-2 upgrade: replace with `Matrix (Fin n) (Fin m) ℂ`.
opaque AFPMat : Type := Unit
opaque AFPVec : Type := Unit

-- ── Generic opaque operations on AFPMat/AFPVec ────────────────────────────────
-- These are the AFP-universal matrix/vector operations.
-- Module-specific preludes that use AFPMat/AFPVec get these for free.

-- Dimension accessors
axiom afpDimRow : AFPMat → ℕ
axiom afpDimCol : AFPMat → ℕ
axiom afpDimVec : AFPVec → ℕ

-- Index operations
axiom afpIndexMat : AFPMat → ℕ → ℕ → ℂ
axiom afpIndexVec : AFPVec → ℕ → ℂ

-- Matrix arithmetic
axiom afpMatMul   : AFPMat → AFPMat → AFPMat
axiom afpMatAdd   : AFPMat → AFPMat → AFPMat
axiom afpSmulMat  : ℂ → AFPMat → AFPMat
axiom afpOneMat   : ℕ → AFPMat
axiom afpZeroMat  : ℕ → ℕ → AFPMat
axiom afpTranspose: AFPMat → AFPMat
axiom afpDagger   : AFPMat → AFPMat   -- conjTranspose; phase-2: Matrix.conjTranspose
axiom afpColVec   : AFPMat → ℕ → AFPVec
axiom afpRowMat   : AFPMat → ℕ → AFPMat

-- Vector arithmetic
axiom afpVecAdd   : AFPVec → AFPVec → AFPVec
axiom afpSmulVec  : ℂ → AFPVec → AFPVec
axiom afpScalar   : AFPVec → AFPVec → ℂ    -- dot product (no conjugation)
axiom afpInner    : AFPVec → AFPVec → ℂ    -- sesquilinear inner product
axiom afpVecNorm  : AFPVec → ℝ             -- ‖v‖

-- Matrix → vector embedding
axiom afpKetVec   : AFPVec → AFPMat        -- |v⟩ as column matrix
axiom afpBraVec   : AFPVec → AFPMat        -- ⟨v| as row matrix

-- Predicates
axiom afpUnitary  : AFPMat → Prop          -- M† * M = 1 ∧ M * M† = 1
axiom afpHermitian: AFPMat → Prop          -- M = M†
axiom afpIsSquare : AFPMat → Prop          -- dimRow M = dimCol M

-- ── Generic typeclass instance axiom pattern ──────────────────────────────────
/-!
## Typeclass instance axiom template

Every AFP module prelude that introduces a new opaque carrier type T needs
numeric and order typeclass instances for T so that AFP expressions like
`1 : T`, `T + T`, `T < T` compile.

Pattern: copy this block into the module prelude, replacing `AFPMat` with
the module-specific type name.

```lean
  axiom instHAddT    : HAdd T T T
  axiom instHMulT    : HMul T T T
  axiom instSubT     : Sub T T
  axiom instNegT     : Neg T
  axiom instHDivT    : HDiv T T T
  axiom instLTT      : LT T
  axiom instLET      : LE T
  axiom instOfNat0T  : OfNat T 0
  axiom instOfNat1T  : OfNat T 1
  attribute [instance] instHAddT instHMulT instSubT instNegT instHDivT
                       instLTT instLET instOfNat0T instOfNat1T
```

Add only the instances actually required by the AFP source. Do not add
instances speculatively — each spurious instance is a future typeclass
search cost.
-/

-- ── Notation conflict guard ────────────────────────────────────────────────────
/-!
## Notation conflict guard

The following tokens MUST NOT be declared as notation in any AFP module
prelude or theory file. Declaring them causes silent conflicts with Mathlib
that manifest as incorrect typeclass resolution or parse failures.

See `integration/afp_type_map.yaml` (notation_conflicts section) for the
authoritative list with alternatives.

Suppressed tokens:
  ⊗   — conflicts with TensorProduct; use `tensorMat` or `Matrix.kronecker`
  †   — conflicts with `Mᴴ` (Matrix.conjTranspose); use `afpDagger` or `Matrix.conjTranspose`
  ∙   — conflicts with Mathlib inner product; use `afpInner` or `inner`
  ⊙   — conflicts with various; use prefix form
  ⟨|⟩ — bra-ket; conflicts with anonymous constructor syntax; use `afpInner`

If the AFP source uses one of these notations, emit the Lean 4 theory file
using the prefix alternative form. Do not propagate AFP Unicode-heavy notation
into the Lean 4 output.
-/

-- ── Locale injection documentation ────────────────────────────────────────────
/-!
## Locale injection rule (universal)

Every AFP `locale foo = fixes p₁ :: T₁ ... assumes h₁ ... hₙ` must be
handled by injecting its fixed parameters and assumptions as explicit
theorem hypotheses in EVERY Lean 4 theorem translated from `(in foo)`.

Step-by-step:
  1. Identify the locale in the AFP source (by `locale` keyword or `(in foo)` tag).
  2. Extract all `fixes` entries → emit as `(p : T)` explicit parameters.
  3. Extract all `assumes` clauses → emit as `(hᵢ : Pᵢ)` explicit hypotheses.
  4. Prepend these to the Lean 4 theorem signature.
  5. Add comment `-- LocaleHyps: foo(p₁, ...) injected` on the theorem.

Example (AFP `locale gate`):
  AFP:    `lemma (in gate n A) foo: ...`
  Lean 4: `theorem foo
             (n : ℕ) (A : AFPMat)
             (hRow : afpDimRow A = 2^n) (hSq : afpIsSquare A) (hU : afpUnitary A)
             -- LocaleHyps: gate(n, A) injected
             : ...`

Failure to inject locale hypotheses is one of the top-3 translation defects
across ALL AFP modules (No_FTL TRL-004 analog; IMD IMD-PRE-004 RULE-B5).
-/

-- ── Phase-1 sorry annotation convention ───────────────────────────────────────
/-!
## Phase-1 proof annotation convention

All phase-1 sorry-discharged proofs MUST carry a trailing comment indicating
the intended phase-2 proof strategy. This ensures sorry proofs are actionable,
not dead weight.

Conventions:
  `sorry -- phase2_linarith`   → provable by `linarith` with Mathlib
  `sorry -- phase2_simp`       → provable by `simp [...]` with Mathlib lemmas
  `sorry -- phase2_ring`       → provable by `ring`
  `sorry -- phase2_norm_num`   → provable by `norm_num`
  `sorry -- phase2_matrix`     → requires Matrix library lemma (specify which)
  `sorry -- phase2_high`       → complex proof; requires human mathematician
  `sorry -- phase2_decide`     → decidable; provable by `decide` for small types
  `sorry -- phase2_exact <lemma_name>` → exact Mathlib lemma name known

Example:
  theorem X_unitary : afpUnitary X_gate := by
    sorry -- phase2_matrix: Matrix.mem_unitaryGroup + X matrix entries
-/

end CATEPTMain.Core.Framework
