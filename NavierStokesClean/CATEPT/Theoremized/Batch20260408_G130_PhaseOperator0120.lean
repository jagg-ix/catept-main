import Mathlib

/-!
# Batch 20260408 Theoremization - Global Row 130

Phase-operator scaffold extracted from
`0120_implementation_for_phase_operator.le.lean`.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.G130

noncomputable section

structure PhaseOperator (H : Type) where
  operator : H → H
  eigenstates : List H

def PhaseOperator.apply {H : Type} (P : PhaseOperator H) (state : H) : H :=
  P.operator state

def PhaseOperator.eigenvalues {H : Type} (P : PhaseOperator H) : List ℝ :=
  (List.range P.eigenstates.length).map (fun i =>
    2 * Real.pi * (i : ℝ) / max 1 (P.eigenstates.length : ℝ))

def PhaseOperator.projectOntoEigenstate
    {H : Type} (P : PhaseOperator H)
    (inner : H → H → ℂ) (scale : H → ℂ → H) (state : H) (idx : Nat) : H :=
  let safeState := P.eigenstates.getD idx (P.eigenstates.getD 0 state)
  scale safeState (inner safeState state)

theorem apply_def {H : Type} (P : PhaseOperator H) (state : H) :
    P.apply state = P.operator state := rfl

theorem eigenvalues_length {H : Type} (P : PhaseOperator H) :
    P.eigenvalues.length = P.eigenstates.length := by
  unfold PhaseOperator.eigenvalues
  simp

theorem projectOntoEigenstate_zero_index
    {H : Type} (P : PhaseOperator H)
    (inner : H → H → ℂ) (scale : H → ℂ → H) (state : H) :
    P.projectOntoEigenstate inner scale state 0 =
      scale (P.eigenstates.getD 0 (P.eigenstates.getD 0 state))
        (inner (P.eigenstates.getD 0 (P.eigenstates.getD 0 state)) state) := by
  unfold PhaseOperator.projectOntoEigenstate
  simp

def createPeggBarnett (dimension : Nat) : PhaseOperator ℂ :=
  { operator := fun z => z
    eigenstates := (List.range dimension).map (fun m =>
      Complex.exp (Complex.I * (2 * Real.pi * (m : ℝ) / max 1 (dimension : ℝ)))) }

def createSusskindGlogower : PhaseOperator ℂ :=
  { operator := fun z => z
    eigenstates := createPeggBarnett 20 |>.eigenstates }

theorem createPeggBarnett_length (n : Nat) :
    (createPeggBarnett n).eigenstates.length = n := by
  simp [createPeggBarnett]

theorem createSusskindGlogower_length :
    createSusskindGlogower.eigenstates.length = 20 := by
  simp [createSusskindGlogower, createPeggBarnett]

end

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.G130
