import Mathlib

/-!
# Batch 20260408 Theoremization - Global Row 116

Measurement-protocol scaffold extracted from
`0030_lean4_model_a_complete_verifiable_th.lean`.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.G116

noncomputable section

structure ActionPotential where
  energy : ℝ
  info : ℝ

abbrev QuantumState := List (ℝ × ℝ)

structure SystemTM where
  stateDist : QuantumState
  actionPotential : ActionPotential

structure ObserverTM where
  freeEnergy : ℝ
  internalEntropy : ℝ
  knowledge : List (ℝ × ℝ)

def choiceEnergyCost : ℝ := 1

/-- Observer spends one unit of free energy to emit an instruction signal. -/
def observerMakesChoice (obs : ObserverTM) : Option (ObserverTM × ActionPotential) :=
  if obs.freeEnergy < choiceEnergyCost then
    none
  else
    let newObserver : ObserverTM :=
      { freeEnergy := obs.freeEnergy - choiceEnergyCost
        internalEntropy := obs.internalEntropy + (choiceEnergyCost / 293.15)
        knowledge := obs.knowledge }
    let instruction : ActionPotential :=
      { energy := choiceEnergyCost, info := 1 }
    some (newObserver, instruction)

theorem observerMakesChoice_none_of_lt (obs : ObserverTM) (h : obs.freeEnergy < choiceEnergyCost) :
    observerMakesChoice obs = none := by
  unfold observerMakesChoice
  simp [h]

theorem observerMakesChoice_some_of_not_lt (obs : ObserverTM) (h : ¬ obs.freeEnergy < choiceEnergyCost) :
    ∃ obs' sig, observerMakesChoice obs = some (obs', sig) := by
  unfold observerMakesChoice
  simp [h]

/-- Activation adds signal energy/information to the current system potential. -/
def activateSystemTM (sys : SystemTM) (signal : ActionPotential) : SystemTM :=
  let newPotential : ActionPotential :=
    { energy := sys.actionPotential.energy + signal.energy
      info := sys.actionPotential.info + signal.info }
  { sys with
    actionPotential := newPotential
    stateDist := [(0.5, 1.0), (0.5, -1.0)] }

theorem activateSystemTM_energy
    (sys : SystemTM) (signal : ActionPotential) :
    (activateSystemTM sys signal).actionPotential.energy
      = sys.actionPotential.energy + signal.energy := by
  unfold activateSystemTM
  simp

theorem activateSystemTM_info
    (sys : SystemTM) (signal : ActionPotential) :
    (activateSystemTM sys signal).actionPotential.info
      = sys.actionPotential.info + signal.info := by
  unfold activateSystemTM
  simp

/-- Reading receipt appends one classical knowledge item. -/
def observerReadsReceipt (obs : ObserverTM) (receipt : ActionPotential) : ObserverTM :=
  { obs with knowledge := obs.knowledge ++ [(1, receipt.info)] }

theorem observerReadsReceipt_knowledge_length
    (obs : ObserverTM) (receipt : ActionPotential) :
    (observerReadsReceipt obs receipt).knowledge.length = obs.knowledge.length + 1 := by
  unfold observerReadsReceipt
  simp

end

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.G116
