import CATEPTMain.QCD.QCDPrelude
import CATEPTMain.QCD.QCDGluonSector
import CATEPTMain.QCD.QCDBetaFunction
import CATEPTMain.QCD.QCDFermionCoupling
/-!
# QCD Port — Root Module

Quantum Chromodynamics (QCD) port for CATEPTMain AFPBridge.

SU(3) gauge theory of the strong nuclear force.  This barrel file
aggregates all QCD submodules in dependency order.

## Module map

  QCDPrelude           — SU(3) color algebra, generators, quark masses
  QCDGluonSector       — F^a_μν field strength, Yang-Mills action, topology
  QCDBetaFunction      — β-function, asymptotic freedom (b₀ > 0 proved)
  QCDFermionCoupling   — quark fields (NC=3), covariant derivative, lattice action

## Theorems proved (Phase 1)

  • `su3_generator_count`          — 8 generators for SU(3)  (decide)
  • `su3Casimir_adjoint_eq_Nc`     — C_A = N_c = 3  (rfl)
  • `quarkMass_pos`                — all 6 quark masses > 0  (norm_num)
  • `alphaS_pos`                   — α_s > 0 for g > 0
  • `gluon_count`                  — 8 gluons (from generator count)
  • `fieldStrengthMatrix_antisymm` — F_νμ = −F_μν  (from axiom + smul_neg)
  • `fieldStrengthMatrix_diag_zero`— F_μμ = 0
  • `fieldStrength_diag_zero`      — F^a_μμ = 0  (from antisymmetry)
  • `qcdb0_pos`                    — b₀ > 0 for N_f ≤ 16  (arithmetic)
  • `qcd_asymptotic_freedom`       — β(g) < 0 at 1-loop
  • `lambdaQCD_pos`                — Λ_QCD > 0
  • `qcd_twoRegimes`               — duality UV-free / IR-confined
  • `qcdLatticeAction_nonneg`      — S_f ≥ 0  (via LDO)
  • `qcdTotalFermionAction_nonneg` — ∑_f S_f ≥ 0

## Axiom surface (pending Phase 2/3)

  QCDPrelude: su3Generator*, su3StructureConst*, su3Casimir_fundamental,
              qcd_color_neutral, qcd_quarks_confined
  QCDGluonSector: gluonField, fieldStrength*, bianchi_identity,
                  ymAction_nonneg_euclidean, ymAction_gauge_invariant,
                  topologicalCharge, theta_parameter
  QCDBetaFunction: qcdb0_twoloop, lambdaQCD_vanishes_weakCoupling
  QCDFermionCoupling: qcdCovariantDeriv, quarkColorCharge,
                      qcdFermionGaugeCoupling, qcdVertex, qcdQuarkPropagator,
                      partonDistribution, qcd_momentum_sum_rule

## Phase-3 roadmap

  HIGH: concrete Gell-Mann matrices → prove su3Casimir_fundamental by norm_num
  HIGH: F_μν from lattice finite difference → prove fieldStrength_antisymm
  MED:  DGLAP evolution equations → parton distributions
  LOW:  Yang-Mills mass gap → connects to LGT (2D Yang-Mills in lakefile)
-/
