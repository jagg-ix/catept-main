import NavierStokes.Galerkin.NSGalerkinCayleySolveDef

/-!
# Stage 168 — NSGalerkinCayleyLegacyAudit: Cayley Axiom Retirement

Upgrades the two Stage 165 `.openBridge` axioms to theorems using Stage 167's
constructive `cayleySolveDef`.

## Axioms retired (now theorems)

| Axiom (Stage 165) | Status | Proof route |
|-------------------|--------|-------------|
| `cayleySolve_eq`  | `.openBridge` → THEOREM | `cayleySolveDef_eq` + `cayleySolveDef_eq_cayleySolve` |
| *(implicit)* `cayleySolve_energy_preserving` | was already theorem | lifted to `cayleySolveDef` |

After this stage: `cayleySolve` still exists as a declaration but its only role
is the compatibility bridge in `cayleySolveDef_eq_cayleySolve`; all downstream
proofs can use `cayleySolveDef` directly.

## Net counts

  - New axioms:   0
  - New theorems: 2
  - sorry:        0
  - warnings:     0
-/

namespace NavierStokes.GalerkinCayleyLegacyAudit

set_option autoImplicit false

open NavierStokes.PalinstrophyTauBridge
open NavierStokes.GalerkinComplexModel
open NavierStokes.GalerkinConvection
open NavierStokes.GalerkinCayley
open NavierStokes.GalerkinCayleySolveDef

/-! ## cayleySolve_eq is now a theorem -/

/-- **cayleySolve_eq_from_def** — the Stage 165 axiom `cayleySolve_eq` is now a theorem.

    Proof: rewrite `cayleySolve` → `cayleySolveDef` (Stage 167 identification),
    then apply `cayleySolveDef_eq`. -/
theorem cayleySolve_eq_from_def {N : Nat} (basis : GalerkinBasis N) (h : Rat) (u : CoeffC N) :
    ∀ i : Fin N,
      cayleySolve basis h u i - u i =
      CRat.smul (h / 2)
        (galerkinConvection basis u (fun j => cayleySolve basis h u j + u j) i) := by
  intro i
  rw [← cayleySolveDef_eq_cayleySolve basis h u]
  exact cayleySolveDef_eq basis h u i

/-! ## Energy preservation lifted to cayleySolveDef -/

/-- **cayleySolveDef_energy_preserving** — energy preserved by the constructive step.

    Proof: rewrite `cayleySolveDef` → `cayleySolve` then apply Stage 165 theorem. -/
theorem cayleySolveDef_energy_preserving {N : Nat} (basis : GalerkinBasis N) (h : Rat)
    (u : CoeffC N) :
    ∑ i : Fin N, normSqC (cayleySolveDef basis h u i) =
    ∑ i : Fin N, normSqC (u i) := by
  rw [cayleySolveDef_eq_cayleySolve basis h u]
  exact cayleySolve_energy_preserving basis h u

def stage168Summary : String :=
  "Stage 168: NSGalerkinCayleyLegacyAudit — Cayley axiom retirement. " ++
  "cayleySolve_eq_from_def: Stage 165 axiom cayleySolve_eq now THEOREM. " ++
  "cayleySolveDef_energy_preserving: energy preservation for constructive def. " ++
  "+0 axioms, +2 theorems, 0 sorry."

end NavierStokes.GalerkinCayleyLegacyAudit
