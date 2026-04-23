import Mathlib

/-!
# Batch 20260408 Theoremization - Global Row 152

DSF modal-logic scaffold extracted from
`0121_implementation_for_dsf_modal_logic.l.lean`.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.G152

noncomputable section

inductive ModalOperator where
  | necessity
  | possibility
  | actuality
  | physicality

deriving DecidableEq, Repr

inductive ModalFormula where
  | atom (p : String)
  | neg (φ : ModalFormula)
  | and (φ ψ : ModalFormula)
  | or (φ ψ : ModalFormula)
  | implies (φ ψ : ModalFormula)
  | modal (op : ModalOperator) (φ : ModalFormula)

deriving DecidableEq, Repr

structure World where
  id : Nat
  isClassical : Bool
  isActual : Bool := false

deriving DecidableEq, Repr

def actualWorld : World :=
  { id := 0, isClassical := true, isActual := true }

def isPhysicalWorld (_w : World) : Bool := true

structure KripkeFrame where
  worlds : Finset World
  accessibility : World → World → Bool

namespace KripkeFrame

def accessibleWorlds (frame : KripkeFrame) (w : World) : Finset World :=
  frame.worlds.filter (fun w2 => frame.accessibility w w2)

end KripkeFrame

structure KripkeModel where
  frame : KripkeFrame
  valuation : String → Finset World

namespace KripkeModel

def evaluate (model : KripkeModel) : ModalFormula → World → Bool
  | ModalFormula.atom p, w => decide (w ∈ model.valuation p)
  | ModalFormula.neg ψ, w => !(evaluate model ψ w)
  | ModalFormula.and ψ χ, w => evaluate model ψ w && evaluate model χ w
  | ModalFormula.or ψ χ, w => evaluate model ψ w || evaluate model χ w
  | ModalFormula.implies ψ χ, w => !(evaluate model ψ w) || evaluate model χ w
  | ModalFormula.modal op ψ, w =>
      let ws := (model.frame.accessibleWorlds w).toList
      match op with
      | ModalOperator.necessity => ws.all (fun w' => evaluate model ψ w')
      | ModalOperator.possibility => ws.any (fun w' => evaluate model ψ w')
      | ModalOperator.actuality => evaluate model ψ actualWorld
      | ModalOperator.physicality => isPhysicalWorld w && evaluate model ψ w

end KripkeModel

def createDSFModalModel : KripkeModel :=
  let quantumWorlds : List World :=
    [{ id := 1, isClassical := false }, { id := 2, isClassical := false }]
  let classicalWorlds : List World :=
    [actualWorld, { id := 3, isClassical := true }]
  let allWorlds : Finset World := (quantumWorlds ++ classicalWorlds).toFinset
  let accessibility : World → World → Bool :=
    fun w1 w2 => if w1.isClassical then w2.isClassical else true
  let valuation : String → Finset World :=
    fun p =>
      if p = "classical" then classicalWorlds.toFinset
      else if p = "quantum" then quantumWorlds.toFinset
      else ∅
  { frame := { worlds := allWorlds, accessibility := accessibility }
    valuation := valuation }

theorem evaluate_atom_def (model : KripkeModel) (p : String) (w : World) :
    model.evaluate (ModalFormula.atom p) w = decide (w ∈ model.valuation p) := rfl

theorem evaluate_implies_def (model : KripkeModel) (φ ψ : ModalFormula) (w : World) :
    model.evaluate (ModalFormula.implies φ ψ) w =
      (!(model.evaluate φ w) || model.evaluate ψ w) := rfl

end

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.G152
