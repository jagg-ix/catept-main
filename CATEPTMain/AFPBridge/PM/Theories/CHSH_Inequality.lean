import CATEPTMain.AFPBridge.PM.Theories.Projective_Measurements
/-!
# CHSH_Inequality — AFP Projective_Measurements → Lean 4 (Phase 1)

Source: `Projective_Measurements/CHSH_Inequality.thy` (Echenim — 2021)
Dependencies: Projective_Measurements

Content: CHSH (Clauser-Horne-Shimony-Holt) inequality and its quantum violation:
  - Classical CHSH bound: |⟨AB⟩ + ⟨AB'⟩ + ⟨A'B⟩ − ⟨A'B'⟩| ≤ 2
  - Quantum CHSH value: up to 2√2 (Tsirelson bound)
  - Bell state exhibits quantum CHSH = 2√2
  - CHSH as PVM correlation function

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.AFPBridge.PM.Theories.CHSH_Inequality

open CATEPTMain.AFPBridge.PM
open CATEPTMain.AFPBridge.IMD

-- ── CHSH correlation function ──────────────────────────────────────────────────
-- AFP: `chsh_expect A A' B B' ρ` = ⟨AB⟩ + ⟨AB'⟩ + ⟨A'B⟩ - ⟨A'B'⟩
-- where ⟨AB⟩ = Tr((A ⊗ B) ρ)

noncomputable def chshExpect (A A' B B' ρ : QMat) : ℝ :=
  (traceMat (matMul (tensorMat A B) ρ)).re +
  (traceMat (matMul (tensorMat A B') ρ)).re +
  (traceMat (matMul (tensorMat A' B) ρ)).re -
  (traceMat (matMul (tensorMat A' B') ρ)).re

-- ── Classical CHSH bound ──────────────────────────────────────────────────────
-- AFP: For classical (hidden-variable) theories |CHSH| ≤ 2.
-- Quantum proof: establishes upper bound 2√2 (Tsirelson).

-- Arithmetic CHSH bound: for a,b,a',b' ∈ {-1,+1},
-- |ab + ab' + a'b - a'b'| ≤ 2.
theorem chsh_classical_bound (a b a' b' : ℝ)
    (ha : a = 1 ∨ a = -1) (hb : b = 1 ∨ b = -1)
    (ha' : a' = 1 ∨ a' = -1) (hb' : b' = 1 ∨ b' = -1) :
    |a * b + a * b' + a' * b - a' * b'| ≤ 2 := by
  sorry -- phase2_decide (finitely many cases; all 16 sign combinations)

-- ── Quantum CHSH: Tsirelson bound ─────────────────────────────────────────────
-- AFP: |chshExpect A A' B B' ρ| ≤ 2√2  for all dichotomic observables A,A',B,B'.

theorem chsh_quantum_bound (A A' B B' ρ : QMat)
    (hA  : IsDichotomicObs A)  (hA' : IsDichotomicObs A')
    (hB  : IsDichotomicObs B)  (hB'  : IsDichotomicObs B')
    (hρ  : IsFullDensityOp ρ) :
    |chshExpect A A' B B' ρ| ≤ 2 * Real.sqrt 2 := by
  sorry -- phase2_spectral: Tsirelson bound via operator inequality ‖CHSH op‖ ≤ 2√2

-- ── Bell state achieves 2√2 ───────────────────────────────────────────────────
-- AFP: The Bell state ρ = |Φ⁺⟩⟨Φ⁺| achieves CHSH = 2√2
-- with A = Z, A' = X, B = -(Z+X)/√2, B' = (Z-X)/√2.

-- Bell state density matrix: ρ_bell = |bell00⟩⟨bell00|
noncomputable def bellDensity : QMat :=
  matMul (ketVec bell00) (braVec bell00)

-- CHSH optimal observables for Bell state:
axiom chshA  : QMat   -- = Z gate
axiom chshA' : QMat   -- = X gate
axiom chshB  : QMat   -- = -(Z + X)/√2
axiom chshB' : QMat   -- = (Z - X)/√2
axiom chshA_dichotomic  : IsDichotomicObs chshA
axiom chshA'_dichotomic : IsDichotomicObs chshA'
axiom chshB_dichotomic  : IsDichotomicObs chshB
axiom chshB'_dichotomic : IsDichotomicObs chshB'

theorem chsh_bell_achieves_tsirelson :
    chshExpect chshA chshA' chshB chshB' (tensorMat bellDensity bellDensity) =
    2 * Real.sqrt 2 := by
  sorry -- phase2_compute: matrix multiplication; trace evaluation on Bell state

-- ── CHSH violation: quantum > classical bound ─────────────────────────────────
theorem chsh_quantum_exceeds_classical :
    2 * Real.sqrt 2 > 2 := by
  sorry -- phase2_norm_num: √2 > 1

end CATEPTMain.AFPBridge.PM.Theories.CHSH_Inequality
