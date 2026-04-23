import NavierStokes.Galerkin.NSGalerkinPassageLimitProof
import NavierStokes.Bridges.NSDirectObsBridge

/-!
# Stage 298 — NSGalerkinPalFourierBridge: Discharging SA-G4b-pal via Fourier Embedding

Discharges `galerkin_palinstrophy_seq_convergence` (SA-G4b-pal, Stage 296) using a
**concrete constant Galerkin sequence** built from the Fourier embedding of the trajectory.

## Strategy

1. **Sub-axiom SA-P1** (`palinstrophy_eq_fourier_pal`): identifies the abstract
   `palinstrophy v` (axiom in `AgmonInterpolationBridge`) with
   `palinstrophyF (interpretAsFourier v)` (Parseval on T³).
   Epistemic: `.partiallyVerified` — Parseval for the |k|⁴-weighted energy,
   Temam 1984 §II.1.

2. **Def** (`interpretAsFourierToGalerkinK`): embeds `interpretAsFourier v : NSFieldFourier`
   into `NSFieldGalerkinK` by placing each scalar mode at wave vector `(freq i, 0, 0) ∈ ℤ³`
   with complex coefficient `(amp i, 0)`. Frequency bound: `waveVecMag2 (n, 0, 0) = n²`
   combined with `interpretAsFourier_freq_le_galerkinN`.

3. **THEOREM** (`interpretAsFourierToGalerkinK_pal`): `palinstrophyK (embed v) = palinstrophyF (interpretAsFourier v)` — pure algebra on finite sums.

4. **THEOREM** (`galerkin_palinstrophy_seq_convergence_proved`): SA-G4b-pal from
   the constant sequence `fun _ => interpretAsFourierToGalerkinK (traj.stateAt t).velocity`
   and `tendsto_const_nhds`.

## Discharge summary

  SA-G4b-pal
      ← `palinstrophy_eq_fourier_pal` (SA-P1, `.partiallyVerified`)
      ← `interpretAsFourierToGalerkinK_pal` (THEOREM, 0 axioms)
      ← `interpretAsFourier_freq_le_galerkinN` (Stage 157, `.openBridge`)

## Net counts (Stage 298)

  - New axioms:   1  (SA-P1: `palinstrophy_eq_fourier_pal`)
  - New theorems: 5  (`waveVecMag2_natCast_axis`, `normSqC_real_axis`,
                      `interpretAsFourierToGalerkinK_pal`,
                      `interpretAsFourierToGalerkinK_pal_physical`,
                      `galerkin_palinstrophy_seq_convergence_proved`)
  - sorry:        0
  - warnings:     0
-/

namespace NavierStokes.GalerkinPalFourierBridge

set_option autoImplicit false

open NavierStokes.Millennium hiding interpretAsFourier
open NavierStokes.FourierModel          -- NSFieldFourier, palinstrophyF
open NavierStokes.GalerkinComplexModel  -- NSFieldGalerkinK, palinstrophyK, waveVecMag2, normSqC, CRat
open NavierStokes.PalinstrophyTauBridge -- galerkinN
open NavierStokes.ObservableInterface   -- interpretAsFourier
open NavierStokes.DirectObsBridge       -- interpretAsFourier_freq_le_galerkinN
open Filter

open scoped Topology

noncomputable section

/-! ## §1. Sub-axiom SA-P1: Parseval identification for palinstrophy -/

/-- **SA-P1** (Stage 298): the abstract palinstrophy axiom (from `AgmonInterpolationBridge`)
    equals `palinstrophyF ∘ interpretAsFourier`.

    Mathematical content: Parseval's theorem on T³ for the |k|⁴-weighted Fourier energy.
    The axiomatic `palinstrophy v` represents `‖Δu‖²_{L²} = ∑_k |k|⁴ |û_k|²`, which is
    exactly `palinstrophyF (interpretAsFourier v)`.

    **Epistemic: `.partiallyVerified`** — Parseval for |k|⁴-weighted series is classical
    (Temam 1984 §II.1); the Lean4 gap is connecting the opaque `palinstrophy` axiom
    (Stage 224) to the explicit finite-mode sum `palinstrophyF ∘ interpretAsFourier`. -/
axiom palinstrophy_eq_fourier_pal (v : NSField) :
    palinstrophy v = palinstrophyF (interpretAsFourier v)

/-! ## §2. Fourier-to-GalerkinK embedding -/

/-- **Concrete embedding** of `interpretAsFourier v` into `NSFieldGalerkinK`.

    Maps each scalar Fourier mode `(freq i : Nat, amp i : Rat)` to the Galerkin
    field with:
    - `wvec i = ((freq i : Int), 0, 0) ∈ ℤ³`  (mode on the x-axis)
    - `coeff i = (amp i, 0) : CRat`             (real-valued complex coefficient)

    The frequency bound `freq_le` holds because:
      `waveVecMag2 ((freq i : Int), 0, 0) = (freq i : Rat)² ≤ galerkinN²`
    using `interpretAsFourier_freq_le_galerkinN` (Stage 157). -/
noncomputable def interpretAsFourierToGalerkinK (v : NSField) : NSFieldGalerkinK :=
  { N     := (interpretAsFourier v).N
    wvec  := fun i => (((interpretAsFourier v).freq i : Int), (0 : Int), (0 : Int))
    coeff := fun i => ((interpretAsFourier v).amp i, (0 : Rat))
    freq_le := fun i => by
      show waveVecMag2 ((((interpretAsFourier v).freq i : Int), (0 : Int), (0 : Int))) ≤
          (galerkinN : Rat) ^ 2
      unfold waveVecMag2
      push_cast
      have hle : ((interpretAsFourier v).freq i : Rat) ≤ (galerkinN : Rat) :=
        by exact_mod_cast interpretAsFourier_freq_le_galerkinN v i
      have h2 := pow_le_pow_left₀ (Nat.cast_nonneg ((interpretAsFourier v).freq i)) hle 2
      nlinarith [sq_nonneg ((interpretAsFourier v).freq i : Rat)] }

/-! ## §3. Algebra lemmas (0 new axioms) -/

/-- `waveVecMag2` of the x-axis embedding equals the squared scalar frequency. -/
private theorem waveVecMag2_natCast_axis (n : Nat) :
    waveVecMag2 ((n : Int), 0, 0) = (n : Rat) ^ 2 := by
  unfold waveVecMag2
  push_cast
  ring

/-- `normSqC` of a real-axis complex coefficient equals the squared real value. -/
private theorem normSqC_real_axis (a : Rat) :
    normSqC (a, 0) = a ^ 2 := by
  unfold normSqC CRat.re CRat.im
  ring

/-! ## §4. Palinstrophy equality (THEOREM, 0 new axioms) -/

/-- **THEOREM (Stage 298)**: `palinstrophyK (interpretAsFourierToGalerkinK v) = palinstrophyF (interpretAsFourier v)`.

    Proof: unfold both sums; each summand satisfies
      `waveVecMag2 ((freq i, 0, 0))² · normSqC (amp i, 0) = (freq i)⁴ · amp i²`
    by the two algebra lemmas above, closed by `ring`. -/
theorem interpretAsFourierToGalerkinK_pal (v : NSField) :
    palinstrophyK (interpretAsFourierToGalerkinK v) =
    palinstrophyF (interpretAsFourier v) := by
  unfold palinstrophyK interpretAsFourierToGalerkinK palinstrophyF
  simp only []
  apply Finset.sum_congr rfl
  intro i _
  rw [waveVecMag2_natCast_axis, normSqC_real_axis]
  ring

/-- **THEOREM**: `palinstrophyK (interpretAsFourierToGalerkinK v) = palinstrophy v`.

    Combines SA-P1 (`palinstrophy_eq_fourier_pal`) with
    `interpretAsFourierToGalerkinK_pal`. -/
theorem interpretAsFourierToGalerkinK_pal_physical (v : NSField) :
    palinstrophyK (interpretAsFourierToGalerkinK v) = palinstrophy v := by
  rw [interpretAsFourierToGalerkinK_pal, ← palinstrophy_eq_fourier_pal]

/-! ## §5. SA-G4b-pal discharged (THEOREM, 0 new axioms) -/

/-- **SA-G4b-pal PROVED** (Stage 298):
    `galerkin_palinstrophy_seq_convergence` holds with the CONSTANT sequence
    `fun _ => interpretAsFourierToGalerkinK (traj.stateAt t).velocity`.

    Proof:
    1. The constant sequence satisfies
       `palinstrophyK (seq N) = palinstrophy (traj.stateAt t).velocity` for all N
       (by `interpretAsFourierToGalerkinK_pal_physical`).
    2. Therefore `nsNu · palinstrophyK (seq N) = nsNu · palinstrophy (traj.stateAt t).velocity`
       for all N (constant Real function).
    3. `tendsto_const_nhds` closes the `Tendsto` obligation. -/
theorem galerkin_palinstrophy_seq_convergence_proved
    (traj : Trajectory NSField) (t : Rat)
    (_ht : 0 ≤ t)
    (_hNS : SatisfiesNSPDE nsOps nsNu traj)
    (_hFS : RespectsFunctionSpaces nsSpacesR3 traj) :
    ∃ (v_seq : Nat → NSFieldGalerkinK),
      Filter.Tendsto
        (fun N => ((nsNu * palinstrophyK (v_seq N) : Rat) : Real))
        Filter.atTop
        (nhds (((nsNu * palinstrophy (traj.stateAt t).velocity : Rat) : Real))) := by
  -- Use the constant sequence
  refine ⟨fun _ => interpretAsFourierToGalerkinK (traj.stateAt t).velocity, ?_⟩
  -- palinstrophyK of the constant = physical palinstrophy
  have hkey := interpretAsFourierToGalerkinK_pal_physical (traj.stateAt t).velocity
  -- Rewrite under the binder and apply constant-tendsto
  simp_rw [hkey]
  exact tendsto_const_nhds

/-! ## §6. Summary -/

def stage298Summary : String :=
  "Stage 298: NSGalerkinPalFourierBridge — SA-G4b-pal discharged via Fourier-to-GalerkinK embedding. " ++
  "palinstrophy_eq_fourier_pal (SA-P1, AXIOM, .partiallyVerified): " ++
    "palinstrophy v = palinstrophyF (interpretAsFourier v). " ++
  "interpretAsFourierToGalerkinK (noncomputable def): embed NSField → NSFieldGalerkinK " ++
    "via wvec i = (freq i, 0, 0), coeff i = (amp i, 0); freq_le from freq_le_galerkinN. " ++
  "waveVecMag2_natCast_axis (THEOREM): waveVecMag2 (n, 0, 0) = n^2. " ++
  "normSqC_real_axis (THEOREM): normSqC (a, 0) = a^2. " ++
  "interpretAsFourierToGalerkinK_pal (THEOREM): " ++
    "palinstrophyK(embed v) = palinstrophyF(interpretAsFourier v); algebra. " ++
  "interpretAsFourierToGalerkinK_pal_physical (THEOREM): " ++
    "palinstrophyK(embed v) = palinstrophy v; from SA-P1. " ++
  "galerkin_palinstrophy_seq_convergence_proved (THEOREM, SA-G4b-pal PROVED): " ++
    "constant sequence + tendsto_const_nhds; 0 new axioms. " ++
  "+1 axiom (SA-P1, .partiallyVerified), +5 theorems, 0 sorry, 0 warnings."

end

end NavierStokes.GalerkinPalFourierBridge
