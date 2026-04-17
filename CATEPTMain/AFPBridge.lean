/-
# AFPBridge — Root aggregator for all AFP ↔ Lean 4 bridge subsystems

Imports every AFP bridge subsystem that has been ported to Lean 4.29 in this
repo.  Subsystem layout:

## Restructuring plan

This file and the AFPBridge/ directory tree are subject to a flattening and
thematic-regrouping plan documented in:
  CATEPTMain/AFPBridge/RESTRUCTURE_WORKLOG.lean    (master orchestration)
  CATEPTMain/AFPBridge/PHASE1_FLATTEN_WORKLOG.lean (remove Theories/ layer)
  CATEPTMain/AFPBridge/PHASE2_STUBS_WORKLOG.lean   (consolidate stub modules)
  CATEPTMain/AFPBridge/PHASE3_THEMATIC_WORKLOG.lean (thematic regrouping)
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

See `CATEPTMain/AFPBridge/*/WORKLOG.lean` for per-subsystem status and
`CATEPTMain/Integration/CATEPTSelfConsistency.lean` for cross-subsystem
physics identifications.
-/

-- ── Framework ─────────────────────────────────────────────────────────────────
import CATEPTMain.AFPBridge.Framework.AFPBridgeFramework

-- ── L2 time integral ──────────────────────────────────────────────────────────
import CATEPTMain.AFPBridge.L2TimeIntegral

-- ── CBO: Complex Bounded Operators ───────────────────────────────────────────
import CATEPTMain.AFPBridge.CBO.Cblinfun_Code
import CATEPTMain.AFPBridge.CBO.Cblinfun_Code_Examples
import CATEPTMain.AFPBridge.CBO.Cblinfun_Matrix
import CATEPTMain.AFPBridge.CBO.Complex_Bounded_Linear_Function
import CATEPTMain.AFPBridge.CBO.Complex_Bounded_Linear_Function0
import CATEPTMain.AFPBridge.CBO.Complex_Euclidean_Space0
import CATEPTMain.AFPBridge.CBO.Complex_Inner_Product
import CATEPTMain.AFPBridge.CBO.Complex_Inner_Product0
import CATEPTMain.AFPBridge.CBO.Complex_L2
import CATEPTMain.AFPBridge.CBO.Complex_Vector_Spaces
import CATEPTMain.AFPBridge.CBO.Complex_Vector_Spaces0
import CATEPTMain.AFPBridge.CBO.Extra_General
import CATEPTMain.AFPBridge.CBO.Extra_Jordan_Normal_Form
import CATEPTMain.AFPBridge.CBO.Extra_Operator_Norm
import CATEPTMain.AFPBridge.CBO.Extra_Ordered_Fields
import CATEPTMain.AFPBridge.CBO.Extra_Pretty_Code_Examples
import CATEPTMain.AFPBridge.CBO.Extra_Vector_Spaces
import CATEPTMain.AFPBridge.CBO.One_Dimensional_Spaces

-- ── CPM: Coproduct Measure ────────────────────────────────────────────────────
import CATEPTMain.AFPBridge.CPM.Coproduct_Measure
import CATEPTMain.AFPBridge.CPM.Coproduct_Measure_Additional
import CATEPTMain.AFPBridge.CPM.Lemmas_Coproduct_Measure

-- ── FOU: Fourier Series ───────────────────────────────────────────────────────
import CATEPTMain.AFPBridge.FOU.Confine
import CATEPTMain.AFPBridge.FOU.Fourier
import CATEPTMain.AFPBridge.FOU.Fourier_Aux2
import CATEPTMain.AFPBridge.FOU.Lspace
import CATEPTMain.AFPBridge.FOU.Periodic
import CATEPTMain.AFPBridge.FOU.Square_Integrable

-- ── GYR: Gyrovector Spaces (Prelude only; Theories pending Phase 2) ───────────
import CATEPTMain.AFPBridge.GYR.GYRPrelude

-- ── HSTP: Hilbert Space Tensor Product ───────────────────────────────────────
import CATEPTMain.AFPBridge.HSTP.Compact_Operators
import CATEPTMain.AFPBridge.HSTP.Eigenvalues
import CATEPTMain.AFPBridge.HSTP.HS2Ell2
import CATEPTMain.AFPBridge.HSTP.Hilbert_Space_Tensor_Product
import CATEPTMain.AFPBridge.HSTP.Misc_TP
import CATEPTMain.AFPBridge.HSTP.Misc_TP_TTS
import CATEPTMain.AFPBridge.HSTP.Partial_Trace
import CATEPTMain.AFPBridge.HSTP.Positive_Operators
import CATEPTMain.AFPBridge.HSTP.Spectral_Theorem
import CATEPTMain.AFPBridge.HSTP.Strong_Operator_Topology
import CATEPTMain.AFPBridge.HSTP.Tensor_Product_Code
import CATEPTMain.AFPBridge.HSTP.Trace_Class
import CATEPTMain.AFPBridge.HSTP.Von_Neumann_Algebras
import CATEPTMain.AFPBridge.HSTP.Weak_Operator_Topology
import CATEPTMain.AFPBridge.HSTP.Weak_Star_Topology

-- ── IMD: Isabelle Markov Decision / Quantum Information ──────────────────────
import CATEPTMain.AFPBridge.IMD.Basics
import CATEPTMain.AFPBridge.IMD.Binary_Nat
import CATEPTMain.AFPBridge.IMD.Complex_Vectors
import CATEPTMain.AFPBridge.IMD.Deutsch
import CATEPTMain.AFPBridge.IMD.Deutsch_Jozsa
import CATEPTMain.AFPBridge.IMD.Entanglement
import CATEPTMain.AFPBridge.IMD.Measurement
import CATEPTMain.AFPBridge.IMD.More_Tensor
import CATEPTMain.AFPBridge.IMD.No_Cloning
import CATEPTMain.AFPBridge.IMD.Quantum
import CATEPTMain.AFPBridge.IMD.Quantum_Prisoners_Dilemma
import CATEPTMain.AFPBridge.IMD.Quantum_Teleportation
import CATEPTMain.AFPBridge.IMD.Tensor

-- ── LAPL: Laplace Transform ───────────────────────────────────────────────────
import CATEPTMain.AFPBridge.LAPL.Convolution_Theorem
import CATEPTMain.AFPBridge.LAPL.Inversion
import CATEPTMain.AFPBridge.LAPL.Laplace_Transform

-- ── LSI: Lebesgue–Stieltjes Integral ─────────────────────────────────────────
import CATEPTMain.AFPBridge.LSI.Lebesgue_Stieltjes_Integral
import CATEPTMain.AFPBridge.LSI.Preliminaries_LSI

-- ── MINK: Minkowski Theorem ───────────────────────────────────────────────────
import CATEPTMain.AFPBridge.MINK.Convex_Body
import CATEPTMain.AFPBridge.MINK.Lattice_Points
import CATEPTMain.AFPBridge.MINK.Minkowski_Main

-- ── MODE: Matrix ODEs ─────────────────────────────────────────────────────────
import CATEPTMain.AFPBridge.MODE.Affine_ODE
import CATEPTMain.AFPBridge.MODE.Matrix_Exp

-- ── MTN: Matrix Tensor / Kronecker Product ────────────────────────────────────
import CATEPTMain.AFPBridge.MTN.Eigenvalues_Kron
import CATEPTMain.AFPBridge.MTN.Kronecker_Product
import CATEPTMain.AFPBridge.MTN.Mixed_Product

-- ── NoFTL: No Faster-Than-Light Observers ────────────────────────────────────
import CATEPTMain.AFPBridge.NoFTL.Affine
import CATEPTMain.AFPBridge.NoFTL.AffineConeLemma
import CATEPTMain.AFPBridge.NoFTL.Cardinalities
import CATEPTMain.AFPBridge.NoFTL.CauchySchwarz
import CATEPTMain.AFPBridge.NoFTL.Classification
import CATEPTMain.AFPBridge.NoFTL.Functions
import CATEPTMain.AFPBridge.NoFTL.KeyLemma
import CATEPTMain.AFPBridge.NoFTL.LinearMaps
import CATEPTMain.AFPBridge.NoFTL.MainLemma
import CATEPTMain.AFPBridge.NoFTL.NoFTLGR
import CATEPTMain.AFPBridge.NoFTL.Norms
import CATEPTMain.AFPBridge.NoFTL.ObserverConeLemma
import CATEPTMain.AFPBridge.NoFTL.Points
import CATEPTMain.AFPBridge.NoFTL.Proposition1
import CATEPTMain.AFPBridge.NoFTL.Proposition2
import CATEPTMain.AFPBridge.NoFTL.Proposition3
import CATEPTMain.AFPBridge.NoFTL.Quadratics
import CATEPTMain.AFPBridge.NoFTL.ReverseCauchySchwarz
import CATEPTMain.AFPBridge.NoFTL.Sorts
import CATEPTMain.AFPBridge.NoFTL.Sublemma3
import CATEPTMain.AFPBridge.NoFTL.Sublemma4
import CATEPTMain.AFPBridge.NoFTL.TangentLineLemma
import CATEPTMain.AFPBridge.NoFTL.TangentLines
import CATEPTMain.AFPBridge.NoFTL.Translations
import CATEPTMain.AFPBridge.NoFTL.Vectors
import CATEPTMain.AFPBridge.NoFTL.WorldLine

-- ── OCT: Octonions ────────────────────────────────────────────────────────────
import CATEPTMain.AFPBridge.OCT.Norm_Octonions
import CATEPTMain.AFPBridge.OCT.Octonion_Algebra

-- ── ODE: Ordinary Differential Equations ─────────────────────────────────────
import CATEPTMain.AFPBridge.ODE.Euler_Method
import CATEPTMain.AFPBridge.ODE.Flow
import CATEPTMain.AFPBridge.ODE.Picard_Lindelof

-- ── PDC: Probabilistic Directed Acyclic Graphs (Prelude only) ────────────────
import CATEPTMain.AFPBridge.PDC.PDCPrelude

-- ── PHQ: Physical Quantities (Prelude only) ───────────────────────────────────
import CATEPTMain.AFPBridge.PHQ.PHQPrelude

-- ── PM: Projective Measurements ──────────────────────────────────────────────
import CATEPTMain.AFPBridge.PM.CHSH_Inequality
import CATEPTMain.AFPBridge.PM.Linear_Algebra_Complements
import CATEPTMain.AFPBridge.PM.Projective_Measurements

-- ── QFT: QFT / Ising Model ───────────────────────────────────────────────────
import CATEPTMain.AFPBridge.QFT.QFT

-- ── QUAT: Unit Quaternions ────────────────────────────────────────────────────
import CATEPTMain.AFPBridge.QUAT.Unit_Quaternions

-- ── SCHTZ: Schröder–Bernstein–Cantor (Prelude only) ──────────────────────────
import CATEPTMain.AFPBridge.SCHTZ.SCHTZPrelude

-- ── FEYNCALC: FeynCalc Dirac/Lorentz algebra port (Wolfram Mathematica → Lean 4) ──
import CATEPTMain.AFPBridge.FEYNCALC.FeynCalcPort

-- ── ELECTROWEAK: Higgs mechanism, W/Z mass theorems (Mathematica → Lean 4) ───
import CATEPTMain.AFPBridge.ELECTROWEAK.ElectroweakPort

-- ── QUANTUM: Density matrices, QFI, Cramér-Rao (lean4-quantum lift) ───────────
import CATEPTMain.AFPBridge.QUANTUM.QuantumPort

-- ── FBD: Fermion-Boson Duality, omega matrices, QED processes (Mathematica) ──
import CATEPTMain.AFPBridge.FBD.FBDPort

-- ── LDO: LatticeDiracOperators.jl (lattice QCD fermion operators) ────────────
import CATEPTMain.AFPBridge.LDO.LDOPort

-- ── QCD: Quantum Chromodynamics — SU(3) gauge theory (Phase 1) ───────────────
import CATEPTMain.AFPBridge.QCD.QCDPort

-- ── CATEPT: Complex Action / Entropic Time framework (Phase 1) ───────────────
import CATEPTMain.AFPBridge.CATEPT.CATEPTPort

-- ── EPT: Entropic Proper Time — NS BKM bounds (Phase 1) ──────────────────────
import CATEPTMain.AFPBridge.EPT.EPTPort

-- ── SM: Smooth Manifolds ──────────────────────────────────────────────────────
import CATEPTMain.AFPBridge.SM.Analysis_More
import CATEPTMain.AFPBridge.SM.Bump_Function
import CATEPTMain.AFPBridge.SM.Chart
import CATEPTMain.AFPBridge.SM.Cotangent_Space
import CATEPTMain.AFPBridge.SM.Differentiable_Manifold
import CATEPTMain.AFPBridge.SM.Partition_Of_Unity
import CATEPTMain.AFPBridge.SM.Product_Manifold
import CATEPTMain.AFPBridge.SM.Projective_Space
import CATEPTMain.AFPBridge.SM.Smooth
import CATEPTMain.AFPBridge.SM.Sphere
import CATEPTMain.AFPBridge.SM.Tangent_Space
import CATEPTMain.AFPBridge.SM.Topological_Manifold
