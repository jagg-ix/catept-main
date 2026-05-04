import CATEPTMain.Domains.TemporalFramework
import CATEPTMain.Domains.CoherenceSpine
import CATEPTMain.Domains.JointAdapter
import CATEPTMain.Integration.UnificationSpine

/-!
# RepoSpine — canonical “single import” for the CAT/EPT unification surface

This module exists to prevent **proof islands**.

If a helper adds a new theorem that is meant to be *load-bearing evidence* for
"CAT/EPT unifies QM, thermodynamics, electromagnetism, and GR", that theorem
should become reachable from one of the repo’s explicit spine entrypoints.

`CATEPTMain.RepoSpine` is the smallest such entrypoint that:

1. Exposes the **kernel temporal contract** (`TemporalFramework`).
2. Exposes the **structural unification** via joint sums (`JointAdapter`).
3. Exposes the **four-pillar capstone** (QM/Thermo/EM/GR) via
   `Integration.UnificationSpine`.

Practical rule:

* If it is a capstone theorem, wire it here.
* If it is exploratory or lane-local, keep it out of this file and label it as
  such in its own module docstring (so it is an intentional island).
-/

set_option autoImplicit false

namespace CATEPTMain.RepoSpine

-- Kernel temporal contract + single global coherence theorem.
export CATEPTMain.Temporal (TemporalFramework LiveTemporalFramework)
export CATEPTMain.Temporal.TemporalFramework (coherence_spine)

-- Three-domain coherence spine (vacuum GR/Minkowski + live EM + live VML).
export CATEPTMain.Temporal (
  coherence_spine_GR_EM_VML
  live_dynamics_EM_VML)

-- Structural join: QM ⊕ GR ⊕ Maxwell (and the curved Maxwell extension).
export CATEPTMain.Temporal.Adapter (
  maxwellGRQM
  maxwellGRQM_satisfies_spine
  maxwellGRQM_clock_decomposition
  maxwellGRQMcurved
  maxwellGRQMcurved_satisfies_spine
  maxwellGRQMcurved_clock_decomposition)

-- Four-pillar capstone: QM / Thermo / EM / GR share a single τ_ent scalar
-- (carrier-level).
export CATEPTMain.Integration.UnificationSpine.CATEPTUnificationBundle (
  catept_unifies_QM_Thermo_EM_GR
  unification_via_modular_flow)

end CATEPTMain.RepoSpine

