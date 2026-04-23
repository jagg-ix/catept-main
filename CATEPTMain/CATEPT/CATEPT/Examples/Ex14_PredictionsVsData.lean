import CATEPTMain.CATEPT.CATEPT.CATEPTPredictions

set_option autoImplicit false

/-!
# Example 14: CAT/EPT Predictions — CODATA vs Lean-Intrinsic

## What makes this unique to CAT/EPT

CAT/EPT's predictions are formulas, not tables. The framework gives
structural rules (Schwinger α/(2π), Landauer k_BT ln 2, trefoil
k_B ln(crossings), …) that can be evaluated against ANY input source:

- **CODATA 2018**: industry-standard reference table
- **Lean-intrinsic**: pure Mathlib arithmetic, no external data

This example demonstrates both modes. The same theorem body works
with either provider, showing that CAT/EPT's predictive content is
independent of where the numerical inputs come from.

## How to use this

If you want to compare CAT/EPT against real-world measurements:
```
#eval predict_aE_leading codataInputs
```

If you want to verify CAT/EPT structure without depending on CODATA:
```
example (α : ℝ) (ha : 0 < α) :
    predict_aE_leading (leanIntrinsicInputs α ha) = α / (2 * Real.pi) := ...
```

## Key results

1. Both providers produce positive leading-order a_e predictions
2. Both providers satisfy Schwinger universality (a_e = a_μ at LO)
3. CAT/EPT Dyson resummation reduces to Schwinger in decoupled limit
4. Same tolerance framework applies to both providers
-/

noncomputable section

namespace CATEPT.Examples

open CATEPT

/-! ### Mode A: CODATA-anchored predictions -/

-- CODATA-anchored a_e prediction is positive
example : 0 < predict_aE_leading codataInputs :=
  codata_aE_positive

-- CODATA-anchored Landauer prediction is positive
example : 0 < predict_landauer codataInputs :=
  predict_landauer_positive codataInputs

-- CODATA-anchored electron/muon mass ratio is positive
example : 0 < predict_electron_muon_mass_ratio codataInputs :=
  predict_electron_muon_mass_ratio_positive codataInputs

/-! ### Mode B: Lean-intrinsic predictions (no CODATA) -/

-- With ONLY an abstract positive α, we still get a positive a_e
example (α : ℝ) (ha : 0 < α) :
    0 < predict_aE_leading (leanIntrinsicInputs α ha) :=
  leanIntrinsic_aE_positive α ha

-- Lean-intrinsic Landauer cost is positive (uses only Real.log 2 and k_B=1, T=1)
example (α : ℝ) (ha : 0 < α) :
    0 < predict_landauer (leanIntrinsicInputs α ha) :=
  predict_landauer_positive (leanIntrinsicInputs α ha)

-- Lean-intrinsic trefoil S_I contribution is non-negative for ≥1 crossings
example (α : ℝ) (ha : 0 < α) {c : ℝ} (hc : 1 ≤ c) :
    0 ≤ predict_trefoil_S_I (leanIntrinsicInputs α ha) c :=
  predict_trefoil_S_I_nonneg (leanIntrinsicInputs α ha) hc

/-! ### Provider-independence theorems -/

-- Leading a_e equals α/(2π) under ANY provider
example (inp : PredictionInputs) :
    predict_aE_leading inp = inp.alpha / (2 * Real.pi) :=
  predict_aE_leading_eq_schwinger inp

-- a_e and a_μ agree at leading order regardless of provider
example (inp : PredictionInputs) :
    predict_aE_leading inp = predict_aMu_leading inp :=
  leading_order_aE_eq_aMu inp

-- In particular, this holds for BOTH CODATA and Lean-intrinsic
example (α : ℝ) (ha : 0 < α) :
    predict_aE_leading (leanIntrinsicInputs α ha) =
      predict_aMu_leading (leanIntrinsicInputs α ha)
    ∧
    predict_aE_leading codataInputs =
      predict_aMu_leading codataInputs :=
  both_providers_aE_eq_aMu_leading α ha

/-! ### Dyson resummation structure -/

-- In the decoupled limit C_tot = 0, resummed a_μ = leading a_μ
example (inp : PredictionInputs) :
    predict_aMu_resummed inp 0 = predict_aMu_leading inp :=
  resummed_at_zero_eq_leading inp

-- Under CODATA, with small sector correction, a_μ stays positive
example {C_tot : ℝ} (hC : C_tot < 1) :
    0 < predict_aMu_resummed codataInputs C_tot :=
  predict_aMu_resummed_positive codataInputs hC

-- Same structure holds under Lean-intrinsic provider
example (α : ℝ) (ha : 0 < α) {C_tot : ℝ} (hC : C_tot < 1) :
    0 < predict_aMu_resummed (leanIntrinsicInputs α ha) C_tot :=
  predict_aMu_resummed_positive (leanIntrinsicInputs α ha) hC

/-! ### Tolerance framework -/

-- A prediction is trivially within any non-negative tolerance of itself
example (ref ε : ℝ) (hε : 0 ≤ ε) : within_rel ref ref ε :=
  within_rel_self ref ε hε

-- Exact agreement → within any tolerance
example (ref pred : ℝ) (heq : pred = ref) (ε : ℝ) (hε : 0 ≤ ε) :
    within_rel ref pred ε :=
  within_rel_of_eq ref pred heq ε hε

end CATEPT.Examples
