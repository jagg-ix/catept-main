import Mathlib

/-!
# Batch 20260408 Theoremization - Global Row 68

DSF simulation-harness scaffold extracted from
`0074_implementation_for_dsfsimulationharn.lean`.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.G068

structure DSFSimulationConfig (State : Type) where
  initialState : State
  protocolChain : List (State → State)
  observables : List (String × (State → ℝ))
  nSteps : ℕ
  temperature : ℝ := 1.0
  timestep : ℝ := 0.1

/-- Apply protocol chain left-to-right to current state. -/
def applyProtocolChain {State : Type} (protocols : List (State → State)) (state : State) : State :=
  protocols.foldl (fun acc p => p acc) state

theorem applyProtocolChain_nil {State : Type} (state : State) :
    applyProtocolChain ([] : List (State → State)) state = state := by
  rfl

theorem applyProtocolChain_cons {State : Type} (p : State → State) (ps : List (State → State))
    (state : State) :
    applyProtocolChain (p :: ps) state = applyProtocolChain ps (p state) := by
  unfold applyProtocolChain
  simp

/-- Update named result series with optional measurements for matching keys. -/
def updateResults (results : List (String × List ℝ))
    (measurements : List (String × ℝ)) : List (String × List ℝ) :=
  results.map fun (name, values) =>
    let newValues :=
      measurements.filterMap (fun (mname, v) => if mname = name then some v else none)
    (name, values ++ newValues)

theorem updateResults_preserves_names (results : List (String × List ℝ))
    (measurements : List (String × ℝ)) :
    (updateResults results measurements).map Prod.fst = results.map Prod.fst := by
  unfold updateResults
  induction results with
  | nil =>
      simp
  | cons hd tl ih =>
      rcases hd with ⟨name, values⟩
      simp [ih]

def zipWithNext {α β : Type} (f : α → α → β) (l : List α) : List β :=
  match l with
  | [] => []
  | [_] => []
  | _ =>
      (List.zip l l.tail).map fun (a, b) => f a b

theorem zipWithNext_nil {α β : Type} (f : α → α → β) :
    zipWithNext f ([] : List α) = [] := by
  rfl

theorem zipWithNext_singleton {α β : Type} (f : α → α → β) (a : α) :
    zipWithNext f [a] = [] := by
  rfl

theorem zipWithNext_length_le {α β : Type} (f : α → α → β) (l : List α) :
    (zipWithNext f l).length ≤ l.length := by
  cases l with
  | nil =>
      simp [zipWithNext]
  | cons a tl =>
      cases tl with
      | nil =>
          simp [zipWithNext]
      | cons b tl2 =>
          unfold zipWithNext
          simp

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.G068

