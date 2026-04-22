import CATEPTMain.CATEPT.PathIntegrals

set_option autoImplicit false

/-!
# Example 10: UV Convergence from Coercivity

## What makes this unique to CAT/EPT

In standard QFT, UV divergences are the central obstacle. They require
renormalization — a systematic but ad hoc procedure of subtracting
infinities. The path integral ∫DΦ exp(iS/ℏ) diverges because every
path contributes with unit weight.

In CAT/EPT, the imaginary action S_I provides **natural UV damping**.
When S_I satisfies the coercivity condition:

  S_I[Φ] ≥ C ‖Φ‖²    (C > 0)

the path integral weight is bounded by:

  |w(Φ)| ≤ exp(-C‖Φ‖²/ℏ)

This is a Gaussian envelope that kills UV modes exponentially.
No renormalization needed — the path integral is finite by construction
when entropy production grows fast enough at high energy.

The Euclidean propagator with entropic damping λ > 0 becomes:

  G_E(k) = 1/(k² + m² + λ)

which has no poles and yields Yukawa screening with effective mass
M_eff = √(m² + λ). Increasing λ shortens the interaction range.

## Key results

1. Coercivity implies UV damping: |w| ≤ exp(-C‖Φ‖²/ℏ)
2. Damping is in (0, 1] under coercivity
3. Euclidean propagator is positive and well-defined
4. Effective mass increases with λ (screening)
5. Larger λ means shorter interaction range
-/

noncomputable section

namespace CATEPT.Examples

open CATEPT

-- Damping magnitude bounded by 1
example (ℏ S_I : ℝ) (hh : 0 < ℏ) (hS : 0 ≤ S_I) :
    |path_integral_damping ℏ S_I| ≤ 1 :=
  eq054_damping_magnitude ℏ S_I hh hS

-- Coercivity implies exponential UV damping
example {Φ : Type*} [NormedAddCommGroup Φ]
    (S_I : Φ → ℝ) (ℏ : ℝ) (hh : 0 < ℏ)
    (coer : CoercivityCondition (Φ := Φ))
    (φ : Φ) (hb : coer.C * ‖φ‖ ^ 2 ≤ S_I φ) :
    path_integral_damping ℏ (S_I φ) ≤
      Real.exp (-coer.C * ‖φ‖ ^ 2 / ℏ) :=
  eq057_coercivity_implies_convergence S_I ℏ hh coer φ hb

-- Under coercivity: damping is in (0, 1]
example {Φ : Type*} [NormedAddCommGroup Φ]
    (S_I : Φ → ℝ) (ℏ : ℝ) (hh : 0 < ℏ)
    (coer : CoercivityCondition (Φ := Φ))
    (hb : ∀ φ, coer.C * ‖φ‖ ^ 2 ≤ S_I φ) (φ : Φ) :
    0 < path_integral_damping ℏ (S_I φ) ∧
    path_integral_damping ℏ (S_I φ) ≤ 1 :=
  eq057_coercivity_ensures_integrability S_I ℏ hh coer hb φ

-- Euclidean propagator G_E(k) = 1/(k² + m² + λ) is positive
example (k_sq m_sq lam : ℝ) (hk : 0 ≤ k_sq) (hm : 0 ≤ m_sq) (hl : 0 < lam) :
    0 < euclidean_propagator k_sq m_sq lam :=
  eq075_propagator_positive k_sq m_sq lam hk hm hl

-- Effective mass increases with entropic damping
example (m_sq lam1 lam2 : ℝ) (hm : 0 ≤ m_sq)
    (h1 : 0 ≤ lam1) (h2 : lam1 < lam2) :
    effective_mass m_sq lam1 < effective_mass m_sq lam2 :=
  eq076_effective_mass_increases m_sq lam1 lam2 hm h1 h2

-- Larger λ means shorter screening length (Yukawa suppression)
example (m_sq lam1 lam2 r : ℝ) (hm : 0 ≤ m_sq)
    (h1 : 0 < lam1) (h2 : lam1 < lam2) (hr : 0 < r) :
    yukawa_potential (effective_mass m_sq lam2) r <
      yukawa_potential (effective_mass m_sq lam1) r :=
  eq076_screening_length_decreases m_sq lam1 lam2 r hm h1 h2 hr

end CATEPT.Examples
