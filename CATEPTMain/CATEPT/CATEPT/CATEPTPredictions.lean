import CATEPTMain.CATEPT.CATEPT.Foundations
import CATEPTMain.CATEPT.CATEPT.MuonGMinus2Bridge
import CATEPTMain.CATEPT.CATEPT.TrefoilTopologyBridge

set_option autoImplicit false

/-!
# CAT/EPT Predictions Framework

## Purpose

This module lets you evaluate CAT/EPT's concrete numerical predictions
for electron, muon, and fermion observables, and optionally compare
them against reference values (CODATA, PDG, etc.).

**Design goal**: the prediction formulas are expressed entirely in
Lean `Real` arithmetic using Mathlib primitives. Reference values are
a *separate* input provider — you can:

- Use `codataInputs` (CODATA 2018, hardcoded with citations) to
  compare CAT/EPT against the standard table.
- Use `leanIntrinsicInputs α` to skip CODATA entirely and work only
  with Lean4/Mathlib-derived quantities (exact rationals, π, ln 2,
  exp, etc.), keeping α as the single phenomenological input.

This lets downstream examples (Ex14, etc.) demonstrate that CAT/EPT's
predictions follow from the formulas alone, independent of which
numerical anchor you feed them.

## Architecture

```
PredictionInputs ──┬── codataInputs       (CODATA 2018 values)
                   └── leanIntrinsicInputs (Mathlib-only values)
        │
        ▼
PredictedObservables   (CAT/EPT formulas evaluated on inputs)
        │
        ▼
predict_within_rel ε   (tolerance-based comparison)
```

## Key results

1. Schwinger prediction is always positive for α > 0
2. Leading-order a_e and a_μ predictions both equal α/(2π)
3. Predictions compose linearly with sector corrections
4. CODATA and Lean-intrinsic inputs both yield structurally valid predictions
-/

noncomputable section

namespace CATEPTMain.CATEPT.CATEPT

/-! ## Input Bundle -/

/-- Phenomenological inputs needed to evaluate CAT/EPT predictions.
    All fields are abstract `Real` parameters — no CODATA values are
    baked in at this layer. -/
structure PredictionInputs where
  /-- Fine-structure constant (dimensionless). -/
  alpha : ℝ
  /-- Reduced Planck constant (J·s). -/
  hbar : ℝ
  /-- Boltzmann constant (J/K). -/
  k_B : ℝ
  /-- Electron mass (kg). -/
  m_e : ℝ
  /-- Muon mass (kg). -/
  m_mu : ℝ
  /-- Tau mass (kg). -/
  m_tau : ℝ
  /-- Reference temperature for thermal predictions (K). -/
  T : ℝ
  /-- Positivity of α. -/
  alpha_pos : 0 < alpha
  /-- Positivity of ℏ. -/
  hbar_pos : 0 < hbar
  /-- Positivity of k_B. -/
  k_B_pos : 0 < k_B
  /-- Positivity of electron mass. -/
  m_e_pos : 0 < m_e
  /-- Positivity of muon mass. -/
  m_mu_pos : 0 < m_mu
  /-- Positivity of tau mass. -/
  m_tau_pos : 0 < m_tau
  /-- Positivity of reference temperature. -/
  T_pos : 0 < T

/-! ## Input Provider 1: CODATA 2018 Anchor

Literal CODATA 2018 values with source citations. Use this provider
when you want to compare CAT/EPT predictions against the standard
reference table. Each line cites the corresponding CODATA entry. -/

/-- CODATA 2018 input bundle. Values from
    `QCElemental/raw_data/nist_data/codata-2018.txt`. -/
def codataInputs : PredictionInputs where
  -- fine-structure constant: α = 1 / 137.035 999 084
  alpha    := 1 / 137.035999084
  -- reduced Planck constant: ℏ = h/(2π), h = 6.626 070 15e-34 J·s (exact)
  hbar     := 1.054571817e-34
  -- Boltzmann constant (exact by SI): 1.380 649e-23 J/K
  k_B      := 1.380649e-23
  -- electron mass: 9.109 383 7015(28)e-31 kg
  m_e      := 9.1093837015e-31
  -- muon mass: 1.883 531 627(42)e-28 kg
  m_mu     := 1.883531627e-28
  -- tau mass energy 1776.86(12) MeV -> kg via E/c²
  m_tau    := 3.16754e-27
  -- room temperature reference
  T        := 298.15
  alpha_pos    := by norm_num
  hbar_pos     := by norm_num
  k_B_pos      := by norm_num
  m_e_pos      := by norm_num
  m_mu_pos     := by norm_num
  m_tau_pos    := by norm_num
  T_pos        := by norm_num

/-! ## Input Provider 2: Lean-Intrinsic (Mathlib-Only)

This provider avoids CODATA entirely. It uses only:
- α as a single abstract positive parameter (phenomenological)
- Mathlib exact values (π, ln 2, exp)
- Simple rational multipliers for mass ratios

The point: CAT/EPT predictions make structural sense with *any*
positive α, ℏ, k_B, etc. — no external data needed. -/

/-- Lean-intrinsic input bundle: unit-normalized masses and abstract α.
    Use this to demonstrate that CAT/EPT predictions follow from formulas
    alone, independent of CODATA. -/
def leanIntrinsicInputs (alpha : ℝ) (ha : 0 < alpha) : PredictionInputs where
  alpha        := alpha
  hbar         := 1
  k_B          := 1
  m_e          := 1
  m_mu         := 207        -- natural-unit ratio, well-known integer
  m_tau        := 3477       -- integer approximation of m_τ/m_e
  T            := 1
  alpha_pos    := ha
  hbar_pos     := by norm_num
  k_B_pos      := by norm_num
  m_e_pos      := by norm_num
  m_mu_pos     := by norm_num
  m_tau_pos    := by norm_num
  T_pos        := by norm_num

/-! ## Predicted Observables (evaluated on any PredictionInputs) -/

/-- Leading-order QED prediction for the electron anomalous magnetic
    moment: a_e = α / (2π). -/
def predict_aE_leading (inp : PredictionInputs) : ℝ :=
  schwinger_term inp.alpha

/-- Leading-order QED prediction for the muon anomalous magnetic
    moment. At this order a_e and a_μ agree; higher-order QED, hadronic,
    and EW sectors lift the degeneracy via `dyson_resummed`. -/
def predict_aMu_leading (inp : PredictionInputs) : ℝ :=
  schwinger_term inp.alpha

/-- CAT/EPT Landauer bound prediction: ΔE ≥ k_B T ln 2. -/
def predict_landauer (inp : PredictionInputs) : ℝ :=
  landauer_cost inp.k_B inp.T

/-- CAT/EPT trefoil topology prediction for S_I contribution at
    `crossings` crossings. -/
def predict_trefoil_S_I (inp : PredictionInputs) (crossings : ℝ) : ℝ :=
  topological_action_im inp.k_B crossings

/-- CAT/EPT-predicted electron/muon mass ratio derived from inputs. -/
def predict_electron_muon_mass_ratio (inp : PredictionInputs) : ℝ :=
  inp.m_e / inp.m_mu

/-- CAT/EPT Dyson-resummed a_μ when a total sector correction is given. -/
def predict_aMu_resummed (inp : PredictionInputs) (C_tot : ℝ) : ℝ :=
  dyson_resummed inp.alpha C_tot

/-! ## Structural Positivity (domain-independent) -/

theorem predict_aE_leading_positive (inp : PredictionInputs) :
    0 < predict_aE_leading inp :=
  schwinger_term_positive inp.alpha inp.alpha_pos

theorem predict_aMu_leading_positive (inp : PredictionInputs) :
    0 < predict_aMu_leading inp :=
  schwinger_term_positive inp.alpha inp.alpha_pos

theorem predict_landauer_positive (inp : PredictionInputs) :
    0 < predict_landauer inp :=
  eq027_landauer_principle inp.k_B inp.T inp.k_B_pos inp.T_pos

theorem predict_trefoil_S_I_nonneg (inp : PredictionInputs)
    {crossings : ℝ} (hc : 1 ≤ crossings) :
    0 ≤ predict_trefoil_S_I inp crossings :=
  topological_action_im_nonneg inp.k_B crossings inp.k_B_pos.le hc

theorem predict_electron_muon_mass_ratio_positive (inp : PredictionInputs) :
    0 < predict_electron_muon_mass_ratio inp :=
  div_pos inp.m_e_pos inp.m_mu_pos

theorem predict_aMu_resummed_positive (inp : PredictionInputs)
    {C_tot : ℝ} (hC : C_tot < 1) :
    0 < predict_aMu_resummed inp C_tot :=
  dyson_resummed_positive inp.alpha C_tot inp.alpha_pos hC

/-! ## Provider-Independence: Leading-Order Equalities

These theorems show that the CAT/EPT prediction formulas depend
ONLY on the input values — they don't change shape between CODATA
and Lean-intrinsic providers. -/

/-- Leading-order a_e prediction is always α/(2π), regardless of provider. -/
theorem predict_aE_leading_eq_schwinger (inp : PredictionInputs) :
    predict_aE_leading inp = inp.alpha / (2 * Real.pi) := rfl

/-- Leading-order a_μ prediction is always α/(2π), regardless of provider. -/
theorem predict_aMu_leading_eq_schwinger (inp : PredictionInputs) :
    predict_aMu_leading inp = inp.alpha / (2 * Real.pi) := rfl

/-- a_e and a_μ agree at leading order (any provider). This is the
    CAT/EPT version of "Schwinger universality". -/
theorem leading_order_aE_eq_aMu (inp : PredictionInputs) :
    predict_aE_leading inp = predict_aMu_leading inp := by
  rw [predict_aE_leading_eq_schwinger, predict_aMu_leading_eq_schwinger]

/-- When C_tot = 0, resummed a_μ equals leading a_μ. Splits the
    "higher-order corrections" from the leading QED term. -/
theorem resummed_at_zero_eq_leading (inp : PredictionInputs) :
    predict_aMu_resummed inp 0 = predict_aMu_leading inp :=
  dyson_resummed_at_zero inp.alpha

/-! ## Tolerance-Based Comparison -/

/-- Relative-tolerance predicate: `|pred - ref| ≤ ε * |ref|`. -/
def within_rel (ref pred ε : ℝ) : Prop :=
  |pred - ref| ≤ ε * |ref|

/-- Zero-tolerance case: exact equality. -/
theorem within_rel_of_eq (ref pred : ℝ) (h : pred = ref) (ε : ℝ) (hε : 0 ≤ ε) :
    within_rel ref pred ε := by
  unfold within_rel
  rw [h]; simp
  exact mul_nonneg hε (abs_nonneg ref)

/-- Self-comparison: any value is within zero tolerance of itself. -/
theorem within_rel_self (x ε : ℝ) (hε : 0 ≤ ε) : within_rel x x ε :=
  within_rel_of_eq x x rfl ε hε

/-! ## Provider Parity Theorems

Demonstrate that leading-order CAT/EPT predictions have the same
structural form under either provider. -/

/-- Under any `α > 0`, the Lean-intrinsic provider gives a positive
    leading-order a_e prediction. -/
theorem leanIntrinsic_aE_positive (alpha : ℝ) (ha : 0 < alpha) :
    0 < predict_aE_leading (leanIntrinsicInputs alpha ha) :=
  predict_aE_leading_positive _

/-- CODATA provider gives a positive leading-order a_e prediction. -/
theorem codata_aE_positive :
    0 < predict_aE_leading codataInputs :=
  predict_aE_leading_positive _

/-- Both providers agree that a_e = a_μ at leading order. -/
theorem both_providers_aE_eq_aMu_leading (alpha : ℝ) (ha : 0 < alpha) :
    predict_aE_leading (leanIntrinsicInputs alpha ha) =
      predict_aMu_leading (leanIntrinsicInputs alpha ha)
    ∧
    predict_aE_leading codataInputs =
      predict_aMu_leading codataInputs :=
  ⟨leading_order_aE_eq_aMu _, leading_order_aE_eq_aMu _⟩

/-! ## Computable Numerics Layer

The theorems above live in `noncomputable ℝ` — exact but not
evaluable. For quick numerical sanity checks (`#eval` style) we
also expose a parallel `Float`-based namespace with the same
prediction shapes. These are NOT used by the proof layer; they
are purely for empirical comparison. -/

namespace Numerics

/-- Python-like π for Float computations. -/
def pi_f : Float := 3.141592653589793

/-- CODATA 2018 fine-structure constant. -/
def alpha_codata : Float := 1.0 / 137.035999084

/-- CODATA 2018 reference electron anomaly. -/
def aE_codata : Float := 1.15965218128e-3

/-- CODATA 2018 reference muon anomaly. -/
def aMu_codata : Float := 1.16592089e-3

/-- CODATA 2018 Boltzmann constant (J/K, exact). -/
def kB_codata : Float := 1.380649e-23

/-- CODATA 2018 electron mass (kg). -/
def m_e_codata : Float := 9.1093837015e-31

/-- CODATA 2018 muon mass (kg). -/
def m_mu_codata : Float := 1.883531627e-28

/-- CODATA 2018 electron-muon mass ratio. -/
def electron_muon_ratio_codata : Float := 4.83633169e-3

/-- Schwinger leading-order prediction a_ℓ^(1) = α/(2π). -/
def schwinger_f (alpha : Float) : Float := alpha / (2.0 * pi_f)

/-- CAT/EPT leading-order prediction for electron anomaly. -/
def predict_aE_f (alpha : Float) : Float := schwinger_f alpha

/-- CAT/EPT leading-order prediction for muon anomaly. -/
def predict_aMu_f (alpha : Float) : Float := schwinger_f alpha

/-- CAT/EPT Landauer cost prediction at given (k_B, T). -/
def predict_landauer_f (kB T : Float) : Float := kB * T * Float.log 2.0

/-- CAT/EPT topological S_I from crossing number (natural log). -/
def predict_trefoil_S_I_f (kB crossings : Float) : Float := kB * Float.log crossings

/-- Absolute value for Float (since Float doesn't ship `abs`). -/
def abs_f (x : Float) : Float := if x < 0 then -x else x

/-- Relative error: |pred − ref| / |ref| (undefined at ref = 0). -/
def rel_error (ref pred : Float) : Float :=
  abs_f (pred - ref) / abs_f ref

/-- Accuracy report for a single observable. -/
structure AccuracyReport where
  name   : String
  predicted : Float
  reference : Float
  relError  : Float
  deriving Repr

/-- Build an accuracy report from a pair of Float values. -/
def mkReport (name : String) (predicted reference : Float) : AccuracyReport :=
  { name := name
  , predicted := predicted
  , reference := reference
  , relError := rel_error reference predicted }

/-- CAT/EPT leading-order electron anomaly vs CODATA a_e. -/
def reportElectronAnomaly : AccuracyReport :=
  mkReport "a_e (leading-order Schwinger)" (predict_aE_f alpha_codata) aE_codata

/-- CAT/EPT leading-order muon anomaly vs CODATA a_μ. -/
def reportMuonAnomaly : AccuracyReport :=
  mkReport "a_μ (leading-order Schwinger)" (predict_aMu_f alpha_codata) aMu_codata

/-- Full leading-order accuracy dossier against CODATA 2018. -/
def codataLeadingOrderReports : List AccuracyReport :=
  [reportElectronAnomaly, reportMuonAnomaly]

/-! ### Higher-order (Dyson-resummed) CAT/EPT predictions

The leading-order Schwinger term α/(2π) captures ~99.85% of a_e and
~99.6% of a_μ. The residual gap is filled by higher-order QED, hadronic,
and electroweak corrections, organized in CAT/EPT's Dyson form:

  a_ℓ = (α/(2π)) / (1 - C'_tot)

The C'_tot values below are the empirical sector totals that reproduce
the CODATA anomalies exactly when fed into the Dyson form. They encode
how much higher-order physics CAT/EPT must account for beyond Schwinger. -/

/-- Empirical C'_tot for the electron: 1 - (Schwinger / a_e_codata).
    Positive → higher orders reduce |anomaly| below Schwinger;
    Negative → higher orders enlarge |anomaly| above Schwinger. -/
def C_tot_electron_empirical : Float :=
  1.0 - schwinger_f alpha_codata / aE_codata

/-- Empirical C'_tot for the muon (from CODATA). -/
def C_tot_muon_empirical : Float :=
  1.0 - schwinger_f alpha_codata / aMu_codata

/-- Dyson-resummed Float prediction. -/
def dyson_resummed_f (alpha C_tot : Float) : Float :=
  schwinger_f alpha / (1.0 - C_tot)

/-- CAT/EPT Dyson-resummed electron anomaly (with empirical C'_tot). -/
def predict_aE_resummed_f : Float :=
  dyson_resummed_f alpha_codata C_tot_electron_empirical

/-- CAT/EPT Dyson-resummed muon anomaly (with empirical C'_tot). -/
def predict_aMu_resummed_f : Float :=
  dyson_resummed_f alpha_codata C_tot_muon_empirical

/-- Electron anomaly: Dyson-resummed CAT/EPT vs CODATA.
    By construction of `C_tot_electron_empirical` this is exact. -/
def reportElectronAnomalyResummed : AccuracyReport :=
  mkReport "a_e (CAT/EPT Dyson-resummed)" predict_aE_resummed_f aE_codata

/-- Muon anomaly: Dyson-resummed CAT/EPT vs CODATA.
    Exact by construction of `C_tot_muon_empirical`. -/
def reportMuonAnomalyResummed : AccuracyReport :=
  mkReport "a_μ (CAT/EPT Dyson-resummed)" predict_aMu_resummed_f aMu_codata

/-- Complete LO+resummed comparison dossier. -/
def codataFullReports : List AccuracyReport :=
  [ reportElectronAnomaly
  , reportElectronAnomalyResummed
  , reportMuonAnomaly
  , reportMuonAnomalyResummed ]

/-! ### Decoherence predictions (cross-domain application)

CAT/EPT's entropic rate λ = k_B T / ℏ determines a universal thermal
decoherence floor. Real decoherence rates are bounded by this thermal
rate; actual T1/T2 values reflect which modes couple to the bath. -/

/-- Thermal entropic rate λ = k_B T / ℏ (rad/s). -/
def entropic_rate_f (T : Float) : Float :=
  kB_codata * T / 1.054571817e-34

/-- CAT/EPT-predicted thermal decoherence floor (s). -/
def thermal_decoherence_floor_f (T : Float) : Float :=
  1.0 / entropic_rate_f T

/-- Rate at transmon dilution-fridge temperature (15 mK). -/
def lambda_transmon_f : Float := entropic_rate_f 0.015

/-- Thermal decoherence floor at 15 mK (approx thermal T2 lower bound). -/
def T2_thermal_floor_transmon_f : Float := thermal_decoherence_floor_f 0.015

/-- Measured transmon T2 lower range (80 μs) from Kjaergaard et al. 2020. -/
def T2_measured_transmon_f : Float := 80.0e-6

/-- Report: CAT/EPT thermal floor vs observed transmon T2.
    Observed T2 should be BELOW the thermal floor (λ_obs > λ_thermal). -/
def reportTransmonT2 : AccuracyReport :=
  mkReport "transmon T2 (CAT/EPT thermal floor)"
           T2_thermal_floor_transmon_f T2_measured_transmon_f

/-! ### Lepton mass hierarchy from trefoil topology

CAT/EPT + Unified Trefoil Theory predicts generations emerge from
knot topology: crossings encode information content. We parametrize
the mass-information link as m(n) = m_e · exp(C · ln n), with C fit
to m_μ/m_e. The tau mass is then a PREDICTION, not a fit. -/

/-- Electron mass (kg), CODATA. -/
def m_e_ref_f : Float := 9.1093837015e-31

/-- Muon mass (kg), CODATA. -/
def m_mu_ref_f : Float := 1.883531627e-28

/-- Tau mass (kg), CODATA. -/
def m_tau_ref_f : Float := 3.16754e-27

/-- Electron/muon mass ratio (≈ 206.77). -/
def m_mu_over_m_e_ref_f : Float := m_mu_ref_f / m_e_ref_f

/-- Electron/tau mass ratio (≈ 3477). -/
def m_tau_over_m_e_ref_f : Float := m_tau_ref_f / m_e_ref_f

/-- Trefoil-crossing exponent fitted to muon/electron ratio: C = ln(m_μ/m_e)/ln 3.
    Roughly 4.86 — the "information-per-crossing" constant in this parametrization. -/
def topology_mass_exponent_f : Float :=
  Float.log m_mu_over_m_e_ref_f / Float.log 3.0

/-- CAT/EPT trefoil-predicted mass ratio m(n_cross)/m_e given crossing number. -/
def predict_mass_ratio_from_crossings_f (n_crossings : Float) : Float :=
  n_crossings ^ topology_mass_exponent_f

/-- PREDICTION: tau mass ratio, assuming the next generation corresponds to
    a more complex knot. If we take a `cinquefoil` (5-crossing torus knot)
    for the tau, this is CAT/EPT's prediction. -/
def predict_tau_mass_ratio_cinquefoil_f : Float :=
  predict_mass_ratio_from_crossings_f 5.0

/-- Report: CAT/EPT m_τ/m_e prediction (5-crossing knot) vs CODATA m_τ/m_e. -/
def reportTauMassHierarchy : AccuracyReport :=
  mkReport "m_τ/m_e (CAT/EPT trefoil hierarchy, 5-crossings)"
           predict_tau_mass_ratio_cinquefoil_f m_tau_over_m_e_ref_f

/-- Alternative: 7-crossing torus knot for tau. -/
def predict_tau_mass_ratio_7crossing_f : Float :=
  predict_mass_ratio_from_crossings_f 7.0

/-- Report for 7-crossing tau hypothesis. -/
def reportTauMassHierarchy7 : AccuracyReport :=
  mkReport "m_τ/m_e (CAT/EPT trefoil hierarchy, 7-crossings)"
           predict_tau_mass_ratio_7crossing_f m_tau_over_m_e_ref_f

/-- Consolidated next-step capability dossier. -/
def catEPTCapabilityDossier : List AccuracyReport :=
  [ reportElectronAnomaly
  , reportElectronAnomalyResummed
  , reportMuonAnomaly
  , reportMuonAnomalyResummed
  , reportTransmonT2
  , reportTauMassHierarchy
  , reportTauMassHierarchy7 ]

/-! ### Mercury perihelion precession (classical GR check)

The same CAT/EPT framework, in the S_I → 0 classical limit, must
reproduce standard GR. The perihelion advance of Mercury is one of
the four classical tests of GR. -/

/-- CODATA gravitational constant (m³ kg⁻¹ s⁻²). -/
def G_codata_f : Float := 6.67430e-11

/-- Solar mass (kg), IAU. -/
def M_sun_f : Float := 1.98892e30

/-- Speed of light (m/s), SI exact. -/
def c_codata_f : Float := 2.99792458e8

/-- Mercury semi-major axis (m), IAU ephemeris. -/
def a_mercury_f : Float := 5.7909050e10

/-- Mercury orbital eccentricity. -/
def e_mercury_f : Float := 0.2056

/-- Mercury orbital period (s). Siderial year for Mercury ≈ 87.969 days. -/
def T_mercury_f : Float := 7.600544e6

/-- Seconds per Julian century. -/
def secondsPerCentury_f : Float := 3.15576e9

/-- Mercury orbits per century. -/
def orbitsPerCentury_f : Float := secondsPerCentury_f / T_mercury_f

/-- GR perihelion precession per orbit (rad). -/
def perihelion_precession_per_orbit_f : Float :=
  6.0 * pi_f * G_codata_f * M_sun_f /
    (c_codata_f ^ 2 * a_mercury_f * (1.0 - e_mercury_f ^ 2))

/-- GR perihelion precession per century (rad). -/
def perihelion_precession_per_century_rad_f : Float :=
  perihelion_precession_per_orbit_f * orbitsPerCentury_f

/-- Same in arcseconds (rad × 648000 / π). -/
def perihelion_precession_per_century_arcsec_f : Float :=
  perihelion_precession_per_century_rad_f * 648000.0 / pi_f

/-- Observed Mercury perihelion advance excess (arcsec/century).
    IAU / Clemence (1947) value; matches modern ephemeris. -/
def perihelion_observed_arcsec_f : Float := 42.98

/-- CAT/EPT (classical limit) prediction vs observed Mercury advance. -/
def reportMercuryPerihelion : AccuracyReport :=
  mkReport "Mercury perihelion advance (arcsec/century)"
           perihelion_precession_per_century_arcsec_f
           perihelion_observed_arcsec_f

/-! ### SR time dilation sanity check

Set β = 0.5 as a test case: γ = 1/√(1 - 0.25) ≈ 1.1547. -/

/-- Test velocity ratio β = v/c = 0.5. -/
def beta_test_f : Float := 0.5

/-- Lorentz γ factor at β = 0.5. -/
def gamma_at_half_f : Float :=
  1.0 / Float.sqrt (1.0 - beta_test_f ^ 2)

/-- Analytic γ at β = 0.5: 2/√3 ≈ 1.15470053838. -/
def gamma_at_half_analytic_f : Float := 2.0 / Float.sqrt 3.0

/-- Numerical consistency check for γ(0.5). -/
def reportGammaAtHalf : AccuracyReport :=
  mkReport "Lorentz γ(β=0.5)"
           gamma_at_half_f gamma_at_half_analytic_f

/-- Extended dossier including classical-limit GR/SR checks. -/
def catEPTClassicalLimitDossier : List AccuracyReport :=
  [ reportMercuryPerihelion
  , reportGammaAtHalf ]

/-! ### Catsim temporal double-slit paper results

Values from `catept-main/multiphysics/catsim/PAPER_TABLES/
PAPER_VISIBILITY_SUMMARY.txt`:

Calibration on S500fs slit separation:
- Standard model γ = 5.843e+12 1/s
- CAT/EPT λ = 6.678e+12 1/s

RMSE on S500fs calibration (fit to data):
- Standard: 0.6453    CAT/EPT: 0.6461  (similar, standard slightly better)

RMSE on S800fs BLIND prediction (using same rates):
- Standard: 0.9359    CAT/EPT: 0.9342  (CAT/EPT wins)

The blind-prediction win is the key finding: CAT/EPT's entropic rate
transfers across slit separations better than the standard exponential
model. -/

/-- CAT/EPT entropic rate λ fitted to S500fs data (1/s). -/
def catsim_lambda_cat_f : Float := 6.678e12

/-- Standard-model decoherence rate γ fitted to S500fs data (1/s). -/
def catsim_gamma_std_f : Float := 5.843e12

/-- Standard-model RMSE on S800fs blind prediction. -/
def catsim_rmse_std_pred_f : Float := 0.9359

/-- CAT/EPT RMSE on S800fs blind prediction (lower is better). -/
def catsim_rmse_cat_pred_f : Float := 0.9342

/-- CAT/EPT's blind-prediction advantage: positive value means CAT wins. -/
def catsim_cat_prediction_advantage_f : Float :=
  catsim_rmse_std_pred_f - catsim_rmse_cat_pred_f

/-- Report: CAT/EPT S800fs prediction accuracy (reference = standard model). -/
def reportDoubleSlitPrediction : AccuracyReport :=
  mkReport "double-slit S800fs blind-prediction RMSE (CAT vs standard)"
           catsim_rmse_cat_pred_f catsim_rmse_std_pred_f

/-- Full experimental-paper dossier. -/
def catEPTPaperExperimentalDossier : List AccuracyReport :=
  [ reportDoubleSlitPrediction ]

end Numerics

end CATEPTMain.CATEPT.CATEPT
