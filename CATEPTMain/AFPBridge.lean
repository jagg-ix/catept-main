/-
# AFPBridge — Root aggregator for all AFP ↔ Lean 4 bridge subsystems

Imports every AFP bridge subsystem that has been ported to Lean 4.29 in this
repo.  Subsystem layout:

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

See `CATEPTMain/AFPBridge/*/WORKLOG.lean` for per-subsystem status and
`CATEPTMain/Integration/CATEPTSelfConsistency.lean` for cross-subsystem
physics identifications.
-/

-- ── Framework ─────────────────────────────────────────────────────────────────
import CATEPTMain.AFPBridge.Framework.AFPBridgeFramework

-- ── L2 time integral ──────────────────────────────────────────────────────────
import CATEPTMain.AFPBridge.L2TimeIntegral

-- ── CBO: Complex Bounded Operators ───────────────────────────────────────────
import CATEPTMain.AFPBridge.CBO.Theories.Cblinfun_Code
import CATEPTMain.AFPBridge.CBO.Theories.Cblinfun_Code_Examples
import CATEPTMain.AFPBridge.CBO.Theories.Cblinfun_Matrix
import CATEPTMain.AFPBridge.CBO.Theories.Complex_Bounded_Linear_Function
import CATEPTMain.AFPBridge.CBO.Theories.Complex_Bounded_Linear_Function0
import CATEPTMain.AFPBridge.CBO.Theories.Complex_Euclidean_Space0
import CATEPTMain.AFPBridge.CBO.Theories.Complex_Inner_Product
import CATEPTMain.AFPBridge.CBO.Theories.Complex_Inner_Product0
import CATEPTMain.AFPBridge.CBO.Theories.Complex_L2
import CATEPTMain.AFPBridge.CBO.Theories.Complex_Vector_Spaces
import CATEPTMain.AFPBridge.CBO.Theories.Complex_Vector_Spaces0
import CATEPTMain.AFPBridge.CBO.Theories.Extra_General
import CATEPTMain.AFPBridge.CBO.Theories.Extra_Jordan_Normal_Form
import CATEPTMain.AFPBridge.CBO.Theories.Extra_Operator_Norm
import CATEPTMain.AFPBridge.CBO.Theories.Extra_Ordered_Fields
import CATEPTMain.AFPBridge.CBO.Theories.Extra_Pretty_Code_Examples
import CATEPTMain.AFPBridge.CBO.Theories.Extra_Vector_Spaces
import CATEPTMain.AFPBridge.CBO.Theories.One_Dimensional_Spaces

-- ── CPM: Coproduct Measure ────────────────────────────────────────────────────
import CATEPTMain.AFPBridge.CPM.Theories.Coproduct_Measure
import CATEPTMain.AFPBridge.CPM.Theories.Coproduct_Measure_Additional
import CATEPTMain.AFPBridge.CPM.Theories.Lemmas_Coproduct_Measure

-- ── FOU: Fourier Series ───────────────────────────────────────────────────────
import CATEPTMain.AFPBridge.FOU.Theories.Confine
import CATEPTMain.AFPBridge.FOU.Theories.Fourier
import CATEPTMain.AFPBridge.FOU.Theories.Fourier_Aux2
import CATEPTMain.AFPBridge.FOU.Theories.Lspace
import CATEPTMain.AFPBridge.FOU.Theories.Periodic
import CATEPTMain.AFPBridge.FOU.Theories.Square_Integrable

-- ── GYR: Gyrovector Spaces (Prelude only; Theories pending Phase 2) ───────────
import CATEPTMain.AFPBridge.GYR.GYRPrelude

-- ── HSTP: Hilbert Space Tensor Product ───────────────────────────────────────
import CATEPTMain.AFPBridge.HSTP.Theories.Compact_Operators
import CATEPTMain.AFPBridge.HSTP.Theories.Eigenvalues
import CATEPTMain.AFPBridge.HSTP.Theories.HS2Ell2
import CATEPTMain.AFPBridge.HSTP.Theories.Hilbert_Space_Tensor_Product
import CATEPTMain.AFPBridge.HSTP.Theories.Misc_TP
import CATEPTMain.AFPBridge.HSTP.Theories.Misc_TP_TTS
import CATEPTMain.AFPBridge.HSTP.Theories.Partial_Trace
import CATEPTMain.AFPBridge.HSTP.Theories.Positive_Operators
import CATEPTMain.AFPBridge.HSTP.Theories.Spectral_Theorem
import CATEPTMain.AFPBridge.HSTP.Theories.Strong_Operator_Topology
import CATEPTMain.AFPBridge.HSTP.Theories.Tensor_Product_Code
import CATEPTMain.AFPBridge.HSTP.Theories.Trace_Class
import CATEPTMain.AFPBridge.HSTP.Theories.Von_Neumann_Algebras
import CATEPTMain.AFPBridge.HSTP.Theories.Weak_Operator_Topology
import CATEPTMain.AFPBridge.HSTP.Theories.Weak_Star_Topology

-- ── IMD: Isabelle Markov Decision / Quantum Information ──────────────────────
import CATEPTMain.AFPBridge.IMD.Theories.Basics
import CATEPTMain.AFPBridge.IMD.Theories.Binary_Nat
import CATEPTMain.AFPBridge.IMD.Theories.Complex_Vectors
import CATEPTMain.AFPBridge.IMD.Theories.Deutsch
import CATEPTMain.AFPBridge.IMD.Theories.Deutsch_Jozsa
import CATEPTMain.AFPBridge.IMD.Theories.Entanglement
import CATEPTMain.AFPBridge.IMD.Theories.Measurement
import CATEPTMain.AFPBridge.IMD.Theories.More_Tensor
import CATEPTMain.AFPBridge.IMD.Theories.No_Cloning
import CATEPTMain.AFPBridge.IMD.Theories.Quantum
import CATEPTMain.AFPBridge.IMD.Theories.Quantum_Prisoners_Dilemma
import CATEPTMain.AFPBridge.IMD.Theories.Quantum_Teleportation
import CATEPTMain.AFPBridge.IMD.Theories.Tensor

-- ── LAPL: Laplace Transform ───────────────────────────────────────────────────
import CATEPTMain.AFPBridge.LAPL.Theories.Convolution_Theorem
import CATEPTMain.AFPBridge.LAPL.Theories.Inversion
import CATEPTMain.AFPBridge.LAPL.Theories.Laplace_Transform

-- ── LSI: Lebesgue–Stieltjes Integral ─────────────────────────────────────────
import CATEPTMain.AFPBridge.LSI.Theories.Lebesgue_Stieltjes_Integral
import CATEPTMain.AFPBridge.LSI.Theories.Preliminaries_LSI

-- ── MINK: Minkowski Theorem ───────────────────────────────────────────────────
import CATEPTMain.AFPBridge.MINK.Theories.Convex_Body
import CATEPTMain.AFPBridge.MINK.Theories.Lattice_Points
import CATEPTMain.AFPBridge.MINK.Theories.Minkowski_Main

-- ── MODE: Matrix ODEs ─────────────────────────────────────────────────────────
import CATEPTMain.AFPBridge.MODE.Theories.Affine_ODE
import CATEPTMain.AFPBridge.MODE.Theories.Matrix_Exp

-- ── MTN: Matrix Tensor / Kronecker Product ────────────────────────────────────
import CATEPTMain.AFPBridge.MTN.Theories.Eigenvalues_Kron
import CATEPTMain.AFPBridge.MTN.Theories.Kronecker_Product
import CATEPTMain.AFPBridge.MTN.Theories.Mixed_Product

-- ── NoFTL: No Faster-Than-Light Observers ────────────────────────────────────
import CATEPTMain.AFPBridge.NoFTL.Theories.Affine
import CATEPTMain.AFPBridge.NoFTL.Theories.AffineConeLemma
import CATEPTMain.AFPBridge.NoFTL.Theories.Cardinalities
import CATEPTMain.AFPBridge.NoFTL.Theories.CauchySchwarz
import CATEPTMain.AFPBridge.NoFTL.Theories.Classification
import CATEPTMain.AFPBridge.NoFTL.Theories.Functions
import CATEPTMain.AFPBridge.NoFTL.Theories.KeyLemma
import CATEPTMain.AFPBridge.NoFTL.Theories.LinearMaps
import CATEPTMain.AFPBridge.NoFTL.Theories.MainLemma
import CATEPTMain.AFPBridge.NoFTL.Theories.NoFTLGR
import CATEPTMain.AFPBridge.NoFTL.Theories.Norms
import CATEPTMain.AFPBridge.NoFTL.Theories.ObserverConeLemma
import CATEPTMain.AFPBridge.NoFTL.Theories.Points
import CATEPTMain.AFPBridge.NoFTL.Theories.Proposition1
import CATEPTMain.AFPBridge.NoFTL.Theories.Proposition2
import CATEPTMain.AFPBridge.NoFTL.Theories.Proposition3
import CATEPTMain.AFPBridge.NoFTL.Theories.Quadratics
import CATEPTMain.AFPBridge.NoFTL.Theories.ReverseCauchySchwarz
import CATEPTMain.AFPBridge.NoFTL.Theories.Sorts
import CATEPTMain.AFPBridge.NoFTL.Theories.Sublemma3
import CATEPTMain.AFPBridge.NoFTL.Theories.Sublemma4
import CATEPTMain.AFPBridge.NoFTL.Theories.TangentLineLemma
import CATEPTMain.AFPBridge.NoFTL.Theories.TangentLines
import CATEPTMain.AFPBridge.NoFTL.Theories.Translations
import CATEPTMain.AFPBridge.NoFTL.Theories.Vectors
import CATEPTMain.AFPBridge.NoFTL.Theories.WorldLine

-- ── OCT: Octonions ────────────────────────────────────────────────────────────
import CATEPTMain.AFPBridge.OCT.Theories.Norm_Octonions
import CATEPTMain.AFPBridge.OCT.Theories.Octonion_Algebra

-- ── ODE: Ordinary Differential Equations ─────────────────────────────────────
import CATEPTMain.AFPBridge.ODE.Theories.Euler_Method
import CATEPTMain.AFPBridge.ODE.Theories.Flow
import CATEPTMain.AFPBridge.ODE.Theories.Picard_Lindelof

-- ── PDC: Probabilistic Directed Acyclic Graphs (Prelude only) ────────────────
import CATEPTMain.AFPBridge.PDC.PDCPrelude

-- ── PHQ: Physical Quantities (Prelude only) ───────────────────────────────────
import CATEPTMain.AFPBridge.PHQ.PHQPrelude

-- ── PM: Projective Measurements ──────────────────────────────────────────────
import CATEPTMain.AFPBridge.PM.Theories.CHSH_Inequality
import CATEPTMain.AFPBridge.PM.Theories.Linear_Algebra_Complements
import CATEPTMain.AFPBridge.PM.Theories.Projective_Measurements

-- ── QFT: QFT / Ising Model ───────────────────────────────────────────────────
import CATEPTMain.AFPBridge.QFT.Theories.QFT

-- ── QUAT: Unit Quaternions ────────────────────────────────────────────────────
import CATEPTMain.AFPBridge.QUAT.Theories.Unit_Quaternions

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

-- ── SM: Smooth Manifolds ──────────────────────────────────────────────────────
import CATEPTMain.AFPBridge.SM.Theories.Analysis_More
import CATEPTMain.AFPBridge.SM.Theories.Bump_Function
import CATEPTMain.AFPBridge.SM.Theories.Chart
import CATEPTMain.AFPBridge.SM.Theories.Cotangent_Space
import CATEPTMain.AFPBridge.SM.Theories.Differentiable_Manifold
import CATEPTMain.AFPBridge.SM.Theories.Partition_Of_Unity
import CATEPTMain.AFPBridge.SM.Theories.Product_Manifold
import CATEPTMain.AFPBridge.SM.Theories.Projective_Space
import CATEPTMain.AFPBridge.SM.Theories.Smooth
import CATEPTMain.AFPBridge.SM.Theories.Sphere
import CATEPTMain.AFPBridge.SM.Theories.Tangent_Space
import CATEPTMain.AFPBridge.SM.Theories.Topological_Manifold
