import Mathlib.MeasureTheory.Integral.IntervalIntegral.Periodic
import Mathlib.MeasureTheory.Constructions.Pi
import Mathlib.MeasureTheory.Measure.Haar.InnerProductSpace
import Mathlib.Analysis.Fourier.AddCircleMulti
import NavierStokesClean.Core.SpatialTypes
import NavierStokesClean.Sobolev.PeriodicSobolev

/-!
# Torus Bridge: UnitAddTorus (Fin 3) ↔ Space under Haar measure

This file constructs the measure-theoretic bridge between
  - `Space = PhysLean.Space 3` (3D Euclidean space) with Lebesgue/Haar measure
  - `UnitAddTorus (Fin 3) = Fin 3 → AddCircle (1:ℝ)` with product Haar measure

The bridge is the standard periodization correspondence: the quotient map
`ℝ³ → T³` restricted to the fundamental domain `Ioc 0 1 × Ioc 0 1 × Ioc 0 1`
is measure-preserving (Haar on T³ = Lebesgue on [0,1]³).

## Main results

### §1. Product measure-preserving equivalence (UnitAddTorus ↔ [0,1]^n)

`measurePreserving_unitAddTorus_equivIoc`: The componentwise application of
`AddCircle.measurableEquivIoc 1 0` to `UnitAddTorus (Fin n)` is measure-preserving
from product Haar on `UnitAddTorus (Fin n)` to product Lebesgue on `Fin n → Ioc 0 (0+1)`.

### §2. Integral bridge

`UnitAddTorus.integral_preimage_pi`: For `f : UnitAddTorus (Fin n) → E`:
  `∫ t, f t = ∫ x : Fin n → Ioc 0 (0+1), f (equivIoc.symm x) ∂piIoc`

`UnitAddTorus.lintegral_preimage_pi`: Lower-integral version.

### §3. Space ↔ CATEPTSpace ↔ UnitAddTorus (Fin 3) chain (NSC-P39 scaffolding)

The two-hop chain:
  `Space →(Space.equivPi)→ CATEPTSpace = Fin 3 → ℝ →(periodization)→ UnitAddTorus (Fin 3)`

`space_torus_bridge_zero_witness`: Zero-enstrophy witness for `space_torus_vorticity_bridge`.

## Notes on measure instances

`UnitAddTorus (Fin n) = Fin n → AddCircle (1:ℝ)` with the product topology carries
the product measure `Measure.pi (fun _ => AddCircle.haarAddCircle)`. This is a
probability measure (total mass 1). The Mathlib file `AddCircleMulti.lean` uses a
`local instance` for `MeasureSpace UnitAddCircle` set to `AddCircle.haarAddCircle`.
We follow the same convention here.
-/

set_option autoImplicit false

-- `AddCircle.measureSpace (T : ℝ) [Fact (0 < T)] : MeasureSpace (AddCircle T)` is a
-- global noncomputable instance in Mathlib.MeasureTheory.Integral.IntervalIntegral.Periodic.
-- It gives `volume (AddCircle T) = AddCircle.haarAddCircle`.
-- We do NOT redeclare a local instance here: the global one is correct and matches
-- what `AddCircle.measurePreserving_equivIoc` expects.
-- Needed for AddCircle.measureSpace 1 and AddCircle.measurePreserving_equivIoc (T = 1)
private noncomputable instance factPeriodOne : Fact (0 < (1 : ℝ)) := ⟨one_pos⟩

namespace NavierStokesClean.Sobolev.TorusBridge

open NavierStokesClean MeasureTheory UnitAddTorus
open scoped ENNReal NNReal BigOperators

/-! ## §1. Product measure-preserving equivalence -/

-- The type that `AddCircle.measurableEquivIoc 1 0` produces:
-- `AddCircle 1 ≃ᵐ Set.Ioc 0 (0 + 1)`.
-- We use `Set.Ioc 0 (0 + 1)` throughout to match.

/-- The componentwise application of `AddCircle.measurableEquivIoc 1 0` gives a
`MeasurableEquiv` between `UnitAddTorus (Fin n)` and `Fin n → Set.Ioc 0 (0 + 1)`. -/
noncomputable def unitAddTorusEquivIoc (n : ℕ) :
    UnitAddTorus (Fin n) ≃ᵐ (Fin n → Set.Ioc (0 : ℝ) (0 + 1)) :=
  MeasurableEquiv.piCongrRight (fun _ => AddCircle.measurableEquivIoc 1 0)

-- The target measure: product of comap-Lebesgue on each `Ioc 0 (0+1)` component.
private noncomputable def piIoc (n : ℕ) : Measure (Fin n → Set.Ioc (0 : ℝ) (0 + 1)) :=
  Measure.pi fun _ => Measure.comap Subtype.val (volume : Measure ℝ)

/-- The componentwise `AddCircle.measurableEquivIoc 1 0` is measure-preserving:
maps product Haar on `UnitAddTorus (Fin n)` to `piIoc n`.

**Proof**: `measurePreserving_pi` + `AddCircle.measurePreserving_equivIoc` per component.
SigmaFinite needed for target: comap Lebesgue on Ioc 0 (0+1) is a finite measure
(Lebesgue of [0,1] = 1 < ∞), hence sigma-finite.

**Sorries**: 1 — `SigmaFinite (Measure.comap Subtype.val volume : Measure (Set.Ioc 0 (0+1)))`.
This holds since the interval has finite Lebesgue measure; no instance currently in Mathlib. -/
theorem measurePreserving_unitAddTorus_equivIoc (n : ℕ) :
    MeasurePreserving (unitAddTorusEquivIoc n)
      (volume : Measure (UnitAddTorus (Fin n)))
      (piIoc n) := by
  -- SigmaFinite for target component: comap Lebesgue on Ioc 0 (0+1) has total mass = 1 < ∞.
  haveI hFin : IsFiniteMeasure (Measure.comap Subtype.val (volume : Measure ℝ) :
      Measure (Set.Ioc (0:ℝ) (0+1))) := by
    refine ⟨?_⟩
    have hle : (Measure.comap Subtype.val (volume : Measure ℝ))
          (Set.univ : Set (Set.Ioc (0:ℝ) (0+1))) ≤
        (volume : Measure ℝ) (Subtype.val '' (Set.univ : Set (Set.Ioc (0:ℝ) (0+1)))) :=
      Measure.comap_apply_le Subtype.val (volume : Measure ℝ)
        MeasurableSet.univ.nullMeasurableSet
    have hrange : Subtype.val '' (Set.univ : Set (Set.Ioc (0:ℝ) (0+1))) = Set.Ioc 0 (0+1) := by
      ext x; simp [Set.mem_Ioc]
    calc (Measure.comap Subtype.val (volume : Measure ℝ)) Set.univ
        ≤ (volume : Measure ℝ) (Subtype.val '' Set.univ) := hle
      _ = volume (Set.Ioc (0:ℝ) (0+1)) := by rw [hrange]
      _ = ENNReal.ofReal (0 + 1 - 0) := Real.volume_Ioc
      _ < ⊤ := by norm_num
  haveI hSF : ∀ _ : Fin n, SigmaFinite (Measure.comap Subtype.val (volume : Measure ℝ) :
      Measure (Set.Ioc (0:ℝ) (0+1))) := fun _ => hFin.toSigmaFinite
  -- Restate the goal in the exact form that `measurePreserving_pi` produces.
  -- The three equalities below are all definitional (rfl):
  -- • volume : Measure (UnitAddTorus Fin n) = Measure.pi (fun _ => volume)  [Pi.measureSpace, volume_pi = rfl]
  -- • piIoc n = Measure.pi (fun _ => Measure.comap Subtype.val volume)       [def of piIoc]
  -- • ⇑(unitAddTorusEquivIoc n) = fun a i => equivIoc 1 0 (a i)             [Equiv.piCongrRight]
  -- After `show`, `measurePreserving_pi` applies directly with `hSF` providing SigmaFinite.
  show MeasurePreserving
      (fun (a : Fin n → AddCircle (1:ℝ)) i => (AddCircle.equivIoc (1:ℝ) 0) (a i))
      (Measure.pi (fun _ => (volume : Measure (AddCircle (1:ℝ)))))
      (Measure.pi (fun _ => Measure.comap Subtype.val (volume : Measure ℝ)))
  exact measurePreserving_pi
      (fun _ => (volume : Measure (AddCircle (1:ℝ))))
      (fun _ => Measure.comap Subtype.val (volume : Measure ℝ))
      (fun _ => show MeasurePreserving (AddCircle.equivIoc (1:ℝ) 0)
          (volume : Measure (AddCircle (1:ℝ)))
          (Measure.comap Subtype.val (volume : Measure ℝ)) from
        @AddCircle.measurePreserving_equivIoc 1 factPeriodOne 0)

/-! ## §2. Integral bridge: UnitAddTorus ↔ [0,1]^n -/

section IntegralBridge

variable {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]

/-- **Lower-integral bridge** (NSC-TorusBridge-L):

`∫⁻ t : UnitAddTorus (Fin n), f t = ∫⁻ x : Fin n → Ioc 0 (0+1), f (equivIoc.symm x) ∂piIoc n`

**Proof**: `MeasurePreserving.symm` + `MeasurePreserving.lintegral_comp`. -/
theorem UnitAddTorus.lintegral_preimage_pi {n : ℕ} (f : UnitAddTorus (Fin n) → ℝ≥0∞) :
    ∫⁻ t : UnitAddTorus (Fin n), f t =
    ∫⁻ x : Fin n → Set.Ioc (0 : ℝ) (0 + 1),
      f ((unitAddTorusEquivIoc n).symm x) ∂(piIoc n) := by
  have hmp_sym := MeasurePreserving.symm (unitAddTorusEquivIoc n)
      (measurePreserving_unitAddTorus_equivIoc n)
  -- lintegral_comp_emb: ∫⁻ x, f (g.symm x) ∂piIoc = ∫⁻ t, f t ∂volume
  exact (hmp_sym.lintegral_comp_emb (unitAddTorusEquivIoc n).symm.measurableEmbedding f).symm

/-- **Bochner integral bridge** (NSC-TorusBridge-I):

`∫ t : UnitAddTorus (Fin n), f t = ∫ x : Fin n → Ioc 0 (0+1), f (equivIoc.symm x) ∂piIoc n`

**Proof**: `MeasurePreserving.symm` + `MeasurePreserving.integral_comp`. -/
theorem UnitAddTorus.integral_preimage_pi {n : ℕ} (f : UnitAddTorus (Fin n) → E) :
    ∫ t : UnitAddTorus (Fin n), f t =
    ∫ x : Fin n → Set.Ioc (0 : ℝ) (0 + 1),
      f ((unitAddTorusEquivIoc n).symm x) ∂(piIoc n) := by
  have hmp_sym := MeasurePreserving.symm (unitAddTorusEquivIoc n)
      (measurePreserving_unitAddTorus_equivIoc n)
  exact (hmp_sym.integral_comp (unitAddTorusEquivIoc n).symm.measurableEmbedding f).symm

end IntegralBridge

/-! ## §3. Space ↔ CATEPTSpace ↔ UnitAddTorus (NSC-P39 scaffolding)

The two hops needed to connect `vorticityLinfNorm u` (L^∞ on Space) to Fourier
coefficients of a function on `UnitAddTorus (Fin 3)`:

**Hop 1** (CATEPTSpaceTime, NSC-P36B):
  `Space.equivPi 3 : Space ≃L[ℝ] CATEPTSpace = Fin 3 → ℝ`
  `MeasurePreserving (Space.equivPi 3)` — PROVED (0 sorrys) via
  `PiLp.volume_preserving_ofLp ∘ LinearIsometryEquiv.measurePreserving (Space.basis.repr)`.

**Hop 2** (T³ periodization):
  `(fun x i => (x i : AddCircle 1)) : (Fin 3 → ℝ) → UnitAddTorus (Fin 3)`
  This is the quotient map ℝ³ → T³. L^∞ transfers because the function is 1-periodic.
  MeasurePreserving — PROVED (0 sorrys) via `measurePreserving_pi + AddCircle.measurePreserving_mk`.

Both hops are proved (0 sorrys). The remaining NSC-P39 gap is the G2+G3 construction
in `space_torus_vorticity_bridge` (PeriodicSobolev.lean): converting `vorticity u : Space → ℝ³`
to `omega_tilde : Lp ℂ 2 (UnitAddTorus (Fin 3))` with the required bridge properties.
-/

/-- **Space → CATEPTSpace volume-preserving** (PROVED, Hop 1):
`Space.equivPi 3 : Space → Fin 3 → ℝ` is measure-preserving
w.r.t. `volume : Measure Space` and `volume : Measure (Fin 3 → ℝ)` (Measure.pi).

**Proof**: Chain `Space →[basis.repr]→ EuclideanSpace ℝ (Fin 3) →[ofLp]→ Fin 3 → ℝ`.
`basis.repr` is a `LinearIsometryEquiv` (measure-preserving by `LinearIsometryEquiv.measurePreserving`).
`WithLp.ofLp` is measure-preserving by `PiLp.volume_preserving_ofLp`.
The whnf-loop concern (NSC-P36B) is bypassed: `heq` uses `simp` to show
`Space.equivPi 3 = ofLp ∘ basis.repr` definitionally, so `volume : Measure Space`
is never directly reduced.

**Reference**: `PiLp.volume_preserving_ofLp` for the `EuclideanSpace` case. -/
theorem space_equivPi_measurePreserving :
    MeasurePreserving (Space.equivPi 3 : Space → Fin 3 → ℝ)
      (volume : Measure Space) (volume : Measure (Fin 3 → ℝ)) := by
  -- Chain: Space →[basis.repr]→ EuclideanSpace ℝ (Fin 3) →[ofLp]→ Fin 3 → ℝ
  -- basis.repr is a LinearIsometryEquiv; ofLp is the PiLp volume-preserving map.
  -- Space.equivPi 3 = ofLp ∘ basis.repr holds definitionally (both are fun p i => p i).
  -- heq: Space.equivPi 3 = ofLp ∘ basis.repr definitionally
  -- (both reduce to fun p i => p i; ofLp unwraps the WithLp.toLp wrapper from basis.repr)
  have heq : (Space.equivPi 3 : Space → Fin 3 → ℝ) =
      @WithLp.ofLp 2 (Fin 3 → ℝ) ∘ ⇑(Space.basis (d := 3).repr) := by
    funext p
    simp [Space.basis, Space.equivPi, LinearEquiv.toContinuousLinearEquiv]
  rw [heq]
  exact (PiLp.volume_preserving_ofLp (ι := Fin 3)).comp
    (LinearIsometryEquiv.measurePreserving (Space.basis (d := 3).repr))

/-- **Fin 3 → ℝ → UnitAddTorus (Fin 3) measure bridge** (PROVED, Hop 2):
The periodization map `fun x i => (x i : AddCircle 1)` transfers
`volume : Measure (Fin 3 → ℝ)` restricted to `Ioc 0 1 ^ 3` to the product Haar on T³.

**Proof**: `rw [volume_pi, Measure.restrict_pi_pi]`, then `measurePreserving_pi` reduces
to per-component `MeasurePreserving ((↑) : ℝ → AddCircle 1) (volume.restrict (Ioc 0 1)) volume`
which is `AddCircle.measurePreserving_mk 1 ⟨one_pos⟩ 0` (after `simp zero_add`).

**Reference**: `AddCircle.measurePreserving_mk` + §1 above. -/
theorem cateptSpace_torus_measurePreserving :
    MeasurePreserving
      (fun (x : Fin 3 → ℝ) (i : Fin 3) => (x i : AddCircle (1 : ℝ)))
      ((volume : Measure (Fin 3 → ℝ)).restrict
        (Set.pi Set.univ (fun _ => Set.Ioc (0 : ℝ) 1)))
      (volume : Measure (UnitAddTorus (Fin 3))) := by
  -- Source: (volume on Fin 3 → ℝ).restrict (pi univ Ioc 0 1)
  --       = Measure.pi (fun _ => volume.restrict Ioc 0 1)   [restrict_pi_pi]
  -- Target: volume on Fin 3 → AddCircle 1 = Measure.pi (fun _ => volume)   [volume_pi = rfl]
  -- Strategy: apply measurePreserving_pi with AddCircle.measurePreserving_mk per component.
  -- volume on pi types = Measure.pi (fun _ => volume); unfold to expose the pi structure
  rw [volume_pi, Measure.restrict_pi_pi]
  apply measurePreserving_pi _ _ fun _ => ?_
  -- Goal: MeasurePreserving ((↑) : ℝ → AddCircle 1) (volume.restrict (Ioc 0 1)) volume
  -- AddCircle.measurePreserving_mk 0 (T=1) gives this with Ioc 0 (0+1); simp closes 0+1=1.
  have h := @AddCircle.measurePreserving_mk 1 factPeriodOne 0
  simp only [zero_add] at h
  exact h

/-! ## §4. Zero-witness discharge for space_torus_vorticity_bridge -/

section ZeroWitness

-- Shadow the factPeriodOne-derived AddCircle.measureSpace 1 with a direct instance
-- (same underlying measure: AddCircle.haarAddCircle) to prevent isDefEq timeout.
-- This mirrors the fix in PeriodicSobolev.lean (line 87) which resolved the same
-- two-candidate Fact (0 < 1) competition in mFourierCoeff/mFourier elaboration.
-- Must be declared AFTER cateptSpace_torus_measurePreserving (which relies on the
-- factPeriodOne-derived instance via AddCircle.measurePreserving_mk).
noncomputable local instance haarCircleInstTB : MeasureTheory.MeasureSpace UnitAddCircle :=
  ⟨AddCircle.haarAddCircle⟩

open NavierStokesClean.Sobolev in
/-- **Zero-vorticity witness** (NSC-TorusBridge-Zero):

When `spatialEnstrophy u = 0`, the zero function `ω̃ = 0 ∈ L²(UnitAddTorus (Fin 3))`
witnesses all four properties of `space_torus_vorticity_bridge`:
1. Mean-zero: `mFourierCoeff 0 0 = 0` ✓
2. H¹ summable: `h1FourierSemiNormCoeffs 0 k = 0` for all k ✓
3. L² bridge: `∫ ‖0‖² = 0 = spatialEnstrophy u` ✓
4. H¹ ≤ palinstrophy: `0 = h1FourierSemiNorm 0 ≤ palinstrophySpatial u` ✓

This handles the degenerate case; the non-trivial case requires Hop 1 + Hop 2 above. -/
theorem space_torus_bridge_zero_witness (u : NSVelocityField)
    (h_zero_enstrophy : spatialEnstrophy u = 0) :
    ∃ omega_tilde : Lp ℂ 2 (volume : Measure (UnitAddTorus (Fin 3))),
      mFourierCoeff (omega_tilde : UnitAddTorus (Fin 3) → ℂ) 0 = 0 ∧
      Summable (h1FourierSemiNormCoeffs (omega_tilde : UnitAddTorus (Fin 3) → ℂ)) ∧
      ∫ t, ‖(omega_tilde : UnitAddTorus (Fin 3) → ℂ) t‖ ^ 2 = spatialEnstrophy u ∧
      h1FourierSemiNorm (omega_tilde : UnitAddTorus (Fin 3) → ℂ) ≤ palinstrophySpatial u :=
  space_torus_vorticity_bridge_zero u h_zero_enstrophy

end ZeroWitness

end NavierStokesClean.Sobolev.TorusBridge
