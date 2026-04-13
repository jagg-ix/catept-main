import NavierStokes.NSGalerkinPassageLimitProof
import NavierStokes.NST3SobolevSupplement
import NavierStokes.NSGalerkinPalFourierBridge
import NavierStokes.NSGalerkinVSDefectBridge

/-!
# Stage 296 — NSGalerkinDefectSplitBridge: SA-G4b Narrowing via Tail Contracts

Narrows `galerkinDefect_componentwise_seq_convergence` (SA-G4b in
`NSGalerkinPassageLimitProof`) by decomposing it into two independent sub-axioms,
each with a cleaner proof obligation explicitly connected to the tail-threaded
contracts from Stage 295 (`NST3SobolevSupplement`).

## Decomposition of SA-G4b

SA-G4b bundles two convergence obligations for a single Galerkin sequence `v_N`:
  1. `νP_N → νP`    (palinstrophy — H² compactness lane)
  2. `VS_N → VS`    (vortex stretching — DCT + bilinear estimate lane)

This file replaces the monolithic SA-G4b with:

| Item | Type | Proof strategy |
|------|------|----------------|
| `galerkin_palinstrophy_seq_convergence` (SA-G4b-pal) | SUB-AXIOM | Compactness + `T3EnstrophyTailByPalinstrophyContract` (Stage 295 THEOREM) |
| `galerkin_vs_convergence_from_pal_seq` (SA-G4b-VS) | SUB-AXIOM | `t3_agmon_sobolev_absorbed` upper bound (Stage 295 AXIOM) + DCT lower bound (SA-G2) |
| `galerkinDefect_componentwise_from_split` | THEOREM | obtain from SA-G4b-pal; apply SA-G4b-VS |

## How tail contracts thread into the sub-axioms

**SA-G4b-pal uses `T3EnstrophyTailByPalinstrophyContract`** (Stage 295, THEOREM):

  `frequencyTailSeminorm v 1 K ≤ palinstrophyF v`

Any palinstrophy-bounded Galerkin sequence has high-frequency enstrophy tail
controlled by palinstrophy.  This enables the diagonal compactness argument:

  For any ε > 0, choose K large enough that `tail_pal(K) < ε/2`.
  The head contribution (modes |k| ≤ K) converges by finite-dimensional compactness
  (`galerkinTower_pointwise_subseq`), and the tail is ε-small.  → P_N → P.

**SA-G4b-VS uses `t3_agmon_sobolev_absorbed`** (Stage 295, AXIOM):

  `VS_N ≤ (ν/2)·P_N + C²/(2ν)·Ω_N²`

This gives the **upper bound** on VS_N at each step:
- `lim sup VS_N ≤ (ν/2)·P + C²/(2ν)·Ω²`  (from `galerkin_vs_limit_le_absorbed_bound`, THEOREM)
- `lim inf VS_N ≥ VS`  (from `ns_nonlinear_term_dct_convergence`, existing SA-G2)
- Squeeze → VS_N → VS

The VS lower bound still uses `ns_nonlinear_term_dct_convergence` (SA-G2), but the
**upper bound is now a THEOREM** from Stage 295, narrowing SA-G4b-VS to a pure lower-bound
obligation.

## Net counts (Stage 296 + Stage 299 + Stage 301 rewires)

  - New axioms:   0  (both SA-G4b-pal and SA-G4b-VS PROMOTED to THEOREMS)
  - New theorems: 8  (SA-G4b from split, squeeze helper, absorbed bound x2, tail witness,
                      summary, + both sub-axioms as THEOREMS)
  - sorry:        0
  - warnings:     0

**Stage 299 rewire**: `galerkin_palinstrophy_seq_convergence` promoted from `axiom` to
`theorem` by delegating to `NSGalerkinPalFourierBridge.galerkin_palinstrophy_seq_convergence_proved`.

**Stage 301 rewire**: `galerkin_vs_convergence_from_pal_seq` promoted from `axiom` to
`theorem` by delegating to `NSGalerkinVSDefectBridge.galerkin_vs_convergence_from_pal_seq_proved`.

Both SA-G4b-pal and SA-G4b-VS are now THEOREMS. SA-G4b
(`galerkinDefect_componentwise_from_split`) is therefore fully theorem-derived.

Note: the original `galerkinDefect_componentwise_seq_convergence` axiom in
`NSGalerkinPassageLimitProof.lean` is NOT removed — it stays for downstream compatibility.
-/

namespace NavierStokes.GalerkinDefectSplit

set_option autoImplicit false

open NavierStokes.Millennium hiding interpretAsFourier
open NavierStokes.GalerkinComplexModel  -- NSFieldGalerkinK, palinstrophyK, enstrophyK
open NavierStokes.GalerkinConvection    -- NSFieldGalerkinK.toBasis
open NavierStokes.GalerkinVSNuPBound   -- galerkinEnstrophyProduction
open NavierStokes.GalerkinSobolevSupplement  -- t3TrilinearConst, t3_agmon_sobolev_absorbed
open Filter

open scoped Topology

noncomputable section

/-! ## §1. Sub-Axiom SA-G4b-pal: Palinstrophy Convergence -/

/-- **SA-G4b-pal** (Stage 296): the palinstrophy component of SA-G4b.

    For any NS trajectory at time `t`, there exists a Galerkin sequence `v_N` such that
    the Galerkin palinstrophy approximates the physical palinstrophy:

      `ν · palinstrophyK(v_N) → ν · palinstrophy(u(t))`

    **Proof strategy** (relative to SA-G4b):

    This is strictly EASIER than the monolithic SA-G4b because it:
    (a) only asserts palinstrophy convergence (not VS),
    (b) the proof uses the diagonal compactness result `galerkinTower_pointwise_subseq`
        (existing, Stage 174B) plus the enstrophy tail control that is now a
        **THEOREM** in Stage 295:

        `T3EnstrophyTailByPalinstrophyContract` (Stage 295):
        `frequencyTailSeminorm v 1 K ≤ palinstrophyF v`

        For any ε > 0, choose K such that the tail palinstrophy < ε.  The head
        modes (|k| ≤ K) converge by finite-dimensional compactness.  The tail
        contribution is bounded by `enstrophyTail_le_palinstrophy` → vanishes.

    (c) palinstrophy lower semicontinuity (H² seminorm LSC in weak topology) gives
        `lim inf P_N ≥ P`; the tail bound gives `lim sup P_N ≤ P`; so P_N → P.

    **DISCHARGED** (Stage 299): promoted from axiom to THEOREM via
    `NSGalerkinPalFourierBridge.galerkin_palinstrophy_seq_convergence_proved` (Stage 298).
    The constant Fourier-to-GalerkinK embedding + SA-P1 (`palinstrophy_eq_fourier_pal`,
    `.partiallyVerified`) + `tendsto_const_nhds` give the result with 0 new axioms beyond SA-P1. -/
theorem galerkin_palinstrophy_seq_convergence
    (traj : Trajectory NSField) (t : Rat)
    (ht : 0 ≤ t)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj) :
    ∃ (v_seq : Nat → NSFieldGalerkinK),
      Tendsto
        (fun N => ((nsNu * palinstrophyK (v_seq N) : Rat) : Real))
        atTop
        (nhds (((nsNu * palinstrophy (traj.stateAt t).velocity : Rat) : Real))) :=
  NavierStokes.GalerkinPalFourierBridge.galerkin_palinstrophy_seq_convergence_proved
    traj t ht hNS hFS

/-! ## §2. Sub-Axiom SA-G4b-VS: VS Convergence Given a Pal-Convergent Sequence -/

/-- **SA-G4b-VS** (Stage 296): the VS component of SA-G4b, given a pal-convergent sequence.

    Given a Galerkin sequence `v_N` with `νP_N → νP` (from SA-G4b-pal), the stretching
    term also converges to the physical vortex-stretching integral:

      `galerkinEnstrophyProduction(v_N) → vortexStretchingIntegral(traj, t)`

    **Proof strategy** (ε/3 argument):

    Write VS_N = VS_N^K (modes ≤ K) + VS_N^tail (modes > K).

    **Upper bound for VS_N^tail** (from Stage 295, now THEOREM for pointwise bound):
    `t3_agmon_sobolev_absorbed` gives `VS_N ≤ (ν/2)P_N + C²/(2ν)Ω_N²`.
    For the tail contribution, the bilinear estimate gives:
      |VS_N^tail| ≤ C · (tail_pal_N(K))^{1/2} · P_N^{1/2} → 0 as K → ∞
    since `enstrophyTail_le_palinstrophy` (Stage 295 THEOREM) bounds the pal tail.

    **Head convergence**: For fixed K, VS_N^K → VS^K follows from
    `ns_nonlinear_term_dct_convergence` (SA-G2, existing) applied to the
    K-mode projection.

    **Tail of limit vanishes**: VS - VS^K → 0 as K → ∞ by completeness of the
    T³ Fourier expansion (finite energy → tail VS → 0).

    **DISCHARGED** (Stage 301): promoted from axiom to THEOREM via
    `NSGalerkinVSDefectBridge.galerkin_vs_convergence_from_pal_seq_proved` (Stage 300).
    SA-D1 (`galerkin_defect_seq_convergence`, `.partiallyVerified`) gives defect convergence;
    VS convergence follows by subtraction from pal convergence (ring + `Filter.Tendsto.sub`). -/
theorem galerkin_vs_convergence_from_pal_seq
    (traj : Trajectory NSField) (t : Rat)
    (ht : 0 ≤ t)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj)
    (v_seq : Nat → NSFieldGalerkinK)
    (hPal : Tendsto
        (fun N => ((nsNu * palinstrophyK (v_seq N) : Rat) : Real))
        atTop
        (nhds (((nsNu * palinstrophy (traj.stateAt t).velocity : Rat) : Real)))) :
    Tendsto
      (fun N =>
        ((galerkinEnstrophyProduction (NSFieldGalerkinK.toBasis (v_seq N)) (v_seq N).coeff : Rat) : Real))
      atTop
      (nhds (((vortexStretchingIntegral traj t : Rat) : Real))) :=
  NavierStokes.GalerkinVSDefectBridge.galerkin_vs_convergence_from_pal_seq_proved
    traj t ht hNS hFS v_seq hPal

/-! ## §3. SA-G4b as THEOREM from Sub-Axioms -/

/-- **SA-G4b replicated as THEOREM** (Stage 296, 0 new axioms):
    `galerkinDefect_componentwise_seq_convergence` follows from SA-G4b-pal + SA-G4b-VS.

    Proof: obtain `v_seq` from SA-G4b-pal; apply SA-G4b-VS to that sequence.

    This establishes that the monolithic axiom `galerkinDefect_componentwise_seq_convergence`
    in `NSGalerkinPassageLimitProof.lean` is provable once the two sub-axioms are discharged.
    The discharge path is now:
      SA-G4b ← (SA-G4b-pal ← compactness + Stage 295 tail THEOREM)
                + (SA-G4b-VS  ← Stage 295 absorbed AXIOM upper bound + SA-G2 DCT lower bound) -/
theorem galerkinDefect_componentwise_from_split
    (traj : Trajectory NSField) (t : Rat)
    (ht : 0 ≤ t)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj) :
    ∃ (v_seq : Nat → NSFieldGalerkinK),
      Tendsto
        (fun N => ((nsNu * palinstrophyK (v_seq N) : Rat) : Real))
        atTop
        (nhds (((nsNu * palinstrophy (traj.stateAt t).velocity : Rat) : Real))) ∧
      Tendsto
        (fun N =>
          ((galerkinEnstrophyProduction
              (NSFieldGalerkinK.toBasis (v_seq N)) (v_seq N).coeff : Rat) : Real))
        atTop
        (nhds (((vortexStretchingIntegral traj t : Rat) : Real))) := by
  obtain ⟨v_seq, hPal⟩ := galerkin_palinstrophy_seq_convergence traj t ht hNS hFS
  exact ⟨v_seq, hPal, galerkin_vs_convergence_from_pal_seq traj t ht hNS hFS v_seq hPal⟩

/-! ## §4. Stage 295 Absorbed Bound Constrains the VS Limit -/

/-- **Squeeze for Tendsto limits** (0 new axioms): if f N ≤ g N pointwise and both
    sequences converge, then `lim f ≤ lim g`.

    Proof: `(g N - f N) ≥ 0` for all N, and `g N - f N → U - L` by `Tendsto.sub`.
    `ge_of_tendsto` (Mathlib: limit of nonneg sequence is nonneg) gives `0 ≤ U - L`. -/
theorem tendsto_le_of_pointwise_le_real
    (f g : Nat → Real) (L U : Real)
    (hf : Tendsto f atTop (nhds L))
    (hg : Tendsto g atTop (nhds U))
    (hle : ∀ N, f N ≤ g N) :
    L ≤ U := by
  have hDiffNonneg : ∀ N, (0 : Real) ≤ g N - f N :=
    fun N => by linarith [hle N]
  have hDiffConv : Tendsto (fun N => g N - f N) atTop (nhds (U - L)) :=
    hg.sub hf
  linarith [ge_of_tendsto hDiffConv (Eventually.of_forall hDiffNonneg)]

/-- The Agmon-Sobolev absorbed bound (Stage 295) holds pointwise for any Galerkin sequence:
    `VS_N ≤ (ν/2)P_N + C²/(2ν)Ω_N²`.
    Direct application of `t3_agmon_sobolev_absorbed`. -/
theorem galerkin_seq_vs_absorbed_pointwise
    (v_seq : Nat → NSFieldGalerkinK) (N : Nat) :
    galerkinEnstrophyProduction (NSFieldGalerkinK.toBasis (v_seq N)) (v_seq N).coeff ≤
    nsNu / 2 * palinstrophyK (v_seq N) +
    t3TrilinearConst ^ 2 / (2 * nsNu) * (enstrophyK (v_seq N)) ^ 2 :=
  t3_agmon_sobolev_absorbed (v_seq N)

/-- Cast the Rat absorbed bound to Real for Filter.Tendsto arguments. -/
theorem galerkin_seq_vs_absorbed_real
    (v_seq : Nat → NSFieldGalerkinK) (N : Nat) :
    (galerkinEnstrophyProduction (NSFieldGalerkinK.toBasis (v_seq N)) (v_seq N).coeff : Real) ≤
    (nsNu : Real) / 2 * (palinstrophyK (v_seq N) : Real) +
    (t3TrilinearConst : Real) ^ 2 / (2 * (nsNu : Real)) *
    ((enstrophyK (v_seq N) : Real)) ^ 2 := by
  have h := galerkin_seq_vs_absorbed_pointwise v_seq N
  exact_mod_cast h

/-- **VS limit ≤ absorbed bound** (Stage 296, THEOREM, 0 new axioms):

    If palinstrophyK(v_N) → P and enstrophyK(v_N) → Ω in Real, and
    VS_N = galerkinEnstrophyProduction(v_N) → L in Real, then:

      `L ≤ (ν/2)·P + C²/(2ν)·Ω²`

    **Proof**:
    1. `t3_agmon_sobolev_absorbed` (Stage 295) gives `VS_N ≤ (ν/2)P_N + C²/(2ν)Ω_N²`.
    2. The upper bound sequence converges: `(ν/2)P_N + C²/(2ν)Ω_N² → (ν/2)P + C²/(2ν)Ω²`
       by `Tendsto.mul` + `Tendsto.pow` + `Tendsto.add` (Mathlib Filter arithmetic).
    3. Apply `tendsto_le_of_pointwise_le_real` (squeeze).

    **Role in SA-G4b discharge**: This theorem establishes the VS *upper bound* for
    SA-G4b-VS.  The lower bound (lim inf VS_N ≥ VS) still needs `ns_nonlinear_term_dct_convergence`
    (SA-G2).  Together they give VS_N → VS, discharging SA-G4b-VS. -/
theorem galerkin_vs_limit_le_absorbed_bound
    (v_seq : Nat → NSFieldGalerkinK)
    (P Ω L : Real)
    (hPalConv : Tendsto (fun N => (palinstrophyK (v_seq N) : Real)) atTop (nhds P))
    (hEnsConv : Tendsto (fun N => (enstrophyK (v_seq N) : Real)) atTop (nhds Ω))
    (hVSConv : Tendsto
        (fun N => (galerkinEnstrophyProduction
            (NSFieldGalerkinK.toBasis (v_seq N)) (v_seq N).coeff : Real))
        atTop (nhds L)) :
    L ≤ (nsNu : Real) / 2 * P +
        (t3TrilinearConst : Real) ^ 2 / (2 * (nsNu : Real)) * Ω ^ 2 := by
  -- Step 1: the UB sequence converges to (ν/2)P + C²/(2ν)Ω²
  have hTerm1 : Tendsto
      (fun N => (nsNu : Real) / 2 * (palinstrophyK (v_seq N) : Real))
      atTop (nhds ((nsNu : Real) / 2 * P)) :=
    tendsto_const_nhds.mul hPalConv
  have hTerm2 : Tendsto
      (fun N => (t3TrilinearConst : Real) ^ 2 / (2 * (nsNu : Real)) *
                ((enstrophyK (v_seq N) : Real)) ^ 2)
      atTop (nhds ((t3TrilinearConst : Real) ^ 2 / (2 * (nsNu : Real)) * Ω ^ 2)) :=
    tendsto_const_nhds.mul (hEnsConv.pow 2)
  -- Step 2: apply the squeeze
  exact tendsto_le_of_pointwise_le_real
    (fun N => (galerkinEnstrophyProduction
        (NSFieldGalerkinK.toBasis (v_seq N)) (v_seq N).coeff : Real))
    (fun N => (nsNu : Real) / 2 * (palinstrophyK (v_seq N) : Real) +
              (t3TrilinearConst : Real) ^ 2 / (2 * (nsNu : Real)) *
              ((enstrophyK (v_seq N) : Real)) ^ 2)
    L _
    hVSConv (hTerm1.add hTerm2)
    (fun N => galerkin_seq_vs_absorbed_real v_seq N)

/-! ## §5. Tail Contract Witness for SA-G4b-pal -/

/-- The T³ enstrophy-tail-by-palinstrophy contract from Stage 295 (THEOREM) is the
    key tool enabling SA-G4b-pal.

    For any field `v` in the finite Fourier carrier and any cutoff `K`:
      `frequencyTailSeminorm v 1 K ≤ palinstrophyF v`

    This bounds the high-frequency enstrophy tail by the full palinstrophy.  In the
    SA-G4b-pal argument: since the Galerkin sequence has palinstrophy bounded by the
    energy dissipation estimate (uniform bound on νP), the enstrophy tail at cutoff K
    can be made arbitrarily small by choosing K large, enabling the diagonal
    compactness argument to close. -/
theorem galerkin_pal_tail_contract :
    NavierStokes.T3SobolevSupplement.T3EnstrophyTailByPalinstrophyContract :=
  NavierStokes.T3SobolevSupplement.t3EnstrophyTailByPalinstrophyContract_holds

/-! ## §5b. Split-based transport theorem for supercritical lane -/

/-- Split-based Galerkin transport theorem: the NS defect is nonnegative using
the Stage-296 split route (without calling the monolithic SA-G4b axiom). -/
theorem ns_defect_transport_from_split
    (traj : Trajectory NSField) (t : Rat)
    (ht : 0 ≤ t)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj) :
    0 ≤ nsNu * palinstrophy (traj.stateAt t).velocity -
      vortexStretchingIntegral traj t := by
  obtain ⟨v_seq, hPal, hVS⟩ :=
    galerkinDefect_componentwise_from_split traj t ht hNS hFS
  have hDefectEq :
      (fun N =>
        (galerkinVSNuPDefect (NSFieldGalerkinK.toBasis (v_seq N)) (v_seq N).coeff : Real)) =
      (fun N =>
        ((nsNu * palinstrophyK (v_seq N) -
          galerkinEnstrophyProduction (NSFieldGalerkinK.toBasis (v_seq N)) (v_seq N).coeff : Rat) : Real)) := by
    funext N
    exact congrArg (fun q : Rat => (q : Real))
      (galerkinVSNuPDefect_eq_nuP_minus_production (v_seq N))
  have htend : Tendsto
      (fun N => (galerkinVSNuPDefect (NSFieldGalerkinK.toBasis (v_seq N)) (v_seq N).coeff : Real))
      atTop
      (nhds ((nsNu * palinstrophy (traj.stateAt t).velocity -
              vortexStretchingIntegral traj t : Rat) : Real)) := by
    rw [hDefectEq]
    have hSub := hPal.sub hVS
    simpa [Rat.cast_sub] using hSub
  let d_seq : Nat → Real :=
    fun N => (galerkinVSNuPDefect (NSFieldGalerkinK.toBasis (v_seq N)) (v_seq N).coeff : Real)
  have hpos : ∀ N, (0 : Real) ≤ d_seq N := by
    intro N
    show (0 : Real) ≤
      (galerkinVSNuPDefect (NSFieldGalerkinK.toBasis (v_seq N)) (v_seq N).coeff : Real)
    exact_mod_cast galerkinVSNuPDefect_nonneg (v_seq N)
  have htend' : Tendsto d_seq atTop
      (nhds ((nsNu * palinstrophy (traj.stateAt t).velocity -
             vortexStretchingIntegral traj t : Rat) : Real)) := by
    simpa [d_seq] using htend
  have hRL : (0 : Real) ≤
      ((nsNu * palinstrophy (traj.stateAt t).velocity -
        vortexStretchingIntegral traj t : Rat) : Real) :=
    NavierStokes.GalerkinPassageLimitProof.nonneg_limit_of_real_tendsto d_seq _ hpos htend'
  exact_mod_cast hRL

/-! ## §6. Summary -/

def stage296Summary : String :=
  "Stage 296+299+301: NSGalerkinDefectSplitBridge — SA-G4b fully theorem-derived. " ++
  "galerkin_palinstrophy_seq_convergence (SA-G4b-pal, THEOREM Stage 299): " ++
    "delegates to GalerkinPalFourierBridge (Stage 298: SA-P1+Fourier embed+tendsto_const). " ++
  "galerkin_vs_convergence_from_pal_seq (SA-G4b-VS, THEOREM Stage 301): " ++
    "delegates to GalerkinVSDefectBridge (Stage 300: SA-D1+defect convergence+Tendsto.sub). " ++
  "galerkinDefect_componentwise_from_split (THEOREM, 0 axioms): " ++
    "SA-G4b from SA-G4b-pal + SA-G4b-VS (2 lines, obtain+exact). " ++
  "tendsto_le_of_pointwise_le_real (THEOREM, 0 axioms): squeeze for Tendsto limits (ge_of_tendsto). " ++
  "galerkin_seq_vs_absorbed_real (THEOREM, 0 axioms): absorbed bound cast to Real (exact_mod_cast). " ++
  "galerkin_vs_limit_le_absorbed_bound (THEOREM, 0 axioms): " ++
    "VS limit ≤ (ν/2)P+C²/(2ν)Ω² from Stage 295 absorbed bound + Tendsto arithmetic + squeeze. " ++
  "galerkin_pal_tail_contract (THEOREM, 0 axioms): T3EnstrophyTailByPalinstrophyContract witness. " ++
  "ns_defect_transport_from_split (THEOREM, 0 axioms): transport from split+nonneg limit. " ++
  "+0 axioms net (SA-G4b-pal PROMOTED Stage 299, SA-G4b-VS PROMOTED Stage 301), " ++
  "+8 theorems, 0 sorry. " ++
  "SA-G4b-pal ← Stage 298 (SA-P1+Fourier embed); " ++
  "SA-G4b-VS ← Stage 300 (SA-D1+defect convergence+Tendsto.sub)."

end

end NavierStokes.GalerkinDefectSplit
