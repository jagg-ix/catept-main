import Mathlib.Data.Complex.Basic
import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Mathlib.Analysis.Calculus.MeanValue
import CATEPTMain.CATEPT.CATEPT.PhysicalConstantsCommon

noncomputable section
set_option autoImplicit false

namespace CATEPTMain.CATEPT.CATEPT

open Real

-- ── Core definitions ─────────────────────────────────────────────────────────

-- `PhysicalConstants` is now provided by `PhysicalConstantsCommon` (T101).

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

/-- Global damped oscillator equation: `m x¨ + k x = -γ x˙`. -/
def SatisfiesDampedOscillator
    (p : DampedOscillatorParams) (x : ℝ → ℝ) : Prop :=
  ∀ t : ℝ, p.m * deriv (deriv x) t + p.k * x t = - p.gamma * deriv x t

/-- Mechanical energy balance law: `dE/dt = -γ (x˙)²`. -/
def SatisfiesMechanicalEnergyBalance
    (p : DampedOscillatorParams) (x : ℝ → ℝ) : Prop :=
  ∀ t : ℝ,
    deriv (fun τ => mechanicalEnergy p (x τ) (deriv x τ)) t
      = - p.gamma * (deriv x t)^2

/-- CAT exponential-decay law: `dE/dt = -(γ/ħ) E`. -/
def SatisfiesCATExponentialDecay
    (c : PhysicalConstants) (γ : ℝ) (E : ℝ → ℝ) : Prop :=
  ∀ t : ℝ, deriv E t = - (γ / c.hbar) * E t

/-- EPT decay law: `dE/dt = -(Texp/ħ) E`. -/
def SatisfiesEPTDecay
    (c : PhysicalConstants) (Texp : ℝ → ℝ) (E : ℝ → ℝ) : Prop :=
  ∀ t : ℝ, deriv E t = - (Texp t / c.hbar) * E t

/-- CAT dressed invariant: `J_CAT(t) = E(t) exp(γ t / ħ)`. -/
def CATDecayInvariant
    (c : PhysicalConstants) (γ : ℝ) (E : ℝ → ℝ) (t : ℝ) : ℝ :=
  E t * Real.exp (γ * t / c.hbar)

/-- CAT invariant (alias with `gamma` spelling for Tier-2 theorems). -/
def CATInvariant
    (c : PhysicalConstants) (gamma : ℝ) (E : ℝ → ℝ) (t : ℝ) : ℝ :=
  E t * Real.exp (gamma * t / c.hbar)

/-- EPT dressed invariant: `J_EPT(t) = E(t) exp(Tacc(t)/ħ)`. -/
def EPTInvariant
    (c : PhysicalConstants) (Tacc : ℝ → ℝ) (E : ℝ → ℝ) (t : ℝ) : ℝ :=
  E t * Real.exp (Tacc t / c.hbar)

/-- `Tacc' = Texp` means Tacc accumulates Texp. -/
def IsAccumulationOf (Tacc Texp : ℝ → ℝ) : Prop :=
  ∀ t : ℝ, deriv Tacc t = Texp t

/-- Constant-of-motion predicate. -/
def IsConstant (f : ℝ → ℝ) : Prop :=
  ∀ t₁ t₂ : ℝ, f t₁ = f t₂

-- ── Tier 1: classical energy balance ─────────────────────────────────────────

/-- The damped equation implies the mechanical energy balance law. -/
theorem dampedEquation_implies_mechanicalEnergyBalance
    (p : DampedOscillatorParams) (x : ℝ → ℝ)
    (hx_diff : Differentiable ℝ x) (hdx_diff : Differentiable ℝ (deriv x)) :
    SatisfiesDampedOscillator p x →
    SatisfiesMechanicalEnergyBalance p x := by
  intro hode t
  have hx_t  := (hx_diff t).hasDerivAt
  have hdx_t := (hdx_diff t).hasDerivAt
  have h_KE : HasDerivAt (fun τ => p.m / 2 * deriv x τ ^ 2)
      (p.m * deriv x t * deriv (deriv x) t) t := by
    have := ((hdx_t.mul hdx_t).const_mul (p.m / 2))
    convert this using 1
    · funext τ; simp only [Pi.mul_apply]; ring
    · ring
  have h_PE : HasDerivAt (fun τ => p.k / 2 * x τ ^ 2)
      (p.k * x t * deriv x t) t := by
    have := ((hx_t.mul hx_t).const_mul (p.k / 2))
    convert this using 1
    · funext τ; simp only [Pi.mul_apply]; ring
    · ring
  have h_E : HasDerivAt (fun τ => mechanicalEnergy p (x τ) (deriv x τ))
      (p.m * deriv x t * deriv (deriv x) t + p.k * x t * deriv x t) t := by
    have h_sum := h_KE.add h_PE
    have hfun : (fun τ => mechanicalEnergy p (x τ) (deriv x τ)) =
                fun τ => p.m / 2 * deriv x τ ^ 2 + p.k / 2 * x τ ^ 2 :=
      funext fun τ => by simp [mechanicalEnergy]
    rwa [hfun]
  rw [h_E.deriv]
  have heq := hode t
  calc p.m * deriv x t * deriv (deriv x) t + p.k * x t * deriv x t
      = (p.m * deriv (deriv x) t + p.k * x t) * deriv x t := by ring
    _ = (-p.gamma * deriv x t) * deriv x t := by rw [heq]
    _ = -p.gamma * (deriv x t) ^ 2 := by ring

-- ── Tier 2: CAT/EPT invariants ───────────────────────────────────────────────

/-- If `E' = -(γ/ħ) E`, the CAT dressed invariant has zero derivative. -/
theorem cat_decay_implies_invariant_deriv_zero
    (c : PhysicalConstants) (γ : ℝ) (E : ℝ → ℝ)
    (hE_diff : Differentiable ℝ E) :
    SatisfiesCATExponentialDecay c γ E →
    ∀ t : ℝ, deriv (fun τ => CATDecayInvariant c γ E τ) t = 0 := by
  intro hE t
  simp only [CATDecayInvariant]
  have hg : HasDerivAt (fun τ => γ * τ / c.hbar) (γ / c.hbar) t := by
    have h := ((hasDerivAt_id t).const_mul γ).div_const c.hbar
    simpa [mul_one] using h
  have hmul : HasDerivAt (fun τ => E τ * Real.exp (γ * τ / c.hbar))
      (deriv E t * Real.exp (γ * t / c.hbar) +
       E t * (Real.exp (γ * t / c.hbar) * (γ / c.hbar))) t :=
    (hE_diff t).hasDerivAt.mul hg.exp
  rw [hmul.deriv, hE t]; ring

/-- If the derivative vanishes everywhere, the function is constant. -/
theorem deriv_zero_implies_constant
    (f : ℝ → ℝ) (hf : Differentiable ℝ f) :
    (∀ t : ℝ, deriv f t = 0) → IsConstant f := by
  intro h t₁ t₂
  exact is_const_of_deriv_eq_zero hf h t₁ t₂

/-- CAT invariant is constant under the decay law. -/
theorem cat_decay_implies_invariant_constant
    (c : PhysicalConstants) (γ : ℝ) (E : ℝ → ℝ)
    (hE_diff : Differentiable ℝ E)
    (hE : SatisfiesCATExponentialDecay c γ E) :
    IsConstant (fun t => CATDecayInvariant c γ E t) := by
  have hJ : Differentiable ℝ (fun t => CATDecayInvariant c γ E t) := by
    unfold CATDecayInvariant; exact hE_diff.mul (by fun_prop)
  apply deriv_zero_implies_constant _ hJ
  intro t
  exact cat_decay_implies_invariant_deriv_zero c γ E hE_diff hE t

/-- If `E' = -(Texp/ħ) E` and `Tacc' = Texp`, the EPT invariant has zero derivative. -/
theorem ept_decay_implies_invariant_deriv_zero
    (c : PhysicalConstants) (Tacc Texp : ℝ → ℝ) (E : ℝ → ℝ)
    (hE_diff : Differentiable ℝ E) (hTacc_diff : Differentiable ℝ Tacc) :
    IsAccumulationOf Tacc Texp →
    SatisfiesEPTDecay c Texp E →
    ∀ t : ℝ, deriv (fun τ => EPTInvariant c Tacc E τ) t = 0 := by
  intro hacc hE t
  simp only [EPTInvariant]
  have hg : HasDerivAt (fun τ => Tacc τ / c.hbar) (Texp t / c.hbar) t := by
    have h := (hTacc_diff t).hasDerivAt.div_const c.hbar
    rwa [hacc t] at h
  have hmul : HasDerivAt (fun τ => E τ * Real.exp (Tacc τ / c.hbar))
      (deriv E t * Real.exp (Tacc t / c.hbar) +
       E t * (Real.exp (Tacc t / c.hbar) * (Texp t / c.hbar))) t :=
    (hE_diff t).hasDerivAt.mul hg.exp
  rw [hmul.deriv, hE t]; ring

/-- EPT invariant is constant under the decay law. -/
theorem ept_decay_implies_invariant_constant
    (c : PhysicalConstants) (Tacc Texp : ℝ → ℝ) (E : ℝ → ℝ)
    (hE_diff : Differentiable ℝ E) (hTacc_diff : Differentiable ℝ Tacc)
    (hacc : IsAccumulationOf Tacc Texp)
    (hE : SatisfiesEPTDecay c Texp E) :
    IsConstant (fun t => EPTInvariant c Tacc E t) := by
  have hJ : Differentiable ℝ (fun t => EPTInvariant c Tacc E t) := by
    unfold EPTInvariant
    exact hE_diff.mul ((hTacc_diff.div_const c.hbar).exp)
  apply deriv_zero_implies_constant _ hJ
  intro t
  exact ept_decay_implies_invariant_deriv_zero c Tacc Texp E hE_diff hTacc_diff hacc hE t

-- ── Contact/Herglotz invariant (opaque energy) ───────────────────────────────

/-- Opaque contact/Herglotz energy — intentionally separate from `mechanicalEnergy`
    until the exact derivation is extracted from the document. -/
opaque contactEnergy :
  DampedOscillatorParams → (ℝ → ℝ) → ℝ → ℝ

/-- Document-specific contact invariant. -/
def ContactInvariant
    (p : DampedOscillatorParams) (x : ℝ → ℝ) (t : ℝ) : ℝ :=
  contactEnergy p x t * Real.exp (p.gamma * t / p.m)

-- `contact_invariant_target` (proving `IsConstant (ContactInvariant p x)`
-- under `SatisfiesDampedOscillator p x` only) was previously a `:= sorry`
-- stub.  The unrestricted version requires functional analysis on
-- `contactEnergy` that is not in scope here; a stronger Option-A version
-- with an explicit envelope-decay hypothesis is proved below as
-- `envelopeDecay_implies_documentInvariant`.  No external callers
-- referenced the stub, so it is removed rather than re-stated.

-- ── Jet-level (local) theorems ────────────────────────────────────────────────

/-- Local jet for the oscillator at a fixed time. -/
structure OscillatorJet where
  x : ℝ
  v : ℝ
  a : ℝ

/-- Damped oscillator equation at the jet level: `m a + k x = -γ v`. -/
def JetSatisfiesDampedEquation
    (p : DampedOscillatorParams) (J : OscillatorJet) : Prop :=
  p.m * J.a + p.k * J.x = - p.gamma * J.v

/-- Time derivative of mechanical energy at the jet level. -/
def mechanicalEnergyDerivAtJet
    (p : DampedOscillatorParams) (J : OscillatorJet) : ℝ :=
  p.m * J.v * J.a + p.k * J.x * J.v

/-- Local balance law: from `m a + k x = -γ v` one gets `dE/dt = -γ v²`. -/
theorem jet_dampedEquation_implies_energyBalance
    (p : DampedOscillatorParams) (J : OscillatorJet)
    (hJ : JetSatisfiesDampedEquation p J) :
    mechanicalEnergyDerivAtJet p J = - p.gamma * J.v^2 := by
  unfold mechanicalEnergyDerivAtJet JetSatisfiesDampedEquation at *
  linear_combination J.v * hJ

-- ── Document classical invariant ─────────────────────────────────────────────

/-- The document's classical exponential invariant. -/
def documentClassicalInvariant
    (p : DampedOscillatorParams) (x : ℝ → ℝ) (t : ℝ) : ℝ :=
  mechanicalEnergy p (x t) (deriv x t) * Real.exp (p.gamma * t / p.m)

/-- Marker: the document invariant requires stronger hypotheses than the
    ordinary damped equation. -/
def RequiresExtraHypothesesForDocumentInvariant : Prop := True

/-- Option A: treat the envelope decay as an added hypothesis. -/
def SatisfiesEnvelopeDecayLaw
    (p : DampedOscillatorParams) (x : ℝ → ℝ) : Prop :=
  ∀ t : ℝ,
    deriv (fun τ => mechanicalEnergy p (x τ) (deriv x τ)) t
      = - (p.gamma / p.m) * mechanicalEnergy p (x t) (deriv x t)

/-- Under the envelope decay law the document's exponential invariant is constant. -/
theorem envelopeDecay_implies_documentInvariant
    (p : DampedOscillatorParams) (x : ℝ → ℝ)
    (hE_diff : Differentiable ℝ (fun τ => mechanicalEnergy p (x τ) (deriv x τ))) :
    SatisfiesEnvelopeDecayLaw p x →
    ∀ t : ℝ, deriv (fun τ => documentClassicalInvariant p x τ) t = 0 := by
  intro henv t
  have hg : HasDerivAt (fun τ => p.gamma * τ / p.m) (p.gamma / p.m) t := by
    have h := ((hasDerivAt_id t).const_mul p.gamma).div_const p.m
    simpa [mul_one] using h
  have hE := (hE_diff t).hasDerivAt
  have hmul := hE.mul hg.exp
  have hd : deriv (fun τ => documentClassicalInvariant p x τ) t =
      deriv (fun τ => mechanicalEnergy p (x τ) (deriv x τ)) t * Real.exp (p.gamma * t / p.m) +
      mechanicalEnergy p (x t) (deriv x t) * (Real.exp (p.gamma * t / p.m) * (p.gamma / p.m)) := by
    have hfun : (fun τ => documentClassicalInvariant p x τ) =
        (fun τ => mechanicalEnergy p (x τ) (deriv x τ)) * fun τ => Real.exp (p.gamma * τ / p.m) :=
      funext fun τ => by simp [documentClassicalInvariant, Pi.mul_apply]
    rw [hfun]; exact hmul.deriv
  rw [hd, henv t]; ring

/-- Option B: contact/Herglotz invariant alias (uses the opaque `contactEnergy`). -/
def contactInvariant
    (p : DampedOscillatorParams) (x : ℝ → ℝ) (t : ℝ) : ℝ :=
  contactEnergy p x t * Real.exp (p.gamma * t / p.m)

-- `contactEnergy_implies_contactInvariant` was previously a `:= sorry`
-- stub claiming `deriv (contactInvariant p x) t = 0` from
-- `SatisfiesDampedOscillator p x` alone.  The proof requires the
-- full Herglotz / contact-form derivation of `contactEnergy`, which is
-- not in scope here.  No external callers referenced the stub, so it is
-- removed rather than re-stated.  See
-- `envelopeDecay_implies_documentInvariant` (Option A) for a proven
-- version under an explicit envelope-decay hypothesis.

-- ── Tier 3: exact CAT/EPT invariant theorems (proved) ────────────────────────

/-- CAT invariant target theorem (uses `CATInvariant` spelling).
    Requires differentiability of E. -/
theorem catDecay_implies_CATInvariant
    (c : PhysicalConstants) (gamma : ℝ) (E : ℝ → ℝ)
    (hE_diff : Differentiable ℝ E) :
    SatisfiesCATExponentialDecay c gamma E →
    ∀ t : ℝ, deriv (fun τ => CATInvariant c gamma E τ) t = 0 := by
  intro hE t
  simp only [CATInvariant]
  have hg : HasDerivAt (fun τ => gamma * τ / c.hbar) (gamma / c.hbar) t := by
    have h := ((hasDerivAt_id t).const_mul gamma).div_const c.hbar
    simpa [mul_one] using h
  have hmul : HasDerivAt (fun τ => E τ * Real.exp (gamma * τ / c.hbar))
      (deriv E t * Real.exp (gamma * t / c.hbar) +
       E t * (Real.exp (gamma * t / c.hbar) * (gamma / c.hbar))) t :=
    (hE_diff t).hasDerivAt.mul hg.exp
  rw [hmul.deriv, hE t]; ring

/-- EPT invariant target theorem (uses `EPTInvariant` spelling).
    Requires differentiability of both E and Tacc. -/
theorem eptDecay_implies_EPTInvariant
    (c : PhysicalConstants) (Tacc Texp : ℝ → ℝ) (E : ℝ → ℝ)
    (hE_diff : Differentiable ℝ E) (hTacc_diff : Differentiable ℝ Tacc) :
    IsAccumulationOf Tacc Texp →
    SatisfiesEPTDecay c Texp E →
    ∀ t : ℝ, deriv (fun τ => EPTInvariant c Tacc E τ) t = 0 := by
  intro hacc hE t
  simp only [EPTInvariant]
  have hg : HasDerivAt (fun τ => Tacc τ / c.hbar) (Texp t / c.hbar) t := by
    have h := (hTacc_diff t).hasDerivAt.div_const c.hbar
    rwa [hacc t] at h
  have hmul : HasDerivAt (fun τ => E τ * Real.exp (Tacc τ / c.hbar))
      (deriv E t * Real.exp (Tacc t / c.hbar) +
       E t * (Real.exp (Tacc t / c.hbar) * (Texp t / c.hbar))) t :=
    (hE_diff t).hasDerivAt.mul hg.exp
  rw [hmul.deriv, hE t]; ring

end CATEPTMain.CATEPT.CATEPT
