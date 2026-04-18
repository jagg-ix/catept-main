import NavierStokes.NSGalerkinConvectionInterface

/-!
# Stage 163 — NSGalerkinConvectionBridge: Trilinear B + Energy Cancellation

Introduces the Galerkin convection operator and its key energy identity.

## Three new items

1. **`galerkinConvection`** — abstract Galerkin-truncated bilinear operator
   `(basis : GalerkinBasis N) → CoeffC N → CoeffC N → CoeffC N`.
   Left abstract at the interface layer to avoid dependence on a concrete
   wavevector index map.

2. **`B_energy_cancel`** — the trilinear antisymmetry axiom:
   `∑ᵢ Re(ūᵢ · (B(u,u))ᵢ) = 0`.
   No hidden `rfl` hypothesis; `basis` is explicit.

3. **`GalerkinBasis N`** — now imported from `NSGalerkinConvectionCore`
   (shared across bridge and definitional modules).

## Derived energy balance

With the axioms in place, the *complete* kinetic energy rate decomposes as:

```
d/dt (½‖u‖²) = Re⟨B(u,u), u⟩ + Re⟨viscous, u⟩
             =       0         +  (−ν · enstrophyK)
             = −ν · enstrophyK
```

The first term vanishes by `B_energy_cancel`; the second is computed by
`viscous_energy_production` (a pure algebraic identity, 0 axioms).
`galerkin_energy_balance` assembles both into a single equality.

## Epistemic status

* `galerkinConvection` — `.openBridge` (concrete triadic sum not yet formalized)
* `B_energy_cancel`    — `.partiallyVerified` (Temam 1984, Ch. II §1, Lemma 1.1;
  follows from integration by parts + ∇·u = 0 on the torus)

## Net counts

  - New axioms:   1  (B_energy_cancel; `galerkinConvection` lives in interface)
  - New theorems: 4
  - sorry:        0
  - warnings:     0
-/

namespace NavierStokes.GalerkinConvection

set_option autoImplicit false

open NavierStokes.GalerkinComplexModel   -- CRat, WaveVec, CoeffC, normSqC, realInnerC,
                                         -- waveVecMag2, NSFieldGalerkinK, enstrophyK

/-! ## Algebraic lemma: realInnerC is linear in its second argument -/

/-- `Re(z̄·(w+w')) = Re(z̄·w) + Re(z̄·w')`.

    Used to split the energy rate into convective and viscous parts. -/
theorem realInnerC_add_right (z w w' : CRat) :
    realInnerC z (w + w') = realInnerC z w + realInnerC z w' := by
  simp only [realInnerC, CRat.re, CRat.im, Prod.fst_add, Prod.snd_add]
  ring

/-! ## Galerkin convection operator -/

-- `galerkinConvection` is provided by `NSGalerkinConvectionInterface`.

/-- **B_energy_cancel** — Trilinear energy antisymmetry (Temam 1984).

    For any N-mode Galerkin system `basis` and coefficient vector `u : CoeffC N`:

      ∑ᵢ Re(ūᵢ · (B(u,u))ᵢ) = 0

    Proof idea: define `b(u,v,w) := ∑ᵢ Re(ūᵢ · (B(u,v))ᵢ)`.  Then
      `b(u,u,u) = −b(u,u,u)`
    by skew-symmetry `b(u,v,w) = −b(u,w,v)` (integration by parts on T³ + ∇·u = 0),
    so `b(u,u,u) = 0`.

    Epistemic status: `.partiallyVerified` (Temam 1984, Ch. II §1, Lemma 1.1). -/
axiom B_energy_cancel {N : Nat} (basis : GalerkinBasis N) (u : CoeffC N) :
    ∑ i : Fin N, realInnerC (u i) (galerkinConvection basis u u i) = 0

/-! ## Viscous damping -/

/-- The viscous damping term for mode `i`: `−ν |k_i|² û_i`.

    In coefficient notation: `(−ν |k_i|² re_i,  −ν |k_i|² im_i)`.

    This is the exact Fourier-space representation of `−ν Δu` restricted to mode `i`. -/
def viscousDamping {N : Nat} (basis : GalerkinBasis N) (ν : Rat)
    (u : CoeffC N) (i : Fin N) : CRat :=
  (-ν * waveVecMag2 (basis.wvec i) * (u i).re,
   -ν * waveVecMag2 (basis.wvec i) * (u i).im)

/-- The viscous contribution to the energy rate:
    `∑ᵢ Re(ūᵢ · (−ν |k_i|² ûᵢ)) = −ν · ∑ᵢ |k_i|² |ûᵢ|² = −ν · enstrophyK`.

    Proved by pure algebra (ring) — zero new axioms. -/
theorem viscous_energy_production {N : Nat} (basis : GalerkinBasis N)
    (u : CoeffC N) (ν : Rat) :
    ∑ i : Fin N, realInnerC (u i) (viscousDamping basis ν u i) =
    -ν * ∑ i : Fin N, waveVecMag2 (basis.wvec i) * normSqC (u i) := by
  simp only [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro i _
  simp only [viscousDamping, realInnerC, normSqC, CRat.re, CRat.im]
  ring

/-! ## Energy balance -/

/-- **Galerkin energy balance** — the complete kinetic energy rate formula.

    For any basis, coefficient vector, and viscosity ν:

      ∑ᵢ Re(ūᵢ · ((B(u,u))ᵢ + (viscous)ᵢ)) = −ν · ∑ᵢ |k_i|² |ûᵢ|²

    Proof:
      LHS = (∑ Re(ūᵢ·Bᵢ)) + (∑ Re(ūᵢ·viscᵢ))   [by linearity]
          =        0         + (−ν · enstrophy)    [B_energy_cancel + viscous_energy_production]
          = −ν · enstrophy                          ∎ -/
theorem galerkin_energy_balance {N : Nat} (basis : GalerkinBasis N)
    (u : CoeffC N) (ν : Rat) :
    ∑ i : Fin N, realInnerC (u i)
        (galerkinConvection basis u u i + viscousDamping basis ν u i) =
    -ν * ∑ i : Fin N, waveVecMag2 (basis.wvec i) * normSqC (u i) := by
  -- Split the sum into convective + viscous parts
  trans (∑ i : Fin N, realInnerC (u i) (galerkinConvection basis u u i) +
         ∑ i : Fin N, realInnerC (u i) (viscousDamping basis ν u i))
  · simp_rw [realInnerC_add_right, Finset.sum_add_distrib]
  · rw [B_energy_cancel, zero_add]
    exact viscous_energy_production basis u ν

/-- Energy balance instantiated for a concrete `NSFieldGalerkinK`.

    The basis is extracted via `v.toBasis`; the enstrophy sum on the RHS
    unfolds definitionally to `enstrophyK v`. -/
theorem galerkin_field_energy_balance (v : NSFieldGalerkinK) (ν : Rat) :
    ∑ i : Fin v.N, realInnerC (v.coeff i)
        (galerkinConvection (NSFieldGalerkinK.toBasis v) v.coeff v.coeff i +
         viscousDamping (NSFieldGalerkinK.toBasis v) ν v.coeff i) =
    -ν * enstrophyK v :=
  galerkin_energy_balance (NSFieldGalerkinK.toBasis v) v.coeff ν

def stage163Summary : String :=
  "Stage 163: NSGalerkinConvectionBridge — GalerkinBasis N (wvec + freq_le), " ++
  "galerkinConvection (basis u v : CoeffC N) : CoeffC N (.openBridge, Temam triadic sum). " ++
  "B_energy_cancel: ∑ Re(ū·(B(u,u))) = 0 (.partiallyVerified, Temam 1984 Lemma II.1.1). " ++
  "viscousDamping + viscous_energy_production (0 axioms, ring). " ++
  "galerkin_energy_balance: ∑ Re(ū·(B+visc)) = -ν·enstrophyK (from B_cancel + visc). " ++
  "+2 axioms, +4 theorems, 0 sorry."

end NavierStokes.GalerkinConvection
