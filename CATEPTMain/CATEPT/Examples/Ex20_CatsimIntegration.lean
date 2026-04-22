import CATEPTMain.CATEPT.CatsimEntropicTimeBridge
import CATEPTMain.CATEPT.CatsimGRObserversBridge
import CATEPTMain.CATEPT.CATEPTPredictions

set_option autoImplicit false

/-!
# Example 20: Catsim Integration — Three Lines of Leverage

## What this demonstrates

Leverages concrete material from
`catept-main/multiphysics/catsim/`:

1. **Integral form of τ_ent** (from `clock/entropic_clock.py`):
   `τ_ent(t0, t1) = ∫ λ(s) ds` — the operational definition used
   in the Python simulator and `catsim/lean/`. This example shows
   Lean equivalence to the algebraic form `S_I / ℏ`.

2. **Schwarzschild metric observer** (from `metrics/redshift.py`):
   static-observer dτ/dt = √(−g₀₀) with g₀₀(r) = −(1 − r_s/r).
   Cleanly complements Ex19's perihelion precession.

3. **Double-slit paper result** (from
   `PAPER_TABLES/PAPER_VISIBILITY_SUMMARY.txt`): CAT/EPT beats the
   standard exponential-decoherence model on blind prediction at
   S800fs slit separation (RMSE 0.9342 vs 0.9359).

## Numerical evaluation

```
#eval CATEPT.Numerics.catsim_lambda_cat_f                -- 6.678e12
#eval CATEPT.Numerics.catsim_gamma_std_f                 -- 5.843e12
#eval CATEPT.Numerics.catsim_cat_prediction_advantage_f  -- +0.0017 (CAT wins)
#eval CATEPT.Numerics.reportDoubleSlitPrediction
#eval CATEPT.Numerics.catEPTPaperExperimentalDossier
```

## Key theorems (proved)

**Integral τ_ent**:
- Zero on degenerate interval
- Non-negative for forward interval with λ ≥ 0
- Equals c·(t1−t0) for constant rate c
- Equivalent to algebraic `entropic_time ℏ S_I` when λ = S_I/ℏ is constant

**GR observers**:
- Minkowski redshift factor = 1
- Schwarzschild g₀₀ < 0 outside horizon
- Static observer dτ/dt > 0 outside horizon
- Static observer dτ/dt → 0 at horizon (clock freezes)
- Rotating observer reduces to static at Ω = 0
-/

noncomputable section

namespace CATEPT.Examples

open CATEPT

/-! ### 1. Integral-form τ_ent -/

-- Degenerate interval: τ_ent(t, t) = 0
example (rate : ℝ → ℝ) (t : ℝ) :
    entropic_time_integral rate t t = 0 :=
  entropic_time_integral_same rate t

-- Non-negativity: ∫ λ ≥ 0 when λ ≥ 0 on forward interval
example (rate : ℝ → ℝ) (t0 t1 : ℝ) (hrate : ∀ t, 0 ≤ rate t) (hle : t0 ≤ t1) :
    0 ≤ entropic_time_integral rate t0 t1 :=
  entropic_time_integral_nonneg rate t0 t1 hrate hle

-- Constant rate: τ_ent = c · (t1 − t0)
example (c t0 t1 : ℝ) :
    entropic_time_integral (fun _ => c) t0 t1 = c * (t1 - t0) :=
  entropic_time_integral_const c t0 t1

-- **Unification**: integral form with constant rate λ = S_I/ℏ
-- equals the algebraic τ_ent × duration
example (S_I ℏ duration : ℝ) :
    entropic_time_integral (fun _ => S_I / ℏ) 0 duration =
      entropic_time ℏ S_I * duration :=
  entropic_time_integral_eq_algebraic S_I ℏ duration

-- At unit duration, integral form = algebraic form
example (S_I ℏ : ℝ) :
    entropic_time_integral (fun _ => S_I / ℏ) 0 1 = entropic_time ℏ S_I :=
  entropic_time_integral_unit_duration S_I ℏ

/-! ### 2. Schwarzschild redshift and static observer -/

-- Minkowski (flat space): redshift factor = 1
example : Real.sqrt (-minkowski_g00) = 1 :=
  minkowski_redshift_factor

-- Minkowski static observer: dτ/dt = 1
example : static_observer_dtau_dt minkowski_g00 = 1 :=
  minkowski_static_observer_rate

-- Schwarzschild g₀₀ negative outside horizon
example (G M c r : ℝ) (hG : 0 < G) (hM : 0 < M) (hc : 0 < c)
    (hr : schwarzschild_radius_classical G M c < r) :
    schwarzschild_g00 G M c r < 0 :=
  schwarzschild_g00_negative_outside_horizon G M c r hG hM hc hr

-- Schwarzschild g₀₀ vanishes at horizon
example (G M c : ℝ) (hG : 0 < G) (hM : 0 < M) (hc : 0 < c) :
    schwarzschild_g00 G M c (schwarzschild_radius_classical G M c) = 0 :=
  schwarzschild_g00_zero_at_horizon G M c hG hM hc

-- Schwarzschild static observer dτ/dt > 0 outside horizon
example (G M c r : ℝ) (hG : 0 < G) (hM : 0 < M) (hc : 0 < c)
    (hr : schwarzschild_radius_classical G M c < r) :
    0 < static_observer_dtau_dt (schwarzschild_g00 G M c r) :=
  schwarzschild_static_dtau_dt_pos G M c r hG hM hc hr

-- Clock freezes at the horizon
example (G M c : ℝ) (hG : 0 < G) (hM : 0 < M) (hc : 0 < c) :
    static_observer_dtau_dt
      (schwarzschild_g00 G M c (schwarzschild_radius_classical G M c)) = 0 :=
  schwarzschild_static_dtau_dt_zero_at_horizon G M c hG hM hc

/-! ### 3. Rotating-observer reduction -/

-- Non-rotating limit: Ω = 0 gives the static observer
example (g_tt g_tphi g_phiphi : ℝ) :
    rotating_observer_dtau_dt g_tt g_tphi g_phiphi 0 =
      static_observer_dtau_dt g_tt :=
  rotating_observer_zero_omega_is_static g_tt g_tphi g_phiphi

end CATEPT.Examples

/-! ### Numerical agreement — Catsim paper results

```
#eval CATEPT.Numerics.catEPTPaperExperimentalDossier
--   [ double-slit S800fs: predicted 0.9342 / reference 0.9359 → CAT wins ]

#eval CATEPT.Numerics.catsim_cat_prediction_advantage_f
--   +0.0017 (dimensionless RMSE margin in favor of CAT/EPT)
```
-/
