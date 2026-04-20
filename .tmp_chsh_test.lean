import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith

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
  have h1 : 0 ≤ (1 - obs.a) * (1 - obs.b) := mul_nonneg (by linarith [obs.ha2]) (by linarith [obs.hb2])
  have h2 : 0 ≤ (1 - obs.a) * (1 + obs.b) := mul_nonneg (by linarith [obs.ha2]) (by linarith [obs.hb1])
  have h3 : 0 ≤ (1 + obs.a) * (1 - obs.b) := mul_nonneg (by linarith [obs.ha1]) (by linarith [obs.hb2])
  have h4 : 0 ≤ (1 + obs.a) * (1 + obs.b) := mul_nonneg (by linarith [obs.ha1]) (by linarith [obs.hb1])
  -- nlinarith might just solve it directly.
  nlinarith [obs.ha1, obs.ha2, obs.hap1, obs.hap2, obs.hb1, obs.hb2, obs.hbp1, obs.hbp2]

