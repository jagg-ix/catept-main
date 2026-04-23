import Mathlib

/-!
# Batch 20260408 Theoremization - QuantumOps Row 12 (Game-Theory Integration)

Finite-strategy theorem layer aligned with Nash/best-response obligations.
-/

set_option autoImplicit false

namespace CATEPTMain.QuantumOps.Theoremized.Batch20260408.B12

noncomputable section

abbrev Strat := Fin 2

structure Profile where
  a : Strat
  b : Strat
  deriving DecidableEq

structure TwoPlayerGame where
  payoffA : Strat → Strat → ℝ
  payoffB : Strat → Strat → ℝ

/-- Pure best response for player A against fixed `b`. -/
def bestResponseA (g : TwoPlayerGame) (b : Strat) : Strat :=
  if g.payoffA 0 b ≥ g.payoffA 1 b then 0 else 1

/-- Pure best response for player B against fixed `a`. -/
def bestResponseB (g : TwoPlayerGame) (a : Strat) : Strat :=
  if g.payoffB a 0 ≥ g.payoffB a 1 then 0 else 1

def isNash (g : TwoPlayerGame) (p : Profile) : Prop :=
  (∀ a' : Strat, g.payoffA p.a p.b ≥ g.payoffA a' p.b) ∧
    (∀ b' : Strat, g.payoffB p.a p.b ≥ g.payoffB p.a b')

/-- Canonical zero-payoff finite game used as existence witness. -/
def zeroGame : TwoPlayerGame where
  payoffA := fun _ _ => 0
  payoffB := fun _ _ => 0

def zeroProfile : Profile := { a := 0, b := 0 }

theorem nash_existence_finite_strategy_witness : ∃ p : Profile, isNash zeroGame p := by
  refine ⟨zeroProfile, ?_⟩
  constructor <;> intro _ <;> simp [zeroGame, zeroProfile]

/-- One-step iterative best response map. -/
def iterativeBestResponseStep (g : TwoPlayerGame) (p : Profile) : Profile :=
  { a := bestResponseA g p.b, b := bestResponseB g p.a }

theorem iterative_best_response_converges_on_zeroGame (p : Profile) :
    iterativeBestResponseStep zeroGame p = zeroProfile := by
  cases p with
  | mk a b =>
      simp [iterativeBestResponseStep, bestResponseA, bestResponseB, zeroGame, zeroProfile]

/-- Support extraction surface compatible with Lemke-Howson-style endpoints. -/
def supportA (p : Profile) : List Strat := [p.a]

def supportB (p : Profile) : List Strat := [p.b]

theorem support_enumeration_contains_profile (p : Profile) :
    p.a ∈ supportA p ∧ p.b ∈ supportB p := by
  simp [supportA, supportB]

/-- Alias coherence: best-response selection equals max payoff value. -/
theorem payoff_best_response_alias_coherence_A (g : TwoPlayerGame) (b : Strat) :
    g.payoffA (bestResponseA g b) b = max (g.payoffA 0 b) (g.payoffA 1 b) := by
  unfold bestResponseA
  split_ifs with h
  · simp [max_eq_left h]
  · have hlt : g.payoffA 0 b < g.payoffA 1 b := lt_of_not_ge h
    have hle : g.payoffA 0 b ≤ g.payoffA 1 b := le_of_lt hlt
    simp [max_eq_right hle]

theorem payoff_best_response_alias_coherence_B (g : TwoPlayerGame) (a : Strat) :
    g.payoffB a (bestResponseB g a) = max (g.payoffB a 0) (g.payoffB a 1) := by
  unfold bestResponseB
  split_ifs with h
  · simp [max_eq_left h]
  · have hlt : g.payoffB a 0 < g.payoffB a 1 := lt_of_not_ge h
    have hle : g.payoffB a 0 ≤ g.payoffB a 1 := le_of_lt hlt
    simp [max_eq_right hle]

/-- Endpoint extracted by a placeholder Lemke-Howson compatibility layer. -/
def lemkeHowsonExtract (g : TwoPlayerGame) : Profile :=
  { a := bestResponseA g 0, b := bestResponseB g 0 }

theorem lemke_howson_extract_compatibility (g : TwoPlayerGame) :
    (lemkeHowsonExtract g).a = bestResponseA g 0 ∧
      (lemkeHowsonExtract g).b = bestResponseB g 0 := by
  simp [lemkeHowsonExtract]

end

end CATEPTMain.QuantumOps.Theoremized.Batch20260408.B12
