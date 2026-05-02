/-
  T-Z / Tier-2 #4: Free-particle propagator phase from Trotter slicing.

  The Feynman propagator for a free particle of mass `m` from `xa` to
  `xb` over time `T` is

        K(xb, xa; T)  =  √(m / (2π·iℏ·T))  ·  exp(i · S_cl / ℏ),

  where `S_cl(xa, xb, T) = m·(xb-xa)² / (2T)` is the classical action.
  Trotter slicing computes K by inserting (n−1) intermediate position
  integrals over a uniform time partition; in the saddle limit each
  intermediate integral collapses onto the geometric saddle, the
  individual phases add, and the resulting total phase is exactly
  `S_cl(xa, xb; T) / ℏ`.

  This file ships the *phase* functional and the slicing identity at
  the level of the real exponent in the propagator:

        Φ(xa, xb, T)  :=  S_cl(xa, xb, T) / ℏ
                        =  m·(xb-xa)² / (2·ℏ·T).

  Phase 1 ships two honest, kernel-only identities:

    (1) `freePropagatorPhase_split_at_saddle` — 2-fold Trotter step:
          Φ(xa, xm*, T₁) + Φ(xm*, xb, T₂)  =  Φ(xa, xb, T₁+T₂)
        with `xm* = (T₂·xa + T₁·xb)/(T₁+T₂)`.
    (2) `freePropagatorPhase_three_split_at_successive_saddles` —
        the iterated 3-fold Trotter step at successive saddles:
          Φ(xa, p, T₁) + Φ(p, q, T₂) + Φ(q, xb, T₃)  =  Φ(xa, xb, T₁+T₂+T₃)
        with `p = saddle(xa, xb, T₁, T₂+T₃)` and
             `q = saddle(p,  xb, T₂,    T₃)`.

  This is the algebraic core of the iterated Trotter slicing: it
  shows that the WKB phase `i·S_cl/ℏ` of the free propagator is
  closed under uniform-grid composition along successive saddles.
  Phase 2 (deferred): full complex-valued propagator with prefactor
  `√(m/(2π·iℏ·T))`, the Gaussian convolution
  `K(·, xa; T₁) ∗ K(xb, ·; T₂) = K(xb, xa; T₁+T₂)`, and the n-fold
  induction lifting Phase 1 to an arbitrary uniform partition.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp
import CATEPTMain.Integration.FreeParticleAction
import CATEPTMain.Integration.FreeParticleSaddle

set_option autoImplicit false

namespace CATEPTMain.Integration.FreeParticlePropagator

open CATEPTMain.Integration.FreeParticleAction
open CATEPTMain.Integration.FreeParticleSaddle

noncomputable section

/-- Free-particle propagator phase: `Φ = S_cl / ℏ = m·(xb-xa)²/(2·ℏ·T)`.
    The exponent of `exp(i·Φ)` in the WKB form of the free-propagator
    kernel; reduces to `freeClassicalAction` at `ℏ = 1`. -/
def freePropagatorPhase (m hbar xa xb T : ℝ) : ℝ :=
  m * (xb - xa) ^ 2 / (2 * hbar * T)

/-- Phase ↔ classical action: rescaled by ℏ. -/
theorem freePropagatorPhase_eq_action_div_hbar
    (m hbar xa xb T : ℝ) (hhbar : hbar ≠ 0) :
    freePropagatorPhase m hbar xa xb T
      = freeClassicalAction m xa xb T / hbar := by
  unfold freePropagatorPhase freeClassicalAction
  field_simp

/-- 2-fold Trotter slicing of the free propagator phase at the saddle.
    Inserting the geometric midpoint `xm* = (T₂·xa + T₁·xb)/(T₁+T₂)`
    splits the WKB phase additively: this is the algebraic content
    of `K(xb, xa; T₁+T₂) = K(xb, xm*; T₂) · K(xm*, xa; T₁)` in the
    saddle limit. -/
theorem freePropagatorPhase_split_at_saddle
    (m hbar xa xb T₁ T₂ : ℝ)
    (hhbar : hbar ≠ 0)
    (hT₁ : T₁ ≠ 0) (hT₂ : T₂ ≠ 0) (hTsum : T₁ + T₂ ≠ 0) :
    freePropagatorPhase m hbar xa (freeSaddle xa xb T₁ T₂) T₁
      + freePropagatorPhase m hbar (freeSaddle xa xb T₁ T₂) xb T₂
      = freePropagatorPhase m hbar xa xb (T₁ + T₂) := by
  rw [freePropagatorPhase_eq_action_div_hbar _ _ _ _ _ hhbar,
      freePropagatorPhase_eq_action_div_hbar _ _ _ _ _ hhbar,
      freePropagatorPhase_eq_action_div_hbar _ _ _ _ _ hhbar,
      ← add_div,
      freeClassicalAction_additive_at_saddle m xa xb T₁ T₂ hT₁ hT₂ hTsum]

/-- 3-fold Trotter slicing of the free propagator phase along
    successive saddles. The first saddle splits `T₁ | T₂+T₃`; the
    second saddle splits the remainder `T₂ | T₃`. The total phase is
    the unbroken `Φ(xa, xb, T₁+T₂+T₃)`, the algebraic core of one
    iteration step in the n-fold Trotter slicing. -/
theorem freePropagatorPhase_three_split_at_successive_saddles
    (m hbar xa xb T₁ T₂ T₃ : ℝ)
    (hhbar : hbar ≠ 0)
    (hT₁ : T₁ ≠ 0) (hT₂ : T₂ ≠ 0) (hT₃ : T₃ ≠ 0)
    (hT23 : T₂ + T₃ ≠ 0) (hT123 : T₁ + (T₂ + T₃) ≠ 0) :
    let p := freeSaddle xa xb T₁ (T₂ + T₃)
    let q := freeSaddle p  xb T₂ T₃
    freePropagatorPhase m hbar xa p T₁
      + freePropagatorPhase m hbar p q T₂
      + freePropagatorPhase m hbar q xb T₃
      = freePropagatorPhase m hbar xa xb (T₁ + (T₂ + T₃)) := by
  intro p q
  -- Inner 2-fold split: Φ(p,q,T₂) + Φ(q,xb,T₃) = Φ(p,xb,T₂+T₃)
  have hinner :
      freePropagatorPhase m hbar p q T₂
        + freePropagatorPhase m hbar q xb T₃
        = freePropagatorPhase m hbar p xb (T₂ + T₃) := by
    simpa using
      freePropagatorPhase_split_at_saddle m hbar p xb T₂ T₃
        hhbar hT₂ hT₃ hT23
  -- Outer 2-fold split: Φ(xa,p,T₁) + Φ(p,xb,T₂+T₃) = Φ(xa,xb,T₁+(T₂+T₃))
  have houter :
      freePropagatorPhase m hbar xa p T₁
        + freePropagatorPhase m hbar p xb (T₂ + T₃)
        = freePropagatorPhase m hbar xa xb (T₁ + (T₂ + T₃)) := by
    simpa using
      freePropagatorPhase_split_at_saddle m hbar xa xb T₁ (T₂ + T₃)
        hhbar hT₁ hT23 hT123
  -- Combine: regroup the LHS and rewrite via the inner step, then the outer.
  calc
    freePropagatorPhase m hbar xa p T₁
        + freePropagatorPhase m hbar p q T₂
        + freePropagatorPhase m hbar q xb T₃
        = freePropagatorPhase m hbar xa p T₁
            + (freePropagatorPhase m hbar p q T₂
              + freePropagatorPhase m hbar q xb T₃) := by ring
    _   = freePropagatorPhase m hbar xa p T₁
            + freePropagatorPhase m hbar p xb (T₂ + T₃) := by rw [hinner]
    _   = freePropagatorPhase m hbar xa xb (T₁ + (T₂ + T₃)) := houter

end

end CATEPTMain.Integration.FreeParticlePropagator
