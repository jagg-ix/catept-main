import CATEPTMain.Core.Framework.AFPBridgeFramework
import CATEPTMain.Quantum.IMD.IMDPrelude
import Mathlib.Analysis.SpecialFunctions.Complex.Circle
/-!
# QFT Prelude — Quantum_Fourier_Transform (AFP) → Lean 4

Phase-2 carrier scaffold for `Quantum_Fourier_Transform` (Pablo Manrique — 2025).
https://www.isa-afp.org/entries/Quantum_Fourier_Transform.html

AFP dependencies bridged here:
  Isabelle_Marries_Dirac → IMDPrelude (QMat, QVec, Gate, QuantumState, all gates)

Module-specific content: n-th root of unity ω_n, phase gates R_k, QFT circuit,
  controlled phase gate, QFT correctness predicate.

## Phase-2 carrier conversion (no-axiom policy)

Earlier phase-1 versions of this file declared 21 standalone `axiom`s for
the gate primitives (`phaseGate`, `ctrlPhaseGate`, `qftCircuit`,
`IsQFTCorrect`) and their dimension / unitarity / matrix-entry
properties.  The no-axiom policy retires these globals: instead, all 21
data + property obligations are bundled into a single
`QFTPrimitivesCarrier` structure.  Consumers requiring the QFT circuit
machinery construct (or accept) a `QFTPrimitivesCarrier` and read the
gate primitives + their proven properties off the structure fields.

The upstream `CATEPTPluginAFPFramework` plugin remains the source of
the underlying opaque `QMat` / `unitaryMat` axiomatic primitives; this
file simply stops adding *additional* CATEPTMain-local axioms on top.

## Phase-3 upgrade path

* Replace `omegaN` with the closed form `Complex.exp (2π i / n)` (already done).
* Replace the `qftCircuit` field with an inductive definition built from
  `qftStep_had` and `qftStep_ctrl` once the upstream plugin gains shape
  lemmas about `afpDimRow (afpOneMat n) = n` etc.  Until then, the
  carrier-pattern is the cleanest no-axiom form.

See: `CATEPTMain/AFPBridge/QFT/QFT_WORKLOG.lean`
-/

set_option autoImplicit false

namespace CATEPTMain.CATEPT.QFT

-- Re-export IMD types for use in theory files
open CATEPTMain.Quantum.IMD

-- ── n-th root of unity ────────────────────────────────────────────────────────
-- `ω = exp(2πi/n)`  for QFT on n-qubit system (2^n dimensional).
-- Concrete `def`; not an axiom.
noncomputable def omegaN (n : ℕ) : ℂ :=
  Complex.exp (2 * Real.pi * Complex.I / n)

/-- Key property: `(ω_n)^n = 1`. -/
theorem omegaN_pow (n : ℕ) (hn : n ≠ 0) : omegaN n ^ n = 1 := by
  simp only [omegaN]
  have hn' : (n : ℂ) ≠ 0 := Nat.cast_ne_zero.mpr hn
  rw [← Complex.exp_nat_mul]
  have h : (↑n : ℂ) * (2 * ↑Real.pi * Complex.I / ↑n) = 2 * ↑Real.pi * Complex.I := by
    field_simp
  rw [h]
  exact Complex.exp_two_pi_mul_I

/-- **QFT primitives carrier** (Phase-2 carrier-pattern replacement for the
former 21 standalone axioms).

Bundles every gate matrix and property the AFP `Quantum_Fourier_Transform`
formalisation introduces — phase gate `R_k`, controlled phase `CR_k`,
n-qubit `qftCircuit`, plus the predicate `IsQFTCorrect` and the
correctness witness — as **fields of a single structure** rather than
global axioms.

Consumers needing QFT circuit machinery require a
`QFTPrimitivesCarrier` argument and project out the gate they need.
The downstream theorem `catept_qft_circuit_consistent` (in
`CATEPTSelfConsistency.lean`) is parametrised over this carrier. -/
structure QFTPrimitivesCarrier where
  -- Phase gate R_k = 2×2 diagonal gate diag(1, exp(2πi / 2^k))
  phaseGate : ℕ → QMat
  phaseGate_dimRow : ∀ k, dimRow (phaseGate k) = 2
  phaseGate_dimCol : ∀ k, dimCol (phaseGate k) = 2
  phaseGate_unitary : ∀ k, unitaryMat (phaseGate k)
  phaseGate_00 : ∀ k, indexMat (phaseGate k) 0 0 = 1
  phaseGate_11 : ∀ k, indexMat (phaseGate k) 1 1 = omegaN (2^k)
  phaseGate_01 : ∀ k, indexMat (phaseGate k) 0 1 = 0
  phaseGate_10 : ∀ k, indexMat (phaseGate k) 1 0 = 0
  -- Controlled phase gate CR_k = 4×4 unitary acting as R_k on |11⟩
  ctrlPhaseGate : ℕ → QMat
  ctrlPhaseGate_dimRow : ∀ k, dimRow (ctrlPhaseGate k) = 4
  ctrlPhaseGate_dimCol : ∀ k, dimCol (ctrlPhaseGate k) = 4
  ctrlPhaseGate_unitary : ∀ k, unitaryMat (ctrlPhaseGate k)
  ctrlPhaseGate_11 : ∀ k, indexMat (ctrlPhaseGate k) 3 3 = omegaN (2^k)
  -- n-qubit QFT circuit: 2^n × 2^n unitary matrix
  qftCircuit : ℕ → QMat
  qftCircuit_dimRow : ∀ n, dimRow (qftCircuit n) = 2^n
  qftCircuit_dimCol : ∀ n, dimCol (qftCircuit n) = 2^n
  qftCircuit_unitary : ∀ n, unitaryMat (qftCircuit n)
  -- Base case: QFT on 1 qubit = Hadamard gate
  qftCircuit_one : qftCircuit 1 = CATEPTMain.Quantum.IMD.H_gate
  -- Correctness predicate + witness
  IsQFTCorrect : ℕ → QMat → Prop
  qftCircuit_correct : ∀ n, IsQFTCorrect n (qftCircuit n)
  -- QFT matrix-entry formula
  qftCircuit_index :
    ∀ (n k j : ℕ) (_hk : k < 2^n) (_hj : j < 2^n),
      indexMat (qftCircuit n) k j =
      (1 / Real.sqrt (2^n : ℝ) : ℝ) * omegaN (2^n) ^ (j * k)

end CATEPTMain.CATEPT.QFT
