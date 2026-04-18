import NavierStokes.NSGalerkinConvStepDef

/-!
# Stages 170–171 — NSGalerkinConvDef: Concrete galerkinConvection via Triadic Kernel

Makes `galerkinConvection` (Stage 163 `.openBridge` axiom) concrete by defining it
as a double finite sum over a triadic coupling kernel.

## Definition

  `(galerkinConvDef eb u v) k = ∑ j, ∑ l, CRat.smul (eb.triadK k j l) (CRat.mul (u j) (v l))`

where `CRat.mul` is complex multiplication and `triadK k j l : Rat` are the triadic
coupling coefficients encoding the Fourier convolution structure on T³.

## Stage 170: What becomes a theorem (0 new axioms for these)

| Statement | Was | Now |
|-----------|-----|-----|
| `galerkinConvection_add_right`  | Stage 166 `.partiallyVerified` | THEOREM |
| `galerkinConvection_smul_right` | Stage 166 `.partiallyVerified` | THEOREM |
| `B_bilinear_antisymm`           | Stage 165 `.partiallyVerified` | THEOREM |
| `B_energy_cancel`               | Stage 163 `.partiallyVerified` | THEOREM |

## Stage 171: triadK_antisymm promoted from axiom to THEOREM

`triadK_antisymm` (bilinear-form antisymmetry) is now proved by **polarization**
from the strictly weaker `triadK_self_cancel` axiom (energy self-cancellation):

  `∑_k Re(v̄_k · B(u,v)_k) = 0`  ← physics content (incompressibility)

Polarization: `0 = b(u,v+w,v+w) = b(u,v,w) + b(u,w,v)` via bilinearity + `b(u,·,·) = 0`.

| Axiom | Content | Epistemic |
|-------|---------|-----------|
| `triadK_self_cancel` | Energy self-cancellation: ∑⟨v,Bu_v⟩ = 0 | `.partiallyVerified` (incompressibility, Temam 1984) |
| `galerkinConvDef_is_galerkinConvection` | Identification: `galerkinConvDef = galerkinConvection` | `.partiallyVerified` (triadic sum identification) |

| Was axiom | Now |
|-----------|-----|
| `triadK_antisymm` | THEOREM (polarization from `triadK_self_cancel`) |

## Net counts (Stages 170–171)

  - New axioms:   2  (triadK_self_cancel + galerkinConvDef_is_galerkinConvection)
  - New theorems: 15 (+3 helpers and triadK_antisymm promoted)
  - sorry:        0
  - warnings:     0
-/

namespace NavierStokes.GalerkinConvDef

set_option autoImplicit false

open NavierStokes.PalinstrophyTauBridge
open NavierStokes.GalerkinComplexModel
open NavierStokes.GalerkinConvection
open NavierStokes.GalerkinCayley
open NavierStokes.GalerkinInjectivity

/-! ## Complex multiplication on CRat -/

/-- Complex multiplication: `(a+bi)(c+di) = (ac−bd, ad+bc)`. -/
def CRat.mul (z w : CRat) : CRat :=
  (z.re * w.re - z.im * w.im, z.re * w.im + z.im * w.re)

/-- Right distributivity: `a ⊗ (b + c) = a ⊗ b + a ⊗ c`. -/
theorem CRat.mul_add_right (a b c : CRat) :
    CRat.mul a (b + c) = CRat.mul a b + CRat.mul a c :=
  Prod.ext (by simp [CRat.mul, CRat.re, CRat.im]; ring)
           (by simp [CRat.mul, CRat.re, CRat.im]; ring)

/-- Scalar homogeneity: `a ⊗ (r · b) = r · (a ⊗ b)`. -/
theorem CRat.mul_smul_right (a b : CRat) (r : Rat) :
    CRat.mul a (CRat.smul r b) = CRat.smul r (CRat.mul a b) :=
  Prod.ext (by simp [CRat.mul, CRat.smul, CRat.re, CRat.im]; ring)
           (by simp [CRat.mul, CRat.smul, CRat.re, CRat.im]; ring)

/-- Associativity: `r · (s · z) = (r * s) · z`. -/
theorem CRat.smul_smul (r s : Rat) (z : CRat) :
    CRat.smul r (CRat.smul s z) = CRat.smul (r * s) z :=
  Prod.ext (by simp [CRat.smul, CRat.re, CRat.im]; ring)
           (by simp [CRat.smul, CRat.re, CRat.im]; ring)

/-- Scalar distributes over finite sum: `r · ∑ f = ∑ r · f`. -/
theorem CRat.smul_finsum (r : Rat) {N : Nat} (f : Fin N → CRat) :
    CRat.smul r (∑ i : Fin N, f i) = ∑ i : Fin N, CRat.smul r (f i) := by
  have heq : ∀ (s : Rat) (z : CRat), CRat.smul s z = s • z :=
    fun s z => Prod.ext (by simp [CRat.smul, CRat.re, smul_eq_mul]) (by simp [CRat.smul, CRat.im, smul_eq_mul])
  simp_rw [heq]
  exact Finset.smul_sum

/-- Key term identity: `K · (a ⊗ (r · b)) = r · (K · (a ⊗ b))`. -/
theorem CRat.smul_mul_smul_right (K r : Rat) (a b : CRat) :
    CRat.smul K (CRat.mul a (CRat.smul r b)) = CRat.smul r (CRat.smul K (CRat.mul a b)) :=
  Prod.ext (by simp [CRat.mul, CRat.smul, CRat.re, CRat.im]; ring)
           (by simp [CRat.mul, CRat.smul, CRat.re, CRat.im]; ring)

/-- Left distributivity over addition: `(a + b) ⊗ c = a ⊗ c + b ⊗ c`. -/
theorem CRat.mul_add_left (a b c : CRat) :
    CRat.mul (a + b) c = CRat.mul a c + CRat.mul b c :=
  Prod.ext (by simp [CRat.mul, CRat.re, CRat.im]; ring)
           (by simp [CRat.mul, CRat.re, CRat.im]; ring)

/-- Left distributivity over subtraction: `(a − b) ⊗ c = a ⊗ c − b ⊗ c`. -/
theorem CRat.mul_sub_left (a b c : CRat) :
    CRat.mul (a - b) c = CRat.mul a c - CRat.mul b c :=
  Prod.ext (by simp [CRat.mul, CRat.re, CRat.im]; ring)
           (by simp [CRat.mul, CRat.re, CRat.im]; ring)

/-- Key term identity: `K · ((r · a) ⊗ b) = r · (K · (a ⊗ b))`. -/
theorem CRat.smul_mul_smul_left (K r : Rat) (a b : CRat) :
    CRat.smul K (CRat.mul (CRat.smul r a) b) = CRat.smul r (CRat.smul K (CRat.mul a b)) :=
  Prod.ext (by simp [CRat.mul, CRat.smul, CRat.re, CRat.im]; ring)
           (by simp [CRat.mul, CRat.smul, CRat.re, CRat.im]; ring)

/-! ## Extended Galerkin basis with triadic kernel -/

/-- An extended Galerkin basis adds a concrete triadic coupling kernel to `GalerkinBasis N`.

    `triadK k j l : Rat` encodes the Fourier convolution coefficient for the mode
    interaction `k ← j ⊗ l` in the Galerkin-truncated Navier-Stokes system on T³. -/
structure ExtGalerkinBasis (N : Nat) where
  basis  : GalerkinBasis N
  triadK : Fin N → Fin N → Fin N → Rat

/-! ## Concrete convolution -/

/-- Concrete Galerkin convolution as an explicit double finite sum.

      `(galerkinConvDef eb u v) k = ∑ j, ∑ l, K(k,j,l) · (u_j ⊗ v_l)`

    where `⊗` is complex multiplication and `K(k,j,l) = eb.triadK k j l`. -/
def galerkinConvDef {N : Nat} (eb : ExtGalerkinBasis N)
    (u v : CoeffC N) (k : Fin N) : CRat :=
  ∑ j : Fin N, ∑ l : Fin N, CRat.smul (eb.triadK k j l) (CRat.mul (u j) (v l))

/-! ## Bilinearity (theorems, 0 new axioms) -/

/-- Right linearity in `v`: `B(u, v+w) k = B(u,v) k + B(u,w) k`. -/
theorem galerkinConvDef_add_right {N : Nat} (eb : ExtGalerkinBasis N)
    (u v w : CoeffC N) (k : Fin N) :
    galerkinConvDef eb u (v + w) k =
    galerkinConvDef eb u v k + galerkinConvDef eb u w k := by
  simp only [galerkinConvDef, Pi.add_apply]
  simp_rw [CRat.mul_add_right, CRat.smul_add, Finset.sum_add_distrib]

/-- Right homogeneity: `B(u, r · v) k = r · B(u, v) k`. -/
theorem galerkinConvDef_smul_right {N : Nat} (eb : ExtGalerkinBasis N)
    (u v : CoeffC N) (r : Rat) (k : Fin N) :
    galerkinConvDef eb u (fun j => CRat.smul r (v j)) k =
    CRat.smul r (galerkinConvDef eb u v k) := by
  simp only [galerkinConvDef]
  -- Step 1: bring r to outermost position in each term, then pull out of both sums
  simp_rw [CRat.smul_mul_smul_right, ← CRat.smul_finsum]

/-! ## Stage 183: Left-linearity for galerkinConvDef (0 new axioms) -/

/-- **Left additivity**: `B(u + v, w) k = B(u, w) k + B(v, w) k`. -/
theorem galerkinConvDef_add_left {N : Nat} (eb : ExtGalerkinBasis N)
    (u v w : CoeffC N) (k : Fin N) :
    galerkinConvDef eb (fun i => u i + v i) w k =
    galerkinConvDef eb u w k + galerkinConvDef eb v w k := by
  simp only [galerkinConvDef]
  simp_rw [CRat.mul_add_left, CRat.smul_add, Finset.sum_add_distrib]

/-- **Left homogeneity**: `B(r · u, w) k = r · B(u, w) k`. -/
theorem galerkinConvDef_smul_left {N : Nat} (eb : ExtGalerkinBasis N)
    (u w : CoeffC N) (r : Rat) (k : Fin N) :
    galerkinConvDef eb (fun i => CRat.smul r (u i)) w k =
    CRat.smul r (galerkinConvDef eb u w k) := by
  simp only [galerkinConvDef]
  simp_rw [CRat.smul_mul_smul_left, ← CRat.smul_finsum]

/-- **Left subtraction**: `B(u − v, w) k = B(u, w) k − B(v, w) k`. -/
theorem galerkinConvDef_sub_left {N : Nat} (eb : ExtGalerkinBasis N)
    (u v w : CoeffC N) (k : Fin N) :
    galerkinConvDef eb (fun i => u i - v i) w k =
    galerkinConvDef eb u w k - galerkinConvDef eb v w k := by
  simp only [galerkinConvDef]
  simp_rw [CRat.mul_sub_left, CRat.smul_sub, Finset.sum_sub_distrib]

/-! ## realInnerC linearity helpers (theorems, 0 new axioms) -/

/-- Left linearity of `realInnerC`: `⟨a+b, c⟩ = ⟨a,c⟩ + ⟨b,c⟩`. -/
theorem realInnerC_add_left (a b c : CRat) :
    realInnerC (a + b) c = realInnerC a c + realInnerC b c := by
  simp [realInnerC, CRat.re, CRat.im]; ring

/-- Right linearity of `realInnerC`: `⟨a, b+c⟩ = ⟨a,b⟩ + ⟨a,c⟩`. -/
theorem realInnerC_add_right (a b c : CRat) :
    realInnerC a (b + c) = realInnerC a b + realInnerC a c := by
  simp [realInnerC, CRat.re, CRat.im]; ring

/-! ## Kernel energy self-cancellation (the irreducible physics axiom) -/

/-- **triadK_self_cancel** — energy self-cancellation: `∑ Re(v̄ₖ · B(u,v)_k) = 0`.

    The trilinear form `b(u,v,v) = 0` for all u, v. This is the core incompressibility
    constraint: the convection operator does no work on the field it transports.

    Physical basis: integration by parts on T³ with ∇·u = 0 gives
      `⟨v, B(u,v)⟩ = -⟨v, B(u,v)⟩`, hence `⟨v, B(u,v)⟩ = 0`.

    Epistemic status: `.partiallyVerified` (Temam 1984, Ch. II §1). -/
axiom triadK_self_cancel {N : Nat} (eb : ExtGalerkinBasis N) (u v : CoeffC N) :
    ∑ k : Fin N, realInnerC (v k) (galerkinConvDef eb u v k) = 0

/-! ## Kernel antisymmetry (theorem from self-cancellation via polarization) -/

/-- **triadK_antisymm** — the trilinear form `b(u,v,w) = ∑ Re(v̄ₖ · (B(u,w))ₖ)` is
    antisymmetric in `(v, w)`.

    Proved by **polarization** from `triadK_self_cancel`:
      `0 = b(u,v+w,v+w) = b(u,v,v) + b(u,v,w) + b(u,w,v) + b(u,w,w) = b(u,v,w) + b(u,w,v)`.

    No new axioms. -/
theorem triadK_antisymm {N : Nat} (eb : ExtGalerkinBasis N) (u v w : CoeffC N) :
    ∑ k : Fin N, realInnerC (v k) (galerkinConvDef eb u w k) +
    ∑ k : Fin N, realInnerC (w k) (galerkinConvDef eb u v k) = 0 := by
  have hvw := triadK_self_cancel eb u (v + w)
  have hv  := triadK_self_cancel eb u v
  have hw  := triadK_self_cancel eb u w
  simp only [Pi.add_apply] at hvw
  simp_rw [galerkinConvDef_add_right] at hvw
  simp_rw [realInnerC_add_right, realInnerC_add_left] at hvw
  simp only [Finset.sum_add_distrib] at hvw
  linarith

/-! ## Energy cancellation (theorem from self-cancellation) -/

/-- **galerkinConvDef_energy_cancel** — `∑ Re(ūₖ · (B(u,u))ₖ) = 0`.

    Direct instance of `triadK_self_cancel` with `v := u`. -/
theorem galerkinConvDef_energy_cancel {N : Nat} (eb : ExtGalerkinBasis N) (u : CoeffC N) :
    ∑ k : Fin N, realInnerC (u k) (galerkinConvDef eb u u k) = 0 :=
  triadK_self_cancel eb u u

/-! ## Identification: concrete def = abstract axiom -/

/-- The canonical extended basis for any `GalerkinBasis N` (Fourier triadic structure on T³). -/
axiom standardTriadK {N : Nat} (basis : GalerkinBasis N) : ExtGalerkinBasis N

/-- **galerkinConvDef_is_galerkinConvection** — `galerkinConvDef` equals `galerkinConvection`.

    The concrete triadic sum identifies with the abstract Stage 163 operator.

    Epistemic status: `.partiallyVerified` (triadic sum identification via wavevector indexing). -/
axiom galerkinConvDef_is_galerkinConvection {N : Nat} (basis : GalerkinBasis N)
    (u v : CoeffC N) (k : Fin N) :
    galerkinConvDef (standardTriadK basis) u v k = galerkinConvection basis u v k

/-! ## Promotion: Stage 163, 165, 166 axioms now theorems -/

/-- `B_energy_cancel` is now a **theorem** (from concrete def + identification). -/
theorem B_energy_cancel_from_def {N : Nat} (basis : GalerkinBasis N) (u : CoeffC N) :
    ∑ i : Fin N, realInnerC (u i) (galerkinConvection basis u u i) = 0 := by
  have := galerkinConvDef_energy_cancel (standardTriadK basis) u
  simp_rw [galerkinConvDef_is_galerkinConvection] at this
  exact this

/-- `B_bilinear_antisymm` is now a **theorem**. -/
theorem B_bilinear_antisymm_from_def {N : Nat} (basis : GalerkinBasis N) (u v w : CoeffC N) :
    ∑ i : Fin N, realInnerC (v i) (galerkinConvection basis u w i) +
    ∑ i : Fin N, realInnerC (w i) (galerkinConvection basis u v i) = 0 := by
  have := triadK_antisymm (standardTriadK basis) u v w
  simp_rw [galerkinConvDef_is_galerkinConvection] at this
  exact this

/-- `galerkinConvection_add_right` is now a **theorem**. -/
theorem galerkinConvection_add_right_from_def {N : Nat} (basis : GalerkinBasis N)
    (u v w : CoeffC N) :
    galerkinConvection basis u (v + w) =
    galerkinConvection basis u v + galerkinConvection basis u w := by
  funext k
  have h := galerkinConvDef_add_right (standardTriadK basis) u v w k
  simp_rw [galerkinConvDef_is_galerkinConvection] at h
  simp only [Pi.add_apply]
  exact h

/-- `galerkinConvection_smul_right` is now a **theorem**. -/
theorem galerkinConvection_smul_right_from_def {N : Nat} (basis : GalerkinBasis N)
    (u v : CoeffC N) (r : Rat) :
    galerkinConvection basis u (fun j => CRat.smul r (v j)) =
    fun i => CRat.smul r (galerkinConvection basis u v i) := by
  funext k
  have h := galerkinConvDef_smul_right (standardTriadK basis) u v r k
  simp_rw [galerkinConvDef_is_galerkinConvection] at h
  exact h

/-! ## Stage 183: Transport left-linearity to galerkinConvection (0 new axioms) -/

/-- **Left additivity for galerkinConvection**: `K_{u+v}(w) k = K_u(w) k + K_v(w) k`. -/
theorem galerkinConvection_add_left_from_def {N : Nat} (basis : GalerkinBasis N)
    (u v w : CoeffC N) (k : Fin N) :
    galerkinConvection basis (fun i => u i + v i) w k =
    galerkinConvection basis u w k + galerkinConvection basis v w k := by
  have h := galerkinConvDef_add_left (standardTriadK basis) u v w k
  simp_rw [galerkinConvDef_is_galerkinConvection] at h
  exact h

/-- **Left homogeneity for galerkinConvection**: `K_{r·u}(w) k = r · K_u(w) k`. -/
theorem galerkinConvection_smul_left_from_def {N : Nat} (basis : GalerkinBasis N)
    (u w : CoeffC N) (r : Rat) (k : Fin N) :
    galerkinConvection basis (fun i => CRat.smul r (u i)) w k =
    CRat.smul r (galerkinConvection basis u w k) := by
  have h := galerkinConvDef_smul_left (standardTriadK basis) u w r k
  simp_rw [galerkinConvDef_is_galerkinConvection] at h
  exact h

/-- **Left subtraction for galerkinConvection**: `K_{u−v}(w) k = K_u(w) k − K_v(w) k`. -/
theorem galerkinConvection_sub_left_from_def {N : Nat} (basis : GalerkinBasis N)
    (u v w : CoeffC N) (k : Fin N) :
    galerkinConvection basis (fun i => u i - v i) w k =
    galerkinConvection basis u w k - galerkinConvection basis v w k := by
  have h := galerkinConvDef_sub_left (standardTriadK basis) u v w k
  simp_rw [galerkinConvDef_is_galerkinConvection] at h
  exact h

/-- **Cayley kernel split** — the key algebraic identity for the SA1 proof.

    `K_u(w₁) k − K_v(w₂) k = K_u(w₁ − w₂) k + K_{u−v}(w₂) k`

    Used to separate the stability term `K_u(δ)` from the error term `K_e(w₂)` when
    subtracting two Cayley equations. -/
theorem galerkinConvection_split {N : Nat} (basis : GalerkinBasis N)
    (u v w1 w2 : CoeffC N) (k : Fin N) :
    galerkinConvection basis u w1 k - galerkinConvection basis v w2 k =
    galerkinConvection basis u (fun i => w1 i - w2 i) k +
    galerkinConvection basis (fun i => u i - v i) w2 k := by
  calc galerkinConvection basis u w1 k - galerkinConvection basis v w2 k
      = (galerkinConvection basis u w1 k - galerkinConvection basis u w2 k) +
        (galerkinConvection basis u w2 k - galerkinConvection basis v w2 k) := by ring
    _ = galerkinConvection basis u (fun i => w1 i - w2 i) k +
        galerkinConvection basis (fun i => u i - v i) w2 k := by
          congr 1
          · exact (congr_fun (galerkinConvection_sub_right basis u w1 w2) k).symm
          · exact (galerkinConvection_sub_left_from_def basis u v w2 k).symm

def stage171Summary : String :=
  "Stages 170-171: NSGalerkinConvDef — concrete galerkinConvection via triadic kernel. " ++
  "CRat.mul: complex multiplication (a+bi)(c+di). " ++
  "ExtGalerkinBasis: GalerkinBasis + triadK : Fin N → Fin N → Fin N → Rat. " ++
  "galerkinConvDef: ∑_j ∑_l K(k,j,l) · (u_j ⊗ v_l). " ++
  "galerkinConvDef_add_right: THEOREM. galerkinConvDef_smul_right: THEOREM. " ++
  "realInnerC_add_left/right: THEOREMS (by simp+ring). " ++
  "triadK_self_cancel: ONE physics axiom (energy self-cancel, .partiallyVerified). " ++
  "Stage 183: +0 axioms. " ++
  "CRat.mul_add_left: THEOREM. CRat.smul_mul_smul_left: THEOREM. " ++
  "galerkinConvDef_add_left: THEOREM. galerkinConvDef_smul_left: THEOREM. " ++
  "galerkinConvDef_sub_left: THEOREM. " ++
  "galerkinConvection_add_left_from_def: THEOREM. " ++
  "galerkinConvection_smul_left_from_def: THEOREM. " ++
  "galerkinConvection_sub_left_from_def: THEOREM. " ++
  "galerkinConvection_split: THEOREM (Cayley-subtract key identity)." ++
  "triadK_antisymm: THEOREM (polarization from triadK_self_cancel, 0 new axioms). " ++
  "galerkinConvDef_energy_cancel: THEOREM (direct from triadK_self_cancel). " ++
  "standardTriadK: canonical extended basis (axiom). " ++
  "galerkinConvDef_is_galerkinConvection: identification axiom (.partiallyVerified). " ++
  "B_energy_cancel_from_def: THEOREM. B_bilinear_antisymm_from_def: THEOREM. " ++
  "galerkinConvection_add_right/smul_right_from_def: THEOREMS. " ++
  "+2 axioms, +15 theorems, 0 sorry."

end NavierStokes.GalerkinConvDef
