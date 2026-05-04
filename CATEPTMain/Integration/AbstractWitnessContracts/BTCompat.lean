import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic

set_option autoImplicit false

/-!
# CATEPT Plugin — Bridge Theory Compatibility (EM ↔ Relativity)

Sibling repo of `jagg-ix/catept-main`. Extracted from
`CATEPTMain.CATEPT.CATEPT.BridgeTheoryCompatibility` (catept-main's
CAT/EPT core barrel). First extraction from the CAT/EPT *core* tree
rather than from `Integration/`.

Encodes the equation-level bridge of:

* M. Auci, "On the Compatibility Between Quantum and Relativistic
  Effects in an Electromagnetic Bridge Theory", arXiv:1003.3861v1.

Compact scalar definitions corresponding to the paper's Eqs. 1-3, 6,
14-18, 19-20 plus lightweight sanity theorems suitable for reuse by
CAT/EPT bridge modules.

This file captures algebraic interfaces only; it does not formalize
the full DEMS ontology.

## Re-import contract

```lean
import CATEPTPluginBTCompat.IntegrationBridge

open CATEPTPluginBTCompat (
  btTotalEnergy btTotalMomentum
  btInvariantEnergySq btPhotonEnergyEq6
  btDopplerFactor btObservedFrequency btObservedPhotonEnergy
  btPeriodPrime btWavelengthPrime
  btLorentzTime btLorentzSpace
  btRelativisticEnergy btRelativisticMomentumTimesC
  btInvariantEnergySq_at_rest
  btDopplerFactor_at_rest btObservedFrequency_at_rest
  btObservedPhotonEnergy_at_rest btPeriodPrime_at_rest
  btWavelengthPrime_at_rest btLorentzTime_at_rest
  btLorentzSpace_at_rest btInvariant_from_relativistic_param)
```
-/

noncomputable section

namespace CATEPTPluginBTCompat

/-- BT Eq. (1): total interaction energy. -/
def btTotalEnergy (E1 E2 : ℝ) : ℝ :=
  E1 + E2

/-- BT Eq. (2): total interaction momentum (1D scalar proxy). -/
def btTotalMomentum (P1 P2 : ℝ) : ℝ :=
  P1 + P2

/-- BT Eq. (14): invariant energy-square term `E^2 - P^2 c^2`. -/
def btInvariantEnergySq (E P c : ℝ) : ℝ :=
  E ^ 2 - P ^ 2 * c ^ 2

/-- BT Eq. (6): observed photon energy along line-of-sight angle `phi`. -/
def btPhotonEnergyEq6 (E P c phi : ℝ) : ℝ :=
  (E ^ 2 - P ^ 2 * c ^ 2) / (2 * (E - P * c * Real.cos phi))

/-- BT Eq. (17) Doppler factor used by the bridge. -/
def btDopplerFactor (beta theta : ℝ) : ℝ :=
  Real.sqrt (1 - beta ^ 2) / (1 - beta * Real.cos theta)

/-- BT Eq. (17): observed frequency from rest-frame characteristic frequency. -/
def btObservedFrequency (nu0 beta theta : ℝ) : ℝ :=
  nu0 * btDopplerFactor beta theta

/-- BT Eq. (16): observed photon energy from invariant energy scale `eps`. -/
def btObservedPhotonEnergy (eps beta theta : ℝ) : ℝ :=
  (eps / 2) * btDopplerFactor beta theta

/-- BT Eq. (18): transformed period. -/
def btPeriodPrime (T lambda beta theta c : ℝ) : ℝ :=
  (T - beta * Real.cos theta * lambda / c) / Real.sqrt (1 - beta ^ 2)

/-- BT Eq. (18): transformed wavelength. -/
def btWavelengthPrime (T lambda beta theta c : ℝ) : ℝ :=
  (lambda - beta * Real.cos theta * c * T) / Real.sqrt (1 - beta ^ 2)

/-- BT Eq. (20): Lorentz time transform (line-of-sight aligned case). -/
def btLorentzTime (t x v c : ℝ) : ℝ :=
  (t - v * x / c ^ 2) / Real.sqrt (1 - (v / c) ^ 2)

/-- BT Eq. (20): Lorentz space transform (line-of-sight aligned case). -/
def btLorentzSpace (x t v c : ℝ) : ℝ :=
  (x - v * t) / Real.sqrt (1 - (v / c) ^ 2)

/-- BT Eq. (15) helper: relativistic energy from invariant scale `eps`. -/
def btRelativisticEnergy (eps beta : ℝ) : ℝ :=
  eps / Real.sqrt (1 - beta ^ 2)

/-- BT Eq. (15) helper: `(P*c)` written from `eps` and `beta`. -/
def btRelativisticMomentumTimesC (eps beta : ℝ) : ℝ :=
  eps * beta / Real.sqrt (1 - beta ^ 2)

/-! ## Sanity lemmas for downstream reuse -/

theorem btInvariantEnergySq_at_rest (E c : ℝ) :
    btInvariantEnergySq E 0 c = E ^ 2 := by
  unfold btInvariantEnergySq
  ring

theorem btDopplerFactor_at_rest (theta : ℝ) :
    btDopplerFactor 0 theta = 1 := by
  unfold btDopplerFactor
  simp

theorem btObservedFrequency_at_rest (nu0 theta : ℝ) :
    btObservedFrequency nu0 0 theta = nu0 := by
  unfold btObservedFrequency
  rw [btDopplerFactor_at_rest]
  ring

theorem btObservedPhotonEnergy_at_rest (eps theta : ℝ) :
    btObservedPhotonEnergy eps 0 theta = eps / 2 := by
  unfold btObservedPhotonEnergy
  rw [btDopplerFactor_at_rest]
  ring

theorem btPeriodPrime_at_rest (T lambda theta c : ℝ) :
    btPeriodPrime T lambda 0 theta c = T := by
  unfold btPeriodPrime
  simp

theorem btWavelengthPrime_at_rest (T lambda theta c : ℝ) :
    btWavelengthPrime T lambda 0 theta c = lambda := by
  unfold btWavelengthPrime
  simp

theorem btLorentzTime_at_rest (t x c : ℝ) :
    btLorentzTime t x 0 c = t := by
  unfold btLorentzTime
  simp

theorem btLorentzSpace_at_rest (x t c : ℝ) :
    btLorentzSpace x t 0 c = x := by
  unfold btLorentzSpace
  simp

/-- Invariant recovery from BT Eq. (15) parametrization. -/
theorem btInvariant_from_relativistic_param
    (eps beta : ℝ)
    (hbeta : beta ^ 2 < 1) :
    btRelativisticEnergy eps beta ^ 2
      - btRelativisticMomentumTimesC eps beta ^ 2
      = eps ^ 2 := by
  unfold btRelativisticEnergy btRelativisticMomentumTimesC
  have hsqrt_pos : 0 < Real.sqrt (1 - beta ^ 2) :=
    Real.sqrt_pos.mpr (by linarith)
  have hsqrt_ne : Real.sqrt (1 - beta ^ 2) ≠ 0 := ne_of_gt hsqrt_pos
  have hsqrt_sq : (Real.sqrt (1 - beta ^ 2)) ^ 2 = 1 - beta ^ 2 := by
    rw [Real.sq_sqrt]
    linarith
  have hden_ne : 1 - beta ^ 2 ≠ 0 := by linarith
  calc
    (eps / Real.sqrt (1 - beta ^ 2)) ^ 2
        - (eps * beta / Real.sqrt (1 - beta ^ 2)) ^ 2
        = (eps ^ 2 * (1 - beta ^ 2)) / (Real.sqrt (1 - beta ^ 2)) ^ 2 := by
          field_simp [hsqrt_ne]
    _ = (eps ^ 2 * (1 - beta ^ 2)) / (1 - beta ^ 2) := by
      rw [hsqrt_sq]
    _ = eps ^ 2 := by
      field_simp [hden_ne]

end CATEPTPluginBTCompat
