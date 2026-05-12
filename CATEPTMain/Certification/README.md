# CATEPTMain Certification Review Guide

This document summarizes what the production certification layer proves today,
what is canonical/scoped, and what remains future generalization work.

## What Is Proved (Production Surface)

The production barrel is `CATEPTMain.Certification`.

- Flat GR certificate surface (`canonical_gr_flat`) is proved.
- GR tensor Stage-A identification (`canonical_gr_tensor`) is proved.
- Stage-B canonical equation payloads are present in `canonical_gr_einstein`:
  - canonical Einstein residual identity,
  - canonical ADM Hamiltonian/momentum residual identities,
  - kernel-checkable Hodge metadata invariants,
  - kernel-checkable covariant-divergence dimensionality invariant.
- Typed residual objects are proved:
  - `canonical_einstein_residual`,
  - `canonical_adm_residual`.
- Typed Einstein/ADM constructor certificates are proved:
  - `canonical_electrovac_einstein_certificate`,
  - `canonical_vacuum_adm_certificate`.
- Curved Maxwell bridge certificate is proved:
  - `canonical_gr_curved_maxwell`.
- VML Maxwell-equilibrium bridge is integrated in certification:
  - `canonical_vml_maxwell_equilibrium`.
- Full direct curved-GR witness-carrying claim interface is proved as an API:
  - `CurvedGRDirectCertificate`,
  - `mk_curved_gr_direct_certificate`,
  - `curved_gr_direct_full_claim`.
- Direct witness-reduction projections are now available from full curved
  certificates into typed indexed families:
  - `curved_gr_direct_to_adm_certificate_for` (unconditional projection),
  - `curved_gr_direct_to_einstein_certificate_for_source` (unconditional
    source-aware projection),
  - `curved_gr_direct_to_einstein_certificate_for` (source-fixed projection
    under `sourceTerm = 0` normalization).
- VML semantic projections are certified both as individual projections and as
  a bundled theorem:
  - `vml_equilibrium_implies_E_zero`,
  - `vml_equilibrium_implies_B_constant`,
  - `vml_equilibrium_implies_global_maxwellian`,
  - `vml_equilibrium_projection_bundle`.
- Maxwell-to-stress conservation is available as a staged family surface:
  - `maxwell_implies_stress_conservation_of_contract`,
  - `maxwell_implies_stress_conservation_derived`,
  - `canonical_minkowski_faraday_family_implies_stress_conservation`.
- Parameterized certificate families are available at indexed type level with
  canonical family-lifts:
  - Einstein: `EinsteinEquationCertificateFor`,
    `EinsteinEquationCertificateForSource`,
    `canonical_electrovac_einstein_certificate_for_family`,
    `canonical_electrovac_einstein_certificate_for_source_family`.
  - ADM: `ADMConstraintCertificateFor`,
    `canonical_vacuum_adm_certificate_for_family`.
- Production universal certificate includes both CurvedMaxwell and VML Maxwell fields:
  - `universalConsistencyCertificate.curvedMaxwell`,
  - `universalConsistencyCertificate.vmlMaxwell`.

## Canonical/Scoped Only (Not Universalized)

- `RelativityGRMaxwellPphi2` is currently support-level/canonical-scope.
- Maxwell/pphi2 is intentionally not promoted to a universal-certificate field yet.
- Several GR claims are certified as canonical payload identities or witness-carrying
  interfaces, rather than witness-free derivations over arbitrary curved inputs.

## Future/Generalization Targets

The following are explicit future targets, not production overclaims:

- Witness-free curved derivations for Einstein/ADM closure families.
- Stronger Hodge-star closure at full tensor equality level under robust
  antisymmetry hypotheses.
- Witness-free Maxwell-to-stress closure derived from Maxwell residuals without
  Faraday/stress bridge premises.
- Deeper semantic projections for imported theorem bundles where upstream
  decomposition allows stronger direct projections.

## Build Commands

Run from repository root.

```bash
lake build CATEPTMain.Certification
lake build CATEPTMain.Certification.Audit
lake build CATEPTMain.Certification.Tests
```

Useful focused checks during review:

```bash
lake build CATEPTMain.Certification.Status
lake build CATEPTMain.Certification.RelativityGRVMLMaxwell
lake build CATEPTMain.Certification.RelativityGREinsteinEquation
lake build CATEPTMain.Certification.RelativityGRADM
```

## Audit Note

Axiom-surface checks are centralized in `CATEPTMain/Certification/Audit.lean`.
Reviewers should treat that file as the source of truth for current `#print axioms`
output on production declarations.
