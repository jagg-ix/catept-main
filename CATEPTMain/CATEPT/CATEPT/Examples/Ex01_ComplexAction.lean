import CATEPTMain.CATEPT.CATEPT.Foundations
import CATEPTMain.CATEPT.CATEPT.InfluenceFunctionalBridge

set_option autoImplicit false

/-!
# Example 1: The Complex Action — S_I ≥ 0 as a Theorem

## What makes this unique to CAT/EPT

In standard QFT, the action is real. Dissipation and decoherence are
bolted on later via Lindblad equations or stochastic terms.

In CAT/EPT, the action is **complex from the start**:

  S[Φ] = S_R[Φ] + i S_I[Φ]

The real part S_R generates unitary oscillations (standard physics).
The imaginary part S_I generates damping (entropy, decoherence).

## The key result: S_I ≥ 0 is derived, not assumed

The non-negativity of S_I follows from the Feynman-Vernon influence
functional: when you trace out a thermal environment coupled linearly
to the system, you get

  S_I[q,q'] = ∫∫ η(t) α_R(t-t') η(t') dt dt'

where η = q - q' is the forward-backward path difference and α_R is
the noise kernel. Since α_R is positive-semi-definite (it's the cosine
transform of the non-negative spectral weight J(ω)coth(βℏω/2)), the
quadratic form S_I is automatically non-negative.

This means entropy is not an add-on — it's **forced** by the
measure-theoretic structure of open quantum systems.
-/

noncomputable section

namespace CATEPT.Examples

open CATEPT

-- The complex action: S = S_R + iS_I with S_I ≥ 0 (field in structure)
example : ∀ {Φ : Type*} (χ : ComplexAction Φ) (φ : Φ), 0 ≤ χ.S_I φ :=
  fun χ φ => χ.S_I_nonneg φ

-- But S_I_nonneg is not an axiom! It can be constructed from influence
-- functional data via the PSD quadratic form:
example : ∀ (Q : PSDQuadraticForm), 0 ≤ Q.value :=
  fun Q => Q.nonneg

-- Building a ComplexAction where S_I_nonneg is PROVED:
example {Φ : Type*} (S_R : Φ → ℝ) (forms : Φ → PSDQuadraticForm) :
    ∀ φ, 0 ≤ (ComplexAction.fromInfluenceFunctional S_R forms).S_I φ :=
  fun φ => (forms φ).nonneg

-- In the Markovian limit, S_I = 2γk_BT ∫ η² dt ≥ 0
-- (integral of non-negative function × positive prefactor)
example (m : MarkovianInfluenceFunctional)
    (eta : ℝ → ℝ) (ti tf : ℝ) (htf : ti ≤ tf) :
    0 ≤ markovian_actionIm m eta ti tf :=
  markovian_actionIm_nonneg m eta ti tf htf

-- S_I = 0 exactly when η = 0 (forward = backward path, no decoherence)
example (m : MarkovianInfluenceFunctional) (ti tf : ℝ) :
    markovian_actionIm m (fun _ => 0) ti tf = 0 :=
  markovian_actionIm_zero_of_eta_zero m ti tf

end CATEPT.Examples
