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

## Open follow-ups

- `*Slot_consistent` definitions in `CATEPTMain.Integration.{QuantumCATEPTBridge, GravitasBridge}` (governs A21–A24).
- `proved_renyi_at_one_eq_shannon`, `proved_renyi_zero_eq_log_n` in `CATEPTMain/Integration/AbstractWitnessContracts/QuantumInfo.lean` (governs B13).
- `ofUVConvergenceCertificate_no_counterterm_needed` (governs B8).
- `complexFKExpectation_integrable` (the second half of B7's bundle).
- `OSReconstruction.Bridge.AxiomBridge` external dep — out of scope for this audit but worth a citation.

These are tracked in `catept_pub_classify_20260505` (in_progress).
