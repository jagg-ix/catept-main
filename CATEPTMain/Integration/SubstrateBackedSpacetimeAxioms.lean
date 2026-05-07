import CATEPTMain.Integration.CATEPTSpaceTime
import CATEPTMain.Integration.RelationalInformationSubstrate

/-!
# Substrate-Backed Spacetime Axioms — Target B of relational-information-substrate.md

`CATEPTSpacetimeModel` carries three Phase-1 placeholders:

  ept_smooth        : True
  ept_causal_arrow  : True
  noFTL             : True

T78 added `SubstrateSpacetimeProjection` alongside, with substantive
substrate-derived theorems (`temporalConsistent`, `noFTLNotifications`)
sitting next to the placeholders. This file completes the architecture
note's Target B by **bundling** the substantive content into a
structure whose fields are real ∀-statements (not `True`), and proving
that every `SubstrateSpacetimeProjection` canonically inhabits it.

The original `CATEPTSpacetimeModel` placeholders stay `:= True` for
backward compatibility with existing bridge consumers (the abstract EPT
axiom package, the entropic-Einstein locality witness, etc.). The
substrate-backed structure here is the principled *upgrade path*: a
new bridge file that wants strong locality / no-FTL guarantees imports
this structure instead of the weakly-typed placeholders.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration

open RelationalInformationSubstrate

/-- **Substantive spacetime axioms backed by a relational-information
    substrate.** Each field is a real ∀-statement on the substrate,
    not the `True` placeholder of `CATEPTSpacetimeModel`.

    * `ept_causal_arrow_substrate` is the substrate's `localOrder_causal`
      law: along causally ordered notification chains addressed to one
      entity, the entity's local ordinal clock strictly increases. This
      is the substrate semantics of "EPT is monotone along future-
      directed causal curves" (in the Phase-1 abstraction where causal
      curves are notification chains).

    * `noFTL_substrate` is the substrate's `notificationDelay_le_bound`
      law: every signaling delay is bounded by the substrate's
      propagation constant. This is the substrate semantics of
      "no faster-than-light" (in the Phase-1 abstraction where signal
      latency is the notification delay). -/
structure SubstrateBackedSpacetimeAxioms
    (S : RelationalInformationSubstrate) where
  /-- Causal-order monotonicity of the local ordinal clock — the
      substrate-level discharge of `CATEPTSpacetimeModel.ept_causal_arrow`. -/
  ept_causal_arrow_substrate :
    ∀ {n₁ n₂ : S.Notification} {e : S.Entity},
      S.receiver n₁ = e → S.receiver n₂ = e →
      S.causalPrecedes n₁ n₂ → S.localOrder e n₁ < S.localOrder e n₂
  /-- Propagation bound on every notification — the substrate-level
      discharge of `CATEPTSpacetimeModel.noFTL`. -/
  noFTL_substrate :
    ∀ n : S.Notification, S.notificationDelay n ≤ S.propagationBound

namespace SubstrateBackedSpacetimeAxioms

/-- **Canonical construction.** Every relational-information substrate
    canonically inhabits the substantive axiom layer — both fields
    discharge directly from the substrate's structure laws. -/
def fromSubstrate (S : RelationalInformationSubstrate) :
    SubstrateBackedSpacetimeAxioms S where
  ept_causal_arrow_substrate := S.localOrder_causal
  noFTL_substrate := S.notificationDelay_le_bound

/-- **Substantiveness witness for noFTL.** The propagation bound is
    strictly positive. This is non-trivial — `True` does not entail it. -/
theorem noFTL_propagation_bound_pos
    {S : RelationalInformationSubstrate}
    (_A : SubstrateBackedSpacetimeAxioms S) :
    0 < S.propagationBound :=
  S.propagationBound_pos

/-- **Substantiveness witness for the causal arrow.** If a substrate
    contains a single causal pair `n₁ ≺ n₂` addressed to the same
    entity, the local ordinal clock strictly increases at that pair.
    This is a non-trivial fact (not derivable from `True`) whenever
    the substrate's `Notification` carrier is inhabited and `causalPrecedes`
    is non-empty. -/
theorem ept_causal_arrow_strict_at_pair
    {S : RelationalInformationSubstrate}
    (A : SubstrateBackedSpacetimeAxioms S)
    {n₁ n₂ : S.Notification} {e : S.Entity}
    (h₁ : S.receiver n₁ = e) (h₂ : S.receiver n₂ = e)
    (hcausal : S.causalPrecedes n₁ n₂) :
    S.localOrder e n₁ < S.localOrder e n₂ :=
  A.ept_causal_arrow_substrate h₁ h₂ hcausal

end SubstrateBackedSpacetimeAxioms

end CATEPTMain.Integration

-- ─── Canonical bridge: SubstrateSpacetimeProjection → strong axioms ──
--
-- The SubstrateSpacetimeProjection structure lives in the namespace
-- CATEPTMain.Integration.CATEPTSpaceTime (T78). The bridge theorems
-- are placed in that namespace so name resolution is canonical.

namespace CATEPTMain.Integration.CATEPTSpaceTime.SubstrateSpacetimeProjection

open CATEPTMain.Integration

/-- Every `SubstrateSpacetimeProjection` canonically inhabits the
    substrate-backed axiom layer. This is the headline theorem of
    Target B: anywhere a `SubstrateSpacetimeProjection` flows, the
    substantive (non-`True`) axiom content flows alongside it. -/
def substrateBackedAxioms
    {S : RelationalInformationSubstrate}
    (_P : CATEPTSpaceTime.SubstrateSpacetimeProjection S) :
    SubstrateBackedSpacetimeAxioms S :=
  SubstrateBackedSpacetimeAxioms.fromSubstrate S

/-- The bundled substrate-backed `noFTL` is positive-bound — substantive,
    not the `True` placeholder of `CATEPTSpacetimeModel`. -/
theorem substrateBackedAxioms_noFTL_pos
    {S : RelationalInformationSubstrate}
    (P : CATEPTSpaceTime.SubstrateSpacetimeProjection S) :
    0 < S.propagationBound :=
  (substrateBackedAxioms P).noFTL_propagation_bound_pos

end CATEPTMain.Integration.CATEPTSpaceTime.SubstrateSpacetimeProjection
