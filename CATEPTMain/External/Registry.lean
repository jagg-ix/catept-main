namespace CATEPTMain.External

structure RepoEntry where
  name : String
  integrationMode : String
  toolchain : String

/-- External repository integration registry for this clean 4.29 migration repo. -/
def repos : List RepoEntry :=
  [ { name := "bochner", integrationMode := "direct_4_29", toolchain := "leanprover/lean4:v4.29.0" }
  , { name := "hille-yosida", integrationMode := "direct_4_29", toolchain := "leanprover/lean4:v4.29.0" }
  , { name := "pphi2", integrationMode := "direct_4_29", toolchain := "leanprover/lean4:v4.29.0" }
  , { name := "cslib-inspect", integrationMode := "direct_4_29", toolchain := "leanprover/lean4:v4.29.0" }
  , { name := "lean-quantuminfo-inspect", integrationMode := "bridge_upgrade_required", toolchain := "leanprover/lean4:v4.28.0" }
  , { name := "brownian-motion-inspect", integrationMode := "bridge_upgrade_required", toolchain := "leanprover/lean4:v4.28.0-rc1" }
  , { name := "kolmogorov-complexity-lean-inspect", integrationMode := "bridge_upgrade_required", toolchain := "leanprover/lean4:v4.29.0-rc8" }
  , { name := "ThermodynamicsLean-inspect", integrationMode := "legacy_port_required", toolchain := "leanprover/lean4:v4.24.0-rc1" }
  , { name := "carleson-inspect", integrationMode := "legacy_port_required", toolchain := "leanprover/lean4:v4.15.0" }
  , { name := "gibbsmeasure-inspect", integrationMode := "legacy_port_required", toolchain := "leanprover/lean4:v4.22.0" }
  , { name := "hopf-lean-4.26-port", integrationMode := "legacy_port_required", toolchain := "leanprover/lean4:v4.26.0" }
  ]

end CATEPTMain.External
