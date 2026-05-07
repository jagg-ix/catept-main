# Helper-walk verdicts

Reads the *helper* invoked by each BUNDLING theorem at the outermost layer in `VERDICTS.md` and classifies the helper's body against the same substance criterion. A theorem is **SUBSTANTIVE-VIA-HELPER** if it delegates to a SUBSTANTIVE helper, even if its own outermost body is bundling.

## Helper inventory and verdicts

### Pool A helpers (in `CATEPT/CATEPT/{Foundations,PathIntegrals,QuantumGravity,ModularFlowKucharCoreAbstractions}.lean`)

| Helper | Tactics in body | Verdict |
|---|---|---|
| `eq003_entropic_time_def` | `:= rfl` | **BUNDLING** (pure definitional unfolding; `entropic_time` is *defined* as `S_I/ℏ`) |
| `eq003_entropic_time_nonneg` | `unfold ; exact div_nonneg hS (le_of_lt hℏ)` | **BUNDLING** (one library lemma applied to the hypotheses, no algebra) |
| `eq003_entropic_time_linear` | `unfold ; rw [add_div]` | **BORDERLINE** (single Mathlib rewrite) |
| `eq046_schwarzschild_positive` | `unfold ; rw [div_lt_one ...] ; linarith` | **SUBSTANTIVE** (real-inequality reasoning via `linarith` after derived `2M/r < 1`) |
| `eq049_unruh_temperature_positive` | `unfold ; apply div_pos ; mul_pos chain ; linarith [pi_pos]` | **SUBSTANTIVE** (positivity argument using `pi_pos`) |
| `eq054_damping_magnitude` | `unfold ; calc Real.exp (-S_I/ℏ) ≤ Real.exp 0 = 1 ; norm_num ; simpa` | **SUBSTANTIVE** (calc-block analytic bound — class-2) |
| `eq075_propagator_well_defined` | `linarith` | **BORDERLINE-SUBSTANTIVE** (one tactic, but discharges `0 < k² + m² + λ` from real-inequality hypotheses) |
| `eq075_propagator_positive` | `unfold ; apply div_pos ; norm_num ; eq075_propagator_well_defined` | **SUBSTANTIVE-VIA-CHAIN** (composes the previous; `div_pos` + `norm_num` + delegated positivity) |
| `eq147_152_bh_entropy_positive` | `unfold ; nlinarith [pi_pos, hG] ; sq_pos_of_pos ; mul_pos ; simpa [mul_assoc]` | **SUBSTANTIVE** (`nlinarith` with auxiliary facts — class-1) |
| `eq147_152_bh_entropy_scaling` | `unfold ; field_simp [ne_of_gt hG, ne_of_gt hM1]` | **SUBSTANTIVE** (`field_simp` discharges the rational identity `S(M₂)/S(M₁) = (M₂/M₁)²`) |
| `eq147_152_bh_entropy_doubling` | `unfold ; simp only [mul_pow, sq] ; ring` | **SUBSTANTIVE** (`ring` discharges `4πG(2M)² = 4·4πGM²` — class-1 + class-3) |
| `relational_time_eq_thermal_time` | `rw [pw.relationalTime_eq_entropic, cr.thermalTime_eq_entropic]` | **BUNDLING** (two field-equality rewrites; no algebra) |

### Pool B helpers (in `CATEPTMain/Integration/`)

| Helper | Tactics in body | Verdict |
|---|---|---|
| `complexFKExpectation_norm_le` | `unfold ; calc ‖∫…‖ ≤ ∫‖…‖ ≤ ∫ C·m.damping = C·∫m.damping` using `norm_integral_le_integral_norm`, `integral_mono_ae`, `integral_const_mul`, `mul_le_mul`, `m.weight_norm_is_damping` | **SUBSTANTIVE** (analytic `calc` chain on integrals — class-2 measure-theoretic) |
| `proved_shannon_entropy_zero` | `unfold shannonEntropy ; simp` | **BORDERLINE** (single `simp` after unfold; verdict depends on whether the simp set used contains substantive lemmas like `0 · log 0 = 0`) |

---

## Reclassification of parent theorems

### Pool A — SUBSTANTIVE-VIA-HELPER (9)

| # | Theorem | Helper that earns the verdict |
|---|---|---|
| A1 | `schwarzschild_f_pos` | `eq046_schwarzschild_positive` (`linarith`) |
| A2 | `bh_entropy_pos` (GR) | `eq147_152_bh_entropy_positive` (`nlinarith`) |
| A5 | `unruh_temperature_pos` | `eq049_unruh_temperature_positive` (`linarith [pi_pos]`) |
| A6 | `bh_entropy_pos` (Gravitas) | same helper as A2 |
| A7 | `bh_entropy_ratio` | `eq147_152_bh_entropy_scaling` (`field_simp`) |
| A8 | `bh_entropy_doubling` | `eq147_152_bh_entropy_doubling` (`ring`) |
| A15 | `damping_abs_le_one` | `eq054_damping_magnitude` (calc bound) |
| A16 | `kinetic_pos` | `eq075_propagator_well_defined` (`linarith`) |
| A17 | `propagator_pos` | `eq075_propagator_positive` (`div_pos` chain) |

### Pool B — SUBSTANTIVE-VIA-HELPER (1)

| # | Theorem | Helper |
|---|---|---|
| B7 | `complex_FK_rigorous` | `complexFKExpectation_norm_le` (calc-integral bound) |

### BORDERLINE-VIA-HELPER (3)

- A9 `catept_gravitas_coherence` — pair-bundling, but one half is `eq147_152_bh_entropy_positive` (SUBSTANTIVE) and the other is `eq003_entropic_time_def` (BUNDLING). Mixed.
- A12 `tauEnt_linear` — helper `eq003_entropic_time_linear` is BORDERLINE.
- B12 `shannon_entropy_zero_via_plugin` — helper `proved_shannon_entropy_zero` is BORDERLINE.

### Still BUNDLING after helper walk (assigned helpers below)

**Pool A** (8 + 4 OSReconstruction + 4 slot-consistent = 16 still-BUNDLING):

- A3, A10, A13 — `tauEnt_eq_div` variants → `eq003_entropic_time_def` (`rfl`)
- A4, A11, A14 — `tauEnt_nonneg` variants → `eq003_entropic_time_nonneg` (one-step library lemma)
- A18, A19, A20 — OSReconstruction signature/Lorentz/spacelike — delegate to **external dep** `OSReconstruction.Bridge.AxiomBridge`; not audited here. The catept-side bridge is BUNDLING (re-export); the upstream proofs may be substantive but live outside this codebase.
- A21, A22, A23, A24 — slot-`consistent` projections — these read `quantumCATEPTSlot_consistent`, `gravitasMinkowskiSlot_consistent`, etc., which are `def`/structure fields not yet audited. Need a follow-up walk into `CATEPTMain.Integration.{QuantumCATEPTBridge, GravitasBridge}`.

**Pool B** (12 still-BUNDLING):

- B1, B3, B4, B5, B6 — capstone family → all delegate to **structure fields** of `CATEPTUnificationBundle` (`B.qm_tauEnt_eq_em`, etc.). Field projections are inherently bundling — the data is given.
- B8 — `physical_uv_certificate_no_counterterm_needed` → `ofUVConvergenceCertificate_no_counterterm_needed _` (not yet audited; one helper deeper)
- B10 — `tauEnt_zero_iff_logDelta_zero` → field rewrite
- B13 — `renyi_at_one_eq_shannon_via_plugin` → `proved_renyi_at_one_eq_shannon` (not yet audited)
- B14 — `tauEnt_eq_beta_Omega` → field projection `M.τ_ent_eq`
- B18, B20 — projection chains
- B22 — field projection `actionIm_nonneg`
- B24 — field projection `consistent`

---

## Updated verdict counts (after helper walk)

| Verdict | Pool A | Pool B | Total |
|---|---:|---:|---:|
| SUBSTANTIVE (direct) | 0 | 5 | 5 |
| SUBSTANTIVE-VIA-HELPER | 9 | 1 | 10 |
| **Net SUBSTANTIVE** | **9** | **6** | **15** |
| BORDERLINE / BORDERLINE-VIA-HELPER | 2 | 4+1 | 7 |
| BUNDLING (still, after helper walk) | 13 (incl. 4 OSReconstruction-external + 4 slot-`consistent` pending) | 12 | 25 |

Up from 5 SUBSTANTIVE to 15 SUBSTANTIVE — the helper walk roughly **tripled** the SUBSTANTIVE list.

---

## What this changes about porting

The naive port — "move the 5 SUBSTANTIVE theorems" — undershoots. Better strategy:

1. **For Pool A SUBSTANTIVE-VIA-HELPER (9 theorems)**: they're already on `feat/publication`. Don't move them. But the README on `feat/publication` should *cite the helper*, not just the bridge wrapper, so reviewers see the substance. This is a doc fix, not a code move.

2. **For Pool B SUBSTANTIVE / SUBSTANTIVE-VIA-HELPER (6 theorems)**: port them and their carrier files (`MatsubaraLuttingerWardCarrier.lean`, `RigorousComplexFeynmanKac.lean`, `KMSModularParameterBridge.lean`, `GravitasBridge.lean` — for `bohmianEM_action_expansion`).

3. **For still-BUNDLING (25 theorems)**: 
   - The 8 OSReconstruction + slot-`consistent` cases need one more helper walk before final verdict (the substance may be one layer further).
   - The 8 capstone-family / projection-only cases (B1, B3, B4, B5, B6, B14, B22, B24) are *genuinely shallow* — they're field projections on a hand-built bundle structure. Either drop them from the publication-facing README or reframe them as "these are the assumptions, codified".
   - The eq003-style trivial cases (A3, A4, A10, A11, A13, A14) similarly are definitional restatements; consider removing from `feat/publication`'s public face and keeping only as internal lemmas.

## Phase 3 finalization — pending helpers walked

Eight helpers from the first pass were marked "needs second walk". Their bodies have now been classified.

| Helper | Tactics | Verdict |
|---|---|---|
| `quantumCATEPTSlot_consistent` | `(qmSuperiorSlot n).consistent` | **BUNDLING** (single field projection; underlying `qmSuperiorSlot.consistent` is itself a hand-built `consistent : Prop` field) |
| `gravitasMinkowskiSlot_consistent` | `minkowskiSuperiorSlot.consistent` | **BUNDLING** (the file's own docstring says "Term-mode proof via `SuperiorMethodSlot.consistent` (`fun _ => div_one _`)" — three layers, ending in `div_one`) |
| `gravitasElectrovacuumPlugin_consistent` | `gravitasMinkowskiSlot_consistent` | **BUNDLING** (direct re-export of the previous) |
| `proved_shannon_entropy_dirac` | `unfold ; rw [neg_eq_zero] ; apply Finset.sum_eq_zero ; intro ; by_cases ; simp ; simp` | **SUBSTANTIVE** (case split + finset induction; `simp` handles `0·log 0 = 0` and `1·log 1 = 0`) |
| `proved_renyi_at_one_eq_shannon` | `unfold renyiEntropy ; simp` | **BORDERLINE** (single `simp` after unfold; closes via the `if α = 1 then …` definitional branch — no real algebra) |
| `proved_renyi_zero_eq_log_n` | `unfold ; have ... by norm_num × 3 ; rw [if_neg, hsub, hone, one_mul] ; congr 1 ; simp [Real.rpow_zero]` | **SUBSTANTIVE** (multi-step `norm_num` chain + closed-form `Real.rpow_zero` expansion) |
| `ofUVConvergenceCertificate_no_counterterm_needed` | `:= exponential_uv_tail_implies_no_counterterm_needed _` | **BUNDLING** at this layer (single re-export — substance is one helper deeper, in `exponential_uv_tail_implies_no_counterterm_needed`) |
| `complexFKExpectation_integrable` | `refine Integrable.mono' ; exact aestronglyMeasurable.mul ; refine hBound.mono ; intro ; rw [norm_mul, weight_norm_is_damping] ; rw [h_damp_eq] ; exact mul_le_mul ...` | **SUBSTANTIVE** (measure-theoretic chain — `Integrable.mono'`, `aestronglyMeasurable.mul`, `mul_le_mul`; class-2 analytic) |

### Reclassification of parents

- **A21–A24** (slot-`consistent` projections, Pool A): remain **BUNDLING-VIA-HELPER**. The slot-`consistent` chain is `qmSuperiorSlot.consistent`/`minkowskiSuperiorSlot.consistent`/etc., which are `def` fields populated by `fun _ => div_one _` or equivalent at construction time. Three layers, all shallow. **The honest constructor `CATEPTUnificationBundle` rescues this only when paired with `honestUnificationBundle`** (which discharges its own `qm_tauEnt_eq_*` fields with real carrier identities). The `*_satisfies_catept_spine` family on its own is genuinely shallow.
- **B12** `shannon_entropy_zero_via_plugin` → **BORDERLINE** (helper `proved_shannon_entropy_zero` is `unfold + simp`).
- **B13** `renyi_at_one_eq_shannon_via_plugin` → **BORDERLINE** (helper is `unfold + simp` with the `if α=1` branch reducing).
- New SUBSTANTIVE-VIA-HELPER candidates outside the original 24:
  - `shannon_entropy_dirac_via_plugin` (helper `proved_shannon_entropy_dirac` SUBSTANTIVE)
  - `renyi_zero_eq_log_n_via_plugin` (helper `proved_renyi_zero_eq_log_n` SUBSTANTIVE)
- **B7** `complex_FK_rigorous` → already SUBSTANTIVE-VIA-HELPER (anchored on `complexFKExpectation_norm_le`); now further confirmed via the second-half helper `complexFKExpectation_integrable` (also SUBSTANTIVE).
- **B8** `physical_uv_certificate_no_counterterm_needed` → **BUNDLING-VIA-HELPER** at the second layer too. Verdict requires walking one more level into `exponential_uv_tail_implies_no_counterterm_needed`. Deferred to a third pass.

### Final SUBSTANTIVE inventory after Phase 3

| Verdict | Pool A | Pool B | New (outside original 24) | Total |
|---|---:|---:|---:|---:|
| SUBSTANTIVE (direct, outermost) | 0 | 5 | 0 | 5 |
| SUBSTANTIVE-VIA-HELPER | 9 | 1 | 2 | 12 |
| **Net SUBSTANTIVE** | **9** | **6** | **2** | **17** |
| BORDERLINE / via-helper | 2 | 6 | 0 | 8 |
| Genuinely-shallow BUNDLING | 13 | 12 | — | 25 |

Up from 15 → 17 SUBSTANTIVE after Phase 3.

The 4 slot-`consistent` cases (A21–A24) are now confirmed **genuinely shallow** at every layer of the chain — the only honest fix is to pair them with `honestUnificationBundle` (or an analogous non-degenerate constructor) so the *bundle* itself carries the real cross-pillar equalities.

## What's still pending after Phase 3

- One more helper walk into `exponential_uv_tail_implies_no_counterterm_needed` (governs B8). Likely SUBSTANTIVE based on the file's name and the fact that `RigorousComplexFeynmanKac` and `PhysicalUVConvergenceCertificate` are paired — but unverified.
- `OSReconstruction.Bridge.AxiomBridge` external dep — out of scope; cite as external.
- `qmSuperiorSlot.consistent` / `minkowskiSuperiorSlot.consistent` / `emSuperiorSlot.consistent` — all confirmed shallow (the file's docstring says so explicitly: `fun _ => div_one _`). No further walk needed.

These are tracked in `catept_pub_classify_20260505`.

---

## Phase 4 — Step 1 closure: slot-`consistent` substantive fix

The 4 slot-`consistent` cases (A21–A24, "genuinely shallow at every layer") were addressed in `catept_pub_slot_consistent_fix_20260506` (catept-main PR #43, merged at `c185a19b0`).

Three coordinated PRs landed:

1. **lean-mwe PR #1** (`804f0cae5`) — renamed `lean_lib NavierStokes` → `MaxwellWaveNS` to free the `NavierStokes` name in the sibling tree (was colliding with `NavierStokesClean`).
2. **catept-plugin-architecture PR #1** (`8c63498c2`) — promoted `consistent : ∀ x, actionIm x / hbar = eptClock x` from a deprecated alias on `SuperiorMethodSlot` to a **required field** on `CATEPTPluginSlot`. Forces every slot constructor to *prove* the action↔clock identity at construction time.
3. **catept-main PR #43** — populated the new `consistent` field at all 8 catept-main constructor sites and added F3 substantive case `bohmianEMCATEPTSlot`.

### F2 sites (8 sites, kernel-axiom audited)

| Site | Disposition for `consistent` | Verdict |
|---|---|---|
| `VMLCATEPTBridge.kineticCATEPTSlot` | `fun _ => div_one _` | TRIVIAL (hbar = 1) |
| `TheoryPluginAdapter.adapterCATEPTSlot` | `by norm_num` | TRIVIAL |
| `TheoryPluginClassicalETHBridge.classicalETHSiteSlot` | `fun _ => rfl` | TRIVIAL (definitional) |
| `BCJBridge.bcjProductSlot` | `add_div + s₁.consistent + hbar_eq + s₂.consistent` | DELEGATES (signature gained `hbar_eq` hypothesis) |
| `ElectroweakCATEPTBridge.higgsCATEPTSlot` | `fun _ => div_one _` | TRIVIAL (hbar = 1) |
| `UnifiedTheorySpine.modularFlowCATEPTSlot` | `fun _ => div_one _` | TRIVIAL (hbar = 1) |
| `PlanckModeBridge.cateptPlanckSlot` | `field_simp [hbar.ne']` | SUBSTANTIVE (real division identity) |
| `NHQMCATEPTBridge.nhqmCATEPTSlot` | `fun _ => rfl` | TRIVIAL (definitional) |

### F3 site (substantive Bohmian-EM)

- `GravitasBridge.bohmianEMCATEPTSlot (A_bg : Fin 4 → ℝ)` — built **directly** as a `CATEPTPluginSlot` (not via `SuperiorMethodSlot.toCATEPTSlot`), so `actionIm ≠ eptClock` syntactically:
  - `actionIm v = (∑ μ : Fin 4, (v μ - A_bg μ)²) / 2` (compact form)
  - `eptClock v = (∑ μ : Fin 4, v μ²)/2 − (∑ μ : Fin 4, v μ · A_bg μ) + (∑ μ : Fin 4, A_bg μ²)/2` (expanded form)
  - `consistent` discharged by `Fin.sum_univ_four × 4` + `ring` (genuinely substantive — proves the four-fold expansion of `(v − A)²`).

The sibling lemma `bohmianEM_action_expansion` provides the same identity at theorem level for re-use. **Verdict: SUBSTANTIVE-VIA-CARRIER.**

### Audit file

`CATEPTMain/Integration/SlotConsistentFix_Audit.lean` ships 10 `#print axioms` directives — 8 F2 + 2 F3 (slot + extracted theorem). Reviewers reproduce kernel-only axiom surface with one `lake build` invocation:

```
[propext, Classical.choice, Quot.sound]
```

reported for every constructor. No `sorry`, no framework axiom.

### What this changes

A21–A24 are no longer "genuinely shallow at every layer". The **structure** itself now demands a proof, and constructors that elide the work would fail to compile. The reviewer's "heavy lifting is in the hypotheses" critique is converted: the hypothesis is now the *equation*, not a free `Prop` field, and at the substantive F3 site the equation reduces to a four-fold polynomial identity that requires `ring`.

Sites that remain trivial (`div_one`, `rfl`, `norm_num`) are honestly trivial — `hbar = 1` and the carrier is *defined* as the clock — but they are now compelled by the type, not asserted by hand.

---

## Phase 5 — Step 2 disposition: eq003 cosmetic finding

A3, A10, A13 (`tauEnt_eq_div` family) and the underlying helper `eq003_entropic_time_def` were flagged Pattern-2: a `:= rfl` theorem with an unused `(_ : 0 < hbar)` hypothesis, presented as if it were a numbered "Equation 3" result.

### Inventory (where `eq003_entropic_time_def` lives)

The definition lives in **sibling repos**, not catept-main:

- `.lake/packages/NavierStokesClean/NavierStokesClean/CATEPT/Foundations.lean:76`
- `.lake/packages/NavierStokesClean/CATEPT/CATEPT/Foundations.lean:96`
- `.lake/packages/catept-core/CATEPTMainExtracted/CATEPT/CATEPT/Foundations.lean:96`
- `.lake/packages/catept-core/CATEPT/CATEPT/Foundations.lean:96`

Catept-main consumers: 4 (`PauliNoGoEntropicTimeBridge.lean`, `Basic.lean`, `Examples/Ex02_EntropicTime.lean`, `Spacetime/Theoremized/Batch20260408_19_EmergentDimensions.lean`).

### Disposition: acknowledge, do not rename

A multi-repo rename was considered (PRs to NavierStokesClean and catept-core) but **rejected**. Reasons:

1. **The `:= rfl` is honest.** `entropic_time` is *defined* as `S_I / hbar`. The theorem `entropic_time hbar S_I = S_I / hbar := rfl` is the definitional unfolding — exactly what it should be. Renaming to `entropic_time_def_eq` would not add substance; it would just rewrite a label.
2. **Substance lives next door.** The siblings `eq003_entropic_time_nonneg` and `eq003_entropic_time_linear` (both BORDERLINE — one library lemma each) are where the actual content lives. Reviewers should be pointed at *those*, not at the `:= rfl` projection.
3. **Paper-numbering is a labeling convention.** "Equation 3" tracks the manuscript's numbered-equation list. `eqNNN_*` names are an editorial choice, not a claim of theorem depth. The reviewer concern is that `:= rfl` *masquerades* as substance — the fix is documentation, not rename.
4. **Multi-repo PRs for a cosmetic relabel cost more than the value delivered.** Step 1 already validated multi-repo coordination (3 PRs across 3 repos for one substantive structural fix). Spending the same coordination cost on a label change is a poor trade.

### What changes

Nothing in code. This README section *is* the disposition. Reviewers reading the publication face should:

- Read `eq003_entropic_time_def` as: "the carrier definition `entropic_time = S_I/ℏ` reflected as a propositional equality", not "a non-trivial theorem named Equation 3".
- Treat `eq003_entropic_time_nonneg` and `eq003_entropic_time_linear` as the load-bearing parts of the entropic-time block (they apply `div_nonneg` and `add_div` respectively to library hypotheses — BORDERLINE, but real).
- Look to A12 `tauEnt_linear` for the bridge-level use of substance, not A3/A10/A13 (which are projections of the `rfl` definitional equality).

### Net effect on verdict counts

A3, A10, A13 remain BUNDLING (the `:= rfl` *is* bundling at every layer — and we confirm that's the right verdict). A12 remains BORDERLINE-VIA-HELPER. The 17-SUBSTANTIVE inventory is unchanged; the publication face just gets a clearer pointer to where substance lives.

These two phases are tracked in `catept_pub_slot_consistent_fix_20260506` (Phase 4) and `catept_pub_eq003_cosmetic_disposition_20260506` (Phase 5).
