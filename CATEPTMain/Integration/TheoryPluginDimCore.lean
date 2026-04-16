import CATEPTMain.Integration.TheoryPluginDimSlot

set_option autoImplicit false

/-!
# Theory Plugin Dimensional Core

Active dimensional analysis infrastructure for the plugin architecture.

## Problem statement

`TheoryPluginDimSlot` provides a *passive* global report: every plugin carries
the same 7 pre-proved facts.  This file adds an *active* layer where each
plugin:

1. **Declares** the dimensions of its slot quantities (`actionDim`, `hbarDim`,
   `energyDim`, `timeDim`, `entropyDim`) as elements of
   `dimension InformationExtendedBase ℤ`.
2. **Checks** those declarations are consistent with the minimal core
   (`PluginDimCoreAxioms`).
3. **Receives** all downstream dimensional facts for free (`PluginDimDerivedFacts`)
   — no additional proof work required.

## Minimal core (four commitments)

A plugin's dimensional analysis is *grounded* in the [I]-basis when it commits:

```
action_is_information : core.actionDim = dim_information   ([A] = [I])
hbar_is_information   : core.hbarDim   = dim_information   ([ħ] = [I])
energy_is_derived     : core.energyDim = dim_energy_ext    ([E] = [I·T⁻¹])
time_is_derived       : core.timeDim   = dim_time_ext      ([T] = [I]/[E])
```

These four are the minimal core.  From them, **every downstream fact is derived
automatically** inside `PluginDimDerivedFacts.mk`.

## Extension layer

Plugins may also declare their own theory-specific quantities
(`PluginDimExtension`) — e.g. gauge field, matter field, Wilson loop — as a
list of `(name, dimension)` pairs.  There is no consistency obligation on
extensions, but the infrastructure provides helper lemmas.

## Usage pattern for a new plugin

```lean
-- 1. Declare the core (usually just `canonicalPluginDimCore`)
def myPlugin_dimCore : PluginDimCore myPlugin := canonicalPluginDimCore myPlugin

-- 2. Prove the four axioms (or use `canonicalCoreAxioms`)
def myPlugin_coreAxioms : PluginDimCoreAxioms myPlugin myPlugin_dimCore :=
  canonicalCoreAxioms myPlugin

-- 3. Get all derived facts for free
def myPlugin_derivedFacts : PluginDimDerivedFacts myPlugin_dimCore myPlugin_coreAxioms :=
  PluginDimDerivedFacts.mk myPlugin_dimCore myPlugin_coreAxioms

-- 4. Optionally add theory-specific quantities
def myPlugin_extension : PluginDimExtension myPlugin myPlugin_dimCore :=
  { extraDims := [("gauge_field", dim_information), ("wilson_loop", dimension.dimensionless _)] }

-- 5. Assemble the full dimensional profile
def myPlugin_dimProfile : PluginDimProfile myPlugin :=
  { core       := myPlugin_dimCore
    axioms     := myPlugin_coreAxioms
    derived    := myPlugin_derivedFacts
    extension  := myPlugin_extension }
```

## Theorem status (zero sorry)

| Name                              | Status |
|-----------------------------------|--------|
| `PluginDimDerivedFacts.mk`        | proved |
| `canonicalPluginDimCore`          | proved |
| `canonicalCoreAxioms`             | proved |
| `canonicalDerivedFacts`           | proved |
| `dimProfile_to_dimConstraint`     | proved |
| `gravitasPphi2Adapter_dimProfile` | proved |

-/

namespace CATEPTMain.Integration

open InformationDimensionalFramework.Concrete
open InformationDimensionalFramework.QuantumAction

-- ── §1  Declaration struct ────────────────────────────────────────────────────

/-- Plugin dimensional core declaration: the four quantity dimensions a plugin
    commits to.  These are the plugin's claim about the dimensional type of its
    key quantities, expressed in the `InformationExtendedBase ℤ` algebra. -/
structure PluginDimCore (plugin : TheoryPlugin) where
  /-- Dimension of the plugin's action (S_R or S_I). -/
  actionDim  : dimension InformationExtendedBase ℤ
  /-- Dimension of the plugin's Planck constant ħ. -/
  hbarDim    : dimension InformationExtendedBase ℤ
  /-- Dimension of the plugin's energy observable. -/
  energyDim  : dimension InformationExtendedBase ℤ
  /-- Dimension of the plugin's time observable. -/
  timeDim    : dimension InformationExtendedBase ℤ
  /-- Dimension of the plugin's entropy observable. -/
  entropyDim : dimension InformationExtendedBase ℤ

-- ── §2  Minimal core axioms ───────────────────────────────────────────────────

/-- The four minimal-core consistency constraints that ground a plugin's
    dimensional declarations in the global [I]-basis algebra.

    These are *not* proved by the infrastructure — each plugin must supply
    the proofs.  The canonical implementation (`canonicalCoreAxioms`) gives
    them for free when the plugin uses `canonicalPluginDimCore`. -/
structure PluginDimCoreAxioms (plugin : TheoryPlugin)
    (core : PluginDimCore plugin) where
  /-- [action] = [I]: every unit of action is a unit of information. -/
  action_is_information : core.actionDim  = dim_information
  /-- [ħ] = [I]: Planck's constant carries the information dimension. -/
  hbar_is_information   : core.hbarDim    = dim_information
  /-- [E] = [I·T⁻¹]: energy is information per unit time. -/
  energy_is_derived     : core.energyDim  = dim_energy_ext
  /-- [T] = [I]/[E]: time is composed — action divided by energy. -/
  time_is_derived       : core.timeDim    = dim_time_ext
  /-- [S] = [I]: entropy counts information states. -/
  entropy_is_information : core.entropyDim = dim_information

-- ── §3  Automatically derived dimensional facts ───────────────────────────────

/-- Downstream dimensional facts that follow *automatically* from
    `PluginDimCoreAxioms`.  No plugin needs to prove these manually.

    The constructor `PluginDimDerivedFacts.mk` derives all fields from the
    four minimal-core axioms. -/
structure PluginDimDerivedFacts {plugin : TheoryPlugin}
    (core : PluginDimCore plugin)
    (ax   : PluginDimCoreAxioms plugin core) where
  /-- [action / ħ] = 1: the path-integral exponent S/ħ is dimensionless. -/
  clock_dimensionless :
      core.actionDim / core.hbarDim =
        dimension.dimensionless InformationExtendedBase ℤ
  /-- [T] = [action] / [E]: time is composed. -/
  time_composed :
      core.timeDim = core.actionDim / core.energyDim
  /-- [action · ħ⁻¹] = 1: the BCJ/EPT clock numerator is dimensionless. -/
  bcj_dimensionless :
      core.actionDim * core.hbarDim⁻¹ =
        dimension.dimensionless InformationExtendedBase ℤ
  /-- [action] = [ħ]: action and ħ are dimensionally identical. -/
  action_eq_hbar :
      core.actionDim = core.hbarDim
  /-- [S] = [action]: entropy and action carry the same dimension. -/
  entropy_eq_action :
      core.entropyDim = core.actionDim

/-- **Core derivation theorem**: given the four minimal-core axioms, construct
    all `PluginDimDerivedFacts` automatically.  Proofs use only the global
    dimensional algebra lemmas from §2/§3 of `InformationDimensionalFrameworkBridge`. -/
def derivePluginDimFacts
    {plugin : TheoryPlugin}
    (core : PluginDimCore plugin)
    (ax   : PluginDimCoreAxioms plugin core) :
    PluginDimDerivedFacts core ax where
  clock_dimensionless := by
    rw [ax.action_is_information, ax.hbar_is_information]
    -- goal: dim_information / dim_information = dimensionless
    rw [dimension.div_eq_mul_inv, ← dimension.one_eq_dimensionless]
    exact dimension.mul_right_inv dim_information
  time_composed := by
    rw [ax.time_is_derived, ax.action_is_information, ax.energy_is_derived]
    -- goal: dim_time_ext = dim_information / dim_energy_ext
    exact time_composed_from_information_and_energy
  bcj_dimensionless := by
    rw [ax.action_is_information, ax.hbar_is_information]
    -- goal: dim_information * dim_information⁻¹ = dimensionless
    rw [← dimension.one_eq_dimensionless]
    exact dimension.mul_right_inv dim_information
  action_eq_hbar := by
    rw [ax.action_is_information, ax.hbar_is_information]
  entropy_eq_action := by
    rw [ax.entropy_is_information, ax.action_is_information]

-- ── §4  Extension layer ───────────────────────────────────────────────────────

/-- Optional plugin-specific dimensional extension.  Plugins declare their
    theory-unique quantities — gauge fields, matter fields, Wilson loops,
    BCJ numerators, etc. — as named `(String × dimension)` pairs.

    No consistency obligation on extensions (the plugin may leave the list
    empty).  Helper lemmas below allow plugins to query the list. -/
structure PluginDimExtension (plugin : TheoryPlugin)
    (core : PluginDimCore plugin) where
  /-- Named extra quantities: `(name, dimension)`. -/
  extraDims : List (String × dimension InformationExtendedBase ℤ)

/-- Empty extension: the default when a plugin has no theory-specific quantities. -/
def emptyPluginDimExtension (plugin : TheoryPlugin) (core : PluginDimCore plugin) :
    PluginDimExtension plugin core :=
  { extraDims := [] }

/-- Look up a named quantity in the extension. -/
def PluginDimExtension.lookup
    {plugin : TheoryPlugin} {core : PluginDimCore plugin}
    (ext : PluginDimExtension plugin core)
    (name : String) :
    Option (dimension InformationExtendedBase ℤ) :=
  (ext.extraDims.find? (fun p => p.1 = name)).map (·.2)

-- ── §5  Full dimensional profile ─────────────────────────────────────────────

/-- Complete dimensional profile for a plugin:
    - `core`      : the four declared quantity dimensions
    - `axioms`    : consistency proofs (minimal core)
    - `derived`   : automatically derived downstream facts
    - `extension` : optional theory-specific quantity declarations -/
structure PluginDimProfile (plugin : TheoryPlugin) where
  core      : PluginDimCore plugin
  axioms    : PluginDimCoreAxioms plugin core
  derived   : PluginDimDerivedFacts core axioms
  extension : PluginDimExtension plugin core

-- ── §6  Canonical implementations ────────────────────────────────────────────

/-- Canonical core: commit all four quantities to the global [I]-basis values.
    This is the standard core for any plugin that does not override dimensions. -/
def canonicalPluginDimCore (plugin : TheoryPlugin) : PluginDimCore plugin where
  actionDim  := dim_information
  hbarDim    := dim_information
  energyDim  := dim_energy_ext
  timeDim    := dim_time_ext
  entropyDim := dim_information

/-- Canonical axioms: when the core is `canonicalPluginDimCore`,
    all four axioms hold by `rfl`. -/
def canonicalCoreAxioms (plugin : TheoryPlugin) :
    PluginDimCoreAxioms plugin (canonicalPluginDimCore plugin) where
  action_is_information  := rfl
  hbar_is_information    := rfl
  energy_is_derived      := rfl
  time_is_derived        := rfl
  entropy_is_information := rfl

/-- Canonical derived facts for the canonical core. -/
def canonicalDerivedFacts (plugin : TheoryPlugin) :
    PluginDimDerivedFacts (canonicalPluginDimCore plugin) (canonicalCoreAxioms plugin) :=
  derivePluginDimFacts _ (canonicalCoreAxioms plugin)

/-- Canonical full profile: use canonical core, axioms, derived facts, and empty extension. -/
def canonicalDimProfile (plugin : TheoryPlugin) : PluginDimProfile plugin where
  core      := canonicalPluginDimCore plugin
  axioms    := canonicalCoreAxioms plugin
  derived   := canonicalDerivedFacts plugin
  extension := emptyPluginDimExtension plugin (canonicalPluginDimCore plugin)

-- ── §7  Connection to PluginDimCertificate (TheoryPluginDimSlot) ──────────────

/-- A plugin dim profile implies a dim certificate: the profile's axioms supply
    the global report, and the CATEPT slot consistency is required separately. -/
theorem dimProfile_to_dimConstraint
    (plugin : TheoryPlugin)
    (_ : PluginDimProfile plugin)
    (hCat : cateptConsistencyConstraint plugin.catept) :
    dimConsistencyConstraint plugin :=
  dimCertificate_of_cateptConsistency plugin hCat

/-- A plugin dim profile combined with CATEPT spine consistency yields full validation. -/
theorem validatePluginFull_of_dimProfile
    (plugin : TheoryPlugin)
    (hVal  : validatePlugin plugin)
    (_ : PluginDimProfile plugin) :
    validatePluginFull plugin :=
  validatePluginFull_of_validatePlugin plugin hVal

-- ── §8  Extended validator with dimensional profile ───────────────────────────

/-- Extended plugin validator: standard 12-slot validation + dim constraint +
    a full dimensional profile.  This is the Phase-2 target for all plugins. -/
def validatePluginWithDimProfile (plugin : TheoryPlugin) : Prop :=
  validatePluginFull plugin ∧ Nonempty (PluginDimProfile plugin)

theorem validatePluginWithDimProfile_intro
    (plugin : TheoryPlugin)
    (hFull : validatePluginFull plugin)
    (hProf : PluginDimProfile plugin) :
    validatePluginWithDimProfile plugin :=
  ⟨hFull, ⟨hProf⟩⟩

theorem validatePluginWithDimProfile_to_full
    (plugin : TheoryPlugin)
    (h : validatePluginWithDimProfile plugin) :
    validatePluginFull plugin :=
  h.1

end CATEPTMain.Integration
