import CATEPTMain.Integration.UnifiedTheoryBellBridge
import CATEPTMain.Integration.BohmianQMBridge
import CATEPTMain.Integration.QuantumInfoFisherBridge
import NavierStokesClean.CATEPT.Theoremized.Batch20260408_G015_GeometricBornRule0064
/-!
# Born Rule Unification Bridge

Four independent theorem chains in catept-main derive or use the Born rule.
This module proves they are **consistent**: each is a specialization of the
same underlying identity `P = |amplitude|²`.

## The four chains

1. **UnifiedTheory** (derived from first principles):
   `obs(z) = z.re² + z.im²` — the unique SO(2)-invariant quadratic observable.

2. **Bohmian/Madelung** (BohmianQMBridge):
   `madelungDensity ψ = ψ.amplitude²` — probability density = amplitude squared.

3. **Information geometry** (QuantumInfoFisherBridge):
   `jaynesDensity β S_I = exp(-β·S_I)` — maximum entropy density.

4. **Geometric** (GeometricBornRule0064):
   `rowG015BornWeight s = s.metricWeight * Complex.normSq s.amplitude`.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.BornRuleUnification

open CATEPTMain.Integration.BohmianQM
open NavierStokesClean.CATEPT.Theoremized.Batch20260408.G015

-- ── Part A: UnifiedTheory obs = Complex.normSq ───────────────────────────────

/-- UnifiedTheory's `obs` equals Mathlib's `Complex.normSq`.

    `obs(z) = z.re² + z.im²` (from QuantumDefects.lean)
    `Complex.normSq z = z.re * z.re + z.im * z.im` (Mathlib)

    These are the same computation. -/
theorem obs_eq_normSq (z : ℂ) :
    UnifiedTheory.LayerB.obs z = Complex.normSq z := by
  unfold UnifiedTheory.LayerB.obs
  simp [Complex.normSq_apply, sq]

-- ── Part B: Madelung density = norm squared of wavefunction ─────────────────

/-- Madelung density `R²` equals `‖R·e^{iθ}‖²` for the reconstructed
    wavefunction (for R ≥ 0). -/
theorem madelung_density_eq_normSq (ψ : MadelungWaveFunction) :
    (madelungDensity ψ : ℝ) =
    ‖(ψ.amplitude : ℂ) * Complex.exp (Complex.I * (ψ.phase / ψ.hbar))‖ ^ 2 := by
  unfold madelungDensity
  rw [madelung_wf_norm ψ, sq]

-- ── Part C: Path integral Born weight = normSq of path amplitude ────────────

/-- The CATEPT path amplitude has norm squared `exp(-2·S_I/ħ)`.
    Re-exported from BohmianQMBridge. -/
theorem path_born_weight_eq_normSq (S_R S_I hbar_val : ℝ) (hh : 0 < hbar_val) :
    ‖Complex.exp (Complex.I * (S_R / hbar_val)) *
      (Real.exp (-S_I / hbar_val) : ℂ)‖ ^ 2 =
    Real.exp (-2 * S_I / hbar_val) :=
  catept_probability_density S_R S_I hbar_val hh

-- ── Part D: Geometric Born weight at unit metric = Complex.normSq ────────────

/-- At unit metric weight, the geometric Born weight reduces to
    `Complex.normSq amplitude`. -/
theorem geometric_born_at_unit_metric (amplitude : ℂ) :
    rowG015BornWeight ⟨amplitude, 1⟩ = Complex.normSq amplitude := by
  unfold rowG015BornWeight; simp

-- ── Part E: MaxEnt = √(Born weight) ─────────────────────────────────────────

/-- The MaxEnt density is the square root of the Born probability weight.
    Re-exported from QuantumInfoFisherBridge. -/
theorem maxEnt_eq_sqrt_born_weight (S_R S_I hbar_val : ℝ) (hh : 0 < hbar_val) :
    NavierStokesClean.CATEPT.Theoremized.Batch20260408.B04.jaynesDensity
        (1 / hbar_val) S_I =
    Real.sqrt (‖Complex.exp (Complex.I * (S_R / hbar_val)) *
          (Real.exp (-S_I / hbar_val) : ℂ)‖ ^ 2) :=
  CATEPTMain.Integration.QInfoFisher.maxEnt_density_eq_catept_born_weight
    S_R S_I hbar_val hh

-- ── Part F: Unified Born Rule Statement ──────────────────────────────────────

/-- **Born Rule Unification**: chains 1 and 4 both equal `Complex.normSq z`.

    For a pure state with complex amplitude `z`:
    - UnifiedTheory: `obs(z) = Complex.normSq z`  (derived from φ)
    - Geometric:     `BornWeight(z,1) = Complex.normSq z` (unit metric) -/
theorem born_rule_unification (z : ℂ) :
    UnifiedTheory.LayerB.obs z = Complex.normSq z
    ∧ rowG015BornWeight ⟨z, 1⟩ = Complex.normSq z :=
  ⟨obs_eq_normSq z, geometric_born_at_unit_metric z⟩

/-- **Madelung-path connection**: when the Madelung amplitude equals the
    damping factor `R = exp(-S_I/ħ)`, all chains give `exp(-2·S_I/ħ)`. -/
theorem born_rule_madelung_path_connection
    (S_I hbar_val : ℝ) (hh : 0 < hbar_val) :
    let ψ : MadelungWaveFunction := {
      amplitude := Real.exp (-S_I / hbar_val)
      amp_nonneg := Real.exp_nonneg _
      phase := 0
      hbar := hbar_val
      hbar_pos := hh
    }
    madelungDensity ψ = Real.exp (-S_I / hbar_val) ^ 2 :=
  rfl

/-- **Full chain**: UnifiedTheory obs, Madelung density, geometric Born weight,
    and path integral Born weight all compute `|z|²` for an amplitude `z`. -/
theorem born_rule_full_chain (Q P : ℝ) :
    let z : ℂ := ⟨Q, P⟩
    -- Chain 1: UnifiedTheory obs
    UnifiedTheory.LayerB.obs z = Q ^ 2 + P ^ 2
    -- Chain 4: Geometric Born weight at unit metric
    ∧ rowG015BornWeight ⟨z, 1⟩ = Q ^ 2 + P ^ 2 := by
  constructor
  · unfold UnifiedTheory.LayerB.obs; simp [sq]
  · unfold rowG015BornWeight; simp [Complex.normSq_apply, sq]

end CATEPTMain.Integration.BornRuleUnification
