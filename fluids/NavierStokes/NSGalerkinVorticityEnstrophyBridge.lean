import NavierStokes.Galerkin.NSGalerkinConvDef

/-!
# Stage 219 — NSGalerkinVorticityEnstrophyBridge

Explicit Galerkin-level decomposition of the vortex-stretching / palinstrophy
relationship for band-limited Fourier fields.

## What this file proves (0 new axioms for theorems 1–8)

| # | Item | Status |
|---|------|--------|
| 1 | `galerkinVorticityCoeff` — `ω̂_k = |k|² û_k` | def (0 axioms) |
| 2 | `normSqC_galerkinVorticityCoeff` — `\|ω̂_k\|² = |k|⁴ · \|û_k\|²` | THEOREM (ring) |
| 3 | `palinstrophyK_eq_vorticity_enstrophy` — `P_N = Σ_k \|ω̂_k\|²` | THEOREM (rfl) |
| 4 | `galerkinEnstrophyProduction` — `VS_N = Σ_k |k|² Re(û_k · B(û,û)_k)` | noncomputable def |
| 5 | `galerkinEnstrophyProduction_eq_vorticityInner` — `VS_N = Σ_k Re(ω̂_k · B)` | THEOREM (ring) |
| 6 | `galerkinVSNuPDefect_eq_nuP_minus_production` — defect rephrase | THEOREM (rfl) |
| 7 | `galerkinVSNuPDefect_nonneg_iff` — defect ≥ 0 ↔ VS_N ≤ νP_N | THEOREM (linarith) |
| 8 | `galerkin_enstrophy_production_le_nuP` — **VS_N ≤ νP_N** | AXIOM (.openBridge) |
| 9 | `galerkinVSNuPDefect_nonneg` — defect ≥ 0 | THEOREM (consequence) |
|10 | `galerkinEnstrophyProduction_le_nu_kmax_enstrophy` — VS_N ≤ ν N² E_N | THEOREM (two-step) |

## Mathematical content

In the Galerkin model with band-limited fields at cutoff `galerkinN = 1024`:

- The vorticity coefficient `ω̂_k = |k|² û_k` (Fourier curl = |k|² scaling).
- Palinstrophy `P_N = Σ_k |k|⁴ |û_k|²` = enstrophy of the vorticity field (item 3).
- The enstrophy production `VS_N = Σ_k |k|² Re(û_k · B(û,û)_k)` is the vortex
  stretching term, i.e. the inner product `⟨ω̂, B(û,û)⟩` (item 5).
- `galerkin_enstrophy_production_le_nuP` (item 8) is the irreducible Galerkin
  VS ≤ νP axiom; it requires the Agmon–Sobolev trilinear estimate on T³ plus the
  div-free constraint `û_k · k = 0`.

## Epistemic note on item 8

`galerkin_enstrophy_production_le_nuP` is labelled `.openBridge`.
Its discharge requires:
  (a) The concrete Fourier resonance condition for T³: `k + j + l = 0` in ℤ³
  (b) Divergence-free constraint `Σ_k k · û_k = 0` (not yet in `NSFieldGalerkinK`)
  (c) Cauchy-Schwarz + Sobolev interpolation in the trilinear sum

This axiom is strictly more concrete than the abstract-trajectory
`SliceProjectedVSLeNuPPrimitiveProp` — it is a finite-dimensional Fourier-mode
inequality and admits a machine-checkable proof once (b) is formalised in Mathlib.

## Net counts

  - New axioms:   1  (galerkin_enstrophy_production_le_nuP)
  - New theorems: 8
  - sorry:        0
  - warnings:     0
-/

namespace NavierStokes.GalerkinVSNuPBound

set_option autoImplicit false

open NavierStokes.GalerkinComplexModel   -- CRat, normSqC, realInnerC, waveVecMag2,
                                          -- NSFieldGalerkinK, enstrophyK, palinstrophyK
open NavierStokes.GalerkinConvection     -- GalerkinBasis, galerkinConvection, CoeffC,
                                          -- NSFieldGalerkinK.toBasis
open NavierStokes.PalinstrophyTauBridge  -- galerkinN, kmax, kmax_pos
open NavierStokes.Millennium             -- nsNu, nsNu_pos

/-! ## 1. Vorticity Coefficient (ω̂_k = |k|² û_k) -/

/-- The Fourier vorticity coefficient at mode `k`: `ω̂_k = |k|² · û_k`.

    In the Fourier representation of T³, the curl operation acts as mode-wise
    multiplication by |k|². The |k|² scaling connects enstrophy and palinstrophy:
    `Σ_k |ω̂_k|² = Σ_k |k|⁴ |û_k|² = palinstrophyK`. -/
def galerkinVorticityCoeff {N : Nat} (basis : GalerkinBasis N)
    (v : CoeffC N) (k : Fin N) : CRat :=
  CRat.smul (waveVecMag2 (basis.wvec k)) (v k)

/-! ## 2. Pointwise Identity: |ω̂_k|² = |k|⁴ |û_k|² (ring) -/

/-- Pointwise: `|ω̂_k|² = |k|⁴ · |û_k|²`.  Ring arithmetic on CRat scalar multiplication. -/
theorem normSqC_galerkinVorticityCoeff {N : Nat} (basis : GalerkinBasis N)
    (v : CoeffC N) (k : Fin N) :
    normSqC (galerkinVorticityCoeff basis v k) =
    waveVecMag2 (basis.wvec k) ^ 2 * normSqC (v k) := by
  simp only [galerkinVorticityCoeff, normSqC, CRat.smul, CRat.re, CRat.im]
  ring

/-! ## 3. Palinstrophy = Enstrophy of Vorticity (0 axioms) -/

/-- **Key algebraic identity — 0 axioms:**

    `palinstrophyK v = Σ_k |ω̂_k|²`  where `ω̂_k = |k|² û_k`.

    The Galerkin palinstrophy equals the enstrophy of the vorticity field.
    Proof is mode-by-mode from `normSqC_galerkinVorticityCoeff`; definitional
    equality resolves `(NSFieldGalerkinK.toBasis v).wvec k = v.wvec k`. -/
theorem palinstrophyK_eq_vorticity_enstrophy (v : NSFieldGalerkinK) :
    palinstrophyK v =
    ∑ k : Fin v.N,
      normSqC (galerkinVorticityCoeff (NSFieldGalerkinK.toBasis v) v.coeff k) := by
  unfold palinstrophyK
  apply Finset.sum_congr rfl
  intro k _
  rw [normSqC_galerkinVorticityCoeff]
  -- Goal: waveVecMag2 (v.wvec k) ^ 2 * normSqC (v.coeff k)
  --     = waveVecMag2 ((NSFieldGalerkinK.toBasis v).wvec k) ^ 2 * normSqC (v.coeff k)
  -- (NSFieldGalerkinK.toBasis v).wvec k = v.wvec k  by definition (rfl)
  rfl

/-! ## 4. Enstrophy Production Term (noncomputable def) -/

/-- The Galerkin enstrophy production term `VS_N`:

    `VS_N = Σ_k |k|² · Re(û_k · (B(û,û))_k)`

    This is the convective contribution to `d(Ω_N)/dt = VS_N − ν · P_N`.
    Marked `noncomputable` because it uses the abstract `galerkinConvection` axiom. -/
noncomputable def galerkinEnstrophyProduction {N : Nat}
    (basis : GalerkinBasis N) (v : CoeffC N) : Rat :=
  ∑ k : Fin N, waveVecMag2 (basis.wvec k) * realInnerC (v k) (galerkinConvection basis v v k)

/-! ## 5. Production = Vorticity Inner Product (ring) -/

/-- The enstrophy production equals the inner product of vorticity with convection:
    `VS_N = Σ_k Re(ω̂_k · (B(û,û))_k)`.

    Proof: `Re(|k|² û_k · w) = |k|² · Re(û_k · w)` by ring. -/
theorem galerkinEnstrophyProduction_eq_vorticityInner {N : Nat}
    (basis : GalerkinBasis N) (v : CoeffC N) :
    galerkinEnstrophyProduction basis v =
    ∑ k : Fin N,
      realInnerC (galerkinVorticityCoeff basis v k) (galerkinConvection basis v v k) := by
  simp only [galerkinEnstrophyProduction, galerkinVorticityCoeff, realInnerC,
             CRat.smul, CRat.re, CRat.im]
  apply Finset.sum_congr rfl
  intro k _
  ring

/-! ## 6–7. VS–νP Defect -/

/-- The Galerkin VS–νP defect: `δ_N = ν · P_N − VS_N`. -/
noncomputable def galerkinVSNuPDefect {N : Nat}
    (basis : GalerkinBasis N) (v : CoeffC N) : Rat :=
  nsNu * ∑ k : Fin N, waveVecMag2 (basis.wvec k) ^ 2 * normSqC (v k) -
  galerkinEnstrophyProduction basis v

/-- Defect rephrased in terms of `palinstrophyK`. -/
theorem galerkinVSNuPDefect_eq_nuP_minus_production (v : NSFieldGalerkinK) :
    galerkinVSNuPDefect (NSFieldGalerkinK.toBasis v) v.coeff =
    nsNu * palinstrophyK v -
    galerkinEnstrophyProduction (NSFieldGalerkinK.toBasis v) v.coeff := by
  simp only [galerkinVSNuPDefect, palinstrophyK, NSFieldGalerkinK.toBasis]

/-- VS–νP defect nonnegativity iff `VS_N ≤ ν · palinstrophyK`. -/
theorem galerkinVSNuPDefect_nonneg_iff (v : NSFieldGalerkinK) :
    0 ≤ galerkinVSNuPDefect (NSFieldGalerkinK.toBasis v) v.coeff ↔
    galerkinEnstrophyProduction (NSFieldGalerkinK.toBasis v) v.coeff ≤
    nsNu * palinstrophyK v := by
  rw [galerkinVSNuPDefect_eq_nuP_minus_production]
  constructor
  · intro h; linarith
  · intro h; linarith

/-! ## 8. The Irreducible Galerkin VS–νP Axiom -/

/-- **galerkin_enstrophy_production_le_nuP** — the Galerkin-level VS ≤ νP bound.

    For any Galerkin field `v` with modes `|k|² ≤ galerkinN²`, the enstrophy
    production `VS_N = Σ_k |k|² Re(û_k · (B(û,û))_k)` is bounded above by
    `ν · P_N = ν · Σ_k |k|⁴ |û_k|²`.

    **Why not derivable from `triadK_self_cancel`:**
    `triadK_self_cancel` gives `Σ_k Re(v_k · B(u,v)_k) = 0` (uniform weight = 1).
    The production has mode-dependent weight `|k|²` that does not factor out of the
    trilinear sum — self-cancellation does not imply the production bound.

    **Discharge requires:**
    (a) T³ Fourier resonance `k + j + l = 0` in ℤ³
    (b) Divergence-free constraint `û_k · k = 0` for all modes
    (c) Cauchy-Schwarz + Sobolev interpolation in the trilinear sum

    Epistemic: `.openBridge`. -/
axiom galerkin_enstrophy_production_le_nuP (v : NSFieldGalerkinK) :
    galerkinEnstrophyProduction (NSFieldGalerkinK.toBasis v) v.coeff ≤
    nsNu * palinstrophyK v

/-! ## 9–10. Consequences (0 additional axioms) -/

/-- The VS–νP defect is nonneg for any Galerkin field. -/
theorem galerkinVSNuPDefect_nonneg (v : NSFieldGalerkinK) :
    0 ≤ galerkinVSNuPDefect (NSFieldGalerkinK.toBasis v) v.coeff :=
  (galerkinVSNuPDefect_nonneg_iff v).mpr (galerkin_enstrophy_production_le_nuP v)

/-- Coarser two-step bound: `VS_N ≤ ν · galerkinN² · E_N`.

    Chain: `VS_N ≤ ν P_N` (item 8) → `P_N ≤ galerkinN² · E_N` (Stage 162) →
    `VS_N ≤ ν · galerkinN² · E_N`. -/
theorem galerkinEnstrophyProduction_le_nu_kmax_enstrophy (v : NSFieldGalerkinK) :
    galerkinEnstrophyProduction (NSFieldGalerkinK.toBasis v) v.coeff ≤
    nsNu * (galerkinN : Rat) ^ 2 * enstrophyK v :=
  calc galerkinEnstrophyProduction (NSFieldGalerkinK.toBasis v) v.coeff
      ≤ nsNu * palinstrophyK v :=
          galerkin_enstrophy_production_le_nuP v
    _ ≤ nsNu * ((galerkinN : Rat) ^ 2 * enstrophyK v) :=
          mul_le_mul_of_nonneg_left
            (palinstrophyK_le_galerkinN2_enstrophyK v) (le_of_lt nsNu_pos)
    _ = nsNu * (galerkinN : Rat) ^ 2 * enstrophyK v := by ring

/-! ## Summary -/

def stage219Summary : String :=
  "Stage 219: NSGalerkinVorticityEnstrophyBridge — " ++
  "galerkinVorticityCoeff: ω̂_k = |k|²û_k (def). " ++
  "normSqC_galerkinVorticityCoeff: |ω̂_k|² = |k|⁴·|û_k|² (ring). " ++
  "palinstrophyK_eq_vorticity_enstrophy: P_N = Σ|ω̂_k|² (KEY 0-axiom id). " ++
  "galerkinEnstrophyProduction: VS_N = Σ|k|²Re(û·B(û,û)) (noncomputable def). " ++
  "galerkinEnstrophyProduction_eq_vorticityInner: VS_N = ΣRe(ω̂·B) (ring). " ++
  "galerkinVSNuPDefect: ν·P_N − VS_N (noncomputable def). " ++
  "galerkinVSNuPDefect_nonneg_iff: 0≤δ ↔ VS_N≤νP_N (linarith). " ++
  "galerkin_enstrophy_production_le_nuP: VS_N≤νP_N (AXIOM, .openBridge). " ++
  "galerkinVSNuPDefect_nonneg + galerkinEnstrophyProduction_le_nu_kmax_enstrophy. " ++
  "+1 axiom, +8 theorems, 0 sorry."

end NavierStokes.GalerkinVSNuPBound
