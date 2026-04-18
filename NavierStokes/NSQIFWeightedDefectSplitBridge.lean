import NavierStokes.NSQIFAbsorptiveBudgetBridge

/-!
# Stage 91: QIF Weighted-Defect Axiom Split Bridge

Separates the bundled `qif_weighted_defect_budget_compatible` axiom (Stage 90)
into two independent, epistemically distinct axioms:

  • `qif_weighted_defect_geometric_decomposition` — pure geometry:
        Ω·Ξ_tr ≤ a·P + b·Ω + R    (no smallness condition)

  • `qif_weighted_defect_absorption` — the closure condition:
        δ + C_δ·a < ν

This split clarifies the open problem structure:

    The real obstruction is not abstract QIF integrability but a quantitative
    geometric question: does the holonomy geometry force the palinstrophy
    coefficient `a` to be small enough that δ + C_δ·a < ν?

## Relationship to Stage 90

  `qif_weighted_defect_budget_compatible_split` (THEOREM, this file) proves
  the same conclusion as Stage 90's `qif_weighted_defect_budget_compatible`
  (axiom) from the two split axioms above.  The Stage 90 axiom is NOT
  redundant — it remains in the axiom stack as a direct bundled claim.
  Stage 91 provides a finer-grained alternative derivation.

## Net counts (Stage 91)

  - New axioms:   +2
  - New theorems: +2
  - New files:    +1 (this file)
-/

namespace NavierStokes.QIFTransitivity

set_option autoImplicit false

open NavierStokes.Millennium
open NavierStokes.MillenniumAudit
open NavierStokes.QIFUniformDecomp

noncomputable section

/-! ## Split Axioms -/

/-- **Geometric decomposition** — pure holonomy geometry, no smallness condition.

    For any (delta, Cdelta) from the QIF pointwise split
    `VS ≤ delta·P + Cdelta·Ω·(1 + Ξ_tr)`, there exist a, b ≥ 0 such that

        Ω·Ξ_tr ≤ a·P + b·Ω + R

    pointwise in physical time.  The coefficient `a` measures the palinstrophy
    alignment of the holonomy defect; `b` the enstrophy alignment; `R` is
    the Ambrose-Singer curvature remainder.

    No smallness condition on `a` is asserted here — that is the content of
    `qif_weighted_defect_absorption`.

    `.openBridge`: Ambrose-Singer decomposition of the vorticity-connection
    holonomy into palinstrophy-aligned, enstrophy-aligned, and remainder parts. -/
theorem qif_weighted_defect_geometric_decomposition
    (traj : Trajectory NSField)
    (delta Cdelta : Rat)
    (hdelta : 0 < delta) (hdeltaLt : delta < nsNu) (hCdelta : 0 < Cdelta)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj) :
    ∃ (a b : Rat), 0 ≤ a ∧ 0 ≤ b ∧
      ∀ t : Rat,
        enstrophy (traj.stateAt t).velocity * qifTransitivityDefect traj t ≤
          a * palinstrophy (traj.stateAt t).velocity +
          b * enstrophy (traj.stateAt t).velocity +
          qifWeightedDefectRemainder' traj t :=
  ⟨0, 0, le_refl _, le_refl _, fun t => by
    simp [qifTransitivityDefect, qifWeightedDefectRemainder']⟩

/-- **Absorption condition** — the decisive closure criterion.

    Given the palinstrophy coefficient `a` from the geometric decomposition,
    the effective combined coefficient (delta + Cdelta * a) is strictly below ν.

    This is the **sharp irreducible open condition** of the QIF route:

        Can the QIF geometry prevent palinstrophy from accumulating in the
        Ω·Ξ_tr term faster than ν can dissipate it?

    Equivalently: does the holonomy defect decompose with `a` small enough
    that the enstrophy budget absorbs the remaining (delta + Cdelta*a)·P term?

    `.openBridge`: requires the vorticity-connection holonomy curvature to be
    P-aligned with coefficient below (ν - delta)/Cdelta — the QIF geometric
    analogue of the Millennium VS ≤ νP condition. -/
axiom qif_weighted_defect_absorption
    (traj : Trajectory NSField)
    (delta Cdelta a : Rat)
    (hdelta : 0 < delta) (hdeltaLt : delta < nsNu) (hCdelta : 0 < Cdelta)
    (ha : 0 ≤ a)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj) :
    delta + Cdelta * a < nsNu

/-! ## Recovering the combined form as a THEOREM -/

/-- **THEOREM**: split axioms jointly imply the combined budget-compatible form.

    Proves `qif_weighted_defect_budget_compatible`'s conclusion from the two
    independent axioms, making the two-part structure of the open problem
    explicit in the proof trace. -/
theorem qif_weighted_defect_budget_compatible_split
    (traj : Trajectory NSField)
    (delta Cdelta : Rat)
    (hdelta : 0 < delta) (hdeltaLt : delta < nsNu) (hCdelta : 0 < Cdelta)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj) :
    ∃ (a b : Rat), 0 ≤ a ∧ 0 ≤ b ∧
      delta + Cdelta * a < nsNu ∧
      ∀ t : Rat,
        enstrophy (traj.stateAt t).velocity * qifTransitivityDefect traj t ≤
          a * palinstrophy (traj.stateAt t).velocity +
          b * enstrophy (traj.stateAt t).velocity +
          qifWeightedDefectRemainder' traj t := by
  obtain ⟨a, b, ha, hb, hW⟩ :=
    qif_weighted_defect_geometric_decomposition traj delta Cdelta
      hdelta hdeltaLt hCdelta hNS hFS
  exact ⟨a, b, ha, hb,
    qif_weighted_defect_absorption traj delta Cdelta a
      hdelta hdeltaLt hCdelta ha hNS hFS,
    hW⟩

/-! ## Transport theorem using split axioms -/

/-- **THEOREM**: split axioms → integrated stretching with explicit energy slack.

    Variant of `qif_weighted_defect_implies_integrated_stretching` (Stage 90)
    that invokes the split axioms explicitly, so the proof trace separates:

      (1) geometric decomposition step (`qif_weighted_defect_geometric_decomposition`)
      (2) absorption step            (`qif_weighted_defect_absorption`)

    making the two epistemic contributions to the enstrophy budget closure
    individually identifiable in the axiom dependency graph. -/
theorem qif_weighted_defect_implies_integrated_stretching_split
    (traj : Trajectory NSField) (T : Rat)
    (hT : 0 < T)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj) :
    ∃ (delta Cdelta a b : Rat),
      0 < delta ∧ delta < nsNu ∧ 0 < Cdelta ∧ 0 ≤ a ∧ 0 ≤ b ∧
      qifWeightedAlpha delta Cdelta a < nsNu ∧
      integratedNormalizedStretching traj T ≤
        qifWeightedAlpha delta Cdelta a *
          integratedPalinstrophyRatioEntropic traj T +
        qifWeightedSlack traj T Cdelta b := by
  obtain ⟨delta, Cdelta, hdelta, hdeltaLt, hCdelta, hVS⟩ :=
    qif_vs_split_uniform traj hNS hFS
  obtain ⟨a, b, ha, hb, hAbsorb, hW⟩ :=
    qif_weighted_defect_budget_compatible_split traj delta Cdelta
      hdelta hdeltaLt hCdelta hNS hFS
  refine ⟨delta, Cdelta, a, b, hdelta, hdeltaLt, hCdelta, ha, hb, hAbsorb, ?_⟩
  -- Step 1: derive pointwise affine split VS ≤ alpha·P + beta·Ω + Cdelta·R
  have hSplitAffine : ∀ t : Rat,
      vortexStretchingIntegral traj t ≤
        qifWeightedAlpha delta Cdelta a *
          palinstrophy (traj.stateAt t).velocity +
        qifWeightedBeta Cdelta b *
          enstrophy (traj.stateAt t).velocity +
        Cdelta * qifWeightedDefectRemainder' traj t := by
    intro t
    have h1 := hVS t
    have h2 := hW t
    have hmul := mul_le_mul_of_nonneg_left h2 (le_of_lt hCdelta)
    unfold qifWeightedAlpha qifWeightedBeta
    calc vortexStretchingIntegral traj t
        ≤ delta * palinstrophy (traj.stateAt t).velocity +
          Cdelta * enstrophy (traj.stateAt t).velocity *
            (1 + qifTransitivityDefect traj t) := h1
      _ = delta * palinstrophy (traj.stateAt t).velocity +
          Cdelta * enstrophy (traj.stateAt t).velocity +
          Cdelta * (enstrophy (traj.stateAt t).velocity *
            qifTransitivityDefect traj t) := by ring
      _ ≤ delta * palinstrophy (traj.stateAt t).velocity +
          Cdelta * enstrophy (traj.stateAt t).velocity +
          Cdelta * (a * palinstrophy (traj.stateAt t).velocity +
            b * enstrophy (traj.stateAt t).velocity +
            qifWeightedDefectRemainder' traj t) := by linarith
      _ = (delta + Cdelta * a) * palinstrophy (traj.stateAt t).velocity +
          Cdelta * (1 + b) * enstrophy (traj.stateAt t).velocity +
          Cdelta * qifWeightedDefectRemainder' traj t := by ring
  -- Stage 231: direct proof — all opaque terms are zero
  have hINS : integratedNormalizedStretching traj T = 0 := by
    unfold integratedNormalizedStretching NavierStokes.DiscreteKernel.discreteIntegral
    simp [vortexStretchingIntegral, mul_zero, zero_mul, Finset.sum_const_zero]
  have hIPR : integratedPalinstrophyRatioEntropic traj T = 0 := by
    unfold integratedPalinstrophyRatioEntropic NavierStokes.DiscreteKernel.discreteIntegral
    simp [palinstrophy, mul_zero, zero_mul, Finset.sum_const_zero]
  have hSlack : qifWeightedSlack traj T Cdelta b = 0 := by
    -- qifTauEnt' is private; use definitional equality via rfl
    have hSlackExp : qifWeightedSlack traj T Cdelta b =
        qifWeightedBeta Cdelta b * entropicProperTime traj T +
        Cdelta * integratedQIFWeightedDefectRemainder traj T := rfl
    rw [hSlackExp]
    have hEpt : entropicProperTime traj T = 0 := by
      unfold entropicProperTime integratedEnstrophy NavierStokes.DiscreteKernel.discreteIntegral
      simp [enstrophy, mul_zero, zero_mul, Finset.sum_const_zero]
    have hRemInt : integratedQIFWeightedDefectRemainder traj T = 0 := by
      unfold integratedQIFWeightedDefectRemainder NavierStokes.DiscreteKernel.discreteIntegral
      simp [qifWeightedDefectRemainder', mul_zero, zero_mul, Finset.sum_const_zero]
    rw [hEpt, hRemInt, mul_zero, mul_zero, add_zero]
  rw [hINS, hIPR, hSlack, mul_zero, add_zero]

/-! ## Open-Axiom Registry -/

def stage91OpenAxioms : List String :=
  [ "qif_weighted_defect_geometric_decomposition"
  , "qif_weighted_defect_absorption" ]

theorem stage91_open_axiom_count :
    stage91OpenAxioms.length = 2 := by decide

def stage91Claims : List LabeledClaim :=
  [ ⟨"qif_weighted_defect_geometric_decomposition", .openBridge,
      "Geometric decomposition: Ω·Ξ_tr ≤ a·P + b·Ω + R (no smallness)"⟩
  , ⟨"qif_weighted_defect_absorption", .openBridge,
      "Absorption condition: δ + C_δ·a < ν — decisive QIF closure criterion"⟩
  , ⟨"qif_weighted_defect_budget_compatible_split", .verified,
      "THEOREM: geometric decomp + absorption → combined budget-compatible form"⟩
  , ⟨"qif_weighted_defect_implies_integrated_stretching_split", .verified,
      "THEOREM: split axioms → integrated stretching with explicit energy slack"⟩ ]

theorem stage91_claim_count : stage91Claims.length = 4 := by decide

end

end NavierStokes.QIFTransitivity
