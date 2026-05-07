import CATEPTMain.Domains.VML.Domain

/-!
# VML Rigidity Spine — Showcase

Machine-checks that the new `vmlRigiditySuperiorSlot_consistent` theorem
depends only on the Lean kernel axioms `propext`, `Classical.choice`, and
`Quot.sound`. Same gate as the existing `qm_satisfies_catept_spine` and
`gr_minkowski_satisfies_catept_spine` checks documented in catept-main's
top-level README.

To audit from the command line:
```
cat > /tmp/vml_audit.lean <<'EOF'
import CATEPTMain.Domains.VML.Showcase
#print axioms CATEPTMain.Domains.VML.vmlRigiditySuperiorSlot_consistent
#print axioms CATEPTMain.Domains.VML.vml_rigidity_steady_state_exists
EOF
lake env lean /tmp/vml_audit.lean
```

Expected output (one line per theorem):
```
'…vmlRigiditySuperiorSlot_consistent' depends on axioms: [propext, Classical.choice, Quot.sound]
'…vml_rigidity_steady_state_exists'   depends on axioms: [propext, Classical.choice, Quot.sound]
```

Any other axiom appearing in the list is a regression.
-/

-- Inline audit: emit the kernel-axiom report at compile time.
#print axioms CATEPTMain.Domains.VML.vmlRigiditySuperiorSlot_consistent
#print axioms CATEPTMain.Domains.VML.vml_rigidity_steady_state_exists
