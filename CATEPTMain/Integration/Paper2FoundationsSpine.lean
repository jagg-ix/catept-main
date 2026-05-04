import CATEPTMain.Integration.ThermalHamiltonianEntropicTimeBridge
import CATEPTMain.Integration.PageWoottersDissipativeExtensionBridge
import CATEPTMain.Integration.UVCoercivityAbsoluteDampingBridge
import CATEPTMain.Integration.Paper2TierAUnifiedBundleBridge
import CATEPTMain.Integration.EntropicPropagatorEnvelopeBridge
import CATEPTMain.Integration.EverettBranchSuppressionBridge
import CATEPTMain.Integration.ZeroDimQuadraticActionConcreteBridge
import CATEPTMain.Integration.DBBQuantumPotentialBridge
import CATEPTMain.Integration.EntropyIncreaseAlongWorldlineBridge

/-!
# Paper2FoundationsSpine — capstone aggregator for Paper 2 Tiers A/B/C

**Source**: `Paper2_CAT_EPT_Foundations (6).pdf`.

Aggregates the nine carrier-level bridges shipped in PRs #15 (Tier A),
#16 (Tier B), and #17 (Tier C) into a single spine import that makes
the Paper 2 foundations reachable from `CATEPTMain.RepoSpine`.

## What's wired

**Tier A (paper §3.2, §4.3, App. A):**
* `ThermalHamiltonianEntropicTimeBridge` — paper §4.3 eq. 28-31
  four-fold identity `H_th = -ln ρ = S_I/ℏ = τ_ent`.
* `PageWoottersDissipativeExtensionBridge` — paper App. A
  dissipative-amplitude squared-form `|amp|² = exp(-S_I/ℏ)`.
* `UVCoercivityAbsoluteDampingBridge` — paper §3.2 / Prop 1
  absolute damping bound `exp(-S_I/ℏ) ≤ exp(-C·‖φ‖²/ℏ)`.

**Tier B (paper §3.3, App. B + composition of Tier A):**
* `Paper2TierAUnifiedBundleBridge` — composes Tier A into a single
  unified witness with shared `ℏ`/`S_I`.
* `EntropicPropagatorEnvelopeBridge` — paper §3.3 propagator-level
  envelope `|K_τ| ≤ exp(-C·‖φ‖²/ℏ) · |K_τ^free|`.
* `EverettBranchSuppressionBridge` — paper App. B branch-overlap
  suppression by `exp(-S_I^{cross}/ℏ)`.

**Tier C (paper §3.3, §4.2, §5, App. C):**
* `ZeroDimQuadraticActionConcreteBridge` — paper §3.3 / §4.2 concrete
  worked example `S_I[φ] = c·φ²` with explicit `toUVCoercivityCarrier`
  realising Tier A Module 3.
* `DBBQuantumPotentialBridge` — paper App. C dBB extension
  `Q[φ] = S_I[φ]·ℏ/(2m)`.
* `EntropyIncreaseAlongWorldlineBridge` — paper §5 entropic-time
  arrow: monotone `τ_ent` along worldlines.

## What this file ships

* `paper2_foundations_bundle` — proven joint existence of all nine
  capstone witnesses (proves the Paper 2 spine is inhabited).
* Re-exports of each module's named capstone bundle theorem.

## Practical rule

If you ship a new Paper 2 / CAT-EPT-foundations bridge, add it here
and to `RepoSpine.lean` so it's reachable from the canonical "single
import" entrypoint.

## Citations

* Paper 2: `Paper2_CAT_EPT_Foundations (6).pdf`.
* Tier A: PR #15.
* Tier B: PR #16.
* Tier C: PR #17.
-/

set_option autoImplicit false

noncomputable section

namespace CATEPTMain.Integration.Paper2FoundationsSpine

/-! ## Joint existence capstone -/

/-- **Paper 2 foundations capstone**: the nine carrier-level bridges
of Tiers A/B/C are simultaneously inhabited.  This is the
existence-statement form of the Paper 2 foundational spine. -/
theorem paper2_foundations_bundle :
    (∃ _ : CATEPTMain.Integration.ThermalHamiltonianEntropicTimeBridge.ThermalHamiltonianFromDensityMatrix, True) ∧
    (∃ _ : CATEPTMain.Integration.PageWoottersDissipativeExtensionBridge.PageWoottersDissipativeCarrier, True) ∧
    (∃ _ : CATEPTMain.Integration.UVCoercivityAbsoluteDampingBridge.UVCoercivityCarrier ℝ, True) ∧
    (∃ _ : CATEPTMain.Integration.Paper2TierAUnifiedBundleBridge.Paper2TierAUnifiedCarrier, True) ∧
    (∃ _ : CATEPTMain.Integration.EntropicPropagatorEnvelopeBridge.EntropicPropagatorEnvelopeCarrier ℝ, True) ∧
    (∃ _ : CATEPTMain.Integration.EverettBranchSuppressionBridge.EverettBranchPairCarrier, True) ∧
    (∃ _ : CATEPTMain.Integration.ZeroDimQuadraticActionConcreteBridge.ZeroDimQuadraticActionCarrier, True) ∧
    (∃ _ : CATEPTMain.Integration.DBBQuantumPotentialBridge.DBBQuantumPotentialCarrier ℝ, True) ∧
    (∃ _ : CATEPTMain.Integration.EntropyIncreaseAlongWorldlineBridge.EntropyIncreaseWorldlineCarrier, True) :=
  ⟨ CATEPTMain.Integration.ThermalHamiltonianEntropicTimeBridge.exists_trivial
  , CATEPTMain.Integration.PageWoottersDissipativeExtensionBridge.exists_trivial
  , CATEPTMain.Integration.UVCoercivityAbsoluteDampingBridge.exists_trivial
  , CATEPTMain.Integration.Paper2TierAUnifiedBundleBridge.exists_trivial
  , CATEPTMain.Integration.EntropicPropagatorEnvelopeBridge.exists_trivial
  , CATEPTMain.Integration.EverettBranchSuppressionBridge.exists_trivial
  , CATEPTMain.Integration.ZeroDimQuadraticActionConcreteBridge.exists_trivial
  , CATEPTMain.Integration.DBBQuantumPotentialBridge.exists_trivial
  , CATEPTMain.Integration.EntropyIncreaseAlongWorldlineBridge.exists_trivial ⟩

end CATEPTMain.Integration.Paper2FoundationsSpine

end
