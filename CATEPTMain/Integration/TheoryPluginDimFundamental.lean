import CATEPTMain.Integration.TheoryPluginDimCategory

set_option autoImplicit false

/-!
# Fundamental Dimensional Analysis: Constants Layer and Rational Exponents

Formalises the key insights from the **Jonsson / CATEPT** synthesis documented in
the dimensional-analysis-mass paper:

## Background and motivation

The existing infrastructure (`InformationDimensionalFrameworkBridge`) works in the
**natural information units** `c = ħ = k_B = 1` with integer exponents.  This
encodes the CATEPT identity `[action] = [ħ] = [I]` cleanly, but it hides the
dimensional role of the universal constants.

The Jonsson analysis reveals three improvements:

1. **Rational exponents** — Planck decompositions like
   `[L] = (G ħ / c³)^{1/2}` require `ℚ`-exponent dimensions, not just `ℤ`.
   `dimension B ℚ` is already provided by the LeanDimensionalAnalysis library
   (since `ℚ` is a `CommRing`). `dimensionZ_to_Q` provides the coercion `ℤ → ℚ`.

2. **Explicit constants layer** — Representing the six-dimensional basis
   `{I, T, Q, Θ, ħ, c}` before reducing to the four-dimensional
   `InformationExtendedBase` via the DimHom `dimHom_constants_to_ext`
   (which sets `ħ = c = 1`) enables the full decomposition table:
   - `[M] = [ħ c⁻² I T⁻¹]` in 6D  →  `[I T⁻¹] = dim_energy_ext` in 4D
   - `[G] = [c⁵ T² ħ⁻¹ I⁻¹]` in 6D  →  `[T² I⁻¹] = dim_G_ext` in 4D

3. **Natural mass dimension and gravitational constant** — In the 4D natural-unit
   basis: `dim_mass_natural = dim_energy_ext = [I T⁻¹]` (E = mc², c = 1), and
   `dim_G_ext = [T² I⁻¹]` from Newton's law.

## Relation to existing code

- `dim_mass_ext = [I T⁻²]` (existing ISQ-bridge convention) is preserved.
- `dim_mass_natural = dim_energy_ext = [I T⁻¹]` is the natural-unit convention.
- `dim_G_ext = [T² I⁻¹]` is new — not in `InformationDimensionalFrameworkBridge`.

## Theorem status (zero sorry)

| Name                                    | Status |
|-----------------------------------------|--------|
| `dimensionZ_to_Q_one`                   | proved |
| `dimensionZ_to_Q_mul`                   | proved |
| `dimHom_constants_to_ext`               | proved |
| `mass_full_maps_to_energy_ext`          | proved |
| `energy_full_maps_to_energy_ext`        | proved |
| `length_full_maps_to_time_ext`          | proved |
| `G_full_maps_to_G_ext`                  | proved |
| `dim_mass_natural_eq_energy`            | proved |
| `dim_force_natural_eq`                  | proved |
| `dim_G_Newton_consistent`               | proved |
| `dim_G_Jacobson`                        | proved |
| `dim_G_dual_derivation_agree`           | proved |
| `jonssonTable_length`                   | proved |

-/

namespace CATEPTMain.Integration

open InformationDimensionalFramework.Concrete
open InformationDimensionalFramework.QuantumAction

-- ── Part A: Rational exponent coercion ───────────────────────────────────────

/-- Coerce an integer-exponent dimension to a rational-exponent one. -/
def dimensionZ_to_Q {B : Type*} [DecidableEq B] [Fintype B]
    (d : dimension B ℤ) : dimension B ℚ :=
  fun b => (d b : ℚ)

/-- Coercion respects multiplication. -/
theorem dimensionZ_to_Q_mul {B : Type*} [DecidableEq B] [Fintype B]
    (d₁ d₂ : dimension B ℤ) :
    dimensionZ_to_Q (d₁ * d₂) = dimensionZ_to_Q d₁ * dimensionZ_to_Q d₂ := by
  funext b
  simp only [dimensionZ_to_Q, dimension.mul_def', Int.cast_add]

/-- Coercion sends the dimensionless identity to the dimensionless identity. -/
theorem dimensionZ_to_Q_one {B : Type*} [DecidableEq B] [Fintype B] :
    dimensionZ_to_Q (1 : dimension B ℤ) = 1 := by
  funext b
  simp only [dimensionZ_to_Q, dimension.one_eq_dimensionless,
             dimension.dimensionless_def', Function.const_apply, Int.cast_zero]

/-!
### Planck-scale rational dimensions

With natural units the Planck decompositions require `dimension B ℚ`:
- `[L_P] = (G ħ / c³)^{1/2}` — needs half-integer exponent
- `[M_P] = (ħ c / G)^{1/2}` — needs half-integer exponent
-/

/-- Rational lift of `dim_information`. -/
def dim_information_q : dimension InformationExtendedBase ℚ :=
  dimensionZ_to_Q dim_information

/-- Rational lift of `dim_time_ext`. -/
def dim_time_q : dimension InformationExtendedBase ℚ :=
  dimensionZ_to_Q dim_time_ext

/-- Rational G dimension: `[G] = [T² I⁻¹]` (defined in Part C, lifted to ℚ). -/
noncomputable def dim_G_q : dimension InformationExtendedBase ℚ :=
  dim_time_q * dim_time_q * dim_information_q⁻¹

/-- Planck length (ℚ-exponents): `[L_P] = (G ħ / c³)^{1/2}` with c=1, ħ=[I]:
    `= (dim_G_q · dim_information_q)^{1/2} = (dim_time_q²)^{1/2} = dim_time_q`. -/
noncomputable def dim_planck_length_q : dimension InformationExtendedBase ℚ :=
  (dim_G_q * dim_information_q) ^ ((1 : ℚ) / 2)

/-- Planck mass (ℚ-exponents): `[M_P] = (ħ / G)^{1/2}` with c=1, ħ=[I]:
    `= (dim_information_q / dim_G_q)^{1/2} = (dim_information_q² / dim_time_q²)^{1/2}`. -/
noncomputable def dim_planck_mass_q : dimension InformationExtendedBase ℚ :=
  (dim_information_q / dim_G_q) ^ ((1 : ℚ) / 2)

-- ── Part B: Explicit constants layer ─────────────────────────────────────────

/-!
### B.1  The six-dimensional `InformationConstantsBase`

Before setting `ħ = c = 1`, physical quantities live in a richer
basis `{I, T, Q, Θ, ħ-exponent, c-exponent}`.  The Jonsson table gives:

| Quantity   | Dimension in 6D basis             |
|------------|-----------------------------------|
| Mass       | `[ħ c⁻² I T⁻¹]`                  |
| Energy     | `[ħ I T⁻¹]`                      |
| Length     | `[c T]`                           |
| Momentum   | `[ħ c⁻¹ I T⁻¹]`                  |
| Grav. const| `[c⁵ T² ħ⁻¹ I⁻¹]`               |

Setting `ħ = c = 1` via `dimHom_constants_to_ext` recovers:
- `[M]` → `[I T⁻¹] = dim_energy_ext` (E = mc², c = 1)
- `[E]` → `[I T⁻¹] = dim_energy_ext` (E = ħω, ħ = 1)
- `[L]` → `[T] = dim_time_ext` (L = cT, c = 1)
- `[G]` → `[T² I⁻¹] = dim_G_ext`
-/

/-- Six-dimensional basis tracking ħ and c exponents explicitly. -/
inductive InformationConstantsBase
  /-- The information dimension `[I]`. -/
  | information
  /-- The time dimension `[T]`. -/
  | time
  /-- The electric charge dimension `[Q]`. -/
  | charge
  /-- The temperature dimension `[Θ]`. -/
  | temperature
  /-- The `ħ`-exponent axis.  Setting `ħ = 1` collapses this. -/
  | hbar
  /-- The `c`-exponent axis.  Setting `c = 1` collapses this. -/
  | c_speed
  deriving DecidableEq, Repr, Fintype

/-!
### B.2  Key quantity dimensions in the 6D basis (Jonsson table)

All 6D dimensions are defined as explicit integer-valued functions on the
enum, which makes the bridge theorems decidable.
-/

/-- `[I]` in the constants basis. -/
def dim_information_6d : dimension InformationConstantsBase ℤ :=
  fun b => if b = .information then 1 else 0

/-- `[T]` in the constants basis. -/
def dim_time_6d : dimension InformationConstantsBase ℤ :=
  fun b => if b = .time then 1 else 0

/-- `[Q]` in the constants basis. -/
def dim_charge_6d : dimension InformationConstantsBase ℤ :=
  fun b => if b = .charge then 1 else 0

/-- `[ħ]` axis in the constants basis. -/
def dim_hbar_6d : dimension InformationConstantsBase ℤ :=
  fun b => if b = .hbar then 1 else 0

/-- `[c]` axis in the constants basis. -/
def dim_c_6d : dimension InformationConstantsBase ℤ :=
  fun b => if b = .c_speed then 1 else 0

/-- `[M] = [ħ c⁻² I T⁻¹]` — explicit exponents:
    ħ: 1, c: -2, information: 1, time: -1, others: 0. -/
def dim_mass_6d : dimension InformationConstantsBase ℤ :=
  fun b => match b with
  | .information => 1 | .time => -1 | .hbar => 1 | .c_speed => -2 | _ => 0

/-- `[E] = [ħ I T⁻¹]` — explicit exponents:
    ħ: 1, information: 1, time: -1, others: 0. -/
def dim_energy_6d : dimension InformationConstantsBase ℤ :=
  fun b => match b with
  | .information => 1 | .time => -1 | .hbar => 1 | _ => 0

/-- `[L] = [c T]` — explicit exponents: c: 1, time: 1, others: 0. -/
def dim_length_6d : dimension InformationConstantsBase ℤ :=
  fun b => match b with
  | .time => 1 | .c_speed => 1 | _ => 0

/-- `[p] = [ħ c⁻¹ I T⁻¹]` — explicit exponents:
    ħ: 1, c: -1, information: 1, time: -1, others: 0. -/
def dim_momentum_6d : dimension InformationConstantsBase ℤ :=
  fun b => match b with
  | .information => 1 | .time => -1 | .hbar => 1 | .c_speed => -1 | _ => 0

/-- `[G] = [c⁵ T² ħ⁻¹ I⁻¹]` — from Jacobson/Verlinde `S_A = A c³ / (4 G ħ)`:
    c: 5, time: 2, ħ: -1, information: -1, others: 0. -/
def dim_G_6d : dimension InformationConstantsBase ℤ :=
  fun b => match b with
  | .c_speed => 5 | .time => 2 | .hbar => -1 | .information => -1 | _ => 0

/-!
### B.3  The projection DimHom: 6D → 4D (setting ħ = c = 1)

`dimHom_constants_to_ext` discards the `ħ` and `c` exponent axes.
-/

/-- The ħ = c = 1 projection: maps 6D constants basis to 4D InformationExtended. -/
def dimHom_constants_to_ext :
    DimHom InformationConstantsBase InformationExtendedBase where
  hom :=
    { toFun   := fun d => fun b => match b with
        | .information => d .information
        | .time        => d .time
        | .charge      => d .charge
        | .temperature => d .temperature
      map_one' := by
        funext b; fin_cases b <;>
          simp [dimension.one_eq_dimensionless,
                dimension.dimensionless_def', Function.const_apply]
      map_mul' := fun d₁ d₂ => by
        funext b; fin_cases b <;>
          simp [dimension.mul_def'] }

-- Helper: unfold the projection
private lemma constants_apply_info (d : dimension InformationConstantsBase ℤ) :
    (dimHom_constants_to_ext.apply d) .information = d .information := by
  simp [DimHom.apply, dimHom_constants_to_ext]

private lemma constants_apply_time (d : dimension InformationConstantsBase ℤ) :
    (dimHom_constants_to_ext.apply d) .time = d .time := by
  simp [DimHom.apply, dimHom_constants_to_ext]

private lemma constants_apply_charge (d : dimension InformationConstantsBase ℤ) :
    (dimHom_constants_to_ext.apply d) .charge = d .charge := by
  simp [DimHom.apply, dimHom_constants_to_ext]

private lemma constants_apply_temperature (d : dimension InformationConstantsBase ℤ) :
    (dimHom_constants_to_ext.apply d) .temperature = d .temperature := by
  simp [DimHom.apply, dimHom_constants_to_ext]

-- Helper: evaluate dim_energy_ext at each slot
private lemma energy_ext_info : dim_energy_ext .information = 1 := by native_decide

private lemma energy_ext_time : dim_energy_ext .time = -1 := by native_decide

private lemma energy_ext_charge : dim_energy_ext .charge = 0 := by native_decide

private lemma energy_ext_temperature : dim_energy_ext .temperature = 0 := by native_decide

-- Helper: evaluate dim_time_ext at each slot
private lemma time_ext_info : dim_time_ext .information = 0 := by
  simp [dim_time_ext]

private lemma time_ext_time : dim_time_ext .time = 1 := by
  simp [dim_time_ext]

private lemma time_ext_charge : dim_time_ext .charge = 0 := by
  simp [dim_time_ext]

private lemma time_ext_temperature : dim_time_ext .temperature = 0 := by
  simp [dim_time_ext]

/-!
### B.4  Bridge theorems: 6D → 4D projections
-/

/-- Under ħ = c = 1: `[M]_6d = [ħ c⁻² I T⁻¹]` maps to `[I T⁻¹] = dim_energy_ext`.
    Formally resolves E = mc² with c = 1. -/
theorem mass_full_maps_to_energy_ext :
    dimHom_constants_to_ext.apply dim_mass_6d = dim_energy_ext := by
  funext b; fin_cases b
  · rw [constants_apply_info]; simp [dim_mass_6d, energy_ext_info]
  · rw [constants_apply_time]; simp [dim_mass_6d, energy_ext_time]
  · rw [constants_apply_charge]; simp [dim_mass_6d, energy_ext_charge]
  · rw [constants_apply_temperature]; simp [dim_mass_6d, energy_ext_temperature]

/-- Under ħ = c = 1: `[E]_6d = [ħ I T⁻¹]` maps to `[I T⁻¹] = dim_energy_ext`. -/
theorem energy_full_maps_to_energy_ext :
    dimHom_constants_to_ext.apply dim_energy_6d = dim_energy_ext := by
  funext b; fin_cases b
  · rw [constants_apply_info]; simp [dim_energy_6d, energy_ext_info]
  · rw [constants_apply_time]; simp [dim_energy_6d, energy_ext_time]
  · rw [constants_apply_charge]; simp [dim_energy_6d, energy_ext_charge]
  · rw [constants_apply_temperature]; simp [dim_energy_6d, energy_ext_temperature]

/-- Under ħ = c = 1: `[L]_6d = [c T]` maps to `[T] = dim_time_ext`. -/
theorem length_full_maps_to_time_ext :
    dimHom_constants_to_ext.apply dim_length_6d = dim_time_ext := by
  funext b; fin_cases b
  · rw [constants_apply_info]; simp [dim_length_6d, time_ext_info]
  · rw [constants_apply_time]; simp [dim_length_6d, time_ext_time]
  · rw [constants_apply_charge]; simp [dim_length_6d, time_ext_charge]
  · rw [constants_apply_temperature]; simp [dim_length_6d, time_ext_temperature]

/-- Under ħ = c = 1: `[G]_6d = [c⁵ T² ħ⁻¹ I⁻¹]` maps to `dim_G_ext = [T² I⁻¹]`.
    This is the Jacobson derivation projected to natural units. -/
theorem G_full_maps_to_G_ext :
    dimHom_constants_to_ext.apply dim_G_6d =
      dim_time_ext * dim_time_ext * dim_information⁻¹ := by
  funext b; fin_cases b
  all_goals simp only [constants_apply_info, constants_apply_time,
                       constants_apply_charge, constants_apply_temperature,
                       dim_G_6d, dim_time_ext, dim_information,
                       dimension.mul_def', Pi.single_apply,
                       dimension.inv_def, dimension.pow_def']
  all_goals native_decide

-- ── Part C: Natural mass dimension and gravitational constant ─────────────────

/-!
### C.1  Natural mass dimension

`dim_mass_natural = dim_energy_ext = [I T⁻¹]` — the natural-unit convention.
(`dim_mass_ext = [I T⁻²]` from the ISQ bridge is kept for compatibility.)
-/

/-- Natural mass dimension: `[M] = [E] = [I T⁻¹]`. -/
def dim_mass_natural : dimension InformationExtendedBase ℤ := dim_energy_ext

theorem dim_mass_natural_eq_energy : dim_mass_natural = dim_energy_ext := rfl

/-- Natural force dimension: `[F] = [M a] = [M L/T²] = [M/T]` (since L = T):
    `dim_force_natural = [I T⁻¹] / [T] = [I T⁻²]`. -/
def dim_force_natural : dimension InformationExtendedBase ℤ :=
  dim_mass_natural * dim_time_ext⁻¹

/-- `dim_force_natural` spelled out: `[F] = [I T⁻²]`. -/
theorem dim_force_natural_eq :
    dim_force_natural = dim_information * dim_time_ext⁻¹ * dim_time_ext⁻¹ := by
  simp only [dim_force_natural, dim_mass_natural_eq_energy, dim_energy_ext]

/-!
### C.2  Gravitational constant dimension

From Newton's law `F = G m₁ m₂ / r²`:

    [G] = [F r²] / [M²]
        = [I T⁻²][T²] / ([I T⁻¹])²
        = [I] / [I² T⁻²]
        = [T² I⁻¹]
-/

/-- Gravitational constant dimension in natural units: `[G] = [T² I⁻¹]`. -/
def dim_G_ext : dimension InformationExtendedBase ℤ :=
  dim_time_ext * dim_time_ext * dim_information⁻¹

/-- Newton's law consistency: `[G] = [F L²] / [M²]` with `dim_mass_natural`. -/
theorem dim_G_Newton_consistent :
    dim_G_ext = dim_force_natural * dim_time_ext * dim_time_ext *
                  dim_mass_natural⁻¹ * dim_mass_natural⁻¹ := by
  funext b; fin_cases b <;> native_decide

/-- Alternative form: `[G] = [T²] / [I]`. -/
theorem dim_G_Jacobson :
    dim_G_ext = dim_time_ext * dim_time_ext / dim_information := by
  unfold dim_G_ext
  rw [dimension.div_eq_mul_inv]

/-- Jacobson projection and Newton agree: both give `dim_G_ext`. -/
theorem G_full_maps_to_G_ext_natural :
    dimHom_constants_to_ext.apply dim_G_6d = dim_G_ext := by
  rw [G_full_maps_to_G_ext, dim_G_ext]

/-- Combined: both derivations of G agree. -/
theorem dim_G_dual_derivation_agree :
    dimHom_constants_to_ext.apply dim_G_6d =
      dim_force_natural * dim_time_ext * dim_time_ext *
        dim_mass_natural⁻¹ * dim_mass_natural⁻¹ := by
  rw [G_full_maps_to_G_ext_natural, dim_G_Newton_consistent]

-- ── Part D: PhysicalQuantity dual representation ─────────────────────────────

/-- A physical quantity with its classical ISQ and fundamental [I, T, Q, Θ] dimensions. -/
structure PhysicalQuantityFormal where
  /-- Human-readable name. -/
  name          : String
  /-- Classical ISQ dimension (integer exponents). -/
  classicalDim  : dimension ISQ ℤ
  /-- Fundamental dimension in the CATEPT [I, T, Q, Θ] natural-unit basis. -/
  fundamentalDim : dimension InformationExtendedBase ℤ

-- ISQ composite dimension abbreviations
private def dim_action_ISQ : dimension ISQ ℤ :=
  dimension.mass ISQ ℤ * dimension.length ISQ ℤ ^ (2 : ℤ) * (dimension.time ISQ ℤ)⁻¹

private def dim_momentum_ISQ : dimension ISQ ℤ :=
  dimension.mass ISQ ℤ * dimension.length ISQ ℤ * (dimension.time ISQ ℤ)⁻¹

private def dim_power_ISQ : dimension ISQ ℤ :=
  dimension.energy ISQ ℤ * (dimension.time ISQ ℤ)⁻¹

private def dim_charge_ISQ : dimension ISQ ℤ :=
  dimension.current ISQ ℤ * dimension.time ISQ ℤ

/-- G in ISQ: [M⁻¹ L³ T⁻²]. -/
private def dim_G_ISQ : dimension ISQ ℤ :=
  (dimension.mass ISQ ℤ)⁻¹ * dimension.length ISQ ℤ ^ (3 : ℤ) *
    (dimension.time ISQ ℤ) ^ (-2 : ℤ)

/-!
### The Jonsson decomposition table (corrected final version)

Fundamental dims are in the [I, T, Q, Θ] basis with c = ħ = k_B = 1:

| Quantity      | ISQ              | Fundamental [I, T, Q, Θ]                    |
|---------------|------------------|----------------------------------------------|
| Length        | L¹               | [T¹]   (L = cT, c=1)                        |
| Time          | T¹               | [T¹]   (primitive)                           |
| Mass          | M¹               | [I T⁻¹]  (E=mc², c=1; = dim_mass_natural)   |
| Velocity      | L¹ T⁻¹           | 1  (dimensionless, L/T = cT/T = c = 1)       |
| Energy        | M¹ L² T⁻²        | [I T⁻¹]  (E = ħω, ħ=1)                     |
| Action/ħ      | M¹ L² T⁻¹        | [I]  (CATEPT: action = information)          |
| Entropy       | (same as action) | [I]  (S = k_B·I, k_B=1)                     |
| Momentum      | M¹ L¹ T⁻¹        | [I T⁻¹]  (p = E/c = E, c=1)                |
| Force         | M¹ L¹ T⁻²        | [I T⁻²]  (F = [M/T])                        |
| Power         | M¹ L² T⁻³        | [I T⁻²]  (P = F·v = F·c = F)               |
| Charge        | Q¹               | [Q¹]  (primitive)                            |
| Grav. const.  | M⁻¹ L³ T⁻²       | [T² I⁻¹]  (Newton: F = G m² / r²)          |
-/

/-- The Jonsson decomposition table: classical ↔ fundamental dimensions. -/
def jonssonDecompositionTable : List PhysicalQuantityFormal := [
  { name := "Length",
    classicalDim   := dimension.length ISQ ℤ,
    fundamentalDim := dim_time_ext },
  { name := "Time",
    classicalDim   := dimension.time ISQ ℤ,
    fundamentalDim := dim_time_ext },
  { name := "Mass",
    classicalDim   := dimension.mass ISQ ℤ,
    fundamentalDim := dim_mass_natural },
  { name := "Velocity",
    classicalDim   := dimension.velocity ISQ ℤ,
    fundamentalDim := 1 },
  { name := "Energy",
    classicalDim   := dimension.energy ISQ ℤ,
    fundamentalDim := dim_energy_ext },
  { name := "Action",
    classicalDim   := dim_action_ISQ,
    fundamentalDim := dim_information },
  { name := "Entropy",
    classicalDim   := dim_action_ISQ,
    fundamentalDim := dim_entropy_ext },
  { name := "Momentum",
    classicalDim   := dim_momentum_ISQ,
    fundamentalDim := dim_energy_ext },
  { name := "Force",
    classicalDim   := dimension.force ISQ ℤ,
    fundamentalDim := dim_force_natural },
  { name := "Power",
    classicalDim   := dim_power_ISQ,
    fundamentalDim := dim_information * dim_time_ext⁻¹ * dim_time_ext⁻¹ },
  { name := "Charge",
    classicalDim   := dim_charge_ISQ,
    fundamentalDim := dim_charge_ext },
  { name := "GravConst",
    classicalDim   := dim_G_ISQ,
    fundamentalDim := dim_G_ext }
]

/-- The decomposition table has exactly 12 entries. -/
theorem jonssonTable_length :
    jonssonDecompositionTable.length = 12 := by native_decide

end CATEPTMain.Integration
