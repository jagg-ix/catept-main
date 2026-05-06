# Substance criterion for `feat/publication`

This file defines the rule used to decide whether a Lean theorem qualifies for the `feat/publication` branch.

The branch is curated as a deliberate response to the reviewer critique:

> Many of them reduce to definitional bundling. That's fine formally, but it means the heavy lifting is in the hypotheses, not the Lean proofs themselves. Some readers might find that shallow.

Theorems on `feat/publication` must do work in the proof body, not just in the hypotheses or in the statement of the structure they instantiate.

## The rule

A theorem **QUALIFIES** for `feat/publication` iff its proof body contains at least one of:

| # | Class | Tactics / patterns that count |
|---|---|---|
| 1 | Algebraic computation | `ring`, `ring_nf`, `field_simp`, `linarith`, `nlinarith`, `polyrith`, `positivity` (when discharging a non-trivial polynomial obligation) |
| 2 | Analytic argument | `calc` block with non-trivial bounds, integral / sum comparison, measure-theoretic estimate, contradiction with quantitative content (`absurd`, `False.elim` after a real inequality), continuity / convergence reasoning |
| 3 | Closed-form identity expansion | substitution + `simp; ring` (or equivalent) producing a *named* formula (e.g. `τ_ent = β·Ω`, `S_I = ‖v − A‖² / 2`) |
| 4 | Induction or recursion | `induction`, `Nat.rec`, structural recursion with a non-trivial step |

A theorem is **EXCLUDED** (shallow / bundling-only) if its proof is exclusively any combination of:

- Structural assembly: `⟨a, b, c⟩` to fill an anonymous constructor or structure literal, `fun x => f x`, `⟨_, by …⟩` where the inner tactic is itself shallow.
- Definitional unfolding without follow-up: `rfl`, `dsimp; rfl`, `unfold X; rfl`, `exact rfl`.
- Pure namespace re-export: `theorem foo := Module.foo`, `theorem foo := bar`.
- Slot-record satisfaction by construction: `⟨h₁, h₂, h₃⟩` where every `hᵢ` is itself a hypothesis or a field projection.
- `decide` / `Decidable.decide` against a proposition whose truth follows entirely from definitional reduction.

A **BORDERLINE** verdict is reserved for cases where the proof body uses qualifying tactics but in a trivial way (e.g. a single `simp` whose simp set discharges the entire goal because every fact is a definitional equality). Borderline verdicts get human review.

## Why these specific exclusions

- *Structural assembly* is the explicit target of the critique: the work is the input, not the proof.
- *Definitional unfolding* leaves a reviewer with no Lean evidence beyond what was already in the statement.
- *Namespace re-export* presents a renamed lemma as new content.
- *Slot-record satisfaction* is the catept-main pattern most likely to be perceived as shallow: a slot/`SlotRecord` that lists all the "obligations" as fields, then the theorem proves the slot exists by handing those fields back as the proof.

## Why these specific inclusions

- *Algebraic computation* is what readers expect to see for an identity claim. `ring` discharging `S_I = ‖v − A‖²/2` after substitution is doing real work, even if a single tactic.
- *Analytic argument* covers the genuinely hard content (Feynman–Kac bound, UV convergence, modular-flow inequalities, KMS-strip non-triviality).
- *Closed-form expansion* lets us admit identities like the Matsubara `τ_ent = β·Ω = −log Z` family, where `simp; ring` is the right tool.
- *Induction* covers any inductive datum (Trotter, lattice, Schwinger–Keldysh ladder).

## Application workflow

1. **Inventory** — list every theorem currently on `feat/publication` and every theorem on `main` that is a publication candidate. For each: file, line, statement, full proof body. Output: `INVENTORY.md`.
2. **Verdict** — apply the rule above. For each theorem: `SUBSTANTIVE`, `BUNDLING`, or `BORDERLINE`, with a one-line justification naming the deciding tactic (or its absence). Output: `VERDICTS.md`.
3. **Curate** — open a PR to `feat/publication` that ports the SUBSTANTIVE-verdict theorems from main, removes BUNDLING-verdict theorems already on `feat/publication` if any, and leaves BORDERLINE ones for human review.

The audit must be reproducible: every verdict cites a file path, line range, and a concrete tactic name. A theorem that cannot be defended with such a citation does not earn placement on `feat/publication`.

## Worklog tasks tracking this work

- `catept_publication_curation_20260505` — umbrella
- `catept_pub_substance_criterion_20260505` — this file
- `catept_pub_inventory_20260505` — Phase 2
- `catept_pub_classify_20260505` — Phase 3
- `catept_pub_port_first_batch_20260505` — Phase 4
