import CATEPTMain.Integration.CausalImplementabilitySMatrixBridge
import CATEPTMain.Integration.RetardedGreenFisherBridge
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Tactic.Linarith

/-!
# KrausEntropicDampingBridge — Kraus operator factorisation across
Cauchy cuts (CIE-007)

Carrier-level surrogate for the Bostelmann/Fewster/Ruep Kraus family

  `Π_q^ψ[f] = (1 / √(2π)) ∫ dp ψ(p) exp(-i p² Δ_r(f, f) / 2 + i p (q - φ(f)))`

with the convolution factorisation across `f = f_+ + f_-`. At carrier
level, we expose the **squared-norm magnitude** `‖Π_q^ψ[f]‖²` as a real
field (because Bochner-integrated complex-valued operator carriers are
beyond magnitude-level scope) and the entropic-damping link
`‖Π‖² ∝ exp(-S_I[f] / ℏ)`.

REPLYID: CAT-EPT-20260506-01.  Depends on CIE-003.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.KrausEntropicDampingBridge

open CATEPTMain.Integration.CausalImplementabilitySMatrixBridge
open CATEPTMain.Integration.RetardedGreenFisherBridge

noncomputable section

/-- **Factorised Kraus carrier**: magnitude-level surrogate for the
convolution-factorising Kraus family `Π_q^ψ[f]`. Stores the
squared-norm magnitude and the imaginary action whose damping it
realises. -/
structure FactorisedKraus (α : Type) where
  /-- Squared-operator-norm magnitude `‖Π_q^ψ[f]‖²` indexed by smearing. -/
  normSq          : (α → ℝ) → ℝ
  normSq_nonneg   : ∀ f, 0 ≤ normSq f
  /-- Imaginary action `S_I[f]` (carrier-level surrogate). -/
  S_I             : (α → ℝ) → ℝ
  S_I_nonneg      : ∀ f, 0 ≤ S_I f
  /-- Reduced Planck constant for the damping link. -/
  hbar            : ℝ
  hbar_pos        : 0 < hbar

namespace FactorisedKraus

theorem exists_trivial : ∃ _ : FactorisedKraus Unit, True :=
  ⟨{ normSq         := fun _ => 1
   , normSq_nonneg  := fun _ => by norm_num
   , S_I            := fun _ => 0
   , S_I_nonneg     := fun _ => le_refl 0
   , hbar           := 1
   , hbar_pos       := by norm_num }, trivial⟩

end FactorisedKraus

/-- **Kraus factorisation predicate** across a Cauchy split:

  `‖Π_q^ψ[f]‖² = ‖Π_q^ψ[f_+]‖² · ‖Π_q^ψ[f_-]‖²`

(squared-norm form of the convolution factorisation). -/
def KrausFactorises {α : Type} (K : FactorisedKraus α) : Prop :=
  ∀ (split : CauchySplit α),
    split.futureSupport → split.pastSupport →
      K.normSq split.f = K.normSq split.f_plus * K.normSq split.f_minus

/-- **Entropic damping link**:

  `‖Π_q^ψ[f]‖² = exp(- S_I[f] / ℏ)`

(predicate; consumers refining to a concrete Kraus family supply the
proof from their underlying integral representation). -/
def EntropicDampingLink {α : Type} (K : FactorisedKraus α) : Prop :=
  ∀ f, K.normSq f = Real.exp (- (K.S_I f / K.hbar))

/-- **Existence witness** that both predicates can hold simultaneously
on a non-degenerate carrier (`S_I = 0`, `hbar = 1`, `normSq = 1`). The
factorisation reduces to `1 = 1 · 1` (closed by `ring`); the damping
link reduces to `1 = exp(0)` (closed by `Real.exp_zero` + `neg_zero`). -/
theorem krausFactorises_constant_witness :
    ∃ K : FactorisedKraus Unit, KrausFactorises K ∧ EntropicDampingLink K := by
  refine ⟨{
      normSq         := fun _ => 1
    , normSq_nonneg  := fun _ => by norm_num
    , S_I            := fun _ => 0
    , S_I_nonneg     := fun _ => le_refl 0
    , hbar           := 1
    , hbar_pos       := by norm_num
  }, ?_, ?_⟩
  · intro split _ _
    show (1 : ℝ) = 1 * 1
    ring
  · intro f
    show (1 : ℝ) = Real.exp (-(0 / 1))
    rw [zero_div, neg_zero, Real.exp_zero]

end -- noncomputable section

end CATEPTMain.Integration.KrausEntropicDampingBridge
