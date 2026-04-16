import CATEPTMain.Integration.TheoryPluginDimCore

set_option autoImplicit false

/-!
# Dimensional Analysis: Category Structure and Theory-Level Unit Declarations

Two inter-related extensions to the plugin dimensional analysis infrastructure:

## Part A — The category of dimension algebras

`dimension B ℤ` is an abelian group under pointwise-exponent multiplication.
A **dimension homomorphism** `DimHom B B'` is a `MonoidHom` (multiplicative)
between these groups.  The `DimHom` type forms a category:

- `DimHom.id B`          — identity morphism
- `DimHom.comp g f`      — composition
- `DimHom.id_comp`, `DimHom.comp_id`, `DimHom.assoc` — category axioms

`dimHom_ISQ_to_Ext` wraps `convertISQToExtended` (already proved to be a
monoid hom in `InformationDimensionalFrameworkBridge`) as a proper `DimHom`.

## Part B — Theory-level unit declarations and physical scale

A theory at a given scale commits to a **unit system**: it names a `PhysicalScale`,
declares which base dimensions are "natural" (set to 1), and supplies a `DimHom`
from its working basis back to the global [I]-basis.

- `PhysicalScale`           — named scales (Planck, quantum, natural, SI, information)
- `NaturalUnitChoice B`     — list of dims set to 1 + the scale
- `TheoryUnitContext plugin B` — bundles scale, unit choice, and `toBasis : DimHom B Ext`
- `TheoryBasisDimensions B` — declares key quantity dims *in basis B*
- `TheoryUnitContext.toPluginDimCore` — translates B-basis declarations to [I]-basis
- `canonicalInfoUnitContext`    — the CAT/EPT default (identity hom, information scale)

## Theorem status (zero sorry)

| Name                                  | Status |
|---------------------------------------|--------|
| `DimHom.id_comp`                      | proved |
| `DimHom.comp_id`                      | proved |
| `DimHom.assoc`                        | proved |
| `dimHom_ISQ_to_Ext`                   | proved |
| `dimHom_ISQ_to_Ext_time`              | proved |
| `dimHom_ISQ_to_Ext_mass`              | proved |
| `canonicalInfoUnitContext_core_eq`    | proved |
| `canonicalInfoUnitContext_axioms`     | proved |

-/

namespace CATEPTMain.Integration

open InformationDimensionalFramework.Concrete
open InformationDimensionalFramework.QuantumAction

-- ============================================================================
-- Part A: The category of dimension algebras
-- ============================================================================

-- ── A.1  Morphisms ────────────────────────────────────────────────────────────

/-- A dimension homomorphism from base B to base B': a `MonoidHom` between the
    multiplicative abelian groups `dimension B ℤ` and `dimension B' ℤ`.

    This is the morphism type for the (informal) category `DimAlgCat` whose
    objects are base dimension types and whose hom-sets are `DimHom B B'`. -/
structure DimHom (B B' : Type*)
    [DecidableEq B]  [Fintype B]
    [DecidableEq B'] [Fintype B'] where
  /-- The underlying MonoidHom (for the multiplicative = additive-exponent group). -/
  hom : dimension B ℤ →* dimension B' ℤ

/-- Apply a DimHom to a dimension. -/
def DimHom.apply
    {B B' : Type*} [DecidableEq B] [Fintype B] [DecidableEq B'] [Fintype B']
    (f : DimHom B B') (d : dimension B ℤ) : dimension B' ℤ :=
  f.hom d

-- ── A.2  Identity and composition ─────────────────────────────────────────────

/-- Identity dimension homomorphism: every dimension maps to itself. -/
def DimHom.id (B : Type*) [DecidableEq B] [Fintype B] : DimHom B B :=
  { hom := MonoidHom.id (dimension B ℤ) }

/-- Composition of dimension homomorphisms (g after f). -/
def DimHom.comp
    {B B' B'' : Type*}
    [DecidableEq B]   [Fintype B]
    [DecidableEq B']  [Fintype B']
    [DecidableEq B''] [Fintype B'']
    (g : DimHom B' B'') (f : DimHom B B') : DimHom B B'' :=
  { hom := g.hom.comp f.hom }

-- ── A.3  Category axioms ───────────────────────────────────────────────────────

theorem DimHom.id_comp
    {B B' : Type*} [DecidableEq B] [Fintype B] [DecidableEq B'] [Fintype B']
    (f : DimHom B B') :
    DimHom.comp (DimHom.id B') f = f := by
  rcases f with ⟨hf⟩
  simp only [DimHom.comp, DimHom.id, MonoidHom.id_comp]

theorem DimHom.comp_id
    {B B' : Type*} [DecidableEq B] [Fintype B] [DecidableEq B'] [Fintype B']
    (f : DimHom B B') :
    DimHom.comp f (DimHom.id B) = f := by
  rcases f with ⟨hf⟩
  simp only [DimHom.comp, DimHom.id, MonoidHom.comp_id]

theorem DimHom.assoc
    {B₁ B₂ B₃ B₄ : Type*}
    [DecidableEq B₁] [Fintype B₁]
    [DecidableEq B₂] [Fintype B₂]
    [DecidableEq B₃] [Fintype B₃]
    [DecidableEq B₄] [Fintype B₄]
    (h : DimHom B₃ B₄) (g : DimHom B₂ B₃) (f : DimHom B₁ B₂) :
    DimHom.comp h (DimHom.comp g f) = DimHom.comp (DimHom.comp h g) f := by
  rcases h with ⟨hh⟩; rcases g with ⟨hg⟩; rcases f with ⟨hf⟩
  simp only [DimHom.comp, MonoidHom.comp_assoc]

-- ── A.4  Hom preservation lemmas ─────────────────────────────────────────────

/-- A DimHom preserves the dimensionless unit. -/
theorem DimHom.apply_one
    {B B' : Type*} [DecidableEq B] [Fintype B] [DecidableEq B'] [Fintype B']
    (f : DimHom B B') :
    f.apply 1 = 1 :=
  f.hom.map_one

/-- A DimHom preserves multiplication (= exponent addition). -/
theorem DimHom.apply_mul
    {B B' : Type*} [DecidableEq B] [Fintype B] [DecidableEq B'] [Fintype B']
    (f : DimHom B B') (d₁ d₂ : dimension B ℤ) :
    f.apply (d₁ * d₂) = f.apply d₁ * f.apply d₂ :=
  f.hom.map_mul d₁ d₂

/-- A DimHom preserves inverses. -/
theorem DimHom.apply_inv
    {B B' : Type*} [DecidableEq B] [Fintype B] [DecidableEq B'] [Fintype B']
    (f : DimHom B B') (d : dimension B ℤ) :
    f.apply d⁻¹ = (f.apply d)⁻¹ :=
  f.hom.map_inv d

/-- A DimHom preserves division. -/
theorem DimHom.apply_div
    {B B' : Type*} [DecidableEq B] [Fintype B] [DecidableEq B'] [Fintype B']
    (f : DimHom B B') (d₁ d₂ : dimension B ℤ) :
    f.apply (d₁ / d₂) = f.apply d₁ / f.apply d₂ :=
  f.hom.map_div d₁ d₂

-- ── A.5  Lifting convertISQToExtended to DimHom ───────────────────────────────

/-- The ISQ → InformationExtended conversion as a proper `DimHom`.
    This is the categorical packaging of `convertISQToExtended`, using the
    already-proved homomorphism property `convertISQToExtended_mul`. -/
def dimHom_ISQ_to_Ext : DimHom ISQ InformationExtendedBase where
  hom :=
    { toFun   := convertISQToExtended
      map_one' := by
        funext b; fin_cases b <;>
          simp [convertISQToExtended, dimension.one_eq_dimensionless,
                dimension.dimensionless_def', Function.const_apply]
      map_mul' := convertISQToExtended_mul }

/-- The extension hom maps ISQ time to `dim_time_ext`. -/
theorem dimHom_ISQ_to_Ext_time :
    dimHom_ISQ_to_Ext.apply (dimension.time ISQ ℤ) = dim_time_ext :=
  convertISQToExtended_time

/-- The extension hom maps ISQ mass to `dim_mass_ext`. -/
theorem dimHom_ISQ_to_Ext_mass :
    dimHom_ISQ_to_Ext.apply (dimension.mass ISQ ℤ) = dim_mass_ext :=
  convertISQToExtended_mass

/-- The extension hom maps ISQ length to `dim_length_ext` (= dim_time_ext, c=1). -/
theorem dimHom_ISQ_to_Ext_length :
    dimHom_ISQ_to_Ext.apply (dimension.length ISQ ℤ) = dim_length_ext :=
  convertISQToExtended_length

/-- ISQ energy [M·L²·T⁻²] maps to `dim_mass_ext` in the extended basis.
    Note: in natural units E = Mc² = M (c=1), so ISQ energy ↦ dim_mass_ext, not
    dim_energy_ext.  This is the documented Mathematica inconsistency. -/
theorem dimHom_ISQ_to_Ext_energy :
    dimHom_ISQ_to_Ext.apply (dimension.energy ISQ ℤ) = dim_mass_ext :=
  convertISQToExtended_energy_eq_mass_ext

-- ============================================================================
-- Part B: Theory-level unit declarations and physical scale
-- ============================================================================

-- ── B.1  Physical scales ──────────────────────────────────────────────────────

/-- Named physical scales at which a theory may operate.
    Each scale corresponds to a distinct choice of natural units. -/
inductive PhysicalScale
  /-- Planck scale: ħ = c = G = k_B = 1.  All dimensions reduce to [I]. -/
  | planck
  /-- Quantum / atomic scale: ħ = k_B = 1.  Action and entropy are [I]. -/
  | quantum
  /-- Particle-physics natural units: ħ = c = 1.  Mass ≃ energy ≃ [I·T⁻¹]. -/
  | natural
  /-- SI scale: no constant set to 1.  Full 7-base ISQ system. -/
  | si
  /-- Information-theoretic scale: k_B = ħ = 1.  The CAT/EPT choice. -/
  | information
  /-- Plugin-defined custom scale. -/
  | custom (name : String)
  deriving Repr

/-- The CAT/EPT default scale is `information` (k_B = ħ = 1). -/
def cateptDefaultScale : PhysicalScale := .information

-- ── B.2  Natural unit choices ─────────────────────────────────────────────────

/-- A natural unit choice for base set B: declares which base dimensions are
    set to 1 (dimensionless) in the theory's unit system.

    Setting dimension `b` to 1 means quantities with exponent `b` are
    treated as pure numbers in the theory.  The `dimensionlessDims` list
    is a declaration, not a proof — consistency is the plugin's obligation. -/
structure NaturalUnitChoice (B : Type*) [DecidableEq B] [Fintype B] where
  /-- Base dimensions declared dimensionless (set to 1). -/
  dimensionlessDims : List B
  /-- The scale at which this choice applies. -/
  scale : PhysicalScale

/-- Standard information-theoretic units: no base dimension of
    `InformationExtendedBase` is collapsed — the algebraic identities
    [action]=[I], [ħ]=[I] already encode k_B = ħ = 1 as proved equalities. -/
def informationNaturalUnits : NaturalUnitChoice InformationExtendedBase :=
  { dimensionlessDims := []
    scale := .information }

/-- Planck-scale units: all four InformationExtended base dimensions
    collapse to dimensionless (ħ = c = G = k_B = 1). -/
def planckNaturalUnits : NaturalUnitChoice InformationExtendedBase :=
  { dimensionlessDims := [.information, .time, .charge, .temperature]
    scale := .planck }

/-- SI units: no InformationExtended dim is collapsed. -/
def siNaturalUnits : NaturalUnitChoice InformationExtendedBase :=
  { dimensionlessDims := []
    scale := .si }

-- ── B.3  Basis-expressed quantity dimensions ──────────────────────────────────

/-- The canonical dimensions of key physical quantities *expressed in basis B*.
    A `TheoryBasisDimensions B` records how action, ħ, energy, time, and entropy
    are typed in the plugin's working basis before translating to the [I]-basis. -/
structure TheoryBasisDimensions (B : Type*) [DecidableEq B] [Fintype B] where
  actionDimInB  : dimension B ℤ
  hbarDimInB    : dimension B ℤ
  energyDimInB  : dimension B ℤ
  timeDimInB    : dimension B ℤ
  entropyDimInB : dimension B ℤ

/-- Canonical basis dimensions for `InformationExtendedBase`:
    action = dim_action_ext = dim_information, etc. -/
def informationBasisDimensions : TheoryBasisDimensions InformationExtendedBase :=
  { actionDimInB  := dim_action_ext
    hbarDimInB    := dim_hbar_ext
    energyDimInB  := dim_energy_ext
    timeDimInB    := dim_time_ext
    entropyDimInB := dim_entropy_ext }

/-- ISQ basis dimensions: action = M·L²·T⁻¹ (Joule·second), etc. -/
def isqBasisDimensions : TheoryBasisDimensions ISQ :=
  { actionDimInB  := dimension.mass ISQ ℤ * dimension.length ISQ ℤ ^ (2 : ℤ) *
                     (dimension.time ISQ ℤ)⁻¹
    hbarDimInB    := dimension.mass ISQ ℤ * dimension.length ISQ ℤ ^ (2 : ℤ) *
                     (dimension.time ISQ ℤ)⁻¹
    energyDimInB  := dimension.energy ISQ ℤ
    timeDimInB    := dimension.time ISQ ℤ
    entropyDimInB := dimension.mass ISQ ℤ * dimension.length ISQ ℤ ^ (2 : ℤ) *
                     (dimension.time ISQ ℤ)⁻¹ * (dimension.temperature ISQ ℤ)⁻¹ }

-- ── B.4  Theory unit context ──────────────────────────────────────────────────

/-- Unit context for a plugin: declares the physical scale, the natural unit
    choice, the key dimensions expressed in the plugin's working basis B, and a
    `DimHom` that translates B-basis dimensions to the global [I]-basis.

    The `toBasis` hom acts as the dimensional bridge:
    `toBasis.apply (basisDims.actionDimInB) = dim_information` for any
    consistent context. -/
structure TheoryUnitContext (plugin : TheoryPlugin)
    (B : Type*) [DecidableEq B] [Fintype B] where
  /-- The physical scale this theory operates at. -/
  scale      : PhysicalScale
  /-- The natural unit choice for this theory's basis. -/
  unitChoice : NaturalUnitChoice B
  /-- Key quantity dimensions expressed in the working basis B. -/
  basisDims  : TheoryBasisDimensions B
  /-- The dimension hom from the working basis to the global [I]-basis. -/
  toBasis    : DimHom B InformationExtendedBase

/-- Build a `PluginDimCore` from a `TheoryUnitContext` by translating each
    declared B-basis dimension through the `toBasis` hom. -/
def TheoryUnitContext.toPluginDimCore
    {plugin : TheoryPlugin}
    {B : Type*} [DecidableEq B] [Fintype B]
    (ctx : TheoryUnitContext plugin B) :
    PluginDimCore plugin where
  actionDim  := ctx.toBasis.apply ctx.basisDims.actionDimInB
  hbarDim    := ctx.toBasis.apply ctx.basisDims.hbarDimInB
  energyDim  := ctx.toBasis.apply ctx.basisDims.energyDimInB
  timeDim    := ctx.toBasis.apply ctx.basisDims.timeDimInB
  entropyDim := ctx.toBasis.apply ctx.basisDims.entropyDimInB

-- ── B.5  Canonical information-theoretic context ──────────────────────────────

/-- The canonical information-theoretic unit context for CAT/EPT plugins:
    working basis = InformationExtended, toBasis = identity hom. -/
def canonicalInfoUnitContext (plugin : TheoryPlugin) :
    TheoryUnitContext plugin InformationExtendedBase where
  scale      := .information
  unitChoice := informationNaturalUnits
  basisDims  := informationBasisDimensions
  toBasis    := DimHom.id InformationExtendedBase

/-- The canonical context's `toPluginDimCore` equals `canonicalPluginDimCore`. -/
theorem canonicalInfoUnitContext_core_eq (plugin : TheoryPlugin) :
    (canonicalInfoUnitContext plugin).toPluginDimCore =
      canonicalPluginDimCore plugin := by
  simp only [TheoryUnitContext.toPluginDimCore, canonicalInfoUnitContext,
             informationBasisDimensions, DimHom.apply, DimHom.id,
             MonoidHom.id_apply, canonicalPluginDimCore]
  -- actionDim: dim_action_ext = dim_information
  -- hbarDim: dim_hbar_ext = dim_information
  -- entropyDim: dim_entropy_ext = dim_information
  simp only [dim_action_eq_information, dim_hbar_eq_information, dim_entropy_eq_information]

/-- The core induced by the canonical info context satisfies all minimal-core axioms. -/
def canonicalInfoUnitContext_axioms (plugin : TheoryPlugin) :
    PluginDimCoreAxioms plugin
      ((canonicalInfoUnitContext plugin).toPluginDimCore) := by
  rw [canonicalInfoUnitContext_core_eq]
  exact canonicalCoreAxioms plugin

-- ── B.6  ISQ unit context ─────────────────────────────────────────────────────

/-- The ISQ-based unit context: plugin works in SI units, `toBasis` is
    `dimHom_ISQ_to_Ext`. -/
noncomputable def isqUnitContext (plugin : TheoryPlugin) :
    TheoryUnitContext plugin ISQ where
  scale      := .si
  unitChoice := { dimensionlessDims := [], scale := .si }
  basisDims  := isqBasisDimensions
  toBasis    := dimHom_ISQ_to_Ext

-- ── B.7  Scale-change morphism ────────────────────────────────────────────────

/-- A scale change between two unit contexts for the same plugin: a `DimHom`
    between the working bases that is compatible with both `toBasis` maps.
    Compatibility: `ctx₂.toBasis ∘ hom = ctx₁.toBasis` (triangle condition). -/
structure ScaleChange
    (plugin : TheoryPlugin)
    {B₁ B₂ : Type*}
    [DecidableEq B₁] [Fintype B₁]
    [DecidableEq B₂] [Fintype B₂]
    (ctx₁ : TheoryUnitContext plugin B₁)
    (ctx₂ : TheoryUnitContext plugin B₂) where
  /-- The hom converting between the two working bases. -/
  hom      : DimHom B₁ B₂
  /-- Triangle: converting then projecting = projecting directly. -/
  triangle : ∀ d : dimension B₁ ℤ,
      ctx₂.toBasis.apply (hom.apply d) = ctx₁.toBasis.apply d

/-- The identity scale change from a context to itself. -/
def ScaleChange.refl
    (plugin : TheoryPlugin)
    {B : Type*} [DecidableEq B] [Fintype B]
    (ctx : TheoryUnitContext plugin B) :
    ScaleChange plugin ctx ctx where
  hom      := DimHom.id B
  triangle := fun _ => rfl

/-- Scale changes compose: if B₁ → B₂ and B₂ → B₃ are compatible,
    so is the composite B₁ → B₃. -/
def ScaleChange.trans
    (plugin : TheoryPlugin)
    {B₁ B₂ B₃ : Type*}
    [DecidableEq B₁] [Fintype B₁]
    [DecidableEq B₂] [Fintype B₂]
    [DecidableEq B₃] [Fintype B₃]
    {ctx₁ : TheoryUnitContext plugin B₁}
    {ctx₂ : TheoryUnitContext plugin B₂}
    {ctx₃ : TheoryUnitContext plugin B₃}
    (f : ScaleChange plugin ctx₁ ctx₂)
    (g : ScaleChange plugin ctx₂ ctx₃) :
    ScaleChange plugin ctx₁ ctx₃ where
  hom      := DimHom.comp g.hom f.hom
  triangle := fun d => by
    show ctx₃.toBasis.apply (g.hom.apply (f.hom.apply d)) = ctx₁.toBasis.apply d
    rw [g.triangle, f.triangle]

-- ── B.8  Full profile with unit context ──────────────────────────────────────

/-- Extended dim profile: bundles a unit context with the induced core and
    its automatically-derived dimensional facts. -/
structure PluginDimProfileWithContext (plugin : TheoryPlugin)
    {B : Type*} [DecidableEq B] [Fintype B] where
  /-- The unit context (scale + natural units + basis hom). -/
  ctx      : TheoryUnitContext plugin B
  /-- Consistency axioms for the induced core. -/
  axioms   : PluginDimCoreAxioms plugin ctx.toPluginDimCore
  /-- Auto-derived facts (filled by `derivePluginDimFacts`). -/
  derived  : PluginDimDerivedFacts ctx.toPluginDimCore axioms :=
               derivePluginDimFacts ctx.toPluginDimCore axioms

/-- The canonical information-context profile satisfies all axioms via
    `canonicalInfoUnitContext_axioms`. -/
def canonicalInfoContextProfile (plugin : TheoryPlugin) :
    PluginDimProfileWithContext (B := InformationExtendedBase) plugin where
  ctx    := canonicalInfoUnitContext plugin
  axioms := canonicalInfoUnitContext_axioms plugin

end CATEPTMain.Integration
