import CATEPTPluginDomainCore.PHQ.PHQPrelude

/-!
# PHQPrelude — re-export shim
Authoritative source: `CATEPTPluginDomainCore.PHQ.PHQPrelude` in sibling
[`jagg-ix/catept-domain-core`](https://github.com/jagg-ix/catept-domain-core).
-/

set_option autoImplicit false

namespace CATEPTMain.Core.PHQ

export CATEPTPluginDomainCore.PHQ (
  PhysDim
  PhysQuantity
  constBoltzmann
  constPlanck
  constSpeedOfLight
  dimAcceleration
  dimAdd
  dimAdd_assoc
  dimAdd_comm
  dimAdd_zero
  dimAmount
  dimBoltzmann
  dimCurrent
  dimDimensionless
  dimEnergy
  dimForce
  dimFrequency
  dimLength
  dimLuminosity
  dimMass
  dimNeg
  dimPlanck
  dimPower
  dimPressure
  dimScale
  dimSub
  dimTemperature
  dimTime
  dimVelocity
  physAdd
  physDiv
  physMk
  physMk_val
  physMul
  physMul_val
  physScale
  physVal
  physVal_mk
  siAmpere
  siCandela
  siKelvin
  siKilogram
  siMetre
  siMole
  siSecond
)

end CATEPTMain.Core.PHQ
