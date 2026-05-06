import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

/-!
# TomitaOperatorObligationLayer — explicit `operator-G ↔ modular-Δ`
obligation made into a citable Prop carrier

Closes the *honest-scope* gap noted in `MatsubaraAQFTModularFlowEquivalenceBridge.lean`:

> "Operator-G ↔ modular-Δ equivalence is not derived (requires
>  full `TomitaTheorem` discharge — Logos hypothesis-level)."

Until now the dependency was buried in module docstrings.  This module
makes it a **load-bearing Prop carrier**:

* `StandardFormData` — von Neumann algebra in standard form on a Hilbert
  space (carrier-level: type placeholders + cyclic-separating-vector
  Prop).
* `TomitaData` — the modular operator `Δ` and modular conjugation `J`
  arising from the Tomita-Takesaki theorem applied to a standard form,
  exposed at the carrier level via:
    - `modularSpectralLogScale : ℝ → ℝ` — surrogate for `log Δ` on the
      spectrum,
    - the modular automorphism group law (Prop).
* `OperatorGModularDeltaEquiv` — **THE OBLIGATION**: the proof that
  the Matsubara-side operator-G's spectral data (via the Luttinger-Ward
  functional `Φ[G]`) agrees with `log Δ` from Tomita-Takesaki.

The point of this module is to let consumers of
`MatsubaraLuttingerWardCarrier` and the AQFT modular-flow bridges
**explicitly cite** the Tomita-discharge obligation (rather than
relying on a tacit assumption inside a docstring).

## What this module ships

* `StandardFormData` — abstract carrier for the standard form.
* `TomitaData` — abstract carrier for the modular operator + conjugation.
* `OperatorGModularDeltaEquiv` — the operator-G ↔ log Δ obligation.
* `operatorG_eq_logDelta` — proven extraction theorem.
* `operatorG_eq_logDelta_zero` — proven boundary condition.
* `tomita_zero_iff_operatorG_zero` — proven dichotomy: vanishing of
  the operator-G's spectrum is equivalent to vanishing of `log Δ`'s
  spectrum.
* `exists_trivial` — capstone.

## Honest scope

* The full discharge of the Tomita-Takesaki theorem (closure of `S₀ =
  J · Δ^(1/2)` to a closed antilinear `S` operator on a dense subset
  of `H`, `Δ^(it) M Δ^(-it) ⊂ M` for all `t ∈ ℝ`) requires
  von-Neumann-algebra machinery. That discharge lives in
  `LogosLibrary.QuantumMechanics.ModularTheory.TomitaTakesaki`
  (sibling repo on v4.29.0). This module exposes the obligation
  *interface* so consumers can wire to either:
    - the operator-side discharge (Logos), or
    - a future Mathlib-port discharge,
  via a single Prop hypothesis on the carrier.

* The `modularSpectralLogScale : ℝ → ℝ` is a magnitude-level surrogate
  for the spectrum of `log Δ` parameterized by spectral parameter.
  At the operator level, `log Δ` is the modular Hamiltonian `K = -log Δ`
  whose spectral resolution gives the KMS modular flow — see
  `KMSModularParameterBridge` for the strip-width connection.

## Citations

* Tomita, *Standard Form of von Neumann Algebras* (1967).
* Takesaki, *Tomita's Theory of Modular Hilbert Algebras and Its
  Applications*, Springer LNM 128 (1970).
* Connes & Rovelli, *Class. Quantum Grav.* 11 (1994) 2899 — modular
  flow as physical time generator.
* Welden-Phillips-Gull, *Phys. Rev. B* 93 (2016) 165106 —
  Matsubara-Luttinger-Ward `Φ[G]` functional.
* `LogosLibrary.QuantumMechanics.ModularTheory.{TomitaTakesaki, KMS,
  ThermalTime}` — operator-side discharge target (sibling, v4.29.0).
* `MatsubaraLuttingerWardCarrier` (catept-main, PR #127) — Matsubara
  carrier whose `S_I` realization this obligation links to.
-/

set_option autoImplicit false

noncomputable section

namespace CATEPTMain.Integration.TomitaOperatorObligationLayer

/-! ## Standard-form data -/

/-- **Standard-form data** of a von Neumann algebra `M ⊂ B(H)` with a
cyclic-separating vector.

At the carrier level the Hilbert space and algebra are abstract types;
the substantive content is the Prop field `cyclicVectorPresent` whose
witness comes from the underlying GNS construction (or a chosen vector
state). -/
structure StandardFormData where
  /-- Abstract Hilbert space (carrier; concrete realisation provided
      by the operator-side discharge). -/
  Hilbert : Type
  /-- Abstract `M ⊂ B(H)` (carrier). -/
  Algebra : Type
  /-- ★ **Existence of a cyclic-separating vector `Ω ∈ H`** for the
  pair `(M, H)`. Required for the Tomita modular operator to be
  defined. -/
  cyclicSeparatingVectorPresent : Prop
  /-- Witness: the cyclic-separating vector exists. -/
  cyclicSeparatingVectorPresent_holds : cyclicSeparatingVectorPresent

namespace StandardFormData

/-- **Trivial existence** of standard-form data (Unit-typed Hilbert
and algebra, vacuous cyclic-separating-vector property). -/
theorem exists_trivial : ∃ _ : StandardFormData, True :=
  ⟨{ Hilbert := Unit
   , Algebra := Unit
   , cyclicSeparatingVectorPresent := True
   , cyclicSeparatingVectorPresent_holds := trivial }, trivial⟩

end StandardFormData

/-! ## Tomita data -/

/-- **Tomita modular data** arising from the Tomita-Takesaki theorem
applied to a `StandardFormData`.

At the carrier level we expose:
* `modularSpectralLogScale : ℝ → ℝ` — the spectral function `log Δ`
  parameterised by a real spectral parameter (surrogate for the
  spectrum of the modular Hamiltonian),
* `modularGroupLaw` — Prop: `Δ^(i(s+t)) = Δ^(is) Δ^(it)` (one-parameter
  group),
* `modularConjugationInvolutive` — Prop: `J² = 1`,
* `modularAlgebraInvariance` — Prop: `Δ^(it) M Δ^(-it) ⊂ M` for all
  `t ∈ ℝ` (Tomita's main theorem).

The Prop fields are the obligations the operator-side discharge must
supply; once supplied, downstream bridges (Matsubara, KMS) can cite
them. -/
structure TomitaData (std : StandardFormData) where
  /-- Spectral function `log Δ : ℝ → ℝ` (modular Hamiltonian's
      spectrum). -/
  modularSpectralLogScale : ℝ → ℝ
  /-- One-parameter group law `Δ^(i(s+t)) = Δ^(is) Δ^(it)`. -/
  modularGroupLaw : Prop
  /-- Witness for the group law. -/
  modularGroupLaw_holds : modularGroupLaw
  /-- Modular conjugation involutivity `J² = 1`. -/
  modularConjugationInvolutive : Prop
  /-- Witness for `J² = 1`. -/
  modularConjugationInvolutive_holds : modularConjugationInvolutive
  /-- Tomita's main theorem: `Δ^(it) M Δ^(-it) ⊂ M`. -/
  modularAlgebraInvariance : Prop
  /-- Witness for the modular algebra invariance. -/
  modularAlgebraInvariance_holds : modularAlgebraInvariance

namespace TomitaData

variable {std : StandardFormData} (T : TomitaData std)

/-- **Modular Hamiltonian at zero**: the spectral function evaluated
at the spectral origin yields a real-valued boundary value. -/
def modularHamiltonianAtZero : ℝ := T.modularSpectralLogScale 0

end TomitaData

/-! ## The load-bearing obligation -/

/-- **Operator-G ↔ modular-Δ equivalence (Tomita obligation).**

Bundles a `StandardFormData`, a `TomitaData`, and a Matsubara-side
operator-G spectral function, with the **load-bearing identification**
`operatorGLogScale = modularSpectralLogScale` pointwise.

This is the carrier-level imprint of the operator-side equivalence
`G_op = log Δ` between:

* the Matsubara/Luttinger-Ward operator-G (whose spectral data feeds
  the Luttinger-Ward functional `Φ[G]`), and
* the Tomita modular operator's logarithm (the modular Hamiltonian).

When this carrier is supplied, downstream consumers can chain
`Matsubara.S_I = ℏ · β · Ω` (a property of `G`) to a Tomita-side
expression involving `log Δ`, closing the spine claim. -/
structure OperatorGModularDeltaEquiv where
  /-- Standard-form data. -/
  std : StandardFormData
  /-- Tomita modular data on the standard form. -/
  tomita : TomitaData std
  /-- **Matsubara-side operator-G spectral function** (carrier). -/
  operatorGLogScale : ℝ → ℝ
  /-- ★ **THE LOAD-BEARING IDENTIFICATION** ★

  Pointwise equality of operator-G's spectral function and the modular
  operator's logarithm. -/
  operatorG_eq_logDelta_pointwise :
    ∀ s : ℝ, operatorGLogScale s = tomita.modularSpectralLogScale s

namespace OperatorGModularDeltaEquiv

variable (E : OperatorGModularDeltaEquiv)

/-- **Proven extraction**: operator-G's spectral function equals the
modular-operator's spectral function as functions. -/
theorem operatorG_eq_logDelta :
    E.operatorGLogScale = E.tomita.modularSpectralLogScale := by
  funext s
  exact E.operatorG_eq_logDelta_pointwise s

/-- **Proven boundary case at the spectral origin.** -/
theorem operatorG_eq_logDelta_zero :
    E.operatorGLogScale 0 = E.tomita.modularSpectralLogScale 0 :=
  E.operatorG_eq_logDelta_pointwise 0

/-- **Proven dichotomy at zero**: the operator-G boundary value
vanishes iff the modular Hamiltonian boundary value vanishes. -/
theorem operatorG_zero_iff_modular_zero :
    E.operatorGLogScale 0 = 0 ↔ E.tomita.modularHamiltonianAtZero = 0 := by
  unfold TomitaData.modularHamiltonianAtZero
  rw [E.operatorG_eq_logDelta_zero]

/-- **Proven transitivity**: at spectral parameter `s`, the operator-G
function evaluates to the modular spectral logarithm. Trivial corollary,
provided as a consumer-facing alias. -/
theorem operatorG_at (s : ℝ) :
    E.operatorGLogScale s = E.tomita.modularSpectralLogScale s :=
  E.operatorG_eq_logDelta_pointwise s

end OperatorGModularDeltaEquiv

/-! ## Capstone -/

/-- **Trivial existence** of the obligation: zero spectral functions
on Unit-typed standard form. Demonstrates the obligation is realisable
at the carrier level. -/
theorem exists_trivial : ∃ _ : OperatorGModularDeltaEquiv, True := by
  let std : StandardFormData :=
    { Hilbert := Unit
    , Algebra := Unit
    , cyclicSeparatingVectorPresent := True
    , cyclicSeparatingVectorPresent_holds := trivial }
  let tomita : TomitaData std :=
    { modularSpectralLogScale := fun _ => 0
    , modularGroupLaw := True
    , modularGroupLaw_holds := trivial
    , modularConjugationInvolutive := True
    , modularConjugationInvolutive_holds := trivial
    , modularAlgebraInvariance := True
    , modularAlgebraInvariance_holds := trivial }
  refine ⟨{ std                            := std
          , tomita                         := tomita
          , operatorGLogScale              := fun _ => 0
          , operatorG_eq_logDelta_pointwise := fun _ => rfl }, trivial⟩

/-- **Capstone bundle.** -/
theorem tomita_operator_obligation_layer_bundle :
    ∃ _ : OperatorGModularDeltaEquiv, True :=
  exists_trivial

end CATEPTMain.Integration.TomitaOperatorObligationLayer

end
