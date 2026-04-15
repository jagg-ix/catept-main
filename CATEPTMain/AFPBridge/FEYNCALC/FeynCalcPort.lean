/-
# FeynCalc Port — Root Module

Aggregates all Phase-1 FeynCalc → Lean 4 translation modules.

Import this file to get the full Dirac+Lorentz algebraic scaffold.

## Module hierarchy

```
FeynCalcPort
├── FCPrelude          (carrier types, eta, leviCivita, gamma)
├── DiracAlgebra       (anti-commutation, γ^5, chiral projectors)
├── DiracTrace         (trace formulas TR-0..TR-9)
└── LorentzAlgebra     (metric contractions, ε-ε identity, p·q)
```

## Usage

```lean
import CATEPTMain.AFPBridge.FEYNCALC.FeynCalcPort
open CATEPTMain.AFPBridge.FEYNCALC

-- Anti-commutation:
#check gamma_anticommute           -- γ^μ γ^ν + γ^ν γ^μ = 2g^μν
-- Trace of two gammas:
#check spinorTrace_two             -- Tr(γ^μ γ^ν) = 4 g^μν
-- Trace of four gammas:
#check spinorTrace_four            -- Tr(γ^μ γ^ν γ^ρ γ^σ) = 4(...)
-- Trace recursion:
#check spinorTrace_recursion_two   -- Hahn Trace4 expansion
-- Lorentz contraction:
#check eta_contraction             -- Σ_ν g^μν g^νρ = δ^μρ
-- Momentum product:
#check lorentzProduct_self         -- p·p = (p⁰)²-(p¹)²-(p²)²-(p³)²
-- Dirac slash squared:
#check pSlash_sq                   -- p̸² = p·p · 1₄
```
-/

import CATEPTMain.AFPBridge.FEYNCALC.FCPrelude
import CATEPTMain.AFPBridge.FEYNCALC.DiracAlgebra
import CATEPTMain.AFPBridge.FEYNCALC.DiracTrace
import CATEPTMain.AFPBridge.FEYNCALC.LorentzAlgebra
