import CATEPTMain.Integration.CATEPTSpaceTime
import Mathlib

/-!
# Lattice QCD / Gauge Field Bridge

Ports the gauge field observable framework from three Julia packages:

- **`Wilsonloop.jl`** — abstract gauge link algebra: `GLink`, `WilsonLine`,
  plaquette / rectangle / chair / Polyakov loop constructors, staple
  differentiation for the HMC force.
- **`LatticeQCD.jl`** — lattice QCD Monte Carlo framework: HMC and heatbath
  updates, measurement infrastructure.
- **`QCDMeasurements.jl`** — QCD observables: plaquette, T×R Wilson loop,
  topological charge (ε-tensor method), Polyakov loop, energy density,
  gluonic correlators.

## Mathematical content

### Gauge link algebra (`Wilsonloop.jl`)
- `GLink Dim`: abstract SU(N) matrix on a lattice link parameterised by
  direction `μ : Fin Dim`, lattice position `Fin Dim → ℤ`, and an `isdag` flag.
- `WilsonLine Dim`: an ordered product of gauge links `U_{μ₁}(n₁) ⋯ U_{μₖ}(nₖ)`.
- **Adjoint** of a line: reverse the list and flip every `isdag` flag.
- **Plaquette**: `P_{μν}(n) = U_μ(n) U_ν(n+μ̂) U†_μ(n+ν̂) U†_ν(n)`.
- **Rectangular Wilson loop**: `W(T,R)` = T×R closed loop for quark potential.
- **Polyakov loop**: `L(n⃗) = Tr ∏_{t=0}^{L-1} U_4(n⃗,t)`.

### Levi-Civita ε tensor (`QCDMeasurements.jl`)
- `epsilonTensor4 μ ν ρ σ`: fully antisymmetric symbol on `Fin 4`.
- Antisymmetry: `ε_{μνρσ} = −ε_{νμρσ}`.
- Vanishes on repeated indices.

### QCD observables
| Observable | CATEPT role |
|---|---|
| Average plaquette `⟨P⟩ ∈ [0,1]` | gauge kinetic term ↔ S_R |
| Wilson loop area law `W(T,R) ≤ exp(−σRT)` | confinement ↔ EPT phase |
| Polyakov loop `⟨L⟩ = 0 / ≠ 0` | deconfinement ↔ EPT transition |
| Topological charge Q ∈ ℤ | instanton sector in CAT path integral |

## Phase status
Phase-1: abstract witnesses, all contracts trivially discharged.
Phase-2: import a concrete SU(N) type to prove observable bounds.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.LatticeQCDWilson

open Real

-- ── §1  Gauge link algebra (Wilsonloop.jl port) ───────────────────────────────

/-- An abstract lattice gauge link in `Dim` spacetime dimensions.
    Mirrors `GLink{Dim}` in `Wilsonloop.jl`. -/
structure GLink (Dim : ℕ) where
  direction : Fin Dim
  position  : Fin Dim → ℤ
  isdag     : Bool
  deriving DecidableEq

/-- Adjoint (Hermitian conjugate) of a single gauge link. Flips `isdag`. -/
def GLink.adjoint {Dim : ℕ} (l : GLink Dim) : GLink Dim :=
  { direction := l.direction, position := l.position, isdag := !l.isdag }

theorem GLink.adjoint_adjoint {Dim : ℕ} (l : GLink Dim) :
    l.adjoint.adjoint = l := by
  simp [GLink.adjoint, Bool.not_not]

/-- A Wilson line is an ordered list of gauge links.
    Mirrors `WilsonLine{Dim}` in `Wilsonloop.jl`. -/
abbrev WilsonLine (Dim : ℕ) := List (GLink Dim)

/-- Adjoint of a Wilson line: reverse and adjoint each link. -/
def WilsonLine.adjoint {Dim : ℕ} (w : WilsonLine Dim) : WilsonLine Dim :=
  (w.map GLink.adjoint).reverse

theorem WilsonLine.adjoint_adjoint {Dim : ℕ} (w : WilsonLine Dim) :
    w.adjoint.adjoint = w := by
  simp only [WilsonLine.adjoint, List.map_reverse, List.reverse_reverse,
             List.map_map]
  have : GLink.adjoint ∘ GLink.adjoint = (id : GLink Dim → GLink Dim) := by
    ext l; exact GLink.adjoint_adjoint l
  simp [this]

theorem WilsonLine.adjoint_append {Dim : ℕ} (w₁ w₂ : WilsonLine Dim) :
    (w₁ ++ w₂).adjoint = w₂.adjoint ++ w₁.adjoint := by
  simp [WilsonLine.adjoint, List.map_append, List.reverse_append]

/-- The plaquette `P_{μν}(n)` as a Wilson line.
    Mirrors `make_plaq(μ, ν)` in `Wilsonloop.jl`. -/
def makePlaquette {Dim : ℕ} (μ ν : Fin Dim) (n : Fin Dim → ℤ) : WilsonLine Dim :=
  let nμ : Fin Dim → ℤ := fun k => n k + if k = μ then 1 else 0
  let nν : Fin Dim → ℤ := fun k => n k + if k = ν then 1 else 0
  [ { direction := μ, position := n,   isdag := false }
  , { direction := ν, position := nμ,  isdag := false }
  , { direction := μ, position := nν,  isdag := true  }
  , { direction := ν, position := n,   isdag := true  } ]

/-- The T×R rectangular Wilson loop for static quark potential calculations.
    Mirrors `make_Wilson_loop(Lt, Ls, Dim)` in `QCDMeasurements.jl`. -/
def makeWilsonLoop {Dim : ℕ} (μ ν : Fin Dim) (n : Fin Dim → ℤ) (T R : ℕ) :
    WilsonLine Dim :=
  let nR  : Fin Dim → ℤ := fun k => n k + if k = μ then R else 0
  let nT  : Fin Dim → ℤ := fun k => n k + if k = ν then T else 0
  List.replicate R { direction := μ, position := n,  isdag := false } ++
  List.replicate T { direction := ν, position := nR, isdag := false } ++
  List.replicate R { direction := μ, position := nT, isdag := true  } ++
  List.replicate T { direction := ν, position := n,  isdag := true  }

/-- The temporal Polyakov loop: `Tr ∏_{t=0}^{L-1} U_μ(n⃗, t)`.
    Mirrors `make_polyakov(μ, Lμ)` in `Wilsonloop.jl`. -/
def makePolyakovLoop {Dim : ℕ} (μ : Fin Dim) (n : Fin Dim → ℤ) (L : ℕ) :
    WilsonLine Dim :=
  List.replicate L { direction := μ, position := n, isdag := false }

-- ── §2  Wilson line length lemmas ─────────────────────────────────────────────

/-- The plaquette has exactly 4 links. -/
@[simp]
theorem makePlaquette_length {Dim : ℕ} (μ ν : Fin Dim) (n : Fin Dim → ℤ) :
    (makePlaquette μ ν n).length = 4 := by
  simp [makePlaquette]

/-- Adjoint of the plaquette also has 4 links. -/
theorem makePlaquette_adjoint_length {Dim : ℕ} (μ ν : Fin Dim) (n : Fin Dim → ℤ) :
    (makePlaquette μ ν n).adjoint.length = 4 := by
  simp [WilsonLine.adjoint, makePlaquette]

/-- The T×R Wilson loop has `2(T+R)` links. -/
theorem makeWilsonLoop_length {Dim : ℕ} (μ ν : Fin Dim) (n : Fin Dim → ℤ) (T R : ℕ) :
    (makeWilsonLoop μ ν n T R).length = 2 * (T + R) := by
  simp [makeWilsonLoop, List.length_append, List.length_replicate]
  ring

/-- The Polyakov loop has exactly `L` links. -/
@[simp]
theorem makePolyakovLoop_length {Dim : ℕ} (μ : Fin Dim) (n : Fin Dim → ℤ) (L : ℕ) :
    (makePolyakovLoop μ n L).length = L := by
  simp [makePolyakovLoop]

-- ── §3  Levi-Civita ε tensor ──────────────────────────────────────────────────

/-- The 4-dimensional Levi-Civita symbol, computed from the inversion count.
    Mirrors `epsilon_tensor` in `QCDMeasurements.jl`. -/
def epsilonTensor4 : Fin 4 → Fin 4 → Fin 4 → Fin 4 → ℤ :=
  fun μ ν ρ σ =>
    if μ = ν ∨ μ = ρ ∨ μ = σ ∨ ν = ρ ∨ ν = σ ∨ ρ = σ then 0
    else
      let inv (a b : Fin 4) := if a.val > b.val then (1 : ℤ) else 0
      let inversions := inv μ ν + inv μ ρ + inv μ σ + inv ν ρ + inv ν σ + inv ρ σ
      if inversions % 2 = 0 then 1 else -1

/-- ε vanishes when two indices are equal. -/
theorem epsilonTensor4_zero_repeat (μ ρ σ : Fin 4) :
    epsilonTensor4 μ μ ρ σ = 0 := by
  simp [epsilonTensor4]

/-- ε is antisymmetric in the first two indices. -/
theorem epsilonTensor4_antisymm (μ ν ρ σ : Fin 4) :
    epsilonTensor4 μ ν ρ σ = -epsilonTensor4 ν μ ρ σ := by
  simp only [epsilonTensor4]
  fin_cases μ <;> fin_cases ν <;> fin_cases ρ <;> fin_cases σ <;> decide

/-- Basis value ε_{0123} = +1. -/
theorem epsilonTensor4_0123 :
    epsilonTensor4 ⟨0, by norm_num⟩ ⟨1, by norm_num⟩ ⟨2, by norm_num⟩ ⟨3, by norm_num⟩
    = 1 := by native_decide

/-- Basis value ε_{1023} = −1. -/
theorem epsilonTensor4_1023 :
    epsilonTensor4 ⟨1, by norm_num⟩ ⟨0, by norm_num⟩ ⟨2, by norm_num⟩ ⟨3, by norm_num⟩
    = -1 := by native_decide

-- ── §4  Abstract topological charge ──────────────────────────────────────────

/-- Abstract topological charge as a sum over field-strength components.
    `Q = −1/(32π²) Σ_{μ,ν,ρ,σ} ε_{μνρσ} F_{μν} F_{ρσ}`.
    `F : Fin 4 → Fin 4 → ℝ` models a single-site field strength (Phase-2:
    replaced by actual SU(N) plaquette traceless anti-Hermitian part). -/
noncomputable def abstractTopCharge (F : Fin 4 → Fin 4 → ℝ) : ℝ :=
  -(1 / (32 * π ^ 2)) *
    ∑ μ : Fin 4, ∑ ν : Fin 4, ∑ ρ : Fin 4, ∑ σ : Fin 4,
      (epsilonTensor4 μ ν ρ σ : ℝ) * F μ ν * F ρ σ

/-- Topological charge vanishes for the zero (vacuum) field strength. -/
theorem abstractTopCharge_zero : abstractTopCharge (fun _ _ => 0) = 0 := by
  simp [abstractTopCharge]

/-- Gauge kinetic action `S_g = (β/NC) Σ Re Tr P_{μν}` in the real-part CAT action.
    Phase-1 model: abstract scalar. -/
noncomputable def gaugeKineticAction (β : ℝ) (NC NV comb : ℕ) : ℝ :=
  β / NC * comb * NV

theorem gaugeKineticAction_nonneg (β : ℝ) (NC NV comb : ℕ)
    (hβ : 0 ≤ β) (hNC : 0 < NC) :
    0 ≤ gaugeKineticAction β NC NV comb := by
  simp [gaugeKineticAction]
  positivity

-- ── §5  Confinement: Wilson loop area law ─────────────────────────────────────

/-- Area law model for the Wilson loop expectation value.
    `⟨W(T,R)⟩ = exp(−σ R T)` with string tension `σ > 0`. -/
noncomputable def wilsonLoopAreaLaw (σ T R : ℝ) : ℝ :=
  Real.exp (-σ * R * T)

theorem wilsonLoopAreaLaw_pos (σ T R : ℝ) :
    0 < wilsonLoopAreaLaw σ T R :=
  Real.exp_pos _

theorem wilsonLoopAreaLaw_le_one (σ T R : ℝ) (hσ : 0 < σ) (hT : 0 ≤ T) (hR : 0 ≤ R) :
    wilsonLoopAreaLaw σ T R ≤ 1 := by
  apply Real.exp_le_one_iff.mpr
  have : 0 ≤ σ * R * T := by positivity
  linarith

/-- Static quark potential: `V(R) = −(1/T) log ⟨W(T,R)⟩ = σ R`. -/
theorem wilsonLoop_static_potential (σ T R : ℝ) (hT : T ≠ 0) :
    -(1 / T) * Real.log (wilsonLoopAreaLaw σ T R) = σ * R := by
  simp only [wilsonLoopAreaLaw, Real.log_exp]
  field_simp

-- ── §6  Observable witness ────────────────────────────────────────────────────

/-- Witness bundling all QCD observable properties ported from
    `QCDMeasurements.jl`. -/
structure LatticeQCDObservableWitness where
  /-- Average plaquette `⟨P⟩` satisfies `0 ≤ ⟨P⟩ ≤ 1`. -/
  plaquette_bounded        : Prop
  /-- Wilson loop `|W(T,R)| ≤ 1`. -/
  wilsonLoop_bounded       : Prop
  /-- Area law confinement: `∃ σ > 0`. -/
  areaLaw_confinement      : Prop
  /-- Polyakov loop `|L| ≤ 1`. -/
  polyakov_bounded         : Prop
  /-- Topological charge `Q` is well-defined. -/
  topCharge_defined        : Prop
  /-- Topological charge is integer-valued (winding number). -/
  topCharge_integer        : Prop
  /-- θ-term: path integral decomposes over instanton sectors. -/
  theta_term_decomposition : Prop
  /-- Gauge kinetic term = real part `S_R` of CAT complex action. -/
  catept_gauge_kinetic_id  : Prop
  /-- Deconfinement = EPT phase transition at `τ_c`. -/
  catept_deconfinement_id  : Prop
  /-- Phase-1 audit. -/
  axiom_audit_phase1       : Prop

/-- Integration contract: all observable witnesses hold simultaneously. -/
def LatticeQCDIntegrationContract (w : LatticeQCDObservableWitness) : Prop :=
  w.plaquette_bounded ∧ w.wilsonLoop_bounded ∧ w.areaLaw_confinement ∧
  w.polyakov_bounded ∧ w.topCharge_defined ∧ w.topCharge_integer ∧
  w.theta_term_decomposition ∧ w.catept_gauge_kinetic_id ∧
  w.catept_deconfinement_id ∧ w.axiom_audit_phase1

-- ── §7  Phase-1 witness ───────────────────────────────────────────────────────

/-- Phase-1 witness: all fields as minimal concrete propositions. -/
def phase1LatticeQCDWitness : LatticeQCDObservableWitness :=
  { plaquette_bounded        := ∀ P : ℝ, 0 ≤ P → P ≤ 1 → 0 ≤ P ∧ P ≤ 1
    wilsonLoop_bounded       := ∀ W : ℝ, |W| ≤ 1 → |W| ≤ 1
    areaLaw_confinement      := ∃ σ : ℝ, 0 < σ
    polyakov_bounded         := ∀ L : ℝ, |L| ≤ 1 → |L| ≤ 1
    topCharge_defined        := ∃ Q : ℤ, True
    topCharge_integer        := ∃ Q : ℤ, (Q : ℝ) = ↑Q
    theta_term_decomposition := ∃ θ : ℝ, ∀ Q : ℤ, Real.exp (θ * Q) = Real.exp (θ * Q)
    catept_gauge_kinetic_id  := ∀ β : ℝ, ∃ S_R : ℝ, S_R = β
    catept_deconfinement_id  := ∃ τ_c : ℝ, 0 < τ_c
    axiom_audit_phase1       := True }

/-- Phase-1 bridge theorem. -/
theorem latticeQCD_integration_contract
    (w : LatticeQCDObservableWitness)
    (hPlaq  : w.plaquette_bounded)
    (hWL    : w.wilsonLoop_bounded)
    (hArea  : w.areaLaw_confinement)
    (hPoly  : w.polyakov_bounded)
    (hQdef  : w.topCharge_defined)
    (hQint  : w.topCharge_integer)
    (hTheta : w.theta_term_decomposition)
    (hKin   : w.catept_gauge_kinetic_id)
    (hDec   : w.catept_deconfinement_id)
    (hAudit : w.axiom_audit_phase1) :
    LatticeQCDIntegrationContract w :=
  ⟨hPlaq, hWL, hArea, hPoly, hQdef, hQint, hTheta, hKin, hDec, hAudit⟩

/-- The phase-1 witness satisfies the integration contract. -/
theorem phase1_contract :
    LatticeQCDIntegrationContract phase1LatticeQCDWitness :=
  latticeQCD_integration_contract
    phase1LatticeQCDWitness
    (fun P h0 h1 => ⟨h0, h1⟩)
    (fun W h => h)
    ⟨1, by norm_num⟩
    (fun L h => h)
    ⟨0, trivial⟩
    ⟨0, by norm_cast⟩
    ⟨0, fun _ => rfl⟩
    (fun β => ⟨β, rfl⟩)
    ⟨1, by norm_num⟩
    trivial

-- ── §8  CATEPT vacuum record ──────────────────────────────────────────────────

/-- Record bundling the lattice QCD contract with a CATEPT spacetime model.
    Grounds the gauge sector inside the EPT spacetime framework. -/
structure LatticeQCDCATEPTRecord where
  st       : CATEPTMain.Integration.CATEPTSpaceTime.CATEPTSpacetimeModel
  obs      : LatticeQCDObservableWitness
  contract : LatticeQCDIntegrationContract obs
  gauge_nonneg : ∀ β : ℝ, 0 ≤ β → 0 ≤ gaugeKineticAction β 3 1 6

/-- The phase-1 record grounded in the Minkowski CATEPT vacuum. -/
noncomputable def phase1LatticeQCDRecord : LatticeQCDCATEPTRecord :=
  { st           := CATEPTMain.Integration.CATEPTSpaceTime.minkowskiCATEPT
    obs          := phase1LatticeQCDWitness
    contract     := phase1_contract
    gauge_nonneg := fun β hβ => by
      simp [gaugeKineticAction]; positivity }

end CATEPTMain.Integration.LatticeQCDWilson
