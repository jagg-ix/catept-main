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
| NHQM        | Non-Hermitian Fermi-Dirac (Shen et al. 2024) | Phase 1 (NHQMPrelude + NHQMCATEPTBridge)                               |

See `CATEPTMain/*/WORKLOG.lean` for per-subsystem status and
`CATEPTMain/Integration/CATEPTSelfConsistency.lean` for cross-subsystem
physics identifications.
-/

-- ── Framework ─────────────────────────────────────────────────────────────────
import CATEPTMain.Core.Framework.AFPBridgeFramework

-- ── L2 time integral ──────────────────────────────────────────────────────────
import CATEPTMain.L2TimeIntegral

-- ── CBO: Complex Bounded Operators ───────────────────────────────────────────
import CATEPTMain.Quantum.CBO.Cblinfun_Code
import CATEPTMain.Quantum.CBO.Cblinfun_Code_Examples
import CATEPTMain.Quantum.CBO.Cblinfun_Matrix
import CATEPTMain.Quantum.CBO.Complex_Bounded_Linear_Function
import CATEPTMain.Quantum.CBO.Complex_Bounded_Linear_Function0
import CATEPTMain.Quantum.CBO.Complex_Euclidean_Space0
import CATEPTMain.Quantum.CBO.Complex_Inner_Product
import CATEPTMain.Quantum.CBO.Complex_Inner_Product0
import CATEPTMain.Quantum.CBO.Complex_L2
import CATEPTMain.Quantum.CBO.Complex_Vector_Spaces
import CATEPTMain.Quantum.CBO.Complex_Vector_Spaces0
import CATEPTMain.Quantum.CBO.Extra_General
import CATEPTMain.Quantum.CBO.Extra_Jordan_Normal_Form
import CATEPTMain.Quantum.CBO.Extra_Operator_Norm
import CATEPTMain.Quantum.CBO.Extra_Ordered_Fields
import CATEPTMain.Quantum.CBO.Extra_Pretty_Code_Examples
import CATEPTMain.Quantum.CBO.Extra_Vector_Spaces
import CATEPTMain.Quantum.CBO.One_Dimensional_Spaces

-- ── CPM: Coproduct Measure ────────────────────────────────────────────────────
import CATEPTMain.Analysis.CPM.Coproduct_Measure
import CATEPTMain.Analysis.CPM.Coproduct_Measure_Additional
import CATEPTMain.Analysis.CPM.Lemmas_Coproduct_Measure

-- ── FOU: Fourier Series ───────────────────────────────────────────────────────
import CATEPTMain.Analysis.FOU.Confine
import CATEPTMain.Analysis.FOU.Fourier
import CATEPTMain.Analysis.FOU.Fourier_Aux2
import CATEPTMain.Analysis.FOU.Lspace
import CATEPTMain.Analysis.FOU.Periodic
import CATEPTMain.Analysis.FOU.Square_Integrable

-- ── GYR: Gyrovector Spaces (Prelude only; Theories pending Phase 2) ───────────
import CATEPTMain.Geometry.GYR.GYRPrelude

-- ── HSTP: Hilbert Space Tensor Product ───────────────────────────────────────
import CATEPTMain.Quantum.HSTP.Compact_Operators
import CATEPTMain.Quantum.HSTP.Eigenvalues
import CATEPTMain.Quantum.HSTP.HS2Ell2
import CATEPTMain.Quantum.HSTP.Hilbert_Space_Tensor_Product
import CATEPTMain.Quantum.HSTP.Misc_TP
import CATEPTMain.Quantum.HSTP.Misc_TP_TTS
import CATEPTMain.Quantum.HSTP.Partial_Trace
import CATEPTMain.Quantum.HSTP.Positive_Operators
import CATEPTMain.Quantum.HSTP.Spectral_Theorem
import CATEPTMain.Quantum.HSTP.Strong_Operator_Topology
import CATEPTMain.Quantum.HSTP.Tensor_Product_Code
import CATEPTMain.Quantum.HSTP.Trace_Class
import CATEPTMain.Quantum.HSTP.Von_Neumann_Algebras
import CATEPTMain.Quantum.HSTP.Weak_Operator_Topology
import CATEPTMain.Quantum.HSTP.Weak_Star_Topology

-- ── IMD: Isabelle Markov Decision / Quantum Information ──────────────────────
import CATEPTMain.Quantum.IMD.Basics
import CATEPTMain.Quantum.IMD.Binary_Nat
import CATEPTMain.Quantum.IMD.Complex_Vectors
import CATEPTMain.Quantum.IMD.Deutsch
import CATEPTMain.Quantum.IMD.Deutsch_Jozsa
import CATEPTMain.Quantum.IMD.Entanglement
import CATEPTMain.Quantum.IMD.Measurement
import CATEPTMain.Quantum.IMD.More_Tensor
import CATEPTMain.Quantum.IMD.No_Cloning
import CATEPTMain.Quantum.IMD.Quantum
import CATEPTMain.Quantum.IMD.Quantum_Prisoners_Dilemma
import CATEPTMain.Quantum.IMD.Quantum_Teleportation
import CATEPTMain.Quantum.IMD.Tensor

-- ── LAPL: Laplace Transform ───────────────────────────────────────────────────
import CATEPTMain.Analysis.LAPL.Convolution_Theorem
import CATEPTMain.Analysis.LAPL.Inversion
import CATEPTMain.Analysis.LAPL.Laplace_Transform

-- ── LSI: Lebesgue–Stieltjes Integral ─────────────────────────────────────────
import CATEPTMain.Analysis.LSI.Lebesgue_Stieltjes_Integral
import CATEPTMain.Analysis.LSI.Preliminaries_LSI

-- ── MINK: Minkowski Theorem ───────────────────────────────────────────────────
import CATEPTMain.Geometry.MINK.Convex_Body
import CATEPTMain.Geometry.MINK.Lattice_Points
import CATEPTMain.Geometry.MINK.Minkowski_Main

-- ── MODE: Matrix ODEs ─────────────────────────────────────────────────────────
import CATEPTMain.Analysis.MODE.Affine_ODE
import CATEPTMain.Analysis.MODE.Matrix_Exp

-- ── MTN: Matrix Tensor / Kronecker Product ────────────────────────────────────
import CATEPTMain.Core.MTN.Eigenvalues_Kron
import CATEPTMain.Core.MTN.Kronecker_Product
import CATEPTMain.Core.MTN.Mixed_Product

-- ── NoFTL: No Faster-Than-Light Observers ────────────────────────────────────
-- Idiomatic port from AFP `No_FTL_observers_Gen_Rel` (Sulzbacher–Martins 2023).
-- Foundation: Sorts (arithmetic) → Points (spacetime geometry).
-- Remaining Isabelle theories (Norms, Vectors, Functions, …, NoFTLGR) will be
-- ported incrementally as real proofs; the previous auto-translated stubs
-- (all-sorry, wrong types) were removed 2026-04-19.
import CATEPTMain.Geometry.NoFTL.NoFTLPrelude
import CATEPTMain.Geometry.NoFTL.Sorts
import CATEPTMain.Geometry.NoFTL.Points
import CATEPTMain.Geometry.NoFTL.AxEField
import CATEPTMain.Geometry.NoFTL.WorldView
import CATEPTMain.Geometry.NoFTL.AxSelfMinus
import CATEPTMain.Geometry.NoFTL.AxEventMinus
import CATEPTMain.Geometry.NoFTL.Functions
import CATEPTMain.Geometry.NoFTL.Norms
import CATEPTMain.Geometry.NoFTL.WorldLine
import CATEPTMain.Geometry.NoFTL.Translations
import CATEPTMain.Geometry.NoFTL.Vectors
import CATEPTMain.Geometry.NoFTL.Matrices
import CATEPTMain.Geometry.NoFTL.AxTriangleInequality
import CATEPTMain.Geometry.NoFTL.TangentLines
import CATEPTMain.Geometry.NoFTL.CauchySchwarz
import CATEPTMain.Geometry.NoFTL.Quadratics
import CATEPTMain.Geometry.NoFTL.LinearMaps
import CATEPTMain.Geometry.NoFTL.ReverseCauchySchwarz
import CATEPTMain.Geometry.NoFTL.Cardinalities
import CATEPTMain.Geometry.NoFTL.AxLightMinus
import CATEPTMain.Geometry.NoFTL.Cones
import CATEPTMain.Geometry.NoFTL.Affine
import CATEPTMain.Geometry.NoFTL.AxDiff
import CATEPTMain.Geometry.NoFTL.Classification
import CATEPTMain.Geometry.NoFTL.Sublemma3
import CATEPTMain.Geometry.NoFTL.Sublemma4
import CATEPTMain.Geometry.NoFTL.MainLemma
import CATEPTMain.Geometry.NoFTL.TangentLineLemma
import CATEPTMain.Geometry.NoFTL.KeyLemma
import CATEPTMain.Geometry.NoFTL.AffineConeLemma
import CATEPTMain.Geometry.NoFTL.Proposition1
import CATEPTMain.Geometry.NoFTL.Proposition2
import CATEPTMain.Geometry.NoFTL.Proposition3
import CATEPTMain.Geometry.NoFTL.ObserverConeLemma
import CATEPTMain.Geometry.NoFTL.NoFTLGR

-- ── OCT: Octonions ────────────────────────────────────────────────────────────
import CATEPTMain.Geometry.OCT.Norm_Octonions
import CATEPTMain.Geometry.OCT.Octonion_Algebra

-- ── ODE: Ordinary Differential Equations ─────────────────────────────────────
import CATEPTMain.Analysis.ODE.Euler_Method
import CATEPTMain.Analysis.ODE.Flow
import CATEPTMain.Analysis.ODE.Picard_Lindelof

-- ── PDC: Probabilistic Directed Acyclic Graphs (Prelude only) ────────────────
import CATEPTMain.Core.PDC.PDCPrelude

-- ── PHQ: Physical Quantities (Prelude only) ───────────────────────────────────
import CATEPTMain.Core.PHQ.PHQPrelude

-- ── PM: Projective Measurements ──────────────────────────────────────────────
import CATEPTMain.Quantum.PM.CHSH_Inequality
import CATEPTMain.Quantum.PM.Linear_Algebra_Complements
import CATEPTMain.Quantum.PM.Projective_Measurements

-- ── QFT: QFT / Ising Model ───────────────────────────────────────────────────
import CATEPTMain.CATEPT.QFT.QFT

-- ── QUAT: Unit Quaternions ────────────────────────────────────────────────────
import CATEPTMain.Geometry.QUAT.Unit_Quaternions

-- ── SCHTZ: Schröder–Bernstein–Cantor (Prelude only) ──────────────────────────
import CATEPTMain.Quantum.SCHTZ.SCHTZPrelude

-- ── FEYNCALC: FeynCalc Dirac/Lorentz algebra port (Wolfram Mathematica → Lean 4) ──
import CATEPTMain.GaugeTheory.FEYNCALC.FeynCalcPort

-- ── ELECTROWEAK: Higgs mechanism, W/Z mass theorems (Mathematica → Lean 4) ───
import CATEPTMain.GaugeTheory.ELECTROWEAK.ElectroweakPort

-- ── QUANTUM: Density matrices, QFI, Cramér-Rao (lean4-quantum lift) ───────────
import CATEPTMain.Quantum.QUANTUM.QuantumPort

-- ── FBD: Fermion-Boson Duality, omega matrices, QED processes (Mathematica) ──
import CATEPTMain.GaugeTheory.FBD.FBDPort

-- ── LDO: LatticeDiracOperators.jl (lattice QCD fermion operators) ────────────
import CATEPTMain.GaugeTheory.LDO.LDOPort

-- ── QCD: Quantum Chromodynamics — SU(3) gauge theory (Phase 1) ───────────────
import CATEPTMain.GaugeTheory.QCD.QCDPort

-- ── CATEPT: Complex Action / Entropic Time framework (Phase 1) ───────────────
import CATEPTMain.CATEPT.CATEPT.CATEPTPort

-- ── EPT: Entropic Proper Time — NS BKM bounds (Phase 1) ──────────────────────
import CATEPTMain.CATEPT.EPT.EPTPort

-- ── NHQM: Non-Hermitian QM / Fermi-Dirac Persistent Current (Phase 1) ────────
import CATEPTMain.NHQM.NHQMPort

-- ── CATEPT Planck mode bridge (ex-TTT, merged into CATEPT) ───────────────────
import CATEPTMain.CATEPT.CATEPT.PlanckModeBridge

-- ── SM: Smooth Manifolds ──────────────────────────────────────────────────────
import CATEPTMain.Geometry.SM.Analysis_More
import CATEPTMain.Geometry.SM.Bump_Function
import CATEPTMain.Geometry.SM.Chart
import CATEPTMain.Geometry.SM.Cotangent_Space
import CATEPTMain.Geometry.SM.Differentiable_Manifold
import CATEPTMain.Geometry.SM.Partition_Of_Unity
import CATEPTMain.Geometry.SM.Product_Manifold
import CATEPTMain.Geometry.SM.Projective_Space
import CATEPTMain.Geometry.SM.Smooth
import CATEPTMain.Geometry.SM.Sphere
import CATEPTMain.Geometry.SM.Tangent_Space
import CATEPTMain.Geometry.SM.Topological_Manifold
