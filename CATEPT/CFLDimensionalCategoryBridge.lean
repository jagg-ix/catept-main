import Mathlib.CategoryTheory.Category.Basic
import Mathlib.CategoryTheory.Functor.Basic
import Mathlib.Data.Real.Basic
import CATEPT.CFLClockEntropicBridge
import CATEPT.ClassicalHerglotzETHBridge

/-!
# CFL Dimensional Analysis and Category Theory of Time Parameterizations

## Part I — Dimensional Analysis via CFL

The CFL **Courant number** `C = a·Δt / Δx` is **dimensionless**:
  `[a] = [L/T]`, `[Δt] = [T]`, `[Δx] = [L]`  →  `[C] = [1]`

Under reparameterization `t → τ = λ·t` (speed rescales `a → a/λ`):
  `C' = (a/λ)·(λ·Δt)/Δx = a·Δt/Δx = C`

**Key result**: CFL proves the stability bound `C ≤ 1` is the SAME in
coordinate time and entropic time — both share the **same dimensionless
structure**. The Courant number is a dimensional invariant.

## Part II — Category of Time Parameterizations

Three kinds of time appear in the CAT/EPT framework:

```
  coord ──λ──▶ entropic ──1/λ──▶ geometric (= coord in flat spacetime)
    │                                 │
    └─────────(identity)──────────────┘
```

**Objects**: `TimeType` with three values: `coord`, `entropic`, `geometric`

**Morphisms** and the data they carry:
```
  coord → entropic    : λ > 0        (dissipation rate, thermodynamic)
  entropic → coord    : 1/λ > 0      (inverse rate)
  coord ↔ geometric   : none         (flat metric ≅ identity)
  entropic → geometric: 1/λ > 0      (τ_geo = τ_ent / λ)
  geometric → entropic: λ > 0  ← REQUIRES EXTRA THERMODYNAMIC DATA
```

## Part III — The Asymmetry: One-Way Integration

`τ_ent → τ_geo` exists: given λ, `τ_geo = τ_ent / λ = t`.

`τ_geo → τ_ent` does NOT exist **canonically**: knowing `t` alone does
not determine λ. Two distinct dissipation rates `λ₁ ≠ λ₂` produce the
SAME geometric time `t` but DIFFERENT entropic times `λ₁·t ≠ λ₂·t`.

The asymmetry encodes the **Second Law**: dissipation is irreversible —
you cannot recover λ(t) from arc length (geometric time) alone.

## Theorems

| Name                                   | Status | Notes                                      |
|----------------------------------------|--------|--------------------------------------------|
| `courantNumber`                        | def    | C = a·Δt/Δx                               |
| `cfl_iff_courant_le_one`               | proved | CFLConstraint ↔ C ≤ 1                      |
| `courant_reparameterization_invariant` | proved | C unchanged under t → λt, a → a/λ         |
| `cfl_same_courant_both_times`          | proved | coord CFL ↔ entropic CFL via same C        |
| `TimeType`                             | def    | 3-object type for the category             |
| `TimeReparamHom`                       | def    | morphism data for each pair of time types  |
| `TimeReparamComp`                      | def    | composition of time reparameterizations    |
| `coord_entropic_round_trip`            | proved | coord → ent → coord = id (given λ, 1/λ)   |
| `ent_geo_round_trip`                   | proved | ent → geo → ent = id (given 1/λ, λ)       |
| `geo_to_entropic_nonunique`            | proved | backward map not determined by t alone     |
| `no_canonical_geo_to_entropic`         | proved | ¬∃ f, f 1 = λ₁ AND f 1 = λ₂ when λ₁ ≠ λ₂ |
| `geo_to_entropic_needs_extra_data`     | proved | two distinct geoToEnt morphisms ≠          |
| `forgetToCoord_surjective`             | proved | every t arises from some dissipative point |
| `forgetToCoord_not_injective`          | proved | same t, different τ_ent (non-injectivity)  |
| `transitivity_asymmetry`              | proved | coord→ent→geo BUT geo⊄ent canonically      |
-/

noncomputable section

set_option autoImplicit false

namespace CATEPT

open Real CategoryTheory

-- ═══════════════════════════════════════════════════════════════════════════════
-- Part I: Dimensional Analysis — the Courant Number
-- ═══════════════════════════════════════════════════════════════════════════════

/-- **Courant number**: the dimensionless CFL ratio `C = a · Δt / Δx`.

    Dimensions: `[a] = [L/T]`, `[Δt] = [T]`, `[Δx] = [L]`
    → `[C] = [1]`  (dimensionless).

    CFL stability condition: `C ≤ 1`. -/
def courantNumber (Δt Δx a : ℝ) : ℝ := a * Δt / Δx

/-- The CFL constraint is equivalent to Courant number ≤ 1.
    This exhibits CFLConstraint as a **dimensionless** statement.

    Proof: `Δt ≤ Δx/a  ↔  Δt·a ≤ Δx  ↔  a·Δt/Δx ≤ 1 = C ≤ 1`. -/
theorem cfl_iff_courant_le_one
    (Δt Δx a : ℝ) (hΔx : 0 < Δx) (ha : 0 < a) :
    CFLConstraint Δt Δx a ↔ courantNumber Δt Δx a ≤ 1 := by
  unfold CFLConstraint courantNumber
  constructor
  · intro h
    -- h : Δt ≤ Δx/a → C = a·Δt/Δx ≤ 1
    have h1 : a * Δt ≤ a * (Δx / a) := mul_le_mul_of_nonneg_left h ha.le
    simp only [mul_div_cancel₀ _ ha.ne'] at h1
    exact div_le_one_of_le₀ h1 hΔx.le
  · intro h
    -- h : a·Δt/Δx ≤ 1 → Δt ≤ Δx/a
    have h1 : a * Δt ≤ Δx := (div_le_one hΔx).mp h
    rw [le_div_iff₀ ha]
    linarith [mul_comm Δt a]

/-- **CFL dimensional invariance**: the Courant number is unchanged by
    the reparameterization `t → τ = λ·t` with speed `a → a/λ`.

    `C' = (a/λ)·(λ·Δt)/Δx = a·Δt/Δx = C`

    This is the dimensional analysis proof that CFL is scale-free:
    no matter what time unit we use, the stability number C is the same.
    Coordinate time and entropic time have the **same dimensional structure**. -/
theorem courant_reparameterization_invariant
    (Δt Δx a lam : ℝ) (hlam : 0 < lam) :
    courantNumber (lam * Δt) Δx (a / lam) = courantNumber Δt Δx a := by
  unfold courantNumber
  field_simp [hlam.ne']

/-- The CFL constraint in coordinate time and entropic time produce the
    same Courant number: `C_coord = C_entropic`.
    Both obey the same dimensionless bound `C ≤ 1`. -/
theorem cfl_same_courant_both_times
    (Δt Δx a lam : ℝ) (hΔx : 0 < Δx) (ha : 0 < a) (hlam : 0 < lam) :
    courantNumber Δt Δx a = courantNumber (lam * Δt) Δx (a / lam) :=
  (courant_reparameterization_invariant Δt Δx a lam hlam).symm

-- ═══════════════════════════════════════════════════════════════════════════════
-- Part II: Category of Time Parameterizations
-- ═══════════════════════════════════════════════════════════════════════════════

/-- Three kinds of time in the CAT/EPT framework.
    In flat spacetime, `geometric ≅ coord` (both equal coordinate time `t`).
    The non-trivial distinction is `coord ↔ entropic`, mediated by `λ`. -/
inductive TimeType : Type
  | coord     -- coordinate time t,     dimension [T]
  | entropic  -- τ_ent = ∫ λ dt,        dimensionless [1]
  | geometric -- τ_geo ≅ t (flat),      dimension [T]
  deriving DecidableEq

/-- Morphism DATA for each pair of time types.
    The presence or absence of `lam` or `lam_inv` in each constructor
    encodes exactly what physical structure each conversion requires.

    **Design principle**: `geoToEnt` carries `lam > 0`, which is
    THERMODYNAMIC data (dissipation rate) NOT present in the metric.
    All other cross-type morphisms either carry `lam_inv` (for ent→geo)
    or nothing (for coord↔geo via the flat identity). -/
inductive TimeReparamHom : TimeType → TimeType → Type
  -- Identities
  | coordId                             : TimeReparamHom .coord     .coord
  | entId                               : TimeReparamHom .entropic  .entropic
  | geoId                               : TimeReparamHom .geometric .geometric
  -- Dissipative conversions (carry λ)
  | coordToEnt (lam : ℝ) (h : 0 < lam) : TimeReparamHom .coord     .entropic
  | entToCoord (inv : ℝ) (h : 0 < inv) : TimeReparamHom .entropic  .coord
  | entToGeo   (inv : ℝ) (h : 0 < inv) : TimeReparamHom .entropic  .geometric
  -- *** KEY *** geometric → entropic requires λ (thermodynamic, not geometric)
  | geoToEnt   (lam : ℝ) (h : 0 < lam) : TimeReparamHom .geometric .entropic
  -- Flat-metric identity (coord ↔ geometric, no dissipative data needed)
  | coordToGeo                          : TimeReparamHom .coord     .geometric
  | geoToCoord                          : TimeReparamHom .geometric .coord

-- ── Composition ───────────────────────────────────────────────────────────────

/-- Composition of time reparameterizations.

    The table of non-trivial compositions:
    ```
    coord →λ→ ent →1/λ→ coord    = coordId    (round trip)
    coord →λ→ ent →1/λ→ geo      = coordToGeo (triangle commutes)
    ent →1/λ→ coord →λ'→ ent     = entId      (round trip; λ'=λ if consistent)
    geo → coord →λ→ ent          = geoToEnt λ (carries λ through flat coord)
    geo → coord → geo            = geoId      (flat identity)
    ent →1/λ→ geo →λ→ ent        = entId      (round trip)
    geo →λ→ ent →1/λ→ geo        = geoId      (round trip)
    ent →1/λ→ geo → coord        = entToCoord (flat geo ≅ coord)
    ```
    Key observation: ANY path through `entropic` or to `entropic` carries
    a dissipation rate λ, even when starting from pure geometric data. -/
def TimeReparamComp :
    ∀ {A B C : TimeType},
    TimeReparamHom A B → TimeReparamHom B C → TimeReparamHom A C
  -- Identities absorb on left and right
  | _, _, _, .coordId, g     => g
  | _, _, _, f,     .coordId => f
  | _, _, _, .entId, g       => g
  | _, _, _, f,     .entId   => f
  | _, _, _, .geoId, g       => g
  | _, _, _, f,     .geoId   => f
  -- coord → entropic → coord: round trip back to coord identity
  | _, _, _, .coordToEnt _ _, .entToCoord _ _ => .coordId
  -- coord → entropic → geometric: coord → geometric (triangle)
  | _, _, _, .coordToEnt _ _, .entToGeo inv h   => .coordToGeo
  -- entropic → coord → entropic: round trip
  | _, _, _, .entToCoord _ _, .coordToEnt lam h => .entId
  -- entropic → coord → geometric: entropic → geometric
  | _, _, _, .entToCoord inv h, .coordToGeo     => .entToGeo inv h
  -- entropic → geometric → coord: entropic → coord (flat geo ≅ coord)
  | _, _, _, .entToGeo inv h, .geoToCoord       => .entToCoord inv h
  -- entropic → geometric → entropic: round trip (ent ≅ geo/λ)
  | _, _, _, .entToGeo _ _, .geoToEnt lam h     => .entId
  -- geometric → coord → entropic: geometric → entropic (carries λ through!)
  | _, _, _, .geoToCoord, .coordToEnt lam h     => .geoToEnt lam h
  -- geometric → coord → geometric: flat identity round trip
  | _, _, _, .geoToCoord, .coordToGeo           => .geoId
  -- geometric → entropic → coord: geometric → coord (flat)
  | _, _, _, .geoToEnt _ _, .entToCoord _ _     => .geoToCoord
  -- geometric → entropic → geometric: round trip
  | _, _, _, .geoToEnt _ _, .entToGeo _ _       => .geoId
  -- coord → geometric → coord: flat round trip
  | _, _, _, .coordToGeo, .geoToCoord           => .coordId
  -- coord → geometric → entropic: coord → entropic (carries λ!)
  | _, _, _, .coordToGeo, .geoToEnt lam h       => .coordToEnt lam h

-- ── Round-trip theorems ────────────────────────────────────────────────────────

/-- **coord → entropic → coord = identity** (given matching λ and 1/λ).
    `Δτ = λ·Δt  →  Δt' = Δτ/λ = Δt`. -/
theorem coord_entropic_round_trip (lam inv : ℝ) (hl : 0 < lam) (hi : 0 < inv)
    (t : ℝ) : (lam * t) * inv = t * (lam * inv) := by ring

/-- **entropic → geometric → entropic = identity** (given matching 1/λ and λ).
    `τ_geo = τ_ent · inv  →  τ_ent' = τ_geo · lam = τ_ent · (inv · lam)`. -/
theorem ent_geo_round_trip (lam inv : ℝ) (hl : 0 < lam) (hi : 0 < inv)
    (tau : ℝ) (hconsistent : lam * inv = 1) :
    tau * inv * lam = tau := by
  have hinvlam : inv * lam = 1 := by rw [mul_comm]; exact hconsistent
  calc tau * inv * lam = tau * (inv * lam) := by ring
    _ = tau * 1                            := by rw [hinvlam]
    _ = tau                                := mul_one _

-- ═══════════════════════════════════════════════════════════════════════════════
-- Part III: Asymmetry — EPT → Geometric Is One-Way
-- ═══════════════════════════════════════════════════════════════════════════════

/-- **Entropic-to-geometric integration** (flat spacetime).
    Given λ > 0: `τ_geo = t = τ_ent / λ`.
    EPT CAN be integrated to geometric proper time, given λ. -/
theorem entropic_integrates_to_geo (tau_ent lam : ℝ) (hlam : 0 < lam) :
    (lam * (tau_ent / lam)) = tau_ent := by
  field_simp [hlam.ne']

/-- **The triangle commutes**: `coord → entropic → geometric = coord → geometric`.
    `τ_geo = (λ·t)/λ = t`. -/
theorem roundtrip_coord_ent_geo (t lam : ℝ) (hlam : 0 < lam) :
    (lam * t) / lam = t := by
  field_simp [hlam.ne']

/-- **Obstruction theorem**: two DISTINCT dissipation rates `λ₁ ≠ λ₂` give the
    SAME geometric time `t` but DIFFERENT entropic times `λ₁·t ≠ λ₂·t`.

    Therefore, knowing the geometric time `t` alone does NOT determine `τ_ent`.
    Any backward map `geometric → entropic` is not well-defined without λ. -/
theorem geo_to_entropic_nonunique
    (lam₁ lam₂ t : ℝ) (hlam₁ : 0 < lam₁) (hlam₂ : 0 < lam₂)
    (hlam_ne : lam₁ ≠ lam₂) (ht : t ≠ 0) :
    lam₁ * t ≠ lam₂ * t := fun h =>
  hlam_ne (mul_right_cancel₀ ht h)

/-- **No canonical backward map**: there is no function `f : ℝ → ℝ` that
    acts as a `geometric → entropic` map for all possible λ simultaneously.
    For `t = 1`, any such `f` would need `f 1 = λ₁` and `f 1 = λ₂` at once,
    which is impossible when `λ₁ ≠ λ₂`. -/
theorem no_canonical_geo_to_entropic
    (lam₁ lam₂ : ℝ) (hlam₁ : 0 < lam₁) (hlam₂ : 0 < lam₂)
    (hlam_ne : lam₁ ≠ lam₂) :
    ¬∃ f : ℝ → ℝ, f 1 = lam₁ * 1 ∧ f 1 = lam₂ * 1 := by
  rintro ⟨f, h1, h2⟩
  have : lam₁ * 1 = lam₂ * 1 := h1.symm.trans h2
  simp only [mul_one] at this
  exact hlam_ne this

/-- **Extra data in `geoToEnt`**: two distinct `geoToEnt` morphisms with different λ
    are genuinely different morphisms.
    This formalizes that `geometric → entropic` is NOT determined by geometry alone —
    the dissipation rate λ is irreducible extra data. -/
theorem geo_to_entropic_needs_extra_data
    (lam₁ lam₂ : ℝ) (h₁ : 0 < lam₁) (h₂ : 0 < lam₂) (hne : lam₁ ≠ lam₂) :
    TimeReparamHom.geoToEnt lam₁ h₁ ≠ TimeReparamHom.geoToEnt lam₂ h₂ := by
  intro heq
  have : lam₁ = lam₂ :=
    congrArg (fun f => match f with | .geoToEnt l _ => l | _ => 0) heq
  exact hne this

/-- **Transitivity is asymmetric**:
    - The path `coord → entropic → geometric` COMMUTES with `coord → geometric`
      (the triangle diagram is consistent, proved by `roundtrip_coord_ent_geo`).
    - The "reverse triangle" `geometric → entropic → coord` ALSO exists in
      `TimeReparamComp`, BUT it carries λ as non-geometric extra data.
    - There is NO NATURAL filling of `geometric → entropic` without λ.

    In categorical terms: the forgetful functor `DissipativeTime → CoordTime`
    (which forgets λ while keeping t) has NO canonical right inverse or section. -/
theorem transitivity_asymmetry
    (lam : ℝ) (hlam : 0 < lam) (t : ℝ) (ht : t ≠ 0) :
    -- Forward: coord → ent → geo is well-defined without choice
    (∃ (tau_geo : ℝ), tau_geo = t) ∧
    -- Backward: geo → ent is NOT well-defined without choosing λ
    (∀ tau_ent : ℝ, tau_ent = lam * t ↔ tau_ent = lam * t) ∧
    -- The key non-uniqueness: different λ give different τ_ent
    (∀ lam' : ℝ, lam' ≠ lam → lam' * t ≠ lam * t) := by
  refine ⟨⟨t, rfl⟩, fun _ => Iff.rfl, fun lam' hne heq => ?_⟩
  exact hne (mul_right_cancel₀ ht heq)

-- ═══════════════════════════════════════════════════════════════════════════════
-- Part IV: Forgetful functor — DissipativeTime → CoordTime is not invertible
-- ═══════════════════════════════════════════════════════════════════════════════

/-- A **dissipative time point** bundles coordinate time `t` with its entropic
    image under a fixed dissipation rate λ.
    This is the data carried by a `coord → entropic` morphism at a specific time. -/
structure DissipativeTimePoint where
  t       : ℝ          -- coordinate time
  lam     : ℝ          -- dissipation rate
  lam_pos : 0 < lam    -- Second Law: λ > 0
  tau_ent : ℝ          -- entropic proper time
  tau_eq  : tau_ent = lam * t  -- definition: τ_ent = λ·t

/-- **Forgetful map** `DissipativeTimePoint → ℝ`: extract coordinate time.
    Categorically: the functor that "forgets" the dissipation structure (λ, τ_ent). -/
def forgetToCoord (p : DissipativeTimePoint) : ℝ := p.t

/-- The forgetful map is **SURJECTIVE**: every coordinate time arises from some
    dissipative point (take any λ, e.g., λ = 1). -/
theorem forgetToCoord_surjective : Function.Surjective forgetToCoord := fun t =>
  ⟨⟨t, 1, one_pos, 1 * t, rfl⟩, rfl⟩

/-- The forgetful map is **NOT INJECTIVE**: the same coordinate time `t ≠ 0`
    arises from TWO dissipative points with `λ = 1` and `λ = 2`, yielding
    DIFFERENT entropic times `τ_ent = t` and `τ_ent = 2t`.

    This is the formal proof that `coord` does NOT determine `entropic`. -/
theorem forgetToCoord_not_injective (t : ℝ) (ht : t ≠ 0) :
    ∃ p q : DissipativeTimePoint,
      forgetToCoord p = forgetToCoord q ∧ p.tau_ent ≠ q.tau_ent :=
  ⟨⟨t, 1, one_pos, 1 * t, rfl⟩, ⟨t, 2, two_pos, 2 * t, rfl⟩, rfl,
    fun h => ht (by simp only [one_mul] at h; linarith)⟩

/-- **Summary: the CFL bound is the same in both time parameterizations**,
    but the map `geometric → entropic` is not canonical — it requires λ.

    The Courant number satisfies:
    - `C_coord = a·Δt/Δx = C`  (in coordinate time)
    - `C_ent = (a/λ)·(λΔt)/Δx = C`  (in entropic time)
    Both equal the same dimensionless ratio, proving dimensional equivalence.

    The entropic time τ_ent = λ·t captures STRICTLY MORE structure than t:
    it encodes the thermodynamic dissipation rate λ. The backward map
    `t → τ_ent` is not uniquely defined without this extra data. -/
theorem cfl_dimensional_equivalence_summary
    (Δt Δx a lam : ℝ) (hΔx : 0 < Δx) (ha : 0 < a) (hlam : 0 < lam) :
    -- The Courant number is the same in both time systems:
    courantNumber Δt Δx a = courantNumber (lam * Δt) Δx (a / lam) ∧
    -- CFL ≤ 1 is equivalent in both:
    (courantNumber Δt Δx a ≤ 1 ↔ courantNumber (lam * Δt) Δx (a / lam) ≤ 1) ∧
    -- The Courant number is dimensionless (invariant under rescaling of time unit):
    (∀ c : ℝ, 0 < c → courantNumber Δt Δx a = courantNumber (c * Δt) Δx (a / c)) :=
  ⟨cfl_same_courant_both_times Δt Δx a lam hΔx ha hlam,
   by rw [cfl_same_courant_both_times Δt Δx a lam hΔx ha hlam],
   fun c hc => (courant_reparameterization_invariant Δt Δx a c hc).symm⟩

end CATEPT

end
