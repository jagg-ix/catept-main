import NavierStokes.Bridges.NSModularNoetherBridge
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith

/-!
# NS Araki Relative Entropy Bridge

Stage-78 bridge layer that introduces an NS-relative-entropy analog and connects
its rate sign to the existing NS bottleneck defect/kms identities.

No Stage-64 closure claim is introduced.
-/

namespace NavierStokes.Bridges.NSArakiRelativeEntropy

set_option autoImplicit false

open NavierStokes.Millennium
open NavierStokes.Bridges.NSModularNoether

noncomputable section

/-- NS Araki-relative-entropy analog:
`S_rel^NS(t) := Ω(t) / (2ν)`.

This is a structural bridge object; no AQFT completeness claim is made. -/
def nsArakiRelativeEntropy
    (traj : Trajectory NSField) (t : Rat) : Rat :=
  enstrophy (traj.stateAt t).velocity / (2 * nsNu)

/-- NS Araki-relative-entropy rate proxy:
`(d/dt) S_rel^NS := (dΩ/dt)/(2ν)`.

This uses the existing trajectory-level `enstrophyRate` object. -/
def nsArakiRelativeEntropyRate
    (traj : Trajectory NSField) (t : Rat) : Rat :=
  enstrophyRate traj t / (2 * nsNu)

/-- Positivity of the NS Araki-relative-entropy analog follows from `Ω ≥ 0`. -/
theorem ns_araki_rel_entropy_nonneg
    (traj : Trajectory NSField) (t : Rat) :
    0 ≤ nsArakiRelativeEntropy traj t := by
  unfold nsArakiRelativeEntropy
  have hOmega : 0 ≤ enstrophy (traj.stateAt t).velocity :=
    enstrophy_nonneg (traj.stateAt t).velocity
  have hDen : 0 ≤ 2 * nsNu := by nlinarith [nsNu_pos]
  exact div_nonneg hOmega hDen

/-- Helper identity: `enstrophyRate = (2ν) * nsArakiRelativeEntropyRate`. -/
theorem ns_araki_rel_entropy_rate_scaled
    (traj : Trajectory NSField) (t : Rat) :
    (2 * nsNu) * nsArakiRelativeEntropyRate traj t = enstrophyRate traj t := by
  unfold nsArakiRelativeEntropyRate
  have hNu : nsNu ≠ 0 := by nlinarith [nsNu_pos]
  have hDen : (2 * nsNu) ≠ 0 := by nlinarith [nsNu_pos]
  field_simp [hDen, hNu]

/-- Exact defect-rate identity for the NS-relative-entropy analog:
`(d/dt)S_rel^NS = -D_I/ν`. -/
theorem ns_araki_rel_entropy_rate_eq_neg_defect_over_nu
    (traj : Trajectory NSField) (t : Rat)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj) :
    nsArakiRelativeEntropyRate traj t = -imaginaryNoetherDefect traj t / nsNu := by
  unfold nsArakiRelativeEntropyRate
  rw [enstrophyRate_eq_neg_two_imaginaryNoetherDefect traj t hNS hFS]
  have hNu : nsNu ≠ 0 := by nlinarith [nsNu_pos]
  field_simp [hNu]

/-- Rate-sign equivalence:
`(d/dt)S_rel^NS ≤ 0` iff `dΩ/dt ≤ 0`. -/
theorem ns_araki_rel_entropy_rate_nonpos_iff_enstrophy_rate_nonpos
    (traj : Trajectory NSField) (t : Rat) :
    nsArakiRelativeEntropyRate traj t ≤ 0 ↔ enstrophyRate traj t ≤ 0 := by
  unfold nsArakiRelativeEntropyRate
  have hPos : 0 < 2 * nsNu := by nlinarith [nsNu_pos]
  have hNonneg : 0 ≤ 2 * nsNu := le_of_lt hPos
  have hNu : nsNu ≠ 0 := by nlinarith [nsNu_pos]
  have hDen : (2 * nsNu) ≠ 0 := by nlinarith [nsNu_pos]
  constructor
  · intro hRate
    have hMul :
        (2 * nsNu) * (enstrophyRate traj t / (2 * nsNu)) ≤ (2 * nsNu) * 0 :=
      mul_le_mul_of_nonneg_left hRate hNonneg
    have hLeft : (2 * nsNu) * (enstrophyRate traj t / (2 * nsNu)) = enstrophyRate traj t := by
      field_simp [hDen, hNu]
    have hRight : (2 * nsNu) * 0 = (0 : Rat) := by ring
    simpa [hLeft, hRight] using hMul
  · intro hEnst
    have hInvNonneg : 0 ≤ (1 / (2 * nsNu)) := by
      exact le_of_lt (one_div_pos.mpr hPos)
    have hMul :
        (1 / (2 * nsNu)) * enstrophyRate traj t ≤ (1 / (2 * nsNu)) * 0 :=
      mul_le_mul_of_nonneg_left hEnst hInvNonneg
    simpa [div_eq_mul_inv, mul_assoc, mul_comm, mul_left_comm] using hMul

/-- NS Stage-78 bottleneck equivalence in relative-entropy language:
`(d/dt)S_rel^NS ≤ 0` iff `D_I ≥ 0`. -/
theorem ns_araki_rel_entropy_decreasing_iff_di_nonneg
    (traj : Trajectory NSField) (t : Rat)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj) :
    nsArakiRelativeEntropyRate traj t ≤ 0 ↔ 0 ≤ imaginaryNoetherDefect traj t := by
  have hRate :
      nsArakiRelativeEntropyRate traj t ≤ 0 ↔ enstrophyRate traj t ≤ 0 :=
    ns_araki_rel_entropy_rate_nonpos_iff_enstrophy_rate_nonpos traj t
  have hDefect :
      0 ≤ imaginaryNoetherDefect traj t ↔ enstrophyRate traj t ≤ 0 :=
    defect_nonneg_iff_enstrophy_rate_nonpos traj t hNS hFS
  exact hRate.trans hDefect.symm

/-- Equivalent bottleneck view through direct `VS ≤ νP`. -/
theorem ns_araki_rel_entropy_decreasing_iff_vs_le_nuP
    (traj : Trajectory NSField) (t : Rat)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj) :
    nsArakiRelativeEntropyRate traj t ≤ 0 ↔
      vortexStretchingIntegral traj t ≤ nsNu * palinstrophy (traj.stateAt t).velocity := by
  calc
    nsArakiRelativeEntropyRate traj t ≤ 0
        ↔ 0 ≤ imaginaryNoetherDefect traj t :=
      ns_araki_rel_entropy_decreasing_iff_di_nonneg traj t hNS hFS
    _ ↔ vortexStretchingIntegral traj t ≤ nsNu * palinstrophy (traj.stateAt t).velocity :=
      defect_nonneg_iff_vs_le_nuP traj t

/-- Stage-78 identification proposition (local trajectory-time form). -/
def NSArakiRelativeEntropyAnalogProp : Prop :=
  ∀ (traj : Trajectory NSField) (t : Rat),
    SatisfiesNSPDE nsOps nsNu traj →
    RespectsFunctionSpaces nsSpacesR3 traj →
    0 ≤ nsArakiRelativeEntropy traj t ∧
    (nsArakiRelativeEntropyRate traj t ≤ 0 ↔
      0 ≤ imaginaryNoetherDefect traj t)

/-- Stage-78 identification holds at theorem level (local form). -/
theorem ns_araki_relative_entropy_aqft_analog :
    NSArakiRelativeEntropyAnalogProp := by
  intro traj t hNS hFS
  constructor
  · exact ns_araki_rel_entropy_nonneg traj t
  · exact ns_araki_rel_entropy_decreasing_iff_di_nonneg traj t hNS hFS

/-! ## Claim Registry -/

def nsArakiRelativeEntropyClaims : List LabeledClaim :=
  [ ⟨"ns_araki_rel_entropy_nonneg", .verified,
      "THEOREM: NS relative entropy analog Ω/(2ν) is nonnegative."⟩
  , ⟨"ns_araki_rel_entropy_rate_eq_neg_defect_over_nu", .verified,
      "THEOREM: (d/dt)S_rel^NS = -D_I/ν using Stage-76 defect identity."⟩
  , ⟨"ns_araki_rel_entropy_rate_nonpos_iff_enstrophy_rate_nonpos", .verified,
      "THEOREM: relative-entropy rate nonpositive iff enstrophy rate nonpositive."⟩
  , ⟨"ns_araki_rel_entropy_decreasing_iff_di_nonneg", .verified,
      "THEOREM: relative-entropy monotonicity iff imaginary defect nonnegative."⟩
  , ⟨"ns_araki_rel_entropy_decreasing_iff_vs_le_nuP", .verified,
      "THEOREM: relative-entropy monotonicity iff VS<=νP at trajectory-time level."⟩
  , ⟨"ns_araki_relative_entropy_aqft_analog", .partiallyVerified,
      "THEOREM: local AQFT-analog identification in NS (no global Stage-64 closure claim)."⟩
  ]

end

end NavierStokes.Bridges.NSArakiRelativeEntropy
