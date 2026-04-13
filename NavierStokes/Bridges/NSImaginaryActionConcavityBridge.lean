import NavierStokes.Bridges.NSArakiRelativeEntropyBridge
import NavierStokes.EntropicRateBoundUniformBKM
import Mathlib.Tactic.Linarith

/-!
# NS Imaginary-Action Concavity Bridge

Stage-79 bridge layer that makes explicit the two CAT/EPT imaginary-action
channels used in the NS stack:

1. `S_I^Ω` channel (enstrophy-driven clock channel):
   - first rate: `dS_I^Ω/dt = ν * Ω`
   - second-rate witness: `d²S_I^Ω/dt² = ν * dΩ/dt`
   - theorem-level equivalence:
     `d²S_I^Ω/dt² ≤ 0 ↔ D_I ≥ 0 ↔ VS ≤ νP`

2. `S_I^BKM` channel (BKM/linfty-vorticity channel):
   - first rate: `dS_I^BKM/dt = ν * ||ω||_{L∞}`
   - positivity is tracked as an explicit contract, not silently assumed.

No Stage-64 closure claim is introduced.
-/

namespace NavierStokes.Bridges.NSImaginaryActionConcavity

set_option autoImplicit false

open NavierStokes.Millennium
open NavierStokes.Bridges.NSModularNoether
open NavierStokes.Bridges.NSArakiRelativeEntropy

noncomputable section

/-! ## 1. Two Imaginary-Action Rate Channels -/

/-- Enstrophy-driven imaginary-action first rate:
`dS_I^Ω/dt := ν * Ω(t)`. -/
def imaginaryActionOmegaRate
    (traj : Trajectory NSField) (t : Rat) : Rat :=
  nsNu * enstrophy (traj.stateAt t).velocity

/-- BKM-driven imaginary-action first rate:
`dS_I^BKM/dt := ν * ||ω||_{L∞}(t)`. -/
def imaginaryActionBKMRate
    (traj : Trajectory NSField) (t : Rat) : Rat :=
  nsNu * vorticityLinfty (traj.stateAt t).velocity

/-- Immediate nonnegativity on the `S_I^Ω` channel from `ν>0`, `Ω≥0`. -/
theorem imaginary_action_omega_rate_nonneg
    (traj : Trajectory NSField) (t : Rat) :
    0 ≤ imaginaryActionOmegaRate traj t := by
  unfold imaginaryActionOmegaRate
  exact mul_nonneg (le_of_lt nsNu_pos)
    (enstrophy_nonneg (traj.stateAt t).velocity)

/-- Contract-scoped positivity for the BKM channel.
This keeps the first-order BKM positivity explicit when `vorticityLinfty` is
represented abstractly in the current NS axiomatization. -/
def ImaginaryActionBKMRateNonnegContract : Prop :=
  ∀ (traj : Trajectory NSField) (t : Rat), 0 ≤ imaginaryActionBKMRate traj t

/-- Under the explicit contract, the BKM channel is first-order nonnegative. -/
theorem imaginary_action_bkm_rate_nonneg_of_contract
    (hBKM : ImaginaryActionBKMRateNonnegContract)
    (traj : Trajectory NSField) (t : Rat) :
    0 ≤ imaginaryActionBKMRate traj t :=
  hBKM traj t

/-! ## 2. Second-Rate Witness and Concavity Equivalences -/

/-- Witness form for the second derivative of the `S_I^Ω` channel:
`d²S_I^Ω/dt² = ν * dΩ/dt`. -/
def ImaginaryActionOmegaSecondRateWitness
    (traj : Trajectory NSField) (t : Rat) (d2SI_Omega : Rat) : Prop :=
  d2SI_Omega = nsNu * enstrophyRate traj t

/-- Under the witness, second rate equals `-2ν D_I`. -/
theorem imaginary_action_omega_second_rate_eq_neg_two_nu_defect_of_witness
    (traj : Trajectory NSField) (t : Rat) (d2SI_Omega : Rat)
    (hW : ImaginaryActionOmegaSecondRateWitness traj t d2SI_Omega)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj) :
    d2SI_Omega = -2 * nsNu * imaginaryNoetherDefect traj t := by
  unfold ImaginaryActionOmegaSecondRateWitness at hW
  calc
    d2SI_Omega = nsNu * enstrophyRate traj t := hW
    _ = nsNu * (-2 * imaginaryNoetherDefect traj t) := by
      rw [enstrophyRate_eq_neg_two_imaginaryNoetherDefect traj t hNS hFS]
    _ = -2 * nsNu * imaginaryNoetherDefect traj t := by ring

/-- Concavity form at one trajectory-time point:
`d²S_I^Ω/dt² ≤ 0 ↔ D_I ≥ 0` under the second-rate witness. -/
theorem imaginary_action_omega_concavity_iff_defect_nonneg_of_witness
    (traj : Trajectory NSField) (t : Rat) (d2SI_Omega : Rat)
    (hW : ImaginaryActionOmegaSecondRateWitness traj t d2SI_Omega)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj) :
    d2SI_Omega ≤ 0 ↔ 0 ≤ imaginaryNoetherDefect traj t := by
  have hEq :
      d2SI_Omega = -2 * nsNu * imaginaryNoetherDefect traj t :=
    imaginary_action_omega_second_rate_eq_neg_two_nu_defect_of_witness
      traj t d2SI_Omega hW hNS hFS
  constructor
  · intro hConc
    have hScaled : -2 * nsNu * imaginaryNoetherDefect traj t ≤ 0 := by
      simpa [hEq] using hConc
    nlinarith [hScaled, nsNu_pos]
  · intro hDefect
    have hConc' : -2 * nsNu * imaginaryNoetherDefect traj t ≤ 0 := by
      nlinarith [hDefect, nsNu_pos]
    simpa [hEq] using hConc'

/-- Equivalent bottleneck form:
`d²S_I^Ω/dt² ≤ 0 ↔ VS ≤ νP` under the second-rate witness. -/
theorem imaginary_action_omega_concavity_iff_vs_le_nuP_of_witness
    (traj : Trajectory NSField) (t : Rat) (d2SI_Omega : Rat)
    (hW : ImaginaryActionOmegaSecondRateWitness traj t d2SI_Omega)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj) :
    d2SI_Omega ≤ 0 ↔
      vortexStretchingIntegral traj t ≤ nsNu * palinstrophy (traj.stateAt t).velocity := by
  calc
    d2SI_Omega ≤ 0
        ↔ 0 ≤ imaginaryNoetherDefect traj t :=
      imaginary_action_omega_concavity_iff_defect_nonneg_of_witness
        traj t d2SI_Omega hW hNS hFS
    _ ↔ vortexStretchingIntegral traj t ≤ nsNu * palinstrophy (traj.stateAt t).velocity :=
      defect_nonneg_iff_vs_le_nuP traj t

/-! ## 3. Claim Registry -/

def nsImaginaryActionConcavityClaims : List LabeledClaim :=
  [ ⟨"imaginary_action_omega_rate_nonneg", .verified,
      "THEOREM: first-rate positivity on S_I^Ω channel, dS_I^Ω/dt = νΩ >= 0."⟩
  , ⟨"imaginary_action_bkm_rate_nonneg_of_contract", .partiallyVerified,
      "THEOREM: first-rate positivity on S_I^BKM channel under explicit vorticity-L∞ nonneg contract."⟩
  , ⟨"imaginary_action_omega_second_rate_eq_neg_two_nu_defect_of_witness", .verified,
      "THEOREM: witness-level second-rate identity d²S_I^Ω/dt² = -2νD_I."⟩
  , ⟨"imaginary_action_omega_concavity_iff_defect_nonneg_of_witness", .verified,
      "THEOREM: concavity form d²S_I^Ω/dt²<=0 iff D_I>=0 (witness-scoped)."⟩
  , ⟨"imaginary_action_omega_concavity_iff_vs_le_nuP_of_witness", .verified,
      "THEOREM: concavity form d²S_I^Ω/dt²<=0 iff VS<=νP (witness-scoped)."⟩
  ]

end

end NavierStokes.Bridges.NSImaginaryActionConcavity
