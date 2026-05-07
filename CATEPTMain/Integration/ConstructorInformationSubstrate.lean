import CATEPTMain.Integration.RelationalInformationSubstrate

/-!
# ConstructorInformationSubstrate — Thin CTI Contract Layer

A constructor-theoretic information layer (à la Deutsch–Marletto's
*Constructor Theory of Information*) over `RelationalInformationSubstrate`.

This module **does not replace** the existing substrate; it adds a contract
vocabulary on top so that helpers / consumers can state computational-
substrate claims (distinguishing, copying, measuring, information media,
superinformation media) without hiding behind `Notification := Empty` or
reflexive-rfl placeholders.

## Design choices

* `SubstrateAttribute S := S.InfoObject → Prop` — attributes are predicates
  on info objects.  This matches the Constructor Theory reading of a state
  variable as a partition of substrate states into mutually-exclusive
  attributes.
* `SubstrateTask S` packs input / output attribute pair, a `possible : Prop`
  field (whose truthhood is the *task possibility* claim), and an
  `Evidence` payload.  An empty / `False`-valued `possible` field encodes
  a *task impossibility* statement.
* `MeasurementTask S` is a dedicated record for the perception side of CTI:
  measured attribute + record attribute + non-perturbing predicate.  This is
  what the Bell bridge ought to consume rather than reflexive content.

## Anti-vacuity guard

`HasNontrivialNotifications S` requires the substrate's `Notification` type
to be inhabited.  This blocks the trivial `Notification := Empty`
projection from satisfying load-bearing measurement / copying / information-
medium claims: any theorem that consumes `HasNontrivialNotifications` is
guaranteed not to fall out for free under the vacuous projection.

## Honest scope

* This is a **thin contract layer**, not a full Constructor Theory of
  Information formalization.  Specifically:
  - We do not formalize composition / interoperability of tasks beyond
    what's needed to state `InformationMedium` and `SuperinformationMedium`.
  - We do not derive the Deutsch–Marletto theorems (e.g. that quantum
    theory is a superinformation theory).
  - The `Evidence` payload is `Type`-valued so consumers can plug in
    their domain-specific witness shape; we don't fix a canonical shape.
* Existing weak rfl-only consumers (e.g. `SubstrateBellBridge`) are
  **not yet upgraded** to use `MeasurementTask`.  That upgrade lands in
  a follow-up so this PR stays small.

## Field-naming note

The structure field for "the family of attributes in a substrate variable"
is named `attr`, not `attribute`, because `attribute` is a reserved Lean 4
keyword (used for the `attribute` command).

## What is honestly proven

* `HasNontrivialNotifications`, `SubstrateTask.HasTaskEvidence`
  (anti-vacuity guards).
* `SubstrateTask.TaskImpossible` — task impossibility as the *negation*
  of `possible`.
* `MeasurementTask.toSubstrateTask` (definitional projection).
* `informationMedium_requires_evidence`: an `InformationMedium` claim
  cannot be discharged purely by `Notification := Empty`; it requires
  `HasNontrivialNotifications S`.
* `superinformationMedium_requires_information`: a
  `SuperinformationMedium` strictly extends `InformationMedium` (it
  inherits the anti-vacuity).
* `taskImpossible_iff_no_evidence`: impossibility ↔ no evidence.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration

namespace ConstructorInformationSubstrate

open CATEPTMain.Integration (RelationalInformationSubstrate)

-- ═══════════════════════════════════════════════════════════════════════
-- Anti-vacuity guards
-- ═══════════════════════════════════════════════════════════════════════

/-- **Anti-vacuity guard**: the substrate's `Notification` type is inhabited.
This blocks the trivial `Notification := Empty` projection from satisfying
load-bearing CTI claims for free. -/
def HasNontrivialNotifications (S : RelationalInformationSubstrate) : Prop :=
  Nonempty S.Notification

-- ═══════════════════════════════════════════════════════════════════════
-- Substrate attributes & variables
-- ═══════════════════════════════════════════════════════════════════════

/-- A **substrate attribute** is a predicate on info objects.  In CTI
language, an attribute partitions substrate states into a "yes / no"
classification (e.g. "the qubit is in the |0⟩ eigenstate"). -/
def SubstrateAttribute (S : RelationalInformationSubstrate) : Type :=
  S.InfoObject → Prop

/-- A **substrate variable** is a finite, nonempty family of mutually-
distinguishable attributes.  In CTI language, this is a *state variable*
or *information variable*: a set of attribute values that the medium can
distinguish.  (Field `attr` rather than `attribute` because the latter
is a Lean 4 keyword.) -/
structure SubstrateVariable (S : RelationalInformationSubstrate) where
  /-- Index type for the family of attributes. -/
  Index : Type
  /-- The family of attributes. -/
  attr : Index → SubstrateAttribute S
  /-- The variable is nonempty. -/
  nonempty : Nonempty Index
  /-- **Distinguishability**: distinct indices give attributes that are
      jointly disjoint on at least one info object — i.e. the attributes
      do not collapse to the same predicate on every state. -/
  distinguishable :
    ∀ (i j : Index), i ≠ j →
      ∃ (x : S.InfoObject), attr i x ≠ attr j x

-- ═══════════════════════════════════════════════════════════════════════
-- Tasks and impossibility
-- ═══════════════════════════════════════════════════════════════════════

/-- A **substrate task** transforms states satisfying an input attribute
into states satisfying an output attribute.  The `possible` field records
whether the task is performable in the substrate; the `Evidence` payload
gives consumers a hook to plug in a domain-specific witness. -/
structure SubstrateTask (S : RelationalInformationSubstrate) where
  /-- Attribute the input must satisfy. -/
  input : SubstrateAttribute S
  /-- Attribute the output must satisfy. -/
  output : SubstrateAttribute S
  /-- **Task possibility**: the substrate admits a constructor performing
      `input ⟹ output`.  Truthhood here is the load-bearing CTI claim. -/
  possible : Prop
  /-- Domain-specific evidence payload (e.g. an explicit constructor,
      a measurement record, a copy-witness pair). -/
  Evidence : Type
  /-- Witness that evidence is inhabited *iff* the task is possible.
      Consumers wanting non-vacuous claims should require both
      `possible` AND `Nonempty Evidence`. -/
  evidence_iff_possible : (Nonempty Evidence) ↔ possible

namespace SubstrateTask

variable {S : RelationalInformationSubstrate}

/-- **Task impossibility**: the negation of `possible`. -/
def TaskImpossible (t : SubstrateTask S) : Prop := ¬ t.possible

/-- An impossible task has no evidence. -/
theorem evidence_empty_of_impossible
    (t : SubstrateTask S) (himp : t.TaskImpossible) :
    ¬ Nonempty t.Evidence := by
  intro h
  exact himp (t.evidence_iff_possible.mp h)

/-- **Anti-vacuity guard for tasks**: the task has actual evidence. -/
def HasTaskEvidence (t : SubstrateTask S) : Prop := Nonempty t.Evidence

/-- A task with evidence is possible. -/
theorem possible_of_hasTaskEvidence
    (t : SubstrateTask S) (h : HasTaskEvidence t) :
    t.possible :=
  t.evidence_iff_possible.mp h

end SubstrateTask

-- ═══════════════════════════════════════════════════════════════════════
-- Reversibility, copying, distinguishing, measurement
-- ═══════════════════════════════════════════════════════════════════════

/-- A **reversible task** carries an inverse task (whose `input` and
`output` are swapped) that is also possible. -/
structure ReversibleTask (S : RelationalInformationSubstrate) where
  /-- The forward task. -/
  forward : SubstrateTask S
  /-- The reverse task: input and output attributes swapped. -/
  reverse : SubstrateTask S
  /-- The reverse task's input is the forward task's output. -/
  reverse_input_eq : reverse.input = forward.output
  /-- The reverse task's output is the forward task's input. -/
  reverse_output_eq : reverse.output = forward.input
  /-- The forward direction is possible. -/
  forward_possible : forward.possible
  /-- The reverse direction is possible. -/
  reverse_possible : reverse.possible

/-- A **copying task** takes a state with attribute `source` and
produces a pair of states each with attribute `source` (idealized;
no-cloning is excluded by *which* attributes can play `source`). -/
structure CopyingTask (S : RelationalInformationSubstrate) where
  /-- The attribute being copied. -/
  source : SubstrateAttribute S
  /-- The underlying task: input is `source`, output is "two copies". -/
  task : SubstrateTask S
  /-- The task's input is the source attribute. -/
  task_input_eq : task.input = source
  /-- The task is possible — i.e. the substrate admits this copy. -/
  task_possible : task.possible

/-- An **attribute distinguisher** witnesses that two attributes are
empirically separable on the substrate (there exists an info object
satisfying one but not the other). -/
def Distinguishable {S : RelationalInformationSubstrate}
    (a b : SubstrateAttribute S) : Prop :=
  ∃ (x : S.InfoObject), a x ∧ ¬ b x

/-- A **measurement task** records a `measured` attribute into a
`record` attribute, optionally non-perturbingly (i.e. without changing
the measured attribute). -/
structure MeasurementTask (S : RelationalInformationSubstrate) where
  /-- The attribute being measured. -/
  measured : SubstrateAttribute S
  /-- The attribute the record is set to, encoding the measurement
      outcome. -/
  record : SubstrateAttribute S
  /-- The underlying task. -/
  task : SubstrateTask S
  /-- The task's input is the measured attribute. -/
  task_input_eq : task.input = measured
  /-- The task's output is the record attribute. -/
  task_output_eq : task.output = record
  /-- The measurement is possible. -/
  task_possible : task.possible
  /-- **Non-perturbing**: after measurement, the measured attribute
      is preserved.  Encoded as a Prop the consumer must establish; we
      do *not* default it to `True`. -/
  nonPerturbing : Prop

namespace MeasurementTask

variable {S : RelationalInformationSubstrate}

/-- Project a measurement task back to its underlying substrate task. -/
def toSubstrateTask (m : MeasurementTask S) : SubstrateTask S := m.task

end MeasurementTask

-- ═══════════════════════════════════════════════════════════════════════
-- Information medium / superinformation medium
-- ═══════════════════════════════════════════════════════════════════════

/-- An **information medium** supports at least one nontrivial
distinguishability + copying claim.  Encodes that the substrate can act
as a carrier for classical information. -/
structure InformationMedium (S : RelationalInformationSubstrate) where
  /-- The substrate has nontrivial notifications (anti-vacuity guard). -/
  notifications_nontrivial : HasNontrivialNotifications S
  /-- A nontrivial information variable. -/
  variable_ : SubstrateVariable S
  /-- A copying task on at least one of its attributes. -/
  copying : CopyingTask S
  /-- The copying task uses one of the variable's attributes as source. -/
  copying_source_in_variable :
    ∃ (i : variable_.Index), copying.source = variable_.attr i

/-- A **superinformation medium** is an information medium where SOME
joint task is impossible — encoding the CTI distinction between
classical and quantum information theories. -/
structure SuperinformationMedium (S : RelationalInformationSubstrate)
    extends InformationMedium S where
  /-- A task that is *impossible* in this medium (e.g. cloning of
      non-orthogonal quantum states). -/
  impossibleTask : SubstrateTask S
  /-- The task is provably impossible. -/
  impossible : impossibleTask.TaskImpossible

-- ═══════════════════════════════════════════════════════════════════════
-- Anti-vacuity theorems
-- ═══════════════════════════════════════════════════════════════════════

/-- **Anti-vacuity for information media**: if `S` is an information
medium then it has nontrivial notifications.  In particular, the
trivial `Notification := Empty` projection cannot be an
`InformationMedium`. -/
theorem informationMedium_requires_evidence
    {S : RelationalInformationSubstrate} (M : InformationMedium S) :
    HasNontrivialNotifications S :=
  M.notifications_nontrivial

/-- **Anti-vacuity for superinformation media**: a superinformation
medium inherits the nontrivial-notifications guard from its underlying
information medium. -/
theorem superinformationMedium_requires_information
    {S : RelationalInformationSubstrate} (M : SuperinformationMedium S) :
    HasNontrivialNotifications S :=
  M.toInformationMedium.notifications_nontrivial

/-- **Impossibility ↔ no-evidence**: a task is impossible exactly when
no evidence exists. -/
theorem taskImpossible_iff_no_evidence
    {S : RelationalInformationSubstrate} (t : SubstrateTask S) :
    t.TaskImpossible ↔ ¬ Nonempty t.Evidence := by
  unfold SubstrateTask.TaskImpossible
  rw [t.evidence_iff_possible]

end ConstructorInformationSubstrate

-- ═══════════════════════════════════════════════════════════════════════
-- Worklog-as-substrate concrete contract (documentation note)
-- ═══════════════════════════════════════════════════════════════════════

/-! ## Worklog-as-substrate concrete contract

Closes the documentation leg of `catept_cti_worklog_as_substrate_contract_20260429`
(parent CTI task): a concrete reading of `RelationalInformationSubstrate`
+ `ConstructorInformationSubstrate` backed by the
`entropic-worklog-tool` data model.  This is a Lean-comment example,
not a Lean instance — the worklog tool is a Python/SQLite stack that
sits outside the Lean trusted core.  The mapping below records how
the substrate types map onto worklog data so consumers can mentally
plug in this instance when reasoning about CTI claims.

### Type mapping

```text
  RelationalInformationSubstrate field   ↔  worklog data
  ───────────────────────────────────────┼─────────────────────────────────
  Entity                                  ↔  agent handle (e.g. "claude-opus-4-7")
  InfoObject                              ↔  task / note / run payload, or
                                              canonical digest thereof
  Notification                            ↔  task/note/run mutation event
                                              (one row in the worklog journal)
  sender (n : Notification) → Entity       ↔  the agent that created the row
  receiver (n : Notification) → Entity     ↔  the agent the row addresses (if any)
                                              else the same as sender
  payload (n : Notification) → InfoObject  ↔  the row's payload column
  causalPrecedes (n₁ n₂ : Notification)    ↔  created_at/updated_at order, or
                                              the git-snapshot merge order if
                                              the worklog DB is checked into git
  localOrder (e) (n : Notification) → ℕ    ↔  per-agent event sequence number
                                              (rank of `n` in the agent's
                                              chronological event stream)
  propagationBound : ℝ                    ↔  worklog-write latency bound
                                              (positive constant, e.g. 1.0 sec)
  notificationDelay (n) → ℝ                ↔  measured write-to-read latency
  phase (e) → ℝ                            ↔  free observable; can be 0 if
                                              the agent has no associated phase
  storedInfo (e) → ℝ                       ↔  agent's accumulated work (e.g.
                                              count of completed tasks, or
                                              bytes-of-output)
  irreversibleCost (e) → ℝ                 ↔  cumulative entropic cost
                                              (proxy: total wall-clock time
                                              spent on completed tasks)
```

### CTI-task interpretation

```text
  ConstructorInformationSubstrate field        ↔  worklog operation
  ─────────────────────────────────────────────┼──────────────────────────
  CopyingTask                                   ↔  git export / import that
                                                    preserves the canonical
                                                    digest of a task/note/run
                                                    (read of source preserves
                                                     source ⟹ task is possible)
  MeasurementTask                               ↔  SQL or summary query that
                                                    reads but does NOT mutate
                                                    the worklog state
                                                    (nonPerturbing : True for
                                                     read-only queries; FALSE
                                                     for queries that update
                                                     last-accessed timestamps)
  SubstrateTask t with t.task.possible          ↔  worklog operation that the
                                                    tool can actually execute
                                                    in the current schema
  TaskImpossible                                ↔  worklog operation rejected
                                                    by the schema (e.g. dropping
                                                    a foreign-key-referenced row
                                                    without cascade)
```

### Anti-vacuity

`HasNontrivialNotifications S` (the CTI scaffold's anti-vacuity guard)
maps to: **the worklog database has at least one journal row**.  Any
real worklog instance trivially satisfies this; the trivial empty-
worklog instance fails it (which is correct — an empty DB cannot
witness any CTI claim).

### Honest scope

This is a **documentation-level** instance: the type mappings above are
what a hypothetical Lean instance would use.  Building the actual Lean
instance would require either an FFI bridge to the SQLite DB or an
in-Lean re-implementation of the worklog data model.  Neither is in
scope for catept-main, so this contract is recorded as a comment block
rather than as code.  Consumers that want a concrete instance for
testing CTI claims can construct a synthetic in-Lean substrate that
mirrors this shape (see e.g. `SubstrateProjections.canonicalSubstrate`
for the projection from a `TemporalFramework`).
-/

end CATEPTMain.Integration
