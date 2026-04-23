import Mathlib

/-!
# Batch 20260408 Theoremization - Global Row 102

DSF category/functor scaffold extracted from
`0078_implementation_for_dsfcategory.lean.lean`.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.G102

structure DSFProjectModule where
  filename : String
  role : String
  definitions : List String
  dependencies : List String
  readyFor : List String
  deriving DecidableEq, Repr

structure DSFCategoryObject where
  module : DSFProjectModule
  morphisms : List (DSFProjectModule → DSFProjectModule)

def applyAllMorphisms (obj : DSFCategoryObject) (target : DSFProjectModule) :
    List DSFProjectModule :=
  obj.morphisms.map (fun f => f target)

theorem applyAllMorphisms_length (obj : DSFCategoryObject) (target : DSFProjectModule) :
    (applyAllMorphisms obj target).length = obj.morphisms.length := by
  unfold applyAllMorphisms
  simp

def hasMorphismTo (source target : DSFCategoryObject) : Bool :=
  source.morphisms.any (fun f =>
    target.module.filename = (f source.module).filename
      || target.module.dependencies.contains source.module.filename)

def getMorphismsTo (source target : DSFCategoryObject) :
    List (DSFProjectModule → DSFProjectModule) :=
  source.morphisms.filter (fun f =>
    target.module.filename = (f source.module).filename
      || target.module.dependencies.contains source.module.filename)

structure DSFCategory where
  objects : List DSFCategoryObject
  edges : List (DSFCategoryObject × DSFCategoryObject)

def findDependents (cat : DSFCategory) (obj : DSFCategoryObject) : List DSFCategoryObject :=
  cat.objects.filter (fun o => o.module.dependencies.contains obj.module.filename)

def findDependencies (cat : DSFCategory) (obj : DSFCategoryObject) : List DSFCategoryObject :=
  cat.objects.filter (fun o => obj.module.dependencies.contains o.module.filename)

theorem findDependencies_contains_self
    (cat : DSFCategory) (obj : DSFCategoryObject)
    (hobj : obj ∈ cat.objects)
    (hdep : obj.module.dependencies.contains obj.module.filename = true) :
    obj ∈ findDependencies cat obj := by
  unfold findDependencies
  exact List.mem_filter.mpr ⟨hobj, hdep⟩

def mapMorphismPair (F : DSFCategoryObject → DSFCategoryObject)
    (morphism : DSFCategoryObject × DSFCategoryObject) :
    DSFCategoryObject × DSFCategoryObject :=
  (F morphism.1, F morphism.2)

theorem mapMorphismPair_fst (F : DSFCategoryObject → DSFCategoryObject)
    (morphism : DSFCategoryObject × DSFCategoryObject) :
    (mapMorphismPair F morphism).1 = F morphism.1 := rfl

theorem mapMorphismPair_snd (F : DSFCategoryObject → DSFCategoryObject)
    (morphism : DSFCategoryObject × DSFCategoryObject) :
    (mapMorphismPair F morphism).2 = F morphism.2 := rfl

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.G102
