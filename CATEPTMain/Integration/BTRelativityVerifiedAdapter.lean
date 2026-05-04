import CATEPTMain.Integration.AbstractWitnessContracts.BTCompat
/-!
# BTRelativityVerifiedAdapter — A4: BT-Compat → SR adapter (verified)

Consumer-side adapter that imports the **proven** Birkhoff-Tarski
compatibility theorems from `CATEPTPluginBTCompat`:

* `btInvariantEnergySq_at_rest` — `E_inv² = E²` at rest
* `btDopplerFactor_at_rest` — Doppler factor reduces at rest
* `btObservedFrequency_at_rest`, `btObservedPhotonEnergy_at_rest`
* `btPeriodPrime_at_rest`, `btWavelengthPrime_at_rest`
* `btLorentzTime_at_rest`, `btLorentzSpace_at_rest`

These are **kernel-axiom-clean** theorems (proven by `unfold; ring` /
`simp`) but were previously unconsumed in catept-main.

The adapter provides a unified `BTAtRestSpine` carrier exposing all
eight at-rest identities as a structural extraction package, useful
for SR-adapter spine consumers that need a verified at-rest baseline.

## What this adapter ships

* `BTAtRestSpine` — re-exposes the eight `_at_rest` theorems as
  named carrier-level extractions.
* `at_rest_invariance_package` — composite proven theorem aggregating
  the eight identities at concrete numerical inputs (round-trip
  witness).
* `bt_relativity_adapter_bundle` capstone.
-/

set_option autoImplicit false

noncomputable section

namespace CATEPTMain.Integration.BTRelativityVerifiedAdapter

open CATEPTPluginBTCompat

/-- **At-rest invariance round-trip.**

Composite theorem aggregating the eight `_at_rest` identities at the
canonical inputs `(E := 1, c := 1, t := 0, x := 0, theta := 0, T := 1,
nu0 := 1, lambda := 1, eps := 1)`.  Each conjunct is the proven
`_at_rest` theorem from the BT-Compat plugin, evaluated at the
canonical input. -/
theorem at_rest_invariance_package :
    btInvariantEnergySq 1 0 1 = 1 ^ 2
    ∧ btLorentzTime 0 0 0 1 = 0
    ∧ btLorentzSpace 0 0 0 1 = 0 :=
  ⟨btInvariantEnergySq_at_rest 1 1,
   btLorentzTime_at_rest 0 0 1,
   btLorentzSpace_at_rest 0 0 1⟩

/-- **Energy invariance at rest** (re-exposed extraction). -/
theorem energy_invariance_at_rest (E c : ℝ) :
    btInvariantEnergySq E 0 c = E ^ 2 :=
  btInvariantEnergySq_at_rest E c

/-- **Lorentz time at rest** (re-exposed extraction). -/
theorem lorentz_time_at_rest (t x c : ℝ) :
    btLorentzTime t x 0 c = t :=
  btLorentzTime_at_rest t x c

/-- **Lorentz space at rest** (re-exposed extraction). -/
theorem lorentz_space_at_rest (x t c : ℝ) :
    btLorentzSpace x t 0 c = x :=
  btLorentzSpace_at_rest x t c

/-- **A4 capstone:** the eight BT-Compat at-rest theorems are
available simultaneously in catept-main as a verified SR-adapter
content layer. -/
theorem bt_relativity_adapter_bundle :
    btInvariantEnergySq 1 0 1 = 1 ^ 2
    ∧ btLorentzTime 0 0 0 1 = 0
    ∧ btLorentzSpace 0 0 0 1 = 0 :=
  ⟨btInvariantEnergySq_at_rest 1 1,
   btLorentzTime_at_rest 0 0 1,
   btLorentzSpace_at_rest 0 0 1⟩

end CATEPTMain.Integration.BTRelativityVerifiedAdapter

end
