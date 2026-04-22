/-!
# CAT/EPT Examples — What Makes It Unique

These 10 examples showcase the distinctive features of the Complex
Action Theory / Entropic Proper Time (CAT/EPT) framework. Each file
is self-contained with literate documentation explaining the physics,
followed by formally verified Lean 4 statements.

## Narrative arc

**Foundation (Ex01-03)**: The complex action S = S_R + iS_I, entropic
time τ_ent = S_I/ℏ, and the Feynman-Kac damping ‖w‖ ≤ 1.

**Surprising consequences (Ex04-06)**: Tsirelson bound from entropic
rate, Pauli no-go bypassed, and three independent time constructions
(relational, thermal, entropic) unified.

**Quantum gravity (Ex07-08)**: Wheeler-DeWitt frozen formalism resolved
by entropic flow, Bekenstein-Hawking entropy as entropic time budget.

**Information bounds (Ex09-10)**: Landauer's principle from S_I, UV
convergence from coercivity — no renormalization needed.

**Experimental predictions (Ex11-12)**: Muon g-2 correction from
entropic backreaction, trefoil knot topology as source of topological
information and generation structure.

**Unification (Ex13)**: Five independent routes to S_I ≥ 0 — influence
functional, electromagnetism, topology, gravity, thermodynamics — all
producing the same damping ≤ 1 and τ_ent ≥ 0.

## Quick start

```
import CATEPTMain.CATEPT.Examples.Ex01_ComplexAction    -- S_I ≥ 0 (theorem!)
import CATEPTMain.CATEPT.Examples.Ex02_EntropicTime     -- τ_ent = S_I/ℏ
import CATEPTMain.CATEPT.Examples.Ex03_FeynmanKacDamping -- ‖w‖ ≤ 1
import CATEPTMain.CATEPT.Examples.Ex04_TsirelsonFromEntropy
import CATEPTMain.CATEPT.Examples.Ex05_PauliNoGoBypassed
import CATEPTMain.CATEPT.Examples.Ex06_ModularFlowTripleClock
import CATEPTMain.CATEPT.Examples.Ex07_WheelerDeWittConstraint
import CATEPTMain.CATEPT.Examples.Ex08_BekensteinHawking
import CATEPTMain.CATEPT.Examples.Ex09_LandauerBound
import CATEPTMain.CATEPT.Examples.Ex10_UVConvergence
import CATEPTMain.CATEPT.Examples.Ex11_MuonGMinus2
import CATEPTMain.CATEPT.Examples.Ex12_TrefoilTopology
import CATEPTMain.CATEPT.Examples.Ex13_FrameworkUnification
import CATEPTMain.CATEPT.Examples.Ex14_PredictionsVsData
import CATEPTMain.CATEPT.Examples.Ex15_AccuracyCheck
import CATEPTMain.CATEPT.Examples.Ex16_HigherOrderAccuracy
import CATEPTMain.CATEPT.Examples.Ex17_DecoherencePredictions
import CATEPTMain.CATEPT.Examples.Ex18_LeptonHierarchy
import CATEPTMain.CATEPT.Examples.Ex19_ClassicalGravity
import CATEPTMain.CATEPT.Examples.Ex20_CatsimIntegration
import CATEPTMain.CATEPT.Examples.Ex21_ComplexEFEAndCoupler
```

## What each example demonstrates

| # | Title | Key Punchline |
|---|-------|---------------|
| 01 | Complex Action | S_I ≥ 0 is a theorem from the influence functional |
| 02 | Entropic Time | Time emerges from information loss, not a clock |
| 03 | FK Damping | Path integral is UV-finite via damping |
| 04 | Tsirelson | Quantum non-locality has a thermodynamic origin |
| 05 | Pauli No-Go | Entropic time is scalar, bypasses the obstruction |
| 06 | Triple Clock | Relational = thermal = entropic time |
| 07 | Wheeler-DeWitt | Frozen formalism dissolved by entropic flow |
| 08 | Black Holes | BH entropy is an entropic time budget |
| 09 | Landauer | Information erasure cost from S_I |
| 10 | UV Convergence | Coercivity → finiteness, no renormalization |
| 11 | Muon g-2 | Entropic backreaction corrects anomalous magnetic moment |
| 12 | Trefoil Topology | Knot crossings → topological S_I → generation structure |
| 13 | Framework Unification | Five routes to S_I ≥ 0 — one framework |
| 14 | Predictions vs Data | CODATA-anchored vs Lean-intrinsic prediction providers |
| 15 | Accuracy Check | Numerical CAT/EPT LO predictions vs CODATA a_e, a_μ |
| 16 | Higher-Order Accuracy | Dyson resummation closes the residual experimental gap |
| 17 | Decoherence Predictions | Same rate formula predicts transmon qubit T2 bounds |
| 18 | Lepton Hierarchy | Trefoil topology predicts tau mass from (e, μ) fit |
| 19 | Classical Gravity | CAT/EPT matches GR (Mercury perihelion) and SR (γ factor) in S_I → 0 limit |
| 20 | Catsim Integration | Integral τ_ent unification, Schwarzschild observers, double-slit paper result |
| 21 | Complex EFE + Coupler | G+iΛ = κ(T+iS) and λ_eff = λ_base·√(-g₀₀)·(1+g·r), plus FEYNCALC sandwich identities |
-/
