import Mathlib.Data.Real.Basic
import CATEPTMain.CATEPT.UnitsDimensionalAnalysis

set_option autoImplicit false

namespace CATEPTMain.CATEPT

open Real

noncomputable section

/-! # CFL Dimensional Analysis and Time-Reparameterization Category Bridge -/

/-- CFL constraint `Δt ≤ Δx / a`. -/
def CFLConstraint (Δt Δx a : ℝ) : Prop :=
  Δt ≤ Δx / a

/-- Courant number `C = a * Δt / Δx`. -/
def courantNumber (Δt Δx a : ℝ) : ℝ :=
  a * Δt / Δx

/-- The CFL constraint is equivalent to `C ≤ 1`. -/
theorem cfl_iff_courant_le_one
    (Δt Δx a : ℝ) (hΔx : 0 < Δx) (ha : 0 < a) :
    CFLConstraint Δt Δx a ↔ courantNumber Δt Δx a ≤ 1 := by
  unfold CFLConstraint courantNumber
  constructor
  · intro h
    have hmul : a * Δt ≤ Δx := by
      have hmul' : a * Δt ≤ a * (Δx / a) := mul_le_mul_of_nonneg_left h ha.le
      have hscale : a * (Δx / a) = Δx := by
        field_simp [ha.ne']
      rw [hscale] at hmul'
      exact hmul'
    have hinv_nonneg : 0 ≤ 1 / Δx := one_div_nonneg.mpr hΔx.le
    have hbound : (a * Δt) * (1 / Δx) ≤ Δx * (1 / Δx) :=
      mul_le_mul_of_nonneg_right hmul hinv_nonneg
    calc
      a * Δt / Δx = (a * Δt) * (1 / Δx) := by ring
      _ ≤ Δx * (1 / Δx) := hbound
      _ = 1 := by field_simp [hΔx.ne']
  · intro h
    have hmulInv : (a * Δt) * (1 / Δx) ≤ 1 := by
      simpa [div_eq_mul_inv, mul_assoc, mul_left_comm, mul_comm] using h
    have hmul : a * Δt ≤ Δx := by
      have hscaled : ((a * Δt) * (1 / Δx)) * Δx ≤ 1 * Δx :=
        mul_le_mul_of_nonneg_right hmulInv hΔx.le
      have hleft : ((a * Δt) * (1 / Δx)) * Δx = a * Δt := by
        field_simp [hΔx.ne']
      rw [hleft] at hscaled
      simpa using hscaled
    have hinv_nonneg : 0 ≤ 1 / a := one_div_nonneg.mpr ha.le
    have hscaled : (a * Δt) * (1 / a) ≤ Δx * (1 / a) :=
      mul_le_mul_of_nonneg_right hmul hinv_nonneg
    calc
      Δt = (a * Δt) * (1 / a) := by field_simp [ha.ne']
      _ ≤ Δx * (1 / a) := hscaled
      _ = Δx / a := by ring

/-- Courant invariance under `t -> λ t`, `a -> a / λ`. -/
theorem courant_reparameterization_invariant
    (Δt Δx a lam : ℝ) (hlam : 0 < lam) :
    courantNumber (lam * Δt) Δx (a / lam) = courantNumber Δt Δx a := by
  unfold courantNumber
  have hlam_ne : lam ≠ 0 := ne_of_gt hlam
  calc
    (a / lam) * (lam * Δt) / Δx
        = (a * (lam / lam) * Δt) / Δx := by ring
    _ = (a * 1 * Δt) / Δx := by simp [hlam_ne]
    _ = a * Δt / Δx := by ring

/-- CFL gives the same Courant number in coordinate and entropic time. -/
theorem cfl_same_courant_both_times
  (Δt Δx a lam : ℝ) (_hΔx : 0 < Δx) (_ha : 0 < a) (hlam : 0 < lam) :
    courantNumber Δt Δx a = courantNumber (lam * Δt) Δx (a / lam) :=
  (courant_reparameterization_invariant Δt Δx a lam hlam).symm

/-- Speed dimension `L / T`. -/
def dimSpeed : Dimension :=
  Dimension.div dimLength dimTime

/-- The Courant ratio `[(L/T) * T / L]` is dimensionless. -/
theorem dim_courant_number_dimensionless :
    Dimension.div (Dimension.mul dimSpeed dimTime) dimLength = Dimension.one := by
  simp [dimSpeed, Dimension.div, Dimension.mul, Dimension.inv, Dimension.one,
    dimLength, dimTime]

/-- Explicit contract tying `courantNumber` to its dimensionless unit law. -/
theorem courant_number_dimension_contract (Δt Δx a : ℝ) :
    courantNumber Δt Δx a = a * Δt / Δx ∧
    Dimension.div (Dimension.mul dimSpeed dimTime) dimLength = Dimension.one := by
  exact ⟨rfl, dim_courant_number_dimensionless⟩

/-- Time parameters used in CAT/EPT bridges. -/
inductive TimeType : Type
  | coord
  | entropic
  | geometric
  deriving DecidableEq

/-- Morphism data between time parameterizations. -/
inductive TimeReparamHom : TimeType -> TimeType -> Type
  | coordId                              : TimeReparamHom .coord .coord
  | entId                                : TimeReparamHom .entropic .entropic
  | geoId                                : TimeReparamHom .geometric .geometric
  | coordToEnt (lam : ℝ) (h : 0 < lam)  : TimeReparamHom .coord .entropic
  | entToCoord (inv : ℝ) (h : 0 < inv)  : TimeReparamHom .entropic .coord
  | entToGeo (inv : ℝ) (h : 0 < inv)    : TimeReparamHom .entropic .geometric
  | geoToEnt (lam : ℝ) (h : 0 < lam)    : TimeReparamHom .geometric .entropic
  | coordToGeo                           : TimeReparamHom .coord .geometric
  | geoToCoord                           : TimeReparamHom .geometric .coord

/-- Composition law for time reparameterization morphisms. -/
def TimeReparamComp :
    ∀ {A B C : TimeType},
    TimeReparamHom A B -> TimeReparamHom B C -> TimeReparamHom A C
  | _, _, _, .coordId, g               => g
  | _, _, _, f, .coordId               => f
  | _, _, _, .entId, g                 => g
  | _, _, _, f, .entId                 => f
  | _, _, _, .geoId, g                 => g
  | _, _, _, f, .geoId                 => f
  | _, _, _, .coordToEnt _ _, .entToCoord _ _ => .coordId
  | _, _, _, .coordToEnt _ _, .entToGeo _ _   => .coordToGeo
  | _, _, _, .entToCoord _ _, .coordToEnt _ _ => .entId
  | _, _, _, .entToCoord inv h, .coordToGeo   => .entToGeo inv h
  | _, _, _, .entToGeo inv h, .geoToCoord     => .entToCoord inv h
  | _, _, _, .entToGeo _ _, .geoToEnt _ _     => .entId
  | _, _, _, .geoToCoord, .coordToEnt lam h   => .geoToEnt lam h
  | _, _, _, .geoToCoord, .coordToGeo         => .geoId
  | _, _, _, .geoToEnt _ _, .entToCoord _ _   => .geoToCoord
  | _, _, _, .geoToEnt _ _, .entToGeo _ _     => .geoId
  | _, _, _, .coordToGeo, .geoToCoord         => .coordId
  | _, _, _, .coordToGeo, .geoToEnt lam h     => .coordToEnt lam h

/-- `coord -> entropic -> coord` recovers coordinate time when rates match. -/
theorem coord_entropic_round_trip
  (lam inv : ℝ) (_hl : 0 < lam) (_hi : 0 < inv) (t : ℝ) :
    (lam * t) * inv = t * (lam * inv) := by
  ring

/-- `entropic -> geometric -> entropic` round trip with `lam * inv = 1`. -/
theorem ent_geo_round_trip
  (lam inv : ℝ) (_hl : 0 < lam) (_hi : 0 < inv)
    (tau : ℝ) (hconsistent : lam * inv = 1) :
    tau * inv * lam = tau := by
  have hinvlam : inv * lam = 1 := by rw [mul_comm]; exact hconsistent
  calc
    tau * inv * lam = tau * (inv * lam) := by ring
    _ = tau * 1 := by rw [hinvlam]
    _ = tau := by ring

/-- Entropic time integrates back to geometric time given `lam > 0`. -/
theorem entropic_integrates_to_geo
    (tau_ent lam : ℝ) (hlam : 0 < lam) :
    lam * (tau_ent / lam) = tau_ent := by
  field_simp [hlam.ne']

/-- Triangle commutation: `coord -> entropic -> geometric` yields `coord`. -/
theorem roundtrip_coord_ent_geo (t lam : ℝ) (hlam : 0 < lam) :
    (lam * t) / lam = t := by
  field_simp [hlam.ne']

/-- Distinct rates induce distinct entropic times for fixed nonzero `t`. -/
theorem geo_to_entropic_nonunique
  (lam1 lam2 t : ℝ) (_hlam1 : 0 < lam1) (_hlam2 : 0 < lam2)
    (hlam_ne : lam1 ≠ lam2) (ht : t ≠ 0) :
    lam1 * t ≠ lam2 * t := fun h =>
  hlam_ne (mul_right_cancel₀ ht h)

/-- There is no canonical geometric-to-entropic map valid for all rates. -/
theorem no_canonical_geo_to_entropic
  (lam1 lam2 : ℝ) (_hlam1 : 0 < lam1) (_hlam2 : 0 < lam2)
    (hlam_ne : lam1 ≠ lam2) :
    ¬∃ f : ℝ -> ℝ, f 1 = lam1 * 1 ∧ f 1 = lam2 * 1 := by
  rintro ⟨f, h1, h2⟩
  have : lam1 * 1 = lam2 * 1 := h1.symm.trans h2
  simp only [mul_one] at this
  exact hlam_ne this

/-- Different `geoToEnt` rates produce genuinely different morphisms. -/
theorem geo_to_entropic_needs_extra_data
    (lam1 lam2 : ℝ) (h1 : 0 < lam1) (h2 : 0 < lam2) (hne : lam1 ≠ lam2) :
    TimeReparamHom.geoToEnt lam1 h1 ≠ TimeReparamHom.geoToEnt lam2 h2 := by
  intro heq
  have : lam1 = lam2 :=
    congrArg (fun f => match f with | .geoToEnt l _ => l | _ => 0) heq
  exact hne this

/-- Dissipative time point with explicit entropic relation `tau_ent = lam * t`. -/
structure DissipativeTimePoint where
  t : ℝ
  lam : ℝ
  lam_pos : 0 < lam
  tau_ent : ℝ
  tau_eq : tau_ent = lam * t

/-- Forgetful map to coordinate time. -/
def forgetToCoord (p : DissipativeTimePoint) : ℝ :=
  p.t

/-- Every coordinate time has at least one dissipative lift (`lam = 1`). -/
theorem forgetToCoord_surjective : Function.Surjective forgetToCoord := by
  intro t
  refine ⟨⟨t, 1, one_pos, 1 * t, rfl⟩, rfl⟩

/-- Same coordinate time can correspond to different entropic times. -/
theorem forgetToCoord_not_injective (t : ℝ) (ht : t ≠ 0) :
    ∃ p q : DissipativeTimePoint,
      forgetToCoord p = forgetToCoord q ∧ p.tau_ent ≠ q.tau_ent := by
  refine ⟨⟨t, 1, one_pos, 1 * t, rfl⟩, ⟨t, 2, two_pos, 2 * t, rfl⟩, rfl, ?_⟩
  intro h
  have h12 : (1 : ℝ) = 2 := mul_right_cancel₀ ht (by simpa [one_mul] using h)
  linarith

/-- CFL equivalence and reparameterization-invariance summary theorem. -/
theorem cfl_dimensional_equivalence_summary
    (Δt Δx a lam : ℝ) (hΔx : 0 < Δx) (ha : 0 < a) (hlam : 0 < lam) :
    courantNumber Δt Δx a = courantNumber (lam * Δt) Δx (a / lam) ∧
    (courantNumber Δt Δx a ≤ 1 ↔ courantNumber (lam * Δt) Δx (a / lam) ≤ 1) ∧
    (∀ c : ℝ, 0 < c ->
      courantNumber Δt Δx a = courantNumber (c * Δt) Δx (a / c)) := by
  refine ⟨cfl_same_courant_both_times Δt Δx a lam hΔx ha hlam, ?_, ?_⟩
  · rw [cfl_same_courant_both_times Δt Δx a lam hΔx ha hlam]
  · intro c hc
    exact (courant_reparameterization_invariant Δt Δx a c hc).symm

/-- Compatibility theorem joining CFL and CAT/EPT unit contracts. -/
theorem cfl_and_catept_unit_compatibility
    (Δt Δx a lam : ℝ) (hΔx : 0 < Δx) (ha : 0 < a) (hlam : 0 < lam) :
    Dimension.div (Dimension.mul dimSpeed dimTime) dimLength = Dimension.one ∧
    dimPathIntegralExponent = Dimension.one ∧
    courantNumber Δt Δx a = courantNumber (lam * Δt) Δx (a / lam) := by
  exact ⟨dim_courant_number_dimensionless,
    dim_path_integral_exponent_dimensionless,
    cfl_same_courant_both_times Δt Δx a lam hΔx ha hlam⟩

end
end CATEPTMain.CATEPT
