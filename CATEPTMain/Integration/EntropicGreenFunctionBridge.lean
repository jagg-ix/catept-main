import NavierStokesClean.CATEPT.CFLClockEntropicBridge
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Data.Complex.Basic

/-!
# Entropic Green-Function Bridge (Phase 1) — Clock Reparameterization at the Resolvent Layer

Phase-1 ship: the **operator-theoretic** companion to the catept
no-renormalization chain.  The Laplace-transform / Green-function
machinery already in `LaplaceTransformBridge` is here re-read through
the entropic clock `dτ = λ dt` from `CFLClockEntropicBridge`.

## Architectural seam

```text
geometric semigroup / resolvent          ← LaplaceTransformBridge
        ↓ clock map dτ = λ dt              ← CFLClockEntropicBridge.dtauFromDt
entropic semigroup / resolvent           ← THIS MODULE
        ↓ S_I/ℏ = τ_ent                    ← ComplexWeightNormEntropicDamping (Phase 12)
entropic damping kernel exp(-τ_ent)      ← MeasurePathIntegralModel.damping
        ↓
counterterm-free / convergence            ← PhysicalUVConvergenceCertificate
                                          ← RigorousComplexFeynmanKac
                                          ← HigherDegreeT3TailSharp
```

Prior modules covered the path-integral kernel side; this fills in the
**operator-theoretic** rung between the geometric resolvent and the
entropic damping.

## What is honestly proven

* `entropicTimeOfGeometric_eq_dtau` — `lam * t = dtauFromDt t lam`
  (definitional identity tying this module to `CFLClockEntropicBridge`).

* `entropic_laplace_weight_const_rate` (real) and
  `entropic_complex_laplace_weight_const_rate` (complex):
  the constant-rate clock reparameterization
  `exp(-(s · (lam · t))) = exp(-((s · lam) · t))`
  shifts the rate parameter without changing the weight.  This is the
  algebraic identity at the heart of the resolvent-scaling formula
  `R_τ(s) = lam · R_t(lam · s)`.

* `EntropicResolventScaling` (structure):
  abstract carrier packaging a scalar rate `lam > 0`, a geometric
  resolvent `Rt : ℝ → ℝ`, an entropic resolvent `Rτ : ℝ → ℝ`, and the
  scaling identity `Rτ(s) = lam · Rt(lam · s)`.

* `entropicResolventScaling_exists`: structural existence — for any
  geometric resolvent `Rt` and rate `lam > 0`, the canonical entropic
  resolvent `s ↦ lam · Rt(lam · s)` populates the scaling carrier.

## Honest scope

* **Constant-rate (`lam` constant)** only.  State-dependent rates yield
  a non-autonomous propagator (time-ordered exponential of `A/lam(τ)`)
  that requires substantially more infrastructure (Mathlib does not
  provide this directly); deferred to Phase 2.

* **Algebraic identity** only.  Connecting the abstract `Rt`/`Rτ` here
  to the actual semigroup resolvent `(sI - A)⁻¹` of a concrete operator
  `A` requires the operator-theoretic infrastructure already framed in
  `LaplaceTransformBridge`; that wiring is also a Phase-2 task.

* **No new physical content.**  This module is the structural seam that
  exposes the rate-reparameterization at the resolvent layer; the
  physical content sits in `CFLClockEntropicBridge` (clock identity)
  and `LaplaceTransformBridge` (Stokes resolvent).

## Naming note

We use `lam` not `λ` for the rate parameter because `λ` is a Lean 4
keyword (lambda binder).  Convention matches `CFLClockEntropicBridge`.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.EntropicGreenFunctionBridge

open NavierStokesClean.CATEPT.CFLClock (dtauFromDt)

-- ═══════════════════════════════════════════════════════════════════════
-- Clock identity (tie to CFLClockEntropicBridge)
-- ═══════════════════════════════════════════════════════════════════════

/-- The clock-mapped time `lam · t` is exactly the existing
`NavierStokesClean.CATEPT.CFLClock.dtauFromDt t lam`.  This identity
ensures the rate-reparameterization here re-uses (rather than
duplicates) the catept clock layer. -/
theorem entropicTimeOfGeometric_eq_dtau (lam t : ℝ) :
    lam * t = dtauFromDt t lam := by
  unfold NavierStokesClean.CATEPT.CFLClock.dtauFromDt
  ring

-- ═══════════════════════════════════════════════════════════════════════
-- Constant-rate Laplace reparameterization (real and complex)
-- ═══════════════════════════════════════════════════════════════════════

/-- **Constant-rate Laplace reparameterization (real).**  Shifting the
rate `lam` from the time argument to the conjugate variable `s`
preserves the exponential weight:

  `exp(−(s · (lam · t))) = exp(−((s · lam) · t))`.

This is the algebraic identity at the heart of the resolvent-scaling
formula `R_τ(s) = lam · R_t(lam · s)`. -/
theorem entropic_laplace_weight_const_rate (s lam t : ℝ) :
    Real.exp (-(s * (lam * t))) = Real.exp (-((s * lam) * t)) := by
  congr 1
  ring

/-- **Constant-rate Laplace reparameterization (complex).**  Same
identity in `ℂ`, suitable for direct linkage to the complex
Feynman–Kac weight `exp(i S_R/ℏ − S_I/ℏ)` of
`MeasurePathIntegralModel`. -/
theorem entropic_complex_laplace_weight_const_rate (s lam t : ℂ) :
    Complex.exp (-(s * (lam * t))) = Complex.exp (-((s * lam) * t)) := by
  congr 1
  ring

-- ═══════════════════════════════════════════════════════════════════════
-- Abstract resolvent-scaling carrier
-- ═══════════════════════════════════════════════════════════════════════

/-- **Abstract resolvent-scaling carrier.**  Packages:
  - a positive rate `lam`,
  - a geometric resolvent `Rt : ℝ → ℝ`,
  - an entropic resolvent `Rτ : ℝ → ℝ`,
  - and the scaling identity `Rτ(s) = lam · Rt(lam · s)`.

Concrete instances arise from any operator-resolvent pair where the
clock is reparameterised via `dτ = lam · dt`.  At the abstract level,
the carrier is just the algebraic shape; semigroup / operator content
is supplied by downstream consumers. -/
structure EntropicResolventScaling where
  /-- Positive entropic-clock rate (`dτ/dt = lam`). -/
  lam : ℝ
  /-- Positivity. -/
  lam_pos : 0 < lam
  /-- Geometric resolvent (e.g. `s ↦ (sI − A)⁻¹` evaluated at some seed). -/
  Rt : ℝ → ℝ
  /-- Entropic resolvent (e.g. `s ↦ (sI − A/lam)⁻¹` evaluated). -/
  Rτ : ℝ → ℝ
  /-- The clock-reparameterization scaling identity. -/
  scaling : ∀ s, Rτ s = lam * Rt (lam * s)

namespace EntropicResolventScaling

/-- The rate-reparameterized weight is preserved (corollary of
`entropic_laplace_weight_const_rate` evaluated against the carrier's
rate). -/
theorem laplace_weight_const_rate (S : EntropicResolventScaling) (s t : ℝ) :
    Real.exp (-(s * (S.lam * t))) = Real.exp (-((s * S.lam) * t)) :=
  entropic_laplace_weight_const_rate s S.lam t

end EntropicResolventScaling

-- ═══════════════════════════════════════════════════════════════════════
-- Structural existence
-- ═══════════════════════════════════════════════════════════════════════

/-- **Structural existence.**  Given any geometric resolvent
`Rt : ℝ → ℝ` and any positive rate `lam > 0`, the canonical entropic
resolvent `s ↦ lam · Rt(lam · s)` populates the
`EntropicResolventScaling` carrier with the prescribed `Rt` and `lam`. -/
theorem entropicResolventScaling_exists
    (Rt : ℝ → ℝ) (lam : ℝ) (hlam : 0 < lam) :
    ∃ S : EntropicResolventScaling,
      S.Rt = Rt ∧ S.lam = lam :=
  ⟨{ lam := lam
   , lam_pos := hlam
   , Rt := Rt
   , Rτ := fun s => lam * Rt (lam * s)
   , scaling := fun _ => rfl }, rfl, rfl⟩

-- ═══════════════════════════════════════════════════════════════════════
-- Direct concrete instance
-- ═══════════════════════════════════════════════════════════════════════

/-- The canonical entropic resolvent built from a geometric resolvent
and a positive rate, made directly available as a definition. -/
def ofGeometricResolvent (Rt : ℝ → ℝ) (lam : ℝ) (hlam : 0 < lam) :
    EntropicResolventScaling where
  lam := lam
  lam_pos := hlam
  Rt := Rt
  Rτ := fun s => lam * Rt (lam * s)
  scaling := fun _ => rfl

@[simp] theorem ofGeometricResolvent_lam (Rt : ℝ → ℝ) (lam : ℝ) (hlam : 0 < lam) :
    (ofGeometricResolvent Rt lam hlam).lam = lam := rfl

@[simp] theorem ofGeometricResolvent_Rt (Rt : ℝ → ℝ) (lam : ℝ) (hlam : 0 < lam) :
    (ofGeometricResolvent Rt lam hlam).Rt = Rt := rfl

@[simp] theorem ofGeometricResolvent_Rτ (Rt : ℝ → ℝ) (lam : ℝ) (hlam : 0 < lam)
    (s : ℝ) :
    (ofGeometricResolvent Rt lam hlam).Rτ s = lam * Rt (lam * s) := rfl

-- ═══════════════════════════════════════════════════════════════════════
-- Phase-2 demo: the zero-operator resolvent is rate-invariant
-- ═══════════════════════════════════════════════════════════════════════

/-- **Zero-operator resolvent is rate-invariant.**  For the trivial
geometric resolvent `R_t(s) = 1/s` (which is `(sI − 0)⁻¹`, the resolvent
of the zero operator), the entropic-clock-reparameterized resolvent
satisfies

  `R_τ(s) = lam · R_t(lam · s) = lam · 1/(lam · s) = 1/s`.

The clock factor cancels: with no dynamics to reparameterise (zero
operator), the entropic and geometric resolvents coincide.

This is the simplest non-trivial Phase-2 instance of
`EntropicResolventScaling`, obtained by plugging the constant-seed
geometric resolvent into `ofGeometricResolvent`.  It demonstrates that
the abstract carrier admits at least one concrete reading where the
scaling identity reduces to a familiar special case. -/
theorem entropicResolventScaling_zero_operator
    (lam : ℝ) (hlam : 0 < lam) (s : ℝ) (hs : s ≠ 0) :
    (ofGeometricResolvent (fun u => 1 / u) lam hlam).Rτ s = 1 / s := by
  simp only [ofGeometricResolvent_Rτ]
  field_simp

end CATEPTMain.Integration.EntropicGreenFunctionBridge
