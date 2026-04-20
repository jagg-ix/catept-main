import NavierStokes.NSGalerkinDefectSplitBridge

/-!
# Stage 304 — NSGalerkinDefectConvergenceClosure: SA-G4b Monolithic as THEOREM

This file extends the `NavierStokes.GalerkinPassageLimitProof` namespace with the
monolithic SA-G4b convergence chain, now proved as theorems using the split
discharge path from `NSGalerkinDefectSplitBridge` (Stages 298–301).

## Why this file exists

`NSGalerkinPassageLimitProof.lean` cannot import `NSGalerkinDefectSplitBridge`
(which imports `NSGalerkinPalFourierBridge` which imports `NSGalerkinPassageLimitProof`).
This file sits after `NSGalerkinDefectSplitBridge` in the import chain, extending
the `GalerkinPassageLimitProof` namespace with the proved versions of the theorems
that previously required the monolithic axiom.

## Discharge chain

```
galerkinDefect_componentwise_seq_convergence
    ← galerkinDefect_componentwise_from_split (THEOREM, DefectSplitBridge Stage 296)
        ← galerkin_palinstrophy_seq_convergence (THEOREM, DefectSplitBridge Stage 299)
        ← galerkin_vs_convergence_from_pal_seq (THEOREM, DefectSplitBridge Stage 301)
```

## Net counts (Stage 304)

  - Axioms removed: 1 (galerkinDefect_componentwise_seq_convergence, ex-SA-G4b)
  - New theorems:   7 (all previously in PassageLimitProof, now proved here)
  - sorry:          0
  - warnings:       0
-/

namespace NavierStokes.GalerkinPassageLimitProof

set_option autoImplicit false

open NavierStokes.Millennium hiding interpretAsFourier
open NavierStokes.GalerkinComplexModel   -- NSFieldGalerkinK, palinstrophyK
open NavierStokes.GalerkinConvection     -- NSFieldGalerkinK.toBasis
open NavierStokes.GalerkinVSNuPBound     -- galerkinVSNuPDefect, galerkinVSNuPDefect_nonneg,
                                          -- galerkinVSNuPDefect_eq_nuP_minus_production,
                                          -- galerkinEnstrophyProduction
open NavierStokes.GalerkinDefectSplit    -- galerkinDefect_componentwise_from_split
open Filter
open scoped Topology

noncomputable section

/-! ## §1. SA-G4b Monolithic as THEOREM (Stage 304) -/

/-- **SA-G4b-components PROVED** (Stage 304): componentwise convergence contract.

    Formerly `axiom galerkinDefect_componentwise_seq_convergence` in
    `NSGalerkinPassageLimitProof.lean`. Now proved via
    `galerkinDefect_componentwise_from_split` (Stage 296 THEOREM in DefectSplitBridge),
    which assembles the two sub-discharges:
    - SA-G4b-pal (Stage 299): `galerkin_palinstrophy_seq_convergence` proved
    - SA-G4b-VS  (Stage 301): `galerkin_vs_convergence_from_pal_seq` proved
    - SA-D1      (Stage 300): `galerkin_defect_seq_convergence` (.partiallyVerified) -/
theorem galerkinDefect_componentwise_seq_convergence
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
          ((galerkinEnstrophyProduction (NSFieldGalerkinK.toBasis (v_seq N)) (v_seq N).coeff : Rat) : Real))
        atTop
        (nhds (((vortexStretchingIntegral traj t : Rat) : Real))) :=
  galerkinDefect_componentwise_from_split traj t ht hNS hFS

/-! ## §2. Dependent theorems (previously in PassageLimitProof, 0 new axioms) -/

/-- SA-G4b-components wrapper with explicit Sobolev-tail budget contract. -/
theorem galerkinDefect_componentwise_seq_convergence_with_tail
    (traj : Trajectory NSField) (t : Rat)
    (ht : 0 ≤ t)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj)
    (_hTail : SAG12TailBudgetContract) :
    ∃ (v_seq : Nat → NSFieldGalerkinK),
      Tendsto
        (fun N => ((nsNu * palinstrophyK (v_seq N) : Rat) : Real))
        atTop
        (nhds (((nsNu * palinstrophy (traj.stateAt t).velocity : Rat) : Real))) ∧
      Tendsto
        (fun N =>
          ((galerkinEnstrophyProduction (NSFieldGalerkinK.toBasis (v_seq N)) (v_seq N).coeff : Rat) : Real))
        atTop
        (nhds (((vortexStretchingIntegral traj t : Rat) : Real))) :=
  galerkinDefect_componentwise_seq_convergence traj t ht hNS hFS

/-- SA-G4b with explicit Sobolev-tail budget threading. -/
theorem galerkinDefect_seq_approx_supercriticalDefect_with_tail
    (traj : Trajectory NSField) (t : Rat)
    (ht : 0 ≤ t)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj)
    (hTail : SAG12TailBudgetContract) :
    ∃ (v_seq : Nat → NSFieldGalerkinK),
      Tendsto
        (fun N => (galerkinVSNuPDefect (NSFieldGalerkinK.toBasis (v_seq N)) (v_seq N).coeff : Real))
        atTop
        (nhds ((nsNu * palinstrophy (traj.stateAt t).velocity -
                vortexStretchingIntegral traj t : Rat) : Real)) := by
  obtain ⟨v_seq, hPal, hVS⟩ :=
    galerkinDefect_componentwise_seq_convergence_with_tail traj t ht hNS hFS hTail
  refine ⟨v_seq, ?_⟩
  have hDefectEq :
      (fun N =>
        (galerkinVSNuPDefect (NSFieldGalerkinK.toBasis (v_seq N)) (v_seq N).coeff : Real)) =
      (fun N =>
        ((nsNu * palinstrophyK (v_seq N) -
          galerkinEnstrophyProduction (NSFieldGalerkinK.toBasis (v_seq N)) (v_seq N).coeff : Rat) : Real)) := by
    funext N
    exact congrArg (fun q : Rat => (q : Real))
      (galerkinVSNuPDefect_eq_nuP_minus_production (v_seq N))
  rw [hDefectEq]
  have hSub := hPal.sub hVS
  simpa [Rat.cast_sub] using hSub

/-- **SA-G4b theoremized**: recover defect convergence from the two componentwise limits. -/
theorem galerkinDefect_seq_approx_supercriticalDefect
    (traj : Trajectory NSField) (t : Rat)
    (ht : 0 ≤ t)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj) :
    ∃ (v_seq : Nat → NSFieldGalerkinK),
      Tendsto
        (fun N => (galerkinVSNuPDefect (NSFieldGalerkinK.toBasis (v_seq N)) (v_seq N).coeff : Real))
        atTop
        (nhds ((nsNu * palinstrophy (traj.stateAt t).velocity -
                vortexStretchingIntegral traj t : Rat) : Real)) :=
  galerkinDefect_seq_approx_supercriticalDefect_with_tail
    traj t ht hNS hFS aubin_lions_tail_budget_contract_holds

/-- **SA-G4a PROVED**: νP−VS is the limit of a nonneg Galerkin approximation sequence. -/
theorem supercriticalDefect_galerkin_approx
    (traj : Trajectory NSField) (t : Rat)
    (ht : 0 ≤ t)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj) :
    ∃ (d_seq : Nat → Real),
      (∀ N, (0 : Real) ≤ d_seq N) ∧
      Tendsto d_seq atTop
        (nhds ((nsNu * palinstrophy (traj.stateAt t).velocity -
               vortexStretchingIntegral traj t : Rat) : Real)) := by
  obtain ⟨v_seq, htend⟩ :=
    galerkinDefect_seq_approx_supercriticalDefect_with_tail
      traj t ht hNS hFS aubin_lions_tail_budget_contract_holds
  refine ⟨fun N => (galerkinVSNuPDefect (NSFieldGalerkinK.toBasis (v_seq N)) (v_seq N).coeff : Real),
          ?_, htend⟩
  intro N
  show (0 : Real) ≤
      (galerkinVSNuPDefect (NSFieldGalerkinK.toBasis (v_seq N)) (v_seq N).coeff : Real)
  have hRat :
      (0 : Rat) ≤ galerkinVSNuPDefect (NSFieldGalerkinK.toBasis (v_seq N)) (v_seq N).coeff :=
    galerkinVSNuPDefect_nonneg (v_seq N)
  exact_mod_cast hRat

/-- **SA-G4 (ns_defect_transport_from_galerkin_lsc) PROVED**: Galerkin weak-LSC transport. -/
theorem ns_defect_transport_from_galerkin_lsc :
    NSDefectTransportFromGalerkinLSCContract := fun traj t ht hNS hFS => by
  obtain ⟨d_seq, hpos, htend⟩ :=
    supercriticalDefect_galerkin_approx traj t ht hNS hFS
  have hRL : (0 : Real) ≤
      ((nsNu * palinstrophy (traj.stateAt t).velocity -
        vortexStretchingIntegral traj t : Rat) : Real) :=
    nonneg_limit_of_real_tendsto d_seq _ hpos htend
  exact_mod_cast hRL

/-- Pointwise projector for SA-G4, used by supercritical-lane proofs. -/
theorem ns_defect_transport_from_galerkin_lsc_apply
    (traj : Trajectory NSField) (t : Rat)
    (ht : 0 ≤ t)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj) :
    0 ≤ nsNu * palinstrophy (traj.stateAt t).velocity - vortexStretchingIntegral traj t :=
  ns_defect_transport_from_galerkin_lsc traj t ht hNS hFS

/-! ## §3. Summary -/

def stage304Summary : String :=
  "Stage 304: NSGalerkinDefectConvergenceClosure — SA-G4b monolithic promoted from axiom to theorem. " ++
  "galerkinDefect_componentwise_seq_convergence (THEOREM): via galerkinDefect_componentwise_from_split " ++
    "(Stage 296 in DefectSplitBridge, itself from SA-G4b-pal (Stage 299) + SA-G4b-VS (Stage 301)). " ++
  "galerkinDefect_componentwise_seq_convergence_with_tail (THEOREM): trivial wrapper. " ++
  "galerkinDefect_seq_approx_supercriticalDefect_with_tail (THEOREM): Tendsto.sub + cast. " ++
  "galerkinDefect_seq_approx_supercriticalDefect (THEOREM): from aubin_lions_tail_budget. " ++
  "supercriticalDefect_galerkin_approx (THEOREM): nonneg approx seq for νP−VS. " ++
  "ns_defect_transport_from_galerkin_lsc (THEOREM): weak-LSC transport (SA-G4). " ++
  "ns_defect_transport_from_galerkin_lsc_apply (THEOREM): pointwise projector. " ++
  "-1 axiom (SA-G4b removed), +7 theorems. 0 sorry, 0 warnings."

end

end NavierStokes.GalerkinPassageLimitProof
