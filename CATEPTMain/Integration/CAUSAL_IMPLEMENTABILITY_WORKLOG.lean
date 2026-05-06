/-!
# Causal Implementability of Entropic Local Operations Worklog

REPLYID: CAT-EPT-20260506-01

Scope:
  Causal admissibility layer for CAT/EPT local operations. Every local
  imaginary-action insertion `S_I`, non-Hermitian update
  `H_eff = H_R - i H_I`, Kraus map, or measurement update must descend
  from a local probe-field interaction whose S-matrix is causally
  factorisable across spacelike Cauchy cuts (continuous additivity or
  Hammerstein factorisation). This blocks Sorkin-type impossible
  measurements while keeping microcausality.

Source paper:
  "Impossible measurements require impossible apparatus" / Bostelmann,
  Fewster, Ruep — local operations, S-matrix factorisation, retarded
  propagator bound on measurement sharpness.

Conventions:
  - CIE-* records in this worklog
  - Status: TODO | IN-PROGRESS | DONE | BLOCKED
  - Priority: P1 (required), P2 (next), P3 (optional)

Anchors already in codebase:
  - CATEPTMain/Integration/AdSCFTEntropicEinsteinLocalityBridge.lean
    (entropic Einstein locality witness)
  - CATEPTMain/Integration/EntropicLocalityTheoremsBridge.lean
  - CATEPTMain/CATEPT/CATEPT/EntropicLocality.lean
  - CATEPTMain/Integration/SchwingerKeldyshInfluenceFunctionalBridge.lean
  - CATEPTMain/Integration/EntropicProperTimeCoreBridge.lean
  - CATEPTMain/Integration/EntropicGreenFunctionBridge.lean
  - CATEPTMain/Integration/ProperTimePathIntegralBridge.lean
  - CATEPTMain/Integration/LorentzInvariantProperTimeBridge.lean
  - CATEPTMain/Geometry/FiniteMinkowski.lean
  - CATEPTMain/QuantumGravity/NoFTLBellBridge.lean
  - CATEPTMain/Integration/NSNoetherEinsteinLocalityBridge.lean
  - CATEPTMain/Gravitas/ADMStressEnergyDecomposition.lean
  - CATEPTMain/Quantum/QUANTUM/QFIMeasurements.lean
  - CATEPTMain/Integration/LocalFisherEntropicGeneratorBridge.lean
  - CATEPTMain/Integration/ReducedModularChannelCarrier.lean
  - CATEPTMain/Integration/OpenSystemMasterEquationCarrier.lean
  - CATEPTMain/Integration/DecoherenceFunctionalCarrier.lean
  - CATEPTMain/NHQM/NHQM_WORKLOG.lean
  - CATEPTMain/CATEPT/CATEPT/NHQMCATEPTBridge.lean

-/

/-!
## CIE-001  Sorkin impossible-measurement axiom (P1)
Goal:
  Carrier for the Sorkin scenario (Alice/Bob/Charlie regions with
  causal/spacelike relations) and a `NoSignallingInSorkinScenario`
  predicate over CAT/EPT updates `Phi_R`.
Bridge:
  - CATEPTMain/Integration/EntropicLocalityTheoremsBridge.lean
  - CATEPTMain/Quantum/QUANTUM/QFIMeasurements.lean
  - CATEPTMain/Geometry/FiniteMinkowski.lean
Plan:
  Extend EntropicLocalityTheoremsBridge with a `SorkinScenario` carrier
  and the `NoSignalling` predicate keyed to spacelike triples.
Status: DONE
Landed:
  EntropicLocalityTheoremsBridge §9 — `SorkinScenario` structure,
  `noSignallingInSorkinScenario` extraction, `exists_trivial`,
  `NoSignallingInSorkinScenario` predicate, and the carrier-vs-predicate
  identity `sorkinScenario_satisfies_noSignalling`. Kernel-only audit
  intended.

-/

/-!
## CIE-002  Local S-matrix continuous-additivity carrier (P1)
Goal:
  Define `LocalSmatrix` with unitarity, support, and the factorisation
    `S[f] = S[f_+] * S[f_-]`
  for any spacelike split `f = f_+ + f_-`. Add a Hammerstein-weakened
  variant for singular interactions.
Bridge:
  - CATEPTMain/Integration/SchwingerKeldyshInfluenceFunctionalBridge.lean
  - CATEPTMain/Integration/LorentzInvariantSliceConstraints.lean
  - CATEPTMain/Geometry/FiniteMinkowski.lean
Plan:
  New module
    `CATEPTMain/Integration/CausalImplementabilitySMatrixBridge.lean`
  with `LocalSmatrix`, `CauchySplit`, `ContinuousAdditive`,
  `HammersteinFactorisation` carriers.
Status: TODO

-/

/-!
## CIE-003  Retarded Green Fisher-information bound (P1)
Goal:
  Carrier for the measurement sharpness bound
    `sigma_eff(f) >= sqrt(Delta_r(f,f))`
  and the Fisher-information rewrite
    `I_F^meas(f) <= 1 / Delta_r(f,f)`.
Bridge:
  - CATEPTMain/Integration/EntropicGreenFunctionBridge.lean
  - CATEPTMain/Integration/LocalFisherEntropicGeneratorBridge.lean
  - CATEPTMain/Quantum/QUANTUM/QFIMeasurements.lean
Plan:
  New module
    `CATEPTMain/Integration/RetardedGreenFisherBridge.lean`
  with `RetardedSharpnessBound` and Fisher-info reciprocal carrier.
Status: TODO

-/

/-!
## CIE-004  QIF-locality axiom (P2)
Goal:
  Quantum Inertial Frame transformation
    `U_QIF(Sigma_1 -> Sigma_2)`
  preserves the causal factorisation of any admissible `S[f]`. State
  the slice-independence equivalence
    `S[f_+^{Sigma_1}] S[f_-^{Sigma_1}] ~ S[f_+^{Sigma_2}] S[f_-^{Sigma_2}]`.
Bridge:
  - CATEPTMain/QuantumGravity/NoFTLBellBridge.lean
  - CATEPTMain/CATEPT/CATEPT/EntropicLocality.lean
  - CATEPTMain/Integration/CausalImplementabilitySMatrixBridge.lean (CIE-002)
Plan:
  New module
    `CATEPTMain/Integration/QuantumInertialFramesLocalityBridge.lean`
  with `QIFSliceTransform` and `qifPreservesFactorisation` carriers.
Status: TODO

-/

/-!
## CIE-005  Entropic stress tensor conservation (P1)
Goal:
  Bridge the operational admissibility of `S_I` with the gravitational
  Bianchi compatibility
    `nabla^mu S^I_{mu nu} = 0`
  (or controlled exchange law) in the complex-Einstein sector
    `G_{mu nu} + i Lambda^I_{mu nu}
       = (8 pi G / c^4) (T_{mu nu} + i S^I_{mu nu})`.
Bridge:
  - CATEPTMain/Gravitas/ADMStressEnergyDecomposition.lean
  - CATEPTMain/Integration/NSNoetherEinsteinLocalityBridge.lean
  - CATEPTMain/Integration/AdSCFTEntropicEinsteinLocalityBridge.lean
Plan:
  New module
    `CATEPTMain/Integration/EntropicStressTensorConservationBridge.lean`
  with `EntropicStressTensor`, conservation field, and admissibility
  link to a causal local probe-field interaction.
Status: TODO

-/

/-!
## CIE-006  SK influence functional factorisation (P2)
Goal:
  Add the relativistic admissibility constraint to the SK influence
  functional:
    `S_IF^I[f_+ + f_-] = S_IF^I[f_+] + S_IF^I[f_-]`
  on Cauchy splits, plus a channel-level Hammerstein analogue.
Bridge:
  - CATEPTMain/Integration/SchwingerKeldyshInfluenceFunctionalBridge.lean
  - CATEPTMain/Integration/DecoherenceFunctionalCarrier.lean
Plan:
  Extend SchwingerKeldyshInfluenceFunctionalBridge with
  `IFCauchyAdditive` and a witness type linking to `LocalSmatrix`.
Status: TODO

-/

/-!
## CIE-007  Kraus factorisation across Cauchy cuts (P2)
Goal:
  Kraus operator family
    `Pi_q^psi[f]
       = (1 / sqrt 2pi) integral dp psi(p)
           exp(- i p^2 Delta_r(f,f) / 2 + i p (q - phi(f)))`
  with the convolution factorisation across `f = f_+ + f_-`.
Bridge:
  - CATEPTMain/Integration/ReducedModularChannelCarrier.lean
  - CATEPTMain/Integration/EntropicProperTimeCoreBridge.lean
  - CATEPTMain/Integration/RetardedGreenFisherBridge.lean (CIE-003)
Plan:
  New module
    `CATEPTMain/Integration/KrausEntropicDampingBridge.lean`
  with `FactorisedKraus` carrier and damping link
    `||Pi_q^psi[f]||^2 ~ exp(- S_I[f] / hbar)`.
Status: TODO

-/

/-!
## CIE-008  Measurement sharpness as entropic cost (P2)
Goal:
  Tie the bound from CIE-003 to the entropic proper-time cost
    `tau_ent = S_I / hbar`
  yielding
    `I_F^meas(f) <= 1 / Delta_r(f,f) <= 2 / S_I[f]`
  whenever an admissible local probe is used.
Bridge:
  - CATEPTMain/Quantum/QUANTUM/QFIMeasurements.lean
  - CATEPTMain/Integration/EntropicProperTimeCoreBridge.lean
  - CATEPTMain/Integration/LocalFisherEntropicGeneratorBridge.lean
Plan:
  New module
    `CATEPTMain/Integration/MeasurementSharpnessEntropicCostBridge.lean`
  with `MeasurementSharpnessCarrier` and a Fisher/`tau_ent` reciprocal
  inequality.
Status: TODO

-/

/-!
## CIE-009  AdS/CFT entropic Einstein locality anchor (REFERENCE)
Goal:
  Treat AdSCFTEntropicEinsteinLocalityBridge as the existing anchor for
  CIE-001..CIE-008. Add open hooks:
    - `sorkin_impossible_measurement_witness`
    - `local_s_matrix_factorization`
    - `entropic_stress_tensor_conservation`
  on `AdSCFTEntropicEinsteinLocalityWitness` once CIE-001/002/005 land.
Bridge:
  - CATEPTMain/Integration/AdSCFTEntropicEinsteinLocalityBridge.lean
  - CATEPTMain/Integration/UnifiedTheorySpine.lean
Status: REFERENCE

-/

/-!
## CIE-010  Lorentz-invariant causal bounds (P3)
Goal:
  Show that the proper-time damping in
  `LorentzInvariantProperTimeBridge` implies a Lorentz-invariant
  retarded support condition for any admissible probe coupling
  `L_I[f] = f(x) phi(x) (x) P`.
Bridge:
  - CATEPTMain/Integration/LorentzInvariantProperTimeBridge.lean
  - CATEPTMain/Geometry/FiniteMinkowski.lean
Plan:
  New module
    `CATEPTMain/Integration/LorentzInvariantCausalBoundsBridge.lean`
  with `RetardedSupportInvariant` carrier and a damping/`Delta_r` link.
Status: TODO

-/

/-!
## CIE-011  NHQM exceptional-point measurement regularity (P2)
Goal:
  Use the `EPRegularityCarrier` from `NHQMMiddleTargets` to certify
  measurement-channel continuity at exceptional points and rule out a
  Sorkin-type measurement instability when crossing an EP.
Bridge:
  - CATEPTMain/NHQM/NHQMMiddleTargets.lean
  - CATEPTMain/CATEPT/CATEPT/NHQMCATEPTBridge.lean
  - CATEPTMain/Quantum/QUANTUM/QFIMeasurements.lean
Plan:
  Extend NHQMCATEPTBridge with an `epAdmissibleMeasurement` carrier
  anchored to `nhPersistentCurrentField_continuousAtEP`.
Status: TODO

-/

/-!
## CIE-012  ResponseTemplate / pointer-probe carrier (P3)
Goal:
  Lift the NHQM `ResponseTemplate` to a pointer/probe-state carrier
  encoding the von Neumann interaction
    `L_I[f] = f(x) phi(x) (x) P`
  and the induced Kraus family from CIE-007.
Bridge:
  - CATEPTMain/NHQM/NHQMMiddleTargets.lean
  - CATEPTMain/Integration/DecoherenceFunctionalCarrier.lean
  - CATEPTMain/Integration/KrausEntropicDampingBridge.lean (CIE-007)
Plan:
  New module
    `CATEPTMain/Integration/ResponseTemplatePointerBridge.lean`
  with `PointerProbeCarrier` and a wiring lemma to `FactorisedKraus`.
Status: TODO

-/

/-!
## Targets summary

| ID      | Title                                              | Priority | Status    |
|---------|----------------------------------------------------|----------|-----------|
| CIE-001 | Sorkin impossible-measurement axiom                | P1       | DONE      |
| CIE-002 | Local S-matrix continuous-additivity carrier       | P1       | TODO      |
| CIE-003 | Retarded Green Fisher-information bound            | P1       | TODO      |
| CIE-004 | QIF-locality axiom                                 | P2       | TODO      |
| CIE-005 | Entropic stress tensor conservation                | P1       | TODO      |
| CIE-006 | SK influence functional factorisation              | P2       | TODO      |
| CIE-007 | Kraus factorisation across Cauchy cuts             | P2       | TODO      |
| CIE-008 | Measurement sharpness as entropic cost             | P2       | TODO      |
| CIE-009 | AdS/CFT entropic Einstein locality anchor          | P1       | REFERENCE |
| CIE-010 | Lorentz-invariant causal bounds                    | P3       | TODO      |
| CIE-011 | NHQM EP measurement regularity                     | P2       | TODO      |
| CIE-012 | ResponseTemplate / pointer-probe carrier           | P3       | TODO      |

Final criterion (target theorem):
  CAT/EPT-admissible local operation iff
    - `S_I >= 0`
    - support of `lambda` in `R`
    - retarded support only
    - `S[f] = S[f_+] * S[f_-]` or Hammerstein factorisation
    - `Phi_R |_{A(R')} = id` for spacelike `R'`
    - `nabla^mu S^I_{mu nu} = 0` (or controlled exchange law).

-/
