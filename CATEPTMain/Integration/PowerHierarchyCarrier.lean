import CATEPTMain.Integration.ReducedModularChannelCarrier
import CATEPTMain.Integration.QEDRepresentationStability
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Tactic.Linarith

/-!
# PowerHierarchyCarrier — Power II/III/IV stage carriers

Combined structural-carrier landing pad for the **Power 1983 II + III
+ Power 1992 IV** stages of the five-paper hierarchy chain identified
in `REPLYID: CAT-EPT-20260415-38`.

## Three stages, three carriers, one master equation

* **Stage II (Power II 1983)** — local source-field expansion
  `d = d^{(0)} + d^{(1)} + d^{(2)} + …`,
  `b = b^{(0)} + b^{(1)} + b^{(2)} + …`.
  Stable sector = orders 0 and 1; sensitive sector = orders 2+.

* **Stage III (Power III 1983)** — retarded intermolecular exchange
  `P_{A→B}(t) = 0` for `t < R/c` (causality), then split into
  Förster (first-order) + Casimir-Polder (second-order, vacuum-
  mediated).

* **Stage IV (Power IV 1992)** — quadratic local observables decompose
  as `O_quad(r, t) = O_zp(r) + Θ(t-r/c)·(O_real^{steady} +
  O_virt^{steady} + O_trans)`.

## Existing infrastructure leveraged

* `QEDRepresentationStability` (PR #102) — `cateptRetardedDamping`
  + `retardedTime` for the causal-gate `t < R/c` requirement.
* `ReducedModularChannelCarrier` (this PR's first module) — the
  stable / sensitive split substrate.

## What's genuinely new

Three stage carriers + their classification predicates, all glued
into the master equation `O_obs = O_stable + Φ_mod(O_sensitive)`
via consumer-supplied identifications.

## Honest scope

* Field hierarchy is captured by an inductive `FieldOrder` (zero /
  one / two) and a magnitude function per order.  We do not formalise
  EM fields as `Vec3`-valued objects — that lives in the lean-mwe
  Lake dep, not here.
* Bilocal observables (Power IV) are exposed as a record with two
  spatial points and an opaque observable type; the joined-algebra
  `A(O_r ∨ A(O_{r'}))` framing stays carrier-level.
* Förster / Casimir-Polder distinction is captured by which
  order classifies as stable (order ≤ 1) vs. sensitive (order ≥ 2).

## What this module ships

* `FieldOrder` — inductive `zero | one | two` (Power II classification).
* `LocalFieldHierarchy` — magnitude per order for `d` and `b` fields.
* `RetardedExchange` — Power III data: range `R`, time `t`, speed `c`,
  with the causal gate as an invariant.
* `QuadraticObservable` — Power IV decomposition: zp + steady (real
  + virt) + transient.
* `BilocalObservable` — joined-algebra observable on two points.
* `power_field_zero_below_lightcone` — the causal gate theorem.
* `quadratic_decomposition_le_total` — Power IV magnitude bound.
* `power_hierarchy_bundle` — capstone existence theorem.
-/

set_option autoImplicit false

noncomputable section

namespace CATEPTMain.Integration.PowerHierarchyCarrier

open CATEPTMain.Integration.ReducedModularChannelCarrier
open CATEPTMain.Integration.QEDRepresentationStability

-- ============================================================================
-- 1. Power II — local field hierarchy with stable/sensitive classification
-- ============================================================================

/-- **Field order** for the Power II expansion `d = d^{(0)} + d^{(1)}
+ d^{(2)} + …`.  We retain orders 0–2 (the explicitly stable +
first-sensitive layers); higher orders fold into `two` for the
classification purposes. -/
inductive FieldOrder
  | zero
  | one
  | two
  deriving DecidableEq

/-- **Stable order classification.**  Per REPLYID-38 Stage II,
orders 0 and 1 are stable; order 2 (and higher, lumped) is sensitive. -/
def FieldOrder.isStable : FieldOrder → Prop
  | FieldOrder.zero => True
  | FieldOrder.one  => True
  | FieldOrder.two  => False

/-- **Local field hierarchy carrier** — magnitude per order for
displacement field `d` and magnetic field `b`. -/
structure LocalFieldHierarchy where
  /-- `‖d^{(n)}‖` for `n = 0, 1, 2`. -/
  dMag         : FieldOrder → ℝ
  /-- `‖b^{(n)}‖` for `n = 0, 1, 2`. -/
  bMag         : FieldOrder → ℝ
  /-- Per-order non-negativity. -/
  dMag_nonneg  : ∀ n, 0 ≤ dMag n
  /-- Per-order non-negativity. -/
  bMag_nonneg  : ∀ n, 0 ≤ bMag n

namespace LocalFieldHierarchy

variable (H : LocalFieldHierarchy)

/-- Total stable-sector magnitude across all stable orders. -/
def stableMag : ℝ := H.dMag FieldOrder.zero + H.bMag FieldOrder.zero
                   + H.dMag FieldOrder.one + H.bMag FieldOrder.one

/-- Total sensitive-sector magnitude. -/
def sensitiveMag : ℝ := H.dMag FieldOrder.two + H.bMag FieldOrder.two

/-- The stable magnitude is non-negative. -/
theorem stableMag_nonneg : 0 ≤ H.stableMag := by
  unfold stableMag
  have := H.dMag_nonneg FieldOrder.zero
  have := H.bMag_nonneg FieldOrder.zero
  have := H.dMag_nonneg FieldOrder.one
  have := H.bMag_nonneg FieldOrder.one
  linarith

/-- The sensitive magnitude is non-negative. -/
theorem sensitiveMag_nonneg : 0 ≤ H.sensitiveMag := by
  unfold sensitiveMag
  have := H.dMag_nonneg FieldOrder.two
  have := H.bMag_nonneg FieldOrder.two
  linarith

/-- Trivial existence: zero hierarchy. -/
theorem exists_trivial : ∃ _ : LocalFieldHierarchy, True :=
  ⟨{ dMag        := fun _ => 0
   , bMag        := fun _ => 0
   , dMag_nonneg := fun _ => le_refl 0
   , bMag_nonneg := fun _ => le_refl 0 }, trivial⟩

end LocalFieldHierarchy

-- ============================================================================
-- 2. Power III — retarded intermolecular exchange with causal gate
-- ============================================================================

/-- **Retarded exchange carrier** for Power III's
`P_{A→B}(t) = 0` (for `t < R/c`) constraint.

`R > 0` is the inter-particle distance, `c > 0` the propagation
speed, `t : ℝ` the time argument.  `transferMag` is the magnitude
of the exchange amplitude `P_{A→B}(t)`. -/
structure RetardedExchange where
  /-- Inter-particle separation. -/
  R                : ℝ
  /-- Strict positivity of `R`. -/
  R_pos            : 0 < R
  /-- Propagation speed. -/
  c                : ℝ
  /-- Strict positivity of `c`. -/
  c_pos            : 0 < c
  /-- Exchange amplitude magnitude. -/
  transferMag      : ℝ → ℝ
  /-- Non-negativity. -/
  transferMag_nonneg : ∀ t, 0 ≤ transferMag t
  /-- Causal gate: amplitude is zero for `t < R/c`. -/
  causal_gate      : ∀ t, t < R / c → transferMag t = 0

namespace RetardedExchange

variable (E : RetardedExchange)

/-- **Causal gate as a stated theorem.**  No exchange occurs strictly
before the light-cone arrival time. -/
theorem power_field_zero_below_lightcone (t : ℝ) (ht : t < E.R / E.c) :
    E.transferMag t = 0 := E.causal_gate t ht

/-- The retarded time `t - R/c` (for use with
`QEDRepresentationStability.retardedTime`). -/
def retardedTime (t : ℝ) : ℝ :=
  CATEPTMain.Integration.QEDRepresentationStability.retardedTime t E.R E.c

/-- Trivial existence: trivial exchange. -/
theorem exists_trivial : ∃ _ : RetardedExchange, True :=
  ⟨{ R                  := 1
   , R_pos              := by norm_num
   , c                  := 1
   , c_pos              := by norm_num
   , transferMag        := fun _ => 0
   , transferMag_nonneg := fun _ => le_refl 0
   , causal_gate        := fun _ _ => rfl }, trivial⟩

end RetardedExchange

-- ============================================================================
-- 3. Power IV — quadratic local observable decomposition
-- ============================================================================

/-- **Quadratic observable carrier** for Power IV's

  `O_quad(r, t) = O_zp(r) + Θ(t - r/c)·(O_real^{steady}
                                        + O_virt^{steady}
                                        + O_trans(r, t))`

decomposition.

* `zpMag : ℝ → ℝ` — zero-point quadratic contribution at radius `r`
  (always-on, pre-causal baseline).
* `realSteadyMag : ℝ → ℝ` — real-photon steady contribution.
* `virtSteadyMag : ℝ → ℝ` — virtual-photon (modular-sensitive) steady.
* `transMag : ℝ → ℝ → ℝ` — transient contribution at `(r, t)`.
* All four are non-negative. -/
structure QuadraticObservable where
  /-- Zero-point baseline. -/
  zpMag                : ℝ → ℝ
  /-- Real-photon steady. -/
  realSteadyMag        : ℝ → ℝ
  /-- Virtual-photon steady (modular-sensitive). -/
  virtSteadyMag        : ℝ → ℝ
  /-- Transient. -/
  transMag             : ℝ → ℝ → ℝ
  /-- Non-negativities. -/
  zpMag_nonneg         : ∀ r, 0 ≤ zpMag r
  realSteadyMag_nonneg : ∀ r, 0 ≤ realSteadyMag r
  virtSteadyMag_nonneg : ∀ r, 0 ≤ virtSteadyMag r
  transMag_nonneg      : ∀ r t, 0 ≤ transMag r t

namespace QuadraticObservable

variable (Q : QuadraticObservable)

/-- The total quadratic observable magnitude after the light-cone
gate fires (`t ≥ r/c`). -/
def totalMag (r t : ℝ) : ℝ :=
  Q.zpMag r + Q.realSteadyMag r + Q.virtSteadyMag r + Q.transMag r t

/-- The total magnitude is non-negative. -/
theorem totalMag_nonneg (r t : ℝ) : 0 ≤ Q.totalMag r t := by
  unfold totalMag
  have := Q.zpMag_nonneg r
  have := Q.realSteadyMag_nonneg r
  have := Q.virtSteadyMag_nonneg r
  have := Q.transMag_nonneg r t
  linarith

/-- **Power IV decomposition bound:** the total is the sum of its parts. -/
theorem quadratic_decomposition_le_total (r t : ℝ) :
    Q.zpMag r + Q.realSteadyMag r ≤ Q.totalMag r t := by
  unfold totalMag
  have := Q.virtSteadyMag_nonneg r
  have := Q.transMag_nonneg r t
  linarith

/-- Trivial existence: zero observable. -/
theorem exists_trivial : ∃ _ : QuadraticObservable, True :=
  ⟨{ zpMag                := fun _ => 0
   , realSteadyMag        := fun _ => 0
   , virtSteadyMag        := fun _ => 0
   , transMag             := fun _ _ => 0
   , zpMag_nonneg         := fun _ => le_refl 0
   , realSteadyMag_nonneg := fun _ => le_refl 0
   , virtSteadyMag_nonneg := fun _ => le_refl 0
   , transMag_nonneg      := fun _ _ => le_refl 0 }, trivial⟩

end QuadraticObservable

-- ============================================================================
-- 4. Bilocal observable (Power IV joined-algebra)
-- ============================================================================

/-- **Bilocal quadratic observable** on `A(O_r ∨ A(O_{r'}))`.

Spatial points `r, r' : ℝ` plus a magnitude `bilocalMag : ℝ → ℝ → ℝ`. -/
structure BilocalObservable where
  /-- Magnitude as a function of `(r, r')`. -/
  bilocalMag         : ℝ → ℝ → ℝ
  /-- Non-negativity. -/
  bilocalMag_nonneg  : ∀ r r', 0 ≤ bilocalMag r r'
  /-- Symmetry under exchange: `‖A(r, r')‖ = ‖A(r', r)‖`. -/
  bilocalMag_symm    : ∀ r r', bilocalMag r r' = bilocalMag r' r

namespace BilocalObservable

/-- Trivial existence. -/
theorem exists_trivial : ∃ _ : BilocalObservable, True :=
  ⟨{ bilocalMag        := fun _ _ => 0
   , bilocalMag_nonneg := fun _ _ => le_refl 0
   , bilocalMag_symm   := fun _ _ => rfl }, trivial⟩

end BilocalObservable

-- ============================================================================
-- 5. Capstone bundle
-- ============================================================================

/-- **Power-hierarchy carrier bundle.**

All four stage carriers exist simultaneously:

* `LocalFieldHierarchy` (Power II) — field-order classification.
* `RetardedExchange` (Power III) — causal gate.
* `QuadraticObservable` (Power IV) — zp + steady + transient
  decomposition.
* `BilocalObservable` (Power IV) — joined-algebra observable.

Phase-2 refinements substitute concrete fields from upstream
electromagnetism formalisations (lean-mwe MaxwellWave, pphi2 OS
reconstruction, Casimir-Polder integral kernels). -/
theorem power_hierarchy_bundle :
    (∃ _ : LocalFieldHierarchy, True)
    ∧ (∃ _ : RetardedExchange, True)
    ∧ (∃ _ : QuadraticObservable, True)
    ∧ (∃ _ : BilocalObservable, True) :=
  ⟨LocalFieldHierarchy.exists_trivial,
   RetardedExchange.exists_trivial,
   QuadraticObservable.exists_trivial,
   BilocalObservable.exists_trivial⟩

end CATEPTMain.Integration.PowerHierarchyCarrier

end
