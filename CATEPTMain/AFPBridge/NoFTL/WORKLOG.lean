/-!
# NoFTL Transpiler Improvement Worklog

Source: AFP `No_FTL_observers_Gen_Rel` (Sulzbacher & Martins 2023)
Target: Lean 4 / CATEPTMain, Lean 4.29+
Evidence base: catept-main build sessions 2026-04 (commits d55a9eea..900c0446),
  strict build logs in navier-stokes-project-clean/verification_results/afp_isabelle/no_ftl_observers_gen_rel/build/

All records graded by severity (P1=blocker / P2=high / P3=medium / P4=low)
and type (TR=translator fix / PL=prelude fix / TLA=TLA+ model update / QA=validation).

────────────────────────────────────────────────────────────────────────────────
## TRL-001  Wrong function-type inference for point parameters
Severity: P1 — blocker (caused ~40 compile errors across Points, Functions, Translations)
Error pattern:
  theorem lemFoo (p : NoFTLObj → NoFTLObj) ...  -- translator inferred function type
  -- ERROR: application type mismatch (expected NoFTLObj, got NoFTLObj→NoFTLObj)
Root cause:
  Isabelle's `p :: 'a Point` is a concrete value; the translator's auto-implicit
  binder inference inferred `p : NoFTLObj → NoFTLObj` because `CoeFun NoFTLObj`
  is in scope, making any free variable eligible as a function.
Fix target (translator):
  Binder inference must check whether the free variable appears as the head of an
  application in the theorem body. Only emit `v : T → T` when v is applied to
  at least one argument. Otherwise emit `v : NoFTLObj`.
Fix target (prelude):
  No change needed; `CoeFun NoFTLObj` is correct and required.
Validation:
  - Regenerate Points.lean, Functions.lean, Translations.lean
  - All 4 Point params in Points.lean should have type `NoFTLObj`, not `→ NoFTLObj`
  - `lake build CATEPTMain.AFPBridge.NoFTL.Theories.Points` EXIT:0
TLA+ model: translator_control_loop.tla — add guard
  `binderInferenceSafe: ¬(isApplied v body) ⇒ emit v : NoFTLObj`

────────────────────────────────────────────────────────────────────────────────
## TRL-002  Relation application `f x y` emitted as Bool instead of Prop
Severity: P1 — blocker (affected MainLemma, Functions, Cardinalities)
Error pattern:
  (h3 : f x y)   -- f : NoFTLObj CoeFun → (NoFTLObj→NoFTLObj), so f x : NoFTLObj
                  -- then (f x) y : NoFTLObj, not Prop → TYPE ERROR in hypothesis
Root cause:
  Isabelle `f x y` where `f` is a binary relation (type `'a⇒'a⇒bool`) is emitted
  as `(h : f x y)` in Lean 4. But with `CoeFun NoFTLObj`, Lean 4 reads `f x`
  as function application via `asFunc`, returning `NoFTLObj`, not `Prop`.
Fix target (translator):
  When an Isabelle term has type `bool` (i.e., is a proposition) and the head `f`
  is a NoFTLObj, emit `f x = y` for binary predicates or add an explicit
  `(h : isPredOf f x y)` using a typed predicate combinator.
  Preferred form: `(h : f x = y)` when `f` is a functional relation (maps x to y).
Validation:
  - Regenerate MainLemma.lean: `(f00 : f origin = origin)` not `(f00 : f origin origin)`
  - `lake build CATEPTMain.AFPBridge.NoFTL.Theories.MainLemma` EXIT:0
TLA+ model: afp_lean4_translation_error_classes.tla — add new error class
  `E6_coe_fun_relation_collapse` : `CoeFun` head causes binary relation to
  type-check as application, not proposition.

────────────────────────────────────────────────────────────────────────────────
## TRL-003  Spurious `wvtFunc` parameter injection
Severity: P1 — blocker (TangentLineLemma, WorldLine, ObserverConeLemma, Proposition3)
Error pattern:
  theorem lemX (wvtFunc : NoFTLObj) ...  -- translator injected redundant param
  (h : affineApprox A (wvtFunc m k) x)  -- wvtFunc m k : NoFTLObj, not function
Root cause:
  The translator emitted `wvtFunc` as an explicit parameter with type `NoFTLObj`
  instead of treating `wvt m k` (from the prelude) as a constructor expression.
  `affineApprox` expects `NoFTLObj` as its 2nd arg (the function-as-object), but
  `wvt : NoFTLObj → NoFTLObj → NoFTLObj → NoFTLObj` is a 3-place world-view
  transformer returning a point, not a function object.
Fix target (translator):
  Recognise the AFP pattern `wvt m k` as shorthand for `toFunc (wvt m k ·)` and
  emit `affineApprox A (toFunc (wvt m k)) x` directly. Do not inject a free
  `wvtFunc` parameter.
Fix target (prelude):
  Ensure `wvt : NoFTLObj → NoFTLObj → NoFTLObj → NoFTLObj` and `toFunc` coercion
  are documented clearly in the prelude header.
Validation:
  - Regenerate TangentLineLemma.lean: no `(wvtFunc : NoFTLObj)` params
  - All occurrences of `affineApprox A` must be followed by `toFunc (wvt m k)`, not free name
  - `lake build CATEPTMain.AFPBridge.NoFTL.Theories.TangentLineLemma` EXIT:0
TLA+ model: translator_control_loop.tla — add guard
  `wvtFuncInjectionSafe: free(wvtFunc) ∧ usedIn(affineApprox) ⇒ emit toFunc(wvt m k)`

────────────────────────────────────────────────────────────────────────────────
## TRL-004  Line typed as `NoFTLObj` instead of `NoFTLSet`
Severity: P1 — blocker (NoFTLGR, Classification, TangentLineLemma, TangentLines)
Error pattern:
  (l : NoFTLObj) ...  (h1 : tangentLine l s x)
  -- tangentLine : NoFTLSet → NoFTLSet → NoFTLObj → Prop
  -- l : NoFTLObj fails first argument
Root cause:
  Isabelle's `line` has type `'a Point set`, i.e., a set. The translator inferred
  `l : NoFTLObj` (the opaque object type) instead of `l : NoFTLSet` (the set type).
Fix target (translator):
  Add AFP sort analysis pass: when the Isabelle type of a variable is `_ set`,
  emit `NoFTLSet`. Cross-reference with prelude predicates:
    `tangentLine  : NoFTLSet → NoFTLSet → NoFTLObj → Prop`
    `applyAffineToLine : NoFTLObj → NoFTLSet → NoFTLSet → Prop`
    `lineJoining  : NoFTLObj → NoFTLObj → NoFTLSet`
    `wline        : NoFTLObj → NoFTLObj → NoFTLSet`
  Any variable used as the first argument of these must have type `NoFTLSet`.
Validation:
  - Regenerate Classification.lean: all line variables typed `NoFTLSet`
  - Grep: `grep "(l : NoFTLObj)" CATEPTMain/AFPBridge/NoFTL/Theories/*.lean` → 0 hits
  - `lake build CATEPTMain.AFPBridge.NoFTL.Theories.Classification` EXIT:0

────────────────────────────────────────────────────────────────────────────────
## TRL-005  Chained comparison operators emitted verbatim
Severity: P2 — high (Sorts, Points, Cardinalities — ~6 errors)
Error pattern:
  (h : 0 < x < 1)       -- Lean 4 has no chained comparison sugar
  (h : 0 < card S ≤ 2)  -- same
Root cause:
  Isabelle allows `0 < x < 1` (chained inequalities in locales).
  Lean 4 does not; it requires explicit conjunction.
Fix target (translator):
  IR → Lean 4 emission pass: flatten chained comparisons to conjunction:
    `0 < x < 1`    → `0 < x ∧ x < 1`
    `0 < x ≤ y`    → `0 < x ∧ x ≤ y`
    `a ≤ b ≤ c`    → `a ≤ b ∧ b ≤ c`
Validation:
  - Search emitted files: `grep -Pn "[0-9] < .* < " CATEPTMain/AFPBridge/NoFTL/Theories/*.lean` → 0 hits
  - `lake build CATEPTMain.AFPBridge.NoFTL.Theories.Sorts EXIT:0`

────────────────────────────────────────────────────────────────────────────────
## TRL-006  Missing prelude axioms for AFP-local predicates
Severity: P2 — high (caused unknown-identifier errors on first build)
Error pattern:
  unknown identifier 'qcase1', 'tl', 'tangentLine', 'slopeInfinite', 'hasRoot', ...
Root cause:
  The translator generated references to AFP local abbreviations/definitions
  (`qcase1..6`, `tl`, `tangentLine`, `tangentLineA`, `hasRoot`,
  `axTriangleInequality`, `slopeInfinite`, `isTranslationPart`, `isLinearPart`,
  `instMembershipNoFTLObjObj`) without emitting corresponding prelude entries.
Fix target (translator):
  Prelude-generation pass: scan all emitted theory files for identifiers that are
  not in scope from the prelude. For AFP-specific predicates that have no
  Lean/Mathlib canonical form, auto-emit `axiom p : ...` entries.
  Specifically ensure the following are always emitted:
    axiom qcase1..6      : NoFTLObj → NoFTLObj → NoFTLObj → Prop
    axiom tl             : NoFTLSet → NoFTLObj → NoFTLObj → NoFTLObj → Prop
    axiom tangentLine    : NoFTLSet → NoFTLSet → NoFTLObj → Prop
    axiom tangentLineA   : NoFTLObj → NoFTLObj → NoFTLObj → Prop
    axiom hasRoot        : NoFTLObj → Prop
    axiom axTriangleInequality : NoFTLObj → NoFTLObj → Prop
    axiom slopeInfinite  : NoFTLObj → NoFTLObj → Prop
    axiom isTranslationPart : NoFTLObj → NoFTLObj → Prop
    axiom isLinearPart      : NoFTLObj → NoFTLObj → Prop
    instance instMembershipNoFTLObjObj : Membership NoFTLObj NoFTLObj
Fix target (prelude):
  Already fixed in commit 900c0446. Translator must not diverge from prelude.
Validation:
  - Run `lake build CATEPTMain.AFPBridge.NoFTL.NoFTLPrelude` after regeneration → EXIT:0
  - No `unknown identifier` errors in any theory file build

────────────────────────────────────────────────────────────────────────────────
## TRL-007  `m sees k at x` notation conflict with `sees` prefix usage
Severity: P2 — high (Proposition3 + ObserverConeLemma failures)
Error pattern:
  -- Parser emits `notation:50 m " sees " k " at " x => sees m k x`
  -- Then theorem body uses `sees m k x` as prefix call
  -- → "unexpected token 'sees'" at parse time
Root cause:
  The infix/mixfix notation `m sees k at x` tokenises `sees` as an infix keyword.
  When the same identifier `sees` appears as a plain prefix symbol in a theorem
  hypothesis, the parser rejects it.
Fix target (translator):
  Do not emit a `notation` declaration for `sees`. The AFP source uses a locale
  abbreviation; just emit `sees m k x` as direct function application throughout.
  Delete the `notation:50 m " sees " k " at " x` line from prelude generation.
Fix target (prelude):
  Already removed in commit 900c0446. Do not re-add.
Validation:
  - `grep -n "notation.*sees" CATEPTMain/AFPBridge/NoFTL/NoFTLPrelude.lean` → 0 hits
  - `lake build CATEPTMain.AFPBridge.NoFTL.Theories.Proposition3` EXIT:0

────────────────────────────────────────────────────────────────────────────────
## TRL-008  Hypothesis parameter aliasing: `(l : l = line B D)` pattern
Severity: P2 — high (Classification.lean — lemLineMeetsCone1..6)
Error pattern:
  (l : l = line B D)   -- parameter name same as its own hypothesis binder
  (X : X = (B x))      -- same for X
Root cause:
  Translator emitted Isabelle `let l = line B D` as `(l : l = line B D)`,
  conflating the binding name with the type annotation. Lean 4 rejects this
  as a circular binder.
Fix target (translator):
  When translating `let v = expr` in theorem hypotheses, emit:
    `(hv : v = expr)` (rename binder to `hv` and keep `v` as a separate
    implicit or explicit parameter, OR inline the expression).
  For common AFP patterns `let l = lineJoining B D`:
    emit `(l : NoFTLSet) (hl : l = lineJoining B D)` as two separate params.
  For `let X = B - x`:
    emit `(X : NoFTLObj) (hX : X = B - x)`.
Validation:
  - `grep -n "(l : l =" CATEPTMain/AFPBridge/NoFTL/Theories/*.lean` → 0 hits
  - `grep -n "(X : X =" CATEPTMain/AFPBridge/NoFTL/Theories/*.lean` → 0 hits
  - `lake build CATEPTMain.AFPBridge.NoFTL.Theories.Classification` EXIT:0

────────────────────────────────────────────────────────────────────────────────
## TRL-009  `(sComponent D) s (sComponent X)` — spatial dot via CoeFun
Severity: P2 — high (Classification.lean sdot usage)
Error pattern:
  (sComponent D) s (sComponent X)
  -- s : NoFTLObj via CoeFun, so (sComponent D) s : NoFTLObj, not a binary op
Root cause:
  Isabelle `sdot (sComponent D) (sComponent X)` emitted as `(sComponent D) s (sComponent X)`
  where `s` was a free variable inferred as `NoFTLObj` (via CoeFun) instead of
  the spatial dot operator.
Fix target (translator):
  Recognise the Isabelle `sdot` operator and always emit `sdot e1 e2` directly.
  Never use a free variable as an infix operator proxy in spatial product expressions.
Validation:
  - `grep -n "sComponent.*) [a-z] (sComponent" CATEPTMain/AFPBridge/NoFTL/Theories/*.lean` → 0 hits

────────────────────────────────────────────────────────────────────────────────
## TRL-010  `(B x)` CoeFun interpreted as function application vs. arithmetic
Severity: P2 — high (Classification.lean — B is a point, not a function)
Error pattern:
  (X : X = (B x))   -- B : NoFTLObj; CoeFun makes (B x) legal but means asFunc B x
  -- intended: X = B - x  (point subtraction)
Root cause:
  Isabelle pattern `B - x` (point subtraction) was emitted as `B x` via CoeFun,
  confusing subtraction with function application.
Fix target (translator):
  Sub-expression disambiguation: when `B : Point` (NoFTLObj) and `x : Point`,
  `B x` in Isabelle is never function application — it is `B - x` (affine subtraction)
  or a coordinate projection. The translator must not emit point-applied-to-point
  patterns via CoeFun.
  Emit explicit subtraction: `B - x` or `B + α *s D` as appropriate.
Validation:
  - `grep -n "= (B x)" CATEPTMain/AFPBridge/NoFTL/Theories/*.lean` → 0 hits

────────────────────────────────────────────────────────────────────────────────
## TRL-011  `intro _` inside `first |` tactic combinator causes unsolved goals
Severity: P2 — high (Translations.lean:lemMkTrans)
Error pattern:
  first | intro _ | simp_all | tauto | omega | decide | trivial | sorry
  -- `intro _` succeeds (introduces a variable) but does NOT close the goal
  -- the `first` combinator reports success after intro, leaving unsolved subgoal
Root cause:
  The translator's tactic emission strategy uses `first | intro _ | ...` as a
  catch-all. `intro _` succeeds on any goal with a leading ∀, but does not close
  it — leaving a broken proof state.
Fix target (translator):
  Remove `intro _` from the `first |` catch-all combinator.
  For ∀-goals with known structure, emit `intro` followed by appropriate tactics.
  The safe fallback combinator should be: `simp_all | omega | linarith | exact rfl | sorry`.
Validation:
  - `grep -rn "first | intro _" CATEPTMain/AFPBridge/NoFTL/Theories/*.lean` → 0 hits
  - `lake build CATEPTMain.AFPBridge.NoFTL.Theories.Translations` EXIT:0

────────────────────────────────────────────────────────────────────────────────
## TRL-012  `invFunc (asFunc T)` double-wrapping
Severity: P3 — medium (Translations.lean:lemInverseOfTransIsTrans)
Error pattern:
  (h2 : T' = invFunc (asFunc T))
  -- asFunc : NoFTLObj → (NoFTLObj → NoFTLObj); invFunc : NoFTLObj → NoFTLObj
  -- invFunc expects NoFTLObj, not NoFTLObj → NoFTLObj
Root cause:
  Translator emitted `invFunc (asFunc T)` when the AFP source has `inv T`
  where `T` is already a relation (NoFTLObj). `asFunc` unwraps to Lean function
  type, making the argument wrong for `invFunc`.
Fix target (translator):
  When the AFP source is `inv R` for relational `R : NoFTLObj`, emit `invFunc R`
  directly without `asFunc` wrapping.
Validation:
  - `grep -n "invFunc (asFunc" CATEPTMain/AFPBridge/NoFTL/Theories/*.lean` → 0 hits

────────────────────────────────────────────────────────────────────────────────
## TRL-013  Empty/stub theory files emitted for 100% singleton theorem theories
Severity: P3 — medium (quality gate failure pattern diagnosed in prior sessions)
Error pattern:
  -- Generated files each contain exactly 1 theorem (singleton_ratio = 1.0)
  -- Quality gate: min avg object decls/file 2.0 fails
Root cause:
  The translator emits one `.lean` file per AFP theorem index even when all
  theorems of a theory belong together conceptually.
Fix target (translator):
  Bundle emission: group per-theory files by `Theory` field, emit one `.lean`
  per theory with all theorems. Override singleton emission for theories with
  ≤ 30 theorems. Use `LEAN_EMIT_BUNDLE_SIZE` parameter.
Validation:
  - After rebundling: `avg_decls_per_file ≥ 2.0`, `singleton_ratio ≤ 0.5`
  - `lean_output_quality_summary.json` shows `quality_gate_pass: true`

────────────────────────────────────────────────────────────────────────────────
## TRL-014  Module path hard-coded to `NavierStokesClean.*` not `CATEPTMain.*`
Severity: P3 — medium (every strict-mode generated file fails import)
Error pattern:
  import NavierStokesClean.AFPIsabellePilot.NoFTLPrelude  -- strict mode output
  -- but the lib is CATEPTMain, not NavierStokesClean
Root cause:
  The translator has the target module root hard-coded to `NavierStokesClean`
  (the original navier-stokes project). When ported to `catept-main`, all
  imports fail.
Fix target (translator):
  Make module root a required CLI parameter: `--lean-module-root CATEPTMain`.
  Default to something clearly wrong (empty string) so misconfiguration is
  immediately obvious rather than silently producing files that fail to import.
Validation:
  - `grep "^import" CATEPTMain/AFPBridge/NoFTL/Theories/*.lean | grep -v "CATEPTMain"` → 0 hits

────────────────────────────────────────────────────────────────────────────────
## TRL-015  `orthogm uo = v` emitted instead of `orthogm uo v`
Severity: P3 — medium (Vectors.lean:lemMDecomposition)
Error pattern:
  orthogm uo = v    -- orthogm is binary predicate: NoFTLObj → NoFTLObj → Prop
                    -- `orthogm uo` has type `NoFTLObj → Prop`, not NoFTLObj
                    -- `= v` then has wrong type
Root cause:
  Translator emitted the Isabelle `orthogm uo v` (application syntax for a
  2-arg predicate) as `orthogm uo = v` (equality between a partial application
  and a value).
Fix target (translator):
  For any binary predicate `P : NoFTLObj → NoFTLObj → Prop`, always emit
  `P a b` not `P a = b` or `(P a) = b`. Add a post-emission lint pass
  checking for `predicate arg = value` patterns where predicate returns Prop.
Validation:
  - `grep -n "orthogm .* = " CATEPTMain/AFPBridge/NoFTL/Theories/*.lean` → 0 hits

────────────────────────────────────────────────────────────────────────────────
## TRL-016  Forward-reference ordering in prelude: defs before their dependencies
Severity: P2 — high (caused false 0/N compile collapse on first prelude build)
Error pattern:
  def timelike (p : NoFTLObj) : Prop := mNorm2 p > 0
  -- mNorm2 was declared AFTER timelike in original emission
  -- → "unknown identifier 'mNorm2'"
Root cause:
  The prelude emission order is driven by AFP theory source order, not by
  dependency order. Some def/abbrev blocks were emitted before their axiom
  dependencies.
Fix target (translator):
  Prelude topological sort: axiom declarations before def/abbrev that use them.
  Strict order: `axiom` blocks → `noncomputable abbrev` → `instance` blocks →
  `def` blocks → `notation` blocks.
Validation:
  - Dependency check: all `def` bodies use only previously-declared names
  - `lake build CATEPTMain.AFPBridge.NoFTL.NoFTLPrelude` EXIT:0 on a freshly
    generated prelude (no manual edits needed)

────────────────────────────────────────────────────────────────────────────────
## TRL-017  Non-idiomatic: `macro "ring"` stub overriding Mathlib tactic
Severity: P3 — medium
Error pattern:
  macro "ring" : tactic => `(tactic| sorry)
  -- Shadowing Mathlib ring tactic breaks any downstream file that imports Mathlib
Root cause:
  The translator emits a prelude with macro stubs to make files compile without
  Mathlib. But `ring`, `linarith`, `norm_num` are core Mathlib tactics; shadowing
  them makes the file incompatible with any Mathlib import.
Fix target (translator):
  Macro shadowing approach is acceptable ONLY if the prelude file has no Mathlib
  import. If Mathlib will be added later, use a scoped namespace or `set_option`
  guards. Document the intent: these stubs are phase-1 compilation scaffolds,
  not permanent.
  Alternative: emit `try (by ring) <|> sorry` at proof site rather than global
  macro shadowing.
Validation:
  - Phase-1 (current): stubs acceptable, prelude must not import Mathlib
  - Phase-2 target: remove stubs, use real Mathlib imports, all proofs non-sorry

────────────────────────────────────────────────────────────────────────────────
## TRL-018  Non-idiomatic: `axiom NoFTLObj : Type` — opaque types not using `opaque`
Severity: P4 — low
Error pattern:
  axiom NoFTLObj : Type   -- legally valid but non-idiomatic in Lean 4
Root cause:
  The correct Lean 4 idiom for an abstract opaque type is:
    `opaque NoFTLObj : Type := Unit`
  Using `axiom` creates an inconsistency risk if instances are later added.
Fix target (translator):
  Emit carrier types as `opaque NoFTLObj : Type := Unit` to make the opaque
  intent explicit and avoid axiom-proliferation warnings.
Validation:
  - `grep "^axiom NoFTLObj\|^axiom NoFTLSet" CATEPTMain/AFPBridge/NoFTL/NoFTLPrelude.lean` → 0 hits
  - `grep "^opaque NoFTLObj\|^opaque NoFTLSet"` → 2 hits

────────────────────────────────────────────────────────────────────────────────
## TRL-019  Non-idiomatic: `autoImplicit true` used as global escape hatch
Severity: P3 — medium
Error pattern:
  set_option autoImplicit true   -- at top of every theory file
Root cause:
  The translator avoids determining all implicit variable types by setting
  `autoImplicit true`. This is non-idiomatic Lean 4 style (disabled by default
  in Mathlib) and masks exactly the free-variable type errors that are the root
  cause of TRL-001 through TRL-004.
Fix target (translator):
  Do NOT emit `set_option autoImplicit true`. Instead, ensure all free variables
  in theorem signatures are explicitly bound. TRL-001..004 fixes are prerequisites:
  once binder inference is correct, autoImplicit can be dropped.
Validation:
  - `grep -c "autoImplicit true" CATEPTMain/AFPBridge/NoFTL/Theories/*.lean` → all 0
  - Full build still EXIT:0

────────────────────────────────────────────────────────────────────────────────
## TLA-001  Add E6_coe_fun_relation_collapse to error taxonomy
Severity: P2 — high (new error class not in existing TLA+ model)
Target file:
  navier-stokes-project-clean/verification/tla/afp_lean4_translation_errors/
  afp_lean4_translation_error_classes.tla
Change:
  Add to `ErrorClasses`:
    "E6_coe_fun_relation_collapse"
  Add to `RemediationClasses`:
    "add_equality_form"
  Update `ErrorToRemediation`:
    ELSE IF e = "E6_coe_fun_relation_collapse" THEN "add_equality_form"
  Update `RetryableErrors` (mechanical fix):
    add "E6_coe_fun_relation_collapse"
  Add safety invariant:
    CoeFunRelationCollapsePrevented ==
      ∀ t ∈ THEOREMS:
        errorClass[t] = "E6_coe_fun_relation_collapse" =>
        remediation[t] = "add_equality_form"
Validation:
  Run TLC model checker on updated .tla — 0 invariant violations

────────────────────────────────────────────────────────────────────────────────
## TLA-002  Add NoFTL-specific binder-inference guard to translator_control_loop
Severity: P2 — high
Target file:
  navier-stokes-project-clean/verification/tla/afp_isabelle_to_lean_control_loop/
  translator_control_loop.tla
Change:
  Add new state variable `binderInferenceSafe : OBLIGATIONS → BOOLEAN`
  Add action `CheckBinderTypes(o)`:
    - Fires after `translated` state
    - Sets `binderInferenceSafe[o] = FALSE` if any param is inferred as `T→T`
      without evidence of application in theorem body
    - Triggers E1 remediation if FALSE
  Add invariant:
    BinderSafetyGate ==
      ∀ o ∈ OBLIGATIONS:
        status[o] = "checked" => binderInferenceSafe[o]
Validation:
  TLC check: all paths through Translate → Check satisfy BinderSafetyGate

────────────────────────────────────────────────────────────────────────────────
## TLA-003  Populate NoFTLFailed8Remediation.tla with current error data
Severity: P2 — medium
Target file:
  navier-stokes-project-clean/verification_results/afp_isabelle/
  no_ftl_observers_gen_rel/subsets/no_ftl_failed8_remediation.tla
Change:
  Populate `FailedFiles`, `Scenarios`, `Actions`, `ScenarioByFile`, `ActionByScenario`
  from the 8 theory files that were failing before commit 900c0446:
    TangentLines, TangentLineLemma, Proposition2, Proposition3,
    Affine, Cardinalities, Translations, ObserverConeLemma
  Map each to a scenario (e.g., "wvtFunc_injection", "line_type_mismatch",
    "coe_fun_relation_collapse", "notation_conflict")
  Map each scenario to the corresponding action (TRL-001..TRL-007 fix IDs).
Validation:
  TLC check: `InvDisjoint` and `InvActionSound` both hold
  TLC check: all FailedFiles reach `done` in the state space

────────────────────────────────────────────────────────────────────────────────
## TLA-004  Update NoFTLTypeBinderCategory.tla with actual binder data
Severity: P3 — medium
Target file:
  navier-stokes-project-clean/verification_results/afp_isabelle/
  no_ftl_observers_gen_rel/subsets/no_ftl_failed8_type_binder_category.tla
Change:
  Populate `Theorems`, `Binders`, `Types`, `BinderType`, `BinderOf` from actual
  generated output. Capture the 3 binder type categories observed:
    "NoFTLObj"        — scalar/point (correct for most params)
    "NoFTLSet"        — set/line (correct for l, wline targets)
    "NoFTLObj→NoFTLObj" — function (correct ONLY when applied in body)
  Add invariant:
    FunctionBinderRequiresApplication ==
      ∀ b ∈ Binders:
        BinderType[b] = "NoFTLObj→NoFTLObj" =>
        appliedInBody[b]   (* new field: BOOLEAN *)
Validation:
  TLC check: no binder has function type without body application evidence

────────────────────────────────────────────────────────────────────────────────
## QA-001  Regression test suite for translator output
Severity: P2 — high
Target: scripts/check_integration.sh (extend) or new scripts/check_noftl_output.sh
Checks to add:
  1. grep "(.[a-z] : [A-Z][a-zA-Z]* → " Theories/*.lean | wc -l  → must equal 0
     (no function-typed params without body application)
  2. grep "(h[0-9]* : [a-z] [a-z] [a-z])" Theories/*.lean → must equal 0
     (no CoeFun binary-relation hypothesis form)
  3. grep "notation.*sees" NoFTLPrelude.lean → must equal 0
  4. grep "intro _" Theories/*.lean → must equal 0
  5. grep "(l : NoFTLObj)" Theories/*.lean | grep -i "line\|cone\|wline" → must equal 0
  6. lake build all 27 modules → EXIT:0
  7. grep "^import NavierStokesClean" Theories/*.lean → must equal 0
Validation:
  Running `scripts/check_noftl_output.sh` after regeneration must exit 0
  with all 7 checks passing.

────────────────────────────────────────────────────────────────────────────────
## QA-002  Faithfulness delta metric
Severity: P3 — medium
Target: analysis pipeline
Define per-theorem faithfulness score:
  faithful_stmt  = 1 if no NoFTLObj in type sig, 0 otherwise
  faithful_proof = 1 if no sorry in proof body, 0 otherwise
  delta          = faithful_stmt + faithful_proof  (0..2)
Baseline (commit 900c0446): faithful_stmt ≈ 0 (all use NoFTLObj), faithful_proof ≈ 0 (all sorry)
Phase-2 target: faithful_stmt = 1 for all 26 theories / faithful_proof > 0.5
Track delta improvement after each translator fix batch.
Validation:
  After TRL-018 (opaque types) + TRL-019 (no autoImplicit):
    faithful_stmt target ≥ 0.8 (80% of theorem params use non-opaque types)

-/

-- This file is a worklog / issue tracker. No runnable Lean 4 code is defined here.
-- Records are sorted: P1 first, then P2, P3, P4 within each category.
-- TRL-* = translator fix targets
-- TLA-* = TLA+ model update targets
-- QA-*  = validation / quality gate targets
