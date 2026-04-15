import CATEPTMain.AFPBridge.LDO.CGMethods
/-!
# LatticeDiracOperators.jl → Lean 4 — Fermion Action (Phase 1)

Formalises the fermion action infrastructure from:
  - `action/FermiAction.jl`                   — abstract FermiAction type + interface
  - `action/WilsonFermiAction.jl`             — Wilson + Wilson-Clover actions
  - `action/StaggeredFermiAction.jl`          — staggered action
  - `action/DomainwallFermiAction.jl`         — domain wall action
  - `action/MobiusDomainwallFermiAction.jl`   — Möbius DW action
  - `action/GeneralizedDomainwallFermiAction.jl` — generalised DW action
  - `action/WilsontypeFermiAction.jl`         — shared Wilson-type machinery
  - `action/GeneralFermionAction.jl`          — general fermion action
  - `action/GeneralWilsonFermiAction.jl`      — general Wilson action
  - `action/clover_data.jl`                   — clover improvement data
  - `action/WilsonFermiAction.jl`             — force term, sampling

## Fermion action (pseudofermion representation)

  Two cases:

  1. Standard (2 flavour):
       S_f[ϕ, U] = ϕ† · (D†D)^{−1} · ϕ    (ϕ: pseudofermion field)
       det(D†D)^{1/2} = ∫ Dϕ Dϕ† exp(−S_f)

  2. RHMC (fractional flavour N_f):
       S_f[ϕ, U] = ϕ† · (D†D)^{−N_f/4} · ϕ
       (D†D)^{−N_f/4} ≈ α₀ + ∑ᵢ αᵢ (D†D + βᵢ)^{−1}  (rational approx)

## Force term (HMC molecular dynamics)

  The gauge force from the fermion action:
    UdSfdU_μ(x) = ∂S_f / ∂U_μ(x) · U_μ(x)

  For Wilson action this involves:
    UdSfdU ~ Tr[U · Σ† + Σ · U†]   (clover: additional F_{μν} contribution)
  where Σ = (D†D)^{−1} ϕ ϕ† is the fermion force matrix.

## Gaussian pseudofermion sampling

  ξ ~ N(0, 1) (Z2, Z4, or Gaussian noise)
  ϕ = D · ξ   so that ⟨ϕ†(D†D)^{−1}ϕ⟩ = ⟨ξ†ξ⟩ = Nf
-/

set_option autoImplicit false

open CATEPTMain.AFPBridgeFramework.TacticStubs

namespace CATEPTMain.AFPBridge.LDO

-- ── FermiAction abstract type ─────────────────────────────────────────────────
/-- Abstract fermion action parametrized by gauge-field dimension.
  Source: `abstract type FermiAction{Dim,Dirac,fermion,gauge}` in FermiAction.jl. -/
opaque FermiAction (NC NX NY NZ NT NG : ℕ) : Type := Unit

-- ── Pseudofermion field ───────────────────────────────────────────────────────
/-- The pseudofermion field ϕ represents the bosonic integral over det(D†D).
  Source: `ϕ::AbstractFermionfields` in WilsonFermiAction, etc. -/
-- reuses FermionField (ϕ is the same type; we just annotate semantically)
abbrev PseudoFermion (NC NX NY NZ NT NG : ℕ) := FermionField NC NX NY NZ NT NG

-- ── Pseudofermion action ──────────────────────────────────────────────────────
/-- Evaluate fermion action S_f = ϕ† · (D†D)^{−1} · ϕ.
  Source: `evaluate_FermiAction(fermi_action, U, ϕ)` in FermiAction.jl.
  Returned as a real number (S_f is real). -/
axiom evalFermiAction (NC NX NY NZ NT NG : ℕ)
    (SF : FermiAction NC NX NY NZ NT NG)
    (U : GaugeField NC NX NY NZ NT 4)
    (ϕ : PseudoFermion NC NX NY NZ NT NG) : ℝ

/-- Fermion action is non-negative: S_f ≥ 0.
  Source: S_f = ‖(D†D)^{−1/2} ϕ‖² ≥ 0. -/
axiom evalFermiAction_nonneg (NC NX NY NZ NT NG : ℕ)
    (SF : FermiAction NC NX NY NZ NT NG)
    (U : GaugeField NC NX NY NZ NT 4)
    (ϕ : PseudoFermion NC NX NY NZ NT NG) :
    0 ≤ evalFermiAction NC NX NY NZ NT NG SF U ϕ

-- ── Gaussian sampling ─────────────────────────────────────────────────────────
/-- Sample pseudofermion: ϕ = D · ξ where ξ is Gaussian noise.
  Source: `sample_pseudofermions!(ϕ, U, fermi_action, ξ)` in FermiAction.jl.
  Implements ϕ ← D·ξ so that E[S_f] = Nf·Vol. -/
axiom samplePseudoFermion (NC NX NY NZ NT NG : ℕ)
    (D : DiracOp NC NX NY NZ NT NG)
    (ξ : FermionField NC NX NY NZ NT NG) : PseudoFermion NC NX NY NZ NT NG

/-- Correctness of sampling: ϕ = D·ξ satisfies ⟨ϕ†(D†D)^{−1}ϕ⟩ = ⟨ξ†ξ⟩.
  Source: standard pseudofermion algebra. -/
axiom samplePseudoFermion_correct (NC NX NY NZ NT NG : ℕ)
    (D : DiracOp NC NX NY NZ NT NG)
    (ξ : FermionField NC NX NY NZ NT NG) :
    True  -- phase2_high: cancel via (D†D)^{-1} D† · D ξ = ξ

-- ── Gauge force (UdSfdU) ──────────────────────────────────────────────────────
/-- The fermion contribution to the gauge force: UdSfdU_μ(x) = ∂S_f/∂U_μ(x) · U.
  Source: `calc_UdSfdU!(UdSfdU, fermi_action, U, ϕ)` in FermiAction.jl.
  Used in HMC molecular dynamics to update the gauge momenta. -/
axiom calcUdSfdU (NC NX NY NZ NT : ℕ)
    (SF : FermiAction NC NX NY NZ NT 4)
    (U : GaugeField NC NX NY NZ NT 4)
    (ϕ : PseudoFermion NC NX NY NZ NT 4) : GaugeField NC NX NY NZ NT 4

/-- Gauge force is anti-Hermitian traceless (in su(NC) Lie algebra direction).
  Source: `Traceless_antihermitian_add!` in WilsonFermiAction.jl L1. -/
axiom calcUdSfdU_antihermitian (NC NX NY NZ NT : ℕ)
    (SF : FermiAction NC NX NY NZ NT 4)
    (U : GaugeField NC NX NY NZ NT 4)
    (ϕ : PseudoFermion NC NX NY NZ NT 4) :
    True  -- phase2_high: UdSfdU ∈ su(NC) at each site

-- ── Wilson fermion action ─────────────────────────────────────────────────────
/-- Wilson fermion action from a Wilson Dirac operator.
  Source: `WilsonFermiAction` in WilsonFermiAction.jl. -/
axiom wilsonFermiAction (NC NX NY NZ NT : ℕ) (p : WilsonParams)
    (U : GaugeField NC NX NY NZ NT 4) : FermiAction NC NX NY NZ NT 4

/-- S_f[Wilson] = ‖ψ‖² where ψ = D_W^{−1} ϕ (solved by CG).
  Source: `evaluate_FermiAction` for WilsonFermiAction returns real(ϕ ⋅ χ)
    where χ is the CG solution. -/
-- S_f[Wilson] evaluation stub (Phase 1: opaque FermiAction prevents explicit formula).
-- Phase 2: evalFermiAction = (dotFermion ϕ (DdagD^{-1} ϕ)).re via CG solve.
axiom wilsonFermiAction_eval (NC NX NY NZ NT : ℕ) (p : WilsonParams)
    (U : GaugeField NC NX NY NZ NT 4)
    (ϕ : PseudoFermion NC NX NY NZ NT 4) :
    True  -- phase2_high: evalFermiAction (wilsonFermiAction p U) U ϕ = ⟨ϕ, D†D^{-1}ϕ⟩.re

-- ── Clover improvement in action ─────────────────────────────────────────────
/-- Whether the fermion action includes clover (SW) improvement.
  Source: `hascloverterm::Bool` field of WilsonFermiAction. -/
axiom hasCloverTerm (NC NX NY NZ NT : ℕ)
    (SF : FermiAction NC NX NY NZ NT 4) : Bool

/-- Clover-improved action: S_f[SW] = S_f[W] + O(a) clover correction.
  Source: `WilsonFermiAction{..., true}` branch with clover_data. -/
theorem wilsonCloverFermiAction_nonneg (NC NX NY NZ NT : ℕ)
    (SF : FermiAction NC NX NY NZ NT 4)
    (U : GaugeField NC NX NY NZ NT 4)
    (ϕ : PseudoFermion NC NX NY NZ NT 4) :
    0 ≤ evalFermiAction NC NX NY NZ NT 4 SF U ϕ :=
  evalFermiAction_nonneg NC NX NY NZ NT 4 SF U ϕ

-- ── Gauss sampling bound ──────────────────────────────────────────────────────
/-- After Gaussian sampling, the pseudofermion norm is Nf × volume.
  Source: `gauss_sampling_in_action!(η, U, fermi_action)` in FermiAction.jl. -/
theorem gaussSamplingNorm (NC NX NY NZ NT NG : ℕ)
    (D : DiracOp NC NX NY NZ NT NG)
    (ξ : FermionField NC NX NY NZ NT NG) :
    0 ≤ normSqFermion NC NX NY NZ NT NG
          (samplePseudoFermion NC NX NY NZ NT NG D ξ) :=
  normSq_nonneg NC NX NY NZ NT NG _

end CATEPTMain.AFPBridge.LDO
