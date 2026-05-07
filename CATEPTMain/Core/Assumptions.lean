/-!
# Physical-identification assumption registry

Every non-derived physical premise in catept-main wraps through the
`CATEPTAssumption` abbrev with a stable string id. This enables:

* `rg "AssumptionId\.\w+"` to enumerate every registered premise across
  the tree,
* auto-generated [`docs/architecture/ASSUMPTIONS.md`](../../docs/architecture/ASSUMPTIONS.md)
  with per-id reference counts and dead-assumption detection,
* a CI gate (`.github/workflows/axiom-gate.yml`) that rejects a
  `CATEPTAssumption "<id>"` whose id is not registered here.

Pattern borrowed from
[PhysicsLogic](https://github.com/xiyin137/PhysicsLogic) — see
[`docs/architecture/plugin-rework-proposal.md`](../../docs/architecture/plugin-rework-proposal.md)
§2 for the rationale.

## Usage

```lean
import CATEPTMain.Core.Assumptions
open CATEPTMain (CATEPTAssumption)
open CATEPTMain.AssumptionId

/-- Use CATEPTAssumption for *provable* physical identifications: -/
theorem hbar_eq_two_nu (ν : ℝ) (hν : 0 < ν) :
    CATEPTAssumption hbarIsTwoNu (∃ hbar : ℝ, hbar = 2 * ν) :=
  ⟨2 * ν, rfl⟩

/-- And also for genuine `axiom` declarations (premises not yet derived): -/
axiom weyl_law_holds {N : ℕ} :
    CATEPTAssumption weylLaw
      (∀ n ≤ N, ∃ C, ∃ _ : ℝ, 0 < C)
```

Because `CATEPTAssumption id P` is a definitional abbreviation of `P`,
it contributes no proof power; `#print axioms` reports the same kernel
axioms as the underlying proof, and the string id is carried through the
source for grep/audit tooling to find.
-/

set_option autoImplicit false

namespace CATEPTMain

/-- Explicit, labeled physical assumption.

`CATEPTAssumption id P` is definitionally `P`; the string carries no proof
power. Its role is traceability: every non-derived physical premise should
have a stable id, greppable from source, countable at build time, and
gated by CI so new unregistered ids are rejected. -/
abbrev CATEPTAssumption (_id : String) (P : Prop) : Prop := P

/-!
### Stable identifiers for project-level physical assumptions

Keep these ids stable so grep / CI / git-history stays meaningful. When an
assumption is retired (replaced by a proof), leave the id here with a
`-- RETIRED <YYYY-MM-DD> by <theorem-name>` comment instead of deleting
— removed ids make historical audit impossible.

Naming scheme: `<domain>.<concept>[.<subconcept>]`. Domains in use:
* `catept.*` — CAT/EPT core identifications (ℏ, τ_ent, complex action)
* `ns.*` — Navier–Stokes specific (BKM criterion, palinstrophy, …)
* `pde.*` — general PDE infrastructure (Weyl law, Agmon, Sobolev, …)
* `qft.*` — quantum field theory (Osterwalder–Schrader, reflection positivity, …)
* `gr.*` — general relativity (Bianchi, Hawking temperature, …)
* `qm.*` — quantum mechanics (Heisenberg, Born rule, …)
-/

namespace AssumptionId

-- ── CAT/EPT core identifications ─────────────────────────────────────────────

/-- ℏ = 2ν Constantin–Iyer identification used by Route 6 NS. -/
def hbarIsTwoNu              : String := "catept.hbar_is_2nu"

/-- τ_ent = S_I / ℏ, the entropic proper time definition. -/
def entropicTimeDefinition   : String := "catept.entropic_time_def"

/-- Complex action χ = S_R + i S_I with S_I ≥ 0. -/
def complexActionStructure   : String := "catept.complex_action_structure"

/-- Modular rate λ = κ / (2π) = k_B T / ℏ (KMS scale bridge). -/
def modularRateIdentification : String := "catept.modular_rate_identification"

/-- CATEPT quantized entropy nonnegativity: `0 ≤ Sₙ` when `kB, lnΩ, ξ, x ≥ 0`
    (Phase-1 axiom; Phase-2 plan: derive from Matsubara sum). -/
def cateptQuantizedEntropyNonneg : String := "catept.planck_bridge.quantized_entropy_nonneg"

/-- CATEPT modified 2nd Law: `ΔS/Δτₙ ≥ 0`
    (Phase-1 axiom; Phase-2 plan: derive from Lindblad positivity). -/
def cateptEntropyNonDecrease : String := "catept.planck_bridge.entropy_nondecreasing"

/-- CATEPT irreversibility lower bound: `ΔS_irr ≥ ℏ/(k_B Δτₙ)`
    (CATEPT analog of the Clausius inequality). -/
def cateptIrreversibilityBound : String := "catept.planck_bridge.irreversibility_bound"

-- ── PDE / Navier–Stokes ──────────────────────────────────────────────────────

/-- Weyl's law for the spectrum of the Laplacian on T³. -/
def weylLaw                  : String := "pde.weyl_law"

/-- Beale–Kato–Majda vorticity continuation criterion. -/
def bkmCriterion             : String := "ns.bkm_criterion"

/-- Agmon interpolation bound on bounded domains. -/
def agmonEstimate            : String := "pde.agmon_estimate"

/-- Fourier-side palinstrophy inequality used in Route 6. -/
def fourierPalinstrophy      : String := "ns.fourier_palinstrophy"

/-- Leray–Hopf existence of weak NS solutions with energy inequality. -/
def lerayHopfExistence       : String := "ns.leray_hopf_existence"

-- ── Spectral physics (T104 retrofit) ─────────────────────────────────────────

/-- Spectral gap of the Laplacian on a connected classical structure
is strictly positive: `∃ gap, 0 < gap` with the kernel-only ground-state
characterisation. Substantive consequence of (and weaker than) Weyl's
law; bridged to the catept-plugin-spectral-physics theorem
`proved_spectral_gap_pos` via `SpectralPhysicsAssumptionTags`. -/
def spectralGapPositive       : String := "pde.spectral_gap_positive"

/-- Spectral Laplacian is self-adjoint: `⟨f, Δg⟩ = ⟨Δf, g⟩`. Bridged
to `proved_laplacian_self_adjoint` via `SpectralPhysicsAssumptionTags`. -/
def laplacianSelfAdjoint      : String := "pde.laplacian_self_adjoint"

/-- Spectral Laplacian is positive semi-definite: `⟨f, Δf⟩.re ≥ 0` on
classical structures. Bridged to `proved_laplacian_pos_semidef` via
`SpectralPhysicsAssumptionTags`. -/
def laplacianPositiveSemidefinite : String :=
  "pde.laplacian_pos_semidef"

-- ── QFT / Osterwalder–Schrader ───────────────────────────────────────────────

/-- OS0 analyticity axiom in n-point Schwinger functions. -/
def osterwalderSchraderOS0   : String := "qft.os.os0_analyticity"

/-- OS2 reflection positivity. -/
def reflectionPositivity     : String := "qft.os.reflection_positivity"

/-- Bargmann–Hall–Wightman envelope-of-holomorphy extension. -/
def bargmannHallWightman     : String := "qft.os.bargmann_hall_wightman"

/-- KMS condition: `⟨A B(t)⟩_β = ⟨B(t+iℏβ) A⟩_β`
    (Phase-1 placeholder; Phase-2 plan: Tomita–Takesaki modular flow). -/
def kmsCondition             : String := "qft.kms_condition"

/-- Cameron–Martin–Girsanov: `dμ_CAT/EPT = exp(−τ_ent) dμ_Wiener`
    (Phase-1 placeholder; Phase-2: Radon–Nikodym derivative). -/
def cameronMartinGirsanov    : String := "qft.cameron_martin_girsanov"

-- ── General relativity ───────────────────────────────────────────────────────

/-- Contracted Bianchi identity ⇒ covariant stress-energy conservation. -/
def bianchiImpliesConservation : String := "gr.bianchi_implies_conservation"

/-- Hawking temperature T = ℏ κ / (2π c k_B). -/
def hawkingTemperatureFormula : String := "gr.hawking_temperature_formula"

/-- Jacobson's derivation of Einstein equations from thermodynamics. -/
def jacobsonEinsteinFromThermo : String := "gr.jacobson_einstein_from_thermo"

-- ── Quantum mechanics ────────────────────────────────────────────────────────

/-- Born rule: probability density = |amplitude|². -/
def bornRule                 : String := "qm.born_rule"

/-- Canonical commutation [x, p] = iℏ. -/
def canonicalCommutation     : String := "qm.canonical_commutation"

-- ── Vlasov–Maxwell–Landau (kinetic theory) ──────────────────────────────────

/-- Vlasov–Maxwell–Landau Theorem 42 rigidity (Aristotle/Clawristotle):
    on a flat 3-torus, the only smooth steady state is the global Maxwellian
    with `E = 0` and `B = const`. The CATEPT spine slot
    `vmlRigiditySuperiorSlot` uses the Lyapunov action
    `‖v‖²/(2T) + ‖E‖² + ‖∇B‖²` whose unique zero is exactly that steady state. -/
def vmlTheorem42Rigidity     : String := "vml.theorem42_rigidity"

-- ── Universal CATEPT-spine invariants (T66, contract-first) ──────────────────

/-- Conservation invariant: a divergence-free stress-energy-like quantity
    associated with the framework. -/
def conservationStressEnergy : String := "catept.conservation_stress_energy"

/-- Reduction invariant: classical-limit projection equals a documented
    classical target (e.g. GR + Maxwell). -/
def reductionToClassical     : String := "catept.reduction_to_classical"

/-- Symmetry invariant: clock invariance under a non-trivial symmetry
    transformation (gauge / diffeo / Lorentz / kinetic isotropy). -/
def symmetryClockInvariance  : String := "catept.symmetry_clock_invariance"

/-- Quantum-correspondence invariant: classical curvature-like quantity is
    sourced by quantum expectation value (`R = 8πG⟨O⟩` skeleton). -/
def quantumCorrespondenceBridge : String := "catept.quantum_correspondence_bridge"

-- ── Relational-information substrate cross-layer identifications (T86) ───────

/-- Substrate-to-causal-geometry: a "Minkowski-type substrate" is one
    whose `causalPrecedes` notification relation aligns with the
    Minkowski causal future cone. Phase-1 placeholder; Phase-2 plan:
    construct the witness via the GR Minkowski adapter
    (`Domains.GR.minkowskiSuperiorSlot` paired with a notification
    carrier indexed by Minkowski 4-vectors). -/
def substrateCausalIsMinkowskiFuture : String := "substrate.causal_is_minkowski_future"

/-- Substrate-to-quantum (phase): the substrate's `phase` observable
    on entities corresponds to quantum-mechanical phase (de Broglie /
    Hamilton-Jacobi phase) under any quantum bridge. Phase-1
    placeholder; Phase-2 plan: discharge through the QM density-matrix
    adapter and the modular-flow bridge. -/
def substratePhaseIsQuantumPhase : String := "substrate.phase_is_quantum_phase"

/-- Substrate-to-quantum (notifications): the substrate's `Notification`
    carrier corresponds to a quantum measurement event / channel
    application. Phase-1 placeholder; Phase-2 plan: discharge through
    the quantum-information bridge (Kraus operator picture). -/
def substrateNotificationIsQuantumChannel : String := "substrate.notification_is_quantum_channel"

/-- Noether invariant under entropic time: the dressed energy
    `J_CAT(t) = E(t)·exp(γ t/ℏ)` is a constant of motion under the
    CAT exponential-decay law `E' = -(γ/ℏ)E`, and the EPT-accumulated
    form `J_EPT(t) = E(t)·exp(T_acc(t)/ℏ)` is constant under EPT decay
    + accumulation. This is CAT/EPT's analog of Noether's theorem (the
    physics 1918 theorem, not the algebra 1933 one): it identifies a
    conserved quantity associated with the exponential-decay symmetry
    that emerges from time-translation under damping. -/
def noetherInvariantUnderEPT : String := "catept.noether_invariant_under_ept"

end AssumptionId

end CATEPTMain
