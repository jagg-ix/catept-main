import CATEPTMain.Integration.MatsubaraLuttingerWardCarrier
import CATEPTMain.Integration.UnificationSpineHonestWitness

/-!
# Certification: Modular / Thermal Sector

This file is the canonical modular-thermal sector certificate for the
`CATEPTMain/Certification/` meta-layer.

## Source material

Wraps two existing modules:

**`MatsubaraLuttingerWardCarrier`**:

| Source | Content |
|---|---|
| `MatsubaraLuttingerWardCarrier` | Carrier: β, ℏ, Ω, Z, τ_ent with `τ_ent = β·Ω` |
| `tauEnt_eq_beta_Omega` | `τ_ent = β·Ω` |
| `S_I_eq_hbar_tauEnt` | `S_I = ℏ·τ_ent` (core CAT/EPT identity) |
| `tauEnt_eq_neg_log_Z` | `τ_ent = −log Z` |
| `matsubara_luttinger_ward_bundle` | Ground-level existence |

**`UnificationSpineHonestWitness`**:

| Source | Content |
|---|---|
| `honestUnificationBundle` | Non-degenerate `CATEPTUnificationBundle` with β=ℏ=Ω=1, Z=exp(−1) |

## Certified claim

> The Matsubara imaginary-time formalism and Luttinger–Ward free-energy
> functional are CAT/EPT-compatible: the imaginary action `S_I = ℏ·τ_ent`
> coincides with `ℏ·β·Ω`, and the partition-function relation
> `τ_ent = −log Z` is machine-checked.  The honest bundle
> `honestUnificationBundle` witnesses that the four-pillar
> (QM/Thermo/EM/GR) unification is non-trivially satisfied (β=ℏ=Ω=1).

## What is NOT yet certified here

- KMS condition as a Prop (lives in `KMSModularParameterBridge`).
- Tomita–Takesaki modular automorphism group linking (lives in
  `TomitaMatsubaraEquivBridge`).
-/

namespace CATEPTMain.Certification.ModularThermal

open CATEPTMain.Integration.MatsubaraLuttingerWardCarrier
open CATEPTMain.Integration.UnificationSpine
open CATEPTMain.Integration.UnificationSpineHonestWitness

/-- Public compatibility alias for the modular-thermal certification type. -/
abbrev ModularThermalCATEPTCertificate := CATEPTUnificationBundle

/-- Re-export: Matsubara–LW carrier type. -/
abbrev MLWCarrier := MatsubaraLuttingerWardCarrier

/-- Re-export: The core CAT/EPT imaginary-action identity `S_I = ℏ·τ_ent`. -/
theorem thermal_imaginary_action_eq (M : MatsubaraLuttingerWardCarrier) :
    M.S_I = M.ℏ * M.τ_ent :=
  M.S_I_eq_hbar_tauEnt

/-- Re-export: Partition-function relation `τ_ent = −log Z`. -/
theorem thermal_tauEnt_neg_log_Z (M : MatsubaraLuttingerWardCarrier) :
    M.τ_ent = -Real.log M.Z :=
  M.tauEnt_eq_neg_log_Z

/-- Re-export: `τ_ent = β·Ω`. -/
theorem thermal_tauEnt_eq_beta_Omega (M : MatsubaraLuttingerWardCarrier) :
    M.τ_ent = M.β * M.Ω :=
  M.tauEnt_eq_beta_Omega

/-- The canonical non-degenerate thermal witness (β=ℏ=Ω=1, Z=exp(−1)).

This is `honestUnificationBundle` from
`CATEPTMain.Integration.UnificationSpineHonestWitness`. -/
noncomputable def canonical_thermal_bundle : CATEPTUnificationBundle :=
  honestUnificationBundle

/-- The canonical thermal bundle satisfies the QM ↔ Matsubara shared-clock identity. -/
theorem canonical_qm_matsubara_eq :
    canonical_thermal_bundle.qmClock.entropicTime =
    canonical_thermal_bundle.spine.pwMat.matsubara.τ_ent :=
  canonical_thermal_bundle.qm_tauEnt_eq_matsubara

end CATEPTMain.Certification.ModularThermal
