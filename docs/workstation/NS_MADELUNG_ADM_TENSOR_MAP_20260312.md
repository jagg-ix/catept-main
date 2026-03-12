# NS Madelung Re-Evaluation + ADM Tensor Map (CAT/EPT, General + No-Gravity Profile)

## Scope
This note encodes the requested chain on top of the canonical NS CAT/EPT setting:

1. Complex Einstein mass channel
2. Complex Dirac effective mass
3. Madelung hydrodynamical reinterpretation
4. ADM 3+1 tensor mapping

All equations use the same CAT/EPT clock setting as
`docs/workstation/NS_MODULAR_FLOW_CAT_EPT_NO_G_CANONICAL.md`:

- entropic-time clock specialization `lambda = Omega/2`

Forcing treatment:
- general profile keeps forcing explicit and modular-split (`f = kappa_g/beta + f_res`)
- no-gravity remains an optional specialization (`kappa_g = 0`, `f_res = 0`)

No claim of Stage-64 closure is added.

## Status and Non-Overclaim Guards

This module is intentionally a **structural/scalarized bridge**, not a complete
constructive local-field derivation of 3D NS via a scalar Madelung wavefunction.

Canonical extractor scope in code:
- `rho = Omega(t)` (global observable proxy channel)
- `pressure = P(t)` (proxy scalar channel)
- `velocity = 0` (placeholder kinematic proxy)
- `quantumPotential = 0` (placeholder proxy)

Implication:
- The bridge is a theorem-backed dictionary layer (`D_I`, Dirac-mass sign,
  ADM source map), not a claim that generic vortical 3D NS is fully encoded by
  a single scalar Madelung field.

## 1) Complex Einstein Mass Channel (Scalarized Split)

Use the split form

```math
G_{\mathrm{re}} + i G_{\mathrm{im}} = \kappa\,(T_{\mathrm{re}} + i T_{\mathrm{im}}),
```

with the CAT/EPT identification

```math
T_{\mathrm{re}} = \rho, \qquad T_{\mathrm{im}} = D_I, \qquad
D_I := \nu P - VS.
```

In the canonical bridge implementation, this is represented with `kappa=1`, so
`G_re = rho` and `G_im = D_I` at the mapped state.

## 2) Complex Dirac Effective Mass

Define NS spinor phase-amplitude **proxy** data in Madelung form

```math
\psi_{NS} = \sqrt{\rho}\,e^{i\theta}, \qquad \dot\theta = \lambda = \rho/2,
```

and effective Dirac mass

```math
m_D = \frac{D_I}{\rho} \quad (\rho>0).
```

Then the key sign equivalence is

```math
m_D \ge 0 \iff D_I \ge 0 \iff VS \le \nu P.
```

So the non-tachyonic Dirac sector is exactly the same bottleneck condition.

## 3) Madelung Hydrodynamics in CAT/EPT

General forced NS in entropic-time form is

```math
\lambda\,\partial_{\tau_{ent}} u + (u\cdot\nabla)u = -\nabla\pi + \nu\Delta u + f,
\qquad \nabla\cdot u = 0.
```

No-gravity profile is recovered by setting `f=0`.

Re-evaluated through the complex Einstein/Dirac channels, the isotropic proxy shift
entering the hydrodynamical stress is

```math
p_{\mathrm{iso}} = p + Q + D_I,
```

where `Q` is the Madelung/Bohm quantum-potential proxy channel and `D_I` is the
CAT/EPT defect channel.

## 4) ADM 3+1 Tensor Mapping

Using spatial indices `i,j \in {1,2,3}`, map Madelung proxy state
`(rho, u_i, p, Q, D_I)` into ADM matter sources:

```math
\rho_{ADM} = \rho,
\qquad
j_i = \rho\,u_i,
\qquad
S_{ij} = \rho\,u_i u_j + (p + Q + D_I)\,\delta_{ij}.
```

Interpretation:
- `rho_ADM` is the energy-density channel (canonical NS bridge uses `rho=Omega`).
- `j_i` is momentum density.
- `S_ij` carries kinetic anisotropy plus isotropic CAT/EPT proxy shift.
- Off-diagonal terms are purely kinetic (`delta_ij = 0` for `i != j`).
- Diagonal terms include the full isotropic shift (`p+Q+D_I`).

## 5) Lean Anchors

Implemented in:

- `lean4_formal_verification/NavierStokes/NavierStokes/Bridges/NSMadelungADMTensorBridge.lean`
- Thin re-export:
  - `lean4_formal_verification/NavierStokes/NavierStokes/NSMadelungADMTensorBridge.lean`

Key theorem/def anchors:
- `madelungFromNSTrajectory`
- `diracMassFromMadelung`
- `dirac_mass_nonneg_iff_vs_le_nuP`
- `complexEinsteinMassFromMadelung`
- `admMatterFromMadelung`
- `adm_stress_offdiag_formula`
- `adm_stress_diag_formula`
- `nsTrajectoryToADMMatter`
- `madelung_adm_tensor_contract`

Build target verified:

```bash
cd lean4_formal_verification/NavierStokes
lake build NavierStokes.Bridges.NSMadelungADMTensorBridge NavierStokes.NSMadelungADMTensorBridge
```
