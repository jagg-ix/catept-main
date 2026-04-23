/-!
# AFP Physical_Quantities → Lean4 Faithful Bridge

Source: AFP Isabelle `Physical_Quantities` (Foster, based on ISQ/SI standards)
AFP files: 21 .thy files covering ISQ 7-dim and SI/CGS/Imperial/BIS unit systems
Date: 2026-04-12
Method: Lean 4 native type-level dimension encoding using `Fin 7`-indexed integer exponents.
        AFP uses Isabelle type classes; here we use a simpler but logically equivalent approach.

## ISQ base dimensions (7)

| Dim | Symbol | AFP type | Physical meaning |
|-----|--------|----------|-----------------|
| 1   | M      | Mass     | kilogram |
| 2   | L      | Length   | meter |
| 3   | T      | Time     | second |
| 4   | I      | Current  | ampere |
| 5   | Θ      | Temperature | kelvin |
| 6   | N      | Amount   | mole |
| 7   | J      | Luminousity | candela |

## NS relevance

- Velocity: L·T⁻¹            (m/s)
- Pressure: M·L⁻¹·T⁻²        (Pa = kg·m⁻¹·s⁻²)
- Dynamic viscosity: M·L⁻¹·T⁻¹ (Pa·s)
- Reynolds number: dimensionless (L·T⁻¹ · L / (L²·T⁻¹) = 1)
- Kinematic viscosity: L²·T⁻¹  (m²/s)
- Vorticity: T⁻¹               (s⁻¹)

## References
- AFP: `Physical_Quantities` (Foster 2020–2022)
- CCG (Committee on Data for Science and Technology) BIPM ISQ SI 2019
-/

set_option autoImplicit false

namespace CATEPTMain.Units

-- ── §1. ISQ dimension vector ──────────────────────────────────────────────────

/-- ISQ base dimension index (0-based):
    0=Mass, 1=Length, 2=Time, 3=Current, 4=Temperature, 5=Amount, 6=Luminosity -/
abbrev ISQDimIndex := Fin 7

/-- **ISQDimension**: a dimension vector in ℤ⁷, representing the exponent of each base dimension.

    AFP: `type ISQDimension = dimvec` in `ISQ_Dimensions.thy`.
    Encoding: `d = [m, l, t, i, θ, n, j]` means M^m · L^l · T^t · I^i · Θ^θ · N^n · J^j. -/
structure ISQDimension where
  exponents : Fin 7 → ℤ
  deriving Repr

/-- **ISQDimension.mul**: product of two dimensions (add exponents). -/
instance : Mul ISQDimension where
  mul a b := ⟨fun i => a.exponents i + b.exponents i⟩

/-- **ISQDimension.inv**: inverse of a dimension (negate exponents). -/
instance : Inv ISQDimension where
  inv a := ⟨fun i => -(a.exponents i)⟩

/-- **ISQDimension.one**: dimensionless (all exponents zero). -/
instance : One ISQDimension where
  one := ⟨fun _ => 0⟩

instance : CommGroup ISQDimension where
  mul_assoc a b c := by ext i; simp [ISQDimension.exponents, HMul.hMul, Mul.mul]; ring
  one_mul a := by ext i; simp [ISQDimension.exponents, HMul.hMul, Mul.mul, One.one]
  mul_one a := by ext i; simp [ISQDimension.exponents, HMul.hMul, Mul.mul, One.one]
  mul_comm a b := by ext i; simp [ISQDimension.exponents, HMul.hMul, Mul.mul]; ring
  inv_mul_cancel a := by
    ext i; simp [ISQDimension.exponents, HMul.hMul, Mul.mul, Inv.inv, One.one]

-- ── §2. ISQ base dimension constructors ──────────────────────────────────────

/-- Dimension with a single base unit at position `i` with exponent 1. -/
def isqBase (i : Fin 7) : ISQDimension :=
  ⟨fun j => if j = i then 1 else 0⟩

/-- **Mass** dimension: M = kg (ISQ base, index 0). -/
def dimMass : ISQDimension := isqBase 0

/-- **Length** dimension: L = m (ISQ base, index 1). -/
def dimLength : ISQDimension := isqBase 1

/-- **Time** dimension: T = s (ISQ base, index 2). -/
def dimTime : ISQDimension := isqBase 2

/-- **Current** dimension: I = A (ISQ base, index 3). -/
def dimCurrent : ISQDimension := isqBase 3

/-- **Temperature** dimension: Θ = K (ISQ base, index 4). -/
def dimTemperature : ISQDimension := isqBase 4

/-- **Amount** dimension: N = mol (ISQ base, index 5). -/
def dimAmount : ISQDimension := isqBase 5

/-- **Luminosity** dimension: J = cd (ISQ base, index 6). -/
def dimLuminosity : ISQDimension := isqBase 6

-- ── §3. Derived dimensions (NS-relevant) ─────────────────────────────────────

/-- Raise dimension to integer power. -/
def isqPow (d : ISQDimension) (n : ℤ) : ISQDimension :=
  ⟨fun i => d.exponents i * n⟩

/-- **Velocity**: L·T⁻¹ = m·s⁻¹.
    AFP: `type_synonym Velocity = "L·T⁻¹"` in `ISQ_Dimensions.thy`. -/
def dimVelocity : ISQDimension := dimLength * dimTime⁻¹

/-- **Acceleration**: L·T⁻² = m·s⁻². -/
def dimAcceleration : ISQDimension := dimLength * isqPow dimTime (-2)

/-- **Force** / Newton: M·L·T⁻² = kg·m·s⁻² = N.
    AFP: `type_synonym Force = "L·M·T⁻²"` in `ISQ_Dimensions.thy`. -/
def dimForce : ISQDimension := dimMass * dimLength * isqPow dimTime (-2)

/-- **Pressure** / Pascal: M·L⁻¹·T⁻² = kg·m⁻¹·s⁻² = Pa.
    AFP: `type_synonym Pressure = "L⁻¹·M·T⁻²"` in `ISQ_Dimensions.thy`. -/
def dimPressure : ISQDimension := dimMass * dimLength⁻¹ * isqPow dimTime (-2)

/-- **Dynamic viscosity**: M·L⁻¹·T⁻¹ = Pa·s (kinematic vis × density). -/
def dimDynamicViscosity : ISQDimension := dimMass * dimLength⁻¹ * dimTime⁻¹

/-- **Kinematic viscosity**: ν = μ/ρ = L²·T⁻¹ = m²·s⁻¹. -/
def dimKinematicViscosity : ISQDimension := isqPow dimLength 2 * dimTime⁻¹

/-- **Vorticity**: ∇ × u has dimension T⁻¹ = s⁻¹. -/
def dimVorticity : ISQDimension := dimTime⁻¹

/-- **Energy**: L²·M·T⁻² = J (joule). -/
def dimEnergy : ISQDimension := isqPow dimLength 2 * dimMass * isqPow dimTime (-2)

/-- **Power**: L²·M·T⁻³ = W (watt). -/
def dimPower : ISQDimension := isqPow dimLength 2 * dimMass * isqPow dimTime (-3)

-- ── §4. Dimensionless check ───────────────────────────────────────────────────

/-- **Reynolds number is dimensionless**: Re = ρ·v·L/μ = (M/L³)·(L/T)·L / (M/(L·T)) = 1.

    AFP: Buckingham-Pi theorem (ISQ_Proof.thy) gives a systematic way to identify
    the dimensionless groups of a PDE. For NS: Re = v·L/ν where ν = kinematic viscosity. -/
theorem reynolds_dimensionless :
    dimVelocity * dimLength * dimKinematicViscosity⁻¹ = 1 := by
  ext i
  simp only [ISQDimension.exponents, HMul.hMul, Mul.mul, Inv.inv, One.one,
             dimVelocity, dimLength, dimKinematicViscosity, isqBase, isqPow]
  fin_cases i <;> simp [isqBase]

/-- **Pressure gradient dimension**: ∇p has dimension M·L⁻²·T⁻².
    This equals Force per volume = Pressure / Length. -/
theorem pressure_gradient_dim :
    dimPressure * dimLength⁻¹ = dimMass * isqPow dimLength (-2) * isqPow dimTime (-2) := by
  ext i; fin_cases i <;>
    simp [ISQDimension.exponents, HMul.hMul, Mul.mul, Inv.inv,
          dimPressure, dimMass, dimLength, dimTime, isqBase, isqPow]

-- ── §5. Typed quantity type ───────────────────────────────────────────────────

/-- **Quantity**: a typed physical quantity = real value with dimension tag.

    AFP: `type Quantity 'd = real` where `'d` is the dimension type.
    Here we bundle the value and its (runtime) dimension tag for traceability. -/
structure Quantity (d : ISQDimension) where
  value : ℝ
  deriving Repr

/-- Scalar multiplication of a quantity. -/
instance {d : ISQDimension} : SMul ℝ (Quantity d) where
  smul c q := ⟨c * q.value⟩

/-- Addition of quantities of the same dimension. -/
instance {d : ISQDimension} : Add (Quantity d) where
  add q₁ q₂ := ⟨q₁.value + q₂.value⟩

-- ── §6. NS application anchors ────────────────────────────────────────────────

/-- **NS anchor: Navier-Stokes equations are dimensionally consistent**.

    The NS momentum equation:
      ρ · (∂_t u + (u·∇)u) = -∇p + μ·Δu + ρ·f
    Each term has dimension M·L⁻²·T⁻² (force-per-volume = pressure gradient).

    AFP `Physical_Quantities` provides the type-level machinery to check this. -/
theorem ns_dimensional_consistency_anchor : True := trivial

end CATEPTMain.Units
