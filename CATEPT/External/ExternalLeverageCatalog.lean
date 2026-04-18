

set_option autoImplicit false

/-!
# CATEPT External Leverage Catalog

Lean-side catalog of prioritized external module targets for opt-in integration.
This file encodes the non-duplicated source queue as theorem-addressable data.
-/


namespace NavierStokesClean.CATEPT.External

noncomputable section

/-- Minimal external module descriptor used by the opt-in leverage queue. -/
structure ExternalModuleRef where
  lane : String
  modulePath : String

/-- Priority-1 semigroup/generation modules from the Hille-Yosida lane. -/
def hilleYosidaP1Modules : List ExternalModuleRef :=
  [ { lane := "hille-yosida", modulePath := "HilleYosida/SemigroupGroupDefs" }
  , { lane := "hille-yosida", modulePath := "HilleYosida/StronglyContinuousSemigroup" }
  , { lane := "hille-yosida", modulePath := "HilleYosida/Future/GenerationTheorem" }
  ]

/-- Priority-1 characteristic-functional and nuclear-space modules. -/
def bochnerMinlosP1Modules : List ExternalModuleRef :=
  [ { lane := "bochner", modulePath := "Bochner/PositiveDefinite" }
  , { lane := "bochner", modulePath := "Minlos/Main" }
  , { lane := "bochner", modulePath := "Minlos/NuclearSpace" }
  , { lane := "bochner", modulePath := "Minlos/ProjectiveFamily" }
  ]

/-- Priority-2 Euclidean/OS bridge modules from `pphi2`. -/
def pphi2P2Modules : List ExternalModuleRef :=
  [ { lane := "pphi2", modulePath := "Common/QFT/Euclidean/Formulations" }
  , { lane := "pphi2", modulePath := "Common/QFT/Euclidean/ReconstructionInterfaces" }
  , { lane := "pphi2", modulePath := "Pphi2/OSAxioms" }
  , { lane := "pphi2", modulePath := "Pphi2/OSProofs/OS2_WardIdentity" }
  , { lane := "pphi2", modulePath := "Pphi2/InteractingMeasure/Normalization" }
  ]

/-- Priority-3 entropy-principle modules from `ThermodynamicsLean`. -/
def thermodynamicsP3Modules : List ExternalModuleRef :=
  [ { lane := "thermodynamics", modulePath := "LY/Entropy/Principle" }
  , { lane := "thermodynamics", modulePath := "LY/Entropy/Construction" }
  , { lane := "thermodynamics", modulePath := "LY/Entropy/Continuity" }
  ]

/-- Priority-2 harmonic-analysis modules from Carleson. -/
def carlesonP2Modules : List ExternalModuleRef :=
  [ { lane := "carleson", modulePath := "Carleson/Classical/SpectralProjectionBound" }
  , { lane := "carleson", modulePath := "Carleson/WeakType" }
  , { lane := "carleson", modulePath := "Carleson/ForestOperator/L2Estimate" }
  ]

/-- Priority-2 Gibbs-specification modules from `GibbsMeasure`. -/
def gibbsMeasureP2Modules : List ExternalModuleRef :=
  [ { lane := "gibbsmeasure", modulePath := "GibbsMeasure/Specification" }
  , { lane := "gibbsmeasure", modulePath := "GibbsMeasure/KolmogorovExtension4/ProductMeasure" }
  , { lane := "gibbsmeasure", modulePath := "GibbsMeasure/Prereqs/Kernel/CondExp" }
  ]

/-- Priority-2 stochastic-process modules from `brownian-motion`. -/
def brownianMotionP2Modules : List ExternalModuleRef :=
  [ { lane := "brownian-motion", modulePath := "BrownianMotion/Gaussian/BrownianMotion" }
  , { lane := "brownian-motion", modulePath := "BrownianMotion/Continuity/KolmogorovChentsov" }
  , { lane := "brownian-motion", modulePath := "BrownianMotion/StochasticIntegral/DoobMeyer" }
  , { lane := "brownian-motion", modulePath := "BrownianMotion/StochasticIntegral/QuadraticVariation" }
  ]

/-- Priority-2 algorithmic-information modules from `kolmogorov-complexity-lean`. -/
def kolmogorovP2Modules : List ExternalModuleRef :=
  [ { lane := "kolmogorov", modulePath := "KolmogorovMathlib/Complexity/Properties" }
  , { lane := "kolmogorov", modulePath := "KolmogorovMathlib/Complexity/Uncomputability" }
  , { lane := "kolmogorov", modulePath := "KolmogorovMathlib/Complexity/Chaitin" }
  ]

/-- Priority-2 finite-dimensional quantum-information modules from `Lean-QuantumInfo`. -/
def quantumInfoP2Modules : List ExternalModuleRef :=
  [ { lane := "quantuminfo", modulePath := "QuantumInfo/Finite/CPTPMap/CPTP" }
  , { lane := "quantuminfo", modulePath := "QuantumInfo/Finite/Distance/Fidelity" }
  , { lane := "quantuminfo", modulePath := "QuantumInfo/Finite/Entropy/VonNeumann" }
  , { lane := "quantuminfo", modulePath := "QuantumInfo/Finite/Entropy/DPI" }
  , { lane := "quantuminfo", modulePath := "QuantumInfo/Finite/Entropy/SSA" }
  , { lane := "quantuminfo", modulePath := "QuantumInfo/Finite/ResourceTheory/SteinsLemma" }
  ]

/-- Priority-2 CSLib foundational modules for operational/semantic proof infrastructure. -/
def cslibP2Modules : List ExternalModuleRef :=
  [ { lane := "cslib", modulePath := "Cslib/Foundations/Semantics/LTS/Basic" }
  , { lane := "cslib", modulePath := "Cslib/Foundations/Semantics/LTS/Bisimulation" }
  , { lane := "cslib", modulePath := "Cslib/Foundations/Semantics/LTS/TraceEq" }
  , { lane := "cslib", modulePath := "Cslib/Foundations/Data/RelatesInSteps" }
  , { lane := "cslib", modulePath := "Cslib/Foundations/Logic/InferenceSystem" }
  , { lane := "cslib", modulePath := "Cslib/Foundations/Syntax/Context" }
  ]

/-- Total currently tracked high-priority external module count. -/
def externalLeveragePriorityCount : Nat :=
  hilleYosidaP1Modules.length + bochnerMinlosP1Modules.length +
    pphi2P2Modules.length + thermodynamicsP3Modules.length +
      carlesonP2Modules.length + gibbsMeasureP2Modules.length +
        brownianMotionP2Modules.length + kolmogorovP2Modules.length +
          quantumInfoP2Modules.length + cslibP2Modules.length

theorem hilleYosidaP1Modules_count :
    hilleYosidaP1Modules.length = 3 := by
  decide

theorem bochnerMinlosP1Modules_count :
    bochnerMinlosP1Modules.length = 4 := by
  decide

theorem pphi2P2Modules_count :
    pphi2P2Modules.length = 5 := by
  decide

theorem thermodynamicsP3Modules_count :
    thermodynamicsP3Modules.length = 3 := by
  decide

theorem carlesonP2Modules_count :
    carlesonP2Modules.length = 3 := by
  decide

theorem gibbsMeasureP2Modules_count :
    gibbsMeasureP2Modules.length = 3 := by
  decide

theorem brownianMotionP2Modules_count :
    brownianMotionP2Modules.length = 4 := by
  decide

theorem kolmogorovP2Modules_count :
    kolmogorovP2Modules.length = 3 := by
  decide

theorem quantumInfoP2Modules_count :
    quantumInfoP2Modules.length = 6 := by
  decide

theorem cslibP2Modules_count :
    cslibP2Modules.length = 6 := by
  decide

theorem externalLeveragePriorityCount_value :
    externalLeveragePriorityCount = 40 := by
  decide

end

end NavierStokesClean.CATEPT.External
