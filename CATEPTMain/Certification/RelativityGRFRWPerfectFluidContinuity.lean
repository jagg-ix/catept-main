/-
# FRW perfect-fluid + continuity ⇒ matter-model contract

This module names the two physics-level halves of the FRW
matter-model contract `FRWMatterModel p`
(from `RelativityGRFRWMatterModel`):

* `FRWPerfectFluidStress p` — "the symbolic covariant divergence of
  the FRW stress-energy tensor vanishes" (the textbook continuity
  equation `∇_μ T^{μν} = 0` for a perfect-fluid stress-energy tensor
  in covariant form).
* `FRWContinuityEquation p` — "the symbolic covariant divergence of
  the Einstein tensor for the FLRW metric vanishes" (the contracted
  Bianchi identity `∇_μ G^{μν} = 0`, sometimes called the
  geometric-side continuity equation).

The combined derivation
`frwMatterModel_of_perfectFluidContinuity` then packages
`FRWMatterModel p` by transitivity:
`∇_μ T^{μν} = 0 = ∇_μ G^{μν}` so the two divergences agree, which
is precisely `FRWMatterModel.divergence_compat`.

This module does **not** attempt to discharge either contract.
Each will be closed by an upstream FLRW symbolic stack:

* `FRWPerfectFluidStress p` by an FLRW perfect-fluid
  stress-energy / continuity simplifier;
* `FRWContinuityEquation p` by the symbolic contracted-Bianchi
  simplifier (closely related to
  `FRWSymbolicDivergenceSimplifies` from
  `RelativityGRFRWChartSymbolicContract`).

## Acceptance

* `lake build CATEPTMain.Certification.RelativityGRFRWPerfectFluidContinuity`
  passes;
* `#check @FRWPerfectFluidStress`,
  `#check @FRWContinuityEquation`, and
  `#check @frwMatterModel_of_perfectFluidContinuity`
  elaborate;
* `#print axioms` reports only standard kernel axioms.
-/

import CATEPTMain.Certification.RelativityGRFRWMatterModel

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.RelativityGR

open Gravitas

/-- **FRW perfect-fluid stress / matter-side continuity contract.**

Names the textbook continuity equation `∇_μ T^{μν} = 0` for the
FRW perfect-fluid stress-energy tensor in covariant symbolic form:
the symbolic covariant divergence of `p.stress` under the FLRW
Levi-Civita connection is the zero array.  Closed by an FLRW
perfect-fluid simplification stack once it lands. -/
structure FRWPerfectFluidStress (p : FRWRawParameter) : Prop where
  /-- Symbolic covariant divergence of `p.stress` under the FLRW
      Levi-Civita connection is the zero array, in dimension equal
      to that of the FLRW metric family. -/
  stress_divergence_zero :
    covariantDivergenceStressEnergy (frwRawMetricFamily p) p.stress =
      Array.replicate (frwRawMetricFamily p).dim
        (Gravitas.Expr.lit 0)

/-- **FRW continuity equation / geometric-side Bianchi contract.**

Names the contracted Bianchi identity `∇_μ G^{μν} = 0` for the FLRW
metric in covariant symbolic form: the symbolic covariant divergence
of the Einstein tensor under the FLRW Levi-Civita connection is the
zero array.  Closed by the symbolic FLRW contracted-Bianchi
simplifier once it lands. -/
structure FRWContinuityEquation (p : FRWRawParameter) : Prop where
  /-- Symbolic covariant divergence of the Einstein tensor for the
      FLRW metric is the zero array, in dimension equal to that of
      the FLRW metric family. -/
  einstein_divergence_zero :
    covariantDivergenceEinsteinTensor (frwRawMetricFamily p) =
      Array.replicate (frwRawMetricFamily p).dim
        (Gravitas.Expr.lit 0)

/-- **Constrained derivation of `FRWMatterModel p` from
perfect-fluid stress and continuity.**

Combines the perfect-fluid stress contract
`FRWPerfectFluidStress p` (`∇_μ T^{μν} = 0`) with the
geometric-side continuity contract `FRWContinuityEquation p`
(`∇_μ G^{μν} = 0`) by transitivity to derive
`FRWMatterModel.divergence_compat`:
`∇_μ T^{μν} = 0_array = ∇_μ G^{μν}`. -/
theorem frwMatterModel_of_perfectFluidContinuity
    (p : FRWRawParameter)
    (hPF : FRWPerfectFluidStress p)
    (hContinuity : FRWContinuityEquation p) :
    FRWMatterModel p where
  divergence_compat :=
    hPF.stress_divergence_zero.trans hContinuity.einstein_divergence_zero.symm

end CATEPTMain.Certification.RelativityGR

end
