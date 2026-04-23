import Mathlib

set_option autoImplicit false

namespace CATEPTMain.CATEPT

noncomputable section

/-- Abstract gauge link in `Dim` dimensions. -/
structure GLink (Dim : ℕ) where
  direction : Fin Dim
  isdag : Bool
  deriving DecidableEq

/-- Adjoint of a gauge link. -/
def GLink.adjoint {Dim : ℕ} (l : GLink Dim) : GLink Dim :=
  { direction := l.direction, isdag := !l.isdag }

@[simp] theorem GLink.adjoint_adjoint {Dim : ℕ} (l : GLink Dim) :
    l.adjoint.adjoint = l := by
  cases l
  simp [GLink.adjoint]

/-- Wilson line as an ordered list of links. -/
abbrev WilsonLine (Dim : ℕ) : Type := List (GLink Dim)

/-- Adjoint of a Wilson line (reverse + link adjoint). -/
def WilsonLine.adjoint {Dim : ℕ} (w : WilsonLine Dim) : WilsonLine Dim :=
  (w.map GLink.adjoint).reverse

@[simp] theorem WilsonLine.adjoint_adjoint {Dim : ℕ} (w : WilsonLine Dim) :
    w.adjoint.adjoint = w := by
  unfold WilsonLine.adjoint
  simp [List.map_reverse, List.reverse_reverse, List.map_map]
  have h : GLink.adjoint ∘ GLink.adjoint = @id (GLink Dim) := by
    funext x
    rcases x with ⟨dir, isdag⟩
    simp [GLink.adjoint]
  rw [h]
  simp

@[simp] theorem WilsonLine.adjoint_append {Dim : ℕ}
    (w1 w2 : WilsonLine Dim) :
    (w1 ++ w2).adjoint = w2.adjoint ++ w1.adjoint := by
  simp [WilsonLine.adjoint, List.map_append, List.reverse_append]

/-- Minimal plaquette skeleton with four links. -/
def makePlaquette {Dim : ℕ} (μ ν : Fin Dim) : WilsonLine Dim :=
  [ { direction := μ, isdag := false }
  , { direction := ν, isdag := false }
  , { direction := μ, isdag := true }
  , { direction := ν, isdag := true } ]

@[simp] theorem makePlaquette_length {Dim : ℕ} (μ ν : Fin Dim) :
    (makePlaquette μ ν).length = 4 := by
  simp [makePlaquette]

/-- Rectangular Wilson loop skeleton with perimeter `2(T+R)`. -/
def makeWilsonLoop {Dim : ℕ} (μ ν : Fin Dim) (T R : ℕ) : WilsonLine Dim :=
  List.replicate R { direction := μ, isdag := false } ++
  List.replicate T { direction := ν, isdag := false } ++
  List.replicate R { direction := μ, isdag := true } ++
  List.replicate T { direction := ν, isdag := true }

theorem makeWilsonLoop_length {Dim : ℕ} (μ ν : Fin Dim) (T R : ℕ) :
    (makeWilsonLoop μ ν T R).length = 2 * (T + R) := by
  simp [makeWilsonLoop, List.length_append, List.length_replicate]
  ring

/-- Polyakov loop skeleton with temporal length `L`. -/
def makePolyakovLoop {Dim : ℕ} (μ : Fin Dim) (L : ℕ) : WilsonLine Dim :=
  List.replicate L { direction := μ, isdag := false }

@[simp] theorem makePolyakovLoop_length {Dim : ℕ} (μ : Fin Dim) (L : ℕ) :
    (makePolyakovLoop μ L).length = L := by
  simp [makePolyakovLoop]

/-- Area-law model for Wilson loop expectation value. -/
def wilsonLoopAreaLaw (sigma T R : ℝ) : ℝ :=
  Real.exp (-sigma * T * R)

theorem wilsonLoopAreaLaw_nonneg (sigma T R : ℝ) :
    0 ≤ wilsonLoopAreaLaw sigma T R := by
  unfold wilsonLoopAreaLaw
  exact Real.exp_nonneg _

theorem wilsonLoopAreaLaw_le_one
    (sigma T R : ℝ)
    (hsigma : 0 ≤ sigma)
    (hT : 0 ≤ T)
    (hR : 0 ≤ R) :
    wilsonLoopAreaLaw sigma T R ≤ 1 := by
  unfold wilsonLoopAreaLaw
  rw [Real.exp_le_one_iff]
  have h1 : 0 ≤ sigma * T := mul_nonneg hsigma hT
  have h2 : 0 ≤ sigma * T * R := mul_nonneg h1 hR
  have h3 : -(sigma * T * R) ≤ 0 := neg_nonpos.mpr h2
  have h4 : -sigma * T * R = -(sigma * T * R) := by ring
  rw [h4]; exact h3/-- Compatibility witness for QCD integration into core CAT/EPT. -/
structure QCDCompatibilityWitness where
  gaugeLinkAlgebraAvailable : Prop
  wilsonLoopObservableAvailable : Prop
  polyakovLoopObservableAvailable : Prop
  topologicalChargeAvailable : Prop
  areaLawConfinementAvailable : Prop
  deconfinementTransitionAvailable : Prop

def qcdCompatibilityContract (w : QCDCompatibilityWitness) : Prop :=
  w.gaugeLinkAlgebraAvailable ∧
    w.wilsonLoopObservableAvailable ∧
    w.polyakovLoopObservableAvailable ∧
    w.topologicalChargeAvailable ∧
    w.areaLawConfinementAvailable ∧
    w.deconfinementTransitionAvailable

theorem qcdCompatibility_contract_of_fields
    (w : QCDCompatibilityWitness)
    (h1 : w.gaugeLinkAlgebraAvailable)
    (h2 : w.wilsonLoopObservableAvailable)
    (h3 : w.polyakovLoopObservableAvailable)
    (h4 : w.topologicalChargeAvailable)
    (h5 : w.areaLawConfinementAvailable)
    (h6 : w.deconfinementTransitionAvailable) :
    qcdCompatibilityContract w :=
  ⟨h1, h2, h3, h4, h5, h6⟩


