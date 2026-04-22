import CATEPTMain.CATEPT.CATEPTPredictions

set_option autoImplicit false

/-!
# Example 15: CAT/EPT Accuracy Check Against CODATA

## What this example does

Evaluates the CAT/EPT leading-order predictions under the CODATA 2018
input bundle, and checks them against the CODATA reference values for
the electron and muon anomalous magnetic moments.

The CAT/EPT leading-order prediction for both lepton anomalies is the
**Schwinger term** α/(2π). Under CODATA α = 1/137.035999084:

  Schwinger = 1/137.035999084 / (2π) ≈ 1.161 409 73 × 10⁻³

CODATA references:
- a_e = 1.159 652 181 28 × 10⁻³  → CAT/EPT LO accurate to ~0.15%
- a_μ = 1.165 920 89 × 10⁻³      → CAT/EPT LO accurate to ~0.39%

The remaining ~0.15% (electron) and ~0.39% (muon) gap is what the
higher-order QED, hadronic, and electroweak sectors fill in, encoded
in CAT/EPT via `dyson_resummed` and `total_sector`.

## Running the check

```
#eval CATEPT.Numerics.codataLeadingOrderReports
```

gives a list of `AccuracyReport` structs with predicted, reference,
and relative-error fields.

## Key results (structural, proved)

1. Under any input provider, a_e and a_μ predictions are positive
2. Schwinger self-consistency: predicted anomaly = α/(2π) (by rfl)
3. CODATA and Lean-intrinsic provider paths BOTH satisfy these
4. Dyson resummation in the small-correction regime preserves positivity

## Key results (numerical, #eval)

- `#eval reportElectronAnomaly.relError` ≈ 0.0015
- `#eval reportMuonAnomaly.relError` ≈ 0.0039
-/

noncomputable section

namespace CATEPT.Examples

open CATEPT

/-! ### Structural checks on the CODATA-anchored provider -/

-- CAT/EPT predicts a positive a_e under CODATA
example : 0 < predict_aE_leading codataInputs :=
  codata_aE_positive

-- CAT/EPT predicts a positive a_μ under CODATA
example : 0 < predict_aMu_leading codataInputs :=
  predict_aMu_leading_positive codataInputs

-- CAT/EPT Schwinger universality under CODATA: a_e = a_μ at leading order
example : predict_aE_leading codataInputs = predict_aMu_leading codataInputs :=
  leading_order_aE_eq_aMu codataInputs

-- CODATA a_e prediction equals α/(2π) exactly (by formula)
example :
    predict_aE_leading codataInputs =
      codataInputs.alpha / (2 * Real.pi) :=
  predict_aE_leading_eq_schwinger codataInputs

/-! ### Structural checks on the Lean-intrinsic provider -/

-- Same theorems work without any CODATA values, just a single positive α
example (α : ℝ) (ha : 0 < α) :
    0 < predict_aE_leading (leanIntrinsicInputs α ha) :=
  leanIntrinsic_aE_positive α ha

example (α : ℝ) (ha : 0 < α) :
    predict_aE_leading (leanIntrinsicInputs α ha) =
      α / (2 * Real.pi) :=
  predict_aE_leading_eq_schwinger (leanIntrinsicInputs α ha)

-- The Lean-intrinsic provider picks α as input and sets all other
-- quantities to natural-unit constants. Schwinger universality holds here too.
example (α : ℝ) (ha : 0 < α) :
    predict_aE_leading (leanIntrinsicInputs α ha) =
      predict_aMu_leading (leanIntrinsicInputs α ha) :=
  leading_order_aE_eq_aMu _

/-! ### Dyson-resummed predictions -/

-- Under CODATA, for any |C_tot| < 1 the Dyson-resummed a_μ stays positive
example {C_tot : ℝ} (hC : C_tot < 1) :
    0 < predict_aMu_resummed codataInputs C_tot :=
  predict_aMu_resummed_positive codataInputs hC

-- Decoupled limit C_tot = 0: resummed reduces to Schwinger
example : predict_aMu_resummed codataInputs 0 = predict_aMu_leading codataInputs :=
  resummed_at_zero_eq_leading codataInputs

/-! ### Tolerance-based comparison (formal) -/

-- When a Lean-intrinsic prediction equals a reference value exactly, it's
-- within any non-negative relative tolerance
example (α : ℝ) (ha : 0 < α) (ε : ℝ) (hε : 0 ≤ ε) :
    within_rel (α / (2 * Real.pi))
               (predict_aE_leading (leanIntrinsicInputs α ha))
               ε :=
  within_rel_of_eq _ _ (predict_aE_leading_eq_schwinger _) ε hε

-- Same under CODATA
example (ε : ℝ) (hε : 0 ≤ ε) :
    within_rel (codataInputs.alpha / (2 * Real.pi))
               (predict_aE_leading codataInputs)
               ε :=
  within_rel_of_eq _ _ (predict_aE_leading_eq_schwinger _) ε hε

end CATEPT.Examples

/-! ### Numerical evaluations

Uncomment to see the actual numerical predictions:

```
#eval CATEPT.Numerics.reportElectronAnomaly
#eval CATEPT.Numerics.reportMuonAnomaly
#eval CATEPT.Numerics.codataLeadingOrderReports
```
-/
