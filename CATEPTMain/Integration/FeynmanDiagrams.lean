/-
  T-C Phase 1: Feynman-diagram algebra — tree-level s-channel exchange.

  Honest, kernel-only algebraic identities for the simplest non-trivial
  Feynman amplitude: a tree-level 4-point s-channel scalar exchange,
        M(g, s, m)  =  g^2 / (s - m^2).
  This object is the building block of every perturbative QFT amplitude.
  It exposes three structural facts that any honest Feynman-rule layer must
  reproduce:

    (1) the amplitude factorises as coupling-squared × propagator;
    (2) the residue at the s-channel pole is exactly g^2 (no anomalous
        prefactor — this is the unitarity normalisation);
    (3) the amplitude scales as the square of the coupling (so
        rescaling g ↦ k·g multiplies M by k², the universal tree-level
        weight).

  Phase 2 (deferred): one-loop vacuum polarisation algebra,
  Cutkosky cutting rules, BPHZ subtraction, on-shell renormalisation.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Positivity

set_option autoImplicit false

namespace CATEPTMain.Integration.FeynmanDiagrams

noncomputable section

/-- Euclidean tree-level scalar propagator
    `Δ(s, m) = 1 / (s - m²)` for Mandelstam invariant `s` and mass `m`. -/
def treePropagator (s m : ℝ) : ℝ := 1 / (s - m ^ 2)

/-- Tree-level s-channel exchange amplitude
    `M(g, s, m) = g² · Δ(s, m) = g² / (s - m²)`. -/
def treeAmplitude (g s m : ℝ) : ℝ := g ^ 2 * treePropagator s m

/-- Closed-form factorisation: amplitude is coupling-squared over propagator
    denominator. -/
theorem treeAmplitude_closed_form (g s m : ℝ) :
    treeAmplitude g s m = g ^ 2 / (s - m ^ 2) := by
  unfold treeAmplitude treePropagator
  ring

/-- Pole residue: away from the pole, multiplying by the kinematic
    denominator `(s - m²)` extracts exactly `g²`. This is the unitarity
    normalisation of a tree-level scalar exchange. -/
theorem treeAmplitude_residue_at_pole
    (g s m : ℝ) (_hpole : s - m ^ 2 ≠ 0) :
    (s - m ^ 2) * treeAmplitude g s m = g ^ 2 := by
  unfold treeAmplitude treePropagator
  field_simp

/-- Coupling rescaling: `g ↦ k·g` multiplies the amplitude by `k²`.
    This is the universal tree-level coupling weight. -/
theorem treeAmplitude_coupling_rescale (k g s m : ℝ) :
    treeAmplitude (k * g) s m = k ^ 2 * treeAmplitude g s m := by
  unfold treeAmplitude
  ring

end

end CATEPTMain.Integration.FeynmanDiagrams
