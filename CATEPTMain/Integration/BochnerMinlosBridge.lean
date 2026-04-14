import Bochner
-- Note: `import Minlos` omitted — the Minlos sub-library requires the
-- remote `kolmogorov_extension4` dependency which is not pinned in
-- catept-main's lake-manifest.json.  Minlos-theorem capabilities are
-- recorded abstractly in `BochnerMinlosWitness.minlosExtensionAvailable`.

/-!
# Bochner–Minlos Integration Bridge

Connects the `BochnerMinlos` package (direct dep, Lean 4 v4.29.0) to CATEPT's
analytic core.

**Source:** `file:///…/bochner` pinned rev `1b56973aff9b`
**Toolchain status:** `direct_4_29` — imported directly.

## CATEPT leverage points

* **LAPL bridge** (`AFPBridge/LAPL`): `laplaceTransform f s` is defined as a
  Bochner integral in `LAPLPrelude`. Bochner's theorem
  (`Bochner.Main.bochner_theorem_of_pd`) identifies when the Laplace kernel's
  characteristic function comes from a probability measure, supporting
  phase-2 inversion proofs.

* **FOU / CBO bridges**: `Bochner.PositiveDefinite.IsPositiveDefinite` is the
  shared PD predicate underlying both Fourier-series kernel estimates (FOU)
  and complex operator L² bounds (CBO).

* **Minlos path-measure construction**: `Minlos.Main` provides the Minlos
  theorem — extension of a σ-additive Gaussian cylinder measure on a nuclear
  space to a full Borel measure. This underpins white-noise / Euclidean
  quantum-field extensions of CATEPT.

## Phase status
Phase-1: integration contract defined; bridge theorem sorry-proved.
Phase-2 work item: fill `bochnerMinlos_to_laplPrelude` by unfolding
`LAPLPrelude.laplaceTransform` via `Mathlib.MeasureTheory.Integral.Bochner.Basic`
and the `IsPositiveDefinite` Schur-product theorem from `Bochner.PositiveDefinite`.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.BochnerMinlos

/-- CATEPT-side requirements on the Bochner–Minlos package for phase-2 proofs. -/
structure BochnerMinlosWitness where
  /-- Bochner's theorem holds for finite-dim real inner product spaces:
      φ continuous, PD, φ(0) = 1 ↔ ∃! prob. measure μ, charFun μ = φ. -/
  bochnerTheoremAvailable : Prop
  /-- Minlos extension theorem: a Gaussian cylinder measure on a nuclear space
      extends to a σ-additive Borel probability measure. -/
  minlosExtensionAvailable : Prop
  /-- Sazonov criterion: tightness of {μ_ε} via Fourier bound
      μ({‖x‖ > R}) ≤ C ∫_{‖ξ‖≤δ} (1 − Re charFun_ε(ξ)) dξ. -/
  sazonovTightnessAvailable : Prop
  /-- Schur product theorem: pointwise product of PD functions is PD. -/
  schurProductAvailable : Prop

/-- Integration contract: records that CATEPT's LAPL/FOU/CBO bridges are
    entitled to assume Bochner–Minlos results once `BochnerMinlosWitness` is
    supplied. -/
def BochnerMinlosIntegrationContract (w : BochnerMinlosWitness) : Prop :=
  w.bochnerTheoremAvailable ∧
  w.minlosExtensionAvailable ∧
  w.sazonovTightnessAvailable ∧
  w.schurProductAvailable

/-- Phase-1 bridge theorem: the contract is satisfied whenever all four
    witness flags are set. -/
theorem bochnerMinlos_integration_contract
    (w : BochnerMinlosWitness)
    (hB  : w.bochnerTheoremAvailable)
    (hM  : w.minlosExtensionAvailable)
    (hS  : w.sazonovTightnessAvailable)
    (hSc : w.schurProductAvailable) :
    BochnerMinlosIntegrationContract w :=
  ⟨hB, hM, hS, hSc⟩

end CATEPTMain.Integration.BochnerMinlos
