import NavierStokes.Bridges.NSPalinstrophyTauBridge

/-!
# Stage 161A — `NSFieldGalerkin`: Band-Limited Fourier Field

A Galerkin field carries its own frequency cutoff proof as a struct field,
so that `palinstrophyF ≤ kmax · enstrophyF` is a **theorem with 0 axioms**.

This is the key object for the Galerkin-semantics ObsLand certificate
(`NSObsLandGalerkinCertificate`), where `interpretAsFourier` is the identity
coercion and the `.openBridge` freq-bound blocker disappears.

## Net counts

  - New axioms:   0
  - New theorems: 1
  - sorry:        0
  - warnings:     0
-/

namespace NavierStokes.GalerkinModel

set_option autoImplicit false

open NavierStokes.Millennium
open NavierStokes.FourierModel
open NavierStokes.PalinstrophyTauBridge   -- galerkinN, kmax

/-! ## The Galerkin field type -/

/-- A band-limited Fourier field: Fourier data with a built-in frequency cutoff.

    Every mode wavenumber is ≤ galerkinN = 1024 **by construction** (struct field
    `freq_le`).  This is the key difference from `NSFieldFourier`, where the freq
    bound is an external axiom (`interpretAsFourier_freq_le_galerkinN`).

    For the Galerkin-semantics ObsLand certificate, `interpretAsFourier` is the
    trivial coercion `toFourier`, and the freq bound is proved from `freq_le`. -/
structure NSFieldGalerkin where
  N       : Nat
  freq    : Fin N → Nat
  amp     : Fin N → Rat
  freq_le : ∀ i : Fin N, freq i ≤ galerkinN

/-- Forget the cutoff proof: every Galerkin field is a Fourier field. -/
def NSFieldGalerkin.toFourier (v : NSFieldGalerkin) : NSFieldFourier :=
  { N := v.N, freq := v.freq, amp := v.amp }

instance : Coe NSFieldGalerkin NSFieldFourier := ⟨NSFieldGalerkin.toFourier⟩

/-! ## Key theorem: palinstrophy bound (0 axioms) -/

/-- `palinstrophyF(v) ≤ kmax · enstrophyF(v)` for any Galerkin field `v`.

    Proof: mode-by-mode.  For each mode `i`, `freq i ≤ galerkinN` (from `v.freq_le i`),
    so `freq i² ≤ galerkinN² = kmax`, giving `freq i⁴ · amp i² ≤ kmax · freq i² · amp i²`.
    Sum over all modes.

    **This replaces `interpretAsFourier_freq_le_galerkinN`** (the sole `.openBridge`
    blocker on the Obs-land critical path) with a provable theorem: the bound now
    follows from the struct field, not an axiom. -/
theorem palinstrophyF_le_kmax_enstrophyF_galerkin (v : NSFieldGalerkin) :
    palinstrophyF v.toFourier ≤ kmax * enstrophyF v.toFourier := by
  unfold palinstrophyF enstrophyF
  rw [Finset.mul_sum]
  apply Finset.sum_le_sum
  intro i _
  calc (v.toFourier.freq i : Rat) ^ 4 * v.toFourier.amp i ^ 2
      = (v.toFourier.freq i : Rat) ^ 2 *
          ((v.toFourier.freq i : Rat) ^ 2 * v.toFourier.amp i ^ 2) := by ring
    _ ≤ kmax * ((v.toFourier.freq i : Rat) ^ 2 * v.toFourier.amp i ^ 2) := by
          apply mul_le_mul_of_nonneg_right _ (mul_nonneg (sq_nonneg _) (sq_nonneg _))
          -- v.toFourier.freq i = v.freq i definitionally; v.freq_le i : v.freq i ≤ galerkinN
          have hle  : v.toFourier.freq i ≤ galerkinN := v.freq_le i
          have hleR : (v.toFourier.freq i : Rat) ≤ (galerkinN : Rat) := by exact_mod_cast hle
          unfold kmax
          exact pow_le_pow_left₀ (Nat.cast_nonneg _) hleR 2

def stage161AFieldSummary : String :=
  "Stage 161A: NSFieldGalerkin — band-limited Fourier field, freq_le : ∀ i, freq i ≤ galerkinN. " ++
  "palinstrophyF_le_kmax_enstrophyF_galerkin: 0-axiom theorem (struct field replaces axiom). " ++
  "+0 axioms, +1 theorem, 0 sorry."

end NavierStokes.GalerkinModel
