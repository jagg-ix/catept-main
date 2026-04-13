import Mathlib

/-!
# Batch 20260408 Theoremization - Global Row 166

Information-conservation/interaction scaffold extracted from
`0024_formalization_in_lean4.lean`.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.G166

noncomputable section

structure ActionPotential where
  energy : ℝ
  info : ℝ

structure CompositeSystem where
  subsystemA : ActionPotential
  subsystemB : ActionPotential
  mutualInfo : ℝ

def totalInfo (sys : CompositeSystem) : ℝ :=
  sys.subsystemA.info + sys.subsystemB.info - sys.mutualInfo

structure Interaction where
  initialState : CompositeSystem
  finalState : CompositeSystem

def informationIsConserved (i : Interaction) : Prop :=
  totalInfo i.initialState = totalInfo i.finalState

theorem secondLawAsMutualInformation (i : Interaction)
    (hConserved : informationIsConserved i)
    (hIndependentInitially : i.initialState.mutualInfo = 0)
    (hCorrelatedFinally : i.finalState.mutualInfo > 0) :
    (i.finalState.subsystemA.info + i.finalState.subsystemB.info) >
      (i.initialState.subsystemA.info + i.initialState.subsystemB.info) := by
  have hTotal := hConserved
  unfold informationIsConserved totalInfo at hTotal
  rw [hIndependentInitially] at hTotal
  linarith [hTotal, hCorrelatedFinally]

theorem totalInfo_symmetric_swap (a b : ActionPotential) (m : ℝ) :
    totalInfo { subsystemA := a, subsystemB := b, mutualInfo := m } =
      totalInfo { subsystemA := b, subsystemB := a, mutualInfo := m } := by
  unfold totalInfo
  ring

end

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.G166
