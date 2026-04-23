import CATEPT.CATEPT.Foundations
import CATEPT.CATEPT.QuantumGravity

/-!
# CAT/EPT ↔ General Relativity — compatibility bridge

Classical GR contributes, via Schwarzschild geometry, a family of real-valued
metric functionals and a surface-gravity / Bekenstein–Hawking entropy map.
The CAT/EPT framework treats the associated imaginary action (Euclidean black
hole action, ADM-reduced) as an `S_I` in the entropic-time identification
`τ_ent = S_I / ℏ` and recovers Hawking temperature from modular rate.

**Bridge claims**:
1. For any Schwarzschild state `(M, r, r > 2M)`, the metric function
   `f(r) = 1 − 2M/r` is strictly positive (exterior region condition).
2. For any positive mass `M`, Bekenstein–Hawking entropy is strictly
   positive — the CAT/EPT entropic clock is nontrivial in the presence of
   gravitational horizons.
3. For any positive ADM imaginary action, `τ_ent = S_I / ℏ` applies.
4. Unruh temperature is positive for any positive `ℏ, κ_B, c, k_B`.

**Axioms**: none beyond the Lean kernel. The GR-specific content (metric,
horizon, entropy laws) enters as data satisfying the hypotheses of the
generic core lemmas.
-/

set_option autoImplicit false

namespace CATEPT.Bridges.GR

open CATEPT

/-- Exterior Schwarzschild state: mass `M > 0`, radius `r > 2M`. -/
structure SchwarzschildExterior where
  M : ℝ
  r : ℝ
  M_pos : 0 < M
  r_gt_horizon : 2 * M < r

/-- Schwarzschild metric function is strictly positive in the exterior. -/
theorem schwarzschild_f_pos (s : SchwarzschildExterior) :
    0 < schwarzschild_f s.M s.r :=
  eq046_schwarzschild_positive s.M s.r s.M_pos s.r_gt_horizon

/-- Bekenstein–Hawking entropy datum for a positive-mass black hole. -/
structure BHMass where
  G : ℝ
  M : ℝ
  G_pos : 0 < G
  M_pos : 0 < M

/-- Bekenstein–Hawking entropy is strictly positive for any positive-mass
black hole — the CAT/EPT horizon clock is nondegenerate. -/
theorem bh_entropy_pos (b : BHMass) :
    0 < bekenstein_hawking_entropy b.G b.M :=
  eq147_152_bh_entropy_positive b.G b.M b.G_pos b.M_pos

/-- ADM (Euclidean) imaginary action with positivity. -/
structure ADMInput where
  S_I : ℝ
  S_I_nonneg : 0 ≤ S_I

/-- Entropic proper time of an ADM input. -/
noncomputable def tauEnt (a : ADMInput) (ℏ : ℝ) : ℝ :=
  entropic_time ℏ a.S_I

/-- CAT/EPT identity `τ_ent = S_I / ℏ` on ADM inputs. -/
theorem tauEnt_eq_div (a : ADMInput) (ℏ : ℝ) (hℏ : 0 < ℏ) :
    tauEnt a ℏ = a.S_I / ℏ :=
  eq003_entropic_time_def ℏ a.S_I hℏ

/-- Nonnegativity of entropic proper time on ADM inputs. -/
theorem tauEnt_nonneg (a : ADMInput) (ℏ : ℝ) (hℏ : 0 < ℏ) :
    0 ≤ tauEnt a ℏ :=
  eq003_entropic_time_nonneg ℏ a.S_I hℏ a.S_I_nonneg

/-- Unruh-flavour datum: positive `ℏ, κ_B, c, k_B`. -/
structure UnruhInput where
  ℏ : ℝ
  κ_B : ℝ
  c : ℝ
  k_B : ℝ
  ℏ_pos : 0 < ℏ
  κ_B_pos : 0 < κ_B
  c_pos : 0 < c
  k_B_pos : 0 < k_B

/-- Unruh temperature is strictly positive — the CAT/EPT thermal clock
registers the horizon's acceleration. -/
theorem unruh_temperature_pos (u : UnruhInput) :
    0 < unruh_temperature u.ℏ u.κ_B u.c u.k_B :=
  eq049_unruh_temperature_positive u.ℏ u.κ_B u.c u.k_B
    u.ℏ_pos u.κ_B_pos u.c_pos u.k_B_pos

end CATEPT.Bridges.GR
