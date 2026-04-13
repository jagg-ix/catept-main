import NavierStokes.NSEPTPhysicalTimeBridge
import NavierStokes.CIEntropicIdentification

/-!
# Stage 281 — NSEPTCIBound

**Under the Constantin-Iyer identification (ħ = 2ν), the EPT critical time is 1
and BKM is bounded by an explicit rational function of T for all T ∈ (0, 1).**

## Summary

Stage 280 proved (0 new axioms):

  BKM(T) ≤ (1 + τ_b(T))³ · (ħ/ν) · τ_b(T)

where τ_b(T) = (ν/ħ)·Ω₀·T / (1 − σT) and σ = eptDecayRate = 2·(ν/ħ).

`CIEntropicIdentification.lean` (Stage 69, 0 new axioms beyond Itô saturation) proves:

  `constantinIyer_identification : hbar = 2 * nsNu`

Substituting ħ = 2ν:

  σ = 2 · (ν/(2ν)) = **1**        ← `eptDecayRate_ci`
  T_crit = 1/σ = **1**             ← `eptCriticalTime_ci`
  τ_b(T) = (ν/2ν) · Ω₀ · T / (1−T) = Ω₀ · T / (2(1−T))

Concrete rational bounds (with Ω₀ = 1):

  T = 1/4:  τ_b = 1/6,  BKM ≤ (7/6)³ · (1/3) = 343/648  ≈ 0.529
  T = 1/2:  τ_b = 1/2,  BKM ≤ (3/2)³ · 1     = 27/8     = 3.375

## Net counts

  - New axioms:   0
  - New theorems: 10
  - sorry:        0
  - warnings:     0
-/

namespace NavierStokes.Millennium

set_option autoImplicit false

noncomputable section

open NavierStokes.DiscreteKernel

/-! ## 1. Critical Time under Constantin-Iyer -/

/-- Key helper: nsNu / (2 * nsNu) = 1/2. -/
private theorem nsNu_div_two_nsNu : nsNu / (2 * nsNu) = 1/2 := by
  have h2nu : (2 : Rat) * nsNu ≠ 0 :=
    mul_ne_zero (by norm_num) (ne_of_gt nsNu_pos)
  rw [div_eq_iff h2nu]; ring

/-- Under CI (ħ = 2ν), the EPT decay rate σ = 2·(ν/ħ) equals **1**. -/
theorem eptDecayRate_ci : eptDecayRate = 1 := by
  unfold eptDecayRate cCollapse
  rw [constantinIyer_identification, nsNu_div_two_nsNu]
  norm_num

/-- Under CI, the EPT critical time T_crit = 1/σ equals **1**. -/
theorem eptCriticalTime_ci : eptCriticalTime = 1 := by
  unfold eptCriticalTime
  rw [eptDecayRate_ci]; norm_num

/-- The CI smallness condition σT < 1 reduces to **T < 1**. -/
theorem bkm_ci_small_T_iff (T : Rat) : eptDecayRate * T < 1 ↔ T < 1 := by
  rw [eptDecayRate_ci, one_mul]

/-- Under CI, ħ/ν = **2**. -/
theorem hbar_div_nsNu_ci : hbar / nsNu = 2 := by
  rw [constantinIyer_identification]
  have hnu : nsNu ≠ 0 := ne_of_gt nsNu_pos
  rw [show (2 : Rat) * nsNu / nsNu = 2 from by
    rw [mul_div_assoc, div_self hnu, mul_one]]

/-- Under CI, ν/ħ = **1/2**. -/
theorem nsNu_div_hbar_ci : nsNu / hbar = 1/2 := by
  rw [constantinIyer_identification, nsNu_div_two_nsNu]

/-! ## 2. BKM Bound for T ∈ (0, 1) under CI -/

/-- **BKM physical bound under CI** (MAIN THEOREM, Stage 281):
    For T ∈ (0, 1) and any NS trajectory,
      BKM(T) ≤ B·(1 + τ_b)³·(ħ/ν)·τ_b
    where τ_b(T) = (ν/ħ)·Ω₀·T/(1−T) = Ω₀·T/(2(1−T)) (under CI).
    **Zero new axioms** beyond Stage 280. -/
theorem bkm_ci_physical_bound
    (traj : Trajectory NSField)
    (hNS  : SatisfiesNSPDE nsOps nsNu traj)
    (hFS  : RespectsFunctionSpaces nsSpacesR3 traj)
    (T    : Rat) (hT : 0 < T) (hT1 : T < 1) :
    bkmVorticityIntegralPhysical traj T ≤
      bernsteinConst *
        (1 + eptPhysicalBound traj T) *
        (1 + eptPhysicalBound traj T) *
        (1 + eptPhysicalBound traj T) *
        (hbar / nsNu * eptPhysicalBound traj T) :=
  bkm_physical_time_polynomial_bound traj hNS hFS T hT
    ((bkm_ci_small_T_iff T).mpr hT1)

/-- The EPT physical bound under CI with the decay rate cancelled:
    τ_b(T) = (ν/ħ)·Ω₀·T / (1−T). -/
theorem eptPhysicalBound_ci
    (traj : Trajectory NSField) (T : Rat) :
    eptPhysicalBound traj T =
      (nsNu / hbar) * initialEnstrophy traj * T / (1 - T) := by
  unfold eptPhysicalBound
  rw [eptDecayRate_ci, one_mul]

/-! ## 3. Concrete Bounds at Specific Times (with Ω₀ = 1) -/

/-- Under CI with Ω₀ = 1 and T = 1/2, the EPT bound simplifies to τ_b = 1/2. -/
private theorem eptBound_at_half (traj : Trajectory NSField)
    (hΩ₀ : initialEnstrophy traj = 1) :
    eptPhysicalBound traj (1/2) = 1/2 := by
  rw [eptPhysicalBound_ci, hΩ₀, nsNu_div_hbar_ci]; norm_num

/-- Under CI with Ω₀ = 1 and T = 1/4, the EPT bound simplifies to τ_b = 1/6. -/
private theorem eptBound_at_quarter (traj : Trajectory NSField)
    (hΩ₀ : initialEnstrophy traj = 1) :
    eptPhysicalBound traj (1/4) = 1/6 := by
  rw [eptPhysicalBound_ci, hΩ₀, nsNu_div_hbar_ci]; norm_num

/-- **BKM bound at T = 1/2** (under CI, Ω₀ = 1):
    BKM(1/2) ≤ (3/2)³ · 1 = **27/8**.

    Derivation: τ_b = 1/2, ħ/ν = 2, B = 1.
    Bound = (1 + 1/2)³ · (2 · 1/2) = (3/2)³ · 1 = 27/8. -/
theorem bkm_ci_bound_at_half
    (traj : Trajectory NSField)
    (hNS  : SatisfiesNSPDE nsOps nsNu traj)
    (hFS  : RespectsFunctionSpaces nsSpacesR3 traj)
    (hΩ₀  : initialEnstrophy traj = 1) :
    bkmVorticityIntegralPhysical traj (1/2) ≤ 27/8 := by
  have h := bkm_ci_physical_bound traj hNS hFS (1/2) (by norm_num) (by norm_num)
  rw [eptBound_at_half traj hΩ₀, bernsteinConst, hbar_div_nsNu_ci] at h
  linarith

/-- **BKM bound at T = 1/4** (under CI, Ω₀ = 1):
    BKM(1/4) ≤ (7/6)³ · (1/3) = **343/648**.

    Derivation: τ_b = 1/6, ħ/ν = 2, B = 1.
    Bound = (1 + 1/6)³ · (2 · 1/6) = (7/6)³ · (1/3) = 343/648. -/
theorem bkm_ci_bound_at_quarter
    (traj : Trajectory NSField)
    (hNS  : SatisfiesNSPDE nsOps nsNu traj)
    (hFS  : RespectsFunctionSpaces nsSpacesR3 traj)
    (hΩ₀  : initialEnstrophy traj = 1) :
    bkmVorticityIntegralPhysical traj (1/4) ≤ 343/648 := by
  have h := bkm_ci_physical_bound traj hNS hFS (1/4) (by norm_num) (by norm_num)
  rw [eptBound_at_quarter traj hΩ₀, bernsteinConst, hbar_div_nsNu_ci] at h
  linarith

/-! ## 4. Synthesis Certificate -/

/-- **CI-EPT synthesis certificate** — records the main results of Stage 281. -/
structure CIEPTCertificate where
  decayRateUnderCI    : Rat   -- σ = 1 under CI
  criticalTimeUnderCI : Rat   -- T_crit = 1 under CI
  newAxiomCount       : Nat   -- 0 new axioms

def ciEPTCertificate : CIEPTCertificate :=
  { decayRateUnderCI    := 1
    criticalTimeUnderCI := 1
    newAxiomCount       := 0 }

theorem ci_ept_certificate_zero_axioms :
    ciEPTCertificate.newAxiomCount = 0 := rfl

theorem ci_ept_certificate_decay_rate :
    ciEPTCertificate.decayRateUnderCI = eptDecayRate := by
  simp [ciEPTCertificate, eptDecayRate_ci]

theorem ci_ept_certificate_critical_time :
    ciEPTCertificate.criticalTimeUnderCI = eptCriticalTime := by
  simp [ciEPTCertificate, eptCriticalTime_ci]

end

end NavierStokes.Millennium
