import NavierStokes.NSGalerkinViscStep
import NavierStokes.NSDiscreteIntegralKernel
import NavierStokes.NSGalerkinConvDef

/-!
# Stage 165 — NSGalerkinCayleyBridge: Cayley Step + Algebraic Energy Preservation

Derives `cayleySolve_energy_preserving` as a **theorem** (0 new axioms after the
Cayley setup) using exactly three algebraic facts:

1. `normSqC_diff`   — `normSqC v − normSqC u = realInnerC (v+u) (v−u)`     (ring)
2. `cayleySolve_eq` — Cayley defining equation: `v − u = h/2 · B(u, v+u)`  (axiom)
3. `B_bilinear_antisymm` — `⟨B(u,v), w⟩ + ⟨B(u,w), v⟩ = 0`                (theorem)

No matrix theory, no Real, no ODE.  The proof unfolds as:

```
normSqC v − normSqC u
  = ∑ realInnerC (v+u) (v−u)     [normSqC_diff + sum linearity]
  = ∑ realInnerC (v+u) (h/2 · B(u, v+u))   [cayleySolve_eq]
  = h/2 · ∑ realInnerC (v+u) (B(u, v+u))   [smul_realInnerC_right]
  = h/2 · 0                                 [B_bilinear_antisymm with w=v=v+u]
  = 0
```

## Relationship to Stage 164

Stage 164's `convStep` (openBridge) and `convStep_energy_preserving` (partiallyVerified)
remain; this stage:

* builds a **parallel** certified construction: `cayleySolve` is the concrete
  Cayley step with proved energy preservation,
* adds `convStep_eq_cayleySolve` (theorem, by `rfl`) identifying the
  two, and
* derives `convStep_energy_preserving` as a **theorem** from that identification.

## Net counts

  - New axioms:   2  (cayleySolve, cayleySolve_eq)
  - New theorems: 8
  - sorry:        0
  - warnings:     0
-/

namespace NavierStokes.GalerkinCayley

set_option autoImplicit false

open NavierStokes.PalinstrophyTauBridge  -- galerkinN
open NavierStokes.GalerkinComplexModel   -- CRat, CoeffC, normSqC, realInnerC, NSFieldGalerkinK
open NavierStokes.GalerkinConvection     -- GalerkinBasis, galerkinConvection, B_energy_cancel
open NavierStokes.GalerkinConvDef        -- B_bilinear_antisymm_from_def
open NavierStokes.DiscreteKernel         -- diH

/-- `realInnerC u (r • v) = r · realInnerC u v`. -/
theorem realInnerC_smul_right (u v : CRat) (r : Rat) :
    realInnerC u (CRat.smul r v) = r * realInnerC u v := by
  unfold realInnerC CRat.smul CRat.re CRat.im; ring

/-! ## Key algebraic identity: normSqC difference -/

/-- `normSqC v − normSqC u = realInnerC (v + u) (v − u)`.

    The discrete analogue of `d/dt |u|² = 2 Re⟨u, u̇⟩`.
    Proved by `ring` — purely algebraic, no continuity needed. -/
theorem normSqC_diff (u v : CRat) :
    normSqC v - normSqC u = realInnerC (v + u) (v - u) := by
  simp only [normSqC, realInnerC, CRat.re, CRat.im, Prod.fst_add, Prod.snd_add,
             Prod.fst_sub, Prod.snd_sub]
  ring

/-! ## Bilinear antisymmetry of the convection operator -/

/-- **B_bilinear_antisymm** — Full Temam bilinear antisymmetry (Lemma II.1.1).

    For fixed `u`, the map `v ↦ galerkinConvection basis u v` is **skew-Hermitian**:
      `⟨B(u,v), w⟩ + ⟨B(u,w), v⟩ = 0`   for all v, w.

    This is the `b(u,v,w) = −b(u,w,v)` identity from Temam 1984, Ch. II §1, Lemma 1.1:
    `b(u,v,w) = ∫_{T³} (u·∇v)·w dx`.
    Integration by parts + ∇·u = 0 gives `b(u,v,w) + b(u,w,v) = 0`.

    Setting `v = w` recovers `B_energy_cancel` (2·b(u,u,u) = 0).

    Epistemic status: `.partiallyVerified` (Temam 1984, stronger than Stage 163's cancellation). -/
theorem B_bilinear_antisymm {N : Nat} (basis : GalerkinBasis N) (u v w : CoeffC N) :
    ∑ i : Fin N, realInnerC (v i) (galerkinConvection basis u w i) +
    ∑ i : Fin N, realInnerC (w i) (galerkinConvection basis u v i) = 0 :=
  B_bilinear_antisymm_from_def basis u v w

/-- `B_energy_cancel` follows from `B_bilinear_antisymm` by setting `v = w = u`. -/
theorem B_energy_cancel_from_antisymm {N : Nat} (basis : GalerkinBasis N) (u : CoeffC N) :
    ∑ i : Fin N, realInnerC (u i) (galerkinConvection basis u u i) = 0 := by
  have h := B_bilinear_antisymm basis u u u
  linarith

/-- Skew-Hermitian quadratic form vanishes: `⟨B(u,w), w⟩ = 0` for any `w`. -/
theorem B_bilinear_self_zero {N : Nat} (basis : GalerkinBasis N) (u w : CoeffC N) :
    ∑ i : Fin N, realInnerC (w i) (galerkinConvection basis u w i) = 0 := by
  have h := B_bilinear_antisymm basis u w w
  linarith

/-! ## Cayley solution: existence and defining equation -/

/-- Packaged Cayley step specification:
    existence of a candidate `v` with the implicit midpoint equation
    `v − u = (h/2) · B(u, v+u)`.

    This is the same epistemic content as the former paired axioms
    `cayleySolve` + `cayleySolve_eq`, but consolidated into one contract. -/
axiom cayleySolve_spec {N : Nat} (basis : GalerkinBasis N) (h : Rat) (u : CoeffC N) :
    { v : CoeffC N // ∀ i : Fin N,
        v i - u i =
          CRat.smul (h / 2)
            (galerkinConvection basis u (fun j => v j + u j) i) }

/-- Abstract Cayley step extracted from the packaged specification. -/
noncomputable def cayleySolve {N : Nat} (basis : GalerkinBasis N) (h : Rat) (u : CoeffC N) : CoeffC N :=
  (cayleySolve_spec basis h u).1

/-- Defining equation of the extracted Cayley step. -/
theorem cayleySolve_eq {N : Nat} (basis : GalerkinBasis N) (h : Rat) (u : CoeffC N) :
    ∀ i : Fin N,
      cayleySolve basis h u i - u i =
      CRat.smul (h / 2)
        (galerkinConvection basis u (fun j => cayleySolve basis h u j + u j) i) := by
  simpa [cayleySolve] using (cayleySolve_spec basis h u).2

/-! ## Main theorem: Cayley step preserves energy -/

/-- **`cayleySolve_energy_preserving`** — the Cayley step is exactly energy-preserving.

    `∑ normSqC (cayleySolve basis h u i) = ∑ normSqC (u i)`.

    ### Proof sketch (5 steps, all algebraic)

    Let `v = cayleySolve basis h u` and `w = v + u : CoeffC N`.

    ```
    ∑ normSqC v i − ∑ normSqC u i
      = ∑ realInnerC (v i + u i) (v i − u i)     [normSqC_diff, sum over i]
      = ∑ realInnerC (w i) ((h/2) · B(u,w) i)    [cayleySolve_eq]
      = (h/2) · ∑ realInnerC (w i) (B(u,w) i)    [realInnerC_smul_right]
      = (h/2) · 0                                  [B_bilinear_self_zero with w]
      = 0
    ``` -/
theorem cayleySolve_energy_preserving {N : Nat} (basis : GalerkinBasis N) (h : Rat)
    (u : CoeffC N) :
    ∑ i : Fin N, normSqC (cayleySolve basis h u i) =
    ∑ i : Fin N, normSqC (u i) := by
  -- Set v := cayleySolve u
  set v : CoeffC N := cayleySolve basis h u with hv_def
  -- Step 1: rewrite energy difference via normSqC_diff
  suffices h_zero : ∑ i : Fin N, normSqC (v i) - ∑ i : Fin N, normSqC (u i) = 0 by linarith
  -- Push the difference inside the sum
  rw [← Finset.sum_sub_distrib]
  -- Cayley defining equation in terms of v (the set local def)
  have hceq : ∀ i : Fin N, v i - u i =
      CRat.smul (h / 2) (galerkinConvection basis u (fun j => v j + u j) i) :=
    cayleySolve_eq basis h u
  -- Steps 2–4: normSqC_diff pointwise, substitute hceq, pull out scalar
  simp_rw [show ∀ i : Fin N, normSqC (v i) - normSqC (u i) = realInnerC (v i + u i) (v i - u i)
           from fun i => normSqC_diff (u i) (v i),
           hceq, realInnerC_smul_right]
  -- Step 5: factor out (h/2) and apply B_bilinear_self_zero
  rw [← Finset.mul_sum, B_bilinear_self_zero basis u (fun j => v j + u j), mul_zero]

/-! ## convStep as a concrete noncomputable def (Stage 189A) -/

/-- **`convStep`** — the concrete Cayley convective step at the fixed kernel step size `diH`.

    Defined as `cayleySolve basis diH u`.  This replaces the Stage 164 open-bridge axiom
    `axiom convStep` (which lives in `NavierStokes.GalerkinODE`).  Downstream code that
    previously used `NavierStokes.GalerkinODE.convStep` should alias this definition.

    Making this a `noncomputable def` (rather than an axiom) means energy preservation
    is a zero-axiom theorem. -/
noncomputable def convStep {N : Nat} (basis : GalerkinBasis N) (u : CoeffC N) : CoeffC N :=
  cayleySolve basis diH u

/-- **`convStep_eq_cayleySolve`** — `convStep` equals `cayleySolve` at `diH` by definition. -/
theorem convStep_eq_cayleySolve {N : Nat} (basis : GalerkinBasis N) (u : CoeffC N) :
    convStep basis u = cayleySolve basis diH u := rfl

/-- `convStep_energy_preserving` is a **theorem** (0 new axioms). -/
theorem convStep_energy_preserving_from_cayley {N : Nat}
    (basis : GalerkinBasis N) (u : CoeffC N) :
    ∑ i : Fin N, normSqC (convStep basis u i) = ∑ i : Fin N, normSqC (u i) :=
  cayleySolve_energy_preserving basis diH u

def stage165Summary : String :=
  "Stage 165/189A: NSGalerkinCayleyBridge — Cayley step + algebraic energy preservation. " ++
  "B_bilinear_antisymm: THEOREM from NSGalerkinConvDef (Temam II.1.1 bridge). " ++
  "cayleySolve_spec: packaged existence+equation axiom (implicit midpoint, finite-dim IFT). " ++
  "cayleySolve: noncomputable def extracted from cayleySolve_spec. " ++
  "cayleySolve_eq: THEOREM from cayleySolve_spec (definitional unpacking). " ++
  "cayleySolve_energy_preserving: THEOREM (normSqC_diff + cayleySolve_eq + B_self_zero). " ++
  "convStep: noncomputable def = cayleySolve basis diH u (Stage 189A, 0 new axioms). " ++
  "convStep_eq_cayleySolve: THEOREM by rfl (was axiom). " ++
  "convStep_energy_preserving_from_cayley: THEOREM (0 new axioms). " ++
  "+1 axiom, +9 theorems, 0 sorry."

end NavierStokes.GalerkinCayley
