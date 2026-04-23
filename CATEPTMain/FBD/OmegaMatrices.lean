import CATEPTMain.FBD.FBDPrelude
import Mathlib.Tactic
/-!
# FBD — Omega Matrix Properties (Phase 1)

Formal statements of the algebraic properties of ω matrices verified by
the Mathematica notebook `01_omega_matrix_properties.nb`.

## Key results

| ID    | Statement                                    | Source            | Status     |
|-------|----------------------------------------------|-------------------|------------|
| OM-1  | ω₀ = ω₃  (same matrix)                     | notebook output   | proved     |
| OM-2  | {ω_μ, ω_ν} = η̃_{μν}·1  (ω anticommutation) | notebook loop     | sorry      |
| OM-3  | (ω̸(A))² = (A₀²−A₁²−A₂²−A₃²)·1             | notebook s1.s1    | sorry      |
| OM-4  | ω₀² = 0  (ω₀ is nilpotent)                 | explicit calc     | sorry      |
| OM-5  | ω₀ + ω₃ = γ₀+γ₃ / ... half-lightcone       | by def             | proved     |
| OM-6  | Tr(ω_μ ω_ν) = Tr(ω₃ ω₀) + ...               | trace formula      | sorry      |

## Notes on ω anticommutation

The standard Dirac algebra gives {γ_μ, γ_ν} = 2η_{μν}·1.
The ω matrices satisfy a *different* algebra due to their mixed definition.
In particular, {ω₀, ω₀} = 2ω₀² (not necessarily 2η₀₀·1).
The notebook verifies this numerically; phase-2 proves it algebraically.
-/

set_option autoImplicit false

-- Note: TacticStubs NOT opened here — real Mathlib proofs required.
open CATEPTMain.FEYNCALC
open CATEPTMain.FBD

namespace CATEPTMain.FBD

-- ── OM-1: ω₀ = ω₃ ───────────────────────────────────────────────────────────
/-- **OM-1**: ω₀ = ω₃.
  Both are (γ₀ + γ₃)/2 in the notebook's final form — the definition makes
  them equal by construction. -/
theorem omega0_eq_omega3 : omega0 = omega3 := by
  unfold omega0 omega3
  congr 1
  exact add_comm _ _

-- ── OM-2: ω anticommutation relations ────────────────────────────────────────
-- Notebook summary: ω-matrix anticommutators differ from the standard Clifford
-- form; the following lemmas encode the checked identities used downstream.

/-- **OM-2a**: ω₁ anticommutes as standard: {ω₁, ω₁} = -2·1. -/
theorem omega1_anticomm_self :
    omega1 * omega1 + omega1 * omega1 = smulEnd (-2 : ℂ) oneEnd := by
  simp only [omega1]
  -- γ₁² + γ₁² = 2·γ₁² = 2·η(1,1)·1 = -2·1  (from Clifford relation)
  sorry  -- phase2_high: from gamma_anticommute with μ=ν=1 → 2η₁₁·1 = -2·1

/-- **OM-2b**: ω₂ anticommutes as standard: {ω₂, ω₂} = -2·1. -/
theorem omega2_anticomm_self :
    omega2 * omega2 + omega2 * omega2 = smulEnd (-2 : ℂ) oneEnd := by
  simp only [omega2]
  sorry  -- phase2_high: from gamma_anticommute with μ=ν=2

/-- **OM-2c**: ω₀ anticommutes to zero: {ω₀, ω₀} = 0 (nilpotent). -/
theorem omega0_anticomm_self :
    omega0 * omega0 + omega0 * omega0 = zeroEnd := by
  sorry  -- phase2_high: ω₀² = (γ₀+γ₃)²/4 = (γ₀²+γ₃²+{γ₀,γ₃})/4 = (1-1+0)/4 = 0

/-- **OM-4**: ω₀ is nilpotent: ω₀² = 0.
  From {γ₀,γ₃}=2η₀₃·1=0 and γ₀²=1, γ₃²=-1:
  ω₀² = (γ₀+γ₃)²/4 = (γ₀²+{γ₀,γ₃}+γ₃²)/4 = (1+0-1)/4 = 0. -/
theorem omega0_nilpotent : omega0 * omega0 = zeroEnd := by
  simp only [omega0, smulEnd, addEnd]
  sorry  -- phase2_high: explicit Clifford algebra computation in FCEnd

/-- **OM-3**: ω-slash squared is a scalar.
  (ω̸(A))² = (A₀² - A₁² - A₂² - A₃²)·1   (Minkowski norm squared)
  Source: notebook `y = s1.s1`, `Simplify[y[[1]]][[1]]`.
  Proof: using {ω_μ, ω_ν} algebra and linearity. -/
theorem omegaSlash_sq (A : FCIdx → ℝ) :
    omegaSlash A * omegaSlash A =
    smulEnd ((A ⟨0, by norm_num⟩ ^ 2 - A ⟨1, by norm_num⟩ ^ 2
             - A ⟨2, by norm_num⟩ ^ 2 - A ⟨3, by norm_num⟩ ^ 2 : ℝ) : ℂ) oneEnd := by
  simp only [omegaSlash]
  sorry  -- phase2_high: expand sum product, use ω anticommutation, simplify

-- ── OM-5: structural relation ω₀ + ω₃ = γ₀+γ₃ ───────────────────────────────
/-- **OM-5**: ω₀ + ω₃ = (γ₀ + γ₃) (unnormalized light-cone combination). -/
theorem omega0_add_omega3 :
    addEnd omega0 omega3 = addEnd (gamma ⟨0, by norm_num⟩) (gamma ⟨3, by norm_num⟩) := by
  simp only [omega0, omega3, show ∀ (a b : FCEnd), addEnd a b = a + b from fun _ _ => rfl]
  rw [add_comm (gamma ⟨3, by omega⟩) (gamma ⟨0, by omega⟩),
      ← smulEnd_addScalar,
      show (1/2 : ℂ) + 1/2 = 1 from by norm_num,
      smulEnd_one_right]

-- ── Cross-anticommutation with γ matrices ─────────────────────────────────────
/-- ω matrices and γ matrices share the same transverse components,
  so ω₁ and ω₂ anticommute identically to γ₁ and γ₂. -/
theorem omega1_eq_gamma1 : omega1 = gamma ⟨1, by norm_num⟩ := rfl
theorem omega2_eq_gamma2 : omega2 = gamma ⟨2, by norm_num⟩ := rfl

end CATEPTMain.FBD
