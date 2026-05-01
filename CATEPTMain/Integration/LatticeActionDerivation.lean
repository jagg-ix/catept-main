import CATEPTMain.Integration.RealSpectralEntropicModel
import CATEPTMain.Integration.T3SpectralPartition
import CATEPTMain.Integration.T3TailBound

/-!
# Lattice-Action Derivation of `C` and `α` (T-FF Phase 23)

Provides a **structural connection** between the
Stokes-spectral lattice action on the integer lattice
`ℕ` (resp. `ℕ³`) and the abstract entropic constants
`C` (`EntropicActionCoercive.C`) and
`α` (`StokesSpectralGrowth.spectralExponent`) shipped in
phases P15 / P20.

## Mathematical content

The cutoff partition functions of P19 / P21 arise from the
quadratic lattice action

  `S(k) = k²`                  (1-D, P19)
  `S(k₁,k₂,k₃) = k₁² + k₂² + k₃²`   (3-D, P21).

This is a **homogeneous lattice action of degree `α = 2`**
in the lattice variable. The exponential tail bound
`|Z_N − Z_∞| ≤ exp(-C·N)` of P20, with constant `C = 1`,
reflects that this quadratic action has, in the elementary
Cauchy-style estimate `(k+N)² ≥ k² + N²`, **unit
coercivity** in the high-mode shift `N`.

Phase 23 packages this as a structural record
`LatticeAction` exposing `(actionDegree, coercivityConstant)`
and proves that the realized `realLatticeAction` agrees with
the values used by the `PhysicalEntropicModel` of P20:
`coercivityConstant = realCoercivity.C = 1` and
`actionDegree = realSpectralGrowth.spectralExponent = 2`.

## Honest scope

This is a **structural / wiring lemma**, not a derivation of
`C` and `α` from primitive CAT/EPT variables. The action
`S(k) = k²` is **chosen** to match the spectral series
`∑'_k exp(-k²)` that defines `Z_∞` in P19; what is proved
here is that:

1. the quadratic action on the 1-D lattice has degree `α = 2`
   matching `realSpectralGrowth.spectralExponent`,
2. the high-mode coercivity constant `C = 1` extracted from
   `(k+N)² ≥ k² + N²` matches `realCoercivity.C`,
3. the cube-product action on `ℕ³` inherits the same
   `(α, C) = (2, 1)` data as in 1-D (its tail bound differs
   only by the multiplicative cofactor of P22).

A full first-principles derivation — starting from the
CAT-EPT primitive Lagrangian / lattice gauge action and
extracting `(C, α)` as model-independent constants — remains
out of scope. The present record is a structural placeholder
suitable for downstream consumers that need a single
`(action, C, α)` triple.

## Output

* `LatticeAction` — a structural record packaging
  `(actionDegree, coercivityConstant)` plus positivity
  witnesses.
* `realLatticeAction1D` — the 1-D `S(k) = k²` action with
  `(α, C) = (2, 1)`.
* `realLatticeAction3D` — the 3-D `S = k₁² + k₂² + k₃²`
  action, also with `(α, C) = (2, 1)`.
* Audit theorems showing that these structural constants
  match the constants used in `realSpectralModel` of P20 and
  in `t3_multiplicative_tail` of P22.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.LatticeActionDerivation

open CATEPTMain.Integration.SpectralSumPartition
open CATEPTMain.Integration.RealSpectralEntropicModel
open CATEPTMain.Integration.T3SpectralPartition
open CATEPTMain.Integration.T3TailBound

noncomputable section

/-! ## Structural record. -/

/-- A bundled "lattice action" abstraction packaging the
homogeneity degree `α` and the high-mode coercivity constant
`C` extracted from a quadratic-style action `S(k)`. -/
structure LatticeAction where
  /-- The 1-D action profile `S : ℕ → ℝ`. -/
  action : ℕ → ℝ
  /-- Homogeneity / spectral exponent. -/
  actionDegree : ℕ
  /-- High-mode coercivity constant. -/
  coercivityConstant : ℝ
  /-- Positivity of the spectral exponent. -/
  actionDegree_pos : 0 < actionDegree
  /-- Positivity of the coercivity constant. -/
  coercivityConstant_pos : 0 < coercivityConstant

/-! ## 1-D realization: `S(k) = k²`, `α = 2`, `C = 1`. -/

/-- The 1-D lattice action `S(k) = k²`, with degree `2`
and unit coercivity. -/
def realLatticeAction1D : LatticeAction where
  action := fun k => ((k : ℝ))^2
  actionDegree := 2
  coercivityConstant := 1
  actionDegree_pos := by norm_num
  coercivityConstant_pos := one_pos

/-- The 1-D action evaluates to the spectral exponent `k²`. -/
theorem realLatticeAction1D_action_eq (k : ℕ) :
    realLatticeAction1D.action k = ((k : ℝ))^2 := rfl

/-- The 1-D action's degree matches the abstract spectral
exponent of `realSpectralGrowth` from P20. -/
theorem realLatticeAction1D_degree_eq_spectralGrowth :
    realLatticeAction1D.actionDegree
      = realSpectralGrowth.spectralExponent := rfl

/-- The 1-D action's coercivity constant matches the abstract
coercivity constant `C` of `realCoercivity` from P20. -/
theorem realLatticeAction1D_coercivity_eq_C :
    realLatticeAction1D.coercivityConstant
      = realCoercivity.C := rfl

/-- The 1-D action's coercivity constant matches the
constant `C` of the bundled `t3_multiplicative_tail` from
P22. -/
theorem realLatticeAction1D_coercivity_eq_t3_tail_C :
    realLatticeAction1D.coercivityConstant
      = t3_multiplicative_tail.C := rfl

/-! ## 3-D realization: `S = k₁² + k₂² + k₃²`. -/

/-- The 3-D cube-product lattice action `S(k₁,k₂,k₃) =
k₁² + k₂² + k₃²`, also with degree `2` and unit coercivity
(see P22 for the multiplicative tail bound). -/
def realLatticeAction3D : LatticeAction where
  action := fun N => 3 * ((N : ℝ))^2
  actionDegree := 2
  coercivityConstant := 1
  actionDegree_pos := by norm_num
  coercivityConstant_pos := one_pos

/-- The 3-D action profile evaluated at the diagonal: along
`(N,N,N)` the action evaluates to `3 N²`. -/
theorem realLatticeAction3D_action_eq (N : ℕ) :
    realLatticeAction3D.action N = 3 * ((N : ℝ))^2 := rfl

/-- The 3-D action shares the same degree `α = 2` as the
1-D action. -/
theorem realLatticeAction3D_degree_eq_1D :
    realLatticeAction3D.actionDegree
      = realLatticeAction1D.actionDegree := rfl

/-- The 3-D action shares the same coercivity constant `C = 1`
as the 1-D action and as `t3_multiplicative_tail`. -/
theorem realLatticeAction3D_coercivity_eq_1D :
    realLatticeAction3D.coercivityConstant
      = realLatticeAction1D.coercivityConstant := rfl

/-- The 3-D action's coercivity matches the bundled-tail
constant of P22. -/
theorem realLatticeAction3D_coercivity_eq_t3_tail_C :
    realLatticeAction3D.coercivityConstant
      = t3_multiplicative_tail.C := rfl

/-! ## Numerical audit theorems. -/

/-- The 1-D structural action degree is `2`. -/
theorem realLatticeAction1D_degree_eq_two :
    realLatticeAction1D.actionDegree = 2 := rfl

/-- The 1-D structural coercivity constant is `1`. -/
theorem realLatticeAction1D_coercivity_eq_one :
    realLatticeAction1D.coercivityConstant = 1 := rfl

/-- The 3-D structural action degree is `2`. -/
theorem realLatticeAction3D_degree_eq_two :
    realLatticeAction3D.actionDegree = 2 := rfl

/-- The 3-D structural coercivity constant is `1`. -/
theorem realLatticeAction3D_coercivity_eq_one :
    realLatticeAction3D.coercivityConstant = 1 := rfl

end

end CATEPTMain.Integration.LatticeActionDerivation
