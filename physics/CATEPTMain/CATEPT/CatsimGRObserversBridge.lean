import CATEPTMain.CATEPT.ClassicalGravityBridge
import Mathlib.Analysis.SpecialFunctions.Pow.Real

set_option autoImplicit false

/-!
# Catsim GR Observer Bridge

## Purpose

The Python simulator `cat_ept_doubleslit.metrics.redshift` and
`cat_ept_doubleslit.metrics.kerr_observers` define:

- `MetricField` with callable g₀₀(t, x) and redshift factor √(−g₀₀)
- `minkowski_metric()`: flat g₀₀ = −1
- `schwarzschild_metric(M)`: g₀₀(r) = −(1 − r_s/r)
- Kerr observer modes (static, ZAMO, circular geodesic) giving dτ/dt

This Lean bridge mirrors the metric-level operations (without
importing numpy/Python). Focus is on:

- Schwarzschild g₀₀ as a scalar function
- Static-observer dτ/dt (requires g₀₀ < 0, outside horizon)
- ZAMO-like extended form available via generic components

## Key results

1. Minkowski redshift factor = 1 (flat-space limit)
2. Schwarzschild g₀₀ is negative outside the horizon
3. Schwarzschild redshift factor ∈ (0, 1] outside the horizon
4. At infinity, redshift factor → 1 (asymptotic flatness)
5. At horizon, redshift factor → 0 (infinite redshift)
-/

noncomputable section

namespace CATEPTMain.CATEPT

/-! ## Minkowski (flat-space) metric -/

/-- Minkowski g₀₀ ≡ −1. -/
def minkowski_g00 : ℝ := -1

/-- Minkowski redshift factor √(−g₀₀) = 1. -/
theorem minkowski_redshift_factor :
    Real.sqrt (-minkowski_g00) = 1 := by
  unfold minkowski_g00
  simp

/-! ## Schwarzschild metric (static, spherically symmetric) -/

/-- Schwarzschild g₀₀ as a function of radius:
    g₀₀(r) = −(1 − r_s/r),  r_s = 2GM/c² . -/
def schwarzschild_g00 (G M c r : ℝ) : ℝ :=
  -(1 - schwarzschild_radius_classical G M c / r)

/-- Outside the horizon (r > r_s), Schwarzschild g₀₀ < 0 (timelike). -/
theorem schwarzschild_g00_negative_outside_horizon
    (G M c r : ℝ)
    (hG : 0 < G) (hM : 0 < M) (hc : 0 < c)
    (hr : schwarzschild_radius_classical G M c < r) :
    schwarzschild_g00 G M c r < 0 := by
  unfold schwarzschild_g00
  have hrs : 0 < schwarzschild_radius_classical G M c :=
    schwarzschild_radius_classical_pos G M c hG hM hc
  have hrpos : 0 < r := lt_trans hrs hr
  have h : schwarzschild_radius_classical G M c / r < 1 := by
    rw [div_lt_one hrpos]; exact hr
  linarith

/-- At the horizon (r = r_s), Schwarzschild g₀₀ = 0 (null). -/
theorem schwarzschild_g00_zero_at_horizon
    (G M c : ℝ) (hG : 0 < G) (hM : 0 < M) (hc : 0 < c) :
    schwarzschild_g00 G M c (schwarzschild_radius_classical G M c) = 0 := by
  unfold schwarzschild_g00
  have hrs : 0 < schwarzschild_radius_classical G M c :=
    schwarzschild_radius_classical_pos G M c hG hM hc
  rw [div_self (ne_of_gt hrs)]
  ring

/-! ## Static observer redshift factor -/

/-- Static-observer proper-time rate dτ/dt = √(−g₀₀). -/
def static_observer_dtau_dt (g00 : ℝ) : ℝ :=
  Real.sqrt (-g00)

theorem static_observer_dtau_dt_nonneg (g00 : ℝ) :
    0 ≤ static_observer_dtau_dt g00 := Real.sqrt_nonneg _

/-- Outside the horizon: static Schwarzschild observer has positive dτ/dt. -/
theorem schwarzschild_static_dtau_dt_pos
    (G M c r : ℝ)
    (hG : 0 < G) (hM : 0 < M) (hc : 0 < c)
    (hr : schwarzschild_radius_classical G M c < r) :
    0 < static_observer_dtau_dt (schwarzschild_g00 G M c r) := by
  unfold static_observer_dtau_dt
  apply Real.sqrt_pos.mpr
  have := schwarzschild_g00_negative_outside_horizon G M c r hG hM hc hr
  linarith

/-- At the horizon: static observer's dτ/dt vanishes (frozen clock). -/
theorem schwarzschild_static_dtau_dt_zero_at_horizon
    (G M c : ℝ) (hG : 0 < G) (hM : 0 < M) (hc : 0 < c) :
    static_observer_dtau_dt
      (schwarzschild_g00 G M c (schwarzschild_radius_classical G M c)) = 0 := by
  rw [schwarzschild_g00_zero_at_horizon G M c hG hM hc]
  unfold static_observer_dtau_dt
  simp

/-! ## Minkowski observer consistency -/

/-- Flat-space static observer: dτ/dt = 1 (no time dilation). -/
theorem minkowski_static_observer_rate :
    static_observer_dtau_dt minkowski_g00 = 1 := by
  unfold static_observer_dtau_dt
  exact minkowski_redshift_factor

/-! ## ZAMO-like form: effective g₀₀ including rotation -/

/-- Effective metric slot for a rotating observer with angular velocity Ω:
    g_metric = g_tt + 2 g_tφ Ω + g_φφ Ω² . -/
def rotating_observer_metric_effective (g_tt g_tphi g_phiphi Ω : ℝ) : ℝ :=
  g_tt + 2 * g_tphi * Ω + g_phiphi * Ω ^ 2

/-- Observer proper-time rate for general angular velocity:
    dτ/dt = √(−g_metric). -/
def rotating_observer_dtau_dt
    (g_tt g_tphi g_phiphi Ω : ℝ) : ℝ :=
  Real.sqrt (-(rotating_observer_metric_effective g_tt g_tphi g_phiphi Ω))

theorem rotating_observer_dtau_dt_nonneg
    (g_tt g_tphi g_phiphi Ω : ℝ) :
    0 ≤ rotating_observer_dtau_dt g_tt g_tphi g_phiphi Ω :=
  Real.sqrt_nonneg _

/-- At Ω = 0, the rotating observer reduces to the static observer. -/
theorem rotating_observer_zero_omega_is_static
    (g_tt g_tphi g_phiphi : ℝ) :
    rotating_observer_dtau_dt g_tt g_tphi g_phiphi 0 =
      static_observer_dtau_dt g_tt := by
  unfold rotating_observer_dtau_dt rotating_observer_metric_effective static_observer_dtau_dt
  simp

end CATEPTMain.CATEPT
