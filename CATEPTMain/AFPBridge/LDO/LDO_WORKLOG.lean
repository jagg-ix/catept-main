/-!
# LatticeDiracOperators.jl → Lean 4 Translation Worklog

Source: LatticeDiracOperators.jl (Kei Suzuki et al., 2022–2024)
  https://github.com/akio-tomiya/LatticeDiracOperators.jl
Target: Lean 4 / CATEPTMain  (namespace CATEPTMain.AFPBridge.LDO)
        Lean 4.29 + Mathlib v4.29.0

## Context

LatticeDiracOperators.jl implements lattice QCD Dirac operators in Julia.
It is the fermion backend for LatticeQCD.jl / GeneralQCD.jl.

Key capabilities:
  - Wilson fermion (4D, 2D, wing/no-wing, MPI, GPU)
  - Staggered fermion (4D, 2D, wing/no-wing, MPI)
  - Domain wall fermion (5D, standard and Möbius)
  - Generalised domain wall fermion
  - Solvers: CG, BiCG, BiCGStab, GMRES, shifted CG (multi-mass)
  - Eigensolvers: LOBPCG, Sakurai-Sugiura
  - Fermion actions: Wilson, Staggered, Domainwall, Möbius
  - RHMC: rational approximation (AlgRemez) for fractional flavours

This port formalises the *mathematical substrate*: type hierarchies,
operator properties, algebraic identities, and convergence properties,
following the AFP→Lean4 bridge methodology established in CATEPTMain.

## Methodology

Follows AFPBridge Phase 1 methodology (as in FCPrelude, FCPrelude, LDOPrelude):
  - Opaque carrier types: FermionField, GaugeField, GaugeLink, DiracOp
  - `axiom` predicates for all operations and their basic properties
  - `sorry`-stubs for non-trivial mathematical theorems (tagged `-- phase2_high`)
  - Provable results proved outright (normSq_nonneg, staggeringPhase_sq, omega, etc.)

Phase 2 upgrade path:
  - FermionField NC NX NY NZ NT NG → Matrix (Fin (NC*NX*NY*NZ*NT*NG)) ℂ
  - GaugeLink NC → { M : Matrix (Fin NC)(Fin NC) ℂ // M.det = 1 ∧ M.IsUnitary }
  - DiracOp → LinearMap ℂ (FermionField ...) (FermionField ...)
  - Proofs via Mathlib.LinearAlgebra.Matrix, Mathlib.Analysis.InnerProductSpace

## File structure

| File                       | Content                                | Status   |
|----------------------------|----------------------------------------|----------|
| LDOPrelude.lean            | Carrier types, BCs, basic ops          | Phase 1  |
| AbstractFermions.lean      | Adjoint, inner product, staggering φ   | Phase 1  |
| WilsonFermion.lean         | Wilson Dirac, γ5-Hermiticity, clover   | Phase 1  |
| StaggeredFermion.lean      | KS staggered operator, anti-Hermitian  | Phase 1  |
| DomainwallFermion.lean     | 5D DW kernel D5DW, J/P ops             | Phase 1  |
| MobiusDomainwallFermion.lean | Möbius kernel with (b,c) coefficients | Phase 1  |
| CGMethods.lean             | BiCG, CG, BiCGStab, shifted CG         | Phase 1  |
| FermiAction.lean           | S_f, UdSfdU, sampling                  | Phase 1  |
| RHMC.lean                  | Rational approx, AlgRemez coeffs       | Phase 1  |
| LDO_WORKLOG.lean           | This file                              | —        |

## Source file audit (75 Julia files → 9 Lean 4 files)

### LDOPrelude.lean
  ✓ AbstractFermions.jl            — FermionField types, getindex, axpby, dot
  ✓ AbstractFermions_4D.jl         — get_latticeindex_fermion, 4D decode
  ✓ AbstractFermion_MPILattice.jl  — MPI halo structure (NDW, wing offset)
  ✓ Diracoperators.jl              — DiracOp, DdagDOp, Gamma5DOp types
  ✓ LatticeDiracOperators.jl       — top-level module (namespace only)

### AbstractFermions.lean
  ✓ AbstractFermions.jl            — adjoint_fermionfields, sigma_munu, verbosity
  ✓ AbstractFermions_2D.jl         — 2D indexing (subsumed by LDOPrelude types)
  ✓ AbstractFermions_3D.jl         — 3D indexing (subsumed by LDOPrelude types)
  ✓ AbstractFermions_4D.jl         — decodeLatticeIdx, staggeringPhase
  ✓ AbstractFermions_5D.jl         — 5D slice get/set, FermionField5D
  ✓ AbstractFermion_MPILattice.jl  — physicalVolume, totalVolume, halo_offset

### WilsonFermion.lean
  ✓ WilsonFermion/WilsonFermion.jl                   — Wilson_Dirac_operator struct
  ✓ WilsonFermion/WilsonFermion_4D.jl                — Dx!, Ddagx!, Tx!, Toex!, calc_beff!
  ✓ WilsonFermion/WilsonFermion_4D_wing.jl           — WilsonFermion_4D_wing{NC,NDW}
  ✓ WilsonFermion/WilsonFermion_4D_wing_Adjoint.jl   — adjoint application
  ✓ WilsonFermion/WilsonFermion_4D_nowing.jl         — no-halo variant (subsumed)
  ✓ WilsonFermion/WilsonFermion_4D_nowing_mpi.jl     — MPI no-halo (subsumed)
  ✓ WilsonFermion/WilsonFermion_4D_wing_mpi.jl       — MPI wing (subsumed)
  ✓ WilsonFermion/WilsonFermion_faster.jl            — fused kernel (subsumed)
  ✓ WilsonFermion/WilsonFermion_improved.jl          — Sheikholeslami-Wohlert
  ✓ WilsonFermion/WilsoncloverFermion.jl             — D_clover = D_W + c_SW/4·σF
  ✓ WilsonFermion/WilsonFermion_2D.jl                — 2D operator (wilsonDx2D)
  ✓ WilsonFermion/WilsonFermion_2D_wing.jl           — 2D wing (subsumed)
  ✓ WilsonFermion/WilsonFermion_4D_wing_fast.jl      — fast variant (subsumed)
  ✓ WilsonFermion/WilsontypeFermion.jl               — WilsonTypeDirac abstract
  ✓ WilsonFermion/mpi_jacc/linearalgebra_4D.jl       — MPI linear algebra (subsumed)
  ✓ WilsonFermion/mpi_jacc/WilsonFermion_4D_MPILattice.jl — MPI lattice (subsumed)
  ✓ WilsonFermion/WilsonFermion_4D_accelerator.jl    — GPU variant (subsumed)
  ✓ WilsonFermion/kernelfunctions/cudakernel_wilson.jl — CUDA kernel (subsumed)
  ✓ WilsonFermion/kernelfunctions/kernel_wilson.jl   — generic kernel (subsumed)
  ✓ WilsonFermion/kernelfunctions/jacckernel_wilson.jl — JACC kernel (subsumed)
  ✓ WilsonFermion/kernelfunctions/linearalgebra_mul.jl — linalg mul (subsumed)
  ✓ WilsonFermion/kernelfunctions/linearalgebra_mul_jacc.jl — JACC linalg (subsumed)
  ✓ WilsonFermion/kernelfunctions/Wilson_jacc.jl     — JACC Wilson (subsumed)
  ✓ WilsonFermion/kernelfunctions/Wilson_cuda.jl     — CUDA Wilson (subsumed)
  ✓ WilsonFermion/kernelfunctions/linearalgebra_mul_cuda.jl — CUDA linalg (subsumed)

### StaggeredFermion.lean
  ✓ StaggeredFermion/StaggeredFermion.jl             — Staggered_Dirac_operator struct
  ✓ StaggeredFermion/StaggeredFermion_4D_wing.jl     — Dx!, staggered_U, wing ops
  ✓ StaggeredFermion/StaggeredFermion_4D_nowing.jl   — no-halo variant (subsumed)
  ✓ StaggeredFermion/StaggeredFermion_2D_wing.jl     — 2D variant (staggeredDx2D)
  ✓ StaggeredFermion/StaggeredFermion_2D_nowing.jl   — 2D no-halo (subsumed)
  ✓ StaggeredFermion/StaggeredFermion_4D_nowing_mpi.jl — MPI (subsumed)
  ✓ StaggeredFermion/StaggeredFermion_4D_wing_mpi.jl   — MPI wing (subsumed)
  □ StaggeredFermion/notused/ (3 files)               — not in active codebase; skip

### DomainwallFermion.lean
  ✓ DomainwallFermion/DomainwallFermion.jl           — D5DW, Domainwall_Dirac operators
  ✓ DomainwallFermion/DomainwallFermion_5d.jl        — D5DWx!, D5DWdagx!, apply_J/P/R
  ✓ DomainwallFermion/DomainwallFermion_5d_wing.jl   — concrete 5D_wing struct
  ✓ DomainwallFermion/DomainwallFermion_3d_wing.jl   — 3D variant (subsumed)
  ✓ DomainwallFermion/DomainwallFermion_5d_mpi.jl    — MPI (subsumed)
  ✓ DomainwallFermion/DomainwallFermion_5d_wing_mpi.jl — MPI wing (subsumed)

### MobiusDomainwallFermion.lean
  ✓ MobiusDomainwallFermion/MobiusDomainwallFermion.jl    — D5DW_Möbius operator
  ✓ MobiusDomainwallFermion/MobiusDomainwallFermion_5d.jl — 5D Möbius kernel
  ✓ MobiusDomainwallFermion/MobiusDomainwallFermion_5d_MPILattice.jl — MPI (subsumed)
  ✓ MobiusDomainwallFermion/linearalgebra_5D.jl           — 5D lin alg (subsumed)

### CGMethods.lean
  ✓ cgmethods.jl               — bicg, bicgstab, cg, shiftedcg, solve_DinvX!
  ✓ cg/cgs.jl                  — CGS variant (subsumed by bicgSolve)

### FermiAction.lean
  ✓ action/FermiAction.jl                      — FermiAction abstract interface
  ✓ action/WilsonFermiAction.jl                — Wilson + clover action + force
  ✓ action/StaggeredFermiAction.jl             — staggered action (subsumed)
  ✓ action/DomainwallFermiAction.jl            — DW action (subsumed)
  ✓ action/MobiusDomainwallFermiAction.jl      — Möbius action (subsumed)
  ✓ action/GeneralizedDomainwallFermiAction.jl — generalised DW (subsumed)
  ✓ action/WilsontypeFermiAction.jl            — Wilson-type shared logic (subsumed)
  ✓ action/GeneralFermionAction.jl             — general action (subsumed)
  ✓ action/GeneralWilsonFermiAction.jl         — general Wilson (subsumed)
  ✓ action/clover_data.jl                      — clover field strength data (subsumed)

### RHMC.lean
  ✓ rhmc/rhmc.jl       — rational approx application + precomputed coefficients
  ✓ rhmc/AlgRemez.jl   — Remez algorithm for minimax rational approximation

### Not ported (deferred to Phase 2 or out of scope)
  □ LOBPCG/lobpcg.jl             — LOBPCG eigensolver (deferred: Mathlib.Analysis.Eigenvalue)
  □ SakuraiSugiura/SakuraiSugiuramethod.jl — SS method (deferred: complex contour)
  □ SakuraiSugiura/SSmodule.jl   — SS module (deferred)
  □ GeneralizedDomainwallFermion/GeneralizedDomainwallFermion.jl (deferred)
  □ GeneralizedDomainwallFermion/GeneralizedDomainwallFermion_5d.jl (deferred)
  □ GeneralFermion/misc/generalDiracoperators.jl (deferred)
  □ GeneralFermion/generalFermion.jl (deferred)

## Phase 1 record table (axiom surface + sorry budget)

| Record  | Statement                                      | File                     | Status       |
|---------|------------------------------------------------|--------------------------|--------------|
| LDO-001 | FermionField opaque type                       | LDOPrelude               | —            |
| LDO-002 | GaugeLink opaque type                          | LDOPrelude               | —            |
| LDO-003 | axpby_fermion axiom                            | LDOPrelude               | —            |
| LDO-004 | dotFermion axiom                               | LDOPrelude               | —            |
| LDO-005 | normSqFermion def (= dotFermion.re)            | LDOPrelude               | **proved**   |
| LDO-006 | applyDdagD def (= applyDiracAdj ∘ applyDirac) | LDOPrelude               | **proved**   |
| LDO-007 | default_bc_4D def                              | LDOPrelude               | **proved**   |
| LDO-008 | decodeLatticeIdx (0-indexed decode)            | AbstractFermions         | **proved**   |
| LDO-009 | staggeringPhase def                            | AbstractFermions         | **proved**   |
| LDO-010 | staggeringPhase_pm_one                         | AbstractFermions         | **proved**   |
| LDO-011 | staggeringPhase_sq = 1                         | AbstractFermions         | **proved**   |
| LDO-012 | halo_offset_correct (by omega)                 | AbstractFermions         | **proved**   |
| LDO-013 | adjointFermion_invol                           | AbstractFermions         | sorry (p2h)  |
| LDO-014 | normSq_nonneg axiom                            | AbstractFermions         | —            |
| LDO-015 | normSq_zero_iff axiom                          | AbstractFermions         | —            |
| LDO-016 | WilsonParams struct                            | WilsonFermion            | —            |
| LDO-017 | wilsonKappaFromM def                           | WilsonFermion            | **proved**   |
| LDO-018 | rPlusGamma_adjoint_eq_rMinus axiom             | WilsonFermion            | — (p2h)      |
| LDO-019 | wilsonD_eq_one_minus_T axiom                   | WilsonFermion            | —            |
| LDO-020 | wilson_gamma5_hermiticity                      | WilsonFermion            | sorry (p2h)  |
| LDO-021 | wilsonDdagD_nonneg                             | WilsonFermion            | **proved**   |
| LDO-022 | siteParity def                                 | WilsonFermion            | **proved**   |
| LDO-023 | wilsonCloverDx noncomputable def               | WilsonFermion            | **proved**   |
| LDO-024 | applyGamma5_sq axiom                           | WilsonFermion            | —            |
| LDO-025 | StaggeredParams struct                         | StaggeredFermion         | —            |
| LDO-026 | staggeredFullDx def (= m·ψ + Dx·ψ)            | StaggeredFermion         | **proved**   |
| LDO-027 | staggeredDx_antiHermitian axiom                | StaggeredFermion         | — (p2h)      |
| LDO-028 | staggeredDdagD_nonneg                          | StaggeredFermion         | **proved**   |
| LDO-029 | staggeredSpectrum_paired                       | StaggeredFermion         | **proved**   |
| LDO-030 | DomainwallParams struct                        | DomainwallFermion        | —            |
| LDO-031 | domainwallKappa def                            | DomainwallFermion        | **proved**   |
| LDO-032 | d5dwDdagDx noncomputable def                   | DomainwallFermion        | **proved**   |
| LDO-033 | d5dw_gamma5_hermiticity                        | DomainwallFermion        | sorry (p2h)  |
| LDO-034 | applyReflectionJ_sq axiom                      | DomainwallFermion        | — (p2h)      |
| LDO-035 | applyPermutationP_unitary axiom                | DomainwallFermion        | — (p2h)      |
| LDO-036 | domainwallDdagD_nonneg                         | DomainwallFermion        | **proved**   |
| LDO-037 | MobiusDWParams struct                          | MobiusDomainwallFermion  | —            |
| LDO-038 | mobiusDWDdagDx noncomputable def               | MobiusDomainwallFermion  | **proved**   |
| LDO-039 | mobiusDW_gamma5_hermiticity                    | MobiusDomainwallFermion  | sorry (p2h)  |
| LDO-040 | mobiusDWDdagD_nonneg                           | MobiusDomainwallFermion  | **proved**   |
| LDO-041 | residualNorm def                               | CGMethods                | **proved**   |
| LDO-042 | bicgSolve_residual axiom                       | CGMethods                | — (p2h)      |
| LDO-043 | cgSolve_monotone axiom                         | CGMethods                | — (p2h)      |
| LDO-044 | shiftedCG_solves axiom                         | CGMethods                | — (p2h)      |
| LDO-045 | solveDinvX_approx                              | CGMethods                | **proved**   |
| LDO-046 | cg_converges_for_ddagd                         | CGMethods                | **proved**   |
| LDO-047 | evalFermiAction_nonneg axiom                   | FermiAction              | —            |
| LDO-048 | samplePseudoFermion_correct axiom              | FermiAction              | — (p2h)      |
| LDO-049 | calcUdSfdU_antihermitian axiom                 | FermiAction              | — (p2h)      |
| LDO-050 | gaussSamplingNorm                              | FermiAction              | **proved**   |
| LDO-051 | AlgRemezCoeffs struct                          | RHMC                     | —            |
| LDO-052 | applyRHMCRational_normNonneg                   | RHMC                     | **proved**   |
| LDO-053 | rhmcRational_posOnPSD                          | RHMC                     | sorry (p2h)  |
| LDO-054 | rhmcFermiAction_nonneg                         | RHMC                     | sorry (p2h)  |
| LDO-055 | rhmcCoeffs_12_nPoles axiom (= 10)              | RHMC                     | —            |
| LDO-056 | rhmcCoeffs_14_nPoles axiom (= 15)              | RHMC                     | —            |

## Phase 1 sorry budget (as of 2026-04-15, Phase 1.0)

Total declarations:     ~120 (axioms + defs + theorems across 9 files)
Total `sorry` stubs:      7  (LDO-013, 020, 033, 039, 053, 054; see table)
Total `axiom` entries:   ~55
Theorems fully proved:   ~30 (normSq_nonneg, staggeringPhase_*, omega, etc.)

Build target: `lake build` on all 9 LDO files (Phase 1 compile-safe).
Phase-2 target: sorry budget ≤ 3 (resolve via Mathlib matrix+CliffordAlgebra).

## Phase 2 priorities

  1. adjointFermion_invol (LDO-013): adjoint_conj + Complex.conj_conj + funext + ext
  2. wilson_gamma5_hermiticity (LDO-020): matrix transpose of rPlusGamma + unitarity U
  3. d5dw_gamma5_hermiticity (LDO-033): induction on 5D slices from LDO-020
  4. mobiusDW_gamma5_hermiticity (LDO-039): from LDO-033 + b,c linearity
  5. rhmcRational_posOnPSD (LDO-053): positive-definite shifted inverse + sum
  6. rhmcFermiAction_nonneg (LDO-054): from LDO-053 + bilinear form positivity
-/

-- This file is documentation only; no Lean declarations needed.
#check True
