import NavierStokes.NSFieldFourierComplex

/-!
# NSGalerkinPhysicalTriadKernel

Physical triadic interaction kernel for T³ Galerkin truncation.

This file provides `physicalTriadKCoeff` — a concrete `noncomputable def` giving
the Leray-projected scalar triadic coefficient for T³ Galerkin NS.

## Stage 294: axiom → def

`physicalTriadKCoeff` was previously an opaque axiom.  Stage 294 replaces it with
an explicit formula based on the Leray projection scalar and the T³ resonance
condition.

## The formula

For an N-mode Galerkin system with wave vectors `wvec : Fin N → WaveVec`:

  ```
  physicalTriadKCoeff wvec k j l =
    dot(wvec k, wvec j) / |wvec k|²    if wvec k = wvec j + wvec l
    0                                   otherwise
  ```

where `dot` is the integer dot product and `|·|²` is `waveVecMag2` (Rat-valued).

The resonance condition `wvec k = wvec j + wvec l` is the T³ Fourier convolution
law: modes interact only when their wave vectors satisfy `k = j + l` in ℤ³.
The factor `dot(k,j) / |k|²` is the scalar Leray component encoding the
divergence-free projection `P(k) = Id − k⊗k/|k|²`.

When `|wvec k|² = 0` (only the zero mode), `Rat` division returns `0` by the
field convention `a / 0 = 0`, matching the NS convention that the mean-flow mode
has zero interaction coefficient.

## What Stage 294 discharges

- **Off-resonance vanishing** (SA-VS1, `galerkin_triadic_resonance_support` in
  `NSTriadicSignLocalityBridge`): now a **theorem** by definition — immediate from
  the `else 0` branch.

## What remains axiomatic

- **`triadK_self_cancel`**: Energy cancellation `∑ Re(v·B(u,v)) = 0` requires
  the full 3D incompressible vector structure (`k · û_k = 0`), which is not
  derivable from this scalar formula alone.  The scalar formula is NOT
  antisymmetric under `j ↔ l` for fixed `k` — the full vector structure is needed.

- **`physicalTriadKCoeff_vs_le_nuP`** (SA-VS2): The Agmon–Sobolev bound
  VS_N ≤ νP_N requires T³ Sobolev interpolation (Temam 1984 §II.3), not yet
  available in Mathlib4.

## Net counts (Stage 294)

  - Axioms eliminated: 1  (physicalTriadKCoeff — replaced by def)
  - New defs:          2  (waveVecDot, physicalTriadKCoeff)
  - New theorems:      2  (physicalTriadKCoeff_off_resonance, physicalTriadKCoeff_resonant)
  - sorry:             0
  - warnings:          0

Reference: Temam 1984 §II.1, Constantin–Foias 1988 §2.
-/

namespace NavierStokes.GalerkinPhysicalTriadKernel

set_option autoImplicit false

open NavierStokes.GalerkinComplexModel

/-! ## Integer dot product on ℤ³ -/

/-- Integer dot product `k · j = k₁j₁ + k₂j₂ + k₃j₃` for wave vectors in ℤ³.

    All components are `Int`; result is `Int`.  Casts cleanly to `Rat`. -/
def waveVecDot (k j : WaveVec) : Int :=
  k.1 * j.1 + k.2.1 * j.2.1 + k.2.2 * j.2.2

/-! ## Concrete Leray-projected triadic coefficient -/

/-- The physical triadic interaction kernel for T³ Galerkin truncation.

    **Stage 294**: Promoted from `.partiallyVerified` axiom to `noncomputable def`.

    For an N-mode system with wave vectors `wvec : Fin N → WaveVec`:

    - If `wvec k ≠ wvec j + wvec l` (off-resonance): returns `0`.
    - If `wvec k = wvec j + wvec l` (T³ resonance):
        returns `dot(wvec k, wvec j) / |wvec k|²`

    where `dot` is `waveVecDot` and `|·|²` is `waveVecMag2`.

    This is the scalar Leray projection factor: the `(k,j)` component of
    `P(k) = Id − k⊗k/|k|²`, the Helmholtz projector onto divergence-free modes.

    **Off-resonance vanishing** (SA-VS1) is a **theorem** by construction — the
    `else 0` branch makes `physicalTriadKCoeff_off_resonance` a definitional fact.

    **Energy cancellation** (`triadK_self_cancel`) is NOT derivable from this
    formula alone — it requires the divergence-free constraint `k · û_k = 0`
    which is part of the 3D vector structure, not captured in the scalar model.

    Reference: Temam 1984 §II.1, Constantin–Foias 1988 §2. -/
noncomputable def physicalTriadKCoeff {N : Nat} (wvec : Fin N → WaveVec) :
    Fin N → Fin N → Fin N → Rat :=
  fun k j l =>
    if wvec k = wvec j + wvec l then
      (waveVecDot (wvec k) (wvec j) : Rat) / waveVecMag2 (wvec k)
    else 0

/-! ## Basic properties (theorems from the definition) -/

/-- **Off-resonance vanishing** (SA-VS1 as theorem):
    If `wvec k ≠ wvec j + wvec l`, the coefficient is `0`.

    This is the T³ resonance support condition: modes can only interact when
    their wave vectors satisfy the Fourier convolution law `k = j + l` in ℤ³.

    Proof: immediate from the `else 0` branch of the definition. -/
theorem physicalTriadKCoeff_off_resonance
    {N : Nat} (wvec : Fin N → WaveVec) (k j l : Fin N)
    (h : wvec k ≠ wvec j + wvec l) :
    physicalTriadKCoeff wvec k j l = 0 := by
  unfold physicalTriadKCoeff
  exact if_neg h

/-- **On-resonance formula**:
    If `wvec k = wvec j + wvec l`, the coefficient is
    `dot(wvec k, wvec j) / |wvec k|²`. -/
theorem physicalTriadKCoeff_resonant
    {N : Nat} (wvec : Fin N → WaveVec) (k j l : Fin N)
    (h : wvec k = wvec j + wvec l) :
    physicalTriadKCoeff wvec k j l =
    (waveVecDot (wvec k) (wvec j) : Rat) / waveVecMag2 (wvec k) := by
  unfold physicalTriadKCoeff
  exact if_pos h

def stage294Summary : String :=
  "Stage 294: NSGalerkinPhysicalTriadKernel — physicalTriadKCoeff: axiom → def. " ++
  "waveVecDot: k·j = k₁j₁+k₂j₂+k₃j₃ (Int-valued, def). " ++
  "physicalTriadKCoeff: dot(k,j)/|k|² if resonant, 0 otherwise (noncomputable def). " ++
  "physicalTriadKCoeff_off_resonance: wvec k ≠ j+l → coeff = 0 (THEOREM, if_neg). " ++
  "physicalTriadKCoeff_resonant: wvec k = j+l → coeff = dot/mag² (THEOREM, if_pos). " ++
  "SA-VS1 (galerkin_triadic_resonance_support) now THEOREM in NSTriadicSignLocalityBridge. " ++
  "triadK_self_cancel + physicalTriadKCoeff_vs_le_nuP: remain axioms (need 3D vector structure). " ++
  "-1 axiom (physicalTriadKCoeff), +2 defs, +2 theorems, 0 sorry."

end NavierStokes.GalerkinPhysicalTriadKernel
