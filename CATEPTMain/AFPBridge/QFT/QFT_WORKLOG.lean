/-!
# QFT Translation Worklog — Quantum_Fourier_Transform → Lean 4
Source: AFP `Quantum_Fourier_Transform` (Pablo Manrique — January 28, 2025)
  https://www.isa-afp.org/entries/Quantum_Fourier_Transform.html
Target: Lean 4 / CATEPTMain, Lean 4.29+  (namespace CATEPTMain.AFPBridge.QFT)
License: BSD

Prior version: none — first translation of this AFP entry in this repo.
Methodology note: follows IMD_WORKLOG.lean tooling lessons. PRE gates must pass first.
  QFT has ONE theory file (QFT.thy) plus utilities; tight coupling with IMD throughout.

AFP entry abstract:
  Formalization of the Quantum Fourier Transform (QFT), a fundamental component of
  Shor's factoring algorithm. Proofs of correctness and unitarity. Proof by induction
  on the recursive definition. Builds directly on Isabelle Marries Dirac (Bordg et al.).

AFP session file order (for TH record numbering):
  1. QFT  (single main theory file)

AFP direct dependencies (bridge required):
  - Isabelle_Marries_Dirac (bridged: IMDPrelude.lean)
  - HOL standard library

Used by (downstream AFP): none currently listed

Citation: Pablo Manrique, AFP 2025. Proof of QFT unitarity and correctness.
Reference: Nielsen & Chuang §5.1; Bordg-Lachnitt-He (JAR 2021)

Mathlib modules used as semantic targets:
  - Mathlib.Analysis.Fourier.FourierTransform
  - Mathlib.NumberTheory.RootsOfUnity.Basic
  - Mathlib.Data.Complex.Exponential
  - Mathlib.Analysis.SpecialFunctions.Complex.Circle

All records graded by severity (P1=blocker/P2=high/P3=medium/P4=low)
and type (PRE/TH/INT/TLA/QA)
-/

--------------------------------------------------------------------------------
-- RECORD KEY
-- QFT-PRE-* = pre-generation gate items (must all pass before any .lean is emitted)
-- QFT-TH-*  = per-theory translation plans (AFP session order)
-- QFT-INT-* = integration bridge targets
-- QFT-TLA-* = TLA+ model extension targets
-- QFT-QA-*  = validation / quality gate targets
--------------------------------------------------------------------------------

/-!
────────────────────────────────────────────────────────────────────────────────
## QFT-PRE-001  AFP dependency bridge: IMD → QFT Lean 4 (P1)
Severity: P1 — blocker; QFT.thy uses IMD types throughout
Context:
  QFT.thy depends directly on IMD's:
    - `H` (Hadamard gate), `·†` (dagger), `tensorMat` (Kronecker product)
    - `gate` locale (with hRow / hSq / hU conditions)
    - `state_qbit` (normalized quantum states)
    - Bell/ket vector notation from Quantum.thy
  The QFT circuit is built recursively using:
    (1) Hadamard gate H applied to highest qubit
    (2) Controlled phase-rotation gates R_k for k=2..n
    (3) SWAP gates to reverse bit order
  All gate dimensions are `2ⁿ × 2ⁿ` matrices.
Strategy:
  Direct import chain: `import CATEPTMain.AFPBridge.IMD.IMDPrelude`
  Additional axioms for QFT:
    -- Controlled phase rotation matrix R_k (size 2×2 or 2ⁿ×2ⁿ in embedded form)
    noncomputable axiom phaseGate (k : ℕ) : QMat  -- 2×2 phase rotation e^{2πi/2^k}
    noncomputable axiom qftCircuit (n : ℕ) : QMat  -- full n-qubit QFT unitary
    -- qftCircuit has correct dimension
    axiom qftCircuit_dim_row (n : ℕ) : dimRow (qftCircuit n) = 2^n
    axiom qftCircuit_dim_col (n : ℕ) : dimCol (qftCircuit n) = 2^n
Key type correspondences:
  ω_n := e^{2πi/n}  →  Complex.exp (2 * Real.pi * Complex.I / n)
  R_k (phase gate)  →  ![![1, 0], ![0, Complex.exp (2 * Real.pi * Complex.I / 2^k)]]
  QFT_n (circuit)   →  qftCircuit n : QMat (axiom in phase-1)
Fix target:
  ω_n must NOT be emitted as a `ℂ → ℂ` function. It is a constant `ℂ`.
  `R_k` must NOT be emitted as `k : QMat → QMat`; must be `phaseGate k : QMat`.
Validation:
  - `grep "(omega : ℂ → \|(R_k : QMat →" QFTPrelude.lean Theories/QFT.lean` → 0 hits
  - `lake build CATEPTMain.AFPBridge.QFT.QFTPrelude` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## QFT-PRE-002  Prelude-first strategy: QFTPrelude.lean (P1)
Severity: P1 — QFT.lean must import QFTPrelude before anything else
Required prelude content:
  import CATEPTMain.AFPBridge.IMD.IMDPrelude
  import Mathlib.Data.Complex.Exponential
  import Mathlib.Analysis.SpecialFunctions.Complex.Circle
  set_option autoImplicit false
  namespace CATEPTMain.AFPBridge.QFT
  -- Primitive n-th root of unity
  noncomputable def omegaN (n : ℕ) : ℂ :=
    Complex.exp (2 * Real.pi * Complex.I / n)
  -- Phase rotation gate R_k
  noncomputable axiom phaseGate : ℕ → QMat
  axiom phaseGate_dim (k : ℕ) : dimRow (phaseGate k) = 2
  -- n-qubit QFT unitary
  noncomputable axiom qftCircuit : ℕ → QMat
  axiom qftCircuit_dim (n : ℕ) : dimRow (qftCircuit n) = 2^n
  -- QFT correctness predicate
  axiom IsQFTCorrect (n : ℕ) (U : QMat) : Prop
  end CATEPTMain.AFPBridge.QFT
Validation:
  - `lake build CATEPTMain.AFPBridge.QFT.QFTPrelude` EXIT:0
  - `Theories/QFT.lean` first import is `CATEPTMain.AFPBridge.QFT.QFTPrelude`
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## QFT-PRE-003  Concrete type map: roots of unity and phase gates (P1)
Severity: P1 — roots of unity handling is the dominant translation risk
Context:
  AFP QFT uses `exp (2 * pi * ii / 2^k)` as the phase rotation value.
  In Lean 4 / Mathlib:
    - `Complex.exp` is in `Mathlib.Data.Complex.Exponential`
    - `Complex.I` (imaginary unit `i`)
    - `Real.pi` for π
    - `Nat.cast` for coercion `2^k : ℂ`
  Critical: the AFP expression `exp (2 * pi * ii / (2^k : real))` must NOT
  be emitted as a free string interpolation. Must use:
    `Complex.exp (2 * Real.pi * Complex.I / (2^k : ℂ))`
Type map:
  AFP symbol                  Lean 4 target
  exp (2*pi*ii/2^k)           Complex.exp (2 * Real.pi * Complex.I / (2^k : ℂ))
  omega_n (n-th root)         omegaN n  (def in QFTPrelude)
  phase_gate k                phaseGate k : QMat
  R_2, R_3, ..., R_n          phaseGate 2, phaseGate 3, ..., phaseGate n
  qft n (QFT circuit on n q)  qftCircuit n : QMat
  classical DFT definition    (semantic target only; used for correctness statement)
Notation conflicts (IMD-TH-005 lesson applied):
  - Do NOT define `notation "ω" => omegaN` (Unicode subscripts fragile in Lean 4)
  - Use function call `omegaN n` everywhere
Validation:
  - `grep "exp (2 \* pi" Theories/QFT.lean` → 0 hits (Isabelle form must not survive)
  - `grep "Complex.exp\|omegaN" Theories/QFT.lean` → ≥1 hits
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## QFT-PRE-004  Binder analysis: inductive dimension arithmetic (P1)
Severity: P1 — QFT proof is inductive on qubit count `n`; dimension arithmetic is key
Context:
  QFT.thy proves unitarity and correctness by induction on n.
  The inductive step uses:
    `unitaryMat (qftCircuit (n+1)) ← unitaryMat (qftCircuit n)`
      combined with phase gate composition `phaseGate k * qftCircuit n`
  Binder rule for dimension:
    B11 — `n : ℕ` in QFT context always bounds `2^n × 2^n` matrix dimension;
          never emit as `(n : QMat)` or `(n : ℂ)`.
    B12 — `R_k` phase gate binder: always `(k : ℕ) (hk : 2 ≤ k)`, never free variable.
    B13 — Composition `A * B` in QFT: both `A B : QMat` with explicit dimension lemmas;
          do not emit dimension proof obligations as separate variables.
Strategy for inductive step:
  Phase-1 emit pattern for each `n`:
    axiom qftCircuit_unitary (n : ℕ) : unitaryMat (qftCircuit n)
    axiom qftCircuit_correct (n : ℕ) (v : QVec) (hv : dimVec v = 2^n) :
              IsQFTCorrect n (qftCircuit n)
Validation:
  `grep "(k : QMat\|(n : QMat" Theories/QFT.lean` → 0 hits
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## QFT-TH-001  Theory: QFT (P1 — sole main theory)
AFP file: Quantum_Fourier_Transform/QFT.thy
Dependency: Isabelle_Marries_Dirac (all of IMD session)
Content summary:
  The complete formalization of the n-qubit QFT circuit:
  1. Phase gate definition: R_k = [[1, 0], [0, e^{2πi/2^k}]] as 2×2 matrix
  2. Controlled-phase embedding: CR_k^(n,j) — R_k embedded in n-qubit space, acting on
     qubit j (controlled by qubit 0 in Nielsen-Chuang convention)
  3. Layer decomposition: QFT_{n+1} = (H ⊗ Id_{2^n}) · (∏ₖ CR_k^(n+1,k)) · (Id_2 ⊗ QFT_n)
  4. Correctness theorem: QFT_n |j⟩ = (1/√(2^n)) ∑ₖ e^{2πijk/2^n} |k⟩
  5. Unitarity: QFT_n is unitary for all n
Translation challenge: CRITICAL
  REASON 1 — Recursive circuit structure:
    QFT_{n+1} defined in terms of QFT_n using Kronecker tensor and matrix product.
    This recursive definition must be faithfully translated; emitting as a flat
    axiom loses the computation content.
    Phase-1: axiom `qftCircuit` with axioms for recursive step.
    Phase-2: expand to `def qftCircuit : ℕ → QMat` by structural recursion.
  REASON 2 — Sum with complex exponentials:
    Correctness requires `∑ k < 2^n, Complex.exp (...) * ketBasisVec n k`.
    In phase-1: axiomatize correctness predicate `IsQFTCorrect`.
    In phase-2: reduce to `Finset.sum` over basis states.
  REASON 3 — Embedded controlled gates:
    The k-th controlled phase gate embedded in n qubits uses:
      `Id_{2^(k-1)} ⊗ R_k ⊗ Id_{2^(n-k)}`
    This requires n-fold Kronecker product; extends IMD-TH-006 `tensorPow` pattern.
    Emit as `axiom ctrlPhaseGate (n k : ℕ) : QMat` in phase-1.
  REASON 4 — Bit-reversal permutation (SWAP network):
    AFP QFT includes bit-reversal at the end (via SWAP gates).
    This is a permutation matrix; phase-1 axiom, phase-2 `Matrix.reindex finReverse`.
Key theorem names (AFP → Lean 4):
  qft_is_unitary       → qftCircuit_unitary (axiom in phase-1)
  qft_correct          → IsQFTCorrect (predicate)
  phase_gate_unitary   → phaseGate_unitary (axiom)
  controlled_phase_unitary → ctrlPhaseGate_unitary (axiom)
Phase-2 upgrade path:
  - `qftCircuit` by structural recursion on n
  - `IsQFTCorrect n U` unfolds to explicit Finset.sum equality
  - proof of correctness by induction, using Lean 4 `ring` / `norm_num` for base case
Validation:
  - `grep "qft_is_unitary\|qft_correct\|qftCircuit_unitary" Theories/QFT.lean` → ≥1 each
  - `grep "IsQFTCorrect" Theories/QFT.lean` → ≥1 (correctness predicate present)
  - `lake build CATEPTMain.AFPBridge.QFT.Theories.QFT` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## QFT-INT-001  Integration bridge: CATEPTMain.Integration.QFTBridge (P2)
Severity: P2 — integration contract for catept-main governance
Target file: CATEPTMain/Integration/QFTBridge.lean
Namespace: CATEPTMain.Integration
Content plan:
  import CATEPTMain.AFPBridge.QFT.QFTPrelude
  import CATEPTMain.AFPBridge.QFT.Theories.QFT
  import CATEPTMain.AFPBridge.IMD.Theories.Quantum
  set_option autoImplicit false
  namespace CATEPTMain.Integration
  /-- Contract: the QFT circuit is unitary for every qubit count n. -/
  structure QFTBridgeContract where
    n      : ℕ
    /-- QFT circuit on n qubits is unitary. -/
    hU     : unitaryMat (qftCircuit n)
    /-- QFT circuit has correct dimension. -/
    hDim   : dimRow (qftCircuit n) = 2^n
  theorem qftBridgeContractExists (n : ℕ) : ∃ _ : QFTBridgeContract, True :=
    ⟨{ n := n, hU := sorry, hDim := sorry }, trivial⟩
  end CATEPTMain.Integration
Validation:
  - `lake build CATEPTMain.Integration.QFTBridge` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## QFT-TLA-001  TLA+ extension for QFT translation control loop (P3)
Severity: P3 — extends IMD TLA model with QFT-specific invariants
New CONSTANTS: THEORIES_QFT ← {"QFT"}
New invariants:
  QFTRecursiveDefPresent ==
    built["QFT"] =>
      ∃ def ∈ defs["QFT"]: name(def) = "qftCircuit" ∧ isRecursive(def)
  OmegaNNotation ==
    ∀ thy ∈ THEORIES_QFT: built[thy] =>
      "notation.*ω" ∉ notationDefs[thy]  -- no omega Unicode notation
  PhaseGateAxiomatic ==
    built["QFT"] =>
      "phaseGate" ∈ axiomNames["QFT"] ∨ "phaseGate" ∈ defNames["QFT"]
  QFTUnitarityPresent ==
    built["QFT"] => "qftCircuit_unitary" ∈ theoremNames["QFT"]
Validation: TLC model check: 0 invariant violations
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## QFT-TLA-002  Extend AFP error classes with QFT-specific errors (P3)
Severity: P3 — new error classes for QFT translator output review
New error classes (extend afp_lean4_translation_error_classes.tla):
  "E19_omega_free_var"
    — ω (root of unity) emitted as free variable, not as Complex.exp definition
    — remediation: "define_omegaN_def_in_prelude"
  "E20_phase_gate_missing_dim"
    — phase gate R_k emitted without dimension axiom / lemma
    — remediation: "add_phaseGate_dim_axiom"
  "E21_qft_flat_axiom_only"
    — qftCircuit emitted only as axiom with no recursive structure
    — remediation: "add_recursive_def_structure"
Validation: TLC check: 0 invariant violations
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## QFT-QA-001  Regression checks for QFT translator output (P1)
Severity: P1 — all checks must pass before Theories/QFT.lean is committed
Checks:
  1. omegaN defined (not free): `grep "def omegaN" QFTPrelude.lean` → ≥1
  2. phaseGate present: `grep "phaseGate\|phase_gate" Theories/QFT.lean` → ≥1
  3. qftCircuit_unitary present: `grep "qftCircuit_unitary\|qft_is_unitary" Theories/QFT.lean` → ≥1
  4. No Isabelle exp syntax: `grep 'exp (2 \* pi' Theories/QFT.lean` → 0
  5. Correct Complex.exp usage: `grep "Complex.exp" Theories/QFT.lean QFTPrelude.lean` → ≥1
  6. No autoImplicit: `grep "autoImplicit true" Theories/*.lean QFTPrelude.lean | wc -l` → 0
  7. Build: `lake build CATEPTMain.AFPBridge.QFT` EXIT:0
Validation: `scripts/check_qft_output.sh` exits 0 with all 7 checks green.
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## QFT-QA-002  Faithfulness delta metric for QFT (P2)
Severity: P2 — track translation quality across phases
Metrics:
  faithful_omega    = 1.0  (omegaN defined as Complex.exp, not axiom)
  faithful_recursion = 1.0 phase-2 target (qftCircuit by structural recursion)
  faithful_unitary  = 1.0  (qftCircuit_unitary stated; proof is sorry in phase-1)
  faithful_proof    = 0.0  (all sorry in phase 1)
Phase-1 baseline: faithful_omega=1.0, faithful_recursion=0 (axiom ok), faithful_unitary=1.0
Phase-2 upgrade: faithful_recursion=1.0 + faithful_proof≥0.5
Validation: add QFT metrics to `scripts/check_qft_output.sh` summary section.
-/

-- This file is a worklog / issue tracker. No runnable Lean 4 code is defined here.
-- Records are sorted by phase then severity: PRE (P1) → TH (P1) → INT → TLA → QA.

/-!
## RS-P1-QFT-BACKREF  Restructuring Phase 1 back-reference

This module has a `Theories/` subdirectory scheduled for removal in Phase 1.

Phase 1 move record:
  → CATEPTMain/AFPBridge/PHASE1_FLATTEN_WORKLOG.lean  (RS-P1-QFT)

Action required here: none — moves are handled by the Phase 1 procedure.
After RS-P1-QFT is DONE, all imports of this module change from
  `CATEPTMain.AFPBridge.QFT.Theories.*`  →  `CATEPTMain.AFPBridge.QFT.*`
-/
