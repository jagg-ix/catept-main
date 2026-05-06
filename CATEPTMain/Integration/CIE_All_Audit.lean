import CATEPTMain.Integration.EntropicLocalityTheoremsBridge
import CATEPTMain.Integration.CausalImplementabilitySMatrixBridge
import CATEPTMain.Integration.RetardedGreenFisherBridge
import CATEPTMain.Integration.QuantumInertialFramesLocalityBridge
import CATEPTMain.Integration.EntropicStressTensorConservationBridge
import CATEPTMain.Integration.SchwingerKeldyshInfluenceFunctionalBridge
import CATEPTMain.Integration.KrausEntropicDampingBridge
import CATEPTMain.Integration.MeasurementSharpnessEntropicCostBridge
import CATEPTMain.Integration.LorentzInvariantCausalBoundsBridge
import CATEPTMain.Integration.EPAdmissibleMeasurementBridge
import CATEPTMain.Integration.ResponseTemplatePointerBridge

/-!
# CIE-001..CIE-012 — combined kernel-axiom audit

REPLYID: CAT-EPT-20260506-01.

Single reproducible audit covering every load-bearing declaration that
the eleven Causal-Implementability bridges (CIE-001..CIE-008, CIE-010,
CIE-011, CIE-012) ship. CIE-009 is REFERENCE — its anchor lives in
`CATEPTMain/Integration/AdSCFTEntropicEinsteinLocalityBridge.lean` and
already audits kernel-only.

Each `#print axioms` directive must report
`[propext, Classical.choice, Quot.sound]` — no other axioms.
-/

-- ── CIE-001  Sorkin impossible-measurement carrier ─────────────────
#print axioms
  CATEPTMain.Integration.EntropicLocalityTheoremsBridge.SorkinScenario.noSignallingInSorkinScenario
#print axioms
  CATEPTMain.Integration.EntropicLocalityTheoremsBridge.SorkinScenario.exists_trivial
#print axioms
  CATEPTMain.Integration.EntropicLocalityTheoremsBridge.NoSignallingInSorkinScenario
#print axioms
  CATEPTMain.Integration.EntropicLocalityTheoremsBridge.sorkinScenario_satisfies_noSignalling

-- ── CIE-002  Local S-matrix continuous-additivity carrier ──────────
#print axioms
  CATEPTMain.Integration.CausalImplementabilitySMatrixBridge.LocalSmatrix.exists_trivial
#print axioms
  CATEPTMain.Integration.CausalImplementabilitySMatrixBridge.CauchySplit.exists_trivial
#print axioms
  CATEPTMain.Integration.CausalImplementabilitySMatrixBridge.Unitary
#print axioms
  CATEPTMain.Integration.CausalImplementabilitySMatrixBridge.ContinuousAdditive
#print axioms
  CATEPTMain.Integration.CausalImplementabilitySMatrixBridge.continuousAdditive_of_constant_one
#print axioms
  CATEPTMain.Integration.CausalImplementabilitySMatrixBridge.HammersteinFactorisation.exists_trivial

-- ── CIE-003  Retarded Green Fisher-information bound ───────────────
#print axioms
  CATEPTMain.Integration.RetardedGreenFisherBridge.RetardedSharpnessCarrier.exists_trivial
#print axioms
  CATEPTMain.Integration.RetardedGreenFisherBridge.SharpnessLowerBound
#print axioms
  CATEPTMain.Integration.RetardedGreenFisherBridge.FisherReciprocalBound
#print axioms
  CATEPTMain.Integration.RetardedGreenFisherBridge.retardedSharpness_constant_witness

-- ── CIE-004  QIF-locality axiom ─────────────────────────────────────
#print axioms
  CATEPTMain.Integration.QuantumInertialFramesLocalityBridge.QIFSliceTransform.exists_trivial
#print axioms
  CATEPTMain.Integration.QuantumInertialFramesLocalityBridge.qifPreservesFactorisation
#print axioms
  CATEPTMain.Integration.QuantumInertialFramesLocalityBridge.qifPreservesFactorisation_constant_witness

-- ── CIE-005  Entropic stress tensor conservation ───────────────────
#print axioms
  CATEPTMain.Integration.EntropicStressTensorConservationBridge.EntropicStressTensor.exists_trivial
#print axioms
  CATEPTMain.Integration.EntropicStressTensorConservationBridge.Conserved
#print axioms
  CATEPTMain.Integration.EntropicStressTensorConservationBridge.entropicStress_conservation_witness

-- ── CIE-006  SK influence functional Cauchy-additivity (in-place) ──
#print axioms
  CATEPTMain.Integration.SchwingerKeldyshInfluenceFunctionalBridge.InfluenceFunctional.exists_trivial
#print axioms
  CATEPTMain.Integration.SchwingerKeldyshInfluenceFunctionalBridge.IFCauchyAdditive
#print axioms
  CATEPTMain.Integration.SchwingerKeldyshInfluenceFunctionalBridge.ifCauchyAdditive_zero_witness

-- ── CIE-007  Kraus factorisation across Cauchy cuts ────────────────
#print axioms
  CATEPTMain.Integration.KrausEntropicDampingBridge.FactorisedKraus.exists_trivial
#print axioms
  CATEPTMain.Integration.KrausEntropicDampingBridge.KrausFactorises
#print axioms
  CATEPTMain.Integration.KrausEntropicDampingBridge.EntropicDampingLink
#print axioms
  CATEPTMain.Integration.KrausEntropicDampingBridge.krausFactorises_constant_witness

-- ── CIE-008  Measurement sharpness as entropic cost ────────────────
#print axioms
  CATEPTMain.Integration.MeasurementSharpnessEntropicCostBridge.MeasurementSharpnessCarrier.exists_trivial
#print axioms
  CATEPTMain.Integration.MeasurementSharpnessEntropicCostBridge.FisherEntropicBound
#print axioms
  CATEPTMain.Integration.MeasurementSharpnessEntropicCostBridge.fisherEntropicBound_zero_witness

-- ── CIE-010  Lorentz-invariant causal bounds ───────────────────────
#print axioms
  CATEPTMain.Integration.LorentzInvariantCausalBoundsBridge.RetardedSupportInvariant.exists_trivial
#print axioms
  CATEPTMain.Integration.LorentzInvariantCausalBoundsBridge.LorentzInvariantRetardedSupport
#print axioms
  CATEPTMain.Integration.LorentzInvariantCausalBoundsBridge.lorentzInvariantRetardedSupport_constant_witness

-- ── CIE-011  NHQM exceptional-point measurement regularity ─────────
#print axioms
  CATEPTMain.Integration.EPAdmissibleMeasurementBridge.EPAdmissibleMeasurement.exists_trivial
#print axioms
  CATEPTMain.Integration.EPAdmissibleMeasurementBridge.epAdmissible
#print axioms
  CATEPTMain.Integration.EPAdmissibleMeasurementBridge.epAdmissibleMeasurement_constant_witness

-- ── CIE-012  ResponseTemplate / pointer-probe carrier ──────────────
#print axioms
  CATEPTMain.Integration.ResponseTemplatePointerBridge.PointerProbeCarrier.exists_trivial
#print axioms
  CATEPTMain.Integration.ResponseTemplatePointerBridge.WiredToKraus
#print axioms
  CATEPTMain.Integration.ResponseTemplatePointerBridge.pointerProbe_kraus_witness
