import CATEPTMain.Core.Assumptions
import CATEPTPluginSpectralPhysics.IntegrationBridge

/-!
# Spectral-Physics Assumption Tags (T104)

Wraps three substantive theorems from
`catept-plugin-spectral-physics.IntegrationBridge` (sibling repo,
T90 audit-clean) under fresh registry AssumptionIds:

  * `spectralGapPositive`             ← `proved_spectral_gap_pos`
  * `laplacianSelfAdjoint`            ← `proved_laplacian_self_adjoint`
  * `laplacianPositiveSemidefinite`   ← `proved_laplacian_pos_semidef`

## Path: hybrid (Path B per task brief)

The original T104 candidate noted that the existing dead ids
`weylLaw` and `agmonEstimate` do **not** match the plugin's content
(spectral gap ≠ Weyl asymptotic; gap ≠ Agmon decay).  Forcing those
existing ids would be a stretch retrofit.

Instead this module follows **Path B**: add three new ids that match
the plugin's actual theorem content, register each immediately
through a tag theorem, and leave `weylLaw` and `agmonEstimate` alone
for a future genuine retrofit (when Mathlib spectral-asymptotic
infrastructure lands).

## Audit-gate effect

  Before T104:  registry has 3 dead PDE-side ids
                (weylLaw, agmonEstimate, fourierPalinstrophy)
  After T104:   3 new ids added, each immediately referenced;
                3 dead ids unchanged (Path B does NOT shrink dead-list,
                it adds new substantive ids alongside).

Phase-2 work can address the genuine `weylLaw` retrofit when
Mathlib's spectral-asymptotic theory is available.

## Note: stretch retrofit deferred

Earlier proposals considered Path A — wrapping the spectral-gap
theorem under `weylLaw` as a "partial witness."  That path was
rejected because it conflates two distinct mathematical statements
(positivity-of-gap is a corollary, NOT an instance, of Weyl's law).
Honest tracking requires three new ids for the three genuine plugin
theorems.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.SpectralPhysicsAssumptionTags

open CATEPTMain (CATEPTAssumption)
open CATEPTMain.AssumptionId
open CATEPTPluginSpectralPhysics
open RelationalStructure

-- ═══════════════════════════════════════════════════════════════════════
-- Spectral gap positivity (proved_spectral_gap_pos)
-- ═══════════════════════════════════════════════════════════════════════

/-- The spectral-gap-positivity claim, propagated from
`proved_spectral_gap_pos`: connected classical relational structures
admit a strictly positive spectral gap with kernel-only ground-state
characterisation.  Substantive consequence of (but weaker than)
Weyl's law. -/
def SpectralGapPositiveClaim
    (S : RelationalStructure) : Prop :=
  S.isClassical → SpectralLaplacian.isStronglyConnected S →
    ∃ gap : ℝ, 0 < gap ∧
      ∀ f : S.X → ℂ,
        (innerProduct S f (SpectralLaplacian S f)).re = 0 →
        ∃ c : ℂ, f = fun _ => c

/-- The plugin theorem `proved_spectral_gap_pos` discharges the
abstract claim. -/
theorem spectralGapPositive_holds
    (S : RelationalStructure) :
    SpectralGapPositiveClaim S :=
  fun hc hconn => proved_spectral_gap_pos S hc hconn

/-- Tag-discharge for `spectralGapPositive`. -/
theorem spectral_gap_positive_tag
    (S : RelationalStructure) :
    CATEPTAssumption spectralGapPositive (SpectralGapPositiveClaim S) :=
  spectralGapPositive_holds S

-- ═══════════════════════════════════════════════════════════════════════
-- Laplacian self-adjointness (proved_laplacian_self_adjoint)
-- ═══════════════════════════════════════════════════════════════════════

/-- The Laplacian-self-adjointness claim, propagated from
`proved_laplacian_self_adjoint`: `⟨f, Δg⟩ = ⟨Δf, g⟩` for the
spectral Laplacian on any relational structure. -/
def LaplacianSelfAdjointClaim
    (S : RelationalStructure)
    (f g : S.X → ℂ) : Prop :=
  innerProduct S f (SpectralLaplacian S g) =
    innerProduct S (SpectralLaplacian S f) g

/-- The plugin theorem `proved_laplacian_self_adjoint` discharges
the abstract claim. -/
theorem laplacianSelfAdjoint_holds
    (S : RelationalStructure)
    (f g : S.X → ℂ) :
    LaplacianSelfAdjointClaim S f g :=
  proved_laplacian_self_adjoint S f g

/-- Tag-discharge for `laplacianSelfAdjoint`. -/
theorem laplacian_self_adjoint_tag
    (S : RelationalStructure) (f g : S.X → ℂ) :
    CATEPTAssumption laplacianSelfAdjoint
      (LaplacianSelfAdjointClaim S f g) :=
  laplacianSelfAdjoint_holds S f g

-- ═══════════════════════════════════════════════════════════════════════
-- Laplacian positive semi-definiteness (proved_laplacian_pos_semidef)
-- ═══════════════════════════════════════════════════════════════════════

/-- The Laplacian-positive-semidefiniteness claim, propagated from
`proved_laplacian_pos_semidef`: `⟨f, Δf⟩.re ≥ 0` for classical
relational structures. -/
def LaplacianPositiveSemidefiniteClaim
    (S : RelationalStructure)
    (f : S.X → ℂ) : Prop :=
  S.isClassical → 0 ≤ (innerProduct S f (SpectralLaplacian S f)).re

/-- The plugin theorem `proved_laplacian_pos_semidef` discharges
the abstract claim. -/
theorem laplacianPositiveSemidefinite_holds
    (S : RelationalStructure)
    (f : S.X → ℂ) :
    LaplacianPositiveSemidefiniteClaim S f :=
  fun hc => proved_laplacian_pos_semidef S hc f

/-- Tag-discharge for `laplacianPositiveSemidefinite`. -/
theorem laplacian_positive_semidefinite_tag
    (S : RelationalStructure) (f : S.X → ℂ) :
    CATEPTAssumption laplacianPositiveSemidefinite
      (LaplacianPositiveSemidefiniteClaim S f) :=
  laplacianPositiveSemidefinite_holds S f

-- ═══════════════════════════════════════════════════════════════════════
-- Bundled discharge
-- ═══════════════════════════════════════════════════════════════════════

/-- **T104 bundle.**  All three new spectral-physics ids are
discharged from the corresponding plugin theorems on a fixed
relational-structure / function pair. -/
theorem spectral_physics_T104_retrofits_discharged
    (S : RelationalStructure) (f g : S.X → ℂ) :
    CATEPTAssumption spectralGapPositive
        (SpectralGapPositiveClaim S)
    ∧ CATEPTAssumption laplacianSelfAdjoint
        (LaplacianSelfAdjointClaim S f g)
    ∧ CATEPTAssumption laplacianPositiveSemidefinite
        (LaplacianPositiveSemidefiniteClaim S f) :=
  ⟨spectral_gap_positive_tag S,
   laplacian_self_adjoint_tag S f g,
   laplacian_positive_semidefinite_tag S f⟩

end CATEPTMain.Integration.SpectralPhysicsAssumptionTags
