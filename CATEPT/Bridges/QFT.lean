import CATEPT.CATEPT.Foundations
import CATEPT.CATEPT.PathIntegrals

/-!
# CAT/EPT ↔ QFT (Euclidean path integral) — compatibility bridge

Any Euclidean QFT provides an imaginary-action functional `S_I[φ]` and a
tree-level propagator built from the kinetic kernel `k² + m² + λ`. The
CAT/EPT framework maps these onto entropic proper time (`τ_ent = S_I / ℏ`)
and exponential path-integral damping.

**Bridge claims** (proved without new axioms):
1. `τ_ent = S_I / ℏ` and `0 ≤ τ_ent` for any Euclidean `S_I ≥ 0`.
2. Damping magnitude `|exp(-S_I / ℏ)| ≤ 1` for `S_I ≥ 0`.
3. The Euclidean propagator kernel is strictly positive given the standard
   hypotheses `k² ≥ 0`, `m² ≥ 0`, `λ > 0`.

The "positive regulator" hypothesis is carried as a real-valued predicate,
not an axiom.
-/

set_option autoImplicit false

namespace CATEPT.Bridges.QFT

open CATEPT

/-- A minimal Euclidean QFT input: imaginary action at a configuration, plus
kinetic-kernel parameters. Downstream integrations supply concrete values. -/
structure EuclideanQFTInput where
  /-- Imaginary part of the Euclidean action. -/
  S_I : ℝ
  /-- `S_I ≥ 0` by Osterwalder–Schrader reflection positivity. -/
  S_I_nonneg : 0 ≤ S_I
  /-- Momentum-squared at the point of interest. -/
  k_sq : ℝ
  /-- Bare mass squared. -/
  m_sq : ℝ
  /-- Self-interaction regulator. -/
  lam : ℝ
  /-- `k² ≥ 0`. -/
  k_sq_nonneg : 0 ≤ k_sq
  /-- `m² ≥ 0`. -/
  m_sq_nonneg : 0 ≤ m_sq
  /-- Regulator positivity. -/
  lam_pos : 0 < lam

/-- Entropic proper time of the QFT input. -/
noncomputable def tauEnt (q : EuclideanQFTInput) (ℏ : ℝ) : ℝ :=
  entropic_time ℏ q.S_I

/-- CAT/EPT identity `τ_ent = S_I / ℏ` on the QFT input. -/
theorem tauEnt_eq_div (q : EuclideanQFTInput) (ℏ : ℝ) (hℏ : 0 < ℏ) :
    tauEnt q ℏ = q.S_I / ℏ :=
  eq003_entropic_time_def ℏ q.S_I hℏ

/-- Nonnegativity of entropic proper time for QFT inputs. -/
theorem tauEnt_nonneg (q : EuclideanQFTInput) (ℏ : ℝ) (hℏ : 0 < ℏ) :
    0 ≤ tauEnt q ℏ :=
  eq003_entropic_time_nonneg ℏ q.S_I hℏ q.S_I_nonneg

/-- Damping magnitude `|exp(-S_I/ℏ)| ≤ 1` on QFT inputs. -/
theorem damping_abs_le_one (q : EuclideanQFTInput) (ℏ : ℝ) (hℏ : 0 < ℏ) :
    abs (path_integral_damping ℏ q.S_I) ≤ 1 :=
  eq054_damping_magnitude ℏ q.S_I hℏ q.S_I_nonneg

/-- The Euclidean kinetic kernel is strictly positive on QFT inputs. -/
theorem kinetic_pos (q : EuclideanQFTInput) :
    0 < q.k_sq + q.m_sq + q.lam :=
  eq075_propagator_well_defined q.k_sq q.m_sq q.lam
    q.k_sq_nonneg q.m_sq_nonneg q.lam_pos

/-- The tree-level Euclidean propagator is strictly positive on QFT inputs. -/
theorem propagator_pos (q : EuclideanQFTInput) :
    0 < euclidean_propagator q.k_sq q.m_sq q.lam :=
  eq075_propagator_positive q.k_sq q.m_sq q.lam
    q.k_sq_nonneg q.m_sq_nonneg q.lam_pos

end CATEPT.Bridges.QFT
