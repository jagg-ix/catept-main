/-
# LDO Port — Root Module

Aggregates all Phase-1 LatticeDiracOperators.jl → Lean 4 translation modules.

Import this file to get the full lattice QCD fermion operator scaffold:
carrier types, Wilson/Staggered/DW/Möbius operators, CG solvers,
fermion actions, and RHMC rational approximation.

## Module hierarchy

```
LDOPort
├── LDOPrelude              (FermionField, GaugeField, DiracOp, BCs, flat-index ops)
├── AbstractFermions        (adjoint, inner product, staggering phase, 5D slices)
├── WilsonFermion           (Wilson Dirac, rPlusGamma, γ5-Hermiticity, clover)
├── StaggeredFermion        (KS staggered, anti-Hermitian hopping, checkerboard)
├── DomainwallFermion       (5D D5DW kernel, J/P operators, full DW preconditioned)
├── MobiusDomainwallFermion (Möbius kernel D5DW_b,c, Shamir/Borici limits)
├── CGMethods               (BiCG, CG, BiCGStab, shifted CG, residual convergence)
├── FermiAction             (S_f pseudofermion, UdSfdU gauge force, Gaussian sampling)
└── RHMC                    (AlgRemez rational approx, fractional-flavour action)
```

## Usage

```lean
import CATEPTMain.LDO.LDOPort
open CATEPTMain.LDO

-- Staggering phase is ±1:
#check staggeringPhase_pm_one   -- staggeringPhase μ ix iy iz it = 1 ∨ = -1
-- DdagD positivity:
#check domainwallDdagD_nonneg   -- 0 ≤ normSq (D5DW ψ)[0]
-- Fermion action non-negative:
#check evalFermiAction_nonneg   -- 0 ≤ S_f[ϕ, U]
-- RHMC positivity (stub):
#check rhmcFermiAction_nonneg   -- 0 ≤ S_f[RHMC, ϕ, U]  (phase2_high)
-- CG convergence:
#check cg_converges_for_ddagd   -- 0 ≤ residualNorm (cgSolve D b ε k)
```
-/

import CATEPTMain.LDO.LDOPrelude
import CATEPTMain.LDO.AbstractFermions
import CATEPTMain.LDO.WilsonFermion
import CATEPTMain.LDO.StaggeredFermion
import CATEPTMain.LDO.DomainwallFermion
import CATEPTMain.LDO.MobiusDomainwallFermion
import CATEPTMain.LDO.CGMethods
import CATEPTMain.LDO.FermiAction
import CATEPTMain.LDO.RHMC
