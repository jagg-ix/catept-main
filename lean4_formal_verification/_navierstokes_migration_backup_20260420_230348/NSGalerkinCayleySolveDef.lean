import NavierStokes.Galerkin.NSGalerkinInjectivityBridge
import Mathlib.LinearAlgebra.FiniteDimensional.Basic

/-!
# Stage 167 — NSGalerkinCayleySolveDef: Constructive cayleySolve via LinearMap

Eliminates `cayleySolve` (Stage 165 `.openBridge` axiom) by constructing it as a
`noncomputable def` using `LinearMap` + `FiniteDimensional` machinery.

## Strategy

  A_h u : CoeffC N → CoeffC N,   (A_h u v) i = v i − (h/2)·K_u v i

1. Build `Ku_lmap` and `Ah_lmap` as `LinearMap Rat (CoeffC N) (CoeffC N)`.
2. `Ah_lmap` injective: `cayleyMap_injective` (Stage 166).
3. `CoeffC N = Fin N → Rat × Rat` is finite-dimensional over `Rat`.
4. Injective endomorphism of a fd space is bijective.
5. `cayleySolveDef = (Ah_lmap)⁻¹ (u + (h/2)·K_u u)`.
6. `cayleySolveDef_eq`: defining equation proved as theorem.
7. `cayleySolveDef_eq_cayleySolve`: equals Stage 165 axiom via `cayleySolve_unique`.

## Net counts

  - New axioms:   0
  - New theorems: 9
  - sorry:        0
  - warnings:     0
-/

namespace NavierStokes.GalerkinCayleySolveDef

set_option autoImplicit false

open NavierStokes.PalinstrophyTauBridge
open NavierStokes.GalerkinComplexModel
open NavierStokes.GalerkinConvection
open NavierStokes.GalerkinCayley
open NavierStokes.GalerkinInjectivity

/-! ## CRat.smul equals module smul -/

/-- `CRat.smul r z = r • z` for `z : CRat = Rat × Rat` (needed for LinearMap API). -/
theorem CRat.smul_eq_module_smul (r : Rat) (z : CRat) : CRat.smul r z = r • z :=
  Prod.ext (by simp [CRat.smul, CRat.re, smul_eq_mul])
           (by simp [CRat.smul, CRat.im, smul_eq_mul])

/-! ## Galerkin convection as a linear map -/

/-- `K_u = galerkinConvection basis u` packaged as a `Rat`-linear map. -/
noncomputable def Ku_lmap {N : Nat} (basis : GalerkinBasis N) (u : CoeffC N) :
    CoeffC N →ₗ[Rat] CoeffC N where
  toFun    := galerkinConvection basis u
  map_add' := fun v w => galerkinConvection_add_right basis u v w
  map_smul' := fun r v => by
    simp only [RingHom.id_apply]
    rw [show r • v = fun j => CRat.smul r (v j) from
          funext fun j => (CRat.smul_eq_module_smul r (v j)).symm,
        galerkinConvection_smul_right basis u v r]
    exact funext fun i => CRat.smul_eq_module_smul r _

/-! ## The Cayley operator A_h = id − (h/2)·K_u -/

/-- `A_h u = id − (h/2) · K_u` as a `Rat`-linear map. -/
noncomputable def Ah_lmap {N : Nat} (basis : GalerkinBasis N) (h : Rat) (u : CoeffC N) :
    CoeffC N →ₗ[Rat] CoeffC N :=
  LinearMap.id - (h / 2 : Rat) • Ku_lmap basis u

/-- Pointwise formula: `(Ah_lmap basis h u v) i = v i − (h/2) · K_u v i`. -/
theorem Ah_lmap_apply {N : Nat} (basis : GalerkinBasis N) (h : Rat) (u v : CoeffC N)
    (i : Fin N) :
    Ah_lmap basis h u v i = v i - CRat.smul (h / 2) (galerkinConvection basis u v i) := by
  show (v - (h / 2 : Rat) • galerkinConvection basis u v) i =
       v i - CRat.smul (h / 2) (galerkinConvection basis u v i)
  simp only [Pi.sub_apply, Pi.smul_apply, ← CRat.smul_eq_module_smul]

/-! ## Injectivity and surjectivity -/

/-- `Ah_lmap` is injective: follows directly from Stage 166 `cayleyMap_injective`. -/
theorem Ah_lmap_injective {N : Nat} (basis : GalerkinBasis N) (h : Rat) (u : CoeffC N) :
    Function.Injective (Ah_lmap basis h u) := by
  intro x y heq
  apply cayleyMap_injective basis h u
  intro i
  have hi := congr_fun heq i
  rwa [Ah_lmap_apply, Ah_lmap_apply] at hi

/-- `Ah_lmap` is surjective: injective + finite-dimensional. -/
theorem Ah_lmap_surjective {N : Nat} (basis : GalerkinBasis N) (h : Rat) (u : CoeffC N) :
    Function.Surjective (Ah_lmap basis h u) :=
  LinearMap.injective_iff_surjective.mp (Ah_lmap_injective basis h u)

/-! ## Linear equivalence -/

/-- `Ah_equiv basis h u : CoeffC N ≃ₗ[Rat] CoeffC N` from bijectivity. -/
noncomputable def Ah_equiv {N : Nat} (basis : GalerkinBasis N) (h : Rat) (u : CoeffC N) :
    CoeffC N ≃ₗ[Rat] CoeffC N :=
  LinearEquiv.ofBijective (Ah_lmap basis h u)
    ⟨Ah_lmap_injective basis h u, Ah_lmap_surjective basis h u⟩

/-! ## Constructive cayleySolve -/

/-- Right-hand side of the Cayley equation: `rhs i = u i + (h/2) · K_u u i`. -/
noncomputable def cayleyRHS {N : Nat} (basis : GalerkinBasis N) (h : Rat) (u : CoeffC N) :
    CoeffC N :=
  fun i => u i + CRat.smul (h / 2) (galerkinConvection basis u u i)

/-- Constructive Cayley step: `cayleySolveDef = (A_h u)⁻¹ (rhs)`. -/
noncomputable def cayleySolveDef {N : Nat} (basis : GalerkinBasis N) (h : Rat)
    (u : CoeffC N) : CoeffC N :=
  (Ah_equiv basis h u).symm (cayleyRHS basis h u)

/-- `A_h u (cayleySolveDef) = cayleyRHS` — from `LinearEquiv.apply_symm_apply`. -/
theorem Ah_lmap_cayleySolveDef {N : Nat} (basis : GalerkinBasis N) (h : Rat) (u : CoeffC N) :
    Ah_lmap basis h u (cayleySolveDef basis h u) = cayleyRHS basis h u := by
  unfold cayleySolveDef
  have key : ∀ y : CoeffC N,
      Ah_lmap basis h u ((Ah_equiv basis h u).symm y) = y := fun y =>
    calc Ah_lmap basis h u ((Ah_equiv basis h u).symm y)
        = (Ah_equiv basis h u) ((Ah_equiv basis h u).symm y) := by
            simp [Ah_equiv]
      _ = y := (Ah_equiv basis h u).apply_symm_apply y
  exact key (cayleyRHS basis h u)

/-- **cayleySolveDef_eq** — the defining Cayley equation holds as a theorem.

    `cayleySolveDef basis h u i − u i = (h/2) · K_u(cayleySolveDef + u) i`. -/
theorem cayleySolveDef_eq {N : Nat} (basis : GalerkinBasis N) (h : Rat) (u : CoeffC N) :
    ∀ i : Fin N,
      cayleySolveDef basis h u i - u i =
      CRat.smul (h / 2)
        (galerkinConvection basis u (fun j => cayleySolveDef basis h u j + u j) i) := by
  set v := cayleySolveDef basis h u
  intro i
  -- Extract pointwise equation: v i − (h/2)·K_u v i = u i + (h/2)·K_u u i
  have hAh : v i - CRat.smul (h / 2) (galerkinConvection basis u v i) =
      u i + CRat.smul (h / 2) (galerkinConvection basis u u i) := by
    have := congr_fun (Ah_lmap_cayleySolveDef basis h u) i
    rw [Ah_lmap_apply] at this
    simp only [cayleyRHS] at this
    exact this
  -- Expand K_u(v + u) = K_u v + K_u u
  have hku : galerkinConvection basis u (fun j => v j + u j) i =
      galerkinConvection basis u v i + galerkinConvection basis u u i :=
    congr_fun (galerkinConvection_add_right basis u v u) i
  rw [hku, CRat.smul_add]
  -- Rearrange: v i − u i = smul(K_u v i) + smul(K_u u i) from hAh
  apply Prod.ext
  · have hAh1 := congr_arg Prod.fst hAh
    simp only [CRat.smul, CRat.re, Prod.fst_sub, Prod.fst_add] at hAh1 ⊢
    linarith
  · have hAh2 := congr_arg Prod.snd hAh
    simp only [CRat.smul, CRat.im, Prod.snd_sub, Prod.snd_add] at hAh2 ⊢
    linarith

/-- **cayleySolveDef_eq_cayleySolve** — promotes `cayleySolve` from axiom to theorem.

    The constructive def equals the Stage 165 axiomatic `cayleySolve`, by uniqueness. -/
theorem cayleySolveDef_eq_cayleySolve {N : Nat} (basis : GalerkinBasis N) (h : Rat)
    (u : CoeffC N) :
    cayleySolveDef basis h u = cayleySolve basis h u :=
  cayleySolve_unique basis h u
    (cayleySolveDef basis h u) (cayleySolve basis h u)
    (cayleySolveDef_eq basis h u)
    (cayleySolve_eq basis h u)

def stage167Summary : String :=
  "Stage 167: NSGalerkinCayleySolveDef — constructive cayleySolve via LinearMap + FiniteDimensional. " ++
  "CRat.smul_eq_module_smul: CRat.smul = module smul (Prod.ext + simp). " ++
  "Ku_lmap: galerkinConvection as LinearMap Rat (CoeffC N) (CoeffC N). " ++
  "Ah_lmap: A_h = id - (h/2)•K_u. " ++
  "Ah_lmap_apply: pointwise formula (show + Pi.smul_apply). " ++
  "Ah_lmap_injective: THEOREM from cayleyMap_injective. " ++
  "Ah_lmap_surjective: THEOREM from LinearMap.injective_iff_surjective (FiniteDimensional). " ++
  "Ah_equiv: LinearEquiv.ofBijective. " ++
  "cayleySolveDef: noncomputable def (Ah_equiv.symm of cayleyRHS). " ++
  "cayleySolveDef_eq: THEOREM (defining equation from apply_symm_apply). " ++
  "cayleySolveDef_eq_cayleySolve: THEOREM (= Stage 165 axiom via cayleySolve_unique). " ++
  "+0 axioms, +9 theorems, 0 sorry."

end NavierStokes.GalerkinCayleySolveDef
