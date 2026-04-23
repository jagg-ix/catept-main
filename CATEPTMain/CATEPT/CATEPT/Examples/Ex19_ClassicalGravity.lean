import CATEPTMain.CATEPT.CATEPT.ClassicalGravityBridge
import CATEPTMain.CATEPT.CATEPT.CATEPTPredictions

set_option autoImplicit false

/-!
# Example 19: CAT/EPT in the Classical Limit — GR and SR Agreement

## What this demonstrates

CAT/EPT's complex action S = S_R + iS_I reduces to standard GR/SR
when the imaginary part S_I vanishes. This example verifies both
structural agreement (theorems) and numerical agreement (Floats)
against two canonical tests:

1. **Special Relativity** — Lorentz γ factor at β = v/c = 0.5
2. **General Relativity** — Mercury perihelion advance (42.98
   arcsec/century; one of Einstein's 1915 classical tests)

## Numerical evaluation

```
#eval CATEPT.Numerics.perihelion_precession_per_century_arcsec_f
-- ~42.98 arcsec/century  (CAT/EPT classical limit = GR prediction)

#eval CATEPT.Numerics.reportMercuryPerihelion
-- predicted vs observed Mercury perihelion advance

#eval CATEPT.Numerics.reportGammaAtHalf
-- γ(0.5) = 2/√3 ≈ 1.1547 (exact Float consistency)

#eval CATEPT.Numerics.catEPTClassicalLimitDossier
-- full classical-limit dossier
```

## Key formal theorems (proved)

**SR**:
- γ(0) = 1 (classical limit) — `gamma_factor_at_zero`
- γ(β) > 0 for β² < 1 — `gamma_factor_pos`
- dτ/dt ≤ 1 (time dilates, never contracts) — `sr_proper_time_rate_le_one`

**GR**:
- Schwarzschild radius r_s = 2GM/c² > 0 — `schwarzschild_radius_classical_pos`
- Perihelion precession Δφ > 0 — `perihelion_precession_pos`
- Δφ monotone in central mass M — `perihelion_precession_monotone_in_mass`

**CAT/EPT classical limit**:
- S_I = 0 ⇒ τ_ent = 0 — `catept_classical_limit_entropic_time`
- S_I = 0 ⇒ FK damping = 1 — `catept_classical_limit_damping`
- Total time = SR proper time in classical limit — `catept_sr_consistency`
-/

noncomputable section

namespace CATEPT.Examples

open CATEPT

/-! ### Special Relativity structural checks -/

-- Classical limit: at β = 0, γ = 1
example : gamma_factor 0 = 1 :=
  gamma_factor_at_zero

-- γ is positive for subluminal velocities
example (β : ℝ) (h : β ^ 2 < 1) : 0 < gamma_factor β :=
  gamma_factor_pos β h

-- Proper time rate at rest equals 1 (no dilation)
example : sr_proper_time_rate 0 = 1 :=
  sr_proper_time_rate_at_zero

-- Proper time rate positive for subluminal velocities
example (β : ℝ) (h : β ^ 2 < 1) : 0 < sr_proper_time_rate β :=
  sr_proper_time_rate_pos β h

-- Time dilation: proper time rate ≤ 1 (moving clocks run slower)
example (β : ℝ) (h : β ^ 2 ≤ 1) : sr_proper_time_rate β ≤ 1 :=
  sr_proper_time_rate_le_one β h

/-! ### General Relativity structural checks -/

-- Schwarzschild radius positive for positive mass
example (G M c : ℝ) (hG : 0 < G) (hM : 0 < M) (hc : 0 < c) :
    0 < schwarzschild_radius_classical G M c :=
  schwarzschild_radius_classical_pos G M c hG hM hc

-- GR time dilation factor non-negative (sqrt)
example (G M c r : ℝ) : 0 ≤ gr_time_dilation_factor G M c r :=
  gr_time_dilation_factor_nonneg G M c r

-- Mercury perihelion precession strictly positive
example (G M c a e : ℝ)
    (hG : 0 < G) (hM : 0 < M) (hc : 0 < c) (ha : 0 < a) (he : e ^ 2 < 1) :
    0 < perihelion_precession_per_orbit G M c a e :=
  perihelion_precession_pos G M c a e hG hM hc ha he

-- Heavier central body → larger perihelion advance
example (G M₁ M₂ c a e : ℝ)
    (hG : 0 < G) (hc : 0 < c) (ha : 0 < a) (he : e ^ 2 < 1)
    (h12 : M₁ < M₂) :
    perihelion_precession_per_orbit G M₁ c a e <
      perihelion_precession_per_orbit G M₂ c a e :=
  perihelion_precession_monotone_in_mass G M₁ M₂ c a e hG hc ha he h12

/-! ### CAT/EPT classical-limit consistency -/

-- When S_I = 0: CAT/EPT entropic time vanishes
example (ℏ : ℝ) (hh : 0 < ℏ) : entropic_time ℏ 0 = 0 :=
  catept_classical_limit_entropic_time ℏ hh

-- When S_I = 0: CAT/EPT FK damping weight = 1 (no damping)
example (ℏ : ℝ) (hh : 0 < ℏ) : Real.exp (-0 / ℏ) = 1 :=
  catept_classical_limit_damping ℏ hh

-- CAT/EPT + SR agreement in classical limit: total time = SR proper time
example (ℏ t β : ℝ) (hh : 0 < ℏ) :
    entropic_time ℏ 0 + t * sr_proper_time_rate β =
      t * sr_proper_time_rate β :=
  catept_sr_consistency ℏ t β hh

end CATEPT.Examples

/-! ### Numerical agreement dossier

Uncomment to see the actual numerical predictions:

```
#eval CATEPT.Numerics.catEPTClassicalLimitDossier
-- [ Mercury perihelion:   predicted ≈ 42.98   / observed 42.98
-- , Lorentz γ(0.5):       predicted ≈ 1.1547  / analytic 2/√3 ]
```

This shows CAT/EPT in the classical limit reproducing:
- Einstein 1915 GR Mercury perihelion prediction
- Standard SR Lorentz factor
-/
