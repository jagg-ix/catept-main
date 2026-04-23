/-!
# AdS/CFT 1907.08126 Integration Worklog

Source:
  Matthew Headrick, "Lectures on entanglement entropy in field theory and holography"
  arXiv:1907.08126v1
  Local file: `~/Downloads/1907.08126v1.pdf`

Primary bridge module:
  `CATEPTMain/Integration/AdSCFTHeadrick1907Bridge.lean`

## Equation-to-Lean map (phase-1)

| Paper eq. | Meaning | Lean symbol |
|---|---|---|
| (2.12) | Conditional entropy `H(A|B)` | `conditionalEntropy` |
| (2.18) | Subadditivity | `subadditivity` + `subadditivity_iff_mutualInformation_nonneg` |
| (2.31) | Mutual information | `mutualInformation` |
| (2.33) | MI monotonicity (`I(A:BC) ≥ I(A:B)`) | `mutualInfoMonotoneUnderAdjoin` |
| (2.34) | Strong subadditivity | `strongSubadditivity` + equivalence theorem |
| (2.35) | Araki-Lieb inequality | `arakiLieb` |
| (2.37) | Pure-state entropy balance | `pureEntropyBalance_of_arakiLieb` |
| (2.40) | Rényi entropy expression | `renyiEntropyFormula` |
| (2.44) | Rényi MI expression | `renyiMutualInformation` |
| (5.6) | RT entropy formula | `rtEntropy` (alias) |
| (5.8) | Minimal-surface entropy (min area) | `rtEntropyFromTwoCandidates` |
| (5.57) | MMI inequality | `monogamyMutualInformation` (contract target) |

## Why this split

Phase-1 captures algebraic identities and compatibility with existing
`AdSCFTBridge` RT machinery. This gives a stable equation contract with zero
`sorry` in the new module.

Phase-2 is reserved for geometric/QFT-heavy arguments that require additional
infrastructure (Lorentzian geometry, extremal surfaces, replica analytics).

## Phase-2 obligations

1. Replica trick core:
   - Formalize `S = lim_{α→1} (1/(1-α)) log Tr(ρ^α)` with analytic-continuation
     side conditions.
2. CFT interval entropy formulas:
   - Vacuum interval (`~ (c/3) log(L/ε)`) and thermal interval formulas as
     theoremized results linked to modular-Hamiltonian assumptions.
3. RT geometric existence/minimality:
   - Replace two-candidate min proxy with genuine minimal/extremal surface
     existence and homology constraints.
4. MMI proof in holographic setting:
   - Prove Eq. (5.57) from surface recombination argument in RT/HRT geometry.

## Suggested follow-on implementation order

1. Add `EntropyAxioms` typeclass for SSA/Araki-Lieb contracts.
2. Attach `EntropyAxioms` instance to current `AdSCFT` witness.
3. Add a dedicated RT/HRT geometry scaffolding file for homology and candidate
   surfaces.
4. Then promote `monogamyMutualInformation` from contract target to theorem.

## 2026-04-18 progress note

- Implemented `EntropyAxioms` + `phase1EntropyAxioms` in
  `AdSCFTHeadrick1907Bridge.lean`.
- Added RT scaling transfer lemmas:
  - `rtEntropy_ssa_of_area_ssa`
  - `rtEntropy_mmi_of_area_mmi`
- Net effect: geometric inequalities on candidate surface areas can now be
  plugged directly into entropy-level SSA/MMI statements without changing
  theorem signatures.
- Added unified downstream export module:
  - `CATEPTMain/Integration/AdSCFT1907Port.lean`
  - bundles entropy witness + replica witness into `Headrick1907PortWitness`
    so consumers can import one file instead of two.
-/
