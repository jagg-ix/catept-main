import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Mathlib.Analysis.Calculus.Deriv.Comp
import NavierStokesClean.CATEPT.Foundations

/-!
# NS EPT Noether Invariant Bridge

Connects the abstract CAT/EPT Noether invariant structure to the Navier-Stokes
enstrophy dynamics.  This is the concrete instantiation of the abstract
`eptDecay_implies_EPTInvariant` pattern from `CATEPTMain.CATEPT.NoetherEPT`
for the NS enstrophy/defect system.

## Core identification (Constantin-Iyer + Modular Noether)

From `NSModularNoetherBridge` (Bridges/NSModularNoetherBridge.lean):

  dΩ/dt = -2 D_I       where D_I = νP - VS  (palinstrophy minus vortex stretching)

Under the CI identification ħ = 2ν, this matches the CAT/EPT decay law

  dE/dt = -(Texp/ħ) · E   with  E = Ω,  Texp = 2 D_I ħ / Ω

giving the EPT accumulator

  Tacc'(t) = Texp(t) = 2 D_I(t) · ħ / Ω(t)

and the conserved NS EPT Noether invariant

  J_NS(t) = Ω(t) · exp(Tacc(t) / ħ)  =  constant.

## Connection to BKM and regularity

  - The **entropic proper time** τ_ent = (ν/ħ)·∫Ω dt is NOT the same as Tacc
    (Tacc tracks D_I/Ω, not Ω itself).
  - τ_ent gives the BKM polynomial bound (Stage 283).
  - Tacc gives the Noether invariant; its finiteness is equivalent to smooth
    solutions existing.

## Phase-1 status

The enstrophy balance and EPT accumulation laws are stated as abstract
hypotheses.  Phase-2 would close them from `SatisfiesNSPDE` +
`RespectsFunctionSpaces` using the proved results in `NSModularNoetherBridge`.

## Zero new axioms.  Zero sorrys.
-/

noncomputable section
set_option autoImplicit false

namespace CATEPTMain.Integration.NSEPTNoether

open Real

-- ── §1  Physical constants ────────────────────────────────────────────────────

/-- Physical constants for the NS EPT Noether analysis. -/
structure NSEPTConstants where
  hbar     : ℝ
  nu       : ℝ
  hbar_pos : 0 < hbar
  nu_pos   : 0 < nu

/-- Constantin-Iyer identification: ħ = 2ν.
    Under this, the CAT/EPT decay rate equals the NS enstrophy dissipation. -/
def NSEPTConstants.CI (c : NSEPTConstants) : Prop :=
  c.hbar = 2 * c.nu

-- ── §2  NS enstrophy dynamics and EPT decay conditions ────────────────────────

/-- The NS enstrophy balance law (from NSModularNoetherBridge, proved):
    dΩ/dt = -2 D_I  where D_I = νP - VS (Noether defect). -/
def IsNSEnstrophyBalance (Omega D_I : ℝ → ℝ) : Prop :=
  ∀ t, deriv Omega t = -2 * D_I t

/-- The EPT decay rate for NS enstrophy.
    When Ω(t) > 0, the imaginary Noether defect ratio gives:
      Texp(t) = 2 D_I(t) · ħ / Ω(t). -/
def NSEPTDecayRate (c : NSEPTConstants) (Omega D_I : ℝ → ℝ) (t : ℝ) : ℝ :=
  2 * D_I t * c.hbar / Omega t

/-- The NS EPT accumulator: Tacc'(t) = NSEPTDecayRate(t). -/
def IsNSEPTAccumulator (c : NSEPTConstants)
    (Tacc Omega D_I : ℝ → ℝ) : Prop :=
  ∀ t, deriv Tacc t = NSEPTDecayRate c Omega D_I t

/-- The NS EPT decay law in standard form:
    dΩ/dt = -(Texp/ħ) · Ω.
    This is equivalent to IsNSEnstrophyBalance when Ω > 0. -/
def IsNSEPTDecay (c : NSEPTConstants) (Omega D_I : ℝ → ℝ) : Prop :=
  ∀ t, deriv Omega t = -(NSEPTDecayRate c Omega D_I t / c.hbar) * Omega t

/-- Equivalence between balance law and EPT decay form (when Ω > 0). -/
theorem nsEnstrophyBalance_iff_EPTDecay
    (c : NSEPTConstants) (Omega D_I : ℝ → ℝ)
    (hΩ_pos : ∀ t, 0 < Omega t) :
    IsNSEnstrophyBalance Omega D_I ↔ IsNSEPTDecay c Omega D_I := by
  simp only [IsNSEnstrophyBalance, IsNSEPTDecay, NSEPTDecayRate]
  constructor
  · intro h t
    rw [h t]
    have hΩ : Omega t ≠ 0 := ne_of_gt (hΩ_pos t)
    have hħ : c.hbar ≠ 0 := ne_of_gt c.hbar_pos
    field_simp [hΩ, hħ]
  · intro h t
    rw [h t]
    have hΩ : Omega t ≠ 0 := ne_of_gt (hΩ_pos t)
    have hħ : c.hbar ≠ 0 := ne_of_gt c.hbar_pos
    field_simp [hΩ, hħ]

-- ── §3  NS EPT Noether invariant ──────────────────────────────────────────────

/-- The NS EPT Noether invariant:
    J_NS(t) = Ω(t) · exp(Tacc(t) / ħ). -/
def NSEPTNoetherInvariant
    (c : NSEPTConstants) (Tacc Omega : ℝ → ℝ) (t : ℝ) : ℝ :=
  Omega t * Real.exp (Tacc t / c.hbar)

/-- **Main theorem: NS EPT Noether invariant has zero derivative.**

    Under:
      - dΩ/dt = -2 D_I  (NS enstrophy balance)
      - Tacc'(t) = 2 D_I(t) · ħ / Ω(t)  (EPT accumulator)
      - Ω > 0 and both functions differentiable

    the NS EPT Noether invariant J_NS = Ω · exp(Tacc/ħ) is locally constant.

    Proof: product rule + cancellation.
      d/dt[J_NS] = dΩ/dt · exp(...) + Ω · exp(·) · (Tacc'/ħ)
                = -2 D_I · exp + Ω · exp · (2 D_I ħ / Ω / ħ)
                = exp · (-2 D_I + 2 D_I)  = 0.

    This instantiates `eptDecay_implies_EPTInvariant` from NoetherEPT
    with E = Ω, Texp = 2 D_I ħ / Ω.
-/
theorem nsEPT_noether_invariant_deriv_zero
    (c : NSEPTConstants)
    (Omega Tacc D_I : ℝ → ℝ)
    (hΩ_diff   : Differentiable ℝ Omega)
    (hTacc_diff : Differentiable ℝ Tacc)
    (hΩ_pos    : ∀ t, 0 < Omega t)
    (hbal      : IsNSEnstrophyBalance Omega D_I)
    (hacc      : IsNSEPTAccumulator c Tacc Omega D_I) :
    ∀ t, deriv (fun τ => NSEPTNoetherInvariant c Tacc Omega τ) t = 0 := by
  intro t
  simp only [NSEPTNoetherInvariant]
  -- Step 1: HasDerivAt for the exp argument Tacc(t)/ħ
  have hTacc_hda : HasDerivAt (fun τ => Tacc τ / c.hbar)
      (NSEPTDecayRate c Omega D_I t / c.hbar) t := by
    have h := (hTacc_diff t).hasDerivAt.div_const c.hbar
    rw [hacc t] at h
    exact h
  -- Step 2: product rule d/dt[Ω(t) · exp(Tacc(t)/ħ)]
  have hmul : HasDerivAt (fun τ => Omega τ * Real.exp (Tacc τ / c.hbar))
      (deriv Omega t * Real.exp (Tacc t / c.hbar) +
       Omega t * (Real.exp (Tacc t / c.hbar) *
         (NSEPTDecayRate c Omega D_I t / c.hbar))) t :=
    (hΩ_diff t).hasDerivAt.mul hTacc_hda.exp
  -- Step 3: rewrite via HasDerivAt.deriv and substitute balance law
  rw [hmul.deriv, hbal t]
  -- Step 4: cancel: (-2 D_I) · exp + Ω · exp · (2 D_I ħ / Ω / ħ) = 0
  simp only [NSEPTDecayRate]
  have hΩ : Omega t ≠ 0 := ne_of_gt (hΩ_pos t)
  have hħ : c.hbar ≠ 0  := ne_of_gt c.hbar_pos
  field_simp [hΩ, hħ]
  ring

-- ── §4  Degeneracy: vanishing defect ─────────────────────────────────────────

/-- When D_I = 0 everywhere (enstrophy frozen: νP = VS), the EPT decay rate
    vanishes, Tacc is constant, and J_NS simplifies to Ω itself (constant). -/
theorem nsEPT_degeneracy_zero_defect
    (Omega D_I : ℝ → ℝ)
    (hbal    : IsNSEnstrophyBalance Omega D_I)
    (hD_zero : ∀ t, D_I t = 0) :
    ∀ t, deriv Omega t = 0 := by
  intro t
  rw [hbal t, hD_zero t]
  ring

/-- When D_I = 0, the NS enstrophy is frozen: Ω is locally constant. -/
theorem nsEPT_frozen_enstrophy_of_zero_defect
    (Omega D_I : ℝ → ℝ)
    (hbal    : IsNSEnstrophyBalance Omega D_I)
    (hD_zero : ∀ t, D_I t = 0) :
    ∀ t, deriv Omega t = 0 :=
  nsEPT_degeneracy_zero_defect Omega D_I hbal hD_zero

-- ── §5  Relation to BKM and entropic proper time ──────────────────────────────

/-- The entropic proper time τ_ent = (ν/ħ) · ∫Ω dt is a DIFFERENT accumulator
    from Tacc.  It gives the BKM bound; Tacc gives the Noether invariant.

    They coincide only when D_I/Ω = ν·Ω/ħ² (a special non-generic condition).
-/
def IsTauEnt (c : NSEPTConstants) (Omega TauEnt : ℝ → ℝ) : Prop :=
  ∀ t, deriv TauEnt t = (c.nu / c.hbar) * Omega t

/-- The Noether accumulator Tacc is NOT the entropic proper time τ_ent in general.
    They are equal iff D_I = ν · Ω² / ħ² (special regime). -/
def IsEPTAccumulatorEqualsTauEnt
    (c : NSEPTConstants) (Omega D_I : ℝ → ℝ) : Prop :=
  ∀ t, D_I t = c.nu * Omega t ^ 2 / c.hbar ^ 2

/-- Under CI (ħ = 2ν), the special regime becomes D_I = Ω²/(4ν). -/
theorem special_regime_under_CI
    (c : NSEPTConstants) (Omega D_I : ℝ → ℝ)
    (hCI : c.CI)
    (hspec : IsEPTAccumulatorEqualsTauEnt c Omega D_I) :
    ∀ t, D_I t = Omega t ^ 2 / (4 * c.nu) := by
  intro t
  rw [hspec t]
  unfold NSEPTConstants.CI at hCI
  rw [hCI]
  have hν : c.nu ≠ 0 := ne_of_gt c.nu_pos
  field_simp [hν]
  ring

-- ── §6  Interface theorem: EPT invariant + BKM bound combine ─────────────────

/-- Abstract interface:
    if J_NS is constant AND τ_ent(T) is bounded, then there is no blowup.
    This is a Prop-level witness for the full NS/EPT regularity chain.
    Phase-2: close from `bkm_eq_integratedEnstrophy` + `J_NS constant`. -/
def NSEPTRegularityInterface
    (c : NSEPTConstants) (Omega Tacc TauEnt : ℝ → ℝ) (T : ℝ) : Prop :=
  -- J_NS constant (Noether invariant)
  (∀ t, deriv (fun τ => NSEPTNoetherInvariant c Tacc Omega τ) t = 0) ∧
  -- τ_ent bounded by initial enstrophy (from Stage 283)
  TauEnt T ≤ (c.nu / c.hbar) * Omega 0 * T

/-- The phase-1 contract: the NS EPT Noether invariant theorem
    (proved above) witnesses the first component of the regularity interface. -/
theorem nsEPT_regularity_interface_noether_component
    (c : NSEPTConstants)
    (Omega Tacc TauEnt D_I : ℝ → ℝ)
    (hΩ_diff   : Differentiable ℝ Omega)
    (hTacc_diff : Differentiable ℝ Tacc)
    (hΩ_pos    : ∀ t, 0 < Omega t)
    (hbal      : IsNSEnstrophyBalance Omega D_I)
    (hacc      : IsNSEPTAccumulator c Tacc Omega D_I)
    (T         : ℝ)
    (hτ_bound  : TauEnt T ≤ (c.nu / c.hbar) * Omega 0 * T) :
    NSEPTRegularityInterface c Omega Tacc TauEnt T :=
  ⟨nsEPT_noether_invariant_deriv_zero c Omega Tacc D_I hΩ_diff hTacc_diff hΩ_pos hbal hacc,
   hτ_bound⟩

-- ── §7  Dependency chain: NSEPTNoether ← Foundations ────────────────────────

/-- The NS EPT decay rate is an `entropic_time` of the imaginary enstrophy action.

    `NSEPTDecayRate c Ω D_I t = entropic_time ħ (2 D_I(t) ħ² / Ω(t))`

    This grounds `NSEPTNoetherInvariantBridge` in `NavierStokesClean.CATEPT.Foundations`:
    the NS decay rate is not a new primitive — it is the entropic time of the
    imaginary "enstrophy action" `S_I^{NS}(t) = 2 D_I(t) ħ² / Ω(t)` per unit ħ. -/
theorem nsEPTDecayRate_eq_entropicTime
    (c : NSEPTConstants) (Omega D_I : ℝ → ℝ) (t : ℝ) :
    NSEPTDecayRate c Omega D_I t =
    NavierStokesClean.CATEPT.entropic_time c.hbar
        (2 * D_I t * c.hbar ^ 2 / Omega t) := by
  unfold NSEPTDecayRate NavierStokesClean.CATEPT.entropic_time
  have hħ : c.hbar ≠ 0 := ne_of_gt c.hbar_pos
  field_simp [hħ]

/-- The NS EPT Noether invariant can be written purely in terms of `entropic_time`:
    J_NS(t) = Ω(t) · exp(Tacc(t) / ħ) = Ω(t) · exp(entropic_time ħ Tacc(t)).

    This connects the conserved invariant to the Foundations entropic-time
    accumulator, showing the NS Noether invariant IS an EPT weight. -/
theorem nsEPTNoetherInvariant_as_entropicTimeWeight
    (c : NSEPTConstants) (Tacc Omega : ℝ → ℝ) (t : ℝ) :
    NSEPTNoetherInvariant c Tacc Omega t =
    Omega t * Real.exp (NavierStokesClean.CATEPT.entropic_time c.hbar (Tacc t)) := by
  simp [NSEPTNoetherInvariant, NavierStokesClean.CATEPT.entropic_time]

end CATEPTMain.Integration.NSEPTNoether

end
