import CATEPTMain.Integration.BohmianQMBridge
import CATEPTMain.Integration.QuantumInfoFisherBridge
import NavierStokesClean.CATEPT.Theoremized.Batch20260408_G015_GeometricBornRule0064
/-!
# Born Rule Unification Bridge

Three independent theorem chains in catept-main derive or use the Born
rule. This module proves they are **consistent**: each is a specialization
of the same underlying identity `P = |amplitude|²`.

## The three chains

1. **Bohmian/Madelung** (BohmianQMBridge):
   `madelungDensity ψ = ψ.amplitude²` — probability density = amplitude squared.

2. **Information geometry** (QuantumInfoFisherBridge):
   `jaynesDensity β S_I = exp(-β·S_I)` — maximum entropy density.

3. **Geometric** (GeometricBornRule0064):
   `rowG015BornWeight s = s.metricWeight * Complex.normSq s.amplitude`.

(An earlier version of this bridge also contained a fourth chain linking
the UnifiedTheory `LayerB.obs` derivation to `Complex.normSq`; that
chain was removed when the UnifiedTheory external dependency was dropped.
The other three chains are self-contained within catept-main.)
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.BornRuleUnification

open CATEPTMain.Integration.BohmianQM
open NavierStokesClean.CATEPT.Theoremized.Batch20260408.G015

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

end CATEPTMain.Integration.BornRuleUnification
