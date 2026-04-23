import NavierStokes.VS.NSVSNuPKernel
import NavierStokes.BKM.EntropicRateBoundUniformBKM
import NavierStokes.Analysis.CIEntropicIdentification
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith

/-!
# NS Modular-Clock / Complex-Noether Bridge

Focused bridge that keeps the NS bottleneck in explicit CAT/EPT modular-clock form
without introducing new PDE closure claims.

This module:
- aliases the NS imaginary defect `D_I = νP - VS`,
- rewrites the enstrophy identity as `dΩ/dt = -2 D_I`,
- records the division-free modular-clock law
  `lambda * (dΩ/dτ_ent) = dΩ/dt = -2 D_I`,
- and makes the CAT/EPT(NS) rate specialization (`lambda = Ω/2`) explicit.

No Stage-64 closure is claimed here.
-/

namespace NavierStokes.Bridges.NSModularNoether

set_option autoImplicit false

open NavierStokes.Millennium

noncomputable section

/-! ## 1. Defect Alias and Exact Balance Rewrite -/

/-- Modular/complex-Noether defect alias:
`D_I(t) = νP(t) - VS(t)` (same object as `nsImaginaryNoetherDefect`). -/
abbrev imaginaryNoetherDefect
    (traj : Trajectory NSField) (t : Rat) : Rat :=
  nsImaginaryNoetherDefect traj t

/-- Exact enstrophy balance in defect form:
`dΩ/dt = -2 * D_I`. -/
theorem enstrophyRate_eq_neg_two_imaginaryNoetherDefect
    (traj : Trajectory NSField) (t : Rat)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj) :
    enstrophyRate traj t = -2 * imaginaryNoetherDefect traj t := by
  unfold imaginaryNoetherDefect nsImaginaryNoetherDefect
  have hEvol := enstrophy_evolution_identity traj t hNS hFS
  linarith [hEvol]

/-- Defect nonnegativity is exactly `VS ≤ νP`. -/
theorem defect_nonneg_iff_vs_le_nuP
    (traj : Trajectory NSField) (t : Rat) :
    0 ≤ imaginaryNoetherDefect traj t ↔
      vortexStretchingIntegral traj t ≤ nsNu * palinstrophy (traj.stateAt t).velocity :=
  ns_imaginary_noether_defect_nonneg_iff_vs_le_nuP traj t

/-- Defect nonnegativity is exactly enstrophy-rate nonpositivity, under NS identity. -/
theorem defect_nonneg_iff_enstrophy_rate_nonpos
    (traj : Trajectory NSField) (t : Rat)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj) :
    0 ≤ imaginaryNoetherDefect traj t ↔ enstrophyRate traj t ≤ 0 :=
  (defect_nonneg_iff_vs_le_nuP traj t).trans
    (vs_le_nuP_iff_enstrophy_rate_nonpos traj t hNS hFS)

/-! ## 2. CAT/EPT(NS) Rate Specialization and Degeneracy -/

/-- CAT/EPT(NS) rate specialization target:
`lambda_NS = Ω/2` (using CI: `hbar = 2ν` and `Ω = ||∇u||²`). -/
def catEptRateNS
    (traj : Trajectory NSField) (t : Rat)
    (_hNS : SatisfiesNSPDE nsOps nsNu traj) : Rat :=
  enstrophy (traj.stateAt t).velocity / 2

/-- Existing operational rate equals CAT/EPT(NS) specialization. -/
theorem entropicRateNS_eq_catEptRateNS
    (traj : Trajectory NSField) (t : Rat)
    (hNS : SatisfiesNSPDE nsOps nsNu traj) :
    entropicRateNS traj t = catEptRateNS traj t hNS := by
  unfold entropicRateNS catEptRateNS
  rw [enstrophyGradientIdentity traj t hNS]
  rw [constantinIyer_identification]
  have hNu : nsNu ≠ 0 := ne_of_gt nsNu_pos
  field_simp [hNu]

/-- Degeneracy equivalence in CAT/EPT(NS): `lambda_NS = 0` iff `Ω = 0`. -/
theorem catEptRateNS_zero_iff_enstrophy_zero
    (traj : Trajectory NSField) (t : Rat)
    (_hNS : SatisfiesNSPDE nsOps nsNu traj) :
    catEptRateNS traj t _hNS = 0 ↔ enstrophy (traj.stateAt t).velocity = 0 := by
  unfold catEptRateNS
  constructor
  · intro h
    nlinarith [h]
  · intro h
    nlinarith [h]

/-- Degeneracy equivalence for the operational rate via CAT/EPT(NS) specialization. -/
theorem entropicRateNS_zero_iff_enstrophy_zero
    (traj : Trajectory NSField) (t : Rat)
    (hNS : SatisfiesNSPDE nsOps nsNu traj) :
    entropicRateNS traj t = 0 ↔ enstrophy (traj.stateAt t).velocity = 0 := by
  rw [entropicRateNS_eq_catEptRateNS traj t hNS]
  exact catEptRateNS_zero_iff_enstrophy_zero traj t hNS

/-- On positive enstrophy states, the CAT/EPT clock rate is nonzero. -/
theorem entropicRateNS_ne_zero_of_enstrophy_pos
    (traj : Trajectory NSField) (t : Rat)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hE : 0 < enstrophy (traj.stateAt t).velocity) :
    entropicRateNS traj t ≠ 0 := by
  intro hZero
  have hE0 : enstrophy (traj.stateAt t).velocity = 0 :=
    (entropicRateNS_zero_iff_enstrophy_zero traj t hNS).1 hZero
  linarith [hE, hE0]

/-! ## 3. Division-Free Modular Product Law -/

/-- Witness form of the time-change identity for enstrophy:
`lambda * (dΩ/dτ_ent) = dΩ/dt`. -/
def EnstrophyEntropicRateWitness
    (traj : Trajectory NSField) (t : Rat) (dOmega_dTau : Rat) : Prop :=
  entropicRateNS traj t * dOmega_dTau = enstrophyRate traj t

/-- Division-free modular law:
if `lambda * dΩ/dτ_ent = dΩ/dt`, then `lambda * dΩ/dτ_ent = -2D_I`. -/
theorem modular_product_law_of_witness
    (traj : Trajectory NSField) (t : Rat) (dOmega_dTau : Rat)
    (hW : EnstrophyEntropicRateWitness traj t dOmega_dTau)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj) :
    entropicRateNS traj t * dOmega_dTau = -2 * imaginaryNoetherDefect traj t := by
  calc
    entropicRateNS traj t * dOmega_dTau = enstrophyRate traj t := hW
    _ = -2 * imaginaryNoetherDefect traj t :=
      enstrophyRate_eq_neg_two_imaginaryNoetherDefect traj t hNS hFS

/-- Nondegenerate division form on `{lambda > 0}` / `{lambda ≠ 0}`. -/
theorem modular_division_law_of_witness
    (traj : Trajectory NSField) (t : Rat) (dOmega_dTau : Rat)
    (hW : EnstrophyEntropicRateWitness traj t dOmega_dTau)
    (hLam : entropicRateNS traj t ≠ 0)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj) :
    dOmega_dTau = (-2 * imaginaryNoetherDefect traj t) / entropicRateNS traj t := by
  apply (eq_div_iff hLam).2
  calc
    dOmega_dTau * entropicRateNS traj t = entropicRateNS traj t * dOmega_dTau := by ring
    _ = -2 * imaginaryNoetherDefect traj t :=
      modular_product_law_of_witness traj t dOmega_dTau hW hNS hFS

/-! ## 4. Claim Registry -/

def nsModularNoetherClaims : List LabeledClaim :=
  [ ⟨"enstrophyRate_eq_neg_two_imaginaryNoetherDefect", .verified,
      "THEOREM: exact defect rewrite dOmega/dt = -2*(nu*P - VS)"⟩
  , ⟨"defect_nonneg_iff_vs_le_nuP", .verified,
      "THEOREM: defect nonnegativity is equivalent to VS<=nuP"⟩
  , ⟨"defect_nonneg_iff_enstrophy_rate_nonpos", .verified,
      "THEOREM: defect nonnegativity is equivalent to enstrophy-rate nonpositivity"⟩
  , ⟨"entropicRateNS_eq_catEptRateNS", .verified,
      "THEOREM: CAT/EPT specialization lambda_NS = Omega/2 under CI identification"⟩
  , ⟨"entropicRateNS_zero_iff_enstrophy_zero", .verified,
      "THEOREM: clock degeneracy lambda=0 iff Omega=0 in CAT/EPT(NS) specialization"⟩
  , ⟨"modular_product_law_of_witness", .partiallyVerified,
      "THEOREM: division-free modular product law lambda*(dOmega/dtau)=dOmega/dt=-2*D_I under witness contract"⟩
  , ⟨"modular_division_law_of_witness", .partiallyVerified,
      "THEOREM: nondegenerate division law on lambda!=0 derived from product law witness"⟩
  ]

end

end NavierStokes.Bridges.NSModularNoether
