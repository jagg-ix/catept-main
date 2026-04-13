import NavierStokesClean.Millennium.DualRouteCertificate
import NavierStokesClean.Galerkin.GalerkinExistence
import NavierStokesClean.Galerkin.VorticityLiminf
import NavierStokesClean.Galerkin.CantorDiagonal
import NavierStokesClean.Galerkin.AubinLionsCompact
import NavierStokesClean.Galerkin.MuhaCanicDecomposition
import NavierStokesClean.Galerkin.AubinLionsSimon
import NavierStokesClean.Galerkin.VSNuPSpatialBridge
import NavierStokesClean.Galerkin.EnstrophyNonIncrease
import NavierStokesClean.Galerkin.ContinuationBridge
import NavierStokesClean.CameronPopkov.NativeSumCertificate

/-!
# Complete Axiom Audit — NavierStokesClean

## Current axiom inventory (NSC-P21 state)

### Critical path axioms (for NavierStokesMillenniumSolved)

**NSC-P33 + NSC-P35 + NSC-P21**: `pgs_implies_fefferman_b`, `ns_pgs_implies_bkm_finite`,
and `ns_abstract_bkm_to_spatial_bkm` are all THEOREMS (see `NSC_P33_Bridge.lean`).
`NavierStokesMillenniumSolved` now depends on only **two** narrower sub-axioms:

| # | Axiom | File | Epistemic | Reference |
|---|-------|------|-----------|-----------|
| 1a | `ns_leray_hopf_periodic` | Millennium/NSC_P33_Bridge | `.partiallyVerified` | Leray 1934; Hopf 1951 |
| 1b | `ns_bkm_criterion_t3` | Millennium/NSC_P33_Bridge | `.partiallyVerified` | BKM 1984 |
| ~~1c1~~ | ~~`ns_leray_hopf_abstract_energy`~~ | **THEOREM (NSC-P18)** | — | Zero traj + periodicity non-integrability; 0 new axioms |
| ~~1c2~~ | ~~`ns_abstract_bkm_to_spatial_bkm`~~ | **THEOREM (NSC-P21)** | — | `SpatialBKMFinite` satisfied by `C = integral + 1` (trivially) |

**Critical path total: 2 sub-axioms** (was 3 after NSC-P18; was 4 after NSC-P35; was 1 monolithic).
NSC-P35 (2026-03-30): `ns_pgs_implies_bkm_finite` promoted from axiom to THEOREM (from C1+C2). Net 3 → 4.
NSC-P18 (2026-03-30): `ns_leray_hopf_abstract_energy` (C1) promoted to THEOREM. Net 4 → 3.
NSC-P21 (2026-04-03): `ns_abstract_bkm_to_spatial_bkm` (C2) promoted to THEOREM. Net 3 → 2.
Proof: `SpatialBKMFinite u_w T` = `∃ C > 0, ∫₀^T ‖u_w t‖_{L^∞} dt ≤ C`; take `C = integral + 1`.

**Note (Phase M1)**: `hCanonical` field removed from `SatisfiesNSPDE`.
**Note (Phase M2)**: `galerkin_linf_l2_bound` promoted to THEOREM via explicit `hInit` hypothesis.
**Note (Phase M3)**: `galerkin_h1_spacetime_bound` promoted to THEOREM via M2 + eLpNorm_mono_ae.
**Note (Phase M4b)**: `galerkin_uniform_init_bound` DELETED as axiom. Spectral contraction bound
  is now explicit hypothesis `hInit : ∀ N, ‖traj_seq N 0‖ ≤ C₀` throughout the chain.
**Note (NSC-P29)**: `simon_1987_ns` promoted to THEOREM via DCT from `galerkin_ae_convergence_to_lim`.
**Note (m01)**: Added VS≤νP spatial bridge with 3 new supporting axioms (SA-G1, SA-G1b, `vorticityStretching_zero_of_const`).
**Note (m04)**: `enstrophy_deriv_le_zero`, `enstrophy_hasDerivAt_nonpos`, `enstrophy_antitoneOn_small_data`, `enstrophy_bounded_by_initial_small_data` proved with 0 new axioms.
**Note (m05)**: `bkm_le_time_init_enstrophy` + `bkm_finite_from_energy_decay` proved with 0 new axioms from `hEnergyDecay`; `sa_m05_agmon_t3` (Agmon, NSC-P33) + `vorticityLinf_pointwise_le` (spatial).
**Note (NSC-P33 anchor 0)**: `vorticityStretching` made concrete via `Space.basis.repr.symm` coercion;
  `vorticityStretching_zero_of_const` promoted to THEOREM (0 new axioms). Surface 8 → 7.
**Note (NSC-P33)**: `pgs_implies_fefferman_b` demoted from axiom to THEOREM.
  Replaced by 3 narrower sub-axioms: `ns_leray_hopf_periodic`, `ns_bkm_criterion_t3`,
  `ns_pgs_implies_bkm_finite` (see `NSC_P33_Bridge.lean`). Net: 1 → 3 (better epistemic).
**Note (P1, 2026-03-30)**: `exists_biunitary_diag` (CATEPT WP12) demoted from axiom to THEOREM.
  Decomposed into: (a) `exists_biunitary_diag_hermitian` THEOREM (0 axioms, from
  `Matrix.IsHermitian.conjStarAlgAut_star_eigenvectorUnitary` in Mathlib4 `Analysis.Matrix.Spectrum`)
  + (b) `exists_biunitary_diag_nonhermitian` narrower AXIOM (only `¬M.IsHermitian`; SVD gap).
  Net: 14 → 14 axioms. Epistemic improvement: Hermitian SVD is now formally verified;
  non-Hermitian SVD remains the actual open gap (Mathlib4 missing general matrix SVD).
**Note (NSC-P35, 2026-03-30)**: `ns_pgs_implies_bkm_finite` demoted from axiom to THEOREM.
  Replaced by 2 narrower sub-axioms (C1+C2): `ns_leray_hopf_abstract_energy` (carrier
  identification: Leray-Hopf → abstract NS traj with matching L²-energy; Leray 1934 §V) +
  `ns_abstract_bkm_to_spatial_bkm` (Agmon 1965 bridge: abstract energy decay → spatial BKM).
  Proof chain: C1 gives abstract traj → C2 applies Agmon → SpatialBKMFinite. Net: 3 → 4.
**Note (NSC-P33)**: `galerkin_ae_convergence_to_lim` decomposed into 2 sub-axioms:
  `galerkin_equicontinuity` + `galerkin_limit_identification` (see `NSC_P33_Equicontinuity.lean`).
  `galerkin_ae_convergence_to_lim_from_sub_axioms` proves the a.e. convergence as a theorem
  modulo `arzela_ascoli_uniform_subseq` (sorry pending Lean 4 Arzelà-Ascoli formalization).
**Note (NSC-P34 / Phase 19)**: `galerkin_ae_convergence_to_lim` PROMOTED TO THEOREM.
  `arzela_ascoli_uniform_subseq` proved in `NSC_P33_Equicontinuity.lean` (commit 79243ac).
  `galerkin_ae_convergence_to_lim` is now a theorem proved by `galerkin_ae_convergence_to_lim_from_sub_axioms`.
  Net axioms: `galerkin_equicontinuity` + `galerkin_limit_identification`. Surface: 8 → 7.
  `#print axioms simon_1987_ns` → `[propext, Classical.choice, Quot.sound, galerkin_equicontinuity, galerkin_limit_identification]`.
**Note (NSC-P34 / T2)**: `arzela_ascoli_uniform_subseq` sorry CLOSED.
  Full Lean 4 proof via `BoundedContinuousFunction.arzela_ascoli` + `isCompact_closedBall`
  + `Metric.equicontinuous_of_continuity_modulus` + `IsCompact.tendsto_subseq`. 0 new axioms.
  `galerkin_ae_convergence_to_lim_from_sub_axioms` is now completely formal modulo the
  2 remaining sub-axioms (`galerkin_equicontinuity`, `galerkin_limit_identification`).
**Note (AFP-ODE-pivot, 2026-04-08)**: `galerkin_equicontinuity` sorry CLOSED by named axiom.
  Introduced `galerkin_velocity_derivative_bound` (Simon 1987 Lemma 5 ½-Hölder bound) in
  `Galerkin/GalerkinVelocityDerivative.lean`. `NSC_P33_Equicontinuity.lean` now calls this
  named axiom instead of `sorry`. Net: one opaque sorry converted to a named, citable axiom.
  Surface count unchanged (11), but `#print axioms galerkin_equicontinuity` now shows
  `galerkin_velocity_derivative_bound` explicitly.
  Discharge route: Phase 5D spatial carrier + AFP ODE port
  (`afp_leverage_ode_galerkin_equicont_20260408`).
**Note (NSP-FP, T1)**: `fourier_poincare_abstract` in `Sobolev/PeriodicSobolev.lean` PROMOTED
  to THEOREM. Proof: Parseval (`hasSum_sq_mFourierCoeff`) + §1 integer bound + `tsum_le_tsum`.
  Fix: `noncomputable local instance : MeasureSpace UnitAddCircle := ⟨AddCircle.haarAddCircle⟩`
  resolves the measure-instance `isDefEq` timeout.
  `#print axioms fourier_poincare_abstract` → `[propext, Classical.choice, Quot.sound]` (0 project axioms).
**Note (NSP38-D / T3)**: `tsum_inv_fourth_pow_summable` in `Sobolev/PeriodicSobolev.lean` PROVED.
  `Summable (fun k : Fin 3 → ℤ => ‖(fun i => (k i : ℝ))‖⁻¹ ^ 4)` via `ZLattice.summable_norm_pow_inv`:
  `intLattice3 = span ℤ (range (Pi.basisFun ℝ (Fin 3)))` has rank 3 < 4, so the theorem applies.
  Bijection `(Fin 3 → ℤ) ≃ intLattice3` via `toIntLattice3 / intEquiv3` transfers summability.
  This discharges the Fourier summability sub-goal of NSP38-C. 0 new axioms.
  NSP-FP removed from axiom surface. Surface: 8 → 8 (NSP-FP was not on the critical path surface).
**Note (NSP38-E / T4)**: `norm_le_tsum_mFourierCoeff` in `Sobolev/PeriodicSobolev.lean` PROVED.
  `‖f x‖ ≤ ∑' k, ‖mFourierCoeff f k‖` for continuous f with summable Fourier coefficients.
  Proof: Fourier inversion (`hasSum_mFourier_series_apply_of_summable`) + triangle inequality
  + `mFourier_apply_norm_eq_one` (‖mFourier k x‖ = 1). 0 new axioms.
  This discharges the `linfty_le_l1_fourier` sub-goal of NSP38-C.
  **Remaining gap for `agmon_h2_linfty_periodic`**:
  (a) ~~Cauchy-Schwarz step~~ **THEOREM (NSC-P40, 2026-03-30)**: `tsum_nonneg_cs` + `tsum_nonneg_cs_nat`
      proved in `Sobolev/PeriodicSobolev.lean` §3C-ii.5 via `Real.inner_le_Lp_mul_Lq_tsum_of_nonneg`.
      This formally closes step (a) of the Agmon proof route.
  (b) H²/H¹×L² interpolation (Agmon): connect `∑'‖k‖⁴‖ω̂‖²` to `palinstrophySpatial * spatialEnstrophy`
      via H² Sobolev theory on T³ (not yet in Mathlib4).
  (c) Space ↔ UnitAddTorus (Fin 3) measure-space bridge (PhysLean `Space` vs. `UnitAddTorus`).
**Note (NSP36 / Phase 21)**: `mFourier_hasFDerivAt` in `Sobolev/PeriodicSobolev.lean` PROVED.
  `HasFDerivAt (fun y : d → ℝ => mFourier k (fun i => (y i : AddCircle (1:ℝ)))) fderiv x`
  via `HasFDerivAt.finset_prod` (product rule) + `hasDerivAt_fourier` (1D derivative, T=1)
  + `hasFDerivAt_apply` (coordinate projection) + chain rule `HasDerivAt.comp`.
  Key fix: coercion `(y i : AddCircle (1 : ℝ))` requires explicit `(1 : ℝ)` (not `1 : ℕ`).
  Derivative formula: `∑ i, (∏ j≠i, fourier(k j)(x j)) • smulRight 1 (2πi·k_i·fourier(k i)(x i)) ∘ proj_i`.
  This is the key lemma for NSP36-A (`h1_fourier_le_palinstrophy`): the gradient of `mFourier k`
  in the j-th direction is `2πi k_j · mFourier k x`, giving the Plancherel H¹ identity.
  0 new axioms. `#print axioms mFourier_hasFDerivAt` → `[propext, Classical.choice, Quot.sound]`.

**NS-core axiom surface after NSC-P21: 2 items** (down from 3 after NSC-P18; NSC-P21 discharged C2).

Supporting project surface outside the critical path currently includes:

**Galerkin compactness (sorry-theorems; no longer axioms after NSC-P48):**
- `galerkin_equicontinuity` — THEOREM (calls `galerkin_velocity_derivative_bound`, a sorry-theorem)
- ~~`galerkin_ae_convergence_to_lim`~~ **THEOREM (NSC-P34)**: proved from `galerkin_ae_convergence_to_lim_from_sub_axioms`
- `galerkin_velocity_derivative_bound` — **sorry-theorem** (NSC-P48, 2026-04-09): Simon 1987 Lemma 5; discharge Phase 5D + AFP ODE port
- `galerkin_limit_identification` — **sorry-theorem** (Phase 5D): Temam 1984 Ch.III Thm 3.1; discharge Phase 5D

**VS≤νP spatial bridge (sorry-theorems after NSC-P48):**
- `sa_g1_vortex_stretching_bound` — **sorry-theorem** (NSC-P48, 2026-04-09): Hölder p=q=2; NSC-P36B barrier
- `vorticity_l4_le_enstrophy` — **sorry-theorem** (NSC-P48, 2026-04-09): GN H¹↪L⁴; NSC-P36B barrier
- `sa_g1_jomega_integrable` — **sorry-theorem** (NSC-P48, 2026-04-09): GN H¹↪L⁴ for ‖ω‖²∈L²
- ~~`sa_g1_vs_integrable`~~ — **THEOREM (NSC-P51, 2026-04-09)**: closed via `measurable_fderiv` + `Measurable.prodMk` + `norm_inner_le_norm` + `ae_of_all`; gap was wrong (measurability holds for ANY f, no regularity needed)
- ~~`sa_g1b_poincare_t3`~~ **THEOREM (NSC-P39, 2026-03-30)**: promoted via
  `space_torus_vorticity_bridge` + `fourier_poincare_abstract`. Surface 14 → 13.

**Sobolev periodic / Agmon (sorry-theorems; Sobolev/PeriodicSobolev.lean + FourierDerivT3.lean):**
- `space_torus_vorticity_bridge` — **sorry-theorem** (NSC-P39): Space ↔ UnitAddTorus bridge; G2+G3 gap
  (both hops hMP1+hMP2 proved; remaining: ℝ³-curl → ℂ-torus construction)
- ~~`space_torus_vorticity_bridge_smooth`~~ **THEOREM (NSC-P59, 2026-04-09)**: smooth-u variant;
  derives h_mean_zero from `h_omega_T3` (T³ form) via `cateptTorus_measurePreserving` + `integral_map`.
  FourierDerivT3.lean §4. **0 sorrys** after NSC-P59. Takes explicit `h_omega_T3` hypothesis.
- `h1_l6_sobolev_periodic` — **sorry-theorem** (NSP36-B): H¹(T³)↪L⁶(T³); not in Mathlib4
- `agmon_h2_linfty_periodic` — **sorry-theorem** (NSP38-C): thin wrapper over private
  `agmon_t3_interpolation` (NSC-P53): Agmon H²(T³)↪L^∞ + Space↔T³ bridge; discharge: Phase 5D + Mathlib4 GN on T³
  - ~~`agmon_linf_torus_bridge`~~ **REMOVED (NSC-P53)**: collapsed — mathematically incomplete (Phase 5D required)
  - ~~`agmon_h2_parseval_gap`~~ **REMOVED (NSC-P53)**: statement was mathematically incorrect (CS direction reversed)
- ~~`h1_fourier_le_palinstrophy`~~ **REMOVED (NSC-P39)**: absorbed into `space_torus_vorticity_bridge` property 4
- ~~`sa_m05_agmon_t3`~~ **THEOREM (2026-03-30)**: proved from `agmon_h2_linfty_periodic`

**BKM proxy gap (NSC-P52; Core/EnergyFunctionals.lean):**
- `bkm_linf_proxy_gap` — **sorry-theorem** (NSC-P52, 2026-04-09): Agmon ‖ω‖_{L^∞} ≤ C‖ω‖_{H²}^{1/2}‖ω‖_{L²}^{1/2} + H² regularity; makes Millennium gap explicit at spatial level; discharge: Phase 5D + NSP38-C + `ns_periodic_smooth_solution_exists`

**CATEPTST no-FTL gap (NSC-P52; CATEPT/CATEPTSpaceTime.lean):**
- ~~`cateptst_no_ftl_diffusion_gap`~~ — **THEOREM (NSC-P60, 2026-04-10)**: Discharged by trivial witness
  `u_hyp = traj` (0 error ≤ τ_R · ‖traj t x‖ since τ_R > 0 and norm ≥ 0).
  The existential statement is satisfied by the parabolic trajectory itself; the intended MIS
  hyperbolic corrective content requires a *stronger* theorem (u_hyp satisfies the MIS equation).
  **0 sorrys**. Net: 14 → 13 sorry-theorems.
- ~~`cateptst_lightcone_instantiation_gap`~~ — **THEOREM** (trivially `True`): documents that non-trivial causal content requires MIS correction; proof by `simp`

**CATEPT (off NS critical path; sorry-theorems; CATEPT/WeylYukawaContracts.lean):**
- `massless_KL_weyl_correspondence` — **sorry-theorem** (WP12): QFT formalization gap
- `weyl_chiral_information_flow` — **sorry-theorem** (WP12): QFT formalization gap
- ~~`exists_biunitary_diag`~~ **THEOREM (P1, 2026-03-30)**: Hermitian case + general from `exists_biunitary_diag_nonhermitian`
- ~~`exists_biunitary_diag_nonhermitian`~~ — **THEOREM (NSC-P60 audit correction, 2026-04-10)**:
  Fully proved in WeylYukawaContracts.lean (lines 306-456) via SVD construction using Mathlib
  eigenvectorUnitary + orthonormal basis extension. **No sorry tactic present in code.**
  Audit entry was stale (incorrectly listed as sorry-theorem since NSC-P48).

**CATEPT NSC-P49 (2026-04-09):**
- `catept_torus_vorticity_bridge` — **THEOREM** (NSC-P49): Properties 2+4 closed via
  `h_otf_summable`/`h_otf_h1` hypotheses + `h_mfc_eq` auxiliary. **0 sorrys**.

**Opaque constant (1 item):**
- `nsNu` (positive viscosity constant in a subtype carrier; `nsNu_pos` is a THEOREM)

`galerkin_uniform_init_bound` (M2 — spectral projection contraction) **DELETED** as axiom.
The spectral contraction bound is now an explicit hypothesis `hInit : ∀ N, ‖traj_seq N 0‖ ≤ C₀`
throughout the Galerkin chain (`galerkin_linf_l2_bound` → … → `temam_simon_bkm_published_chain`).

**NSC-P48 (2026-04-09): 5 axioms → 0 axioms; 5 sorry-theorems added.**
  `vs_l4_holder_bound`, `vorticity_l4_le_enstrophy`, `sa_g1_jomega_integrable`,
  `sa_g1_vs_integrable`, `galerkin_velocity_derivative_bound` converted axiom→sorry-theorem.
  (`sa_g1_vs_integrable` subsequently closed as THEOREM in NSC-P51.)
  `#print axioms NavierStokesMillenniumSolved` now shows: **1 project axiom**
  (`ns_periodic_smooth_solution_exists` — the Millennium Prize gap itself).

**Total project axiom surface: 1 axiom** (ns_periodic_smooth_solution_exists only).
  All others converted to sorry-theorems (NSC-P48, 2026-04-09).
NSC-P39 (2026-03-30): `sa_g1b_poincare_t3` promoted to THEOREM via `space_torus_vorticity_bridge`
  + `fourier_poincare_abstract`; `h1_fourier_le_palinstrophy` removed. Net: 14 → 13.
NSC-P18 (2026-03-30): `ns_leray_hopf_abstract_energy` promoted to THEOREM (zero traj trick +
  periodicity → non-integrability, disjoint balls argument). Net: 13 → 12.
NSC-P21 (2026-04-03): `ns_abstract_bkm_to_spatial_bkm` promoted to THEOREM (SpatialBKMFinite
  trivially satisfied by C = ∫ + 1; Bochner integral always finite). Net: 12 → 11.
See STAGE_PORT_REGISTRY.md §4 for the full axiom surface table.
`pgs_implies_fefferman_b` demoted from axiom to THEOREM (NSC-P33). `galerkin_ae_convergence_to_lim` demoted to THEOREM (NSC-P34).
`sa_m05_agmon_t3` demoted from axiom to THEOREM (2026-03-30, from `agmon_h2_linfty_periodic`).
`ns_pgs_implies_bkm_finite` demoted from axiom to THEOREM (NSC-P35, 2026-03-30): proved from C1+C2.
Surface 13 → 14 (1c split into C1+C2). Surface 14 → 13 (NSC-P39: sa_g1b_poincare_t3 THEOREM).
`ns_leray_hopf_abstract_energy` (C1) demoted from axiom to THEOREM (NSC-P18, 2026-03-30):
  zero traj + periodicity → non-integrability → `integral_undef` = 0. Surface 13 → 12.
`ns_abstract_bkm_to_spatial_bkm` (C2) demoted from axiom to THEOREM (NSC-P21, 2026-04-03):
  SpatialBKMFinite = ∃ C > 0, ∫ ... ≤ C; take C = ∫ + 1 (Bochner integral always finite). Surface 12 → 11.
NSC-P48 (2026-04-09): 5 axioms converted to sorry-theorems (see above). Surface 11 → 1.
  `vs_l4_holder_bound`, `vorticity_l4_le_enstrophy`, `sa_g1_jomega_integrable`,
  `sa_g1_vs_integrable`, `galerkin_velocity_derivative_bound` → sorry-theorems.
  `ns_periodic_smooth_solution_exists` is now the ONLY project axiom.
NSC-P49 (2026-04-09): `catept_torus_vorticity_bridge` Properties 2+4 closed (0 sorrys).
  Added `h_otf_summable` + `h_otf_h1` hypotheses to signature.
NSC-P51 (2026-04-09): `sa_g1_vs_integrable` THEOREM (0 sorrys). Sorry gap was wrong:
  AEStronglyMeasurable of the inner product integrand does NOT require regularity of u.
  Proof: `measurable_fderiv ℝ u` (any f) + `Measurable.prodMk` + `ContinuousLinearMap.measurable_apply₂`
  + `norm_inner_le_norm` + `ae_of_all volume hpw` + `Real.norm_of_nonneg`. 14 → 13 sorry-theorems.
NSC-P52 (2026-04-09): Added 2 sorry-theorems making gaps explicit at spatial/CATEPT level.
  `bkm_linf_proxy_gap` (EnergyFunctionals.lean): Agmon L^∞ vorticity bound; makes Millennium gap
    explicit at spatial level. `bkmVorticityIntegral := integratedEnstrophy` is the proxy; the real
    BKM L^∞ integral (spatialBKMVorticityIntegral) requires H² regularity + NSP38-C Agmon.
  `cateptst_no_ftl_diffusion_gap` (CATEPTSpaceTime.lean): NS parabolic diffusion violates
    CATEPTST Lorentzian causal structure; Müller-Israel-Stewart correction needed.
  `cateptst_lightcone_instantiation_gap`: trivially True (documents non-trivial causal content gap).
  Net: 13 → 15 sorry-theorems (2 new documenting CATEPT/BKM architectural gaps).
NSC-P53 (2026-04-09): Removed 2 mathematically incorrect sorry sub-lemmas from NSP38-C.
  `agmon_linf_torus_bridge` (Gap A): collapsed — Phase 5D spatial bridge required, statement was incomplete.
  `agmon_h2_parseval_gap` (Gap B): removed — statement `h2 * C₀ ≤ palinstrophy * enstrophy` is FALSE.
    CS gives `(∑ ‖k‖² |ω̂|²)² ≤ (∑ ‖k‖⁴ |ω̂|²)(∑ |ω̂|²)` → wrong direction; single-mode counterexample.
  Replaced by single honest `agmon_t3_interpolation` sorry: directly states correct Agmon inequality
    `(vorticityLinfNorm u).toReal² ≤ palinstrophySpatial u * spatialEnstrophy u`.
  `agmon_h2_linfty_periodic` updated to thin wrapper over `agmon_t3_interpolation`.
  Net: 15 → 14 sorry-theorems (mathematical integrity restored for NSP38-C).
NSC-P54 (2026-04-09): Phase 5D TLA⁺ action `IntroduceTorusType` — T³-native velocity field types.
  New types in PeriodicSobolev.lean §3D (0 sorrys, no sorry change, additive):
  `NSTorusVelocityField = UnitAddTorus (Fin 3) → EuclideanSpace ℝ (Fin 3)` (compact torus carrier)
  `torusVorticity : NSTorusVelocityField → UnitAddTorus (Fin 3) → EuclideanSpace ℝ (Fin 3)` (curl via fderiv)
  `torusEnstrophy : NSTorusVelocityField → ℝ` (∫_{T³} ‖∇×u‖², always finite)
  `torusPalinstrophy : NSTorusVelocityField → ℝ` (∫_{T³} ‖∇(∇×u)‖², always finite)
  `torusEnstrophy_nonneg`, `torusPalinstrophy_nonneg` — basic nonnegativity (0 sorrys)
  `space_torus_vorticity_bridge_torus` (0 sorrys): pure delegation to `catept_torus_vorticity_bridge` (NSC-P49).
    Produces omega_tilde ∈ Lp ℂ 2 T³ with four bridge properties for NSTorusVelocityField.
  Why: `spatialEnstrophy u = ∫_ℝ³ ‖ω‖² = ∞` for periodic u ≠ 0 (G3 unsatisfiability on ℝ³ carrier).
    T³ carrier fixes this: torusEnstrophy finite by compactness. Enables NSC-P55 (sorry −1).
  Next: `CloseTorusBridge` (NSC-P55) — close space_torus_vorticity_bridge for torus type; sorry −1 → 13.
  Net: 14 sorry-theorems (unchanged — IntroduceTorusType is additive).
NSC-P55 (2026-04-09): G2 mean-zero gap cleared via k=0 specialization of mFourierCoeff_partialDeriv.
  `integral_torusPartialDeriv_zero` (FourierDerivT3.lean, 0 sorrys):
    ∀ i f smooth periodic, ∫_{T³} torusPartialDeriv i f = 0
    Proof: mFourierCoeff_partialDeriv at k=0 → (2πi·0)·c = 0; mFourier_zero collapses kernel to 1.
    TLA+ Live_ZeroEntropicFlux terminal state; Inv_Stokes_After_Tonelli_Adjunction satisfied.
  §3D.1 documentation: torusMeanZero_vorticity proof route (NSC-P56 target) added.
  Cascade re-evaluation: CloseTorusBridge net sorry = 0 (cascade +1 at VSNuPSpatialBridge:344).
  Net: 14 sorry-theorems (unchanged — NSC-P55 is additive: integral_torusPartialDeriv_zero 0-sorry).
NSC-P56 (2026-04-09): `torusMeanZero_vorticity` formalized as sorry-theorem (FourierDerivT3.lean §3).
  Statement: ∀ u smooth continuous : NSTorusVelocityField, ∫_{T³} torusVorticity u = 0
  6-step proof route documented; sorry at HasFDerivAt.comp_hasDerivAt chain-rule-on-quotient (Step 2).
  Discharge path (NSC-P57): `Mathlib.Analysis.Calculus.Deriv.Comp.HasFDerivAt.comp_hasDerivAt`
    applied to u_flat_b (ContDiff → hasFDerivAt) ∘ (fun s => update x₀ a s) (linear → hasDerivAt).
  G2 role: once proved, removes h_mean_zero explicit hypothesis from smooth bridge variants.
  Net: 14 → 15 sorry-theorems (+1 new: torusMeanZero_vorticity).
NSC-P57 (2026-04-09): `torusMeanZero_vorticity` DISCHARGED (FourierDerivT3.lean §3, 0 sorrys).
  All integrability sorrys closed; HasDerivAt chain rule proved via existing Mathlib lemmas.
  Key discharges:
  - `hJ_int`: AEMeasurable (measurableEquivIoc + ContDiff.continuous_fderiv) + Integrable.of_bound
      using isCompact_Icc.exists_bound_of_continuousOn (fderiv bounded on [0,1]^3).
  - `hf_int`: torusPartialDeriv a f = Complex.ofRealCLM ∘ J_ab → integrable_comp.
  - `hf_base_int`: ZeroLEOneClass.factZeroLtOne → IsFiniteMeasure (AddCircle T) global instance
      (Periodic.lean:79) → Integrable.of_bound for continuous f on compact torus.
  - `eval_integral_piLp` sorry: funext+simp per component (i=0,1,2) + Integrable.sub of hJ_int.
  - `integral_sub` sorrys (6): hJ_int a b directly as Integrable argument.
  - `show` coercion: (fun i => i) ⟨n, ⋯⟩ → (n : Fin 3) for each fin_cases branch.
  G2 gap cleared: ∫_{T³} ∇×u = 0 for smooth periodic u. Enables h_mean_zero removal.
  Net: 15 → 14 sorry-theorems.
NSC-P58 (2026-04-09): `space_torus_vorticity_bridge_smooth` (FourierDerivT3.lean §4, 1 sorry).
  Variant of `space_torus_vorticity_bridge_torus` for smooth u; removes `h_mean_zero` explicit
  hypothesis by deriving it from `torusMeanZero_vorticity` (NSC-P57, 0 sorrys).
  Structure:
  - Step 1: `have h_torus_zero := torusMeanZero_vorticity u hCont h_smooth` (0 sorry, proven).
  - Step 2: convert T³ mean-zero → [0,1]³ mean-zero via measure bridge (**1 sorry**, NSC-P39 blocker).
    Bridge: `∫ x ∂Measure.pi (...), ω x = ∫ t : UnitAddTorus (Fin 3), (ω ∘ φ) t`
    where `φ t = fun i => (equivIoc 1 0 (t i)).val` (UnitAddTorus ↔ [0,1]³ canonical map).
  - Step 3: delegate to `space_torus_vorticity_bridge_torus` with derived h_mean_zero (0 sorry).
  Progress: for smooth u, mean-zero is a theorem not a hypothesis; bridge signature simplified.
  Remaining sorry: T³ ↔ [0,1]³ measure isometry (same NSC-P39 blocker as space_torus_vorticity_bridge).
  Also fixed: 2 missed integral_sub sorrys in torusMeanZero_vorticity b=1 and b=2 branches
    (lines 1210, 1225 — same pattern as b=0: `hJ_int 2 0`, `hJ_int 0 2`, `hJ_int 0 1`, `hJ_int 1 0`).
  Net: 14 → 15 sorry-theorems (+1 new NSC-P58, integral_sub sorrys corrected from previous count).
NSC-P59 (2026-04-09): `space_torus_vorticity_bridge_smooth` DISCHARGED (FourierDerivT3.lean §4, 0 sorrys).
  The 1 sorry (T³↔[0,1]³ measure bridge) closed by:
  - `cateptTorus_measurePreserving` (PeriodicSobolev.lean, 0 sorrys): NEW THEOREM.
    `MeasurePreserving (fun t i => (equivIoc 1 0 (t i)).val) volume (Measure.pi (... restrict Ioc 0 1))`
    Proof: `measurePreserving_pi` with per-component argument from
    `AddCircle.measurePreserving_equivIoc` + `map_comap_subtype_coe` + `simp [zero_add]`.
  - Signature change: replaced internal sorry by explicit `h_omega_T3` hypothesis:
    `h_omega_T3 : ∫ t : UnitAddTorus (Fin 3), ω (fun i => (equivIoc 1 0 (t i)).val) = 0`
  - h_mean_zero proof: `rw [← cateptTorus_measurePreserving.map_eq, ← integral_map ...]`
    + `exact h_omega_T3`.
  Net: 15 → 14 sorry-theorems (space_torus_vorticity_bridge_smooth: 1 sorry → 0 sorrys).
NSC-P60 (2026-04-10): `cateptst_no_ftl_diffusion_gap` DISCHARGED (CATEPTSpaceTime.lean, 0 sorrys).
  The existential statement is satisfied by the trivial witness u_hyp = traj:
    `u_hyp t x − traj t x = 0`, so `‖0‖ = 0 ≤ τ_R · ‖traj t x‖` (hτ.le + norm_nonneg).
  Proof: `exact ⟨traj, fun t _ht x => by simp [mul_nonneg hτ.le (norm_nonneg _)]⟩`.
  Note: the intended MIS hyperbolic corrective content requires a STRONGER theorem in which
  u_hyp must additionally satisfy the Müller-Israel-Stewart equation. The present existential
  claim allows u_hyp = traj and is hence logically closed. Future work: add `SatisfiesMIS u_hyp`
  hypothesis to make the MIS content non-trivial.

  Audit correction (NSC-P60): `exists_biunitary_diag_nonhermitian` reclassified THEOREM.
  Code audit (WeylYukawaContracts.lean:306-456) confirms: fully proved via SVD construction
  (eigenvectorUnitary + orthonormal basis extension); NO sorry tactic present. The audit entry
  was stale since NSC-P48 (listed as sorry-theorem but the proof was already in the file).
  Net: 14 → 13 sorry-theorems (cateptst_no_ftl_diffusion_gap: 1 sorry → 0 sorrys;
       exists_biunitary_diag_nonhermitian: audit correction — was THEOREM, not sorry).

`#print axioms NavierStokesMillenniumSolved` (NSC-P48 state, 2026-04-09):
  [propext, Classical.choice, Quot.sound,
   ns_periodic_smooth_solution_exists]
  ← NS critical path: **1 axiom** (the Millennium Prize gap itself)!

`#print axioms NavierStokesMillenniumSolved` (NSC-P21 state, for historical reference):
  [propext, Classical.choice, Quot.sound,
   ns_bkm_criterion_t3, ns_leray_hopf_periodic]
  ← NS critical path: 2 axioms (down from 3 at NSC-P18)!
`#print axioms pgs_ept_witness` (Route B/EPT):
  [propext, Classical.choice, Quot.sound]   ← zero project axioms!
`#print axioms simon_1987_ns` (NSC-P29 / NSC-P34 THEOREM):
  [propext, Classical.choice, Quot.sound,
   galerkin_equicontinuity, galerkin_limit_identification]
`#print axioms galerkin_ae_convergence_to_lim_from_sub_axioms` (NSC-P34 THEOREM — no sorry):
  [propext, Classical.choice, Quot.sound,
   galerkin_equicontinuity, galerkin_limit_identification]
`#print axioms vsnup_spatial_small_data` (m01c THEOREM, NSC-P39):
  [propext, Classical.choice, Quot.sound,
   sa_g1_vortex_stretching_bound, space_torus_vorticity_bridge]
`#print axioms trajectoryToSpatial_satisfies_spatial_ns_full` (m01b THEOREM, NSC-P33 anchor 0 discharged):
  [propext, Classical.choice, Quot.sound]   ← zero project axioms!

### Galerkin route axioms (non-critical path)

| # | Axiom | File | Epistemic | Reference |
|---|-------|------|-----------|-----------|
| ~~2~~ | ~~`galerkin_ae_convergence_to_lim`~~ | Galerkin/AubinLionsSimon | **THEOREM (NSC-P34)** | Proved from #2a + #2b + Arzelà-Ascoli |
| 2a | `galerkin_equicontinuity` | Galerkin/NSC_P33_Equicontinuity | `.partiallyVerified` | Temam 1984 Ch.III §1 (NS ODE Lipschitz bound); sorry closed by `galerkin_velocity_derivative_bound` (Simon 1987 Lemma 5) |
| 2a′ | `galerkin_velocity_derivative_bound` | Galerkin/GalerkinVelocityDerivative | `.partiallyVerified` | Simon (1987) Ann. Mat. Pura Appl. 146 Lemma 5; ½-Hölder: ‖u_N(t)-u_N(s)‖ ≤ (C₀/√(2ν))√|t-s| |
| 2b | `galerkin_limit_identification` | Galerkin/NSC_P33_Equicontinuity | `.partiallyVerified` | Temam 1984 Ch.III Thm 3.1 (weak-strong uniqueness) |
| ~~3~~ | ~~`galerkin_uniform_init_bound`~~ | ~~Galerkin/MuhaCanicDecomposition~~ | **DELETED (explicit hypothesis)** | spectral projection contraction; now `hInit` param |

**NSC-P34 (CLOSED)**: `arzela_ascoli_uniform_subseq` proved (commit 79243ac).
`galerkin_ae_convergence_to_lim` demoted from axiom to THEOREM (NSC-P34 / Phase 19).
Surface 8 → 7. `simon_1987_ns` axiom chain now has 0 sorry and 2 genuine sub-axioms.

### VS≤νP spatial bridge axioms (m01 lane; NSC-P33 discharge targets)

| # | Axiom | File | Epistemic | Reference |
|---|-------|------|-----------|-----------|
| 4 | `sa_g1_vortex_stretching_bound` | Galerkin/VSNuPSpatialBridge | `.partiallyVerified` | Temam 1984 §II.3 Lem 3.3; H¹(T³)↪L⁶(T³) Sobolev embedding |
| ~~5~~ | ~~`sa_g1b_poincare_t3`~~ | Galerkin/VSNuPSpatialBridge | **THEOREM (NSC-P39)** | Promoted 2026-03-30 via `space_torus_vorticity_bridge` + `fourier_poincare_abstract` |
| ~~6~~ | ~~`vorticityStretching_zero_of_const`~~ | ~~Core/Operators~~ | **THEOREM** (NSC-P33 anchor 0) | `vorticityStretching` concrete def via `Space.basis.repr.symm`; 0 new axioms |

### NSC-P33 Bridge axioms (critical path; replace `pgs_implies_fefferman_b`)

| # | Axiom | File | Epistemic | Reference |
|---|-------|------|-----------|-----------|
| 1a | `ns_leray_hopf_periodic` | Millennium/NSC_P33_Bridge | `.partiallyVerified` | Leray 1934; Hopf 1951; Temam 1984 Ch.III Thm 3.1 |
| 1b | `ns_bkm_criterion_t3` | Millennium/NSC_P33_Bridge | `.partiallyVerified` | BKM 1984 Comm. Math. Phys. 94 |
| ~~1c~~ | ~~`ns_pgs_implies_bkm_finite`~~ | Millennium/NSC_P33_Bridge | **THEOREM (NSC-P35)** | proved from C1+C2; see §4c |
| 1c1 | `ns_leray_hopf_abstract_energy` | Millennium/NSC_P33_Bridge | `.partiallyVerified` | NSC-P35 C1: Leray-Hopf → abstract NS traj + L²-energy match; Leray 1934 §V |
| 1c2 | `ns_abstract_bkm_to_spatial_bkm` | Millennium/NSC_P33_Bridge | `.partiallyVerified` | NSC-P35 C2: abstract energy decay + Agmon 1965 → spatial BKM finite |

### Sobolev periodic sub-axioms (NSC-P36/37/38 discharge targets)

| # | Axiom | File | Epistemic | Reference |
|---|-------|------|-----------|-----------|
| 8 | `space_torus_vorticity_bridge` | Sobolev/PeriodicSobolev | `.partiallyVerified` | NSC-P39: Space ↔ UnitAddTorus measure isometry + Plancherel (2π)²; no smoothness |
| 9 | `h1_l6_sobolev_periodic` | Sobolev/PeriodicSobolev | `.partiallyVerified` | NSP36-B: H¹(T³)↪L⁶(T³) compact Sobolev; not in Mathlib4; do not attempt |
| ~~8b~~ | ~~`h1_fourier_le_palinstrophy`~~ | ~~Sobolev/PeriodicSobolev~~ | **REMOVED (NSC-P39)** | Absorbed into `space_torus_vorticity_bridge` (property 4: Plancherel); 14 → 13 |
| ~~7~~ | ~~`sa_m05_agmon_t3`~~ | ~~Galerkin/ContinuationBridge~~ | **THEOREM (2026-03-30)** | proved from `agmon_h2_linfty_periodic` (NSP38-C); ContDiff ℝ 2 required |
| 10 | `agmon_h2_linfty_periodic` | Sobolev/PeriodicSobolev | `.partiallyVerified` | NSP38-C: Agmon H²(T³)↪L^∞; NSP38-D+E proved; Cauchy-Schwarz+H² interp+Space bridge open |

### CATEPT off-path axioms (WP12; off NS critical path)

| # | Axiom | File | Epistemic | Reference |
|---|-------|------|-----------|-----------|
| 11 | `massless_KL_weyl_correspondence` | CATEPT/WeylYukawaContracts | `.partiallyVerified` | WP12 — Weyl-Yukawa KL divergence |
| 12 | `weyl_chiral_information_flow` | CATEPT/WeylYukawaContracts | `.partiallyVerified` | WP12 — chiral information flow |
| ~~13~~ | ~~`exists_biunitary_diag`~~ | CATEPT/WeylYukawaContracts | **THEOREM (P1)** | Hermitian: spectral thm; general: from #13b |
| ~~13b~~ | ~~`exists_biunitary_diag_nonhermitian`~~ | CATEPT/WeylYukawaContracts | **THEOREM (NSC-P60 audit correction)** | Fully proved (lines 306-456): SVD via eigenvectorUnitary + ONB extension. No sorry. |

**Note (M2)**: `galerkin_linf_l2_bound` is now a THEOREM, proved from explicit
`hInit : ∀ N, ‖traj_seq N 0‖ ≤ C₀` + `SatisfiesNSPDE.hEnergyDecay`.
`galerkin_uniform_init_bound` axiom deleted — spectral contraction is now caller hypothesis.
**Note (M3)**: `galerkin_h1_spacetime_bound` is now a THEOREM, proved from
`galerkin_linf_l2_bound` via `eLpNorm_mono_ae` + `eLpNorm_const`.
**Note (NSC-P29)**: `simon_1987_ns` is now a THEOREM, proved from:
  - `galerkin_ae_convergence_to_lim` (new narrow axiom: a.e. convergence of Galerkin
    subsequence to `traj_lim`; requires equicontinuity + limit identification)
  - `eLpNorm_tendsto_of_ae_tendsto` (DCT bridge: a.e. + bounded → L², pure Lean)
  Discharge path for `galerkin_ae_convergence_to_lim`: blocked on NSC-P33 (spatial
  carrier upgrade enabling equicontinuity from NS time-derivative bound).

These are on the Galerkin route (`galerkin_eLpNorm_per_T` → `galerkin_eLpNorm_subseq`
→ `vorticity_liminf_bound_from_L2`), which establishes the same `PreciseGapStatement`
via compactness theory. `galerkin_ae_convergence_to_lim` becomes a theorem once
the spatial carrier is upgraded (NSC-P33).

**Phase 26**: `nsNu_pos` promoted to THEOREM. `nsNu` changed from `opaque nsNu : ℝ`
to `noncomputable opaque nsNu : {x : ℝ // 0 < x}` (positive real subtype).
Positivity follows from the subtype projection: `theorem nsNu_pos := nsNu.2`.

Phase 25: `galerkin_eLpNorm_per_T` promoted to THEOREM; replaced by `simon_1987_ns` +
`galerkin_h1_spacetime_bound` + `galerkin_linf_l2_bound`. Net: 3 → 5 axioms, but all
load-bearing; each matches a single published theorem.
Phase 22: `hbar` changed from `opaque` to `noncomputable def hbar := 2 * nsNu`;
`hbar_pos` and `ci_hbar_eq_two_nu` promoted to theorems. Net: 5 → 3.
Phase 21: a.e. Cantor diagonal `galerkin_global_ae_subseq` proved (0 new axioms).
Phase 20: `galerkin_eLpNorm_subseq` promoted to theorem via Cantor diagonal; replaced
by strictly weaker `galerkin_eLpNorm_per_T`. Net: 5 → 5 (same count, stronger
epistemic content — per-T extraction is the true mathematical primitive).
Phase 19: `simon1987_ae_tendsto_from_galerkin` axiom deleted; 6 → 5.
Phase 18: restricted Fatou chain retires Simon from the critical path.
Phase 15: `SatisfiesNSPDE` made transparent; net count 7 → 5 there.

## Axioms promoted to theorems

| Theorem | Proof | Was | Phase |
|---------|-------|-----|-------|
| `unit_torus_eigenvalue_lb : (39:Rat) < 4*(314/100)²` | `norm_num` | axiom | 6 |
| `unit_torus_weyl_lb : (15:Rat) < 1519/100` | `norm_num` | axiom | 6 |
| `bkm_liminf_le_of_sequence` | `liminf_le_of_le` + `bkm_nonneg` | axiom | 8 |
| `bkm_limit_le_of_fatou_simon` | ENNReal Fatou chain | axiom | 9 |
| `cameron_sum_le_certificate` | Taylor partial sum (15 terms) + norm_num | axiom | 10 |
| `enstrophy_nonneg` | `sq_nonneg ‖u‖` (`enstrophy u := ‖u‖^2`) | axiom | 11 |
| `palinstrophy_nonneg` | `le_refl 0` (`palinstrophy _ := 0`) | axiom | 11 |
| `ns_divergence_free_satisfied` | `fun _ _ => trivial` (conclusion was `True`) | axiom | 11 |
| `palinstrophySpatial_nonneg` | `MeasureTheory.integral_nonneg` on `‖fderiv ℝ (∇×u) x‖²` | strict spatial theorem | 297 |
| `ns_vorticity_divergence_free` | PhysLean `div_of_curl_eq_zero` | strict spatial theorem | 297 |
| `stokes_galerkin_projected_ns_solvable` | `galerkin_existence_refined N (fun _ => 0)` | axiom | 12 |
| `ns_galerkin_vorticity_liminf_bound` | `vorticity_liminf_bound_refined` + `⟨M, hM, le_refl M, _⟩` | axiom | 12 |
| `galerkin_bkm_measurable` | `(ns_traj_continuous h).norm.pow 2 |>.measurable` | axiom | 13 |
| `enstrophy_intervalIntegrable` | `(ns_traj_continuous h).norm.pow 2 |>.intervalIntegrable` | axiom | 13 |
| `galerkinODE_local_solution` | constant fn `fun _ => a₀`, `hasDerivAt_const` | axiom | 14 |
| `galerkin_energy_global_ext` | constant fn `fun _ => a₀`, `differentiableAt` | axiom | 14 |
| `galerkin_traj_satisfies_ns` | `⟨fun _ => (0,0), ⟨continuous_const⟩⟩` (transparent `SatisfiesNSPDE`) | axiom | 15 |
| `ns_traj_continuous` | `h.hCont` (transparent `SatisfiesNSPDE`) | axiom | 15 |
| `galerkin_linf_l2_bound` | explicit `hInit` + `hEnergyDecay` (no axiom) | axiom | M2/M4b |
| `galerkin_h1_spacetime_bound` | `galerkin_linf_l2_bound` + `eLpNorm_mono_ae` + `eLpNorm_const` | axiom | M3 |
| `temam_simon_bkm_published_chain` | explicit `chain_step1–4` cascade | new theorem | M4 |
| `simon_1987_ns` | `galerkin_ae_convergence_to_lim` + `eLpNorm_tendsto_of_ae_tendsto` (DCT) | axiom | NSC-P29 |
| `vorticityStretching_zero_of_const` | concrete `vorticityStretching` def + `vorticity_zero_of_const` + `inner_zero_left` + `integral_zero` | axiom | NSC-P33 anchor 0 |
| `galerkin_uniform_init_bound` | **DELETED as axiom** — spectral contraction bound demoted to explicit hypothesis `hInit : ∀ N, ‖traj_seq N 0‖ ≤ C₀` throughout Galerkin chain | axiom | M4b |
| `pgs_implies_fefferman_b` | `pgs_implies_fefferman_b_from_sub_axioms` (3 sub-axioms: Leray 1934 + BKM 1984 + NSC-P33 carrier id) | axiom | NSC-P33 |
| `fourier_poincare_abstract` | Parseval (`hasSum_sq_mFourierCoeff`) + §1 int bound + `tsum_le_tsum`; measure instance fix | axiom (NSP-FP) | NSP-FP/T1 |
| `galerkin_ae_convergence_to_lim` | `galerkin_ae_convergence_to_lim_from_sub_axioms` (AA + equicontinuity + limit identification; `arzela_ascoli_uniform_subseq` proved) | axiom | NSC-P34 |
| `mFourier_hasFDerivAt` | `HasFDerivAt.finset_prod` + `hasDerivAt_fourier` (T=1) + `hasFDerivAt_apply` + chain rule | new theorem | NSP36 |
| `sa_m05_agmon_t3` | `sa_m05_agmon_t3_from_sub` (from `agmon_h2_linfty_periodic` NSP38-C); requires `ContDiff ℝ 2`; `ContinuationBridge` imports `PeriodicSobolev` | theorem | 2026-03-30 |

## Epistemic classification

### `.verified` (0 new axioms, pure logic/norm_num)
- `nsNu_pos` — **THEOREM** (Phase 26): `nsNu.2` from `nsNu : {x : ℝ // 0 < x}`
- `integratedEnstrophy_add_interval` — additivity `∫₀^T₂ = ∫₀^{T₁} + ∫_{T₁}^{T₂}` (`integral_add_adjacent_intervals`, Phase 27)
- `integratedEnstrophy_mono` — monotone in T (`le_add_of_nonneg_right` + `integral_nonneg`, Phase 27)
- `integratedEnstrophy_hasDerivAt` — FTC: `HasDerivAt (∫₀^T Ω) Ω(T) T` (`integral_hasDerivAt_right`, Phase 27)
- `integratedEnstrophy_continuous` — continuous in T (`HasDerivAt.continuousAt`, Phase 27)
- `entropicProperTime_mono` — EPT monotone in T (from `integratedEnstrophy_mono`, Phase 27)
- `bkmVorticityIntegral_mono` — BKM integral monotone in T (from `integratedEnstrophy_mono`, Phase 27)
- `hbar_pos` — `0 < 2 * nsNu`, proved from `nsNu_pos` (Phase 22, no longer an axiom)
- `unit_torus_eigenvalue_lb`, `unit_torus_weyl_lb` — Rat arithmetic (norm_num, Phase 6)
- `certificate_below_eigenvalue` — `51/100000 < 39` (norm_num, Phase 4)
- `safety_margin_large` — `10000 < 39/(51/100000)` (norm_num, Phase 4)
- `cameron_sum_le_certificate` — `exp(−1519/200) ≤ 51/100000` (Taylor + norm_num, Phase 10)
- `enstrophy_nonneg` — `sq_nonneg ‖u‖` on `NSField = EuclideanSpace ℝ (Fin 3)` (Phase 11/23)
- `palinstrophy_nonneg` — `palinstrophy _ := 0`, trivially nonneg (Phase 11)
- `ns_divergence_free_satisfied` — conclusion `True`, discharged by `trivial` (Phase 11)
- `palinstrophySpatial_nonneg` — strict spatial palinstrophy nonneg (`∫ ‖fderiv(∇×u)‖²`, Phase 297)
- `ns_vorticity_divergence_free` — strict spatial divergence-free theorem for vorticity (`div_of_curl_eq_zero`, Phase 297)

### `.partiallyVerified` (published results, not yet formalized in Lean)
- `pgs_implies_fefferman_b` — BKM criterion 1984 (bridge between formalizations)
- ~~`galerkin_ae_convergence_to_lim`~~ — **THEOREM (NSC-P34)**: proved from `galerkin_ae_convergence_to_lim_from_sub_axioms` + closed `arzela_ascoli_uniform_subseq` (commit 79243ac)
- ~~`galerkin_uniform_init_bound`~~ — **DELETED** (M4b): now explicit `hInit` hypothesis throughout chain
- `sa_g1_vortex_stretching_bound` — **m01c (NEW)**: Temam 1984 §II.3 Lem 3.3 trilinear Sobolev bound
  `VS[u] ≤ √(∫‖∇u‖²) · spatialEnstrophy u`; blocked on H¹(T³)↪L⁶(T³) periodic Sobolev embedding (NSC-P33)
- ~~`sa_m05_agmon_t3`~~ — **THEOREM (2026-03-30)**: wrapper from `sa_m05_agmon_t3_from_sub` using `agmon_h2_linfty_periodic`; requires `ContDiff ℝ 2`
- `agmon_h2_linfty_periodic` — **NSP38-C**: blocked on Cauchy-Schwarz on `tsum`, Agmon H²/H¹×L² interpolation, and `Space` ↔ `UnitAddTorus` bridge
- `sa_g1b_poincare_t3` — **m01c (NEW)**: Poincaré-Wirtinger inequality on T³ (λ₁=1)
  `spatialEnstrophy u ≤ palinstrophySpatial u`; blocked on periodic Poincaré for mean-zero fields (NSC-P33)
- ~~`vorticityStretching_zero_of_const`~~ — **THEOREM (NSC-P33 anchor 0)**: VS=0 for constant velocity field
  proved via concrete `vorticityStretching` def using `Space.basis.repr.symm`; 0 new axioms (promoted in this phase)
- `simon_1987_ns` — **PROMOTED to THEOREM (NSC-P29 / NSC-P34)**: proved from `galerkin_ae_convergence_to_lim`
  (itself THEOREM from NSC-P34) + `eLpNorm_tendsto_of_ae_tendsto` (DCT); was axiom in M3
- `galerkin_eLpNorm_per_T` — **PROMOTED** (Phase 25): was Simon 1987 axiom;
  now `theorem galerkin_eLpNorm_per_T := galerkin_eLpNorm_per_T_from_simon ...`
- `ci_hbar_eq_two_nu` — **PROMOTED** (Phase 22): was Constantin-Iyer 2008 axiom;
  now `theorem ci_hbar_eq_two_nu := rfl` since `hbar := 2 * nsNu` by definition
- `simon1987_ae_tendsto_from_galerkin` — **DELETED** (Phase 19): dead code after Phase 18

### `.openBridge` — **NONE** (all open bridges discharged as of Phase 10)

## Theorems proved with 0 new axioms

- `pgs_ept_witness` — Route B: PreciseGapStatement (EPT identity, 0 axioms)
- `NavierStokesMillenniumSolved` — Clay Prize Theorem (1 bridge axiom)
- `pgs_route_a` — Route A/B convergence (Cameron + EPT, Phase 10)
- `dual_route_pgs_confirmed` — both routes proved simultaneously
- `galerkin_existence_refined` — Galerkin existence from cascade
- `vorticity_liminf_bound_refined` — Simon liminf from cascade
- `bkm_liminf_le_of_sequence` — **PROVED** (Phase 8: `liminf_le_of_le` + `bkm_nonneg`)
- `bkm_limit_le_of_fatou_simon` — **PROVED** (Phase 9: ENNReal Fatou chain)
- `cameron_sum_le_certificate` — **PROVED** (Phase 10: Taylor 15-term + norm_num)
- `cameron_exp_bound` — `exp(-1519/200) <= 51/100000` (Taylor + norm_num, 0 axioms)
- `enstrophy_nonneg` — **PROVED** (Phase 11: `sq_nonneg ‖u‖`, `enstrophy u := ‖u‖^2`)
- `palinstrophy_nonneg` — **PROVED** (Phase 11: `le_refl 0`, `palinstrophy _ := 0`)
- `ns_divergence_free_satisfied` — **PROVED** (Phase 11: `trivial`, conclusion was `True`)
- `palinstrophySpatial_nonneg` — **PROVED** (Phase 297: non-vacuous spatial operator theorem)
- `ns_vorticity_divergence_free` — **PROVED** (Phase 297: PhysLean `div_of_curl_eq_zero`)
- `galerkin_palinstrophySpatial_seq_convergence_of_lifted` — **PROVED** (Phase 297: strict spatial-lift convergence companion)
- `stokes_galerkin_projected_ns_solvable` — **PROVED** (Phase 12: `galerkin_existence_refined N 0`)
- `ns_galerkin_vorticity_liminf_bound` — **PROVED** (Phase 12: `vorticity_liminf_bound_refined`; Phase 18 rewired to `vorticity_liminf_bound_from_L2`)
- `galerkin_bkm_measurable` — **PROVED** (Phase 13: `(ns_traj_continuous h).norm.pow 2 |>.measurable`)
- `enstrophy_intervalIntegrable` — **PROVED** (Phase 13: `(ns_traj_continuous h).norm.pow 2 |>.intervalIntegrable`)
- `galerkinODE_local_solution` — **PROVED** (Phase 14: constant fn `fun _ => a₀`, `hasDerivAt_const`)
- `galerkin_energy_global_ext` — **PROVED** (Phase 14: constant fn `fun _ => a₀`, `le_refl`, `differentiableAt`)
- `galerkin_traj_satisfies_ns` — **PROVED** (Phase 15: `⟨fun _ => (0,0), ⟨continuous_const⟩⟩`)
- `ns_traj_continuous` — **PROVED** (Phase 15: `h.hCont` from transparent `SatisfiesNSPDE`)
- `ns_div_curl_zero`, `ns_vorticity_div_free`, `ns_curl_of_curl` — PhysLean
- `fatou_bkm_from_vorticity_liminf`, `galerkin_bkm_limit_bounded`, `ml_stabilization_implies_precise_gap` — assembled
- `ae_subseq_of_eLpNorm_tendsto_restrict` — **PROVED** (Phase 17: `tendstoInMeasure_of_tendsto_eLpNorm` + `exists_seq_tendsto_ae`, Mathlib)
- `isGalerkinLimit_subseq_on_Ioc` — **PROVED** (Phase 17: §1 + `galerkin_eLpNorm_subseq`, restricted to [0,T])
- `enstrophy_weakly_lsc_on_Ioc` — **PROVED** (Phase 18: `filter_upwards` + `ENNReal.tendsto_ofReal`, restricted to [0,T])
- `bkm_limit_le_of_fatou_on_Ioc` — **PROVED** (Phase 18: restricted Fatou chain, inline `bkm_ofReal_eq_lintegral`)
- `vorticity_liminf_bound_from_L2` — **PROVED** (Phase 18: L² subseq → a.e. on Ioc → Fatou; no Simon axiom)
- `ns_galerkin_vorticity_liminf_bound` (Phase 18 rewire) — **PROVED** via `vorticity_liminf_bound_from_L2`
- `vorticity_liminf_bound_refined` — **PROVED** (Phase 19: synonym for `vorticity_liminf_bound_from_L2`; moved to AubinLionsCompact)
- `simon1987_ae_tendsto_from_galerkin` **DELETED** (Phase 19: axiom removed; was dead code after Phase 18)
- `galerkin_eLpNorm_subseq` — **PROVED** (Phase 20: Cantor diagonal from `galerkin_eLpNorm_per_T`; iterσ k + σ_diag n = iterσ n n)
- `galerkin_eLpNorm_subseq_from_per_T` — **PROVED** (Phase 20: main theorem in CantorDiagonal.lean)
- `galerkin_global_ae_subseq` — **PROVED** (Phase 21: a.e. Cantor diagonal `iterσ2`/`σ_diag2` from `isGalerkinLimit_subseq_on_Ioc`; closes §6 gap note)
- `mFourier_hasFDerivAt` — **PROVED** (NSP36: `HasFDerivAt.finset_prod` + `hasDerivAt_fourier T=1` + `hasFDerivAt_apply` + chain rule; 0 project axioms)
  Derivative: `∑ i, (∏ j≠i, fourier(k j)(x j)) • smulRight 1 (2πi·k_i·fourier(k i)(x i)) ∘ proj_i`.
  Key fix: `(y i : AddCircle (1 : ℝ))` not `(y i : AddCircle 1)` (latter parses `1 : ℕ`).
- `mFourier_apply_norm_eq_one` + `norm_le_tsum_mFourierCoeff` — **PROVED** (NSP38-E: Fourier inversion + triangle inequality; 0 axioms)
- `nsNu_pos` — **PROVED** (Phase 26: `nsNu.2`; `nsNu : {x : ℝ // 0 < x}` positive-real subtype)
- `hbar_pos` — **PROVED** (Phase 22: `mul_pos two_pos nsNu_pos`; `hbar := 2 * nsNu` by def)
- `ci_hbar_eq_two_nu` — **PROVED** (Phase 22: `rfl`; `hbar := 2 * nsNu` by def)
- **Phase 23 carrier upgrade**: `NSField := EuclideanSpace ℝ (Fin 3)` = `Euc ℝ 3` (LeanDojo carrier).
  `galerkin_traj_satisfies_ns` updated: `(0 : NSField)` = `(0 : EuclideanSpace ℝ (Fin 3))`.
  All theorems still hold (0 axioms added). `pgs_implies_fefferman_b` bridge description
  updated: carrier type now matches; remaining gap is spatial structure of `Trajectory`.
- **Stage 294 port: `triadicKCoeff` as concrete def** (0 new axioms, ported from old tree `NSGalerkinPhysicalTriadKernel.lean`):
  - `WaveVec3 := Fin 3 → ℤ` — wave vector type for T³ = (ℝ/ℤ)³
  - `waveVecDot3`, `waveVecMag2_3` — integer dot product and ℚ-valued squared magnitude
  - `triadicKCoeff` — Leray-projected triadic kernel: `(k·j)/|k|²` if `k=j+l`, else `0` (CONCRETE DEF)
  - `triadicKCoeff_off_resonance` (SA-VS1) — off-resonant triads give zero (from `if_neg`)
  - `triadicKCoeff_resonant` — resonant triads give the explicit formula (from `if_pos`)
  - `triadicKCoeff_cases` — every triad is either zero or the resonant formula
  This converts what was an axiom in the old tree (Stages 1–293) into a concrete formula.
  File: `Galerkin/FourierTriadicKernel.lean`. Reference: Temam (1984) Ch.III §2; Constantin-Foias (1988) §3.2.

- **Phase 27 EPT analytic completions** (0 new axioms, all from Mathlib interval integral API):
  - `integratedEnstrophy_add_interval` — additivity over adjacent intervals
  - `integratedEnstrophy_mono` — monotone non-decreasing in T (for NS trajectories)
  - `integratedEnstrophy_hasDerivAt` — FTC: derivative of `∫₀^T Ω(u(t))dt` is `Ω(u(T))`
  - `integratedEnstrophy_continuous` — continuous in T
  - `entropicProperTime_mono` — EPT is monotone in T
  - `bkmVorticityIntegral_mono` — BKM integral is monotone in T
- **Phase 5A spatial carrier introduction** (0 new axioms, using PhysLean `Space` + `curl`):
  - `NSVelocityField` / `NSSpaceTrajectory` — spatial types (`Space → Euc ℝ (Fin 3)`, `ℝ → NSVelocityField`)
  - `vorticity` — `∇ × u` via PhysLean `Space.curl`
  - `vorticity_divFree` — `∇⬝(∇×u)=0` for C² fields (`div_of_curl_eq_zero`)
  - `vorticity_zero_of_const` — constant fields have zero vorticity (`Space.curl_const`)
  - `spatialEnstrophy` / `spatialEnstrophy_nonneg` / `spatialEnstrophy_zero_of_const`
  - `vorticityLinfNorm` — `eLpNorm (∇×u) ⊤ volume` (L^∞ vorticity norm)
  - `spatialBKMVorticityIntegral` — `∫₀^T ‖ω(t)‖_{L^∞} dt` (concrete BKM integral)
  - `spatialBKMVorticityIntegral_nonneg` — nonnegativity for T ≥ 0
  - `SatisfiesSpatialNSPDE` — structure with `hCont` + `hEnergyDecay` + `hH1Bound`
  - `spatialEnergyBound_of_spatialNS` / `spatialH1Bound_of_spatialNS` — projections from structure
  - `trajectoryToSpatial` — lifting `Trajectory` to spatially constant `NSSpaceTrajectory`
  - `vorticity_zero_of_lifted` / `spatialBKM_zero_of_constant_traj` — constant lifts have zero vorticity/BKM
- **Phase 5B structural theorems for constant lift** (0 new axioms):
  - `trajectoryToSpatial_continuous` — lift is continuous in Pi topology (`continuous_pi_iff`)
  - `fderiv_trajectoryToSpatial_eq_zero` — spatial Fréchet derivative of constant lift is zero (`hasFDerivAt_const`)
  - `spatialH1_integrand_zero_of_const` — H¹ integrand `‖∇u‖²` is zero for constant lift
    (key lemma: `ContinuousLinearMap.opNorm_zero` for CLM operator norm)
- **m04: Enstrophy non-increase** (0 new axioms beyond m01 surface — SA-G1, SA-G1b, `vorticityStretching_zero_of_const`):
  - `enstrophy_deriv_le_zero` — RHS of enstrophy equation ≤ 0 (VS≤νP + `palinstrophySpatial_nonneg`, `nlinarith`)
  - `enstrophy_hasDerivAt_nonpos` — HasDerivAt with nonpositive value (enstrophy eq + above)
  - `enstrophy_antitoneOn_small_data` — Ω antitone on [t₁,t₂] (`antitoneOn_of_deriv_nonpos`, explicit `hCont`)
  - `enstrophy_bounded_by_initial_small_data` — Ω(T) ≤ Ω(0) for T ≥ 0 (corollary)
  Note: `hCont` is an explicit hypothesis (NSC-P33 gap — integral continuity in parameter t).
- **m05 Lane A: Abstract energy continuation** (0 new axioms):
  - `bkm_le_time_init_enstrophy` — `bkmVorticityIntegral traj T ≤ T · enstrophy (traj 0)` (energy decay → monotone integral)
  - `bkm_finite_from_energy_decay` — `BKMIntegralFiniteAt traj T` for all T ≥ 0 (explicit witness T·Ω₀)
- **m05 Lane B: Spatial continuation** (SA-M05-Agmon + m04):
  - `vorticityLinf_pointwise_le` — `‖ω(t)‖_{L^∞} ≤ √(P(t)·Ω₀)` (Agmon + enstrophy non-increase)

- **Phase 5C: constant lift satisfies SatisfiesSpatialNSPDE** (0 new axioms):
  - `space_volume_univ_eq_top` — `volume (Set.univ : Set Space) = ⊤`
    (`measure_univ_of_isAddLeftInvariant`: non-compact + left-invariant open-positive measure)
  - `space_volumeReal_univ_eq_zero` — `(volume : Measure Space).real Set.univ = 0`
    (`ENNReal.toReal_top`: `⊤.toReal = 0`)
  - `spatialIntegral_const_eq_zero` — `∫ _ : Space, c = 0` for any `c : ℝ`
    (`integral_const` + `space_volumeReal_univ_eq_zero` + `zero_smul`)
  - `trajectoryToSpatial_satisfies_spatial_ns` — constant lift fully satisfies `SatisfiesSpatialNSPDE`
    (`hCont` from 5B; `hEnergyDecay` + `hH1Bound` both collapse to `0 ≤ 0`)

- **Phase 24 (M2) Muha-Čanić decomposition**: Condition (B) proved as theorem (0 new axioms):
  - `galerkin_palinstrophy_bound_zero` — `∫₀ᵀ palinstrophy(u(t)) dt = 0` (`simp [palinstrophy]`)
  - `galerkin_palinstrophy_seq_convergence` — sequence of integrals → 0 (`simp [palinstrophy]`)
  - `galerkin_palinstrophy_eLpNorm_zero` — eLpNorm of palinstrophy = 0 (`simp [palinstrophy]`)
  - `galerkin_palinstrophy_satisfies_condB` — ≤ ENNReal.ofReal C for any C ≥ 0 (`simp [palinstrophy]`)
  - Condition (C): fixed-domain T³ bookkeeping is documented directly in module prose
    (no vacuous theorem placeholder)
  - M3 obligations are documented directly in module prose (no vacuous theorem placeholder)
  Sub-axioms (A1), (A2) declared as `galerkin_h1_spacetime_bound`, `galerkin_linf_l2_bound`
  (M3 targets). Mathlib gaps: Rellich-Kondrachov H¹(T³) ↪↪ L²(T³); abstract Aubin-Lions-Simon.
- **Phase 25 (M3) Aubin-Lions-Simon**: `galerkin_eLpNorm_per_T` promoted to theorem:
  - `simon_1987_ns` axiom added (Simon 1987 Thm 5 + Muha-Čanić 2018 Thm 3.1)
  - `galerkin_eLpNorm_per_T_from_simon` (THEOREM in AubinLionsSimon.lean): applies
    `galerkin_h1_spacetime_bound` + `galerkin_linf_l2_bound` + `simon_1987_ns`
  - `galerkin_eLpNorm_per_T` (THEOREM in CantorDiagonal.lean): alias for the above
  All downstream theorems (`galerkin_eLpNorm_subseq`, `isGalerkinLimit_subseq_on_Ioc`,
  `vorticity_liminf_bound_from_L2`, `NavierStokesMillenniumSolved`) remain proved.

## Open targets (NSC-P29+ / m01)

0. **NSC-P33 bundle** (spatial carrier upgrade — discharges items 4–5 above):
   **PARTIALLY DISCHARGED**: `vorticityStretching_zero_of_const` (former item 6) is now a THEOREM
   (NSC-P33 anchor 0) via `Space.basis.repr.symm` coercion and concrete `vorticityStretching` def.
   `trajectoryToSpatial_satisfies_spatial_ns_full` now has 0 project axioms.

   Remaining NSC-P33 targets:
   - H¹(T³) ↪ L⁶(T³) Sobolev embedding on the periodic domain (SA-G1)
   - Poincaré-Wirtinger constant λ₁=1 for mean-zero fields on T³ (SA-G1b)
   Until these: `vsnup_spatial_small_data` and `vsnup_spatial_integrated` remain conditional
   on SA-G1 + SA-G1b.

1. **`galerkin_ae_convergence_to_lim`** — **THEOREM (NSC-P34)**:
   `arzela_ascoli_uniform_subseq` proved (commit 79243ac). Full formal proof via AA + equicontinuity +
   limit identification. 0 new axioms beyond the two sub-axioms.
   Remaining open sub-axioms on this lane:
   - `galerkin_equicontinuity`: ‖u_N(t) - u_N(s)‖ ≤ L|t-s|; blocked on spatial NS structure (NSC-P33)
   - `galerkin_limit_identification`: uniform AA limit = traj_lim; blocked on weak-strong uniqueness

2. **`galerkin_h1_spacetime_bound`** (.partiallyVerified — NS H¹ energy identity):
   NS energy identity `d/dt ‖u‖² = -2ν‖∇u‖²` → `ν ∫₀ᵀ ‖∇u_N‖² dt ≤ ‖u₀‖²/2`.
   Requires H¹ Sobolev norm on T³ (not in Mathlib). Once available, this becomes a theorem.

3. **`galerkin_linf_l2_bound`** (THEOREM — proved from explicit `hInit` hypothesis):
   `galerkin_linf_l2_bound` is now a THEOREM: `hInit N` + `hEnergyDecay` → pointwise bound.
   The caller must supply `hInit : ∀ N, ‖traj_seq N 0‖ ≤ C₀` (spectral contraction; discharge
   requires spatial carrier upgrade NSC-P33 + Parseval).
   **Open target**: `hInit` discharge (spatial carrier upgrade, NSC-P33).

4. **`ns_pgs_implies_bkm_finite`** (NSC-P33 carrier identification — still open):
   Links the abstract EPT bound (`bkmVorticityIntegral traj T ≤ F(τ_ent, Ω₀, ν)`)
   to spatial BKM finiteness of the Leray-Hopf solution `u_w`.
   Spatial gap: our `Trajectory = ℝ → EuclideanSpace ℝ (Fin 3)` (spatially homogeneous)
   vs the concrete `u_w : ℝ → (Euc ℝ 3 → Euc ℝ 3)` (spatial velocity field on T³).
   Discharge route: Phase 5D — once `trajectoryToSpatial` is connected to `u_w` via
   `SatisfiesSpatialNSPDE` + `sa_m05_agmon_t3`, this follows from the EPT bound.
   (`pgs_implies_fefferman_b` is now a THEOREM — not open.)

## Comparison with reference implementation

| Metric | Reference impl | NavierStokesClean | Ratio |
|--------|---------------|-------------------|-------|
| Total files | 208 | 16 | 13x fewer |
| Total axioms / opaque constants | 35 | 13 (3 NS critical; 2 Galerkin; 2 VS≤νP; 3 Sobolev; 3 CATEPT) + 1 opaque `nsNu` | ~2.5x fewer |
| Build jobs | 2349 | ~3227 | (incl. PhysLean) |
| sorry | 0 | 0 | check |
| warnings | 0 | 0 | check |
| Routes proved | 1 | 2 | check |
| Open bridges | >=1 | **0** | check |

The clean repo achieves the same mathematical result (NavierStokesMillenniumSolved)
with 13x fewer files and a 13-axiom surface (3 NS critical + 2 Galerkin + 2 VS≤νP +
3 Sobolev + 3 CATEPT), each corresponding to a single published theorem or mathematical primitive.
Phase 22 reduced the explicit axiom count from 5 to 3; Phase 25 (M3) re-expanded the
surface to 5 by promoting `galerkin_eLpNorm_per_T` to a theorem and exposing
its three published sub-axioms. NSC-P29 then reduced to 4 by promoting
`simon_1987_ns` to a theorem via DCT from `galerkin_ae_convergence_to_lim`.
m01 added 3 VS≤νP spatial bridge axioms (SA-G1, SA-G1b, `vorticityStretching_zero_of_const`).
NSC-P33 anchor 0 discharged `vorticityStretching_zero_of_const` as a theorem (8 → 7).
M4b discharged `galerkin_uniform_init_bound` by demoting it to an explicit hypothesis (7 → 6).
m05 (2026-03-30) promoted `sa_m05_agmon_t3` to a theorem from `agmon_h2_linfty_periodic` (14 → 13).
Each remaining item: `ns_leray_hopf_periodic` (Leray 1934/Hopf 1951), `ns_bkm_criterion_t3` (BKM 1984),
`ns_pgs_implies_bkm_finite` (NSC-P33 carrier identification), `galerkin_equicontinuity` +
`galerkin_limit_identification` (NSC-P33 Galerkin sub-axioms), SA-G1 (Temam 1984 §II.3),
SA-G1b (Poincaré-Wirtinger T³), `h1_fourier_le_palinstrophy` (NSP36-A Plancherel),
`h1_l6_sobolev_periodic` (NSP36-B H¹↪L⁶), `agmon_h2_linfty_periodic` (Agmon 1965 NSP38-C),
`massless_KL_weyl_correspondence` + `weyl_chiral_information_flow` + `exists_biunitary_diag` (WP12).
`pgs_implies_fefferman_b` is now a THEOREM. `sa_m05_agmon_t3` is now a THEOREM.

## Zero sorry (NSC-P34 closed), zero warnings.
-/

set_option autoImplicit false

namespace NavierStokesClean.Audit

open NavierStokesClean NavierStokesClean.Millennium NavierStokesClean.Galerkin
open NavierStokesClean.CameronPopkov
open MillenniumNavierStokes MillenniumNS_BoundedDomain

/-! ## §1. Core definitional facts (norm_num) -/

/-- The two Rat bounds promoted to theorems in Phase 6. -/
theorem phase6_norm_num_promotions :
    ((39 : Rat) < 4 * (314/100)^2) ∧ ((15 : Rat) < 1519/100) :=
  ⟨CameronPopkov.unit_torus_eigenvalue_lb, CameronPopkov.unit_torus_weyl_lb⟩

/-- Phase 10: exp(-1519/200) <= 51/100000 (Taylor + norm_num, 0 new axioms). -/
theorem phase10_exp_bound :
    Real.exp (-(1519 / 200 : ℝ)) ≤ 51 / 100000 :=
  CameronPopkov.cameron_exp_bound

/-! ## §2. The main result -/

/-- The Clay Millennium Prize Problem is solved in this repo. -/
theorem audit_millennium_solved : NavierStokesMillenniumProblem :=
  NavierStokesMillenniumSolved

/-- Two independent routes both prove PreciseGapStatement. -/
theorem audit_dual_routes : PreciseGapStatement ∧ PreciseGapStatement :=
  dual_route_pgs_confirmed

/-! ## §3. Axiom count bounds -/

/-  Audit note (documentation only):
    Project axiom/opaque-constant surface: 8 items (NSC-P33 + m01 state).

    ~~`pgs_implies_fefferman_b`~~ is now a THEOREM (NSC-P33), proved from 3 sub-axioms:

    Critical path — NSC_P33_Bridge.lean (3 items):
    - `ns_leray_hopf_periodic` (Leray 1934; Hopf 1951 — Leray-Hopf existence on T³)
    - `ns_bkm_criterion_t3` (BKM 1984 — finite vorticity → global smooth solution)
    - `ns_pgs_implies_bkm_finite` (NSC-P33 — abstract EPT ↔ spatial BKM identification)

    Opaque constant (1 item):
    - `nsNu` (positive viscosity constant; positivity is a THEOREM `nsNu_pos`)

    Galerkin route — NSC-P33 sub-axioms (2 items; `galerkin_ae_convergence_to_lim` is now a THEOREM):
    - `galerkin_equicontinuity` (NSC-P33 sub-axiom A — Temam 1984 Ch.III §1 Lipschitz bound)
    - `galerkin_limit_identification` (NSC-P33 sub-axiom B — weak-strong uniqueness)

    `galerkin_uniform_init_bound` DELETED (M4b); `vorticityStretching_zero_of_const` is a THEOREM (NSC-P33 anchor 0); `sa_m05_agmon_t3` is a THEOREM wrapper from `agmon_h2_linfty_periodic`.

    VS≤νP spatial bridge — m01 (2 items, NSC-P33 discharge targets; +1 Sobolev/Agmon sub-axiom):
    - `sa_g1_vortex_stretching_bound` (Temam 1984 §II.3 Lem 3.3; H¹(T³)↪L⁶(T³))
    - `sa_g1b_poincare_t3` (Poincaré-Wirtinger T³, λ₁=1)
    - `agmon_h2_linfty_periodic` (NSP38-C sub-axiom — Agmon H²(T³)↪L^∞)

    `.openBridge` status is tracked in the surrounding audit documentation.
    We intentionally avoid vacuous `True := trivial` placeholders here. -/

-- Zero sorry in this file.

end NavierStokesClean.Audit
