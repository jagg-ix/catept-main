import CATEPTMain.CATEPT.CATEPT.CATEPTPrelude
import CATEPTMain.CATEPT.CATEPT.GeometryGauge
import CATEPTMain.CATEPT.CATEPT.ThermodynamicsCoreAbstractions

/-!
# GTD Entropy-Affine Bridge

Carrier-level contracts for geometrothermodynamics (GTD):

* **Entropy-affine parameter**: `S(λ) = a · λ + b` along a chosen
  thermodynamic path.
* **Equilibrium limit**: `a = 0`, so entropy (and entropic time) is
  constant along the parameter.
* **GTD equilibrium identification**: `S_I = (hbar / kB) · S`, hence
  `tau_ent = S / kB` under the CAT/EPT entropic-time definition.

No GTD metric or geodesic equation is assumed here; this is a minimal
bridge surface for wiring affine-entropy parameterizations into the
existing entropic-time infrastructure.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.GTDEntropyAffineBridge

open CATEPTMain.CATEPT.CATEPT
open CATEPTMain.CATEPT.CATEPT.Thermodynamics

noncomputable section

/-- **Entropy-affine parameterization.**
A function `entropy` is affine in the parameter `λ`:
`entropy(λ) = slope · λ + intercept`. -/
structure EntropyAffineParameter where
  entropy : ℝ → ℝ
  slope : ℝ
  intercept : ℝ
  entropy_affine : ∀ λ, entropy λ = slope * λ + intercept

namespace EntropyAffineParameter

/-- If the slope is non-negative, entropy is non-decreasing. -/
theorem entropy_affine_monotone
    (E : EntropyAffineParameter) (hs : 0 ≤ E.slope)
    {t1 t2 : ℝ} (h : t1 ≤ t2) :
    E.entropy t1 ≤ E.entropy t2 := by
  calc
    E.entropy t1 = E.slope * t1 + E.intercept := E.entropy_affine t1
    _ ≤ E.slope * t2 + E.intercept := by
      exact add_le_add_right (mul_le_mul_of_nonneg_left h hs) _
    _ = E.entropy t2 := (E.entropy_affine t2).symm

/-- Trivial existence: constant zero entropy. -/
theorem exists_trivial : ∃ _ : EntropyAffineParameter, True := by
  refine ⟨{ entropy := fun _ => 0
          , slope := 0
          , intercept := 0
          , entropy_affine := ?_ }, trivial⟩
  intro t
  simp

end EntropyAffineParameter

/-- **Thermodynamic geodesic with affine entropy.**
Uses a `ThermodynamicsEntropyCertificate` state space and tracks
an affine entropy along a chosen parameter. -/
structure ThermodynamicGeodesic (w : ThermodynamicsEntropyCertificate) where
  point : ℝ → w.State
  slope : ℝ
  intercept : ℝ
  entropy_affine : ∀ λ, w.entropy (point λ) = slope * λ + intercept

namespace ThermodynamicGeodesic

variable {w : ThermodynamicsEntropyCertificate}

/-- Extracts the affine-entropy parameter from a thermodynamic geodesic. -/
def entropyAffineParameter (G : ThermodynamicGeodesic w) : EntropyAffineParameter :=
  { entropy := fun t => w.entropy (G.point t)
  , slope := G.slope
  , intercept := G.intercept
  , entropy_affine := G.entropy_affine }

end ThermodynamicGeodesic

/-- **GTD equilibrium identification.**
If `S_I = (hbar / kB) · S`, then `tau_ent = S / kB`. -/
theorem entropicTime_eq_entropy_over_kB
    (c : PhysicalConstants) (S : ℝ) :
    entropicTime c.hbar (entropicActionOfEntropy c S) = S / c.kB := by
  unfold entropicTime entropicActionOfEntropy
  have hbar_ne : c.hbar ≠ 0 := ne_of_gt c.hbar_pos
  have kB_ne : c.kB ≠ 0 := ne_of_gt c.kB_pos
  field_simp [hbar_ne, kB_ne]
  ring

/-- **Bridge contract:** entropic time is entropy divided by `kB`, and
entropy is affine in the GTD parameter. -/
structure EntropicTimeEntropyAffineBridge extends EntropyAffineParameter where
  constants : PhysicalConstants
  tauEnt : ℝ → ℝ
  tau_ent_eq_entropy_over_kB : ∀ t, tauEnt t = entropy t / constants.kB

namespace EntropicTimeEntropyAffineBridge

/-- Entropic time is affine whenever entropy is affine. -/
theorem tauEnt_affine (B : EntropicTimeEntropyAffineBridge) :
    ∀ t, B.tauEnt t = (B.slope * t + B.intercept) / B.constants.kB := by
  intro t
  rw [B.tau_ent_eq_entropy_over_kB, B.entropy_affine t]

/-- Monotonicity of entropic time from non-negative slope. -/
theorem tauEnt_monotone
    (B : EntropicTimeEntropyAffineBridge) (hs : 0 ≤ B.slope)
    {t1 t2 : ℝ} (h : t1 ≤ t2) :
    B.tauEnt t1 ≤ B.tauEnt t2 := by
  have hS : B.entropy t1 ≤ B.entropy t2 :=
    EntropyAffineParameter.entropy_affine_monotone B.toEntropyAffineParameter hs h
  have hk : 0 ≤ B.constants.kB := le_of_lt B.constants.kB_pos
  have hdiv : B.entropy t1 / B.constants.kB ≤ B.entropy t2 / B.constants.kB :=
    div_le_div_of_nonneg_right hS hk
  simpa [B.tau_ent_eq_entropy_over_kB] using hdiv

end EntropicTimeEntropyAffineBridge

/-- **GTD equilibrium limit:** zero slope, so entropy and entropic time
are constant along the parameter. -/
structure GTDEquilibriumLimit extends EntropicTimeEntropyAffineBridge where
  slope_zero : slope = 0

namespace GTDEquilibriumLimit

/-- Entropy is constant in the equilibrium limit. -/
theorem entropy_constant (E : GTDEquilibriumLimit) (t1 t2 : ℝ) :
    E.entropy t1 = E.entropy t2 := by
  calc
    E.entropy t1 = E.intercept := by
      simpa [E.slope_zero] using E.entropy_affine t1
    _ = E.entropy t2 := by
      symm
      simpa [E.slope_zero] using E.entropy_affine t2

/-- Entropic time is constant in the equilibrium limit. -/
theorem tauEnt_constant (E : GTDEquilibriumLimit) (t1 t2 : ℝ) :
    E.tauEnt t1 = E.tauEnt t2 := by
  have hS : E.entropy t1 = E.entropy t2 := entropy_constant E t1 t2
  calc
    E.tauEnt t1 = E.entropy t1 / E.constants.kB := E.tau_ent_eq_entropy_over_kB t1
    _ = E.entropy t2 / E.constants.kB := by
      simpa [hS]
    _ = E.tauEnt t2 := (E.tau_ent_eq_entropy_over_kB t2).symm

end GTDEquilibriumLimit

end

end CATEPTMain.Integration.GTDEntropyAffineBridge
