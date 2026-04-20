import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

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

def CHSH_Polynomial (obs : ClassicalObserver) : ℝ :=
  obs.a * obs.b + obs.a * obs.b' + obs.a' * obs.b - obs.a' * obs.b'

theorem classical_chsh_bound (obs : ClassicalObserver) :
    CHSH_Polynomial obs ≤ 2 := by
  rcases le_or_lt 0 (obs.b + obs.b') with hp1 | hn1
  · rcases le_or_lt 0 (obs.b - obs.b') with hp2 | hn2
    · have t1 := mul_le_mul_of_nonneg_right obs.ha2 hp1
      have t2 := mul_le_mul_of_nonneg_right obs.hap2 hp2
      have hb_bound : obs.b + obs.b' + (obs.b - obs.b') ≤ 2 := by linarith [obs.hb2]
      calc
        CHSH_Polynomial obs = obs.a * (obs.b + obs.b') + obs.a' * (obs.b - obs.b') := by
          dsimp [CHSH_Polynomial]; ring
        _ ≤ 1 * (obs.b + obs.b') + 1 * (obs.b - obs.b') := add_le_add t1 t2
        _ = obs.b + obs.b' + (obs.b - obs.b') := by ring
        _ ≤ 2 := hb_bound
    · have hn2' : 0 ≤ -(obs.b - obs.b') := by linarith
      have t1 := mul_le_mul_of_nonneg_right obs.ha2 hp1
      have t2 := mul_le_mul_of_nonneg_right obs.hap1 hn2'
      have hb_bound : obs.b + obs.b' - (obs.b - obs.b') ≤ 2 := by linarith [obs.hbp2]
      calc
        CHSH_Polynomial obs = obs.a * (obs.b + obs.b') + (-obs.a') * -(obs.b - obs.b') := by
          dsimp [CHSH_Polynomial]; ring
        _ ≤ 1 * (obs.b + obs.b') + 1 * -(obs.b - obs.b') := add_le_add t1 t2
        _ = obs.b + obs.b' - (obs.b - obs.b') := by ring
        _ ≤ 2 := hb_bound
  · have hn1' : 0 ≤ -(obs.b + obs.b') := by linarith
    rcases le_or_lt 0 (obs.b - obs.b') with hp2 | hn2
    · have t1 := mul_le_mul_of_nonneg_right obs.ha1 hn1'
      have t2 := mul_le_mul_of_nonneg_right obs.hap2 hp2
      have hb_bound : -(obs.b + obs.b') + (obs.b - obs.b') ≤ 2 := by linarith [obs.hbp1]
      calc
        CHSH_Polynomial obs = (-obs.a) * -(obs.b + obs.b') + obs.a' * (obs.b - obs.b') := by
          dsimp [CHSH_Polynomial]; ring
        _ ≤ 1 * -(obs.b + obs.b') + 1 * (obs.b - obs.b') := add_le_add t1 t2
        _ = -(obs.b + obs.b') + (obs.b - obs.b') := by ring
        _ ≤ 2 := hb_bound
    · have hn2' : 0 ≤ -(obs.b - obs.b') := by linarith
      have t1 := mul_le_mul_of_nonneg_right obs.ha1 hn1'
      have t2 := mul_le_mul_of_nonneg_right obs.hap1 hn2'
      have hb_bound : -(obs.b + obs.b') - (obs.b - obs.b') ≤ 2 := by linarith [obs.hb1]
      calc
        CHSH_Polynomial obs = (-obs.a) * -(obs.b + obs.b') + (-obs.a') * -(obs.b - obs.b') := by
          dsimp [CHSH_Polynomial]; ring
        _ ≤ 1 * -(obs.b + obs.b') + 1 * -(obs.b - obs.b') := add_le_add t1 t2
        _ = -(obs.b + obs.b') - (obs.b - obs.b') := by ring
        _ ≤ 2 := hb_bound

