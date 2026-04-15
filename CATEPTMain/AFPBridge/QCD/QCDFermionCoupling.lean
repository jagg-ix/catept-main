import CATEPTMain.AFPBridge.QCD.QCDPrelude
import CATEPTMain.AFPBridge.QCD.QCDGluonSector
import CATEPTMain.AFPBridge.LDO.WilsonFermion
import CATEPTMain.AFPBridge.LDO.FermiAction
import CATEPTMain.AFPBridge.FEYNCALC.FCPrelude
/-!
# QCD Port — Quark–Gluon Coupling (Phase 1)

Formalises the quark sector of QCD by instantiating the LDO fermion framework
at N_c = 3 (SU(3) color) and coupling it to the SU(3) gluon field.

## Physical content

The quark Lagrangian is:
  L_quark = ∑_f ψ̄_f (iγ^μ D_μ − m_f) ψ_f

where the covariant derivative is:
  D_μ ψ = (∂_μ − ig A^a_μ T^a) ψ

and ψ_f has:
  - 3 color components (fundamental of SU(3))
  - 4 spin components (Dirac spinor)
  - flavor index f ∈ {u, d, s, c, b, t}

## Connection to LDO

LDO already provides the lattice regularization of this:
  - `LDO.GaugeField NC_QCD NX NY NZ NT 4` for the SU(3) link variables
  - `LDO.FermionField NC_QCD NX NY NZ NT 4` for the quark fields
  - `LDO.wilsonDx` / `LDO.staggeredDx` for the lattice Dirac operators
  - `LDO.evalFermiAction` for S_f = ψ† (D†D)^{-1} ψ

This file:
  1. Pins NC = 3 (QCD)
  2. Defines the multi-flavor QCD quark field
  3. States the covariant derivative (axiomatic at continuum level)
  4. Proves fermion action non-negativity via LDO

## Theorem status

| Name                              | Status      | Notes                            |
|-----------------------------------|-------------|----------------------------------|
| `qcdQuarkField` (type def)        | defined     | FermionField with NC = 3         |
| `qcdLatticeAction_nonneg`         | **proved**  | via LDO.evalFermiAction_nonneg   |
| `qcdCovariantDeriv`               | axiom       | D_μ ψ (continuum)                |
| `quarkColorCharge`                | axiom       | T^a acting on 3-component spinor |
| `qcdFermionGaugeCoupling`         | axiom       | minimal coupling principle       |
-/

set_option autoImplicit false

open CATEPTMain.AFPBridgeFramework.TacticStubs

namespace CATEPTMain.AFPBridge.QCD

open CATEPTMain.AFPBridge.LDO
open CATEPTMain.AFPBridge.FEYNCALC (FCIdx eta)

-- ── QCD carrier types (NC = 3 instantiation) ──────────────────────────────────

/-- QCD quark field on a 4D lattice: 3 colors × 4 spin components per site.
  This is a `FermionField` from LDO with NC fixed to 3. -/
def qcdQuarkField (NX NY NZ NT : ℕ) : Type :=
  FermionField NC_QCD NX NY NZ NT 4

/-- QCD gauge field: SU(3) link variables on a 4D lattice. -/
def qcdGaugeField (NX NY NZ NT : ℕ) : Type :=
  GaugeField NC_QCD NX NY NZ NT 4

/-- Multi-flavor QCD quark fields: one field per quark flavor f ∈ Fin 6. -/
def qcdMultiFlavorField (NX NY NZ NT : ℕ) : Type :=
  QCDFlavor → qcdQuarkField NX NY NZ NT

-- ── Covariant derivative (continuum) ─────────────────────────────────────────

/-- Minimal coupling: the covariant derivative acting on a quark field.
  D_μ ψ = ∂_μ ψ − ig A^a_μ T^a ψ
  Phase-1: axiomatized.  Phase-2: lattice forward difference + gauge link. -/
axiom qcdCovariantDeriv (μ : FCIdx) (g : ℝ) : True
    -- phase2_high: D_μ ψ(x) = (U_μ(x) ψ(x+μ̂) − ψ(x)) / a + O(a) on lattice

/-- Color rotation of a quark: A^a_μ T^a acts on the 3-component color index.
  The generator T^a rotates the color state in SU(3). -/
axiom quarkColorCharge (a : Fin 8) (μ : FCIdx) : True
    -- phase2_high: (T^a ψ)_i = ∑_j (su3Generator a) i j * ψ_j

/-- Minimal coupling: coupling quarks to gluons via the covariant derivative.
  Source: the QCD Lagrangian L = ψ̄ (iD̸ − m) ψ = ψ̄ (iγ^μ ∂_μ − m) ψ + g ψ̄ γ^μ A_μ ψ.
  The second term is the quark-gluon vertex. -/
axiom qcdFermionGaugeCoupling : True
    -- phase2_high: expand D̸ = γ^μ D_μ using FEYNCALC.pSlash + gauge correction

-- ── Wilson quark action (lattice QCD) ─────────────────────────────────────────

/-- Quark mass in Float (for use in Wilson hopping parameter). -/
def quarkMassFloat : QCDFlavor → Float
  | ⟨0, _⟩ => 0.0022   -- up
  | ⟨1, _⟩ => 0.0047   -- down
  | ⟨2, _⟩ => 0.093    -- strange
  | ⟨3, _⟩ => 1.27     -- charm
  | ⟨4, _⟩ => 4.18     -- bottom
  | ⟨5, _⟩ => 173.0    -- top

/-- Wilson fermion parameters for a single quark flavor on QCD lattice.
  Uses the standard Wilson term r=1 and no clover improvement.
  κ = 1/(8 + 2·m_f) for the hopping parameter (tree-level relation). -/
def qcdWilsonParams (f : QCDFlavor) : WilsonParams :=
  { κ       := (1.0 : Float) / (8.0 + 2.0 * quarkMassFloat f)
    r       := 1.0
    bc      := default_bc_4D
    hasClov := false
    cSW     := 0.0 }

/-- The Wilson lattice QCD fermion action for flavor f:
  S_f[U, ψ] = ψ† (D†_W D_W)^{-1} ψ  (pseudofermion action).
  Constructed via `wilsonFermiAction` then evaluated with `evalFermiAction`. -/
noncomputable def qcdWilsonFermionAction
    (NX NY NZ NT : ℕ) (f : QCDFlavor)
    (U : qcdGaugeField NX NY NZ NT)
    (ψ : qcdQuarkField NX NY NZ NT) : ℝ :=
  evalFermiAction NC_QCD NX NY NZ NT 4
    (wilsonFermiAction NC_QCD NX NY NZ NT (qcdWilsonParams f) U) U ψ

/-- The QCD Wilson fermion action is non-negative: S_f[U, ψ] ≥ 0.
  Proof: inherited from LDO.evalFermiAction_nonneg. -/
theorem qcdLatticeAction_nonneg
    (NX NY NZ NT : ℕ) (f : QCDFlavor)
    (U : qcdGaugeField NX NY NZ NT)
    (ψ : qcdQuarkField NX NY NZ NT) :
    0 ≤ qcdWilsonFermionAction NX NY NZ NT f U ψ :=
  evalFermiAction_nonneg NC_QCD NX NY NZ NT 4 _ U ψ

/-- Total QCD fermion action summed over all 6 flavors is non-negative. -/
theorem qcdTotalFermionAction_nonneg
    (NX NY NZ NT : ℕ)
    (U : qcdGaugeField NX NY NZ NT)
    (ψ : qcdMultiFlavorField NX NY NZ NT) :
    0 ≤ Finset.univ.sum (fun f : QCDFlavor =>
          qcdWilsonFermionAction NX NY NZ NT f U (ψ f)) :=
  Finset.sum_nonneg (fun f _ => qcdLatticeAction_nonneg NX NY NZ NT f U (ψ f))

-- ── Quark–gluon vertex ────────────────────────────────────────────────────────

/-- Quark-gluon vertex factor from Feynman rules: ig γ^μ T^a.
  This is the elementary QCD coupling vertex used in perturbation theory.
  In FEYNCALC notation: vertex ~ g * (gamma μ) ⊗ (su3Generator a).
  Phase-2: define as element of End(ℂ^4) ⊗ Mat(3,3,ℂ) (spin ⊗ color tensor product). -/
axiom qcdVertex (a : Fin 8) (μ : FCIdx) : True
    -- phase2_high: igγ^μ T^a = smulEnd (Complex.I * g) (gamma μ) ⊗ su3Generator a

/-- Quark propagator S_F(p) = i(p̸ − m)^{-1} in momentum space.
  Phase-1: axiom.  Phase-2: derive from (i p̸ − m)(−i p̸ − m) = p² + m² · 1. -/
axiom qcdQuarkPropagator (p : FCIdx → ℝ) (m : ℝ) : True
    -- phase2_high: S_F(p) = i/(p̸ - m) = i(p̸ + m)/(p² - m² + iε)

-- ── DGLAP evolution (deep inelastic scattering) ───────────────────────────────

/-- Parton distribution functions q_f(x, μ²) give the probability of finding
  a quark of flavor f carrying momentum fraction x at scale μ².
  Phase-1: axiom.  Phase-2: PDFs satisfy the DGLAP evolution equations. -/
axiom partonDistribution (f : QCDFlavor) (x mu2 : ℝ) : ℝ
    -- 0 ≤ q_f(x, μ²) ≤ 1,  ∫₀¹ q_f dx = 1  (normalization)

/-- Momentum sum rule: ∑_f ∫₀¹ x [q_f(x) + q̄_f(x)] dx + ∫₀¹ x g(x) dx = 1.
  (All momentum fractions in a proton sum to 1.)
  Phase-2: follows from DGLAP evolution + QCD conservation laws. -/
axiom qcd_momentum_sum_rule : True
    -- phase2_high: requires DGLAP + conservation of QCD energy-momentum tensor

end CATEPTMain.AFPBridge.QCD
