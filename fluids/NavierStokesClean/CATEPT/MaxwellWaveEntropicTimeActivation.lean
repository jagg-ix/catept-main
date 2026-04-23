import NavierStokesClean.CATEPT.Foundations
import MaxwellWave.WaveEquation

/-!
# MaxwellWave Entropic-Time Activation Bridge

This module adds a controllable time-gauge layer over `lean-mwe` (`MaxwellWave`)
so users can choose between:

- geometric time `t`, and
- CAT/EPT entropic proper time `tau_ent`.

The bridge is theorem-level: we do not rewrite `MaxwellWave`; instead we
re-index its already-proved equations at an "active time" selected by a mode.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT

noncomputable section

namespace MaxwellWaveEntropicTime

/-- Toggle for selecting the active time coordinate in MaxwellWave theorems. -/
inductive TimeMode where
  | geometric
  | entropicProper
  deriving DecidableEq, Repr

/-- Minimal CAT/EPT spacetime clock data needed to activate entropic proper time. -/
structure CATEPTSpaceTime where
  entropicProperTime : ℝ → ℝ

/-- Active time used by the Maxwell bridge. -/
def activeTime (st : CATEPTSpaceTime) (mode : TimeMode) (t : ℝ) : ℝ :=
  match mode with
  | .geometric => t
  | .entropicProper => st.entropicProperTime t

/-- Bool switch helper for runtime/DSL-style activation. -/
def modeOfBool (useEntropicProperTime : Bool) : TimeMode :=
  if useEntropicProperTime then .entropicProper else .geometric

@[simp] theorem activeTime_geometric (st : CATEPTSpaceTime) (t : ℝ) :
    activeTime st .geometric t = t := rfl

@[simp] theorem activeTime_entropicProper (st : CATEPTSpaceTime) (t : ℝ) :
    activeTime st .entropicProper t = st.entropicProperTime t := rfl

@[simp] theorem activeTime_modeOfBool_false (st : CATEPTSpaceTime) (t : ℝ) :
    activeTime st (modeOfBool false) t = t := by
  simp [modeOfBool, activeTime]

@[simp] theorem activeTime_modeOfBool_true (st : CATEPTSpaceTime) (t : ℝ) :
    activeTime st (modeOfBool true) t = st.entropicProperTime t := by
  simp [modeOfBool, activeTime]

/-- CAT/EPT entropic proper-time clock from the foundational equation
`tau_ent = S_I / hbar` (`Foundations.eq003`). -/
structure EntropicProperClock where
  hbar : ℝ
  hbar_pos : 0 < hbar
  imagAction : ℝ → ℝ
  imagAction_nonneg : ∀ t, 0 ≤ imagAction t

/-- Convert the CAT/EPT entropic clock into a spacetime activation map. -/
def EntropicProperClock.toSpaceTime (clk : EntropicProperClock) : CATEPTSpaceTime where
  entropicProperTime := fun t => entropic_time clk.hbar (clk.imagAction t)

theorem EntropicProperClock.entropicProperTime_nonneg (clk : EntropicProperClock) (t : ℝ) :
    0 ≤ (clk.toSpaceTime.entropicProperTime t) := by
  dsimp [EntropicProperClock.toSpaceTime]
  exact eq003_entropic_time_nonneg clk.hbar (clk.imagAction t) clk.hbar_pos (clk.imagAction_nonneg t)

/-! ## MaxwellWave equations under active-time selection -/

variable {m : MaxwellWave.Medium}

/-- Source-free Gauss law remains valid after active-time selection. -/
theorem gauss_simplified_at_active_time
    (sys : MaxwellWave.SourceFreeMaxwell m)
    (st : CATEPTSpaceTime) (mode : TimeMode)
    (t : ℝ) (x : MaxwellWave.Vec3) :
    MaxwellWave.divergence (sys.E (activeTime st mode t)) x = 0 := by
  simpa [activeTime] using sys.gauss_simplified (activeTime st mode t) x

/-- Source-free no-monopole law remains valid after active-time selection. -/
theorem no_monopole_at_active_time
    (sys : MaxwellWave.SourceFreeMaxwell m)
    (st : CATEPTSpaceTime) (mode : TimeMode)
    (t : ℝ) (x : MaxwellWave.Vec3) :
    MaxwellWave.divergence (sys.B (activeTime st mode t)) x = 0 := by
  simpa [activeTime] using sys.no_monopole (activeTime st mode t) x

/-- Faraday law evaluated at active time. -/
theorem faraday_at_active_time
    (sys : MaxwellWave.SourceFreeMaxwell m)
    (st : CATEPTSpaceTime) (mode : TimeMode)
    (t : ℝ) (x : MaxwellWave.Vec3) (j : Fin 3) :
    MaxwellWave.curl (sys.E (activeTime st mode t)) x j =
      -(MaxwellWave.timeDerivComp sys.B j (activeTime st mode t) x) := by
  simpa [activeTime] using sys.faraday (activeTime st mode t) x j

/-- Ampere-Maxwell (source-free simplified form) evaluated at active time. -/
theorem ampere_simplified_at_active_time
    (sys : MaxwellWave.SourceFreeMaxwell m)
    (st : CATEPTSpaceTime) (mode : TimeMode)
    (t : ℝ) (x : MaxwellWave.Vec3) (j : Fin 3) :
    MaxwellWave.curl (sys.B (activeTime st mode t)) x j =
      m.μ * m.σ * sys.E (activeTime st mode t) x j +
      m.μ * m.ε * MaxwellWave.timeDerivComp sys.E j (activeTime st mode t) x := by
  simpa [activeTime] using sys.ampere_simplified (activeTime st mode t) x j

/-- General electromagnetic wave equation for `E` at active time. -/
theorem general_wave_equation_E_at_active_time
    (sys : MaxwellWave.SourceFreeMaxwell m)
    (sm : MaxwellWave.SufficientlySmooth sys)
    (st : CATEPTSpaceTime) (mode : TimeMode)
    (t : ℝ) (x : MaxwellWave.Vec3) (j : Fin 3) :
    MaxwellWave.vectorLaplacian (sys.E (activeTime st mode t)) x j =
      m.μ * m.ε * MaxwellWave.timeDerivComp2 sys.E j (activeTime st mode t) x +
      m.μ * m.σ * MaxwellWave.timeDerivComp sys.E j (activeTime st mode t) x := by
  simpa [activeTime] using
    (MaxwellWave.general_wave_equation_E m sys sm (activeTime st mode t) x j)

/-- General electromagnetic wave equation for `B` at active time. -/
theorem general_wave_equation_B_at_active_time
    (sys : MaxwellWave.SourceFreeMaxwell m)
    (sm : MaxwellWave.SufficientlySmooth sys)
    (st : CATEPTSpaceTime) (mode : TimeMode)
    (t : ℝ) (x : MaxwellWave.Vec3) (j : Fin 3) :
    MaxwellWave.vectorLaplacian (sys.B (activeTime st mode t)) x j =
      m.μ * m.ε * MaxwellWave.timeDerivComp2 sys.B j (activeTime st mode t) x +
      m.μ * m.σ * MaxwellWave.timeDerivComp sys.B j (activeTime st mode t) x := by
  simpa [activeTime] using
    (MaxwellWave.general_wave_equation_B m sys sm (activeTime st mode t) x j)

/-- Runtime switch form: same theorem surface, controlled by a Boolean flag. -/
theorem general_wave_equation_E_with_switch
    (sys : MaxwellWave.SourceFreeMaxwell m)
    (sm : MaxwellWave.SufficientlySmooth sys)
    (st : CATEPTSpaceTime) (useEntropicProperTime : Bool)
    (t : ℝ) (x : MaxwellWave.Vec3) (j : Fin 3) :
    MaxwellWave.vectorLaplacian (sys.E (activeTime st (modeOfBool useEntropicProperTime) t)) x j =
      m.μ * m.ε *
        MaxwellWave.timeDerivComp2 sys.E j (activeTime st (modeOfBool useEntropicProperTime) t) x +
      m.μ * m.σ *
        MaxwellWave.timeDerivComp sys.E j (activeTime st (modeOfBool useEntropicProperTime) t) x := by
  simpa using
    (general_wave_equation_E_at_active_time (m := m) sys sm st (modeOfBool useEntropicProperTime) t x j)

/-- Geometric mode is a strict no-op on time argument. -/
theorem geometric_mode_recovers_geometric_time
    (sys : MaxwellWave.SourceFreeMaxwell m)
    (sm : MaxwellWave.SufficientlySmooth sys)
    (st : CATEPTSpaceTime)
    (t : ℝ) (x : MaxwellWave.Vec3) (j : Fin 3) :
    MaxwellWave.vectorLaplacian (sys.E t) x j =
      m.μ * m.ε * MaxwellWave.timeDerivComp2 sys.E j t x +
      m.μ * m.σ * MaxwellWave.timeDerivComp sys.E j t x := by
  simpa using
    (general_wave_equation_E_at_active_time (m := m) sys sm st .geometric t x j)

/-! ## Entropic-first model (`τ` fundamental, `t` derived) -/

/-- Entropic-first spacetime parameterization:
`τ` is fundamental; geometric time is recovered via `t = t(τ)`. -/
structure EntropicFirstSpaceTime where
  geometricTimeOfEntropic : ℝ → ℝ
  entropicTimeOfGeometric : ℝ → ℝ
  leftInverse_geometric_entropic :
    Function.LeftInverse geometricTimeOfEntropic entropicTimeOfGeometric

/-- Active geometric time when equations are parameterized by fundamental `τ`. -/
def activeGeometricTimeFromTau
    (stτ : EntropicFirstSpaceTime) (mode : TimeMode) (τ : ℝ) : ℝ :=
  match mode with
  | .geometric => τ
  | .entropicProper => stτ.geometricTimeOfEntropic τ

@[simp] theorem activeGeometricTimeFromTau_geometric
    (stτ : EntropicFirstSpaceTime) (τ : ℝ) :
    activeGeometricTimeFromTau stτ .geometric τ = τ := rfl

@[simp] theorem activeGeometricTimeFromTau_entropic
    (stτ : EntropicFirstSpaceTime) (τ : ℝ) :
    activeGeometricTimeFromTau stτ .entropicProper τ = stτ.geometricTimeOfEntropic τ := rfl

/-- Entropic-first form: Maxwell wave equation for `E`, indexed by `τ`. -/
theorem general_wave_equation_E_tau_fundamental
    (sys : MaxwellWave.SourceFreeMaxwell m)
    (sm : MaxwellWave.SufficientlySmooth sys)
    (stτ : EntropicFirstSpaceTime) (mode : TimeMode)
    (τ : ℝ) (x : MaxwellWave.Vec3) (j : Fin 3) :
    MaxwellWave.vectorLaplacian
      (sys.E (activeGeometricTimeFromTau stτ mode τ)) x j =
      m.μ * m.ε *
        MaxwellWave.timeDerivComp2 sys.E j (activeGeometricTimeFromTau stτ mode τ) x +
      m.μ * m.σ *
        MaxwellWave.timeDerivComp sys.E j (activeGeometricTimeFromTau stτ mode τ) x := by
  simpa using
    (MaxwellWave.general_wave_equation_E m sys sm
      (activeGeometricTimeFromTau stτ mode τ) x j)

/-- Entropic-first form: Maxwell wave equation for `B`, indexed by `τ`. -/
theorem general_wave_equation_B_tau_fundamental
    (sys : MaxwellWave.SourceFreeMaxwell m)
    (sm : MaxwellWave.SufficientlySmooth sys)
    (stτ : EntropicFirstSpaceTime) (mode : TimeMode)
    (τ : ℝ) (x : MaxwellWave.Vec3) (j : Fin 3) :
    MaxwellWave.vectorLaplacian
      (sys.B (activeGeometricTimeFromTau stτ mode τ)) x j =
      m.μ * m.ε *
        MaxwellWave.timeDerivComp2 sys.B j (activeGeometricTimeFromTau stτ mode τ) x +
      m.μ * m.σ *
        MaxwellWave.timeDerivComp sys.B j (activeGeometricTimeFromTau stτ mode τ) x := by
  simpa using
    (MaxwellWave.general_wave_equation_B m sys sm
      (activeGeometricTimeFromTau stτ mode τ) x j)

/-- Switch form in the entropic-first parameterization (`τ` fundamental). -/
theorem general_wave_equation_E_tau_with_switch
    (sys : MaxwellWave.SourceFreeMaxwell m)
    (sm : MaxwellWave.SufficientlySmooth sys)
    (stτ : EntropicFirstSpaceTime) (useEntropicProperTime : Bool)
    (τ : ℝ) (x : MaxwellWave.Vec3) (j : Fin 3) :
    MaxwellWave.vectorLaplacian
      (sys.E (activeGeometricTimeFromTau stτ (modeOfBool useEntropicProperTime) τ)) x j =
      m.μ * m.ε *
        MaxwellWave.timeDerivComp2 sys.E j
          (activeGeometricTimeFromTau stτ (modeOfBool useEntropicProperTime) τ) x +
      m.μ * m.σ *
        MaxwellWave.timeDerivComp sys.E j
          (activeGeometricTimeFromTau stτ (modeOfBool useEntropicProperTime) τ) x := by
  simpa using
    (general_wave_equation_E_tau_fundamental (m := m)
      sys sm stτ (modeOfBool useEntropicProperTime) τ x j)

/-- In entropic-proper mode, geometric time is explicitly the composed map `t(τ)`. -/
theorem entropic_mode_uses_composed_geometric_time
    (sys : MaxwellWave.SourceFreeMaxwell m)
    (sm : MaxwellWave.SufficientlySmooth sys)
    (stτ : EntropicFirstSpaceTime)
    (τ : ℝ) (x : MaxwellWave.Vec3) (j : Fin 3) :
    MaxwellWave.vectorLaplacian (sys.E (stτ.geometricTimeOfEntropic τ)) x j =
      m.μ * m.ε * MaxwellWave.timeDerivComp2 sys.E j (stτ.geometricTimeOfEntropic τ) x +
      m.μ * m.σ * MaxwellWave.timeDerivComp sys.E j (stτ.geometricTimeOfEntropic τ) x := by
  simpa using
    (general_wave_equation_E_tau_fundamental (m := m) sys sm stτ .entropicProper τ x j)

end MaxwellWaveEntropicTime

end

end NavierStokesClean.CATEPT
