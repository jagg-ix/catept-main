import NavierStokesClean.CATEPT.CovariantDerivative

/-!
# Curved Maxwell Unification (coordinate kernel)

Concrete implementation of a curved-space Maxwell layer on top of the existing
CAT/EPT GR tensor kernel.

This file provides:

- Faraday tensor from a potential (`F = dA`) in coordinates
- homogeneous Maxwell equation as cyclic derivative identity
- covariant divergence `∇_μ F^{μν}` for contravariant rank-2 tensors
- Minkowski specialization (`Γ = 0`) reducing covariant Maxwell to flat Maxwell
- Lorenz-gauge reduction from inhomogeneous Maxwell to wave equation

No axioms, no `sorry`.
-/

set_option autoImplicit false

open BigOperators

namespace NavierStokesClean.CATEPT

noncomputable section

variable {n : Type*} [Fintype n] [DecidableEq n]

abbrev OneForm (n : Type*) : Type _ := CoordVec n -> n -> ℝ
abbrev TwoTensor (n : Type*) : Type _ := CoordVec n -> n -> n -> ℝ
abbrev VectorCurrent (n : Type*) : Type _ := CoordVec n -> n -> ℝ

/-- Contract rule: partial derivative distributes over subtraction. -/
def PartialDerivSubRule (n : Type*) [Fintype n] [DecidableEq n] : Prop :=
  ∀ (f g : CoordVec n -> ℝ) (k : n) (x : CoordVec n),
    partialDeriv (fun y => f y - g y) k x = partialDeriv f k x - partialDeriv g k x

/-- Coordinate Faraday tensor from a potential one-form:
`F_{μν} = ∂_μ A_ν - ∂_ν A_μ`. -/
def faradayFromPotential (A : OneForm n) : TwoTensor n :=
  fun x μ ν =>
    partialDeriv (fun y => A y ν) μ x -
      partialDeriv (fun y => A y μ) ν x

/-- Antisymmetry of `F = dA`. -/
theorem faradayFromPotential_antisymm
    (A : OneForm n) (x : CoordVec n) (μ ν : n) :
    faradayFromPotential A x μ ν = -faradayFromPotential A x ν μ := by
  unfold faradayFromPotential
  ring_nf

/-- Cyclic homogeneous Maxwell operator:
`∂_μ F_{νρ} + ∂_ν F_{ρμ} + ∂_ρ F_{μν}`. -/
def homogeneousCyclic (F : TwoTensor n) (μ ν ρ : n) (x : CoordVec n) : ℝ :=
  partialDeriv (fun y => F y ν ρ) μ x +
    partialDeriv (fun y => F y ρ μ) ν x +
    partialDeriv (fun y => F y μ ν) ρ x

/-- Mixed-partial commutator for one potential component. -/
def mixedPartialCommutator
    (A : OneForm n) (μ ν ρ : n) (x : CoordVec n) : ℝ :=
  partialDeriv (fun y => partialDeriv (fun z => A z ρ) ν y) μ x -
    partialDeriv (fun y => partialDeriv (fun z => A z ρ) μ y) ν x

/-- Exact decomposition of `d(dA)` into mixed-partial commutators. -/
theorem homogeneousCyclic_faraday_eq_mixedPartialCommutatorSum
    (A : OneForm n)
    (hSub : PartialDerivSubRule n)
    (μ ν ρ : n) (x : CoordVec n) :
    homogeneousCyclic (faradayFromPotential A) μ ν ρ x =
      mixedPartialCommutator A μ ν ρ x +
      mixedPartialCommutator A ν ρ μ x +
      mixedPartialCommutator A ρ μ ν x := by
  unfold homogeneousCyclic faradayFromPotential mixedPartialCommutator
  rw [hSub (fun y => partialDeriv (fun z => A z ρ) ν y)
      (fun y => partialDeriv (fun z => A z ν) ρ y) μ x]
  rw [hSub (fun y => partialDeriv (fun z => A z μ) ρ y)
      (fun y => partialDeriv (fun z => A z ρ) μ y) ν x]
  rw [hSub (fun y => partialDeriv (fun z => A z ν) μ y)
      (fun y => partialDeriv (fun z => A z μ) ν y) ρ x]
  ring_nf

/-- Symmetry of mixed partials for all potential components. -/
def MixedPartialSymmetric (A : OneForm n) : Prop :=
  ∀ (μ ν ρ : n) (x : CoordVec n), mixedPartialCommutator A μ ν ρ x = 0

/-- Homogeneous Maxwell equation for `F = dA` under mixed-partial symmetry. -/
theorem homogeneousCyclic_faraday_zero_of_mixedPartialSymmetric
    (A : OneForm n)
    (hSub : PartialDerivSubRule n)
    (hSymm : MixedPartialSymmetric A)
    (μ ν ρ : n) (x : CoordVec n) :
    homogeneousCyclic (faradayFromPotential A) μ ν ρ x = 0 := by
  rw [homogeneousCyclic_faraday_eq_mixedPartialCommutatorSum (A := A) (hSub := hSub)]
  simpa [hSymm μ ν ρ x, hSymm ν ρ μ x, hSymm ρ μ ν x]

/-- Covariant derivative of a contravariant rank-2 tensor:
`∇_k F^{ij} = ∂_k F^{ij} + Γ^i_{kl} F^{lj} + Γ^j_{kl} F^{il}`. -/
def covariantDerivTwoContravariant
    (g : MetricField n) (F : TwoTensor n)
    (k i j : n) (x : CoordVec n) : ℝ :=
  partialDeriv (fun y => F y i j) k x +
    (∑ l : n, christoffel g x i k l * F x l j) +
    (∑ l : n, christoffel g x j k l * F x i l)

/-- Covariant divergence `∇_μ F^{μν}` in index-contracted coordinate form. -/
def covariantDivTwoContravariant
    (g : MetricField n) (F : TwoTensor n)
    (ν : n) (x : CoordVec n) : ℝ :=
  ∑ μ : n, covariantDerivTwoContravariant g F μ μ ν x

/-- Flat (partial) divergence `∂_μ F^{μν}`. -/
def partialDivTwoContravariant
    (F : TwoTensor n)
    (ν : n) (x : CoordVec n) : ℝ :=
  ∑ μ : n, partialDeriv (fun y => F y μ ν) μ x

/-- In Minkowski spacetime, `∇_k F^{ij}` reduces to `∂_k F^{ij}`. -/
theorem covariantDerivTwoContravariant_minkowski_eq_partial
    (F : TwoTensor (Fin 4))
    (k i j : Fin 4) (x : CoordVec (Fin 4)) :
    covariantDerivTwoContravariant minkowskiMetric F k i j x =
      partialDeriv (fun y => F y i j) k x := by
  simp [covariantDerivTwoContravariant, christoffel_eq_zero_minkowski]

/-- In Minkowski spacetime, `∇_μ F^{μν} = ∂_μ F^{μν}`. -/
theorem covariantDivTwoContravariant_minkowski_eq_partial
    (F : TwoTensor (Fin 4))
    (ν : Fin 4) (x : CoordVec (Fin 4)) :
    covariantDivTwoContravariant minkowskiMetric F ν x =
      partialDivTwoContravariant F ν x := by
  simp [covariantDivTwoContravariant, partialDivTwoContravariant,
    covariantDerivTwoContravariant_minkowski_eq_partial]

/-- Flat divergence of a one-form `A`: `∂_μ A^μ` (coordinate contraction). -/
def partialDivOneForm (A : OneForm n) (x : CoordVec n) : ℝ :=
  ∑ μ : n, partialDeriv (fun y => A y μ) μ x

/-- Coordinate gradient of `∂·A` in component `ν`: `∂_ν(∂·A)`. -/
def gradPartialDivOneForm (A : OneForm n) (ν : n) (x : CoordVec n) : ℝ :=
  ∑ μ : n, partialDeriv (fun y => partialDeriv (fun z => A z μ) μ y) ν x

/-- Flat wave operator on potential component `A_ν`:
`□A_ν := ∑_μ ∂_μ∂_μ A_ν`. -/
def wavePotential (A : OneForm n) (ν : n) (x : CoordVec n) : ℝ :=
  ∑ μ : n, partialDeriv (fun y => partialDeriv (fun z => A z ν) μ y) μ x

/-- Divergence-level mixed-partial commutator sum
`∑_μ (∂_μ∂_ν A_μ - ∂_ν∂_μ A_μ)`. -/
def divergenceCommutator (A : OneForm n) (ν : n) (x : CoordVec n) : ℝ :=
  ∑ μ : n,
    (partialDeriv (fun y => partialDeriv (fun z => A z μ) ν y) μ x -
      partialDeriv (fun y => partialDeriv (fun z => A z μ) μ y) ν x)

/-- Exact flat identity for `F = dA`:
`∂_μ F^{μν} = □A_ν - ∂_ν(∂·A) - comm(A,ν)`. -/
theorem partialDiv_faraday_eq_wave_sub_gradDiv_sub_commutator
    (A : OneForm n)
    (hSub : PartialDerivSubRule n)
    (ν : n) (x : CoordVec n) :
    partialDivTwoContravariant (faradayFromPotential A) ν x =
      wavePotential A ν x - gradPartialDivOneForm A ν x - divergenceCommutator A ν x := by
  unfold partialDivTwoContravariant faradayFromPotential
  have hExpand :
      (∑ μ : n, partialDeriv
        (fun y =>
          partialDeriv (fun z => A z ν) μ y - partialDeriv (fun z => A z μ) ν y)
        μ x) =
      ∑ μ : n,
        (partialDeriv (fun y => partialDeriv (fun z => A z ν) μ y) μ x -
          partialDeriv (fun y => partialDeriv (fun z => A z μ) ν y) μ x) := by
    refine Finset.sum_congr rfl ?_
    intro μ hμ
    simpa using hSub
      (fun y => partialDeriv (fun z => A z ν) μ y)
      (fun y => partialDeriv (fun z => A z μ) ν y)
      μ x
  rw [hExpand]
  unfold wavePotential gradPartialDivOneForm divergenceCommutator
  repeat rw [Finset.sum_sub_distrib]
  ring

/-- Symmetry condition needed to cancel divergence commutator terms. -/
def DivergenceMixedPartialSymmetric (A : OneForm n) : Prop :=
  ∀ (μ ν : n) (x : CoordVec n),
    partialDeriv (fun y => partialDeriv (fun z => A z μ) ν y) μ x =
      partialDeriv (fun y => partialDeriv (fun z => A z μ) μ y) ν x

/-- Commutator sum vanishes under divergence-level mixed-partial symmetry. -/
theorem divergenceCommutator_eq_zero_of_symmetry
    (A : OneForm n)
    (hSymm : DivergenceMixedPartialSymmetric A)
    (ν : n) (x : CoordVec n) :
    divergenceCommutator A ν x = 0 := by
  unfold divergenceCommutator
  refine Finset.sum_eq_zero ?_
  intro μ hμ
  linarith [hSymm μ ν x]

/-- Flat identity with commuting mixed partials:
`∂_μ F^{μν} = □A_ν - ∂_ν(∂·A)`. -/
theorem partialDiv_faraday_eq_wave_sub_gradDiv_of_symmetry
    (A : OneForm n)
    (hSub : PartialDerivSubRule n)
    (hSymm : DivergenceMixedPartialSymmetric A)
    (ν : n) (x : CoordVec n) :
    partialDivTwoContravariant (faradayFromPotential A) ν x =
      wavePotential A ν x - gradPartialDivOneForm A ν x := by
  rw [partialDiv_faraday_eq_wave_sub_gradDiv_sub_commutator (A := A) (hSub := hSub)]
  simp [divergenceCommutator_eq_zero_of_symmetry, hSymm]

/-- Lorenz gauge in flat coordinates: `∂·A = 0`. -/
def LorenzGauge (A : OneForm n) : Prop :=
  ∀ x : CoordVec n, partialDivOneForm A x = 0

/-- Differentiated Lorenz-gauge closure: `∂_ν(∂·A)=0` for all components. -/
def LorenzGaugeGradient (A : OneForm n) : Prop :=
  ∀ (ν : n) (x : CoordVec n), gradPartialDivOneForm A ν x = 0

/-- Bundle carrying Lorenz gauge plus its differentiated closure law. -/
def LorenzGaugeClosure (A : OneForm n) : Prop :=
  LorenzGauge A ∧ LorenzGaugeGradient A

/-- Under Lorenz gauge and commuting mixed partials:
`∂_μ F^{μν} = □A_ν`. -/
theorem partialDiv_faraday_eq_wave_of_lorenzGauge
    (A : OneForm n)
    (hSub : PartialDerivSubRule n)
    (hGauge : LorenzGaugeClosure A)
    (hSymm : DivergenceMixedPartialSymmetric A)
    (ν : n) (x : CoordVec n) :
    partialDivTwoContravariant (faradayFromPotential A) ν x = wavePotential A ν x := by
  rcases hGauge with ⟨_, hGaugeGrad⟩
  rw [partialDiv_faraday_eq_wave_sub_gradDiv_of_symmetry
    (A := A) (hSub := hSub) (hSymm := hSymm) (ν := ν) (x := x)]
  rw [hGaugeGrad ν x]
  ring

/-- Homogeneous curved Maxwell equation (`dF = 0` in coordinates). -/
def MaxwellHomogeneous (F : TwoTensor n) : Prop :=
  ∀ (μ ν ρ : n) (x : CoordVec n), homogeneousCyclic F μ ν ρ x = 0

/-- Inhomogeneous curved Maxwell equation (`∇_μ F^{μν} = J^ν`). -/
def MaxwellInhomogeneousCurved
    (g : MetricField n) (F : TwoTensor n) (J : VectorCurrent n) : Prop :=
  ∀ (ν : n) (x : CoordVec n), covariantDivTwoContravariant g F ν x = J x ν

/-- Flat inhomogeneous Maxwell equation (`∂_μ F^{μν} = J^ν`). -/
def MaxwellInhomogeneousFlatTensor
    (F : TwoTensor n) (J : VectorCurrent n) : Prop :=
  ∀ (ν : n) (x : CoordVec n), partialDivTwoContravariant F ν x = J x ν

/-- Flat inhomogeneous Maxwell equation written via potential (`F = dA`). -/
def MaxwellInhomogeneousFlatPotential
    (A : OneForm n) (J : VectorCurrent n) : Prop :=
  MaxwellInhomogeneousFlatTensor (faradayFromPotential A) J

/-- Flat wave equation target for potential components (`□A = J`). -/
def WaveEquationFlatPotential
    (A : OneForm n) (J : VectorCurrent n) : Prop :=
  ∀ (ν : n) (x : CoordVec n), wavePotential A ν x = J x ν

/-- Curved inhomogeneous Maxwell on Minkowski is equivalent to flat inhomogeneous Maxwell. -/
theorem maxwellInhomogeneousCurved_minkowski_iff_flat
    (F : TwoTensor (Fin 4)) (J : VectorCurrent (Fin 4)) :
    MaxwellInhomogeneousCurved minkowskiMetric F J ↔
      MaxwellInhomogeneousFlatTensor F J := by
  constructor
  · intro h ν x
    have hx : covariantDivTwoContravariant minkowskiMetric F ν x = J x ν := h ν x
    simpa [MaxwellInhomogeneousFlatTensor,
      covariantDivTwoContravariant_minkowski_eq_partial] using hx
  · intro h ν x
    have hx : partialDivTwoContravariant F ν x = J x ν := h ν x
    simpa [MaxwellInhomogeneousFlatTensor,
      covariantDivTwoContravariant_minkowski_eq_partial] using hx

/-- Flat potential form: Maxwell + Lorenz gauge + commuting mixed partials imply wave equation. -/
theorem flatMaxwellPotential_implies_wave_of_lorenzGauge
    (A : OneForm n) (J : VectorCurrent n)
    (hSub : PartialDerivSubRule n)
    (hMaxwell : MaxwellInhomogeneousFlatPotential A J)
    (hGauge : LorenzGaugeClosure A)
    (hSymm : DivergenceMixedPartialSymmetric A) :
    WaveEquationFlatPotential A J := by
  intro ν x
  have hDiv :
      partialDivTwoContravariant (faradayFromPotential A) ν x = J x ν :=
    hMaxwell ν x
  have hWave :
      partialDivTwoContravariant (faradayFromPotential A) ν x = wavePotential A ν x :=
    partialDiv_faraday_eq_wave_of_lorenzGauge
      (A := A) (hSub := hSub) (hGauge := hGauge) (hSymm := hSymm) ν x
  calc
    wavePotential A ν x = partialDivTwoContravariant (faradayFromPotential A) ν x := by
      simpa using hWave.symm
    _ = J x ν := hDiv

/-- Curved-space unification theorem on Minkowski background:
`∇_μ F^{μν} = J^ν`, `F=dA`, Lorenz gauge, and mixed-partial symmetry imply
`□A_ν = J_ν`. -/
theorem curvedMaxwell_minkowski_implies_wave_of_lorenzGauge
    (A : OneForm (Fin 4)) (J : VectorCurrent (Fin 4))
    (hSub : PartialDerivSubRule (Fin 4))
    (hCurved : MaxwellInhomogeneousCurved minkowskiMetric (faradayFromPotential A) J)
    (hGauge : LorenzGaugeClosure A)
    (hSymm : DivergenceMixedPartialSymmetric A) :
    WaveEquationFlatPotential A J := by
  have hFlat : MaxwellInhomogeneousFlatPotential A J :=
    (maxwellInhomogeneousCurved_minkowski_iff_flat
      (F := faradayFromPotential A) (J := J)).1 hCurved
  exact flatMaxwellPotential_implies_wave_of_lorenzGauge
    (A := A) (J := J) hSub hFlat hGauge hSymm

/-- Homogeneous Maxwell equation in potential form (`F=dA`). -/
theorem maxwellHomogeneous_of_potential
    (A : OneForm n)
    (hSub : PartialDerivSubRule n)
    (hSymm : MixedPartialSymmetric A) :
    MaxwellHomogeneous (faradayFromPotential A) := by
  intro μ ν ρ x
  exact homogeneousCyclic_faraday_zero_of_mixedPartialSymmetric A hSub hSymm μ ν ρ x

end

end NavierStokesClean.CATEPT
