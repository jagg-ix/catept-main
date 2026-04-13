import Mathlib
import Physlib
import Bochner
import Minlos
import HilleYosida
import Cslib
import Pphi2
import CATEPTMain.External.Registry
import CATEPTMain.Integration.MaxwellCurveSpacePphi2Bridge

/-!
CATEPTMain root module for clean Lean 4.29 migration work.
-/

def integratedRepoCount : Nat := CATEPTMain.External.repos.length
