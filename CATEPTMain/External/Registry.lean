namespace CATEPTMain.External

structure RepoEntry where
  name : String
  integrationMode : String
  toolchain : String
  /-- Lean module path of the CATEPT integration bridge for this repo. -/
  leverageFile : String

/-- External repository integration registry for this clean 4.29 migration repo.
    Each entry records the integration mode, source toolchain, and the CATEPT
    Integration module that concretely leverages the package. -/
def repos : List RepoEntry :=
  [ { name := "bochner"
    , integrationMode := "direct_4_29"
    , toolchain := "leanprover/lean4:v4.29.0"
    , leverageFile := "CATEPTMain.Integration.BochnerMinlosBridge" }
  , { name := "hille-yosida"
    , integrationMode := "direct_4_29"
    , toolchain := "leanprover/lean4:v4.29.0"
    , leverageFile := "CATEPTMain.Integration.HilleYosidaBridge" }
  , { name := "pphi2"
    , integrationMode := "direct_4_29"
    , toolchain := "leanprover/lean4:v4.29.0"
    , leverageFile := "CATEPTMain.Integration.MaxwellCurveSpacePphi2Bridge" }
  , { name := "cslib-inspect"
    , integrationMode := "direct_4_29"
    , toolchain := "leanprover/lean4:v4.29.0"
    , leverageFile := "CATEPTMain.Integration.CslibBridge" }
  , { name := "LeanDimensionalAnalysis"
    , integrationMode := "direct_4_29"
    , toolchain := "leanprover/lean4:v4.29.0"
    , leverageFile := "CATEPTMain.Integration.LeanDimensionalAnalysisBridge" }
  , { name := "lean-quantuminfo-inspect"
    , integrationMode := "bridge_upgrade_required"
    , toolchain := "leanprover/lean4:v4.28.0"
    , leverageFile := "CATEPTMain.Integration.QuantumInfoBridge" }
  , { name := "brownian-motion-inspect"
    , integrationMode := "bridge_upgrade_required"
    , toolchain := "leanprover/lean4:v4.28.0-rc1"
    , leverageFile := "CATEPTMain.Integration.BrownianMotionBridge" }
  , { name := "kolmogorov-complexity-lean-inspect"
    , integrationMode := "bridge_upgrade_required"
    , toolchain := "leanprover/lean4:v4.29.0-rc8"
    , leverageFile := "CATEPTMain.Integration.KolmogorovComplexityBridge" }
  , { name := "ThermodynamicsLean-inspect"
    , integrationMode := "legacy_port_required"
    , toolchain := "leanprover/lean4:v4.24.0-rc1"
    , leverageFile := "CATEPTMain.Integration.ThermodynamicsLeanBridge" }
  , { name := "carleson-inspect"
    , integrationMode := "legacy_port_required"
    , toolchain := "leanprover/lean4:v4.15.0"
    , leverageFile := "CATEPTMain.Integration.CarlesonBridge" }
  , { name := "gibbsmeasure-inspect"
    , integrationMode := "legacy_port_required"
    , toolchain := "leanprover/lean4:v4.22.0"
    , leverageFile := "CATEPTMain.Integration.GibbsMeasureBridge" }
  , { name := "hopf-lean-4.26-port"
    , integrationMode := "legacy_port_required"
    , toolchain := "leanprover/lean4:v4.26.0"
    , leverageFile := "CATEPTMain.Integration.HopfLeanBridge" }
  , { name := "formal-verification-of-the-vlasov-maxwell-landau-steady-state-theorem"
    , integrationMode := "direct_4_29"
    , toolchain := "leanprover/lean4:v4.29.0"
    , leverageFile := "CATEPTMain.Integration.VMLSteadyStateBridge" }
  , { name := "lean-inf"
    , integrationMode := "direct_4_29"
    , toolchain := "leanprover/lean4:v4.29.0"
    , leverageFile := "CATEPTMain.Integration.LeanInfBridge" }
  , { name := "pphi2N"
    , integrationMode := "direct_4_29"
    , toolchain := "leanprover/lean4:v4.29.0"
    , leverageFile := "CATEPTMain.Integration.Pphi2NCATEPTBridge" }
  , { name := "lgt"
    , integrationMode := "direct_4_29_gauge_fixing_pending"
    , toolchain := "leanprover/lean4:v4.29.0"
    , leverageFile := "CATEPTMain.Integration.LGTCATEPTBridge" }
  ]

end CATEPTMain.External
