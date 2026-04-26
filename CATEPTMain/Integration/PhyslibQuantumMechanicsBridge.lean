import Physlib.QuantumMechanics.OneDimension.HarmonicOscillator.Basic

/-!
# Physlib Quantum Mechanics Bridge

Dedicated Physlib QM bridge for theorem reuse in non-root targets.

Important integration note:
this module is intentionally *not* imported by the umbrella `CATEPTMain.lean`
target, because that target currently includes modules that load
`Mathlib.Analysis.Distribution.Distribution`, which conflicts with the
`Physlib.Mathematics.Distribution.*` lane pulled transitively by this QM path.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.PhyslibQuantumMechanics

noncomputable section

/-- Harmonic-oscillator characteristic length is strictly positive. -/
theorem harmonicOscillator_xi_pos
    (Q : QuantumMechanics.OneDimension.HarmonicOscillator) :
    0 < Q.ξ :=
  QuantumMechanics.OneDimension.HarmonicOscillator.ξ_pos Q

/-- Harmonic-oscillator characteristic length identity:
`ξ^2 = ℏ / (m ω)`. -/
theorem harmonicOscillator_xi_sq
    (Q : QuantumMechanics.OneDimension.HarmonicOscillator) :
    Q.ξ ^ 2 = (↑Constants.ℏ : ℝ) / (Q.m * Q.ω) :=
  QuantumMechanics.OneDimension.HarmonicOscillator.ξ_sq Q

/-- Inverse characteristic-length identity:
`(1/ξ)^2 = m ω / ℏ`. -/
theorem harmonicOscillator_inv_xi_sq
    (Q : QuantumMechanics.OneDimension.HarmonicOscillator) :
    (1 / Q.ξ) ^ 2 = Q.m * Q.ω / (↑Constants.ℏ : ℝ) :=
  QuantumMechanics.OneDimension.HarmonicOscillator.one_over_ξ_sq Q

end
end CATEPTMain.Integration.PhyslibQuantumMechanics
