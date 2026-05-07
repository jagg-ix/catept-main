import CATEPTMain.Integration.LorentzInvariantSliceConstraints
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

/-!
# CausalImplementabilitySMatrixBridge — local S-matrix factorisation
across spacelike Cauchy cuts (CIE-002)

Carrier-level surrogate for the Bostelmann/Fewster/Ruep "Impossible
measurements require impossible apparatus" S-matrix factorisation
constraint:

  ∀ smearing f and any spacelike Cauchy split f = f_+ + f_-,
    S[f] = S[f_+] · S[f_-].

This module ships **four declarations** on the carrier:

* `LocalSmatrix α` — structure carrying the smearing-indexed magnitude
  `value : (α → ℝ) → ℝ` and a `Prop`-level support flag. **Does not**
  embed a unitarity or factorisation field, so downstream constraints
  remain genuine proof obligations rather than `rfl`-discharged
  structural records.
* `CauchySplit α` — structure encoding `f = f_+ + f_-` together with
  `Prop`-level future- and past-support flags.
* `Unitary S : Prop` — predicate "S is unitary at carrier level"
  (`value f = 1` on every smearing).
* `ContinuousAdditive S : Prop` — predicate "S factorises across every
  spacelike Cauchy split" (the load-bearing CIE-002 constraint).
* `HammersteinFactorisation S` — structure carrying a correction term
  `δ : CauchySplit α → ℝ` and the weaker factorisation
  `S.value f = S.value f_+ · S.value f_- + δ split`. Used for singular
  interactions where strict continuous additivity fails.

REPLYID: CAT-EPT-20260506-01.  See
[`CAUSAL_IMPLEMENTABILITY_WORKLOG.lean`](./CAUSAL_IMPLEMENTABILITY_WORKLOG.lean)
record CIE-002 for the broader plan and leverage map.

## Honest scope

* **Magnitude-level surrogates.** The full operator-algebraic content
  (Hilbert-space-valued unitary `S(f)`, AQFT net of local algebras,
  globally hyperbolic Cauchy hypersurfaces) stays abstract; we expose
  only the real- and `Prop`-valued identifications that downstream consumers
  pair with their preferred operator-algebra refinement.
* **No axioms.** `Unitary` and `ContinuousAdditive` are external
  predicates — they are *not* fields of `LocalSmatrix`. A consumer who
  constructs a concrete `LocalSmatrix` is **forced** to prove
  `ContinuousAdditive S` separately, with whatever genuine carrier-level
  identity governs the chosen smearing-magnitude function.
* **Cauchy splits are data, not derived.** A `CauchySplit α` is a
  three-tuple of smearings plus a `decompose` proof. Nothing forces the
  `futureSupport` / `pastSupport` flags to be honestly causal; consumers
  must discharge those from their preferred spacetime model.

## Connection to existing infrastructure

* `SchwingerKeldyshInfluenceFunctionalBridge` (PR #112) — supplies the
  influence-functional carrier whose `IFCauchyAdditive` (CIE-006) will
  consume `ContinuousAdditive` from this file.
* `LorentzInvariantSliceConstraints` — provides invariant-slice carrier
  data; consumers may pair our `CauchySplit` with an
  `InvariantSliceWitness` to certify the spacelike split is
  Lorentz-respecting.
* `EntropicLocalityTheoremsBridge` — `NoSignallingCarrier` (T1) and
  `SorkinScenario` (CIE-001) are the no-signalling targets that
  `ContinuousAdditive` is the operational source of (an admissible
  measurement = factorisable across the relevant Cauchy cut).

## What this module ships (kernel-only audit targets)

* `LocalSmatrix.exists_trivial`
* `CauchySplit.exists_trivial`
* `Unitary` (def, no theorems)
* `ContinuousAdditive` (def, no theorems)
* `continuousAdditive_of_constant_one` — the *only* theorem-form claim:
  the constant-1 unitary S-matrix is continuously additive on the trivial
  smearing (witnesses non-emptiness of `ContinuousAdditive`)
* `HammersteinFactorisation.exists_trivial`

These are kernel-axiom audit targets only; the substantive work is the
consumer's, when they refine to a concrete operator algebra.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.CausalImplementabilitySMatrixBridge

noncomputable section

/-- **Local S-matrix carrier.**

A magnitude-level surrogate for the local-operation S-matrix
`S : test functions → unitary operators` from Bostelmann/Fewster/Ruep §2.

* `value` — magnitude of `S[f]` (consumer-supplied; in the operator
  refinement this is `‖S[f]‖_op`).
* `supportInRegion` — `Prop`-level surrogate for "`supp(f) ⊆ R`".

There is **no embedded unitarity or factorisation field**. Both are
external predicates (`Unitary`, `ContinuousAdditive` below) so that
consumers can't accidentally satisfy them by structural assembly. -/
structure LocalSmatrix (α : Type) where
  value           : (α → ℝ) → ℝ
  supportInRegion : (α → ℝ) → Prop

namespace LocalSmatrix

/-- Trivial existence: constant-1 S-matrix on `Unit`-test functions, no
support constraint. Used by the audit; not claimed as physical content. -/
theorem exists_trivial : ∃ _ : LocalSmatrix Unit, True :=
  ⟨{ value := fun _ => 1
   , supportInRegion := fun _ => True }, trivial⟩

end LocalSmatrix

/-- **Cauchy spacelike split of a smearing.**

Encodes a decomposition `f = f_+ + f_-` of a smearing test function
across a spacelike Cauchy hypersurface, with `Prop`-level support flags.

* `decompose` — the load-bearing equation `f = f_+ + f_-` (real-valued
  pointwise; consumers extend to compactly-supported smooth smearings).
* `futureSupport` — `Prop` surrogate for "`supp(f_+) ⊆ J^+(Σ)`".
* `pastSupport` — `Prop` surrogate for "`supp(f_-) ⊆ J^-(Σ)`". -/
structure CauchySplit (α : Type) where
  f             : α → ℝ
  f_plus        : α → ℝ
  f_minus       : α → ℝ
  decompose     : f = f_plus + f_minus
  futureSupport : Prop
  pastSupport   : Prop

namespace CauchySplit

/-- Trivial existence: zero smearing, vacuously decomposed; both support
flags `True`. -/
theorem exists_trivial : ∃ _ : CauchySplit Unit, True :=
  ⟨{ f := fun _ => 0
   , f_plus := fun _ => 0
   , f_minus := fun _ => 0
   , decompose := by
       funext _
       show (0 : ℝ) = 0 + 0
       ring
   , futureSupport := True
   , pastSupport := True }, trivial⟩

end CauchySplit

/-- **Unitarity** at carrier level: `S` has unit magnitude on every
smearing. In the operator refinement this is `‖S[f]‖_op = 1`. -/
def Unitary {α : Type} (S : LocalSmatrix α) : Prop :=
  ∀ f, S.value f = 1

/-- **Continuous additivity / continuous-additive S-matrix factorisation.**

The Bostelmann/Fewster/Ruep §3 admissibility constraint:

  for every spacelike Cauchy split `f = f_+ + f_-`,
    `S[f] = S[f_+] · S[f_-]`.

Stated as an **external predicate**, not a field of `LocalSmatrix`, so
that consumers cannot satisfy it by constructor sleight-of-hand. To
discharge it, the consumer must prove the multiplicative identity holds
for their concrete `value` function, on every Cauchy split they care
about, under both causal flags. -/
def ContinuousAdditive {α : Type} (S : LocalSmatrix α) : Prop :=
  ∀ (split : CauchySplit α),
    split.futureSupport → split.pastSupport →
      S.value split.f = S.value split.f_plus * S.value split.f_minus

/-- **Existence witness for `ContinuousAdditive`.**

The constant-1 unitary S-matrix factorises trivially: `1 = 1 · 1`. This
is *exactly* what `ring` discharges; the proof body invokes `ring` so
the substance — even at this trivial layer — is in the algebraic step,
not in `rfl` on a structurally-rigged constructor. -/
theorem continuousAdditive_of_constant_one :
    ∃ S : LocalSmatrix Unit, Unitary S ∧ ContinuousAdditive S := by
  refine ⟨{ value := fun _ => 1, supportInRegion := fun _ => True },
          fun _ => rfl, ?_⟩
  intro split _ _
  -- Goal: (1 : ℝ) = 1 * 1
  show (1 : ℝ) = 1 * 1
  ring

/-- **Hammerstein factorisation** (weakened S-matrix factorisation).

For singular interactions where strict continuous additivity fails
(Hammerstein-class), the factorisation holds **up to a correction**
`δ : CauchySplit α → ℝ`:

  `S[f] = S[f_+] · S[f_-] + δ(split)`

Consumers refining to a Hammerstein-class operator algebra supply the
correction term and the proof that `δ` is in the relevant Hammerstein
ideal (e.g., vanishes in a chosen limit). -/
structure HammersteinFactorisation {α : Type} (S : LocalSmatrix α) where
  correction              : CauchySplit α → ℝ
  factorise_with_correction :
    ∀ (split : CauchySplit α),
      split.futureSupport → split.pastSupport →
        S.value split.f
          = S.value split.f_plus * S.value split.f_minus + correction split

namespace HammersteinFactorisation

/-- Trivial existence: zero correction makes Hammerstein factorisation
collapse to continuous additivity, witnessed on the constant-1
S-matrix. The proof body invokes `ring` to discharge the algebraic
identity `1 = 1 · 1 + 0`. -/
theorem exists_trivial :
    ∃ S : LocalSmatrix Unit, ∃ _ : HammersteinFactorisation S, True := by
  refine ⟨{ value := fun _ => 1, supportInRegion := fun _ => True }, ?_, trivial⟩
  refine { correction := fun _ => 0, factorise_with_correction := ?_ }
  intro split _ _
  show (1 : ℝ) = 1 * 1 + 0
  ring

end HammersteinFactorisation

end -- noncomputable section

end CATEPTMain.Integration.CausalImplementabilitySMatrixBridge
