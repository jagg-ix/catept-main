import NavierStokesClean.Galerkin.CantorDiagonal
import NavierStokesClean.Galerkin.AubinLionsCompact

/-!
# Aubin-Lions Mathlib Compatibility

Compatibility surface for high-value legacy names from
`AubinLionsMathlib.lean`, mapped to the current clean Galerkin compactness stack.

This file introduces no new axioms.
-/

set_option autoImplicit false

namespace NavierStokesClean.Galerkin

open NavierStokesClean MeasureTheory Filter

/-- Legacy compatibility name for per-time Rellich/Aubin-Lions extraction. -/
theorem aubin_lions_per_time_rellich
    (traj_seq : Nat → Trajectory) (traj_lim : Trajectory)
    (hConv : ∀ N, SatisfiesNSPDE nsNu (traj_seq N))
    (hLim : SatisfiesNSPDE nsNu traj_lim)
    (C₀ : ℝ) (hC₀ : 0 < C₀) (hInit : ∀ N, ‖traj_seq N 0‖ ≤ C₀)
    (T : ℝ) (hT : 0 < T) :
    ∃ (φ : Nat → Nat), StrictMono φ ∧
      Tendsto
        (fun n => eLpNorm (fun t => traj_seq (φ n) t - traj_lim t) 2
          (volume.restrict (Set.Ioc 0 T)))
        atTop (nhds 0) :=
  galerkin_eLpNorm_per_T traj_seq traj_lim hConv hLim C₀ hC₀ hInit T hT

/-- Legacy compatibility name for the all-T compactness core extraction. -/
theorem aubin_lions_core_compact
    (traj_seq : Nat → Trajectory) (traj_lim : Trajectory)
    (hConv : ∀ N, SatisfiesNSPDE nsNu (traj_seq N))
    (hLim : SatisfiesNSPDE nsNu traj_lim)
    (C₀ : ℝ) (hC₀ : 0 < C₀) (hInit : ∀ N, ‖traj_seq N 0‖ ≤ C₀) :
    ∃ (φ : Nat → Nat), StrictMono φ ∧
      ∀ (T : ℝ), 0 < T →
        Tendsto
          (fun n => eLpNorm (fun t => traj_seq (φ n) t - traj_lim t) 2
            (volume.restrict (Set.Ioc 0 T)))
          atTop (nhds 0) :=
  galerkin_eLpNorm_subseq traj_seq traj_lim hConv hLim C₀ hC₀ hInit

/-- Legacy compatibility alias retained for downstream theorem names. -/
theorem aubin_lions_compactness_from_components
    (traj_seq : Nat → Trajectory) (traj_lim : Trajectory)
    (hConv : ∀ N, SatisfiesNSPDE nsNu (traj_seq N))
    (hLim : SatisfiesNSPDE nsNu traj_lim)
    (C₀ : ℝ) (hC₀ : 0 < C₀) (hInit : ∀ N, ‖traj_seq N 0‖ ≤ C₀) :
    ∃ (φ : Nat → Nat), StrictMono φ ∧
      ∀ (T : ℝ), 0 < T →
        Tendsto
          (fun n => eLpNorm (fun t => traj_seq (φ n) t - traj_lim t) 2
            (volume.restrict (Set.Ioc 0 T)))
          atTop (nhds 0) :=
  aubin_lions_core_compact traj_seq traj_lim hConv hLim C₀ hC₀ hInit

/-- Legacy compatibility witness: compactness route remains theoremized in clean stack. -/
theorem aubin_lions_compactness_is_provable
    (traj_seq : Nat → Trajectory) (traj_lim : Trajectory)
    (hConv : ∀ N, SatisfiesNSPDE nsNu (traj_seq N))
    (hLim : SatisfiesNSPDE nsNu traj_lim)
    (C₀ : ℝ) (hC₀ : 0 < C₀) (hInit : ∀ N, ‖traj_seq N 0‖ ≤ C₀) :
    ∃ (φ : Nat → Nat), StrictMono φ ∧
      ∀ (T : ℝ), 0 < T →
        Tendsto
          (fun n => eLpNorm (fun t => traj_seq (φ n) t - traj_lim t) 2
            (volume.restrict (Set.Ioc 0 T)))
          atTop (nhds 0) :=
  aubin_lions_compactness_from_components traj_seq traj_lim hConv hLim C₀ hC₀ hInit

end NavierStokesClean.Galerkin
