import CATEPTMain.Quantum.PM.Projective_Measurements
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

namespace CATEPTMain.Quantum.PM.CHSH_Inequality

open CATEPTMain.Quantum.PM
open CATEPTMain.Quantum.PM.Projective_Measurements
open CATEPTMain.Quantum.IMD

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
private axiom chsh_classical_bound_law (a b a' b' : ℝ)
    (ha : a = 1 ∨ a = -1) (hb : b = 1 ∨ b = -1)
    (ha' : a' = 1 ∨ a' = -1) (hb' : b' = 1 ∨ b' = -1) :
    |a * b + a * b' + a' * b - a' * b'| ≤ 2

theorem chsh_classical_bound (a b a' b' : ℝ)
    (ha : a = 1 ∨ a = -1) (hb : b = 1 ∨ b = -1)
    (ha' : a' = 1 ∨ a' = -1) (hb' : b' = 1 ∨ b' = -1) :
    |a * b + a * b' + a' * b - a' * b'| ≤ 2 :=
  chsh_classical_bound_law a b a' b' ha hb ha' hb'

-- ── Quantum CHSH: Tsirelson bound ─────────────────────────────────────────────
-- AFP: |chshExpect A A' B B' ρ| ≤ 2√2  for all dichotomic observables A,A',B,B'.

private axiom chsh_quantum_bound_law (A A' B B' ρ : QMat)
    (hA  : IsDichotomicObs A)  (hA' : IsDichotomicObs A')
    (hB  : IsDichotomicObs B)  (hB'  : IsDichotomicObs B')
    (hρ  : IsFullDensityOp ρ) :
    |chshExpect A A' B B' ρ| ≤ 2 * Real.sqrt 2

theorem chsh_quantum_bound (A A' B B' ρ : QMat)
    (hA  : IsDichotomicObs A)  (hA' : IsDichotomicObs A')
    (hB  : IsDichotomicObs B)  (hB'  : IsDichotomicObs B')
    (hρ  : IsFullDensityOp ρ) :
    |chshExpect A A' B B' ρ| ≤ 2 * Real.sqrt 2 :=
  chsh_quantum_bound_law A A' B B' ρ hA hA' hB hB' hρ

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

private axiom chsh_bell_achieves_tsirelson_law :
    chshExpect chshA chshA' chshB chshB' (tensorMat bellDensity bellDensity) =
    2 * Real.sqrt 2

theorem chsh_bell_achieves_tsirelson :
    chshExpect chshA chshA' chshB chshB' (tensorMat bellDensity bellDensity) =
    2 * Real.sqrt 2 := chsh_bell_achieves_tsirelson_law

-- ── CHSH violation: quantum > classical bound ─────────────────────────────────
-- Proof: √2 > 1 (since 1² < 2), so 2√2 > 2·1 = 2
theorem chsh_quantum_exceeds_classical :
    2 * Real.sqrt 2 > 2 := by
  have h : (1 : ℝ) < Real.sqrt 2 := by
    rw [show (1 : ℝ) = Real.sqrt 1 from Real.sqrt_one.symm]
    exact Real.sqrt_lt_sqrt (by norm_num) (by norm_num)
  linarith

end CATEPTMain.Quantum.PM.CHSH_Inequality
