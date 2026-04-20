import CATEPTMain.AFPBridge.FEYNCALC.FCPrelude
/-!
# FBD Prelude — Fermion-Boson Duality / Omega Matrices (Phase 1)

Foundational definitions for the Fermion-Boson Duality port, derived from
the Mathematica notebook `03_theoretical_foundations/notebooks/01_omega_matrix_properties.nb`
(H. Maruyama, January 2025).

## Source summary

The notebook constructs ω matrices as linear combinations of standard 4×4
Dirac γ matrices, then verifies:
  1. Anticommutation relations for both γ and ω
  2. ω-slash invariant: (ω^μ A_μ)² = A^μ A_μ · 1

## Omega matrix definitions

The notebook's final definitions (after revision in the source):
```mathematica
ω[0] = (γ[0] + γ[3])/2
ω[1] = γ[1]               (= (γ[1]+γ[1])/2 in notebook)
ω[2] = γ[2]               (= (γ[2]+γ[2])/2 in notebook)
ω[3] = (γ[3] + γ[0])/2
```
Note: ω[0] = ω[3] in the notebook's final form — the pair forms a
null-direction projector along the 0–3 light-cone combination.

## Phase-2 upgrade path
- Replace `FCEnd` opaque with `CliffordAlgebra minkowskiQF` (4×4 concrete)
- Prove anticommutation via explicit matrix calculation
- Relate JW duality to the ω algebra via `QUANTUM.JordanWigner`
-/

set_option autoImplicit false

open CATEPTMain.AFPBridge.FEYNCALC

namespace CATEPTMain.AFPBridge.FBD

-- Re-export the FCEnd algebra so FBD files don't need to reopen FEYNCALC
-- gamma : FCIdx → FCEnd   (4×4 Dirac gamma matrices, from FCPrelude)
-- FCEnd : Type             (opaque 4×4 spinor endomorphism)
-- FCIdx = Fin 4            (Lorentz index)
-- eta   : FCIdx → FCIdx → ℝ  (Minkowski metric)

-- ── Omega matrices ───────────────────────────────────────────────────────────
/-- ω₀ = (γ₀ + γ₃)/2 — light-cone combination along the 0–3 direction.
  Source: notebook `ω[0] = (γ[0]+γ[3])/2`. -/
noncomputable def omega0 : FCEnd :=
  smulEnd ((1:ℂ)/2) (addEnd (gamma ⟨0, by norm_num⟩) (gamma ⟨3, by norm_num⟩))

/-- ω₁ = γ₁ — transverse direction, unchanged.
  Source: notebook `ω[1] = γ[1]`. -/
noncomputable def omega1 : FCEnd := gamma ⟨1, by norm_num⟩

/-- ω₂ = γ₂ — transverse direction, unchanged.
  Source: notebook `ω[2] = γ[2]`. -/
noncomputable def omega2 : FCEnd := gamma ⟨2, by norm_num⟩

/-- ω₃ = (γ₃ + γ₀)/2 — same as ω₀ in the notebook's final form.
  Source: notebook `ω[3] = (γ[3]+γ[0])/2`. -/
noncomputable def omega3 : FCEnd :=
  smulEnd ((1:ℂ)/2) (addEnd (gamma ⟨3, by norm_num⟩) (gamma ⟨0, by norm_num⟩))

/-- Index-based lookup for ω matrices (convenience). -/
noncomputable def omega : FCIdx → FCEnd
  | ⟨0, _⟩ => omega0
  | ⟨1, _⟩ => omega1
  | ⟨2, _⟩ => omega2
  | ⟨3, _⟩ => omega3
  | ⟨n+4, h⟩ => absurd h (by omega)

-- ── Omega-slash ───────────────────────────────────────────────────────────────
/-- ω-slash: ω̸(A) = ω^μ A_μ = ω₀A₀ + ω₁A₁ + ω₂A₂ + ω₃A₃.
  Source: notebook `s1 = ω[0]*A0 + ω[1]*A1 + ω[2]*A2 + ω[3]*A3`. -/
noncomputable def omegaSlash (A : FCIdx → ℝ) : FCEnd :=
  Finset.univ.sum (fun μ => smulEnd (A μ : ℂ) (omega μ))

end CATEPTMain.AFPBridge.FBD
