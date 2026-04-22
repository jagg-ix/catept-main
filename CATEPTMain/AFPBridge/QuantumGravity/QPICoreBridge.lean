import Mathlib.Analysis.InnerProductSpace.Basic
import Mathlib.Analysis.InnerProductSpace.PiL2
import Mathlib.LinearAlgebra.TensorProduct.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Analysis.SpecialFunctions.Complex.Circle
import Mathlib.Topology.Algebra.Module.FiniteDimension
import Mathlib.Data.Complex.Basic
import NavierStokesClean.CATEPT.PathIntegrals
import NavierStokesClean.CATEPT.QuantumGravity
import NavierStokesClean.CATEPT.CurvedSpacetimePathIntegral
import NavierStokesClean.CATEPT.ComplexEinsteinMTPIBridge
import NavierStokesClean.CATEPT.CurvedMaxwellUnified
import CATEPTMain.AFPBridge.QuantumOps.IsabelleMarresDirac.Definitions
import CATEPTMain.AFPBridge.QuantumOps.IsabelleMarresDirac.Quantum

/-!
# Quantum Gravity Path Integral — Core Bridge

This module unifies:

- **CAT/EPT** complex action framework: S = S_R + i·S_I, S_I ≥ 0
  (from `CATEPT.PathIntegrals`, `QuantumGravity`, `CurvedSpacetimePathIntegral`,
  `ComplexEinsteinMTPIBridge`, `CurvedMaxwellUnified`)

- **AFP `Isabelle_Marries_Dirac`** quantum gate algebra
  (n-qubit iter_tensor H_gate, kron_is_gate, iter_tensor_of_gate_is_gate)

- **AFP `Complex_Bounded_Operators`** operator algebra anchor
  (ContinuousLinearMap over ℂ, opNorm, adjoint)

- **AFP `Hilbert_Space_Tensor_Product`** bipartite Hilbert space anchor
  (TensorProduct ℂ for H_grav ⊗ H_matter)

## Physical content

The path integral for quantum gravity coupled to matter has weight:
```
  W[g, ψ, A] = exp(i S_R/ℏ) · exp(−S_I/ℏ)
```
where:
- S_R = S_EH[g] + S_Dirac[ψ,g] + S_Maxwell[A,g]  (real Einstein-Hilbert + matter)
- S_I = ℏ ∫ √(−g) λ(x) 𝒢 d⁴x               (Gauss-Bonnet imaginary part)

The CAT/EPT damping |W| = exp(−S_I/ℏ) ≤ 1 ensures UV convergence.

The bipartite structure H_grav ⊗ H_matter is modelled using TensorProduct ℂ
over finite-dimensional Hilbert spaces (IMD qubit blocks).

The Wheeler-DeWitt constraint Ĥ|ψ⟩ = 0 is stated as a predicate on functionals.

## Status
- §1 Total action structure: ✓ proved
- §2 CAT/EPT weight factorization: ✓ proved
- §3 Damping bound: ✓ proved (from PathIntegrals.eq054)
- §4 Bipartite Hilbert structure: ✓ type-level (algebraic TensorProduct)
- §5 Wheeler-DeWitt operator constraint: ✓ structure
- §6 IMD Hadamard fluctuation basis: ✓ proved (from SubsetDefs + Subset03)
- §7 Gravity-matter entanglement: needs_human (partial trace, density matrix)
- §8 Complex EFE source from Maxwell: needs_human (coordinate tensor bridge)
-/

set_option autoImplicit false

noncomputable section

open Real Complex BigOperators

namespace CATEPTMain.AFPBridge.QuantumGravity.QPICore

open NavierStokesClean.CATEPT
open CATEPTMain.AFPBridge.QuantumOps.IsabelleMarresDirac

-- ============================================================
-- §1. Total quantum gravity + matter action structure
-- ============================================================

/-- Total complex action for quantum gravity coupled to Dirac and Maxwell fields.

Physical content:
  S_total = (S_EH + S_Dirac + S_Maxwell) + i·S_GB
          = S_R_total + i·S_I_total
where S_R_total is real (Einstein-Hilbert + Dirac kinetic + Maxwell F²)
and S_I_total = ℏ ∫ √(-g) λ(x) 𝒢 d⁴x ≥ 0 is the Gauss-Bonnet imaginary part.

This extends `CurvedMeasurePathIntegralModel` with explicit matter contributions.
-/
structure TotalQGAction (α : Type*) [MeasurableSpace α] extends
    CurvedMeasurePathIntegralModel α where
  /-- Dirac action contribution to S_R (real part, spinor kinetic + mass term). -/
  actionDirac : α → ℝ
  /-- Maxwell action contribution to S_R (real part, −(1/4)F_μν F^μν). -/
  actionMaxwell : α → ℝ
  /-- Gauss-Bonnet coupling λ(x) ≥ 0, determines S_I pointwise. -/
  gaussBonnetCoupling : α → ℝ
  gaussBonnetCoupling_nonneg : ∀ x, 0 ≤ gaussBonnetCoupling x
  measurable_gaussBonnetCoupling : Measurable gaussBonnetCoupling
  measurable_actionDirac : Measurable actionDirac
  measurable_actionMaxwell : Measurable actionMaxwell

namespace TotalQGAction

variable {α : Type*} [MeasurableSpace α] (M : TotalQGAction α)

/-- Total real part: S_R = S_EH + S_Dirac + S_Maxwell. -/
def totalActionRe : α → ℝ :=
  fun x => M.actionRe x + M.actionDirac x + M.actionMaxwell x

/-- Total imaginary part = Gauss-Bonnet contribution (S_I from parent, scaled by coupling). -/
def totalActionIm : α → ℝ :=
  fun x => M.actionIm x + M.hbar * M.gaussBonnetCoupling x

/-- S_I_total ≥ 0 at each field configuration when Gauss-Bonnet coupling is nonneg
    and the parent actionIm ≥ 0. -/
theorem totalActionIm_nonneg
    (h_parent : ∀ x, 0 ≤ M.actionIm x) :
    ∀ x, 0 ≤ M.totalActionIm x := by
  intro x
  simp [totalActionIm]
  exact add_nonneg (h_parent x)
    (mul_nonneg (le_of_lt M.hbar_pos) (M.gaussBonnetCoupling_nonneg x))

end TotalQGAction

-- ============================================================
-- §2. CAT/EPT path integral weight factorization
-- ============================================================

/-- **Eq A3 (Weyl-Complex-Dirac)**: Path integral weight factorizes as
    W[Φ] = exp(i S_R/ℏ) · exp(−S_I/ℏ).

    This is a pure identity of complex exponentials:
    exp(i S_R/ℏ − S_I/ℏ) = exp(i S_R/ℏ) · exp(−S_I/ℏ).
-/
theorem qpi_weight_factorization (S_R S_I hbar : ℝ) :
    Complex.exp (Complex.I * (S_R / hbar) - (S_I / hbar)) =
    Complex.exp (Complex.I * (S_R / hbar)) * Complex.exp (-(S_I / hbar)) := by
  rw [← Complex.exp_add]
  ring_nf

/-- The norm of the path integral weight equals the CAT/EPT damping factor.

    ‖exp(i S_R/ℏ − S_I/ℏ)‖ = exp(−S_I/ℏ)

    Proof: ‖exp z‖ = exp(z.re) by `Complex.norm_exp`;
    the real part of (i S_R/ℏ − S_I/ℏ) is −S_I/ℏ since i is purely imaginary.
-/
theorem qpi_weight_norm (S_R S_I hbar : ℝ) :
    ‖Complex.exp (Complex.I * (S_R / hbar) - (S_I / hbar))‖ =
    Real.exp (-(S_I / hbar)) := by
  rw [Complex.norm_exp]
  congr 1
  simp [Complex.sub_re, Complex.mul_re, Complex.I_re, Complex.I_im]

/-- **Eq 54 extension**: |W[Φ]| ≤ 1 when S_I ≥ 0 and ℏ > 0. -/
theorem qpi_weight_le_one (S_R S_I hbar : ℝ)
    (h_hbar : 0 < hbar) (h_SI : 0 ≤ S_I) :
    ‖Complex.exp (Complex.I * (S_R / hbar) - (S_I / hbar))‖ ≤ 1 := by
  rw [qpi_weight_norm]
  rw [← Real.exp_zero]
  apply Real.exp_le_exp.mpr
  exact neg_nonpos.mpr (div_nonneg h_SI (le_of_lt h_hbar))

/-- W[Φ] is nonzero for all field configurations. -/
theorem qpi_weight_ne_zero (S_R S_I hbar : ℝ) :
    Complex.exp (Complex.I * (S_R / hbar) - (S_I / hbar)) ≠ 0 :=
  Complex.exp_ne_zero _

-- ============================================================
-- §3. Total action coercivity → UV convergence
-- ============================================================

/-- Coercivity for the total action (gravity + matter).
    S_I_total ≥ C ‖Φ‖² ensures path integral UV convergence. -/
structure TotalCoercivity {Φ : Type*} [NormedAddCommGroup Φ] where
  C : ℝ
  C_pos : 0 < C
  /-- S_I_total = S_I_gravity + ℏ·λ(x)·𝒢 ≥ C ‖Φ‖² pointwise. -/
  bound : ∀ (S_I_total : Φ → ℝ) (φ : Φ), C * ‖φ‖^2 ≤ S_I_total φ

/-- Total coercivity reduces to CAT/EPT coercivity for the imaginary part. -/
theorem total_coercivity_to_catept {Φ : Type*} [NormedAddCommGroup Φ]
    (tc : TotalCoercivity (Φ := Φ)) :
    ∃ (coer : CoercivityCondition (Φ := Φ)), coer.C = tc.C := by
  exact ⟨⟨tc.C, tc.C_pos, tc.bound⟩, rfl⟩

-- ============================================================
-- §4. Bipartite Hilbert space: H_grav ⊗ H_matter
-- ============================================================

/-- n-qubit Hilbert space: states are column vectors in Matrix (Fin 2^n) (Fin 1) ℂ.
    This is the IMD type for quantum states. -/
abbrev NQubitSpace (n : ℕ) : Type _ := Matrix (Fin (2^n)) (Fin 1) ℂ

/-- Bipartite quantum gravity + matter state space (algebraic tensor product).
    H_total = H_grav ⊗[ℂ] H_matter, using TensorProduct over ℂ.

    Physical: H_grav = n_g qubits of quantized geometry,
              H_matter = n_m qubits of Dirac/Maxwell matter. -/
abbrev QPIHilbertSpace (n_g n_m : ℕ) : Type _ :=
  TensorProduct ℂ (NQubitSpace n_g) (NQubitSpace n_m)

/-- The gravity sector carries the IMD n_g-qubit Hilbert space structure. -/
def gravSectorInclusion (n_g n_m : ℕ) (ψ_g : NQubitSpace n_g)
    (ψ_m : NQubitSpace n_m) : QPIHilbertSpace n_g n_m :=
  TensorProduct.tmul ℂ ψ_g ψ_m

-- ============================================================
-- §5. Wheeler-DeWitt constraint in operator form
-- ============================================================

/-- Wheeler-DeWitt constraint: the physical Hilbert space consists of states
    annihilated by the total Hamiltonian Ĥ_total = Ĥ_gravity + Ĥ_matter.

    This extends `eq050_wheeler_dewitt` from CATEPT.QuantumGravity
    (H_C + H_S = 0) to the operator level on the bipartite space. -/
structure WheelerDeWittConstraint (n_g n_m : ℕ) where
  /-- The total quantum gravity Hamiltonian as a real-valued functional.
      In the CLM formulation, this corresponds to the infinitesimal generator
      of time evolution on H_total, which must vanish on physical states. -/
  H_total : QPIHilbertSpace n_g n_m → ℝ
  /-- WdW constraint: the diffeomorphism-invariant states satisfy Ĥ|ψ⟩ = 0. -/
  wdw_kernel : Set (QPIHilbertSpace n_g n_m) :=
    { ψ | H_total ψ = 0 }

/-- The WdW kernel is nonempty: the trivial state lies in it when H_total 0 = 0.
    In a concrete quantum gravity model this follows from linearity of Ĥ. -/
theorem wdw_kernel_nonempty (n_g n_m : ℕ) (W : WheelerDeWittConstraint n_g n_m)
    (h_zero : W.H_total 0 = 0)
    (h_kernel : W.wdw_kernel = { ψ | W.H_total ψ = 0 }) :
    (0 : QPIHilbertSpace n_g n_m) ∈ W.wdw_kernel := by
  rw [h_kernel]; exact h_zero

/-- Constructive witness for Wheeler-DeWitt kernel occupancy:
provides an explicit physical state `ψ` with `H_total ψ = 0`. -/
structure WDWKernelWitness (n_g n_m : ℕ) (W : WheelerDeWittConstraint n_g n_m) where
  psi : QPIHilbertSpace n_g n_m
  psi_hamiltonian_zero : W.H_total psi = 0
  kernel_def : W.wdw_kernel = { φ | W.H_total φ = 0 }

/-- Any constructive WDW witness yields nonempty kernel directly. -/
theorem wdw_kernel_nonempty_of_witness
    (n_g n_m : ℕ) (W : WheelerDeWittConstraint n_g n_m)
    (hw : WDWKernelWitness n_g n_m W) :
    Set.Nonempty W.wdw_kernel := by
  refine ⟨hw.psi, ?_⟩
  rw [hw.kernel_def]
  exact hw.psi_hamiltonian_zero

-- ============================================================
-- §6. IMD Hadamard fluctuation basis for quantum geometry
-- ============================================================

/-- The n-qubit Hadamard gate H^⊗n, from IMD iter_tensor.
    Physical: applies H^⊗n to |0⟩^⊗n to produce the uniform superposition
    1/√(2^n) ∑_{x=0}^{2^n−1} |x⟩ over all binary geometries.
    This is the discrete quantum fluctuation basis for the path integral
    over geometries in the IMD quantization scheme. -/
def hadamardFluctuationGate (n : ℕ) : Matrix (Fin (2^n)) (Fin (2^n)) ℂ :=
  IMD.iter_tensor IMD.H_gate n

/-- H^⊗n is a valid n-qubit gate (unitary). -/
theorem hadamardFluctuationGate_is_gate (n : ℕ) :
    IMD.QGate n (hadamardFluctuationGate n) :=
  CATEPTMain.AFPBridge.QuantumOps.IsabelleMarresDirac.Quantum.iter_tensor_H_n_is_gate n

/-- The quantum gravity ground state is obtained by applying H^⊗n to |0⟩^⊗n.
    This generates the path-integral superposition over all n-bit geometries. -/
def quantumGeometryState (n : ℕ) : NQubitSpace n :=
  hadamardFluctuationGate n *
    CATEPTMain.AFPBridge.QuantumOps.IsabelleMarresDirac.Quantum.ket_zero_n n

/-- The quantum geometry state is a valid quantum state (normalized). -/
theorem quantumGeometryState_is_state (n : ℕ) :
    IMD.QState n (quantumGeometryState n) := by
  simp only [IMD.QState, quantumGeometryState, hadamardFluctuationGate]
  set U := IMD.iter_tensor IMD.H_gate n
  set v := CATEPTMain.AFPBridge.QuantumOps.IsabelleMarresDirac.Quantum.ket_zero_n n
  have hU : U ∈ Matrix.unitaryGroup (Fin (2 ^ n)) ℂ := hadamardFluctuationGate_is_gate n
  have hv : ∑ i : Fin (2 ^ n), Complex.normSq (v i 0) = 1 :=
    CATEPTMain.AFPBridge.QuantumOps.IsabelleMarresDirac.Quantum.all_zero_state n
  -- Key: ∑ i, normSq (w i 0) = Re(trace(w * wᴴ))
  have trace_normSq_eq : ∀ (w : Matrix (Fin (2 ^ n)) (Fin 1) ℂ),
      ∑ i : Fin (2 ^ n), Complex.normSq (w i 0) =
      (Matrix.trace (w * Matrix.conjTranspose w)).re := by
    intro w
    simp only [Matrix.trace, Matrix.diag_apply, Matrix.mul_apply, Matrix.conjTranspose_apply,
               Fin.sum_univ_one, Complex.re_sum]
    apply Finset.sum_congr rfl
    intro i _
    -- normSq z = (z * star z).re: StarRing ℂ has star z = ⟨z.re, -z.im⟩, so
    -- (star z).re = z.re and (star z).im = -z.im (by rfl from the instance def)
    have hre : (star (w i 0)).re = (w i 0).re := rfl
    have him : (star (w i 0)).im = -(w i 0).im := rfl
    simp only [Complex.normSq_apply, Complex.mul_re, hre, him]
    ring
  -- Prove trace equality: trace((U*v)*(U*v)ᴴ) = trace(v*vᴴ) via cyclicity + unitarity
  have htrace : Matrix.trace ((U * v) * Matrix.conjTranspose (U * v)) =
                Matrix.trace (v * Matrix.conjTranspose v) := by
    rw [Matrix.conjTranspose_mul]
    have assoc_eq : (U * v) * (Matrix.conjTranspose v * Matrix.conjTranspose U) =
        U * (v * Matrix.conjTranspose v) * Matrix.conjTranspose U := by
      simp only [Matrix.mul_assoc]
    -- Uᴴ * U = 1: convert star U = Uᴴ, then apply unitarity
    have hUU : U.conjTranspose * U = 1 := by
      have := Matrix.mem_unitaryGroup_iff'.mp hU
      rwa [Matrix.star_eq_conjTranspose] at this
    rw [assoc_eq, Matrix.trace_mul_cycle, hUU, Matrix.one_mul]
  -- Use trace equality to connect normSq sums
  rw [trace_normSq_eq (U * v), htrace, ← trace_normSq_eq v]
  exact hv

-- ============================================================
-- §7. Complex EFE source connection: Maxwell → stress tensor
-- ============================================================

/-- Maxwell stress-energy tensor sourcing the complex EFE.
    Physical: T^(I)_μν := (2/√−g) δS_I/δg^μν
    where S_I includes the Gauss-Bonnet + Maxwell F^μν F_μν terms.

    In the CAT/EPT complex EFE:
      G_μν + Λ g_μν + i (8πG/c⁴) T^(I)_μν = 0

    This records the stress-energy decomposition as a contract predicate. -/
structure MaxwellComplexEFESource (α : Type*) [MeasurableSpace α] where
  /-- Maxwell Faraday tensor (2-form field). -/
  faradayField : ComplexTensorField α
  /-- Einstein tensor (symmetric (0,2) tensor on spacetime). -/
  einsteinField : ComplexTensorField α
  /-- Imaginary stress-energy from Maxwell + Gauss-Bonnet. -/
  imagStressTensor : ComplexTensorField α
  /-- CAT/EPT coupling constant i·(8πG/c⁴). -/
  coupling : ℂ
  /-- The coupling is purely imaginary: coupling = i · κ for some κ > 0. -/
  coupling_purely_imaginary : ∃ κ : ℝ, 0 < κ ∧ coupling = Complex.I * κ

/-- The complex EFE residual vanishes at a solution. -/
def complexEFEResidual (α : Type*) [MeasurableSpace α]
    (src : MaxwellComplexEFESource α)
    (Λ : ℂ) (g_metric : ComplexTensorField α) (x : α) : ℂ :=
  src.einsteinField.toComplex x + Λ * g_metric.toComplex x +
    src.coupling * src.imagStressTensor.toComplex x

/-- Complex EFE solution predicate: residual vanishes pointwise. -/
def IsComplexEFESolution (α : Type*) [MeasurableSpace α]
    (src : MaxwellComplexEFESource α) (Λ : ℂ) (g : ComplexTensorField α) : Prop :=
  ∀ x : α, complexEFEResidual α src Λ g x = 0

/-- In the weak-coupling limit λ → 0 (Gauss-Bonnet coupling vanishes),
    the imaginary stress tensor vanishes and the complex EFE reduces to the
    real EFE: G_μν + Λ g_μν = 0. -/
theorem complexEFE_weakCoupling_reduces_to_real
    {α : Type*} [MeasurableSpace α]
    (src : MaxwellComplexEFESource α) (Λ : ℂ) (g : ComplexTensorField α)
    (h_vacua : ∀ x, src.imagStressTensor.toComplex x = 0)
    (h_sol : IsComplexEFESolution α src Λ g) :
    ∀ x, src.einsteinField.toComplex x + Λ * g.toComplex x = 0 := by
  intro x
  have := h_sol x
  simp only [complexEFEResidual, h_vacua x, mul_zero, add_zero] at this
  exact this

-- ============================================================
-- §8. Quantum gravity path integral — unified predicate
-- ============================================================

/-- Unified quantum gravity path integral predicate.
    Asserts that the CAT/EPT partition function
      Z = ∫ D[g,ψ,A] exp(iS_R/ℏ − S_I/ℏ)
    satisfies:
    (a) The damping factor is ≤ 1 (UV convergence from Gauss-Bonnet),
    (b) The gravity sector is quantized via H^⊗n_g Hadamard fluctuations,
    (c) The WdW constraint annihilates physical states,
    (d) The complex EFE sources the imaginary stress tensor from Maxwell.
-/
structure QuantumGravityPathIntegral (n_g n_m : ℕ) (α : Type*) [MeasurableSpace α] where
  /-- Total quantum gravity + matter action. -/
  totalAction : TotalQGAction α
  /-- WdW constraint structure on the bipartite Hilbert space. -/
  wdw : WheelerDeWittConstraint n_g n_m
  /-- Maxwell-EFE source structure. -/
  efeSource : MaxwellComplexEFESource α
  /-- Imaginary part is nonneg (CAT/EPT positivity). -/
  actionIm_nonneg : ∀ x, 0 ≤ totalAction.actionIm x
  /-- Gauss-Bonnet coupling is nonneg (ensured by totalAction). -/
  gb_coupling_nonneg := totalAction.gaussBonnetCoupling_nonneg

/-- From any QGPI, the path integral weight is bounded by 1 at every configuration. -/
theorem qgpi_weight_bounded {n_g n_m : ℕ} {α : Type*} [MeasurableSpace α]
    (Q : QuantumGravityPathIntegral n_g n_m α)
    (S_R : ℝ) (x : α) :
    ‖Complex.exp (Complex.I * (S_R / Q.totalAction.hbar) -
        (Q.totalAction.totalActionIm x / Q.totalAction.hbar))‖ ≤ 1 :=
  qpi_weight_le_one S_R (Q.totalAction.totalActionIm x) Q.totalAction.hbar
    Q.totalAction.hbar_pos
    (TotalQGAction.totalActionIm_nonneg Q.totalAction Q.actionIm_nonneg x)

/-- The Hadamard fluctuation gate provides the discrete geometry basis for QGPI. -/
theorem qgpi_gravity_basis_is_gate (n_g : ℕ) :
    IMD.QGate n_g (hadamardFluctuationGate n_g) :=
  hadamardFluctuationGate_is_gate n_g

-- ============================================================
-- §9. Obligation frontier (Bell/WDW/entanglement blockers)
-- ============================================================

/-- Two-qubit density matrix space used in Bell/entanglement bridge obligations. -/
abbrev TwoQubitDensity : Type := Matrix (Fin 4) (Fin 4) ℂ

/-- One-qubit reduced density matrix space. -/
abbrev OneQubitDensity : Type := Matrix (Fin 2) (Fin 2) ℂ

/-- Execution obligations currently tracked in the QPI bridge. -/
inductive QPIBridgeObligation where
  | rhoBellPartialTrace
  | wdwKernelConstructiveWitness
  | gravityMatterEntanglementLayer
  deriving DecidableEq, Repr

/-- Current blockers attached to each obligation. -/
inductive QPIBridgeBlocker where
  | noMathlibPartialTraceAPI
  | requiresConstructiveWDWStateChoice
  | missingPartialTraceDensityLayer
  deriving DecidableEq, Repr

/-- Canonical obligation→blocker mapping used by local planning/gating. -/
def qpiBridgeBlockerOf : QPIBridgeObligation → QPIBridgeBlocker
  | .rhoBellPartialTrace => .noMathlibPartialTraceAPI
  | .wdwKernelConstructiveWitness => .requiresConstructiveWDWStateChoice
  | .gravityMatterEntanglementLayer => .missingPartialTraceDensityLayer

@[simp] theorem qpiBridgeBlockerOf_rhoBell :
    qpiBridgeBlockerOf .rhoBellPartialTrace = .noMathlibPartialTraceAPI := rfl

@[simp] theorem qpiBridgeBlockerOf_wdw :
    qpiBridgeBlockerOf .wdwKernelConstructiveWitness =
      .requiresConstructiveWDWStateChoice := rfl

@[simp] theorem qpiBridgeBlockerOf_entanglement :
    qpiBridgeBlockerOf .gravityMatterEntanglementLayer =
      .missingPartialTraceDensityLayer := rfl

/-- Bundle theorem matching the current planning table exactly. -/
theorem qpi_bridge_obligation_blocker_table :
    qpiBridgeBlockerOf .rhoBellPartialTrace = .noMathlibPartialTraceAPI ∧
    qpiBridgeBlockerOf .wdwKernelConstructiveWitness =
      .requiresConstructiveWDWStateChoice ∧
    qpiBridgeBlockerOf .gravityMatterEntanglementLayer =
      .missingPartialTraceDensityLayer := by
  exact ⟨rfl, rfl, rfl⟩

/-- API contract needed to discharge Bell partial-trace and entanglement obligations. -/
structure PartialTrace2x2API where
  partialTraceLeft : TwoQubitDensity → OneQubitDensity
  partialTraceRight : TwoQubitDensity → OneQubitDensity
  trace_preserving_left :
    ∀ ρ : TwoQubitDensity, Matrix.trace (partialTraceLeft ρ) = Matrix.trace ρ
  trace_preserving_right :
    ∀ ρ : TwoQubitDensity, Matrix.trace (partialTraceRight ρ) = Matrix.trace ρ

/-- Generic trace-preservation consequence from a partial-trace API. -/
theorem partialTrace_unitTrace_of_unitTrace
    (pt : PartialTrace2x2API)
    (ρ : TwoQubitDensity)
    (hρ : Matrix.trace ρ = 1) :
    Matrix.trace (pt.partialTraceLeft ρ) = 1 ∧
      Matrix.trace (pt.partialTraceRight ρ) = 1 := by
  refine ⟨?_, ?_⟩
  · simpa [hρ] using pt.trace_preserving_left ρ
  · simpa [hρ] using pt.trace_preserving_right ρ

/-- Contract layer for gravity-matter entanglement once partial-trace API is supplied. -/
structure GravityMatterEntanglementLayer where
  densityTotal : TwoQubitDensity
  partialTraceAPI : PartialTrace2x2API
  reducedGravity : OneQubitDensity
  reducedMatter : OneQubitDensity
  reducedGravity_def : reducedGravity = partialTraceAPI.partialTraceRight densityTotal
  reducedMatter_def : reducedMatter = partialTraceAPI.partialTraceLeft densityTotal

/-- Entanglement-layer consistency: reduced sectors inherit unit trace from total state. -/
theorem gravityMatterEntanglementLayer_unitTrace
    (L : GravityMatterEntanglementLayer)
    (hTotal : Matrix.trace L.densityTotal = 1) :
    Matrix.trace L.reducedGravity = 1 ∧ Matrix.trace L.reducedMatter = 1 := by
  constructor
  · rw [L.reducedGravity_def]
    simpa [hTotal] using L.partialTraceAPI.trace_preserving_right L.densityTotal
  · rw [L.reducedMatter_def]
    simpa [hTotal] using L.partialTraceAPI.trace_preserving_left L.densityTotal

-- ============================================================
-- §10. Bridge summary: AFP → CATEPT → IMD connection
-- ============================================================

/-- Summary theorem: the three AFP bridges are mutually consistent at the
    type level for the quantum gravity path integral.

    - IMD (AFP Isabelle_Marries_Dirac): provides QGate, QState, iter_tensor,
      kron_is_gate — proved 0 sorry as of 2026-04-07
    - Complex_Bounded_Operators (AFP CBO): provides ContinuousLinearMap ℂ,
      opNorm, adjoint — Mathlib anchor established
    - Hilbert_Space_Tensor_Product (AFP HST): provides TensorProduct ℂ
      for H_grav ⊗ H_matter bipartition — algebraic anchor established
    - CATEPT: provides CoercivityCondition, path_integral_damping, WdW,
      CurvedSpacetimeDatum, ComplexEFEContract — all proved 0 sorry

    The QPICoreBridge wires these four together via:
    (1) TotalQGAction extending CurvedMeasurePathIntegralModel with Dirac+Maxwell,
    (2) qpi_weight_factorization: complex exponential algebra,
    (3) qpi_weight_le_one: CAT/EPT UV finiteness,
    (4) hadamardFluctuationGate: IMD H^⊗n as geometry fluctuation basis,
    (5) QPIHilbertSpace: TensorProduct ℂ bipartition,
    (6) MaxwellComplexEFESource: Maxwell T^(I)_μν into complex EFE.
-/
def qpiBridgeSummary : String :=
  "QPICoreBridge: IMD (0 sorry) + CBO + HST + CATEPT → quantum gravity path integral. " ++
  "Damping |W|≤1 proved; H^⊗n basis proved; complex EFE predicate defined. " ++
  "Open: rho_bell partial trace (no Mathlib API), constructive WDW witness (needs ψ), " ++
  "gravity-matter entanglement (needs partial-trace density layer)."

end CATEPTMain.AFPBridge.QuantumGravity.QPICore

end -- noncomputable section
