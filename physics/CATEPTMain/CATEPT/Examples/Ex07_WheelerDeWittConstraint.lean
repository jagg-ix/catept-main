import CATEPTMain.CATEPT.QuantumGravity

set_option autoImplicit false

/-!
# Example 7: Wheeler-DeWitt Constraint and the Problem of Time

## What makes this unique to CAT/EPT

The Wheeler-DeWitt equation Ĥ|Ψ⟩ = 0 says the total Hamiltonian of
the universe is zero — the universe is "frozen." This is the infamous
**problem of time** in quantum gravity: if Ĥ = 0, nothing evolves.

Standard approaches struggle with this. CAT/EPT **dissolves** the
problem rather than solving it:

  Ĥ_C + Ĥ_S = 0  ↔  Ĥ_C = -Ĥ_S

The clock subsystem (C) and physical subsystem (S) are entangled such
that the total constraint is satisfied. But locally, each subsystem
experiences evolution — parameterized by the entropic time τ_ent.

The frozen formalism is not a problem when time is relational and
emergent from entropy production. The Wheeler-DeWitt constraint
becomes a consistency condition, not a dynamical equation.

## Key results

1. Ĥ_C + Ĥ_S = 0 ↔ Ĥ_C = -Ĥ_S (constraint rewrite)
2. WDW constraint implies Ĥ = 0 (timeless)
3. Schwarzschild geometry: f(r) > 0 outside horizon
4. f(2M) = 0 (horizon condition)
5. Unruh temperature T > 0 (thermal physics from geometry)
-/

noncomputable section

namespace CATEPT.Examples

open CATEPT

-- Wheeler-DeWitt structure: H_C + H_S = 0 ↔ H_C = -H_S
example (H_C H_S : ℝ) : (H_C + H_S = 0) ↔ (H_C = -H_S) :=
  eq050_wheeler_dewitt_structure H_C H_S

-- The WDW operator is constrained to zero (timelessness)
example (op : WheelerDeWittOperator) : op.Ĥ = 0 :=
  eq050_wheeler_dewitt_timeless op

-- Schwarzschild metric is positive outside the horizon
example (M r : ℝ) (hM : 0 < M) (hr : 2 * M < r) :
    0 < schwarzschild_f M r :=
  eq046_schwarzschild_positive M r hM hr

-- The horizon is at r = 2M (f vanishes there)
example (M : ℝ) (hM : 0 < M) : schwarzschild_f M (2 * M) = 0 :=
  eq046_schwarzschild_horizon M hM

-- Unruh/Hawking temperature is positive
example (hbar kappa c kB : ℝ) (h1 : 0 < hbar) (h2 : 0 < kappa)
    (h3 : 0 < c) (h4 : 0 < kB) :
    0 < unruh_temperature hbar kappa c kB :=
  eq049_unruh_temperature_positive hbar kappa c kB h1 h2 h3 h4

end CATEPT.Examples
