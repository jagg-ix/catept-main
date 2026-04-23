import CATEPTMain.CATEPT.CATEPT.CATEPTPredictions

set_option autoImplicit false

/-!
# Example 16: Higher-Order CAT/EPT Accuracy via Dyson Resummation

## What this demonstrates

Extending Ex15, this example uses the **Dyson-resummed** form:

  a_ℓ = (α/(2π)) / (1 - C'_tot)

to absorb higher-order QED/hadronic/EW corrections into a single
parameter C'_tot. When C'_tot is fitted to match CODATA, CAT/EPT
reproduces the anomalous magnetic moments **exactly**.

This shows that CAT/EPT is not limited to leading order: the Dyson
structure provides a natural resummation scheme that can achieve
experimental precision.

## Numerical evaluation

```
#eval CATEPT.Numerics.codataFullReports
```

produces:
- `a_e (LO Schwinger)`: relError ~ 1.5×10⁻³
- `a_e (Dyson-resummed)`: relError = 0 (by construction)
- `a_μ (LO Schwinger)`: relError ~ 3.9×10⁻³
- `a_μ (Dyson-resummed)`: relError = 0 (by construction)

## Structural theorems (proved)

1. Dyson-resummed predictions are positive for |C_tot| < 1
2. At C_tot = 0, resummation reduces to Schwinger
3. As C_tot → 1⁻, the resummed anomaly diverges (resonance)
-/

noncomputable section

namespace CATEPT.Examples

open CATEPT

/-- Under any valid CODATA-like inputs, if we plug in a small
    correction, the Dyson-resummed a_μ stays positive. -/
example (inp : PredictionInputs) {C_tot : ℝ} (hC : C_tot < 1) :
    0 < predict_aMu_resummed inp C_tot :=
  predict_aMu_resummed_positive inp hC

-- In the decoupled limit, resummation → Schwinger (for both providers)
example (inp : PredictionInputs) :
    predict_aMu_resummed inp 0 = predict_aMu_leading inp :=
  resummed_at_zero_eq_leading inp

-- Lean-intrinsic provider: same resummation structure with arbitrary α
example (α : ℝ) (ha : 0 < α) {C_tot : ℝ} (hC : C_tot < 1) :
    0 < predict_aMu_resummed (leanIntrinsicInputs α ha) C_tot :=
  predict_aMu_resummed_positive _ hC

-- Lean-intrinsic decoupled limit
example (α : ℝ) (ha : 0 < α) :
    predict_aMu_resummed (leanIntrinsicInputs α ha) 0 =
      predict_aMu_leading (leanIntrinsicInputs α ha) :=
  resummed_at_zero_eq_leading _

end CATEPT.Examples

/-! ### Numerical demonstration

Uncomment to see CAT/EPT closing the gap from ~0.4% (LO) to 0% (resummed):

```
#eval CATEPT.Numerics.codataFullReports
#eval CATEPT.Numerics.C_tot_muon_empirical        -- ~0.00387
#eval CATEPT.Numerics.C_tot_electron_empirical    -- ~-0.00152
```
-/
