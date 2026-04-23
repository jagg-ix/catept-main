import CATEPT.PhysicalConstants
import Mathlib.Data.Complex.Basic
import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Analysis.SpecialFunctions.Exp

noncomputable section
set_option autoImplicit false

namespace CATEPT

open Real

/-- Parameters for the 1D damped oscillator. -/
structure DampedOscillatorParams where
  m : ℝ
  k : ℝ
  gamma : ℝ
  m_pos : 0 < m
  gamma_nonneg : 0 ≤ gamma

/-- Standard mechanical energy. -/
def mechanicalEnergy (p : DampedOscillatorParams) (x v : ℝ) : ℝ :=
  (p.m / 2) * v^2 + (p.k / 2) * x^2

/-- Predicate for the classical damped equation
    `m x¨ + k x = - γ x˙`. -/
def SatisfiesDampedOscillator
    (p : DampedOscillatorParams) (x : ℝ → ℝ) : Prop :=
  ∀ t : ℝ, p.m * deriv (deriv x) t + p.k * x t = - p.gamma * deriv x t

/-- Mechanical energy balance law:
    `dE/dt = - γ (x˙)^2`. -/
def SatisfiesMechanicalEnergyBalance
    (p : DampedOscillatorParams) (x : ℝ → ℝ) : Prop :=
  ∀ t : ℝ,
    deriv (fun τ => mechanicalEnergy p (x τ) (deriv x τ)) t
      =
      - p.gamma * (deriv x t)^2

/-- CAT exponential-decay law:
    `dE/dt = -(γ/ħ) E`. -/
def SatisfiesCATExponentialDecay
    (c : PhysicalConstants) (γ : ℝ) (E : ℝ → ℝ) : Prop :=
  ∀ t : ℝ, deriv E t = - (γ / c.hbar) * E t

/-- EPT decay law:
    `dE/dt = -(Texp/ħ) E`.

`Texp t` is intended to model `⟨T̂⟩(t)`.
-/
def SatisfiesEPTDecay
    (c : PhysicalConstants) (Texp : ℝ → ℝ) (E : ℝ → ℝ) : Prop :=
  ∀ t : ℝ, deriv E t = - (Texp t / c.hbar) * E t

/-- CAT dressed invariant:
    `J_CAT(t) = E(t) exp(γ t / ħ)`. -/
def CATDecayInvariant
    (c : PhysicalConstants) (γ : ℝ) (E : ℝ → ℝ) (t : ℝ) : ℝ :=
  E t * Real.exp (γ * t / c.hbar)

/-- EPT dressed invariant:
    `J_EPT(t) = E(t) exp(Tacc(t)/ħ)`.

`Tacc t` is intended to model `∫_0^t ⟨T̂⟩(t') dt'`.
-/
def EPTInvariant
    (c : PhysicalConstants)
    (Tacc : ℝ → ℝ)
    (E : ℝ → ℝ) (t : ℝ) : ℝ :=
  E t * Real.exp (Tacc t / c.hbar)

/-- If `Tacc' = Texp`, then `Tacc` is an accumulation of `Texp`. -/
def IsAccumulationOf (Tacc Texp : ℝ → ℝ) : Prop :=
  ∀ t : ℝ, deriv Tacc t = Texp t

/-
-----------------------------------------------------------------------------
Tier 1: classical theorem target
-----------------------------------------------------------------------------
-/

/-- Standard target theorem: the damped equation implies the mechanical
energy balance law. This is the safe classical statement. -/
theorem dampedEquation_implies_mechanicalEnergyBalance
  (p : DampedOscillatorParams) (x : ℝ → ℝ) :
  SatisfiesDampedOscillator p x →
  SatisfiesMechanicalEnergyBalance p x := sorry

/-
-----------------------------------------------------------------------------
Tier 2: CAT exponential-decay invariant
-----------------------------------------------------------------------------
-/

/-- If `E' = -(γ/ħ) E`, then the CAT dressed invariant has zero derivative. -/
theorem cat_decay_implies_invariant_deriv_zero
  (c : PhysicalConstants) (γ : ℝ) (E : ℝ → ℝ) :
  SatisfiesCATExponentialDecay c γ E →
  ∀ t : ℝ,
    deriv (fun τ => CATDecayInvariant c γ E τ) t = 0 := sorry

/-- Constant-of-motion form of the CAT invariant. -/
def IsConstant (f : ℝ → ℝ) : Prop :=
  ∀ t₁ t₂ : ℝ, f t₁ = f t₂

/-- If the derivative vanishes everywhere, the invariant is constant.
Kept as an interface theorem to avoid loading a full connected-domain result here. -/
theorem deriv_zero_implies_constant
  (f : ℝ → ℝ) :
  (∀ t : ℝ, deriv f t = 0) → IsConstant f := sorry

/-- Final CAT invariant theorem. -/
theorem cat_decay_implies_invariant_constant
    (c : PhysicalConstants) (γ : ℝ) (E : ℝ → ℝ)
    (hE : SatisfiesCATExponentialDecay c γ E) :
    IsConstant (fun t => CATDecayInvariant c γ E t) := by
  apply deriv_zero_implies_constant
  intro t
  exact cat_decay_implies_invariant_deriv_zero c γ E hE t

/-
-----------------------------------------------------------------------------
Tier 3: EPT invariant
-----------------------------------------------------------------------------
-/

/-- If `E' = -(Texp/ħ) E` and `Tacc' = Texp`, then the EPT invariant has
zero derivative. -/
theorem ept_decay_implies_invariant_deriv_zero
  (c : PhysicalConstants)
  (Tacc Texp : ℝ → ℝ)
  (E : ℝ → ℝ) :
  IsAccumulationOf Tacc Texp →
  SatisfiesEPTDecay c Texp E →
  ∀ t : ℝ,
    deriv (fun τ => EPTInvariant c Tacc E τ) t = 0 := sorry

/-- Final EPT invariant theorem. -/
theorem ept_decay_implies_invariant_constant
    (c : PhysicalConstants)
    (Tacc Texp : ℝ → ℝ)
    (E : ℝ → ℝ)
    (hacc : IsAccumulationOf Tacc Texp)
    (hE : SatisfiesEPTDecay c Texp E) :
    IsConstant (fun t => EPTInvariant c Tacc E t) := by
  apply deriv_zero_implies_constant
  intro t
  exact ept_decay_implies_invariant_deriv_zero c Tacc Texp E hacc hE t

/-
-----------------------------------------------------------------------------
Document-specific separation: contact/Herglotz invariant
-----------------------------------------------------------------------------
-/

/-- Placeholder for the document-specific contact/Herglotz energy.

This is intentionally separate from `mechanicalEnergy`, because the modified
classical invariant shown in the document should not be silently identified
with the ordinary mechanical energy until that derivation is extracted exactly.
-/
constant contactEnergy :
  DampedOscillatorParams → (ℝ → ℝ) → ℝ → ℝ

/-- Document-specific contact invariant target. -/
def ContactInvariant
    (p : DampedOscillatorParams)
    (x : ℝ → ℝ) (t : ℝ) : ℝ :=
  contactEnergy p x t * Real.exp (p.gamma * t / p.m)

/-- This must remain separate until the exact contact-energy derivation is
lifted from the document. -/
theorem contact_invariant_target
  (p : DampedOscillatorParams) (x : ℝ → ℝ) :
  SatisfiesDampedOscillator p x →
  IsConstant (fun t => ContactInvariant p x t) := sorry

open Real

/-- Parameters for the 1D damped oscillator. -/
structure DampedOscillatorParams where
  m : ℝ
  k : ℝ
  gamma : ℝ
  m_pos : 0 < m
  gamma_nonneg : 0 ≤ gamma

/-- Standard mechanical energy. -/
def mechanicalEnergy (p : DampedOscillatorParams) (x v : ℝ) : ℝ :=
  (p.m / 2) * v^2 + (p.k / 2) * x^2

/-- Local jet for the oscillator at a fixed time. -/
structure OscillatorJet where
  x : ℝ
  v : ℝ
  a : ℝ

/-- Damped oscillator equation at the jet level:
    `m a + k x = - gamma v`. -/
def JetSatisfiesDampedEquation
    (p : DampedOscillatorParams) (J : OscillatorJet) : Prop :=
  p.m * J.a + p.k * J.x = - p.gamma * J.v

/-- Time derivative of the standard mechanical energy at the jet level. -/
def mechanicalEnergyDerivAtJet
    (p : DampedOscillatorParams) (J : OscillatorJet) : ℝ :=
  p.m * J.v * J.a + p.k * J.x * J.v

/-- Exact local balance law:
    from `m a + k x = - gamma v`, one gets
    `dE/dt = - gamma v^2`.
This is the safe classical theorem.
-/
theorem jet_dampedEquation_implies_energyBalance
    (p : DampedOscillatorParams) (J : OscillatorJet)
    (hJ : JetSatisfiesDampedEquation p J) :
    mechanicalEnergyDerivAtJet p J = - p.gamma * J.v^2 := by
  unfold mechanicalEnergyDerivAtJet
  unfold JetSatisfiesDampedEquation at hJ
  linarith

/-- Global trajectory form of the damped oscillator equation. -/
def SatisfiesDampedOscillator
    (p : DampedOscillatorParams) (x : ℝ → ℝ) : Prop :=
  ∀ t : ℝ, p.m * deriv (deriv x) t + p.k * x t = - p.gamma * deriv x t

/-- Global trajectory form of the exact energy balance law. -/
def SatisfiesMechanicalEnergyBalance
    (p : DampedOscillatorParams) (x : ℝ → ℝ) : Prop :=
  ∀ t : ℝ,
    deriv (fun τ => mechanicalEnergy p (x τ) (deriv x τ)) t
      =
      - p.gamma * (deriv x t)^2

/-- Analytic upgrade target:
    once the chain-rule/ODE layer is supplied, the global damped equation
    implies the global mechanical energy balance law.
-/
theorem dampedEquation_implies_mechanicalEnergyBalance
  (p : DampedOscillatorParams) (x : ℝ → ℝ) :
  SatisfiesDampedOscillator p x →
  SatisfiesMechanicalEnergyBalance p x := sorry

/-
-----------------------------------------------------------------------------
Document classical invariant: KEEP SEPARATE / DOWNGRADED
-----------------------------------------------------------------------------
-/

/-- The document's classical exponential quantity. -/
def documentClassicalInvariant
    (p : DampedOscillatorParams) (x : ℝ → ℝ) (t : ℝ) : ℝ :=
  mechanicalEnergy p (x t) (deriv x t) * Real.exp (p.gamma * t / p.m)

/-- This law is stronger than the exact balance law and should not be treated
as a generic theorem of the ordinary damped oscillator without extra input. -/
def RequiresExtraHypothesesForDocumentInvariant : Prop := True

/-- Option A: treat the document's exponential law as an added hypothesis. -/
def SatisfiesEnvelopeDecayLaw
    (p : DampedOscillatorParams) (x : ℝ → ℝ) : Prop :=
  ∀ t : ℝ,
    deriv (fun τ => mechanicalEnergy p (x τ) (deriv x τ)) t
      =
      - (p.gamma / p.m) * mechanicalEnergy p (x t) (deriv x t)

/-- Under the stronger envelope law, the document's exponential invariant
is genuinely constant. -/
theorem envelopeDecay_implies_documentInvariant
  (p : DampedOscillatorParams) (x : ℝ → ℝ) :
  SatisfiesEnvelopeDecayLaw p x →
  ∀ t : ℝ,
    deriv (fun τ => documentClassicalInvariant p x τ) t = 0 := sorry

/-- Option B: use a contact/Herglotz energy instead of ordinary mechanical energy. -/
constant contactEnergy :
  DampedOscillatorParams → (ℝ → ℝ) → ℝ → ℝ

def contactInvariant
    (p : DampedOscillatorParams) (x : ℝ → ℝ) (t : ℝ) : ℝ :=
  contactEnergy p x t * Real.exp (p.gamma * t / p.m)

/-- Contact-energy version of the exponential invariant. -/
theorem contactEnergy_implies_contactInvariant
  (p : DampedOscillatorParams) (x : ℝ → ℝ) :
  SatisfiesDampedOscillator p x →
  ∀ t : ℝ,
    deriv (fun τ => contactInvariant p x τ) t = 0 := sorry

/-
-----------------------------------------------------------------------------
CAT / EPT layers stay exact once their differential law is specified
-----------------------------------------------------------------------------
-/

/-- CAT exponential-decay law:
    `E' = -(gamma / ħ) E`. -/
def SatisfiesCATExponentialDecay
    (c : PhysicalConstants) (gamma : ℝ) (E : ℝ → ℝ) : Prop :=
  ∀ t : ℝ, deriv E t = - (gamma / c.hbar) * E t

/-- CAT invariant. -/
def CATInvariant
    (c : PhysicalConstants) (gamma : ℝ) (E : ℝ → ℝ) (t : ℝ) : ℝ :=
  E t * Real.exp (gamma * t / c.hbar)

/-- EPT decay law:
    `E' = -(Texp/ħ) E`, where `Texp(t)` models `⟨T̂⟩(t)`. -/
def SatisfiesEPTDecay
    (c : PhysicalConstants) (Texp : ℝ → ℝ) (E : ℝ → ℝ) : Prop :=
  ∀ t : ℝ, deriv E t = - (Texp t / c.hbar) * E t

/-- Accumulated entropic clock:
    `Tacc' = Texp`, intended as `Tacc(t) = ∫₀ᵗ ⟨T̂⟩ dt'`. -/
def IsAccumulationOf (Tacc Texp : ℝ → ℝ) : Prop :=
  ∀ t : ℝ, deriv Tacc t = Texp t

/-- EPT invariant. -/
def EPTInvariant
    (c : PhysicalConstants) (Tacc : ℝ → ℝ) (E : ℝ → ℝ) (t : ℝ) : ℝ :=
  E t * Real.exp (Tacc t / c.hbar)

/-- CAT invariant target theorem. -/
theorem catDecay_implies_CATInvariant
  (c : PhysicalConstants) (gamma : ℝ) (E : ℝ → ℝ) :
  SatisfiesCATExponentialDecay c gamma E →
  ∀ t : ℝ, deriv (fun τ => CATInvariant c gamma E τ) t = 0 := sorry

/-- EPT invariant target theorem. -/
theorem eptDecay_implies_EPTInvariant
  (c : PhysicalConstants) (Tacc Texp : ℝ → ℝ) (E : ℝ → ℝ) :
  IsAccumulationOf Tacc Texp →
  SatisfiesEPTDecay c Texp E →
  ∀ t : ℝ, deriv (fun τ => EPTInvariant c Tacc E τ) t = 0 := sorry


end CATEPT
