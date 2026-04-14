/-!
# IMD Translation Worklog — Isabelle Marries Dirac → Lean 4

Source: AFP `Isabelle_Marries_Dirac` (Bordg, Lachnitt, He — November 22, 2020)
  https://www.isa-afp.org/entries/Isabelle_Marries_Dirac.html
Target: Lean 4 / CATEPTMain, Lean 4.29+  (namespace CATEPTMain.AFPBridge.IMD)
License: BSD

Prior version: IMD-v0 — scrapped (analogous to NoFTL-v0 before catept-main rebuild)
  Prior-v0 artifacts: none present in workspace (confirmed by workspace scan 2026-04)
  Reason scrapped: same class of defects as NoFTL TRL-001..019; prior translator
  output was unusable. Specifically: opaque-object collapse for `complex mat`,
  CoeFun-induced type confusion on `cpx_sqr_mat`, wrong binder types for locale
  parameters, and `smoke_<hash>` theorem naming.

Improved methodology: IMD-v1 uses a pre-generation validation pipeline that gates
  every defect class observed in NoFTL before any .lean file is emitted.
  See IMD-PRE-001..006 below.

Generalized framework: rather than writing IMDPrelude.lean from scratch,
  use the universal AFP Bridge Framework:
    import CATEPTMain.AFPBridge.Framework.AFPBridgeFramework
    open CATEPTMain.AFPBridgeFramework.TacticStubs  -- (phase-1 only)
  The framework provides: AFPMat, AFPVec, afpDagger, afpUnitary, locale injection
  rules, notation conflict guard, and phase-1 tactic stubs without duplication.
  IMDPrelude.lean then adds ONLY the IMD-specific predicates (Gate/State structures,
  Bell state axioms, bin_rep, etc.).
  Type map reference: integration/afp_type_map.yaml (authoritative; prevents
  re-deriving AFP→Lean4 type correspondences per-module).

AFP dependencies (must be bridged before any IMD theory can compile):
  Jordan_Normal_Form   → Mathlib.LinearAlgebra.Matrix.Determinant (etc.)
  Matrix_Tensor        → Mathlib.LinearAlgebra.Matrix.Kronecker
  VectorSpace          → Mathlib.LinearAlgebra.Basis

AFP session order (theory dependency chain, bottom-up):
  01 Basics              — set/arithmetic utility lemmas
  02 Binary_Nat          — n-bit binary representations
  03 Complex_Vectors     — complex inner product spaces
  04 Quantum             — qubits, gates, dagger, ket/bra, Bell states
  05 Tensor              — tensor product of complex matrices
  06 More_Tensor         — extended tensor theory
  07 Measurement         — projective measurement
  08 Entanglement        — entanglement criteria
  09 Quantum_Teleportation — teleportation protocol
  10 Deutsch             — Deutsch's algorithm
  11 Deutsch_Jozsa       — Deutsch-Jozsa algorithm
  12 No_Cloning          — no-cloning theorem
  13 Quantum_Prisoners_Dilemma — prisoner's dilemma variant

Used by (future translation targets): Projective_Measurements, Quantum_Fourier_Transform

All records graded by severity (P1=blocker / P2=high / P3=medium / P4=low)
and type (PRE=pre-generation gate / TH=theory plan / INT=integration / TLA=TLA+ / QA=validation).

────────────────────────────────────────────────────────────────────────────────
## IMD-PRE-001  AFP dependency bridge: Jordan_Normal_Form → Mathlib Matrix (P1)
Severity: P1 — translation fails entirely without this bridge
Context:
  The IMD AFP session imports Jordan_Normal_Form.Matrix as its primary matrix type.
  `mat` in AFP is a runtime-dimensioned type: `mat (dim_row) (dim_col)` carries
  dimension as runtime fields. In Lean 4 / Mathlib, `Matrix n m ℂ` has dimensions
  as type-level `ℕ` parameters (via `Fintype`).
  This mismatch is the dominant structural challenge for IMD, analogous to how
  NoFTL's `NoFTLObj` opaque type bridged Isabelle's `'a Point`.
Strategy:
  OPTION A (concrete): Use `Matrix n m ℂ` with explicit dimension parameters
    wherever the AFP lemma states a specific dimension (e.g., `2×2`, `4×4`, `2^n × 2^n`).
    Gate n : ℕ := 1 (single-qubit) or n : ℕ := 2 (two-qubit) for concrete gates.
  OPTION B (opaque): Use `axiom QMat : Type` with bridge axioms for gate definitions.
    Avoids dimensional bookkeeping but is a phase-1 scaffold only.
  RECOMMENDED: OPTION A for concrete gates (X, Y, Z, H, CNOT, S, T, Bell states);
    OPTION B (opaque QMat/QVec) only for theorems with universally quantified dimensions.
Key correspondences:
  AFP                     Lean 4 / Mathlib
  complex mat             Matrix n m ℂ  (or QMat opaque for phase 1)
  complex vec             Matrix n 1 ℂ  (or Fin n → ℂ; QVec opaque for phase 1)
  dim_row M               ← inferred from type Matrix m n ℂ as m
  dim_col M               ← inferred from type Matrix m n ℂ as n
  M $$ (i, j)             M i j  (Matrix index notation)
  col M j                 Matrix.col M j
  row M i                 Matrix.row M i
  1⇩m n                   (1 : Matrix n n ℂ)  i.e. Matrix.one
  M * N                   M * N  (Matrix multiplication via HMul instance)
  M ⊗ N  (tensor)         Matrix.kronecker M N  (see IMD-PRE-003)
  carrier_mat m n         {M : Matrix m n ℂ // True}  (trivially via type)
Fix target (translator):
  Pre-generation pass: construct a static dimension map from AFP theorem hypotheses.
  For theorems with `assume square_mat M`, `dim_row M = 2^n`, emit `(M : Matrix (2^n) (2^n) ℂ)`.
  Do NOT emit `dim_row : QMat → ℕ` as an axiom if the dimension is recoverable from context.
Validation:
  - IMDPrelude.lean has `import Mathlib.LinearAlgebra.Matrix.Determinant`
  - `lake build CATEPTMain.AFPBridge.IMD.IMDPrelude` EXIT:0

────────────────────────────────────────────────────────────────────────────────
## IMD-PRE-002  Prelude-first strategy — write IMDPrelude.lean before theory generation (P1)
Severity: P1 — NoFTL lesson: theory files emitted before prelude caused 50+ missing identifier errors
Context:
  In NoFTL, the prelude was written after theory generation. This caused TRL-006:
  missing axioms for AFP-local predicates discovered only at build time.
  For IMD, the prelude must be written FIRST by scanning ALL 13 AFP theory files
  for definitions, locales, abbreviations, and notation before any .lean is generated.
Strategy:
  AFP scan pass (pre-generation):
    1. Collect all `locale` definitions (state, gate) → emit as `structure` or typeclass
    2. Collect all `typedef` definitions (cpx_sqr_mat) → emit as subtype or opaque
    3. Collect all `definition` with no direct Mathlib analog → emit as `axiom` or `def`
    4. Collect all `abbreviation` and `notation` → emit minimally (avoid TRL-007 notation trap)
    5. Map AFP imports to Mathlib imports: list all required `import Mathlib.*` lines
Required prelude content (from Quantum.html / Basics.html scan):
  -- Phase-1 opaque types (upgrade to concrete in phase 2)
  opaque QMat  : Type := Unit   -- bridges `complex mat`
  opaque QVec  : Type := Unit   -- bridges `complex vec`
  -- Or phase-2 concrete: abbrev QMat (n m : ℕ) := Matrix (Fin n) (Fin m) ℂ
  -- Dimension accessors (phase 1 axioms)
  axiom dimRow  : QMat → ℕ
  axiom dimCol  : QMat → ℕ
  axiom dimVec  : QVec → ℕ
  -- Index operations
  axiom indexMat   : QMat → ℕ → ℕ → ℂ
  axiom indexVec   : QVec → ℕ → ℂ
  -- Matrix operations
  axiom matMul     : QMat → QMat → QMat
  axiom matAdd     : QMat → QMat → QMat
  axiom smulMat    : ℂ → QMat → QMat
  axiom oneMat     : ℕ → QMat             -- 1⇩m n
  axiom colVec     : QMat → ℕ → QVec
  axiom rowVec     : QMat → ℕ → QVec
  axiom transposeMat : QMat → QMat
  -- Complex vector operations
  axiom smulVec    : ℂ → QVec → QVec
  axiom addVec     : QVec → QVec → QVec
  axiom scalarProd : QVec → QVec → ℂ     -- ∙
  -- Hermitian conjugate (dagger) — MUST NOT be emitted as axiom in phase 2
  axiom dagger     : QMat → QMat          -- M† ≡ conjTranspose M
  -- Unitary predicate
  axiom unitaryMat : QMat → Prop           -- M† * M = 1 ∧ M * M† = 1
  -- Locales as structures
  structure StateQbit (n : ℕ) : Type where
    vec  : QVec
    hDim : dimVec vec = 2^n
    hNorm : True  -- placeholder; phase 2: ‖vec‖ = 1
  structure Gate (n : ℕ) : Type where
    mat  : QMat
    hDim : dimRow mat = 2^n
    hSq  : dimRow mat = dimCol mat
    hU   : unitaryMat mat
  -- Ket / bra
  axiom ketVec     : QVec → QMat          -- |v⟩
  axiom braVec     : QMat → QMat          -- ⟨v|  (= dagger of ket column mat)
  axiom innerProd  : QVec → QVec → ℂ     -- ⟨u|v⟩
  -- cpx_vec_length (norm)
  axiom cpxVecLen  : QVec → ℝ            -- ∥v∥
  -- cpx_sqr_mat typedef  (phase 1: opaque; phase 2: subtype {M : QMat // dimRow M = dimCol M})
  opaque CpxSqrMat : Type := Unit
  axiom sqrMatToMat : CpxSqrMat → QMat   -- Rep morphism
  -- Phase-2 upgrade path: replace opaque types with Matrix-backed concrete types
  -- and derive all axioms as theorems from Mathlib lemmas.
Fix target (translator):
  Gate: generate IMDPrelude.lean BEFORE generating any Theories/*.lean.
  Validation: `lake build CATEPTMain.AFPBridge.IMD.IMDPrelude` EXIT:0 before
  any theory file is generated.
Validation:
  - IMDPrelude.lean: no unknown identifier on first build
  - All 13 theory files import `CATEPTMain.AFPBridge.IMD.IMDPrelude` not any NoFTL prelude
  - `lake build CATEPTMain.AFPBridge.IMD.IMDPrelude` EXIT:0

────────────────────────────────────────────────────────────────────────────────
## IMD-PRE-003  Concrete type map — no opaque collapse for well-known operators (P1)
Severity: P1 — NoFTL lesson (TRL-002): collapsing types to opaque objects breaks hypothesis typing
Context:
  In NoFTL, binary relations were collapsed to `NoFTLObj` via CoeFun, hiding all type structure.
  IMD has a similar risk: `cpx_sqr_mat` has a coercion `cpx_sqr_mat_to_cpx_mat` in AFP.
  This coercion must be mapped to a transparent bridge, not elided into opaque type confusion.
Critical mappings (must not be collapsed):
  AFP                           Lean 4 emit rule
  ─────────────────────────────────────────────────────────────────────────────
  dagger M (M†)                 MUST emit `Matrix.conjTranspose M` (phase 2)
                                or `dagger M` axiom (phase 1). NEVER an opaque object.
  M * N (matrix product)        MUST emit `M * N` (HMul instance). NEVER `matMulOpaque`.
  M ⊗ N (tensor / Kronecker)    MUST emit `Matrix.kronecker M N`. NEVER `tensorOpaque`.
                                WARNING: `⊗` notation conflicts with TensorProduct;
                                use `Matrix.kronecker` prefix form to avoid TRL-007 analog.
  unitary M                     MUST emit `unitaryMat M` predicate. NEVER Bool-coerced.
  carrier_mat m n               Drop entirely: use type `Matrix m n ℂ` directly.
  cpx_sqr_mat_to_cpx_mat        Phase-1: axiom sqrMatToMat. Phase-2: subtype coercion.
  cnj z (complex conjugate)     MUST emit `starRingEnd ℂ z` or `conj z`. NEVER opaque.
  cmod z (complex modulus)      MUST emit `Complex.abs z` or `‖z‖`. NEVER opaque.
  Re z / Im z                   MUST emit `z.re` / `z.im`. NEVER opaque.
  state_qbit n (set of states)  Emit as `Set QVec` or `{v : QVec | dimVec v = 2^n ∧ ...}`
  gate n A (locale predicate)   Emit as `Gate n` structure field check or predicate.
  real_to_cpx_mat               MUST emit `Matrix.map M (algebraMap ℝ ℂ)` not opaque.
Fix target (translator):
  Type-preserving emission rule: scan each AFP constant for its AFP type.
  For constants whose AFP type maps to a Mathlib type exactly, emit the Mathlib form.
  Only fall back to opaque axioms for AFP constants with no known Mathlib analog.
  Add a "known-concrete" allowlist: dagger, mul_mat, one_mat, cnj, cmod, Re, Im.
Validation:
  - `grep "dagger" Theories/Quantum.lean` must show `Matrix.conjTranspose` or `dagger` axiom
    call, NOT `QMat` returning `QMat` via an opaque collision
  - `grep "unitaryMat\|unitary" Theories/Quantum.lean` → predicate form, not Bool
  - `grep "kronecker\|tensor" Theories/Tensor.lean` → `Matrix.kronecker` or `tensorMat` axiom

────────────────────────────────────────────────────────────────────────────────
## IMD-PRE-004  Binder-analysis pre-pass — enforce binderInferenceSafe (P1)
Severity: P1 — NoFTL lesson (TRL-001, TRL-004): wrong binder types caused ~40 compile errors
Context:
  IMD locales (`state`, `gate`) carry fixed `n : ℕ` and `A : complex mat` params.
  These must become explicit structure fields or typeclass parameters, not free binders.
  Error pattern to prevent (analogous to TRL-001 for NoFTL):
    theorem lemFoo (A : QMat → QMat) ...  -- translator inferred function type for gate param
    -- ERROR: application type mismatch (A is a gate matrix, not a function on matrices)
  IMD-specific binder rules:
    AFP Isabelle         Lean 4 IMD binder
    ─────────────────────────────────────────────────────────────────────────
    n :: nat (locale)    (n : ℕ) explicit
    A :: complex mat     (A : QMat) explicit (phase 1) or (A : Matrix (2^n) (2^n) ℂ) (phase 2)
    v :: complex vec     (v : QVec) explicit (phase 1) or (v : Matrix (2^n) 1 ℂ) (phase 2)
    M :: cpx_sqr_mat     (M : CpxSqrMat) — NOT (M : QMat → QMat)
    U :: complex mat (unitary) (U : QMat) with hypothesis (hU : unitaryMat U)
    l :: complex mat (gate A)  (l : Gate n) or explicit (A : QMat) (hGate : Gate n)
Binder pre-pass rules:
  RULE B1 (from TRL-001): emit `v : T→T` ONLY if v appears applied to an argument in body.
  RULE B2 (from TRL-004): emit `v : QVec` (not QMat) if v is used as argument to dimVec.
  RULE B3 (NEW for IMD): `cpx_sqr_mat` vars → always `CpxSqrMat`, never `QMat → QMat`.
  RULE B4 (NEW for IMD): locale `n` parameter → always `(n : ℕ)`, never inferred as `QMat`.
  RULE B5 (NEW for IMD): `complex mat` in locale `gate` context → `(A : QMat)` with explicit
    `(hDim : dimRow A = 2^n)` hypothesis emitted separately.
Fix target (translator):
  Pre-generation: for each AFP locale, extract the fixed parameters and hypothesis list.
  Emit them as `(param : Type)` explicit parameters in every theorem that is in that locale.
  Gate the binder-analysis pre-pass on ALL theorems from IMD before generating .lean files.
  The pass must produce a validated binder map before emission begins.
Validation:
  - `grep "(A : QMat → " Theories/Quantum.lean` → 0 hits
  - `grep "(n : QMat)" Theories/*.lean` → 0 hits
  - `grep "(M : CpxSqrMat → " Theories/*.lean` → 0 hits

────────────────────────────────────────────────────────────────────────────────
## IMD-PRE-005  Name recovery — use AFP theorem names, never smoke_<hash> (P1)
Severity: P1 — NoFTL lesson (TRL-017): smoke_<hash> names are useless for downstream integration
Context:
  The IMD AFP session has well-named lemmas: `dagger_of_X`, `X_is_gate`, `X_inv`,
  `H_is_gate`, `CNOT_is_gate`, `state_to_state_qbit`, `inner_prod_is_sesquilinear`, etc.
  These names must be preserved in the Lean 4 output.
Name recovery strategy:
  - Map AFP `lemma foo` → Lean 4 `theorem foo`
  - Map AFP `theorem foo` → Lean 4 `theorem foo`
  - Map AFP `definition foo` → Lean 4 `def foo` or `noncomputable def foo`
  - Map AFP locale `(in state)` prefix → include locale params in theorem signature
    and suffix theorem name with locale clarifier if collision: e.g. `state_to_state_qbit`
  - Map AFP `[simp]` attribute → `@[simp]` attribute in Lean 4
  - Map AFP `typedef cpx_sqr_mat` → `opaque CpxSqrMat` with note
  Never emit: `theorem smoke_deadbeef`, `theorem th_00042`, or any hash-based name.
Critical name list (from Quantum.html — must appear verbatim in Theories/Quantum.lean):
  dagger_of_X, X_inv, X_is_gate, Y_is_gate, Z_is_gate
  dagger_of_H, H_is_gate, H_values, H_without_scalar_prod
  CNOT_is_gate, S_is_gate, T_is_gate
  state_to_state_qbit, cpx_vec_length_inner_prod
  inner_prod_is_sesquilinear, inner_prod_is_linear, inner_prod_cnj
  unitary_is_isometry, id_is_unitary, id_is_gate
  dagger_of_id, dim_row_of_dagger, dim_col_of_dagger
Fix target (translator):
  Name recovery pass: extract theorem/lemma names from AFP HTML or .thy source
  and inject them into the IR before emission. Fail loudly (not silently with hash)
  if name is unavailable.
Validation:
  - `grep "smoke_" Theories/*.lean` → 0 hits
  - `grep "dagger_of_X\|X_is_gate\|H_is_gate\|CNOT_is_gate" Theories/Quantum.lean` → correct hits

────────────────────────────────────────────────────────────────────────────────
## IMD-PRE-006  No autoImplicit — all binders explicit from the start (P1)
Severity: P1 — NoFTL lesson (TRL-019): autoImplicit true masked all binder defects
Context:
  IMD Lean 4 output must have `set_option autoImplicit false` at the top of every
  theory file. This is the CATEPTMain project default and is required for
  Mathlib compatibility.
  Setting `autoImplicit true` would mask all binder-type errors from IMD-PRE-004,
  producing silently wrong types that only fail at proof time.
Pre-condition: IMD-PRE-004 (binder analysis) must be complete and validated before
  any file with `set_option autoImplicit false` can be emitted cleanly.
Fix target (translator):
  Standard header for all IMD theory files:
    set_option autoImplicit false
    import CATEPTMain.AFPBridge.IMD.IMDPrelude
    namespace CATEPTMain.AFPBridge.IMD.Theories
    ...
    end CATEPTMain.AFPBridge.IMD.Theories
  NEVER emit `set_option autoImplicit true`.
Validation:
  - `grep "autoImplicit true" Theories/*.lean` → 0 hits
  - `grep "autoImplicit false" Theories/*.lean | wc -l` → 13 (one per theory file)

────────────────────────────────────────────────────────────────────────────────
## IMD-TH-001  Theory: Basics (P2)
AFP file: Isabelle_Marries_Dirac/Basics.thy
Dependency: Jordan_Normal_Form
Content summary (from Basics.html):
  - Set-theoretic utility lemmas (set_2, set_4, set_8, set_4_disj, index_sl_four)
  - Arithmetic lemmas for index div/mod calculations (index_div_eq, index_mod_eq,
    less_power_add_imp_div_less, div_mult_mod_eq_minus, neq_imp_neq_div_or_mod)
  - Matrix product index theorem (index_matrix_prod)
  - Sum manipulation lemmas (sum_insert, sum_of_index_diff)
  - Exponential/complex lemmas (exp_of_real, exp_of_real_cnj, exp_of_half_pi,
    sin_of_quarter_pi, cos_of_quarter_pi, sin_squared_le_one)
Translation challenge: MEDIUM
  - Most lemmas are arithmetic / real-analysis facts with Mathlib analogs.
  - `index_matrix_prod` — Mathlib's `Matrix.mul_apply` is the direct analog.
  - `index_one_mat_div_mod` — requires `Fin` arithmetic; `Nat.div_mul_mod` etc.
  - The `set_2`, `set_4` family — `Finset.card_fin`, `Fin.cases` in Lean 4.
Emit strategy:
  - Pure `sorry` proofs for phase 1 (theorems are well-stated with explicit binders).
  - Target: all Basics lemmas are definitional or simp-derivable in phase 2.
  - Import: `Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic` for sin/cos/exp.
Validation:
  - `lake build CATEPTMain.AFPBridge.IMD.Theories.Basics` EXIT:0

────────────────────────────────────────────────────────────────────────────────
## IMD-TH-002  Theory: Binary_Nat (P2)
AFP file: Isabelle_Marries_Dirac/Binary_Nat.thy
Dependency: HOL (standard)
Content summary: n-bit binary representation of natural numbers; `bin_rep n i` gives
  the list of n bits of i.
Translation challenge: MEDIUM
  - Isabelle's `bin_rep : ℕ → ℕ → bool list` maps to `Nat.testBit` or
    `Nat.bits` in Lean 4 / Mathlib.
  - List indexing: AFP `bin_rep n i ! k` → `Nat.testBit i (n-1-k)` in Lean 4.
  - Note: `bin_rep` returns `nat` list (0/1), not `bool` list. Map to `Fin 2` values.
Critical invariant to preserve: `∀ i < 2^n, i = ∑ k < n, bin_rep n i ! k * 2^k`
  (binary representation completeness). This must be the key theorem of Binary_Nat.lean.
Emit strategy:
  - Phase 1: `def binRep (n i : ℕ) : List ℕ := ...` via `Nat.testBit`
  - Phase 2: prove all lemmas using `Nat.testBit_lt_two`, `Nat.sum_testBit` etc.
Validation:
  - `lake build CATEPTMain.AFPBridge.IMD.Theories.Binary_Nat` EXIT:0

────────────────────────────────────────────────────────────────────────────────
## IMD-TH-003  Theory: Complex_Vectors (P2)
AFP file: Isabelle_Marries_Dirac/Complex_Vectors.thy
Dependency: Jordan_Normal_Form.Matrix, VectorSpace
Content summary: complex inner product space on `complex vec`; cpx_vec_length,
  inner product abbreviation (using scalar_prod), orthogonality.
Translation challenge: HIGH
  - AFP's `complex vec` is `Jordan_Normal_Form`'s dynamically-sized vector.
  - Mathlib's inner product spaces are Hilbert spaces on FiniteDimensional types.
  - Phase-1 strategy: axiomatize `innerProd : QVec → QVec → ℂ` and `cpxVecLen : QVec → ℝ`.
  - Phase-2 strategy: use `EuclideanSpace ℂ (Fin n)` or `PiLp 2 (fun _ : Fin n => ℂ)`.
  - CoeFun risk: AFP coercion pattern between `complex vec` and `complex mat` column
    must not collapse (IMD-PRE-003 rule applies here).
Key theorems: cpx_vec_length_inner_prod, inner_prod_cnj, inner_prod_is_linear,
  inner_prod_is_sesquilinear (bilinearity over ℂ).
Validation:
  - `lake build CATEPTMain.AFPBridge.IMD.Theories.Complex_Vectors` EXIT:0

────────────────────────────────────────────────────────────────────────────────
## IMD-TH-004  Theory: Quantum (P1 — highest complexity)
AFP file: Isabelle_Marries_Dirac/Quantum.thy
Dependency: Jordan_Normal_Form.Matrix, Basics, Binary_Nat
Content summary: qubits (state_qbit), dagger (M†), unitary, gate locale,
  ket/bra, Bell states, Pauli gates (X/Y/Z), Hadamard (H), CNOT, S, T gates,
  inner product properties under unitary transformation.
Translation challenge: CRITICAL (highest in session)
  REASON 1 — `typedef cpx_sqr_mat`:
    Isabelle `typedef cpx_sqr_mat = {M | square_mat M}` creates a new type with
    `Rep_cpx_sqr_mat / Abs_cpx_sqr_mat` morphisms and a coercion `cpx_sqr_mat_to_cpx_mat`.
    Lean 4 translation: `structure CpxSqrMat (n : ℕ) where mat : Matrix (Fin n) (Fin n) ℂ`
    or phase-1 opaque `opaque CpxSqrMat : Type := Unit` with bridge axioms.
    CRITICAL: do NOT emit `CpxSqrMat` as `QMat → QMat` — this is the IMD analog of NoFTL
    TRL-002 CoeFun collapse.
  REASON 2 — `dagger` notation `M†`:
    In AFP, `dagger M` is definable as `conjTranspose M`. In Lean 4, Mathlib already has
    `Matrix.conjTranspose` and notation `Mᴴ`. Phase-1: axiom; phase-2: use Mathlib.
    CRITICAL: `dagger` MUST NOT be emitted as an axiom returning `QMat` from `QMat`
    if `QMat` is opaque — this would block all downstream reasoning about dagger.
  REASON 3 — `locale gate`:
    AFP locale `gate n A` has assumptions: `dim_row A = 2^n`, `square_mat A`, `unitary A`.
    Every `(in gate)` theorem has these implicit assumptions. Failure to inject them
    as explicit hypotheses was a key NoFTL v0 error.
    Lean 4 emit: for every `(in gate)` lemma, prepend:
      `(A : QMat) (hRow : dimRow A = 2^n) (hSq : dimRow A = dimCol A) (hU : unitaryMat A)`
  REASON 4 — Gate matrix definitions (X, Y, Z, H, CNOT, S, T, bell00..11):
    These are concrete `2×2` and `4×4` matrices. Phase-1: emit as `def X : QMat := ...`
    with axiomatized index access. Phase-2: emit as `def X : Matrix (Fin 2) (Fin 2) ℂ :=
    ![![0,1],![1,0]]` (using Lean 4 matrix notation).
    CautionL Bell states are `4×1` column matrices (ket vectors); emit as `QMat` with
    `dimRow = 4` and `dimCol = 1`.
  REASON 5 — Notation conflicts (⊗, †, ⟨|⟩):
    `†` for dagger: Lean 4 Mathlib uses `ᴴ` (star); avoid redeclaring notation.
    `⊗` for tensor: conflicts with `TensorProduct` notation; use `Matrix.kronecker`.
    `⟨u|v⟩` bra-ket: avoid infix `|` notation (tokenizer ambiguity); use `innerProd u v`.
    RULE: do not emit any notation that conflicts with Mathlib or uses `|` as infix.
Key theorems to validate by name (IMD-PRE-005):
  dagger_of_prod, dagger_of_id, id_is_unitary, id_is_gate
  gate_of_prod (composition of gates), unitary_of_iso
  dagger_of_X, X_inv, X_is_gate, Y_is_gate, Z_is_gate
  H_is_gate, H_without_scalar_prod, H_values
  CNOT_is_gate, S_is_gate, T_is_gate
  state_to_state_qbit (‖state‖ = 1 → col ∈ state_qbit)
  unitary_preserves_inner_prod, cpx_vec_length_inner_prod
Validation:
  - No `CpxSqrMat → QMat` function-type binders (IMD-PRE-004 rule)
  - No notation for `†` that shadows Mathlib `ᴴ`
  - Name list check (IMD-PRE-005): all 30 named lemmas present
  - `lake build CATEPTMain.AFPBridge.IMD.Theories.Quantum` EXIT:0

────────────────────────────────────────────────────────────────────────────────
## IMD-TH-005  Theory: Tensor (P1)
AFP file: Isabelle_Marries_Dirac/Tensor.thy
Dependency: Quantum, Matrix_Tensor
Content summary: tensor product of complex matrices (Kronecker product);
  `tensor_mat M N` (≡ `M ⊗ N`); dimension lemmas; distributivity with dagger.
Translation challenge: HIGH
  - AFP's tensor product = Kronecker product of matrices = `Matrix.kronecker` in Mathlib.
  - `Matrix.kronecker M N` has type `Matrix (m₁ × m₂) (n₁ × n₂) ℂ` in Lean 4.
    The index type is `Fin m₁ × Fin m₂`, not `Fin (m₁ * m₂)`. This requires
    `Fin.equiv_finProd` or index reindexing in proofs.
  - Phase-1: `axiom tensorMat : QMat → QMat → QMat` with axioms for dim.
  - Phase-2: `def tensorMat (M : Matrix (Fin m₁) (Fin n₁) ℂ) (N : Matrix (Fin m₂) (Fin n₂) ℂ)
    : Matrix (Fin (m₁ * m₂)) (Fin (n₁ * n₂)) ℂ := Matrix.reindex ... (Matrix.kronecker M N)`
    (reindex via `finProdFinEquiv.symm`).
  WARNING on notation: `⊗` is used in Mathlib for `TensorProduct`. IMD translator
    MUST NOT emit `notation "⊗" => tensorMat` because it will conflict in any file
    that also imports `Mathlib.LinearAlgebra.TensorProduct`. Emit as `tensorMat` prefix only.
Key theorems: dagger_tensor (M ⊗ N)† = M† ⊗ N†; dim_tensor; tensor_gate (gate composites).
Validation:
  - No `⊗` notation defined in Theories/Tensor.lean or IMDPrelude.lean
  - `lake build CATEPTMain.AFPBridge.IMD.Theories.Tensor` EXIT:0

────────────────────────────────────────────────────────────────────────────────
## IMD-TH-006  Theory: More_Tensor (P2)
AFP file: Isabelle_Marries_Dirac/More_Tensor.thy
Dependency: Tensor
Content summary: extended tensor properties; partial tensor applications on
  multi-qubit systems; `ptensor_mat` (partial/mixed tensor); dimension bookkeeping.
Translation challenge: MEDIUM-HIGH
  - Extends IMD-TH-005 challenges with multi-qubit dimension arithmetic.
  - Key identity: `(A ⊗ B) * (C ⊗ D) = (A*C) ⊗ (B*D)` for conforming dimensions.
  - In Lean 4: `Matrix.kronecker_mul_kronecker` exists in Mathlib.
  - `ptensor_mat` (partial tensor) requires careful index handling.
Validation:
  - `lake build CATEPTMain.AFPBridge.IMD.Theories.More_Tensor` EXIT:0

────────────────────────────────────────────────────────────────────────────────
## IMD-TH-007  Theory: Measurement (P2)
AFP file: Isabelle_Marries_Dirac/Measurement.thy
Dependency: Quantum, Tensor
Content summary: projective quantum measurement; measurement postulates;
  probability of outcome; post-measurement state.
Translation challenge: HIGH
  - Measurement involves probability (real-valued outcomes) and non-determinism.
  - AFP defines measurement as projection operators (hermitian idempotents).
  - Lean 4 phase-1: axiomatize `measProb`, `measOutcome` as opaque functions.
  - Phase-2: use `Matrix.IsHermitian` and `Matrix.IsProjection` from Mathlib.
  - Key invariant: probabilities sum to 1 (requires norm lemmas from Complex_Vectors).
Validation:
  - `lake build CATEPTMain.AFPBridge.IMD.Theories.Measurement` EXIT:0

────────────────────────────────────────────────────────────────────────────────
## IMD-TH-008  Theory: Entanglement (P2)
AFP file: Isabelle_Marries_Dirac/Entanglement.thy
Dependency: Quantum, Tensor
Content summary: separability of quantum states; entanglement witnesses;
  Schmidt decomposition (implicit); Bell state entanglement proofs.
Translation challenge: HIGH
  - Entanglement involves tensor product structure on composite Hilbert spaces.
  - AFP uses Bell states (bell00..11) from Quantum; these must be imported cleanly.
  - Key predicate: `separable n m v` ↔ ∃ v1 v2, v = v1 ⊗ v2.
  - In Lean 4: `separable` as `∃ (v1 : QVec) (v2 : QVec), v = tensorMat v1 v2`.
Validation:
  - `lake build CATEPTMain.AFPBridge.IMD.Theories.Entanglement` EXIT:0

────────────────────────────────────────────────────────────────────────────────
## IMD-TH-009  Theory: Quantum_Teleportation (P2)
AFP file: Isabelle_Marries_Dirac/Quantum_Teleportation.thy
Dependency: Quantum, Tensor, Measurement
Content summary: full verification of the quantum teleportation protocol;
  circuit correctness; state reconstruction after measurement and correction.
Translation challenge: HIGH
  - Teleportation proof is a circuit equality: (classical correction circuit) ∘
    (Bell measurement circuit) applied to EPR pair + state = original state.
  - Requires correct composition rules for gates and tensors (IMD-TH-005/006).
  - Phase-1: sorry-stub proofs are acceptable; the theorem statements must be
    faithfully translated (no sorry in hypothesis/conclusion types).
Validation:
  - `lake build CATEPTMain.AFPBridge.IMD.Theories.Quantum_Teleportation` EXIT:0

────────────────────────────────────────────────────────────────────────────────
## IMD-TH-010  Theory: Deutsch (P2)
AFP file: Isabelle_Marries_Dirac/Deutsch.thy
Dependency: Quantum, Tensor
Content summary: Deutsch's algorithm; oracle functions (constant / balanced);
  circuit evaluation; correctness theorem for single-qubit version.
Translation challenge: MEDIUM
  - Deutsch's algorithm uses H ⊗ H and CNOT gates; all defined in Quantum.
  - Oracle is represented as a quantum gate (unitary matrix encoding f : bool→bool).
  - Key predicate: `is_const_fun f` and `is_balanced_fun f`.
  - In Lean 4: `def IsDeutschConst (f : Bool → Bool) : Prop := f 0 = f 1`
  - Phase-1: sorry proofs; phase-2: decide by cases (finite type).
Validation:
  - `lake build CATEPTMain.AFPBridge.IMD.Theories.Deutsch` EXIT:0

────────────────────────────────────────────────────────────────────────────────
## IMD-TH-011  Theory: Deutsch_Jozsa (P2)
AFP file: Isabelle_Marries_Dirac/Deutsch_Jozsa.thy
Dependency: Deutsch, More_Tensor
Content summary: n-qubit generalization of Deutsch's algorithm; Hadamard transforms;
  quantum parallelism; correctness theorem for the n-qubit case.
Translation challenge: MEDIUM-HIGH
  - Generalizes Deutsch to n-qubit functions via Hadamard tensor n times.
  - Requires `n`-fold Kronecker product of H: `H^⊗n` — emit as `tensorPow H n` axiom.
  - `dim_row (tensorPow H n) = 2^n` — requires IMD-TH-001 arithmetic lemmas.
Validation:
  - `lake build CATEPTMain.AFPBridge.IMD.Theories.Deutsch_Jozsa` EXIT:0

────────────────────────────────────────────────────────────────────────────────
## IMD-TH-012  Theory: No_Cloning (P2)
AFP file: Isabelle_Marries_Dirac/No_Cloning.thy
Dependency: Quantum, Tensor
Content summary: formal proof of the quantum no-cloning theorem;
  if a unitary gate copies arbitrary states, then all states are equal.
Translation challenge: MEDIUM
  - No-cloning is a clean mathematical proof: linearity of unitaries implies
    ⟨φ|ψ⟩² = ⟨φ|ψ⟩ (so ⟨φ|ψ⟩ = 0 or 1); then inner-product sesquilinearity closes it.
  - Requires inner product lemmas from Complex_Vectors (IMD-TH-003).
  - Phase-2 proof is achievable: map to Mathlib inner_product_space properties.
Key theorem name: `no_cloning` (AFP theorem) — must appear verbatim (IMD-PRE-005).
Validation:
  - `grep "no_cloning" Theories/No_Cloning.lean` → 1+ hits
  - `lake build CATEPTMain.AFPBridge.IMD.Theories.No_Cloning` EXIT:0

────────────────────────────────────────────────────────────────────────────────
## IMD-TH-013  Theory: Quantum_Prisoners_Dilemma (P2)
AFP file: Isabelle_Marries_Dirac/Quantum_Prisoners_Dilemma.thy
Dependency: Quantum, Tensor, Measurement
Content summary: quantum game-theoretic version of the prisoner's dilemma;
  Eisert-Wilkens scheme; entanglement as a game resource; Nash equilibrium.
Translation challenge: MEDIUM-HIGH
  - Uses rotation gate family parameterized by (θ, φ): requires `exp (ι * θ)` arithmetic.
  - Nash equilibrium formalization requires comparing real-valued payoffs.
  - Has no equivalent in prior AFP work in this repo — novel territory.
  - Phase-1: axiom stubs for payoff functions; sorry proofs for Nash equilibrium.
Validation:
  - `lake build CATEPTMain.AFPBridge.IMD.Theories.Quantum_Prisoners_Dilemma` EXIT:0

────────────────────────────────────────────────────────────────────────────────
## IMD-INT-001  Integration bridge: CATEPTMain.Integration.DiracBridge (P2)
Severity: P2 — high (integration contract required for catept-main governance)
Context:
  Following the MaxwellCurveSpacePphi2Bridge pattern (Integration/MaxwellCurveSpacePphi2Bridge.lean),
  an integration bridge is required that:
    1. Imports the IMD theory files
    2. Defines a structure encoding the AFP session's key invariants in CATEPTMain idiom
    3. Proves at least one contract theorem relating the IMD types to CATEPTMain types
Target file: CATEPTMain/Integration/DiracBridge.lean
Namespace: CATEPTMain.Integration
Content plan:
  import CATEPTMain.AFPBridge.IMD.IMDPrelude
  import CATEPTMain.AFPBridge.IMD.Theories.Quantum
  import CATEPTMain.AFPBridge.IMD.Theories.No_Cloning
  set_option autoImplicit false
  namespace CATEPTMain.Integration
  /-- Contract: a quantum gate preserves the norm of quantum states. -/
  structure DiracGateBridgeContract where
    n      : ℕ
    gate   : CATEPTMain.AFPBridge.IMD.Gate n
    /-- Any state in state_qbit n maps to a state in state_qbit n under the gate. -/
    hPres  : ∀ (v : QVec),
               dimVec v = 2^n →
               cpxVecLen v = 1 →
               cpxVecLen (colVec (matMul gate.mat (ketVec v)) 0) = 1
  /-- Existence: Id n is a valid bridge contract instance. -/
  theorem diracBridgeContractExists (n : ℕ) : ∃ _ : DiracGateBridgeContract, True :=
    ⟨{ n := n, gate := sorry, hPres := sorry }, trivial⟩
  end CATEPTMain.Integration
Validation:
  - `lake build CATEPTMain.Integration.DiracBridge` EXIT:0
  - Structure fields match IMD prelude types exactly

────────────────────────────────────────────────────────────────────────────────
## IMD-TLA-001  New TLA+ model for IMD translation control loop (P2)
Severity: P2 — high (governance model for IMD pre-generation gates)
Target file:
  navier-stokes-project-clean/verification/tla/afp_isabelle_to_lean_control_loop/
  imd_lean4_translation_control.tla
  (extends translator_control_loop.tla framework)
Change:
  CONSTANTS THEORIES ← the 13 IMD theory names
  CONSTANTS AFP_DEPS ← {"Jordan_Normal_Form", "Matrix_Tensor", "VectorSpace"}
  State variable: preGenerationGatesPassed : THEORIES → BOOLEAN
  State variable: preludeCompiles : BOOLEAN
  Actions:
    RunPreGenGate(thy) — sets preGenerationGatesPassed[thy] to outcome of:
      - BinderAnalysisPass (IMD-PRE-004)
      - NameRecoveryPass (IMD-PRE-005)
      - TypeMapCheck (IMD-PRE-003)
    EmitTheoryFile(thy) — gated: ENABLED ONLY IF preGenerationGatesPassed[thy] = TRUE
    BuildPrelude — sets preludeCompiles; must run before any EmitTheoryFile
  Invariants:
    PreludeFirstInvariant ==
      ∀ thy ∈ THEORIES: emitted[thy] => preludeCompiles
    NoAutoImplicitInvariant ==
      ∀ thy ∈ THEORIES: built[thy] => autoImplicitDisabled[thy]
    NoSmokeNamesInvariant ==
      ∀ thy ∈ THEORIES: built[thy] =>
        ∀ name ∈ emittedNames[thy]: ¬ containsHash(name)
    BinderSafetyIMD ==
      ∀ thy ∈ THEORIES: built[thy] =>
        ∀ binder ∈ binders[thy]:
          isFunctionType(binder) => appliedInBody[binder]
    NoTensorNotationConflict ==
      ∀ thy ∈ THEORIES: emitted[thy] => "⊗" ∉ notations[thy]
    NoDaggerNotationConflict ==
      ∀ thy ∈ THEORIES: emitted[thy] => "†" ∉ definedNotations[thy]
Validation:
  TLC check on imd_lean4_translation_control.tla — 0 invariant violations in full state space

────────────────────────────────────────────────────────────────────────────────
## IMD-TLA-002  Extend afp_lean4_translation_error_classes.tla with IMD error classes (P2)
Severity: P2 — high (IMD introduces error classes not present in NoFTL taxonomy)
Target file:
  navier-stokes-project-clean/verification/tla/afp_lean4_translation_errors/
  afp_lean4_translation_error_classes.tla
New error classes to add (extend ErrorClasses set):
  "E13_cpx_sqr_mat_coefun_collapse"
    — typedef cpx_sqr_mat coercion emitted as function type QMat→QMat
    — remediation: "emit_as_subtype_or_opaque"
  "E14_tensor_notation_conflict"
    — ⊗ notation defined, conflicts with TensorProduct
    — remediation: "use_kronecker_prefix"
  "E15_dagger_notation_conflict"
    — † notation defined, shadows Mathlib ᴴ
    — remediation: "use_conjTranspose"
  "E16_locale_param_not_injected"
    — locale (state/gate) fixed params missing from theorem signature
    — remediation: "inject_locale_params_explicit"
  "E17_runtime_dim_as_type_param"
    — dim_row/dim_col used as runtime values that should be type-level ℕ
    — remediation: "promote_dim_to_type_param"
  "E18_bin_rep_list_indexing"
    — bin_rep n i ! k (AFP list index) emitted literally → Lean 4 List.get? needed
    — remediation: "emit_testBit_nat"
New invariants to add:
  CpxSqrMatSafe == ∀ t ∈ THEOREMS:
    errorClass[t] = "E13_cpx_sqr_mat_coefun_collapse" =>
    remediation[t] = "emit_as_subtype_or_opaque"
  TensorNotationSafe == ∀ t ∈ THEOREMS:
    errorClass[t] = "E14_tensor_notation_conflict" =>
    remediation[t] = "use_kronecker_prefix"
Validation:
  TLC check: 0 invariant violations

────────────────────────────────────────────────────────────────────────────────
## IMD-QA-001  Regression test suite for IMD translator output (P1)
Severity: P1 — pre-generation gate must all pass before any theory file is shipped
Target: scripts/check_imd_output.sh  (new script)
Checks (NoFTL-derived, adapted for IMD):
  1. No function-typed params for matrix/vector variables:
     grep "(A : QMat → \|V : QVec → " Theories/*.lean | wc -l → must be 0
  2. No CoeFun relation collapse:
     grep "(h[0-9]* : [A-Za-z]* [a-z] [a-z])" Theories/*.lean → must be 0
  3. No autoImplicit true:
     grep "autoImplicit true" Theories/*.lean | wc -l → must be 0
  4. No smoke_ theorem names:
     grep "theorem smoke_\|def smoke_" Theories/*.lean | wc -l → must be 0
  5. No ⊗ notation definition (tensor conflict):
     grep "notation.*⊗\|notation.*tensor" Theories/*.lean IMDPrelude.lean | wc -l → must be 0
  6. No † dagger notation definition (Mathlib ᴴ conflict):
     grep "notation.*†" Theories/*.lean IMDPrelude.lean | wc -l → must be 0
  7. All imports use CATEPTMain module root:
     grep "^import" Theories/*.lean | grep -v "CATEPTMain\|Mathlib" | wc -l → must be 0
  8. Prelude builds before theory files:
     lake build CATEPTMain.AFPBridge.IMD.IMDPrelude → must EXIT:0 FIRST
  9. No locale params missing from theorem signature:
     grep "in gate\|in state" Theories/Quantum.lean → must be 0
     (all locale params injectable; no Isabelle `(in locale)` left untranslated)
  10. All 13 theory files build:
     for thy in Basics Binary_Nat Complex_Vectors Quantum Tensor More_Tensor
                Measurement Entanglement Quantum_Teleportation Deutsch
                Deutsch_Jozsa No_Cloning Quantum_Prisoners_Dilemma ; do
       lake build CATEPTMain.AFPBridge.IMD.Theories.$thy → must EXIT:0
     done
IMD-specific additional checks (no analog in check_noftl_output.sh):
  11. dagger emitted correctly (not collapsed):
     grep "dagger\|conjTranspose" Theories/Quantum.lean → at least 1 hit
  12. No Matrix→QObj collapse (QMat kept as matrix-compatible type, not untyped object):
     grep "(: QMat → QMat → QMat)" Theories/Quantum.lean → must be 0
     (multiplication should be `matMul` or `*`, not a 3-arg function)
  13. Bell states present by name:
     grep "bell00\|bell01\|bell10\|bell11" Theories/Quantum.lean → 4 hits
Validation:
  Running `scripts/check_imd_output.sh` after generation must exit 0 with all 13 checks passing.
  Pre-shipment gating: zero IMD theory file is committed without all 13 checks green.

────────────────────────────────────────────────────────────────────────────────
## IMD-QA-002  Faithfulness delta metric for IMD (P2)
Severity: P2 — track translation quality improvement across phases
Context:
  Analogous to QA-002 for NoFTL. Defines a per-theorem quality score for IMD.
Metrics:
  faithful_stmt  = 1 if no opaque QMat/QVec collapse in theorem signature; 0 otherwise
  faithful_dagger = 1 if dagger emitted as axiom or Matrix.conjTranspose (not opaque); 0 otherwise
  faithful_names  = 1 if theorem name matches AFP name exactly; 0 if smoke_ or index-based
  faithful_proof  = 1 if proof is not solely `sorry`; 0 otherwise
  delta_total = faithful_stmt + faithful_dagger + faithful_names + faithful_proof  (0..4)
Phase-1 baseline targets (at initial emission):
  faithful_stmt   ≥ 0.7  (70% of theorems have correctly typed params)
  faithful_dagger  = 1.0  (all dagger calls are non-opaque even in phase 1)
  faithful_names   = 1.0  (all names recovered from AFP — IMD-PRE-005 is a hard gate)
  faithful_proof   = 0.0  (all sorry in phase 1 — acceptable)
Phase-2 targets:
  faithful_stmt   ≥ 1.0  (100% — all QMat replaced with Matrix (Fin n) (Fin m) ℂ)
  faithful_proof  ≥ 0.5  (50% non-sorry proofs using Mathlib tactics)
  delta_total     ≥ 3.0  per theorem on average
Validation:
  Add faithful_delta metric to `scripts/check_imd_output.sh` output section.
  Gate phase-2 merge on: faithful_stmt ≥ 0.9 AND faithful_names = 1.0.

-/

-- This file is a worklog / issue tracker. No runnable Lean 4 code is defined here.
-- Records are sorted by phase then severity: PRE (P1) → TH (P1/P2) → INT → TLA → QA.
-- IMD-PRE-* = pre-generation gate items (must all pass before any .lean is emitted)
-- IMD-TH-*  = per-theory translation plans (in AFP session order)
-- IMD-INT-* = integration bridge targets
-- IMD-TLA-* = TLA+ model update targets
-- IMD-QA-*  = validation / quality gate targets
