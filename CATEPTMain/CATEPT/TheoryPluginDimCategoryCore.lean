import CATEPTMain.CATEPT.UnitsDimensionalAnalysis

set_option autoImplicit false

namespace CATEPTMain.CATEPT

/-- Named physical scales for plugin unit policies. -/
inductive PhysicalScale
  | planck
  | quantum
  | natural
  | information
  | si
  | custom (name : String)
  deriving Repr, DecidableEq

/-- Multiplicative homomorphism on the CAT/EPT `Dimension` algebra. -/
structure DimHom where
  toFun : Dimension -> Dimension
  map_one : toFun Dimension.one = Dimension.one
  map_mul : forall a b : Dimension,
    toFun (Dimension.mul a b) = Dimension.mul (toFun a) (toFun b)

instance : CoeFun DimHom (fun _ => Dimension -> Dimension) where
  coe f := f.toFun

/-- Identity dimensional homomorphism. -/
def DimHom.id : DimHom where
  toFun := fun d => d
  map_one := rfl
  map_mul := by intro a b; rfl

/-- Composition of dimensional homomorphisms. -/
def DimHom.comp (g f : DimHom) : DimHom where
  toFun := fun d => g (f d)
  map_one := by
    simpa [f.map_one] using g.map_one
  map_mul := by
    intro a b
    simp [f.map_mul, g.map_mul]

theorem DimHom.id_apply (d : Dimension) : DimHom.id d = d := rfl

theorem DimHom.comp_apply (g f : DimHom) (d : Dimension) :
    DimHom.comp g f d = g (f d) := rfl

theorem DimHom.id_comp_apply (f : DimHom) (d : Dimension) :
    DimHom.comp DimHom.id f d = f d := rfl

theorem DimHom.comp_id_apply (f : DimHom) (d : Dimension) :
    DimHom.comp f DimHom.id d = f d := rfl

theorem DimHom.assoc_apply (h g f : DimHom) (d : Dimension) :
    DimHom.comp h (DimHom.comp g f) d =
      DimHom.comp (DimHom.comp h g) f d := rfl

/-- Core unit declarations for a plugin lane at a selected physical scale. -/
structure NaturalUnitChoice where
  scale : PhysicalScale
  actionDimension : Dimension
  hbarDimension : Dimension
  energyDimension : Dimension
  timeDimension : Dimension
  entropyDimension : Dimension

/-- Canonical CAT/EPT unit policy in the information scale. -/
def informationNaturalUnits : NaturalUnitChoice where
  scale := .information
  actionDimension := dimAction
  hbarDimension := dimHbar
  energyDimension := dimEnergy
  timeDimension := dimTime
  entropyDimension := dimAction

theorem informationNaturalUnits_action_eq_hbar :
    informationNaturalUnits.actionDimension =
      informationNaturalUnits.hbarDimension := by
  rfl

theorem informationNaturalUnits_entropic_clock_dimensionless :
    Dimension.div informationNaturalUnits.actionDimension
      informationNaturalUnits.hbarDimension = Dimension.one := by
  simpa [informationNaturalUnits, dimEntropicTime]
    using dim_entropic_time_dimensionless

/-- Unit context with a declared scale and a map into the core dimension algebra. -/
structure TheoryUnitContext where
  units : NaturalUnitChoice
  toCore : DimHom

/-- Map declared action dimension through the context homomorphism. -/
def TheoryUnitContext.mapAction (ctx : TheoryUnitContext) : Dimension :=
  ctx.toCore ctx.units.actionDimension

/-- Map declared ħ dimension through the context homomorphism. -/
def TheoryUnitContext.mapHbar (ctx : TheoryUnitContext) : Dimension :=
  ctx.toCore ctx.units.hbarDimension

/-- Canonical context: information units with identity mapping. -/
def canonicalInfoUnitContext : TheoryUnitContext where
  units := informationNaturalUnits
  toCore := DimHom.id

theorem canonicalInfoUnitContext_mapAction :
    canonicalInfoUnitContext.mapAction = dimAction := rfl

theorem canonicalInfoUnitContext_mapHbar :
    canonicalInfoUnitContext.mapHbar = dimHbar := rfl

theorem canonicalInfoUnitContext_action_eq_hbar :
    canonicalInfoUnitContext.mapAction = canonicalInfoUnitContext.mapHbar := by
  rfl

theorem canonicalInfoUnitContext_clock_dimensionless :
    Dimension.div canonicalInfoUnitContext.mapAction
      canonicalInfoUnitContext.mapHbar = Dimension.one := by
  simpa [TheoryUnitContext.mapAction, TheoryUnitContext.mapHbar,
    canonicalInfoUnitContext, informationNaturalUnits, dimEntropicTime]
    using dim_entropic_time_dimensionless

end CATEPTMain.CATEPT
