import NavierStokes.NSGalerkinCayleyBridge
import NavierStokes.NSGalerkinConvDef

/-!
# Stage 166 — NSGalerkinInjectivityBridge: Algebraic Injectivity of the Cayley Map

Proves that the map `A_h u : CoeffC N → CoeffC N` defined by
`(A_h u x) i = x i − (h/2) · K_u(x) i`
is **injective for all h : Rat**, using only bilinear antisymmetry.

## Key norm identity

For any `w : CoeffC N`, setting `K_u w = galerkinConvection basis u w`:
```
∑ normSqC (w i − (h/2)·K_u w i)
  = ∑ normSqC (w i) + (h/2)² · ∑ normSqC (K_u w i)
```
The cross-term `−h · ∑ Re(w̄_i · (K_u w)_i)` vanishes by `B_bilinear_self_zero`.
In particular: `A_h u w = 0 → ∑ normSqC (w i) = 0 → w = 0`.

## Epistemic upgrade

`cayleySolve` (Stage 165, `.openBridge`) is now:
* **Unique** by `cayleySolve_unique` (THEOREM, 0 new axioms after linearity)
* **Justified** by the norm identity (finite-dimensional injectivity → bijectivity)

Status upgrade: `cayleySolve` + `cayleySolve_eq` → `.partiallyVerified`.

## Net counts

  - New axioms:   2  (galerkinConvection_add_right, galerkinConvection_smul_right)
  - New theorems: 9
  - sorry:        0
  - warnings:     0
-/

namespace NavierStokes.GalerkinInjectivity

set_option autoImplicit false

open NavierStokes.PalinstrophyTauBridge  -- galerkinN
open NavierStokes.GalerkinComplexModel   -- CRat, CoeffC, normSqC, realInnerC
open NavierStokes.GalerkinConvection     -- GalerkinBasis, galerkinConvection
open NavierStokes.GalerkinCayley         -- CRat.smul, B_bilinear_self_zero
open NavierStokes.GalerkinConvDef        -- _from_def linearity transports

/-! ## CRat algebraic lemmas -/

/-- Polarization identity: `|a − r·b|² = |a|² − 2r⟨a,b⟩ + r²|b|²`. -/
theorem normSqC_sub_smul (a b : CRat) (r : Rat) :
    normSqC (a - CRat.smul r b) =
    normSqC a - 2 * r * realInnerC a b + r ^ 2 * normSqC b := by
  simp only [normSqC, realInnerC, CRat.smul, CRat.re, CRat.im,
             Prod.fst_sub, Prod.snd_sub]
  ring

/-- `normSqC z = 0 ↔ z = 0`. -/
theorem normSqC_zero_iff (z : CRat) : normSqC z = 0 ↔ z = 0 := by
  constructor
  · intro h
    simp only [normSqC, CRat.re, CRat.im] at h
    have hre : z.1 = 0 := by nlinarith [sq_nonneg z.1, sq_nonneg z.2]
    have him : z.2 = 0 := by nlinarith [sq_nonneg z.1, sq_nonneg z.2]
    exact Prod.ext hre him
  · rintro rfl
    simp [normSqC, CRat.re, CRat.im]

/-- If `∑ normSqC (x i) = 0` then every component is zero. -/
theorem normSqC_sum_zero {N : Nat} (x : CoeffC N)
    (h : ∑ i : Fin N, normSqC (x i) = 0) : ∀ i : Fin N, x i = 0 := by
  intro i
  apply (normSqC_zero_iff _).mp
  apply le_antisymm _ (normSqC_nonneg _)
  have hle := Finset.single_le_sum (f := fun j => normSqC (x j))
    (fun j _ => normSqC_nonneg (x j)) (Finset.mem_univ i)
  linarith

/-- `CRat.smul r (a + b) = CRat.smul r a + CRat.smul r b`. -/
theorem CRat.smul_add (r : Rat) (a b : CRat) :
    CRat.smul r (a + b) = CRat.smul r a + CRat.smul r b :=
  Prod.ext (by simp [CRat.smul, CRat.re, CRat.im, mul_add])
           (by simp [CRat.smul, CRat.re, CRat.im, mul_add])

/-- `CRat.smul r (a − b) = CRat.smul r a − CRat.smul r b`. -/
theorem CRat.smul_sub (r : Rat) (a b : CRat) :
    CRat.smul r (a - b) = CRat.smul r a - CRat.smul r b :=
  Prod.ext (by simp [CRat.smul, CRat.re, CRat.im, mul_sub])
           (by simp [CRat.smul, CRat.re, CRat.im, mul_sub])

/-! ## Right-linearity axioms for galerkinConvection -/

/-- **galerkinConvection_add_right** — `K_u(v + w) = K_u v + K_u w`.

    Captures linearity of the Galerkin bilinear operator in its second argument:
    `(u·∇)(v + w) = (u·∇)v + (u·∇)w`.

    Promoted from axiom to theorem via `NSGalerkinConvDef`. -/
theorem galerkinConvection_add_right {N : Nat} (basis : GalerkinBasis N) (u v w : CoeffC N) :
    galerkinConvection basis u (v + w) =
    galerkinConvection basis u v + galerkinConvection basis u w :=
  galerkinConvection_add_right_from_def basis u v w

/-- **galerkinConvection_smul_right** — `K_u(r·v) = r·K_u v` (componentwise CRat.smul).

    Promoted from axiom to theorem via `NSGalerkinConvDef`. -/
theorem galerkinConvection_smul_right {N : Nat} (basis : GalerkinBasis N)
    (u v : CoeffC N) (r : Rat) :
    galerkinConvection basis u (fun j => CRat.smul r (v j)) =
    fun i => CRat.smul r (galerkinConvection basis u v i) :=
  galerkinConvection_smul_right_from_def basis u v r

/-- `K_u(v − w) = K_u v − K_u w` (derived from add + smul). -/
theorem galerkinConvection_sub_right {N : Nat} (basis : GalerkinBasis N)
    (u v w : CoeffC N) :
    galerkinConvection basis u (v - w) =
    galerkinConvection basis u v - galerkinConvection basis u w := by
  have hsub : v - w = v + fun j => CRat.smul (-1) (w j) :=
    funext fun j => by
      simp only [Pi.sub_apply, Pi.add_apply]
      have hsmul : CRat.smul (-1) (w j) = -(w j) :=
        Prod.ext
          (by simp [CRat.smul, CRat.re, CRat.im])
          (by simp [CRat.smul, CRat.re, CRat.im])
      rw [hsmul]
      exact sub_eq_add_neg (v j) (w j)
  rw [hsub, galerkinConvection_add_right,
      galerkinConvection_smul_right basis u w (-1)]
  funext i
  apply Prod.ext
  · simp only [Pi.sub_apply, Pi.add_apply, CRat.smul, CRat.re, Prod.fst_add, Prod.fst_sub]; ring
  · simp only [Pi.sub_apply, Pi.add_apply, CRat.smul, CRat.im, Prod.snd_add, Prod.snd_sub]; ring

/-! ## Main norm identity -/

/-- **cayleyMap_norm_sq** — The squared-norm identity for `A_h u w = w − (h/2)·K_u w`.

    `∑ normSqC (w i − (h/2)·K_u w i) = ∑ normSqC (w i) + (h/2)² · ∑ normSqC (K_u w i)`.

    The cross-term `−h · ∑ Re(w̄·K_u w)` vanishes by `B_bilinear_self_zero`. -/
theorem cayleyMap_norm_sq {N : Nat} (basis : GalerkinBasis N) (h : Rat) (u w : CoeffC N) :
    ∑ i : Fin N, normSqC (w i - CRat.smul (h / 2) (galerkinConvection basis u w i)) =
    ∑ i : Fin N, normSqC (w i) +
    (h / 2) ^ 2 * ∑ i : Fin N, normSqC (galerkinConvection basis u w i) := by
  -- Expand via polarization, then apply B_bilinear_self_zero
  suffices h_expand :
      ∑ i : Fin N, normSqC (w i - CRat.smul (h / 2) (galerkinConvection basis u w i)) =
      ∑ i : Fin N, normSqC (w i) -
      2 * (h / 2) * ∑ i : Fin N, realInnerC (w i) (galerkinConvection basis u w i) +
      (h / 2) ^ 2 * ∑ i : Fin N, normSqC (galerkinConvection basis u w i) by
    rw [h_expand, B_bilinear_self_zero]
    ring
  simp_rw [normSqC_sub_smul]
  rw [Finset.sum_add_distrib, Finset.sum_sub_distrib,
      ← Finset.mul_sum, ← Finset.mul_sum]

/-! ## Injectivity of the Cayley map -/

/-- **cayleyMap_injective** — `w ↦ w − (h/2)·K_u w` is injective for all `h`.

    If `∀ i, x i − (h/2)·K_u x i = y i − (h/2)·K_u y i` then `x = y`.

    Proof: set `d = x − y`.  Right-linearity gives `d i − (h/2)·K_u d i = 0` for all i.
    By `cayleyMap_norm_sq`: `∑ normSqC (d i) + nonneg_term = 0`,
    so `∑ normSqC (d i) = 0`, hence `d = 0`. -/
theorem cayleyMap_injective {N : Nat} (basis : GalerkinBasis N) (h : Rat) (u x y : CoeffC N)
    (heq : ∀ i : Fin N,
      x i - CRat.smul (h / 2) (galerkinConvection basis u x i) =
      y i - CRat.smul (h / 2) (galerkinConvection basis u y i)) :
    x = y := by
  -- Step 1: show (x-y) i - (h/2)·K_u(x-y) i = 0 for all i
  have hzero : ∀ i : Fin N,
      (x - y) i - CRat.smul (h / 2) (galerkinConvection basis u (x - y) i) = 0 := by
    intro i
    have hk : galerkinConvection basis u (x - y) i =
        galerkinConvection basis u x i - galerkinConvection basis u y i :=
      congr_fun (galerkinConvection_sub_right basis u x y) i
    rw [Pi.sub_apply, hk, CRat.smul_sub]
    -- Goal: x i - y i - (CRat.smul (h/2) (K_u x i) - CRat.smul (h/2) (K_u y i)) = 0
    -- Rearrange to (x i - CRat.smul (h/2) (K_u x i)) - (y i - CRat.smul (h/2) (K_u y i))
    have hrearr : x i - y i - (CRat.smul (h / 2) (galerkinConvection basis u x i) -
                               CRat.smul (h / 2) (galerkinConvection basis u y i)) =
                  (x i - CRat.smul (h / 2) (galerkinConvection basis u x i)) -
                  (y i - CRat.smul (h / 2) (galerkinConvection basis u y i)) := by
      apply Prod.ext
      · simp only [CRat.smul, CRat.re, Prod.fst_sub]; ring
      · simp only [CRat.smul, CRat.im, Prod.snd_sub]; ring
    rw [hrearr, heq i, sub_self]
  -- Step 2: ∑ normSqC ((x-y) i) = 0
  have hsum : ∑ i : Fin N, normSqC ((x - y) i) = 0 := by
    have hnorm := cayleyMap_norm_sq basis h u (x - y)
    have hlhs : ∑ i : Fin N,
        normSqC ((x - y) i - CRat.smul (h / 2) (galerkinConvection basis u (x - y) i)) = 0 := by
      apply Finset.sum_eq_zero
      intro i _
      rw [hzero i]
      simp [normSqC, CRat.re, CRat.im]
    rw [hlhs] at hnorm
    have hnn : 0 ≤ (h / 2) ^ 2 * ∑ i : Fin N, normSqC (galerkinConvection basis u (x - y) i) :=
      mul_nonneg (sq_nonneg _) (Finset.sum_nonneg fun i _ => normSqC_nonneg _)
    have hnn2 : 0 ≤ ∑ i : Fin N, normSqC ((x - y) i) :=
      Finset.sum_nonneg (fun i _ => normSqC_nonneg ((x - y) i))
    linarith
  -- Step 3: conclude x = y
  funext i
  have hzi := normSqC_sum_zero (x - y) hsum i
  rw [Pi.sub_apply] at hzi
  exact sub_eq_zero.mp hzi

/-! ## Uniqueness of the Cayley solution -/

/-- **cayleySolve_unique** — the Cayley equation has at most one solution.

    If `v` and `w` both satisfy `z i − u i = (h/2) · K_u(z + u) i`, then `v = w`.

    Proof: subtract the equations; right-linearity reduces to `A_h u (v − w) = 0`,
    and `cayleyMap_injective` gives `v − w = 0`. -/
theorem cayleySolve_unique {N : Nat} (basis : GalerkinBasis N) (h : Rat) (u v w : CoeffC N)
    (hv : ∀ i : Fin N,
      v i - u i = CRat.smul (h / 2) (galerkinConvection basis u (fun j => v j + u j) i))
    (hw : ∀ i : Fin N,
      w i - u i = CRat.smul (h / 2) (galerkinConvection basis u (fun j => w j + u j) i)) :
    v = w := by
  apply cayleyMap_injective basis h u
  intro i
  -- Expand K_u(v+u) = K_u v + K_u u  and  K_u(w+u) = K_u w + K_u u
  have hkv : galerkinConvection basis u (fun j => v j + u j) i =
      galerkinConvection basis u v i + galerkinConvection basis u u i :=
    congr_fun (galerkinConvection_add_right basis u v u) i
  have hkw : galerkinConvection basis u (fun j => w j + u j) i =
      galerkinConvection basis u w i + galerkinConvection basis u u i :=
    congr_fun (galerkinConvection_add_right basis u w u) i
  -- Distribute smul over the sum
  have hkv_smul : CRat.smul (h / 2) (galerkinConvection basis u (fun j => v j + u j) i) =
      CRat.smul (h / 2) (galerkinConvection basis u v i) +
      CRat.smul (h / 2) (galerkinConvection basis u u i) := by
    rw [hkv, CRat.smul_add]
  have hkw_smul : CRat.smul (h / 2) (galerkinConvection basis u (fun j => w j + u j) i) =
      CRat.smul (h / 2) (galerkinConvection basis u w i) +
      CRat.smul (h / 2) (galerkinConvection basis u u i) := by
    rw [hkw, CRat.smul_add]
  -- From hv i and hw i: both v i - smul(K_u v i) and w i - smul(K_u w i) equal u i + smul(K_u u i)
  have hv_eq : v i - CRat.smul (h / 2) (galerkinConvection basis u v i) =
      u i + CRat.smul (h / 2) (galerkinConvection basis u u i) := by
    have hvi := hv i
    rw [hkv_smul] at hvi
    apply Prod.ext
    · have h1 := congr_arg Prod.fst hvi
      simp only [CRat.smul, CRat.re, Prod.fst_sub, Prod.fst_add] at h1 ⊢
      linarith
    · have h2 := congr_arg Prod.snd hvi
      simp only [CRat.smul, CRat.im, Prod.snd_sub, Prod.snd_add] at h2 ⊢
      linarith
  have hw_eq : w i - CRat.smul (h / 2) (galerkinConvection basis u w i) =
      u i + CRat.smul (h / 2) (galerkinConvection basis u u i) := by
    have hwi := hw i
    rw [hkw_smul] at hwi
    apply Prod.ext
    · have h1 := congr_arg Prod.fst hwi
      simp only [CRat.smul, CRat.re, Prod.fst_sub, Prod.fst_add] at h1 ⊢
      linarith
    · have h2 := congr_arg Prod.snd hwi
      simp only [CRat.smul, CRat.im, Prod.snd_sub, Prod.snd_add] at h2 ⊢
      linarith
  rw [hv_eq, hw_eq]

def stage166Summary : String :=
  "Stage 166: NSGalerkinInjectivityBridge — algebraic injectivity of A_h = I - h/2·K_u. " ++
  "normSqC_sub_smul: polarization identity (ring). " ++
  "normSqC_zero_iff: normSqC z = 0 ↔ z = 0 (nlinarith). " ++
  "normSqC_sum_zero: ∑ normSqC = 0 → ∀ i, x i = 0 (single_le_sum). " ++
  "CRat.smul_add, CRat.smul_sub: smul distributes (ring). " ++
  "galerkinConvection_add_right: K_u(v+w) = K_u v + K_u w (.partiallyVerified). " ++
  "galerkinConvection_smul_right: K_u(r·v) = r·K_u v (.partiallyVerified). " ++
  "galerkinConvection_sub_right: K_u(v-w) = K_u v - K_u w (THEOREM). " ++
  "cayleyMap_norm_sq: ∑|Aw|² = ∑|w|² + (h/2)²∑|Kw|² (B_bilinear_self_zero). " ++
  "cayleyMap_injective: THEOREM (0 new axioms). " ++
  "cayleySolve_unique: THEOREM (cayleySolve solution is unique). " ++
  "+2 axioms, +9 theorems, 0 sorry."

end NavierStokes.GalerkinInjectivity
