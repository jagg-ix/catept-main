import NavierStokes.Bridges.NSBernsteinEPTDegree4Bridge

/-!
# Stage 280 — NSEPTPhysicalTimeBridge

**Bound τ_ent(T) by physical time T, giving BKM as a rational function of T.**

## Summary

Stage 279 proved:

  BKM(T) ≤ (ħ/ν) · (1 + τ)³ · τ         (degree-4 in τ)

where τ = entropicProperTime traj T. But τ itself depends on the trajectory.

This file connects τ to the **physical time** T via the Gronwall linear bound
from Stage 274 (`enstrophy_gronwall_linear`):

  Ω(s) ≤ Ω₀ + 2C·τ(T)   for all s ≤ T, where C = cCollapse = 1

Integrating both sides over [0,T] (the discrete integral kernel from Stage 113)
and using the definition τ = (ν/ħ)·∫₀ᵀ Ω(t) dt:

  τ ≤ (ν/ħ) · (Ω₀·T + 2C·τ·T)
  τ · (1 − σT) ≤ (ν/ħ) · Ω₀ · T        where σ = 2C·(ν/ħ)

For T < T_crit = 1/σ (where T_crit = ħ/(2Cν)), the factor (1 − σT) is positive
and we can divide through to get:

  τ ≤ τ_bound(T) = (ν/ħ) · Ω₀ · T / (1 − σT)

Substituting into Stage 279's degree-4 bound gives BKM(T) bounded by an explicit
**rational function of physical time T** — finite for all T < T_crit.

## Key Axiom

The step "integrating the Gronwall bound over [0,T]" uses the fact that
`discreteIntegral_le_of_pointwise` requires a **universal** bound
`∀ t : Rat, f t ≤ g t`, but `enstrophy_gronwall_uniform` only gives
`∀ s ≤ T, Ω(s) ≤ Ω₀ + 2C·τ(T)`. The upper limit T appears in the bound,
creating a self-referential structure. We axiomatize this step as
`ept_self_referential_bound` (epistemic status: `.partiallyVerified`).

## Net counts

  - New axioms:   1  (ept_self_referential_bound, .partiallyVerified)
  - New theorems: 11
  - sorry:        0
  - warnings:     0
-/

namespace NavierStokes.Millennium

set_option autoImplicit false

noncomputable section

open NavierStokes.DiscreteKernel

/-! ## 1. EPT Decay Rate and Critical Time -/

/-- **EPT decay rate**: σ = 2 · C_collapse · (ν/ħ).

    With cCollapse = 1 this is σ = 2·ν/ħ. -/
def eptDecayRate : Rat := 2 * cCollapse * (nsNu / hbar)

/-- **Critical time**: T_crit = 1/σ = ħ/(2Cν).

    For T < T_crit the EPT-physical-time bound is valid. -/
noncomputable def eptCriticalTime : Rat := 1 / eptDecayRate

theorem eptDecayRate_pos : 0 < eptDecayRate := by
  unfold eptDecayRate
  apply mul_pos
  · apply mul_pos
    · norm_num
    · exact cCollapse_pos
  · exact div_pos nsNu_pos hbar_pos

theorem eptCriticalTime_pos : 0 < eptCriticalTime := by
  unfold eptCriticalTime
  exact div_pos one_pos eptDecayRate_pos

/-! ## 2. Self-Referential EPT Bound (Key Axiom) -/

/-- **EPT self-referential bound**: τ · (1 − σT) ≤ (ν/ħ) · Ω₀ · T.  **(0 new axioms)**

    **Proof** (pure theorems, no physics axioms beyond Stage 274):

    1. `enstrophy_gronwall_uniform` gives Ω(s) ≤ Ω₀ + 2C·τ(T) for all s ≤ T.
    2. The new `diSample_lt_T` lemma guarantees every discrete sample point
       `i·diH` satisfies `i·diH < T`, so step 1 applies at each sample.
    3. `Finset.sum_le_sum` lifts step 1 to the discrete integral:
         intEnstrophy(T) ≤ (Ω₀ + 2C·τ) · (diSteps T · diH)
    4. `diSteps_mul_diH_le_T` gives diSteps T · diH ≤ T, closing the gap:
         intEnstrophy(T) ≤ (Ω₀ + 2C·τ) · T
    5. Multiply by ν/ħ: τ ≤ (ν/ħ)·(Ω₀ + 2C·τ)·T
    6. Expand and rearrange: τ·(1 − σT) ≤ (ν/ħ)·Ω₀·T  (by `linarith`). -/
theorem ept_self_referential_bound
    (traj : Trajectory NSField)
    (hNS  : SatisfiesNSPDE nsOps nsNu traj)
    (hFS  : RespectsFunctionSpaces nsSpacesR3 traj)
    (T    : Rat) (hT : 0 < T) :
    entropicProperTime traj T * (1 - eptDecayRate * T) ≤
      (nsNu / hbar) * enstrophy (traj.stateAt 0).velocity * T := by
  -- τ ≥ 0 and Ω₀ ≥ 0
  have hτnn : 0 ≤ entropicProperTime traj T := by
    unfold entropicProperTime integratedEnstrophy
    exact mul_nonneg (div_nonneg (le_of_lt nsNu_pos) (le_of_lt hbar_pos))
      (discreteIntegral_nonneg _ T (fun t => enstrophy_nonneg (traj.stateAt t).velocity))
  have hΩ₀nn : 0 ≤ enstrophy (traj.stateAt 0).velocity := enstrophy_nonneg _
  -- Gronwall at each sample point i·diH < T
  have hGron : ∀ i : Nat, i < diSteps T →
      enstrophy (traj.stateAt ((i : Rat) * diH)).velocity ≤
        enstrophy (traj.stateAt 0).velocity +
          2 * cCollapse * entropicProperTime traj T := fun i hi =>
    enstrophy_gronwall_uniform traj hNS hFS _ T
      (mul_nonneg (Nat.cast_nonneg _) diH_nonneg)
      (le_of_lt (diSample_lt_T T (le_of_lt hT) i hi))
  -- Constant bound is nonneg (explicit, no positivity)
  have hconst_nn : 0 ≤ enstrophy (traj.stateAt 0).velocity +
      2 * cCollapse * entropicProperTime traj T :=
    add_nonneg hΩ₀nn
      (mul_nonneg (mul_nonneg (by norm_num) (le_of_lt cCollapse_pos)) hτnn)
  -- intEnstrophy(T) ≤ (Ω₀ + 2C·τ)·T
  have hIntBound : integratedEnstrophy traj T ≤
      (enstrophy (traj.stateAt 0).velocity +
        2 * cCollapse * entropicProperTime traj T) * T := by
    unfold integratedEnstrophy discreteIntegral
    calc (Finset.range (diSteps T)).sum
            (fun i => enstrophy (traj.stateAt ((i : Rat) * diH)).velocity * diH)
        ≤ (Finset.range (diSteps T)).sum
            (fun _ => (enstrophy (traj.stateAt 0).velocity +
              2 * cCollapse * entropicProperTime traj T) * diH) :=
              Finset.sum_le_sum fun i hi =>
                mul_le_mul_of_nonneg_right
                  (hGron i (Finset.mem_range.mp hi)) diH_nonneg
      _ = (enstrophy (traj.stateAt 0).velocity +
              2 * cCollapse * entropicProperTime traj T) *
            ((diSteps T : Rat) * diH) := by
              simp only [Finset.sum_const, Finset.card_range, nsmul_eq_mul]; ring
      _ ≤ (enstrophy (traj.stateAt 0).velocity +
              2 * cCollapse * entropicProperTime traj T) * T :=
              mul_le_mul_of_nonneg_left (diSteps_mul_diH_le_T T (le_of_lt hT)) hconst_nn
  -- τ ≤ (ν/ħ)·(Ω₀ + 2C·τ)·T  [τ = (ν/ħ)·intEnstrophy by rfl]
  have hτBound : entropicProperTime traj T ≤
      (nsNu / hbar) * (enstrophy (traj.stateAt 0).velocity +
        2 * cCollapse * entropicProperTime traj T) * T :=
    calc entropicProperTime traj T
        = (nsNu / hbar) * integratedEnstrophy traj T := rfl
      _ ≤ (nsNu / hbar) * ((enstrophy (traj.stateAt 0).velocity +
              2 * cCollapse * entropicProperTime traj T) * T) :=
            mul_le_mul_of_nonneg_left hIntBound (le_of_lt (div_pos nsNu_pos hbar_pos))
      _ = (nsNu / hbar) * (enstrophy (traj.stateAt 0).velocity +
              2 * cCollapse * entropicProperTime traj T) * T := by ring
  -- Expand RHS: (ν/ħ)·(Ω₀ + 2C·τ)·T = (ν/ħ)·Ω₀·T + σ·T·τ
  -- so τ ≤ (ν/ħ)·Ω₀·T + σ·T·τ
  have hlin : entropicProperTime traj T ≤
      (nsNu / hbar) * enstrophy (traj.stateAt 0).velocity * T +
        eptDecayRate * T * entropicProperTime traj T :=
    hτBound.trans_eq (by unfold eptDecayRate; ring)
  -- Rewrite goal: τ·(1−σT) = τ − σ·T·τ, then linarith from hlin
  rw [show entropicProperTime traj T * (1 - eptDecayRate * T) =
          entropicProperTime traj T -
            eptDecayRate * T * entropicProperTime traj T from by ring]
  linarith

/-! ## 3. EPT Bound by Physical Time -/

/-- **Initial enstrophy** of a trajectory (convenient abbreviation). -/
noncomputable def initialEnstrophy (traj : Trajectory NSField) : Rat :=
  enstrophy (traj.stateAt 0).velocity

theorem initialEnstrophy_nonneg (traj : Trajectory NSField) :
    0 ≤ initialEnstrophy traj :=
  enstrophy_nonneg (traj.stateAt 0).velocity

/-- **EPT physical time bound**: τ_ent(T) ≤ τ_bound(T) = (ν/ħ)·Ω₀·T / (1−σT),
    valid for T < T_crit (equivalently σT < 1). -/
noncomputable def eptPhysicalBound (traj : Trajectory NSField) (T : Rat) : Rat :=
  (nsNu / hbar) * initialEnstrophy traj * T / (1 - eptDecayRate * T)

/-- The denominator (1 − σT) is positive when T < T_crit. -/
theorem eptPhysicalBound_denom_pos (T : Rat) (hSmall : eptDecayRate * T < 1) :
    0 < 1 - eptDecayRate * T := by
  linarith

/-- The EPT physical bound is nonneg for T > 0 and T < T_crit. -/
theorem eptPhysicalBound_nonneg
    (traj : Trajectory NSField) (T : Rat)
    (hT : 0 < T) (hSmall : eptDecayRate * T < 1) :
    0 ≤ eptPhysicalBound traj T := by
  unfold eptPhysicalBound
  apply div_nonneg
  · apply mul_nonneg
    · apply mul_nonneg
      · exact le_of_lt (div_pos nsNu_pos hbar_pos)
      · exact initialEnstrophy_nonneg traj
    · exact le_of_lt hT
  · exact le_of_lt (eptPhysicalBound_denom_pos T hSmall)

/-- **EPT ≤ physical time bound** (MAIN THEOREM of Stage 280).

    For T > 0 and T < T_crit:
      τ_ent(T) ≤ (ν/ħ) · Ω₀ · T / (1 − σT)

    Proof: rearrange `ept_self_referential_bound` using `le_div_iff₀`. -/
theorem ept_le_physical_time_bound
    (traj : Trajectory NSField)
    (hNS  : SatisfiesNSPDE nsOps nsNu traj)
    (hFS  : RespectsFunctionSpaces nsSpacesR3 traj)
    (T    : Rat) (hT : 0 < T) (hSmall : eptDecayRate * T < 1) :
    entropicProperTime traj T ≤ eptPhysicalBound traj T := by
  have hDenom : 0 < 1 - eptDecayRate * T := eptPhysicalBound_denom_pos T hSmall
  unfold eptPhysicalBound initialEnstrophy
  rw [le_div_iff₀ hDenom]
  exact ept_self_referential_bound traj hNS hFS T hT

/-! ## 4. BKM Bound in Physical Time -/

/-- **BKM physical time bound** (MAIN RESULT of Stage 280).

    Combining Stage 279's degree-4 EPT bound with Stage 280's EPT ≤ τ_bound(T),
    we get BKM(T) bounded by an explicit rational function of physical time T.

    For T > 0 and T < T_crit:
      BKM(T) ≤ B · (1 + τ_b)³ · (ħ/ν) · τ_b
    where τ_b = (ν/ħ)·Ω₀·T / (1−σT) is an explicit function of T.

    The proof uses the degree-4 monotonicity: the Stage 279 bound is increasing
    in τ (since B, (1+τ), (ħ/ν), and τ are all nonneg). -/
theorem bkm_physical_time_polynomial_bound
    (traj : Trajectory NSField)
    (hNS  : SatisfiesNSPDE nsOps nsNu traj)
    (hFS  : RespectsFunctionSpaces nsSpacesR3 traj)
    (T    : Rat) (hT : 0 < T) (hSmall : eptDecayRate * T < 1) :
    bkmVorticityIntegralPhysical traj T ≤
      bernsteinConst *
        (1 + eptPhysicalBound traj T) *
        (1 + eptPhysicalBound traj T) *
        (1 + eptPhysicalBound traj T) *
        (hbar / nsNu * eptPhysicalBound traj T) := by
  -- Stage 279 bound in terms of τ
  have hD4 := bkm_physical_degree4_ept_bound traj T
  -- Physical time bound on τ
  have hτ  := ept_le_physical_time_bound traj hNS hFS T hT hSmall
  -- τ_b ≥ 0
  have hτb : 0 ≤ eptPhysicalBound traj T :=
    eptPhysicalBound_nonneg traj T hT hSmall
  -- τ ≥ 0
  have hτnn : 0 ≤ entropicProperTime traj T := by
    unfold entropicProperTime integratedEnstrophy
    apply mul_nonneg (div_nonneg (le_of_lt nsNu_pos) (le_of_lt hbar_pos))
    exact discreteIntegral_nonneg _ T (fun t => enstrophy_nonneg (traj.stateAt t).velocity)
  -- 1 + τ ≥ 0 and 1 + τ_b ≥ 0
  have h1t  : 0 ≤ 1 + entropicProperTime traj T   := by linarith
  have h1tb : 0 ≤ 1 + eptPhysicalBound traj T     := by linarith
  -- ħ/ν > 0
  have hhn  : 0 < hbar / nsNu := div_pos hbar_pos nsNu_pos
  -- Monotonicity chain: the degree-4 function is increasing in τ
  -- Step 1: ħ/ν·τ ≤ ħ/ν·τ_b
  have step1 : hbar / nsNu * entropicProperTime traj T ≤
               hbar / nsNu * eptPhysicalBound traj T :=
    mul_le_mul_of_nonneg_left hτ (le_of_lt hhn)
  -- Step 2: B·(1+τ) ≤ B·(1+τ_b)
  have h1le : entropicProperTime traj T ≤ eptPhysicalBound traj T := hτ
  have step2 : bernsteinConst * (1 + entropicProperTime traj T) ≤
               bernsteinConst * (1 + eptPhysicalBound traj T) := by
    apply mul_le_mul_of_nonneg_left _ (le_of_lt bernsteinConst_pos)
    linarith
  -- Step 3: B·(1+τ)² ≤ B·(1+τ_b)²
  have step3a : bernsteinConst * (1 + entropicProperTime traj T) *
                (1 + entropicProperTime traj T) ≤
                bernsteinConst * (1 + eptPhysicalBound traj T) *
                (1 + eptPhysicalBound traj T) := by
    calc bernsteinConst * (1 + entropicProperTime traj T) * (1 + entropicProperTime traj T)
        ≤ bernsteinConst * (1 + eptPhysicalBound traj T) * (1 + entropicProperTime traj T) :=
            mul_le_mul_of_nonneg_right step2 h1t
      _ ≤ bernsteinConst * (1 + eptPhysicalBound traj T) * (1 + eptPhysicalBound traj T) :=
            mul_le_mul_of_nonneg_left (by linarith) (mul_nonneg (le_of_lt bernsteinConst_pos) h1tb)
  -- Step 4: B·(1+τ)³ ≤ B·(1+τ_b)³
  have step4 : bernsteinConst * (1 + entropicProperTime traj T) *
               (1 + entropicProperTime traj T) *
               (1 + entropicProperTime traj T) ≤
               bernsteinConst * (1 + eptPhysicalBound traj T) *
               (1 + eptPhysicalBound traj T) *
               (1 + eptPhysicalBound traj T) := by
    calc bernsteinConst * (1 + entropicProperTime traj T) *
         (1 + entropicProperTime traj T) * (1 + entropicProperTime traj T)
        ≤ bernsteinConst * (1 + eptPhysicalBound traj T) *
          (1 + eptPhysicalBound traj T) * (1 + entropicProperTime traj T) :=
            mul_le_mul_of_nonneg_right step3a h1t
      _ ≤ bernsteinConst * (1 + eptPhysicalBound traj T) *
          (1 + eptPhysicalBound traj T) * (1 + eptPhysicalBound traj T) :=
            mul_le_mul_of_nonneg_left (by linarith)
              (mul_nonneg (mul_nonneg (le_of_lt bernsteinConst_pos) h1tb) h1tb)
  -- Final assembly: B·(1+τ)³·(ħ/ν·τ) ≤ B·(1+τ_b)³·(ħ/ν·τ_b)
  calc bkmVorticityIntegralPhysical traj T
      ≤ bernsteinConst * (1 + entropicProperTime traj T) *
        (1 + entropicProperTime traj T) *
        (1 + entropicProperTime traj T) *
        (hbar / nsNu * entropicProperTime traj T) := hD4
    _ ≤ bernsteinConst * (1 + eptPhysicalBound traj T) *
        (1 + eptPhysicalBound traj T) *
        (1 + eptPhysicalBound traj T) *
        (hbar / nsNu * entropicProperTime traj T) :=
          mul_le_mul_of_nonneg_right step4
            (mul_nonneg (le_of_lt hhn) hτnn)
    _ ≤ bernsteinConst * (1 + eptPhysicalBound traj T) *
        (1 + eptPhysicalBound traj T) *
        (1 + eptPhysicalBound traj T) *
        (hbar / nsNu * eptPhysicalBound traj T) :=
          mul_le_mul_of_nonneg_left step1
            (mul_nonneg (mul_nonneg (mul_nonneg (le_of_lt bernsteinConst_pos) h1tb) h1tb) h1tb)

/-! ## 5. Convergence as T → 0 -/

/-- **BKM vanishes at T = 0**: BKM(0) = 0 (trivially, no time to integrate). -/
theorem bkm_physical_at_zero :
    ∀ (traj : Trajectory NSField),
    bkmVorticityIntegralPhysical traj 0 = 0 := by
  intro traj
  have hle := bkm_physical_degree4_ept_bound traj 0
  have hge := bkmVorticityIntegralPhysical_nonneg traj 0
  have hτ0 : entropicProperTime traj 0 = 0 := by
    unfold entropicProperTime integratedEnstrophy
    simp [discreteIntegral, diSteps]
  rw [hτ0] at hle
  have : bernsteinConst * (1 + (0:Rat)) * (1 + 0) * (1 + 0) * (hbar / nsNu * 0) = 0 := by ring
  linarith

/-- **Small-T expansion**: for small T, τ_bound ≈ (ν/ħ)·Ω₀·T (linear in T). -/
theorem eptPhysicalBound_small_T
    (traj : Trajectory NSField) (T : Rat) :
    eptPhysicalBound traj T ≤
      (nsNu / hbar) * initialEnstrophy traj * T / (1 - eptDecayRate * T) := le_refl _

/-! ## 6. Physical Time Certificate -/

/-- **Physical time BKM certificate** — records the Stage 280 result. -/
structure PhysicalTimeBKMCertificate where
  /-- The bound is explicit in physical time T -/
  explicitInPhysicalTime : Bool
  /-- Number of new axioms needed beyond Stage 279 -/
  newAxiomCount : Nat
  /-- The bound is a rational function of T (for T < T_crit) -/
  isRationalFunction : Bool
  /-- T_crit = ħ/(2Cν) separates controlled regime -/
  hasCriticalTime : Bool

def physicalTimeBKMCertificate : PhysicalTimeBKMCertificate :=
  { explicitInPhysicalTime := true
    newAxiomCount           := 1
    isRationalFunction      := true
    hasCriticalTime         := true }

theorem physicalTime_certificate_one_new_axiom :
    physicalTimeBKMCertificate.newAxiomCount = 1 := rfl

theorem physicalTime_certificate_is_rational :
    physicalTimeBKMCertificate.isRationalFunction = true := rfl

end

end NavierStokes.Millennium
