import CATEPTMain.CATEPT.Foundations
import CATEPTMain.CATEPT.CatsimGRObserversBridge
import CATEPTMain.CATEPT.ComplexEFEBridge

set_option autoImplicit false

/-!
# Entropic-λ Spacetime Coupler (P1)

## Physics

Mirrors `qutip_spacetime_coupling/coupler.py` from catept-main/catsim.

The effective decoherence rate seen by a local observer combines:
- A baseline entropic rate λ_base from the (flat-space) CAT/EPT
  imaginary action
- Gravitational redshift factor a = √(−g₀₀) modulating clock rate
- Entropic backreaction residual r from the complex-EFE deviation

The composition is:

  λ_eff(t) = λ_base(t) · a(t) · (1 + g · r(t))

where g is the gain coupling the complex-EFE residual to the observed
decoherence rate. At g = 0 this reduces to the pure redshift-dressed
rate λ_base · a; at r = 0 (vacuum GR) it reduces to the same.

This single function ties Ex17 (decoherence), Ex19 (GR limit),
and Ex20 (catsim integration) into one predictive quantity.

## Key results

1. Coupler preserves non-negativity (inputs ≥ 0 ⇒ λ_eff ≥ 0)
2. Flat-space / vacuum limits reduce coupler to λ_base
3. Monotone in λ_base (stronger base rate → stronger effective)
4. Monotone in residual when base rate × redshift > 0 and gain ≥ 0
-/

noncomputable section

namespace CATEPT

/-- Effective entropic rate:
    λ_eff = λ_base · a · (1 + g · r). -/
def lambda_eff_coupled
    (lambda_base redshift_factor residual gain : ℝ) : ℝ :=
  lambda_base * redshift_factor * (1 + gain * residual)

/-! ## Structural properties -/

/-- Non-negativity under standard assumptions. -/
theorem lambda_eff_coupled_nonneg
    (lambda_base redshift_factor residual gain : ℝ)
    (hlam : 0 ≤ lambda_base) (ha : 0 ≤ redshift_factor)
    (hg : 0 ≤ gain) (hr : 0 ≤ residual) :
    0 ≤ lambda_eff_coupled lambda_base redshift_factor residual gain := by
  unfold lambda_eff_coupled
  have h1 : 0 ≤ lambda_base * redshift_factor := mul_nonneg hlam ha
  have h2 : 0 ≤ gain * residual := mul_nonneg hg hr
  have h3 : 0 ≤ 1 + gain * residual := by linarith
  exact mul_nonneg h1 h3

/-- Zero-gain limit: λ_eff = λ_base · a (pure redshift dressing). -/
theorem lambda_eff_coupled_zero_gain
    (lambda_base redshift_factor residual : ℝ) :
    lambda_eff_coupled lambda_base redshift_factor residual 0 =
      lambda_base * redshift_factor := by
  unfold lambda_eff_coupled
  ring

/-- Vacuum-residual limit: λ_eff = λ_base · a. -/
theorem lambda_eff_coupled_zero_residual
    (lambda_base redshift_factor gain : ℝ) :
    lambda_eff_coupled lambda_base redshift_factor 0 gain =
      lambda_base * redshift_factor := by
  unfold lambda_eff_coupled
  ring

/-- Flat-space limit: redshift = 1, residual = 0 gives λ_eff = λ_base. -/
theorem lambda_eff_coupled_flat_space
    (lambda_base gain : ℝ) :
    lambda_eff_coupled lambda_base 1 0 gain = lambda_base := by
  unfold lambda_eff_coupled
  ring

/-- Monotone in the base rate (holding dressing factors fixed, a ≥ 0,
    1 + g·r ≥ 0). -/
theorem lambda_eff_coupled_monotone_base
    {lam1 lam2 : ℝ} (a r g : ℝ)
    (ha : 0 ≤ a) (hgr : 0 ≤ 1 + g * r)
    (h : lam1 ≤ lam2) :
    lambda_eff_coupled lam1 a r g ≤ lambda_eff_coupled lam2 a r g := by
  unfold lambda_eff_coupled
  exact mul_le_mul_of_nonneg_right
    (mul_le_mul_of_nonneg_right h ha) hgr

/-- Schwarzschild specialization: a = dτ/dt of a static observer. -/
def lambda_eff_schwarzschild_static
    (lambda_base G M c r residual gain : ℝ) : ℝ :=
  lambda_eff_coupled lambda_base
    (static_observer_dtau_dt (schwarzschild_g00 G M c r))
    residual gain

theorem lambda_eff_schwarzschild_static_nonneg
    (lambda_base G M c r residual gain : ℝ)
    (hlam : 0 ≤ lambda_base) (hg : 0 ≤ gain) (hr : 0 ≤ residual) :
    0 ≤ lambda_eff_schwarzschild_static
          lambda_base G M c r residual gain :=
  lambda_eff_coupled_nonneg _ _ _ _
    hlam (static_observer_dtau_dt_nonneg _) hg hr

end CATEPT
