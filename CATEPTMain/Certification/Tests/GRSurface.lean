import CATEPTMain.Certification.RelativityGR
import CATEPTMain.Certification.RelativityGRHodgeDual
import CATEPTMain.Certification.RelativityGRStressConservation
import CATEPTMain.Certification.RelativityGRCurvedMaxwell
import CATEPTMain.Certification.RelativityGRUnsafeFixes

/-!
# GR Certification Surface Tests

These tests record the currently implemented GR theorem surface.
They intentionally do not claim arbitrary full GR.
-/

set_option autoImplicit false

namespace CATEPTMain.Certification.Tests.GRSurface

open CATEPTMain.Certification.RelativityGR

-- Flat and tensor GR certificates
#check canonical_gr_flat
#check canonical_gr_tensor

-- Hodge-star implementation currently certified at bivector/canonical layers
#check gravitasFaraday_hodgeStar_involutive
#check gravitasFaraday_double_hodge_bivector

-- Stress conservation currently certified for flat/constant canonical models
#check canonical_radiation_stress_conserved
#check gravitasCanonicalStress_conserved_constant_model

-- Curved Maxwell bridge surface
#check canonical_gr_curved_maxwell
#check gr_curved_maxwell_faraday_antisymm
#check gr_curved_maxwell_homogeneous_of_potential
#check gr_curved_maxwell_flat_wave_eq

-- Unsafe-claim closure certificate
#check canonical_gr_unsafe_claims_closed
#check gravitasEinstein_residual_exact
#check gravitasCanonicalVacuumADM_hamiltonian_residual_exact
#check gravitasCanonicalVacuumADM_momentum_residual_exact

end CATEPTMain.Certification.Tests.GRSurface
