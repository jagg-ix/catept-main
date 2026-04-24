import CATEPTMain.Domains.SuperiorMethod
import CATEPTMain.Quantum.QUANTUM.QFIToolbox

/-!
# QM Superior-Method Domain

Defines the Quantum-Mechanics domain slot for the CATEPT plugin architecture
using the Superior-Method pattern: a single `actionFn = vonNeumannEntropy`
serves as both the imaginary action and the entropic clock.

## Physical interpretation

For a density matrix ρ, the von Neumann entropy S(ρ) = −Tr(ρ log₂ ρ) ≥ 0 is:
  - the imaginary action measuring decoherence/irreversibility
  - the entropic clock τ_ent(ρ) = S(ρ)  (with ħ = 1)

The consistency constraint `S(ρ) / 1 = S(ρ)` holds by `div_one` — no slot
unfolding required.

## Import profile (core-free)

This file does NOT import `CATEPTMain.CATEPT.CATEPT.CATEPTPort` or any
`CATEPTMain.CATEPT.CATEPT.*` core module.  It depends only on:
  - `CATEPTMain.Domains.SuperiorMethod`  (the slot interface)
  - `CATEPTMain.Quantum.QUANTUM.QFIToolbox`  (von Neumann entropy)
-/

set_option autoImplicit false

open CATEPTMain.Quantum.QUANTUM

namespace CATEPTMain.Domains.QM

/-- The QM Superior-Method slot.

    Configuration space: `DensityMatrix n` (n × n mixed quantum states).
    The entropic action is the von Neumann entropy S(ρ) ≥ 0.

    With ħ = 1 (canonical), `eptClock = actionIm = S(ρ)` by construction. -/
def qmSuperiorSlot (n : ℕ) : SuperiorMethodSlot where
  ConfigSpaceTy   := DensityMatrix n
  actionRe        := fun _ => 0
  actionFn        := fun ρ => vonNeumannEntropy n ρ
  actionFn_nonneg := vonNeumannEntropy_nonneg n

/-- The QM superior slot satisfies the CATEPT consistency constraint.
    Proof: `S(ρ) / 1 = S(ρ)` by `div_one`.  No slot unfolding. -/
theorem qmSuperiorSlot_consistent (n : ℕ) :
    CATEPTMain.Integration.cateptConsistencyConstraint
      (qmSuperiorSlot n).toCATEPTSlot :=
  (qmSuperiorSlot n).consistent

/-- The QM superior slot's Feynman-Kac weight is `exp(-S(ρ))`.
    Measures quantum mixedness; maximal weight at pure states (S=0). -/
theorem qmSuperiorSlot_damping (n : ℕ) (ρ : DensityMatrix n) :
    Real.exp (-((qmSuperiorSlot n).toCATEPTSlot.actionIm ρ /
                (qmSuperiorSlot n).toCATEPTSlot.hbar)) =
    Real.exp (-(vonNeumannEntropy n ρ)) :=
  (qmSuperiorSlot n).damping_eq ρ

end CATEPTMain.Domains.QM
