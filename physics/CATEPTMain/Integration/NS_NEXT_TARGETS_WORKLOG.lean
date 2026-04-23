/-!
# NS Next Targets Worklog — Post-CALCULUS Critical Path

Scope:  Five P0/P1 items that become actionable now that
        `AFPBridge/CALCULUS/` (HasVJP framework) has landed.

DB tasks referenced:
  - task 153  nsc_p57_torusMeanZero_chain_rule_20260410   (P0, in_progress)
  - task 273  afpb_calc_lean4mlir_leverage                (P0, done 2026-04-18)
  - task 154  ns_phase5d_energy_identity_t3_20260410      (P0, todo)
  - task 34   ns_mid_m2_discharge_split_palinstrophy_...  (P0, todo)
  - task 35   ns_mid_m3_discharge_split_vs_convergence... (P0, todo)
  - task 141  afp_leverage_ode_galerkin_equicont_20260408 (P1, in_progress)

Cross-reference:
  CATEPTMain/AFPBridge/CALCULUS_PORT_WORKLOG.lean    (DONE)
  CATEPTMain/AFPBridge/EQFTRTFT/EQFTRTFT_VARIATIONAL_WORKLOG.lean

Conventions:
  - NT-*: records in this worklog
  - Status: TODO | IN-PROGRESS | DONE | BLOCKED
  - Priority: P0 (blocker), P1 (required for milestone)
-/

/-!
## NT-001  Close `catept_ns_p0_vorticity_mean_zero` sorry (P0)

File:    `CATEPTMain/Integration/CATEPTSelfConsistency.lean`, line 873
DB task: 153 (nsc_p57_torusMeanZero_chain_rule_20260410)

### What the sorry says

```lean
theorem catept_ns_p0_vorticity_mean_zero
    (u : CATEPTVelocityField) (h_smooth : ContDiff ℝ 2 u) :
    ∀ x, catept_div (fun y => catept_curl u y) x = 0 := by
  -- phase2_exact: mixed partials commute (Schwarz theorem)
  sorry
```

### Strategy

`catept_div` and `catept_curl` expand to `fderiv` applications on
`Fin 3 → ℝ`. The proof is: `fderiv` is linear, mixed partials of a
`ContDiff ℝ 2` function commute via `HasFDerivAt.comp_hasDerivAt`
(Schwarz / Clairaut theorem — in Mathlib as `fderiv_clairaut` or via
`HasFDerivAt.comp`).

CALCULUS connection: `pdiv_comp` (chain rule axiom in Differentiation.lean)
mirrors this; but the actual proof should use Mathlib's
`ContDiff.hasFDerivAt` + `HasFDerivAt.comp` directly.

### Lean4 proof sketch

```lean
intro x
simp only [catept_div, catept_curl, Fin.sum_univ_three]
-- Each summand is ∂/∂xᵢ(∂/∂xⱼ u k) - ∂/∂xᵢ(∂/∂xᵢ u k)
-- Apply fderiv_comm (ContDiff ℝ 2 h_smooth) for each (i,j) pair
have h2 := h_smooth.hasFDerivAt (𝕜 := ℝ)
-- fderiv (fderiv u) commutes via ContDiff.fderiv_comm
simp [fderiv_comm (h_smooth.of_le (by norm_num : 2 ≤ 2)), sub_self]
```

Key Mathlib lemma: `ContDiff.fderiv_comm` or `HasFDerivAt.hasFDerivAt_comp`.
Search: `grep -r "fderiv_comm\|Clairaut" ~/.elan/toolchains/leanprover-lean4-v4.30.0-rc1/`

### Validation
  `grep "sorry" CATEPTMain/Integration/CATEPTSelfConsistency.lean | wc -l`
  Must drop from 1 to 0.

### Status: TODO
-/

/-!
## NT-002  Phase 5D energy identity on T³ (P0)

File:    NS-pending (see NavierStokesClean/Galerkin/ or Integration/)
DB task: 154 (ns_phase5d_energy_identity_t3_20260410)

### What needs to be proved

  d/dt ‖u_N‖² = -2ν‖∇u_N‖²

for the Galerkin ODE trajectory `u_N : ℝ → NSTorusVelocityField`.

### Strategy

This is the **product rule** applied to `‖u_N(t)‖²`:

  d/dt ‖u_N‖² = 2⟨u_N, du_N/dt⟩ = 2⟨u_N, ν Δ u_N − P_N(u_N·∇u_N)⟩

The second term vanishes by the divergence-free + antisymmetry of the
nonlinear term, leaving:

  = 2ν⟨u_N, Δu_N⟩ = -2ν‖∇u_N‖²

CALCULUS connection: `elemwiseProduct_has_vjp` (product rule, proved in
Differentiation.lean) supplies the formal Leibniz identity for `‖·‖²`.

### Key Mathlib lemmas needed

  - `HasDerivAt.inner`  or  `inner_hasDerivAt`
  - `MeasureTheory.inner_laplaceOperator` or `inner_fderiv_eq_neg_inner_fderiv`
    (integration by parts on T³)
  - `NavierStokesClean.Sobolev.TorusBridge` (torus carrier ↔ ℝ³ bridge)

### Prerequisite

  `NavierStokesClean.Galerkin.FourierTriadicKernel.lean` (stage 294, confirmed present).
  `ns_phase5d_spatial_carrier_upgrade_20260409` (task 152, p1).

### Status: TODO (after task 152 done)
-/

/-!
## NT-003  Palinstrophy sequential convergence M2 (P0)

DB task: 34 (ns_mid_m2_discharge_split_palinstrophy_seq_convergence)

### What needs to be proved

SA-G4b-pal: palinstrophy sequence {‖∇ω_N‖²} converges in L¹(0,T).

This is the enstrophy → palinstrophy step: given uniform H¹ bound on
vorticity ω_N, extract a weak-* convergent subsequence.

### Strategy

  1. Uniform H¹ bound from energy identity (NT-002).
  2. Banach-Alaoglu → weakly convergent subsequence in H¹.
  3. Lower semicontinuity of norm → liminf bound.
  4. Strong convergence via compact embedding H¹(T³) ↪ L²(T³)
     (Rellich-Kondrachov; in Mathlib as `ContinuousLinearMap.isCompact_range`
     on the Sobolev embedding).

CALCULUS connection: `biPath_has_vjp` (additive fan-in, proved in
Differentiation.lean) handles the splitting of the energy into kinetic
+ palinstrophy contributions.

### Prerequisite: NT-002 DONE.

### Status: TODO
-/

/-!
## NT-004  VS convergence from palinstrophy M3 (P0)

DB task: 35 (ns_mid_m3_discharge_split_vs_convergence_from_pal_seq)

### What needs to be proved

SA-G4b-VS: velocity-stretching term S(ω_N, u_N) converges in L¹(0,T)
given palinstrophy convergence from NT-003.

### Strategy

  S(ω, u) = ∫ ω·(∇u)·ω dV

By Hölder: |S| ≤ ‖ω‖_{L⁴}² ‖∇u‖_{L²}.

The L⁴ norm of ω is controlled by the GN embedding H¹↪L⁴ (P2 cluster).
Once EV-004 (`FractionalSobolev.lean`) provides `cubicEmbedding`,
the bound closes via `elemwiseProduct_has_vjp`.

### EQFTRTFT connection

`cubicEmbedding` (Lemma 3 in FractionalSobolev.lean) is exactly the
`∫ fg³ ≤ C‖f‖ · (‖g‖_{H¹} + ‖g‖_{L⁴})` estimate needed here.

### Prerequisite: NT-003 DONE; EV-004 (FractionalSobolev) DONE.

### Status: BLOCKED on EV-004
-/

/-!
## NT-005  AFP ODE port → galerkin_equicontinuity axiom (P1)

DB task: 141 (afp_leverage_ode_galerkin_equicont_20260408)

### What needs to be proved

Retire the `axiom galerkin_equicontinuity` used in
`NavierStokesClean/NSCEquicontinuity.lean` (task NSC-P33).

### Strategy

The AFP `Ordinary_Differential_Equations` entry (Isabelle) proves:
Picard-Lindelöf → unique solution → continuous dependence on data.
For the Galerkin ODE system this gives equicontinuity of the trajectory
family {u_N} in C([0,T]; H).

Files to extend: `CATEPTMain/AFPBridge/ODE/Picard_Lindelof.lean`
(already has Phase-1 stubs).

CALCULUS connection: `vjp_comp` (chain rule) applied to the Galerkin
ODE's Duhamel formula retires the composition sorry in `Flow.lean`.

### Key Mathlib entry point

  `ODE.existence_and_uniqueness_of_solutions` or
  `MeasureTheory.ODE.Picard_Lindelof`

### Validation

  `grep "axiom galerkin_equicontinuity"
     NavierStokesClean/Galerkin/NSC_P33_Equicontinuity.lean`
  Must disappear after this task.

### Status: IN-PROGRESS (ODE stubs exist; composition sorry remains)
-/

/-!
## NT-SEQUENCE  Logical execution order

```
NT-001  catept_ns_p0_vorticity_mean_zero
  (independent — uses ContDiff.fderiv_comm directly)
      ↓
NT-002  Phase 5D energy identity
  (needs FourierTriadicKernel + spatial carrier)
      ↓
NT-003  Palinstrophy M2
  (needs energy identity)
      ↓                           EV-004 (FractionalSobolev)
NT-004  VS convergence M3 ────────────────────────────────────→ also feeds
  (needs NT-003 + EV-004)                                       NT-004 + EV-005

NT-005  AFP ODE equicontinuity
  (independent track; parallels NT-002..004)
```

NT-001 is the **highest-priority, lowest-dependency** item:
one sorry, one Mathlib lemma, no external prerequisites.
Start here.
-/
