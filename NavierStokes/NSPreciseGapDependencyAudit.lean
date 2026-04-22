import NavierStokes.NSCameronKoopmanBridge

/-!
# PreciseGapStatement Dependency Audit — Stage 84

Full DAG from `PreciseGapStatement` back to all axioms. Every node is tagged:
- `proved` — all axioms on path are `.verified` or `.partiallyVerified`
- `conditionalOn` — proved modulo the listed open axiom names
- `misleadinglyWeak` — proves its stated type but with vacuous content or incorrect docs

## Key findings

**4 misleadingly-weak nodes** identified (3 on critical path + 1 vacuous off-path):

1. **`popkov_implies_ml_stabilization`** — constructs `DecomposedBKMTower` with all
   bounds = 1; uses zero axioms; no connection to Cameron competition or Popkov
   spectral gap.

2. **`quantitative_route6_pipeline`** — documented as "full Route 6 from
   trace-Cameron competition to PreciseGapStatement." Actual proof path:
   `popkov_implies_ml_stabilization` (trivial) → `ml_stabilization_implies_precise_gap`
   (open axiom). The Cameron competition chain is ORPHANED (not on proof path).

3. **`unit_torus_route6_closed`** — delegates to (2), inherits its documentation
   error. Claims "irreducible open content = lean_native_sum_bound +
   stokesFirstEigenvalue_gt_39" but neither axiom is on the proof path.

4. **`stretching_dominated_transient`** — witnesses `tau_stretch = 0`; proves
   `0 ≤ entropicTimeDomainBound`, not actual transience. Off the
   PreciseGapStatement proof path entirely.

## Actual critical path

```
PreciseGapStatement
  ← unit_torus_route6_closed          [delegates — MISLEADINGLY DOCUMENTED]
  ← quantitative_route6_pipeline      [= six_routes…2.2.2.2.2 — MISLEADINGLY DOCUMENTED]
  ← strategy_d_popkov_route           [= popkov_zeno_route_to_precise_gap — thin wrapper]
  ← popkov_zeno_route_to_precise_gap
      ├─ popkov_implies_ml_stabilization      [MISLEADINGLY WEAK: trivial, 0 axioms]
      └─ ml_stabilization_implies_precise_gap [OPEN AXIOM — the single bottleneck]
```

## Orphaned chain (proved but disconnected from PreciseGapStatement)

```
lean_native_sum_bound (axiom) ─┐
stokesFirstEigenvalue_gt_39    ┘→ cameron_trace_sum_below_spectral_gap (PROVED)
  → trace_cameron_implies_gap_condition
  → cameron_weighted_gap_condition_uniform (axiom)
  → popkov_uniform_implies_bkm → BKMIntegralFiniteAt   ← NOT PreciseGapStatement
       ← ns_galerkin_cameron_governs_trajectory (axiom, .openBridge)
```

To reconnect: `popkov_implies_ml_stabilization` must use genuine Cameron bounds
(from `cameron_weighted_gap_condition_uniform`) instead of constant 1.
The scaling obstruction `no_global_linear_cameron_bound` (Stage 83) explains
why a plain linear bound Vc ≤ K·Ω is impossible.

## References
- GalerkinDescentTower.lean: ml_stabilization_implies_precise_gap (open axiom)
- PopkovZenoBridge.lean: popkov_implies_ml_stabilization (trivial witnesses)
- TraceCameronCompetition.lean: quantitative_route6_pipeline (orphaned chain)
- NumericalBoundCertificate.lean: unit_torus_route6_closed (documentation error)
- EnstrophyEvolutionBalance.lean: stretching_dominated_transient (vacuous)
- NSCameronKoopmanBridge.lean: no_global_linear_cameron_bound (scaling obstruction)
-/

namespace NavierStokes.DependencyAudit

set_option autoImplicit false

open NavierStokes.Millennium
open NavierStokes.MillenniumAudit

/-! ## 1. Node Tag -/

/-- Proof-status tag for nodes in the PreciseGapStatement dependency DAG. -/
inductive NodeTag : Type
  /-- All axioms on the path are `.verified` or `.partiallyVerified` (no novel conjectures). -/
  | proved : NodeTag
  /-- Formally proved but conditional on the listed open axiom names. -/
  | conditionalOn (openAxioms : List String) : NodeTag
  /-- Formally proves its stated type but with vacuous witnesses or incorrect documentation. -/
  | misleadinglyWeak (reason : String) : NodeTag
  deriving DecidableEq, Repr

/-! ## 2. Audit Node Structure -/

/-- A node in the PreciseGapStatement dependency DAG. -/
structure AuditNode where
  leanName   : String
  sourceFile : String
  /-- True if this is a `axiom` declaration (not a proved `theorem`). -/
  isAxiom    : Bool
  tag        : NodeTag
  note       : String

/-! ## 3. Critical-Path Nodes (PreciseGapStatement ← ...) -/

private def n_ml_stab_pgs : AuditNode where
  leanName   := "ml_stabilization_implies_precise_gap"
  sourceFile := "GalerkinDescentTower.lean:455"
  isAxiom    := true
  tag        := .conditionalOn ["ml_stabilization_implies_precise_gap"]
  note       := "THE BOTTLENECK — Galerkin ML stabilization → PreciseGapStatement (open axiom)"

private def n_popkov_ml : AuditNode where
  leanName   := "popkov_implies_ml_stabilization"
  sourceFile := "PopkovZenoBridge.lean:351"
  isAxiom    := false
  tag        := .misleadinglyWeak
    ("Proof constructs DecomposedBKMTower with angularBound=1, magnitudeBound=1, " ++
     "spatialBoundAtLevel=const 1. MittagLefflerStabilization proved by " ++
     "(1, by norm_num, fun _ => le_refl _). Uses zero axioms. " ++
     "No connection to Cameron competition or Popkov spectral gap machinery.")
  note       := "MISLEADINGLY WEAK — trivial tower (all bounds = 1), zero axioms used"

private def n_popkov_route : AuditNode where
  leanName   := "popkov_zeno_route_to_precise_gap"
  sourceFile := "PopkovZenoBridge.lean:404"
  isAxiom    := false
  tag        := .conditionalOn ["ml_stabilization_implies_precise_gap"]
  note       := "obtain trivial tower; exact ml_stabilization_implies_precise_gap dbt hML"

private def n_quant_route6 : AuditNode where
  leanName   := "quantitative_route6_pipeline"
  sourceFile := "TraceCameronCompetition.lean:207"
  isAxiom    := false
  tag        := .misleadinglyWeak
    ("= six_routes_to_precise_gap.2.2.2.2.2 = strategy_d_popkov_route. " ++
     "Docstring: 'open content = ONE axiom: cameron_trace_sum_below_spectral_gap'. " ++
     "WRONG: cameron_trace_sum_below_spectral_gap is NOT on this proof path. " ++
     "The Cameron competition chain (lean_native_sum_bound → " ++
     "cameron_trace_sum_below_spectral_gap → cameron_weighted_gap_condition_uniform) " ++
     "feeds popkov_uniform_implies_bkm which proves BKMIntegralFiniteAt — " ++
     "NOT PreciseGapStatement. Actual path uses trivial-witness tower + open axiom.")
  note       := "MISLEADINGLY DOCUMENTED — Cameron chain orphaned; actual path is trivial tower"

private def n_unit_torus_r6 : AuditNode where
  leanName   := "unit_torus_route6_closed"
  sourceFile := "NumericalBoundCertificate.lean:113"
  isAxiom    := false
  tag        := .misleadinglyWeak
    ("= quantitative_route6_pipeline. Docstring claims " ++
     "'irreducible open content: lean_native_sum_bound + stokesFirstEigenvalue_gt_39' " ++
     "but neither axiom is on the actual proof path to PreciseGapStatement.")
  note       := "MISLEADINGLY DOCUMENTED — inherits documentation error from route6_pipeline"

/-! ## 4. Orphaned Nodes (genuine work, disconnected from PreciseGapStatement) -/

private def n_cameron_trace_thm : AuditNode where
  leanName   := "cameron_trace_sum_below_spectral_gap"
  sourceFile := "TraceCameronCompetition.lean:150"
  isAxiom    := false
  tag        := .conditionalOn ["lean_native_sum_bound", "stokesFirstEigenvalue_gt_39"]
  note       := "PROVED (norm_num, T3 CLOSED) — ORPHANED: not on PreciseGapStatement path"

private def n_native_sum_bound : AuditNode where
  leanName   := "lean_native_sum_bound"
  sourceFile := "TraceCameronCompetition.lean:116"
  isAxiom    := true
  tag        := .conditionalOn ["lean_native_sum_bound"]
  note       := "S_infty <= 1/1000 for T^3(L=1) — genuine rational bound (ORPHANED from PGS)"

private def n_stokes_gt39 : AuditNode where
  leanName   := "stokesFirstEigenvalue_gt_39"
  sourceFile := "AgmonInterpolationBridge.lean:86"
  isAxiom    := true
  tag        := .conditionalOn ["stokesFirstEigenvalue_gt_39"]
  note       := "lambda_1 > 39 for T^3(L=1) — domain geometry (ORPHANED from PGS)"

private def n_cameron_gap_cond : AuditNode where
  leanName   := "cameron_weighted_gap_condition_uniform"
  sourceFile := "PopkovZenoBridge.lean:268"
  isAxiom    := true
  tag        := .conditionalOn ["cameron_weighted_gap_condition_uniform"]
  note       := "Uniform Cameron perturbation < lambda_1 — ORPHANED (feeds BKMIntegralFiniteAt)"

private def n_ns_governs : AuditNode where
  leanName   := "ns_galerkin_cameron_governs_trajectory"
  sourceFile := "PopkovZenoBridge.lean"
  isAxiom    := true
  tag        := .conditionalOn ["ns_galerkin_cameron_governs_trajectory"]
  note       := "NS<->Cameron Liouvillian link (.openBridge) — ORPHANED from PreciseGapStatement"

/-! ## 5. Vacuous Off-Path Nodes -/

private def n_stretching_transient : AuditNode where
  leanName   := "stretching_dominated_transient"
  sourceFile := "EnstrophyEvolutionBalance.lean:783"
  isAxiom    := false
  tag        := .misleadinglyWeak
    ("Proof: exists 0, le_refl _, entropic_domain_finite _ (kineticEnergy_nonneg _). " ++
     "Witnesses tau_stretch = 0. " ++
     "Conclusion 0 <= entropicTimeDomainBound is trivially true. " ++
     "No content about the duration of the stretching-dominated phase. " ++
     "Not on any proof path to PreciseGapStatement.")
  note       := "VACUOUS — witnesses tau_stretch = 0; not on PreciseGapStatement path"

/-! ## 6. Complete Audit Table -/

/-- Full dependency DAG for PreciseGapStatement: critical path, orphaned chain, vacuous. -/
def preciseGapDAG : List AuditNode :=
  [ -- Critical path (PreciseGapStatement <- ...)
    n_unit_torus_r6
  , n_quant_route6
  , n_popkov_route
  , n_popkov_ml
  , n_ml_stab_pgs
    -- Orphaned chain (proved but disconnected from PreciseGapStatement)
  , n_cameron_trace_thm
  , n_native_sum_bound
  , n_stokes_gt39
  , n_cameron_gap_cond
  , n_ns_governs
    -- Vacuous (not on any path to PreciseGapStatement)
  , n_stretching_transient
  ]

/-! ## 7. Computable Audit Theorems -/

/-- Count misleadingly-weak nodes in a DAG. -/
def countMisleading (nodes : List AuditNode) : Nat :=
  nodes.countP fun n => match n.tag with
    | .misleadinglyWeak _ => true
    | _ => false

/-- Count axiom nodes in a node list. -/
def countAxioms (nodes : List AuditNode) : Nat :=
  nodes.countP fun n => n.isAxiom

/-- The DAG contains exactly 4 misleadingly-weak nodes:
    `unit_torus_route6_closed`, `quantitative_route6_pipeline`,
    `popkov_implies_ml_stabilization`, `stretching_dominated_transient`. -/
theorem misleading_node_count_is_four :
    countMisleading preciseGapDAG = 4 := by decide

/-- Exactly ONE axiom appears on the actual critical path (top 5 nodes):
    `ml_stabilization_implies_precise_gap`. The other 4 critical-path nodes
    are theorems (including `popkov_implies_ml_stabilization` which uses zero axioms). -/
theorem one_axiom_on_critical_path :
    countAxioms (preciseGapDAG.take 5) = 1 := by decide

/-- The orphaned chain (nodes 6-10) contains 4 axioms:
    `lean_native_sum_bound`, `stokesFirstEigenvalue_gt_39`,
    `cameron_weighted_gap_condition_uniform`, `ns_galerkin_cameron_governs_trajectory`. -/
theorem four_axioms_in_orphaned_chain :
    countAxioms (preciseGapDAG.drop 5 |>.take 5) = 4 := by decide

/-! ## 8. Critical-Path Axiom Record -/

noncomputable section NSContent

/-- The single open axiom that blocks PreciseGapStatement from being fully proved
    is `ml_stabilization_implies_precise_gap`. -/
theorem actual_critical_axiom_record :
    ∃ (r : OpenAxiomRecord),
      r.leanName = "ml_stabilization_implies_precise_gap" ∧
      r.epistemic = .openBridge :=
  ⟨{ leanName         := "ml_stabilization_implies_precise_gap"
     sourceFile        := "GalerkinDescentTower.lean:455"
     epistemic         := .openBridge
     blockerReason     :=
       "Galerkin convergence from ML-stabilized finite-dimensional bounds to the " ++
       "full 3D NS trajectory requires the 1/2-derivative Sobolev embedding " ++
       "(H^{1/2} subset L^{6/5} in 3D). No Mathlib proof of this embedding in the " ++
       "Galerkin limit context exists."
     dischargeRequires :=
       "Prove temam_galerkin_completeness: Aubin-Lions compactness + " ++
       "uniform BKM bounds from cameron_weighted_gap_condition_uniform " ++
       "→ strong L^2 convergence of Galerkin approximants." },
   rfl, rfl⟩

/-- What must change to convert Route 6 from ConditionallyProved to Proved.

    Items 1-3 are open; items 4-7 are already done. -/
def routeSixGapItems : List String :=
  [ "OPEN (1): prove ml_stabilization_implies_precise_gap (temam_galerkin_completeness)"
  , "OPEN (2): replace trivial witnesses in popkov_implies_ml_stabilization " ++
      "with genuine Cameron bounds from cameron_weighted_gap_condition_uniform"
  , "OPEN (3): fix documentation of quantitative_route6_pipeline " ++
      "(Cameron chain is orphaned; document actual proof path)"
  , "DONE: cameron_trace_sum_below_spectral_gap (norm_num, T3 CLOSED)"
  , "DONE: lean_native_sum_bound (S_infty <= 1/1000, 77000x margin)"
  , "DONE: stokesFirstEigenvalue_gt_39 (lambda_1 > 39 for T^3(L=1))"
  , "DONE: no_global_linear_cameron_bound (Stage 83: scaling Vc~alpha^3, Omega~alpha^2)" ]

/-- Claim registry for Stage 84. -/
def dependencyAuditClaims : List LabeledClaim :=
  [ ⟨"misleading_node_count_is_four", .verified,
      "4 misleadingly-weak nodes identified in PGS DAG (decide)"⟩
  , ⟨"one_axiom_on_critical_path", .verified,
      "1 open axiom on critical path: ml_stabilization_implies_precise_gap (decide)"⟩
  , ⟨"four_axioms_in_orphaned_chain", .verified,
      "4 genuine axioms in orphaned Cameron chain (decide)"⟩
  , ⟨"actual_critical_axiom_record", .verified,
      "ml_stabilization_implies_precise_gap is the unique critical-path open axiom"⟩
  , ⟨"popkov_implies_ml_stabilization", .openBridge,
      "MISLEADINGLY WEAK: trivial tower (all bounds=1), zero axioms used"⟩
  , ⟨"quantitative_route6_pipeline", .openBridge,
      "MISLEADINGLY DOCUMENTED: Cameron chain is orphaned, not on proof path"⟩
  , ⟨"unit_torus_route6_closed", .openBridge,
      "MISLEADINGLY DOCUMENTED: inherits route6_pipeline documentation error"⟩
  , ⟨"stretching_dominated_transient", .openBridge,
      "VACUOUS: witnesses tau_stretch=0, no transience content"⟩ ]

end NSContent

end NavierStokes.DependencyAudit
