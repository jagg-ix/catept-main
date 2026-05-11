import CATEPTMain.Certification.RelativityGR
import CATEPTMain.Certification.RelativityGRHodgeDual
import CATEPTMain.Certification.RelativityGRHodgeTensor
import CATEPTMain.Certification.RelativityGRCovariantDivergence
import CATEPTMain.Certification.RelativityGRStressConservation
import CATEPTMain.Certification.RelativityGRCurvedMaxwell
import CATEPTMain.Certification.RelativityGRResiduals
import CATEPTMain.Certification.RelativityGREinsteinEquation
import CATEPTMain.Certification.RelativityGRADM
import CATEPTMain.Certification.RelativityGRVMLMaxwell
import CATEPTMain.Certification.RelativityGRMaxwellPphi2
import CATEPTMain.Certification.RelativityGRCurvedDirect
import CATEPTMain.Certification.RelativityGRUnsafeFixes

/-!
# GR Certification Surface Tests

These tests record the currently implemented GR theorem surface.
They include the full direct curved-GR certificate interface.
-/

set_option autoImplicit false

namespace CATEPTMain.Certification.Tests.GRSurface

open CATEPTMain.Certification.RelativityGR

-- Flat and tensor GR certificates
#check canonical_gr_flat
#check canonical_gr_tensor

-- Full tensor Hodge API, scoped
#check hodgeStarEM
#check hodgeStarEM_involutive
#check hodgeStarEM_involutive_for_minkowski_family
#check hodgeStarEM_double_components_fixedAntisymmetric4D
#check gravitasFaraday_hodgeStarEM_involutive

-- Bivector/canonical Hodge closure
#check gravitasFaraday_hodgeStar_involutive
#check gravitasFaraday_double_hodge_bivector

-- Covariant divergence
#check covariantDivergenceStressEnergy
#check gravitasCanonicalStress_covariantDivergence_zero

-- Stress conservation currently certified for flat/constant canonical models
#check canonical_radiation_stress_conserved
#check flat_constant_stress_conserved_for_all_constant_T
#check gravitasCanonicalStress_conserved_constant_model

-- Curved Maxwell bridge surface
#check canonical_gr_curved_maxwell
#check gr_curved_maxwell_faraday_antisymm
#check gr_curved_maxwell_homogeneous_of_potential
#check gr_curved_maxwell_flat_wave_eq

-- Residual objects
#check EinsteinResidual
#check ADMResidual
#check canonical_einstein_residual
#check canonical_adm_residual

-- Typed Einstein equation
#check EinsteinEquationCertificate
#check mk_einstein_equation_certificate
#check mk_einstein_equation_certificate_holds
#check canonical_electrovac_einstein_certificate
#check canonical_electrovac_einstein_equation_holds

-- Typed ADM
#check ADMConstraintCertificate
#check mk_adm_constraint_certificate
#check mk_adm_constraint_certificate_holds
#check canonical_vacuum_adm_certificate
#check canonical_vacuum_adm_hamiltonian_constraint_holds
#check canonical_vacuum_adm_momentum_constraint_holds

-- VML Maxwell equilibrium
#check VMLMaxwellEquilibriumCertificate
#check canonical_vml_maxwell_equilibrium
#check vml_maxwell_rigidity_wrapped
#check vml_maxwell_content_available_wrapped

-- Maxwell-CurveSpace/pphi2 bridge
#check MaxwellPphi2Certificate
#check mk_maxwell_pphi2_certificate
#check mk_maxwell_pphi2_certificate_contract_holds
#check canonical_maxwell_pphi2_certificate
#check canonical_maxwell_pphi2_bridge_contract_available

-- Full direct curved-GR claim surface
#check CurvedGRDirectCertificate
#check mk_curved_gr_direct_certificate
#check curved_gr_direct_full_claim
#check mk_curved_gr_direct_certificate_claim

-- Unsafe-claim closure certificate
#check canonical_gr_unsafe_claims_closed
#check gravitasEinstein_residual_exact
#check einstein_residual_zero_for_vacuum_family
#check gravitasCanonicalVacuumADM_hamiltonian_residual_exact
#check gravitasCanonicalVacuumADM_momentum_residual_exact

end CATEPTMain.Certification.Tests.GRSurface
