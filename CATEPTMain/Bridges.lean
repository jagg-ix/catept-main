/-
# Bridges — Root aggregator for all AFP ↔ Lean 4 bridge subsystems

Imports every AFP bridge subsystem that has been ported to Lean 4.29 in this
repo.  Subsystem layout:

## Restructuring plan

This file and the flattened bridge tree are documented in:
  CATEPTMain/RESTRUCTURE_WORKLOG.lean    (master orchestration)
  CATEPTMain/PHASE1_FLATTEN_WORKLOG.lean (remove Theories/ layer)
  CATEPTMain/PHASE2_STUBS_WORKLOG.lean   (consolidate stub modules)
  CATEPTMain/PHASE3_THEMATIC_WORKLOG.lean (thematic regrouping)
See RS-MASTER-001 before making any file moves.

## Subsystem layout

| Code  | AFP Entry (Isabelle)                  | Status   |
|-------|---------------------------------------|----------|
| CBO   | Complex_Bounded_Operators             | Phase 1  |
| CPM   | Coproduct_Measure                     | Phase 1  |
| FOU   | Fourier_Series                        | Phase 1  |
| GYR   | GyrovectorSpaces                      | Phase 1 (Prelude only) |
| HSTP  | Hilbert_Space_Tensor_Product          | Phase 1  |
| IMD   | Isabelle_Markov_Decision_Processes    | Phase 1  |
| LAPL  | Laplace_Transform                     | Phase 1  |
| LSI   | Lebesgue_Stieltjes_Integral           | Phase 1  |
| MINK  | Minkowski_Theorem                     | Phase 1  |
| MODE  | Ordinary_Differential_Equations       | Phase 1  |
| MTN   | Matrix_Tensor                         | Phase 1  |
| NoFTL | No_FTL_observers_Gen_Rel              | Phase 1  |
| OCT   | Octonions                             | Phase 1  |
| ODE   | Ordinary_Differential_Equations       | Phase 1  |
| PDC   | Probabilistic_Directed_Acyclic_Graphs | Phase 1 (Prelude only) |
| PHQ   | Physical_Quantities                   | Phase 1 (Prelude only) |
| PM    | Projective_Measurements               | Phase 1  |
| QFT   | QFT_Ising_Model                       | Phase 1  |
| QUAT  | Quaternions                           | Phase 1  |
| SCHTZ | Schroder_Bernstein_Cantor             | Phase 1 (Prelude only) |
| SM    | Smooth_Manifolds                      | Phase 1  |
| FEYNCALC    | FeynCalc (Wolfram Mathematica → Lean 4)      | Phase 1 (Prelude + DiracAlgebra + DiracTrace + LorentzAlgebra) |
| ELECTROWEAK | ElectroweakInteraction_HiggsMechanism (Mathematica) | Phase 1 (EWPrelude + HiggsMechanism; EW-1..EW-5 proved) |
| QUANTUM     | lean4-quantum lift + QFI-Toolbox scaffold    | Phase 1 (QuantumPrelude + QuantumGates + DensityMatrix + QFIScaffold + JordanWigner + QFIToolbox + PhysicsHamiltonians + QFIMeasurements) |
| FBD         | FermionBosonDuality_QFT (Mathematica)        | Phase 1 (FBDPrelude + OmegaMatrices + QEDProcesses + WeakProcesses) |
| CATEPT      | Complex Action / Entropic Time framework     | Phase 1 (CATEPTPrelude + FeynmanKacBridge + ModularFlowBridge)       |
| EPT         | Entropic Proper Time — NS/BKM bounds         | Phase 1 (EPTPrelude: decay rate, CI, τ_bound, BKM axioms)            |
| CALCULUS    | lean4-mlir Tensor/VJP framework              | Phase 1 (Differentiation + Normalization + Attention)                  |
| NHQM        | Non-Hermitian Fermi-Dirac (Shen et al. 2024) | Phase 1 (NHQMPrelude + NHQMCATEPTBridge)                               |

See `CATEPTMain/*/WORKLOG.lean` for per-subsystem status and
`CATEPTMain/Integration/CATEPTSelfConsistency.lean` for cross-subsystem
physics identifications.
-/

-- ── Framework ─────────────────────────────────────────────────────────────────
import CATEPTMain.Framework.AFPBridgeFramework

-- ── L2 time integral ──────────────────────────────────────────────────────────
import CATEPTMain.L2TimeIntegral

-- ── CALCULUS: lean4-mlir Tensor/VJP framework port ───────────────────────────
import CATEPTMain.CALCULUS.Differentiation
import CATEPTMain.CALCULUS.Normalization
import CATEPTMain.CALCULUS.Attention

-- ── CBO: Complex Bounded Operators ───────────────────────────────────────────
import CATEPTMain.CBO.Cblinfun_Code
import CATEPTMain.CBO.Cblinfun_Code_Examples
import CATEPTMain.CBO.Cblinfun_Matrix
import CATEPTMain.CBO.Complex_Bounded_Linear_Function
import CATEPTMain.CBO.Complex_Bounded_Linear_Function0
import CATEPTMain.CBO.Complex_Euclidean_Space0
import CATEPTMain.CBO.Complex_Inner_Product
import CATEPTMain.CBO.Complex_Inner_Product0
import CATEPTMain.CBO.Complex_L2
import CATEPTMain.CBO.Complex_Vector_Spaces
import CATEPTMain.CBO.Complex_Vector_Spaces0
import CATEPTMain.CBO.Extra_General
import CATEPTMain.CBO.Extra_Jordan_Normal_Form
import CATEPTMain.CBO.Extra_Operator_Norm
import CATEPTMain.CBO.Extra_Ordered_Fields
import CATEPTMain.CBO.Extra_Pretty_Code_Examples
import CATEPTMain.CBO.Extra_Vector_Spaces
import CATEPTMain.CBO.One_Dimensional_Spaces

-- ── CPM: Coproduct Measure ────────────────────────────────────────────────────
import CATEPTMain.CPM.Coproduct_Measure
import CATEPTMain.CPM.Coproduct_Measure_Additional
import CATEPTMain.CPM.Lemmas_Coproduct_Measure

-- ── FOU: Fourier Series ───────────────────────────────────────────────────────
import CATEPTMain.FOU.Confine
import CATEPTMain.FOU.Fourier
import CATEPTMain.FOU.Fourier_Aux2
import CATEPTMain.FOU.Lspace
import CATEPTMain.FOU.Periodic
import CATEPTMain.FOU.Square_Integrable

-- ── GYR: Gyrovector Spaces (Prelude only; Theories pending Phase 2) ───────────
import CATEPTMain.GYR.GYRPrelude

-- ── HSTP: Hilbert Space Tensor Product ───────────────────────────────────────
import CATEPTMain.HSTP.Compact_Operators
import CATEPTMain.HSTP.Eigenvalues
import CATEPTMain.HSTP.HS2Ell2
import CATEPTMain.HSTP.Hilbert_Space_Tensor_Product
import CATEPTMain.HSTP.Misc_TP
import CATEPTMain.HSTP.Misc_TP_TTS
import CATEPTMain.HSTP.Partial_Trace
import CATEPTMain.HSTP.Positive_Operators
import CATEPTMain.HSTP.Spectral_Theorem
import CATEPTMain.HSTP.Strong_Operator_Topology
import CATEPTMain.HSTP.Tensor_Product_Code
import CATEPTMain.HSTP.Trace_Class
import CATEPTMain.HSTP.Von_Neumann_Algebras
import CATEPTMain.HSTP.Weak_Operator_Topology
import CATEPTMain.HSTP.Weak_Star_Topology

-- ── IMD: Isabelle Markov Decision / Quantum Information ──────────────────────
import CATEPTMain.IMD.Basics
import CATEPTMain.IMD.Binary_Nat
import CATEPTMain.IMD.Complex_Vectors
import CATEPTMain.IMD.Deutsch
import CATEPTMain.IMD.Deutsch_Jozsa
import CATEPTMain.IMD.Entanglement
import CATEPTMain.IMD.Measurement
import CATEPTMain.IMD.More_Tensor
import CATEPTMain.IMD.No_Cloning
import CATEPTMain.IMD.Quantum
import CATEPTMain.IMD.Quantum_Prisoners_Dilemma
import CATEPTMain.IMD.Quantum_Teleportation
import CATEPTMain.IMD.Tensor

-- ── LAPL: Laplace Transform ───────────────────────────────────────────────────
import CATEPTMain.LAPL.Convolution_Theorem
import CATEPTMain.LAPL.Inversion
import CATEPTMain.LAPL.Laplace_Transform

-- ── LSI: Lebesgue–Stieltjes Integral ─────────────────────────────────────────
import CATEPTMain.LSI.Lebesgue_Stieltjes_Integral
import CATEPTMain.LSI.Preliminaries_LSI

-- ── MINK: Minkowski Theorem ───────────────────────────────────────────────────
import CATEPTMain.MINK.Convex_Body
import CATEPTMain.MINK.Lattice_Points
import CATEPTMain.MINK.Minkowski_Main

-- ── MODE: Matrix ODEs ─────────────────────────────────────────────────────────
import CATEPTMain.MODE.Affine_ODE
import CATEPTMain.MODE.Matrix_Exp

-- ── MTN: Matrix Tensor / Kronecker Product ────────────────────────────────────
import CATEPTMain.MTN.Eigenvalues_Kron
import CATEPTMain.MTN.Kronecker_Product
import CATEPTMain.MTN.Mixed_Product

-- ── NoFTL: No Faster-Than-Light Observers ────────────────────────────────────
-- Idiomatic port from AFP `No_FTL_observers_Gen_Rel` (Sulzbacher–Martins 2023).
-- Foundation: Sorts (arithmetic) → Points (spacetime geometry).
-- Remaining Isabelle theories (Norms, Vectors, Functions, …, NoFTLGR) will be
-- ported incrementally as real proofs; the previous auto-translated stubs
-- (all-sorry, wrong types) were removed 2026-04-19.
import CATEPTMain.NoFTL.NoFTLPrelude
import CATEPTMain.NoFTL.Sorts
import CATEPTMain.NoFTL.Points
import CATEPTMain.NoFTL.AxEField
import CATEPTMain.NoFTL.WorldView
import CATEPTMain.NoFTL.AxSelfMinus
import CATEPTMain.NoFTL.AxEventMinus
import CATEPTMain.NoFTL.Functions
import CATEPTMain.NoFTL.Norms
import CATEPTMain.NoFTL.WorldLine
import CATEPTMain.NoFTL.Translations
import CATEPTMain.NoFTL.Vectors
import CATEPTMain.NoFTL.Matrices
import CATEPTMain.NoFTL.AxTriangleInequality
import CATEPTMain.NoFTL.TangentLines
import CATEPTMain.NoFTL.CauchySchwarz
import CATEPTMain.NoFTL.Quadratics
import CATEPTMain.NoFTL.LinearMaps
import CATEPTMain.NoFTL.ReverseCauchySchwarz
import CATEPTMain.NoFTL.Cardinalities
import CATEPTMain.NoFTL.AxLightMinus
import CATEPTMain.NoFTL.Cones
import CATEPTMain.NoFTL.Affine
import CATEPTMain.NoFTL.AxDiff
import CATEPTMain.NoFTL.Classification
import CATEPTMain.NoFTL.Sublemma3
import CATEPTMain.NoFTL.Sublemma4
import CATEPTMain.NoFTL.MainLemma
import CATEPTMain.NoFTL.TangentLineLemma
import CATEPTMain.NoFTL.KeyLemma
import CATEPTMain.NoFTL.AffineConeLemma
import CATEPTMain.NoFTL.Proposition1
import CATEPTMain.NoFTL.Proposition2
import CATEPTMain.NoFTL.Proposition3
import CATEPTMain.NoFTL.ObserverConeLemma
import CATEPTMain.NoFTL.NoFTLGR

-- ── OCT: Octonions ────────────────────────────────────────────────────────────
import CATEPTMain.OCT.Norm_Octonions
import CATEPTMain.OCT.Octonion_Algebra

-- ── ODE: Ordinary Differential Equations ─────────────────────────────────────
import CATEPTMain.ODE.Euler_Method
import CATEPTMain.ODE.Flow
import CATEPTMain.ODE.Picard_Lindelof

-- ── PDC: Probabilistic Directed Acyclic Graphs (Prelude only) ────────────────
import CATEPTMain.PDC.PDCPrelude

-- ── PHQ: Physical Quantities (Prelude only) ───────────────────────────────────
import CATEPTMain.PHQ.PHQPrelude

-- ── PM: Projective Measurements ──────────────────────────────────────────────
import CATEPTMain.PM.CHSH_Inequality
import CATEPTMain.PM.Linear_Algebra_Complements
import CATEPTMain.PM.Projective_Measurements

-- ── QFT: QFT / Ising Model ───────────────────────────────────────────────────
import CATEPTMain.QFT.QFT

-- ── QUAT: Unit Quaternions ────────────────────────────────────────────────────
import CATEPTMain.QUAT.Unit_Quaternions

-- ── SCHTZ: Schröder–Bernstein–Cantor (Prelude only) ──────────────────────────
import CATEPTMain.SCHTZ.SCHTZPrelude

-- ── FEYNCALC: FeynCalc Dirac/Lorentz algebra port (Wolfram Mathematica → Lean 4) ──
import CATEPTMain.FEYNCALC.FeynCalcPort

-- ── ELECTROWEAK: Higgs mechanism, W/Z mass theorems (Mathematica → Lean 4) ───
import CATEPTMain.ELECTROWEAK.ElectroweakPort

-- ── QUANTUM: Density matrices, QFI, Cramér-Rao (lean4-quantum lift) ───────────
import CATEPTMain.QUANTUM.QuantumPort

-- ── FBD: Fermion-Boson Duality, omega matrices, QED processes (Mathematica) ──
import CATEPTMain.FBD.FBDPort

-- ── LDO: LatticeDiracOperators.jl (lattice QCD fermion operators) ────────────
import CATEPTMain.LDO.LDOPort

-- ── QCD: Quantum Chromodynamics — SU(3) gauge theory (Phase 1) ───────────────
import CATEPTMain.QCD.QCDPort

-- ── CATEPT: Complex Action / Entropic Time framework (Phase 1) ───────────────
import CATEPTMain.CATEPT.CATEPTPort

-- ── EPT: Entropic Proper Time — NS BKM bounds (Phase 1) ──────────────────────
import CATEPTMain.EPT.EPTPort

-- ── NHQM: Non-Hermitian QM / Fermi-Dirac Persistent Current (Phase 1) ────────
import CATEPTMain.NHQM.NHQMPort

-- ── CATEPT Planck mode bridge (ex-TTT, merged into CATEPT) ───────────────────
import CATEPTMain.CATEPT.PlanckModeBridge

-- ── SM: Smooth Manifolds ──────────────────────────────────────────────────────
import CATEPTMain.SM.Analysis_More
import CATEPTMain.SM.Bump_Function
import CATEPTMain.SM.Chart
import CATEPTMain.SM.Cotangent_Space
import CATEPTMain.SM.Differentiable_Manifold
import CATEPTMain.SM.Partition_Of_Unity
import CATEPTMain.SM.Product_Manifold
import CATEPTMain.SM.Projective_Space
import CATEPTMain.SM.Smooth
import CATEPTMain.SM.Sphere
import CATEPTMain.SM.Tangent_Space
import CATEPTMain.SM.Topological_Manifold
