import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-!
# Zero-Axiom Classical CHSH Bounds for Dual-Sphere Fluids

Instead of relying on philosophical axioms of Determinism or Non-Contextuality
(as heavily debated in Diracs critique), this module directly extracts the
algebraic bounds derived from those theories and proves them strictly on continuous
classical fluid observables.

This explicitly maps Option 1 (Locality/Non-Contextuality limits) directly onto
the fluid framework without admitting `axiom` or `sorry`.
-/

namespace NavierStokesClean.CATEPT.External.DSFCHSHBound

/-- A framework for classical measurement outcomes inside the 3D fluid.
    $a, a'$ represent velocity gradient projections at one vortex region,
    $b, b'$ represent projections at a separated region. -/
structure ClassicalObserver where
  a : ℝ
  a' : ℝ
  b : ℝ
  b' : ℝ
  ha1 : -1 ≤ a
  ha2 : a ≤ 1
  hap1 : -1 ≤ a'
  hap2 : a' ≤ 1
  hb1 : -1 ≤ b
  hb2 : b ≤ 1
  hbp1 : -1 ≤ b'
  hbp2 : b' ≤ 1

/-- The CHSH correlation polynomial constructed from dual-sphere projections -/
def CHSH_Polynomial (obs : ClassicalObserver) : ℝ :=
  obs.a * obs.b + obs.a * obs.b' + obs.a' * obs.b - obs.a' * obs.b'

/-- Option 1 Proof: Any deterministic, non-contextual sub-algebra of the 
    classical Navier-Stokes fluid MUST strictly obey the CHSH upper bound of 2.
    Proved rigorously using real-ordered arithmetic. -/
theorem classical_chsh_bound (obs : ClassicalObserver) :
    CHSH_Polynomial obs ≤ 2 := by
  -- We factor CHSH_Polynomial into parts that group 'b' and 'b''
  rcases le_or_lt 0 (obs.b + obs.b') with hp1 | hn1
  · rcases le_or_lt 0 (obs.b - obs.b') with hp2 | hn2
    · have t1 : obs.a * (obs.b + obs.b') ≤ 1 * (obs.b + obs.b') := mul_le_mul_of_nonneg_right obs.ha2 hp1
      have t2 : obs.a' * (obs.b - obs.b') ≤ 1 * (obs.b - obs.b') := mul_le_mul_of_nonneg_right obs.hap2 hp2
      calc
        CHSH_Polynomial obs = obs.a * (obs.b + obs.b') + obs.a' * (obs.b - obs.b') := by
          dsimp [CHSH_Polynomial]; ring
        _ ≤ 1 * (obs.b + obs.b') + 1 * (obs.b - obs.b') := add_le_add t1 t2
        _ = 2 * obs.b := by ring
        _ ≤ 2 * 1 := by linarith [obs.hb2]
        _ = 2 := by ring
    · have hn2' : 0 ≤ -(obs.b - obs.b') := by linarith
      have t1 : obs.a * (obs.b + obs.b') ≤ 1 * (obs.b + obs.b') := mul_le_mul_of_nonneg_right obs.ha2 hp1
      have t2 : (-obs.a') * -(obs.b - obs.b') ≤ 1 * -(obs.b - obs.b') := mul_le_mul_of_nonneg_right (by linarith [obs.hap1]) hn2'
      calc
        CHSH_Polynomial obs = obs.a * (obs.b + obs.b') + (-obs.a') * -(obs.b - obs.b') := by
          dsimp [CHSH_Polynomial]; ring
        _ ≤ 1 * (obs.b + obs.b') + 1 * -(obs.b - obs.b') := add_le_add t1 t2
        _ = 2 * obs.b' := by ring
        _ ≤ 2 * 1 := by linarith [obs.hbp2]
        _ = 2 := by ring
  · have hn1' : 0 ≤ -(obs.b + obs.b') := by linarith
    rcases le_or_lt 0 (obs.b - obs.b') with hp2 | hn2
    · have t1 : (-obs.a) * -(obs.b + obs.b') ≤ 1 * -(obs.b + obs.b') := mul_le_mul_of_nonneg_right (by linarith [obs.ha1]) hn1'
      have t2 : obs.a' * (obs.b - obs.b') ≤ 1 * (obs.b - obs.b') := mul_le_mul_of_nonneg_right obs.hap2 hp2
      calc
        CHSH_Polynomial obs = (-obs.a) * -(obs.b + obs.b') + obs.a' * (obs.b - obs.b') := by
          dsimp [CHSH_Polynomial]; ring
        _ ≤ 1 * -(obs.b + obs.b') + 1 * (obs.b - obs.b') := add_le_add t1 t2
        _ = 2 * -obs.b' := by ring
        _ ≤ 2 * 1 := by linarith [obs.hbp1]
        _ = 2 := by ring
    · have hn2' : 0 ≤ -(obs.b - obs.b') := by linarith
      have t1 : (-obs.a) * -(obs.b + obs.b') ≤ 1 * -(obs.b + obs.b') := mul_le_mul_of_nonneg_right (by linarith [obs.ha1]) hn1'
      have t2 : (-obs.a') * -(obs.b - obs.b') ≤ 1 * -(obs.b - obs.b') := mul_le_mul_of_nonneg_right (by linarith [obs.hap1]) hn2'
      calc
        CHSH_Polynomial obs = (-obs.a) * -(obs.b + obs.b') + (-obs.a') * -(obs.b - obs.b') := by
          dsimp [CHSH_Polynomial]; ring
        _ ≤ 1 * -(obs.b + obs.b') + 1 * -(obs.b - obs.b') := add_le_add t1 t2
        _ = 2 * -obs.b := by ring
        _ ≤ 2 * 1 := by linarith [obs.hb1]
        _ = 2 := by ring

end NavierStokesClean.CATEPT.External.DSFCHSHBound
