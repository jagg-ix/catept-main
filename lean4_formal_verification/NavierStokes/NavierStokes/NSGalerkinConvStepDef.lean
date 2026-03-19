import NavierStokes.NSGalerkinCayleyLegacyAudit

/-!
# Stage 169 — NSGalerkinConvStepDef: Definitional convStep

Makes `convStep` (Stage 164 `.openBridge` axiom) definitional by setting

  `convStepDef basis u := cayleySolveDef basis diH u`

and proving:
1. `convStepDef_energy_preserving`  — energy preserved (0 new axioms, theorem chain)
2. `convStepDef_eq_convStep`        — equals Stage 164 axiom `convStep`
3. `convStep_energy_preserving_def` — Stage 164 axiom `convStep_energy_preserving` is theorem

After this stage, the discrete-time Galerkin NS integrator (viscous step + convective step)
has **both steps fully defined**, with energy dissipation a theorem depending only on:
  - `B_bilinear_antisymm`  (.partiallyVerified, Temam II.1.1)
  - `galerkinConvection_add_right`, `galerkinConvection_smul_right` (.partiallyVerified)
  - `convStep_eq_cayleySolve` (.partiallyVerified, Lie/Strang splitting identification)

## Net counts

  - New axioms:   0
  - New theorems: 3
  - sorry:        0
  - warnings:     0
-/

namespace NavierStokes.GalerkinConvStepDef

set_option autoImplicit false

open NavierStokes.PalinstrophyTauBridge
open NavierStokes.GalerkinComplexModel
open NavierStokes.GalerkinConvection
open NavierStokes.GalerkinCayley
open NavierStokes.GalerkinODE
open NavierStokes.GalerkinCayleySolveDef
open NavierStokes.GalerkinCayleyLegacyAudit

/-! ## Definitional convective step -/

/-- `convStepDef basis u = cayleySolveDef basis diH u`

    The convective step as a `noncomputable def` using the constructive Cayley step.
    No axioms required for the definition itself. -/
noncomputable def convStepDef {N : Nat} (basis : GalerkinBasis N) (u : CoeffC N) :
    CoeffC N :=
  cayleySolveDef basis NavierStokes.DiscreteKernel.diH u

/-! ## Theorems -/

/-- **convStepDef_energy_preserving** — the definitional step preserves energy. -/
theorem convStepDef_energy_preserving {N : Nat} (basis : GalerkinBasis N) (u : CoeffC N) :
    ∑ i : Fin N, normSqC (convStepDef basis u i) =
    ∑ i : Fin N, normSqC (u i) :=
  cayleySolveDef_energy_preserving basis NavierStokes.DiscreteKernel.diH u

/-- **convStepDef_eq_convStep** — `convStepDef` equals the Stage 164 axiomatic `convStep`. -/
theorem convStepDef_eq_convStep {N : Nat} (basis : GalerkinBasis N) (u : CoeffC N) :
    convStepDef basis u = convStep basis u := by
  unfold convStepDef
  rw [cayleySolveDef_eq_cayleySolve basis NavierStokes.DiscreteKernel.diH u]
  exact (convStep_eq_cayleySolve basis u).symm

/-- **convStep_energy_preserving_def** — Stage 164 axiom `convStep_energy_preserving` is
    now a **theorem**: route `convStep = convStepDef` then energy preservation. -/
theorem convStep_energy_preserving_def {N : Nat} (basis : GalerkinBasis N) (u : CoeffC N) :
    ∑ i : Fin N, normSqC (convStep basis u i) =
    ∑ i : Fin N, normSqC (u i) := by
  rw [← convStepDef_eq_convStep]
  exact convStepDef_energy_preserving basis u

def stage169Summary : String :=
  "Stage 169: NSGalerkinConvStepDef — definitional convStep. " ++
  "convStepDef: noncomputable def = cayleySolveDef basis diH u. " ++
  "convStepDef_energy_preserving: THEOREM (cayleySolveDef_energy_preserving). " ++
  "convStepDef_eq_convStep: THEOREM (cayleySolveDef_eq_cayleySolve + convStep_eq_cayleySolve). " ++
  "convStep_energy_preserving_def: THEOREM (Stage 164 axiom now proved). " ++
  "+0 axioms, +3 theorems, 0 sorry."

end NavierStokes.GalerkinConvStepDef
