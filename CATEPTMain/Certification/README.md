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
- Witness-free canonical Faraday derivation from concrete Gravitas data is now
  provided:
  - `canonical_faraday_minkowski_fixed_witness`,
  - `canonical_faraday_minkowski_fixed_witness_claim`.
- Witness-free canonical curved direct GR assembly is now provided:
  - `canonical_curved_gr_direct_certificate_witness_free`,
  - `canonical_curved_gr_direct_certificate_witness_free_claim`.
- Family-level fixed-antisymmetric theorem for arbitrary
  `ElectromagneticTensor.ofMetric g A μ₀` (4D inputs) is now provided. Because
  Gravitas's symbolic engine exposes `simplify` as a `partial def`, the
  obligations bind to component-level identities collected in a hypothesis
  bundle; the canonical Minkowski instance discharges that bundle from
  concrete Gravitas data via `native_decide`:
  - `FaradayOfMetricFixedWitness`,
  - `faraday_ofMetric_is_fixedAntisymmetric4D`,
  - `canonical_faraday_ofMetric_witness_minkowski`.
- Witness-free curved-GR direct certificate from a single umbrella
  admissibility predicate (WF-GR-009 / WF-GR-010) is now provided. The
  predicate `IsCertifiedCurvedGRData` bundles the five direct-claim
  obligations (Hodge involution, stress divergence, Einstein residual, ADM
  Hamiltonian residual, ADM momentum residual) over arbitrary
  metric/Faraday/stress/ADM/source data, and ships with a constructor and a
  full-claim projection; the canonical Minkowski instance is discharged from
  the existing canonical sector theorems and the witness-free canonical
  Faraday derivation:
  - `IsCertifiedCurvedGRData`,
  - `curved_gr_direct_certificate_of_certified_data`,
  - `certified_curved_gr_data_implies_full_direct_claim`,
  - `isCertifiedCurvedGRData_of_fixedAntisymmetric4D`,
  - `canonical_certified_curved_gr_data`,
  - `canonical_curved_gr_direct_certificate_of_certified_data`,
  - `canonical_certified_curved_gr_data_full_claim`.
- Witness-free Einstein-electrovacuum family (WF-GR-005 / WF-GR-006) is now
  provided. The umbrella predicate `IsEinsteinElectrovacuumSolution g A μ₀ Λ
  sourceTerm` bundles the Einstein residual identity at the
  electromagnetic-field stress-energy and the Maxwell residual array vanishing;
  the indexed source-aware certificate constructor lifts admissible inputs into
  `EinsteinEquationCertificateForSource`; the canonical Minkowski instance is
  discharged from concrete Gravitas data via `native_decide`:
  - `IsEinsteinElectrovacuumSolution`,
  - `einsteinElectrovacuumStress`,
  - `einstein_certificate_for_solution`,
  - `einstein_electrovacuum_solution_full_claim`,
  - `canonical_minkowski_is_einstein_electrovacuum_solution`,
  - `canonical_einstein_certificate_of_electrovacuum_solution`,
  - `canonical_einstein_electrovacuum_solution_full_claim`.
- Witness-free ADM-constraint family (WF-GR-007 / WF-GR-008) is now provided.
  The umbrella predicate `IsCertifiedADMData adm admStress sourceTerm` bundles
  the Hamiltonian-constraint and momentum-constraint residual identities; the
  indexed certificate constructor lifts admissible inputs into
  `ADMConstraintCertificateFor`; the canonical Minkowski vacuum instance
  reuses `gravitasCanonicalVacuumADM_*_residual_exact`:
  - `IsCertifiedADMData`,
  - `adm_certificate_for_data`,
  - `adm_data_full_claim`,
  - `canonical_minkowski_is_certified_adm_data`,
  - `canonical_adm_certificate_of_data`,
  - `canonical_adm_data_full_claim`.
- Witness-free VML-Landau flat equilibrium family is now provided. The
  umbrella predicate `IsVMLElectrovacuumEquilibrium M` bundles the three
  rigidity outputs of `proved_vml_steady_state_rigidity`
  (= Aristotle's `VML.CoulombConcreteTheorem42`): global Maxwellian,
  `E ≡ 0`, `B = const`; the bridge theorem
  `vml_equilibrium_supports_flat_electrovacuum_family` lifts equilibria into
  the existing flat Maxwell→stress-conservation route on `gravitasMinkowski`
  via `maxwell_implies_stress_conservation_minkowski`:
  - `IsVMLElectrovacuumEquilibrium`,
  - `isVMLElectrovacuumEquilibrium_of_maxwellian`,
  - `vml_electrovacuum_equilibrium_full_claim`,
  - `canonical_trivial_vml_electrovacuum_equilibrium`,
  - `vml_equilibrium_supports_flat_electrovacuum_family`,
  - `vml_electrovacuum_equilibrium_content_available`.
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
- The new witness-free Faraday derivation is canonical-scope (Minkowski/Faraday
  payload) and is not yet promoted as a universal-certificate field.

## Future/Generalization Targets

The following are explicit future targets, not production overclaims:

- Witness-free curved derivations for Einstein/ADM closure families.
- Family-level witness-free Hodge-star closure at full tensor equality beyond
  the canonical Minkowski/Faraday payload.
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
