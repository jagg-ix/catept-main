# First-pass verdicts against the substance criterion

Applies the rule in `SUBSTANCE_CRITERION.md` to every theorem in `INVENTORY.md`.

**Verdict counts (outermost-proof-body audit only):**

| Verdict | Pool A (feat/publication) | Pool B (main) | Total |
|---|---:|---:|---:|
| SUBSTANTIVE | 0 | 5 | 5 |
| BORDERLINE | 0 | 4 | 4 |
| BUNDLING | 24 | 15 | 39 |

> **Caveat — only the outermost layer is audited.** Many BUNDLING verdicts here delegate to a helper lemma (`*_norm_le`, `*_integrable`, `*_consistent`, `eq075_*`, `eq147_152_*`, `proved_*`) whose body may itself be substantive. A second-pass audit walking those helpers is tracked under `catept_pub_classify_20260505`.

---

## SUBSTANTIVE (5 theorems)

These pass the criterion: their proof body contains a class-1 algebraic-computation tactic (`ring`, `nlinarith`, `norm_num` discharging a non-trivial obligation) or a closed-form identity expansion.

| # | Theorem | Deciding tactic | Justification |
|---|---|---|---|
| B15 | `MatsubaraLuttingerWardCarrier.S_I_eq_hbar_tauEnt` | `ring` | Two field rewrites then `ring` discharges `M.ℏ * M.β * M.Ω = M.ℏ * (M.β * M.Ω)`. Class-1 algebraic computation. |
| B16 | `MatsubaraLuttingerWardCarrier.tauEnt_eq_neg_log_Z` | `Real.log_exp` + `ring` | Closed-form expansion: rewrites through `Z = exp(...)` and `log(exp x) = x`, then `ring` closes. Class-3 closed-form expansion. |
| B17 | `MatsubaraLuttingerWardCarrier.S_I_eq_hbar_neg_log_Z` | `ring` | Composes B15 + B16 then `ring`. Class-1. |
| B21 | `GravitasBridge.bohmianEM_action_expansion` | `simp only [...] ; ring` | After unfolding the slot definitions and `Fin.sum_univ_four`, `ring` discharges the closed-form identity `S_I^{EM} = ‖v‖²/2 − ⟨v,A⟩ + ‖A‖²/2`. Class-1 + class-3. |
| B11 | `KMSModularParameterBridge.kms_strip_separate_from_entropicProperTime` | `unfold` + `norm_num` | Constructs an existential witness `(γ_I = 1, τ_ent = id, t = 2)` and discharges `2 ≠ 1/1` via `norm_num`. Class-1 (`norm_num` against a real numeric inequality). |

---

## BORDERLINE (4 theorems)

Proof body uses a qualifying tactic but in a trivial way — a single `simp` or `rw` chain that closes by definitional reduction across hypotheses, with no algebraic step. Needs human review.

| # | Theorem | Tactic | Concern |
|---|---|---|---|
| B2 | `unification_via_modular_flow` | `rw [B.qm_tauEnt_eq_matsubara, B.spine.matsubara_eq_kms]` | Two rewrites both from hypotheses — chain composition only, no algebraic step. |
| B9 | `matsubara_S_I_eq_hbar_logDelta_zero` | `rw [B.matsubara.S_I_eq_hbar_tauEnt, B.matsubara_tauEnt_eq_logDelta_zero]` | Two rewrites, one named lemma + one hypothesis. |
| B19 | `S_I_eq_hbar_logDelta_eq_hbar_channel` | `refine ⟨…, ?_⟩ ; rw [B.tomitaMatsubara.matsubara.S_I_eq_hbar_tauEnt, B.matsubara_tauEnt_eq_channel]` | One half is bundling (`refine ⟨lemma, _⟩`), other half is a `rw` chain. |
| B23 | `vml_vacuum_em_action_zero` | `simp [...]` | Single `simp` discharges via the simp set — close to definitional unfolding. No `ring`/`linarith` follow-up. |

---

## BUNDLING (39 theorems)

Proof body is exclusively structural assembly, definitional unfolding, namespace re-export, or slot-record satisfaction. Excluded by the criterion.

### Pool A — all 24 feat/publication theorems

Every theorem on `feat/publication` is a single named-helper invocation:

| # | Theorem | Pattern |
|---|---|---|
| A1 | `schwarzschild_f_pos` | `eq046_schwarzschild_positive ...` (re-export) |
| A2 | `bh_entropy_pos` (GR) | `eq147_152_bh_entropy_positive ...` (re-export) |
| A3 | `tauEnt_eq_div` (GR) | `eq003_entropic_time_def ℏ a.S_I hℏ` (re-export) |
| A4 | `tauEnt_nonneg` (GR) | `eq003_entropic_time_nonneg ...` (re-export) |
| A5 | `unruh_temperature_pos` | `eq049_unruh_temperature_positive ...` (re-export) |
| A6 | `bh_entropy_pos` (Gravitas) | duplicate of A2 |
| A7 | `bh_entropy_ratio` | `eq147_152_bh_entropy_scaling ...` (re-export) |
| A8 | `bh_entropy_doubling` | `eq147_152_bh_entropy_doubling ...` (re-export) |
| A9 | `catept_gravitas_coherence` | `⟨lemma1, lemma2⟩` (anonymous constructor) |
| A10 | `tauEnt_eq_div` (Pphi2N) | duplicate of A3 |
| A11 | `tauEnt_nonneg` (Pphi2N) | duplicate of A4 |
| A12 | `tauEnt_linear` | `eq003_entropic_time_linear ...` (re-export) |
| A13 | `tauEnt_eq_div` (QFT) | duplicate of A3 |
| A14 | `tauEnt_nonneg` (QFT) | duplicate of A4 |
| A15 | `damping_abs_le_one` | `eq054_damping_magnitude ...` (re-export) |
| A16 | `kinetic_pos` | `eq075_propagator_well_defined ...` (re-export) |
| A17 | `propagator_pos` | `eq075_propagator_positive ...` (re-export) |
| A18 | `minkowski_signature_coincides` | `minkowskiSignature_eq_metricSignature` (re-export) |
| A19 | `is_lorentz_matrix_coincides` | `isLorentzMatrix_iff Λ` (re-export) |
| A20 | `spacelike_condition_coincides` | `spacelike_condition_iff v` (re-export) |
| A21 | `qm_satisfies_catept_spine` | `quantumCATEPTSlot_consistent n` (re-export) |
| A22 | `gr_minkowski_satisfies_catept_spine` | `gravitasMinkowskiSlot_consistent` (re-export) |
| A23 | `gr_electrovacuum_satisfies_catept_spine` | `gravitasElectrovacuumPlugin_consistent` (re-export) |
| A24 | `qm_gr_unified_via_entropic_proper_time` | `⟨A21, A22⟩` (anonymous constructor) |

### Pool B — 15 of 24 main substance theorems

| # | Theorem | Pattern |
|---|---|---|
| B1 | `catept_unifies_QM_Thermo_EM_GR` | 6-tuple of hypothesis projections via `refine ⟨?_, …⟩ ; · exact h_i ; …` |
| B3 | `unification_QM_thermo_pillar` | Direct re-export of `relational_time_eq_thermal_time ...` |
| B4 | `unification_QM_EM_pillar` | Direct field projection `B.qm_tauEnt_eq_em` |
| B5 | `unification_QM_GR_pillar` | Direct field projection `B.qm_tauEnt_eq_gr` |
| B6 | `unification_QM_Matsubara` | Direct field projection `B.qm_tauEnt_eq_matsubara` |
| B7 | `complex_FK_rigorous` | `⟨_norm_le, _integrable⟩` — anonymous constructor of two helper lemmas |
| B8 | `physical_uv_certificate_no_counterterm_needed` | Single-helper re-export `ofUVConvergenceCertificate_no_counterterm_needed _` |
| B10 | `tauEnt_zero_iff_logDelta_zero` | Single `rw [B.matsubara_tauEnt_eq_logDelta_zero]` |
| B12 | `shannon_entropy_zero_via_plugin` | `proved_shannon_entropy_zero` (re-export from plugin) |
| B13 | `renyi_at_one_eq_shannon_via_plugin` | `proved_renyi_at_one_eq_shannon p` (re-export from plugin) |
| B14 | `tauEnt_eq_beta_Omega` | `M.τ_ent_eq` — direct field projection |
| B18 | `four_way_equivalence_at_zero` | 3-tuple of hypothesis projections in anonymous constructor |
| B20 | `matsubara_tauEnt_eq_one_over_gammaI` | 3-rewrite chain, all named lemmas/hypotheses, no algebraic step |
| B22 | `bohmianEM_nonneg` | Direct field projection `(slot).actionIm_nonneg v` |
| B24 | `gravitasEMCATEPTSlot_consistent` | Direct field projection `(slot).consistent` |

---

## Implication for `feat/publication`

By the strict outermost-body criterion:

1. **Every theorem currently on `feat/publication` is BUNDLING.** The branch as it exists today is exactly the kind of content the reviewer critique targets. The substance lives one level down, in the `eq003_*`/`eq046_*`/`eq075_*`/`eq147_152_*` core lemmas — not in the bridge files that the README points reviewers at.

2. **Five SUBSTANTIVE theorems live on `public/main`** but are **not yet on `feat/publication`**: B11, B15, B16, B17, B21. These are the obvious candidates to port to `feat/publication`. They belong to:
   - `MatsubaraLuttingerWardCarrier.lean` (B15, B16, B17 — the closed-form `τ_ent = β·Ω`, `= -log Z`, and `S_I = ℏ·τ_ent` algebra)
   - `GravitasBridge.lean` (B21 — bohmian-EM closed-form action)
   - `KMSModularParameterBridge.lean` (B11 — KMS-strip non-triviality, an existential lemma with a numeric witness)

3. **Four BORDERLINE theorems** (B2, B9, B19, B23) get human review. They use qualifying tactics in marginal ways and could go either way depending on how strict the criterion is read.

4. **Two follow-up audits to do before final curation:**
   - Walk into the helper lemmas (`*_norm_le`, `*_integrable`, `*_consistent`, `proved_*`, `eq03_*` family) and classify those bodies. Many BUNDLING-at-this-layer theorems become SUBSTANTIVE-via-helper, which changes the curation strategy from "drop them" to "promote the helper to a top-level publication theorem".
   - Decide whether `feat/publication` should host the *helper* (the substantive proof) directly, or the *bundling theorem* paired with a worklog note pointing at the helper.

## Recommended next step

Promote the five SUBSTANTIVE-verdict theorems from main to `feat/publication`, then walk the helpers to grow the SUBSTANTIVE list. This is Phase 4 (`catept_pub_port_first_batch_20260505`) and depends on the user agreeing with these verdicts.
