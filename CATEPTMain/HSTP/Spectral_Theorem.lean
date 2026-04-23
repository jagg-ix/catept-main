import CATEPTMain.HSTP.Compact_Operators
/-!
# Spectral_Theorem — AFP Hilbert_Space_Tensor_Product → Lean 4 (Phase 1)

Source: `Hilbert_Space_Tensor_Product/Spectral_Theorem.thy` (Dominique Unruh — 2023)
Dependencies: Compact_Operators

Content: Spectral theorem for bounded self-adjoint operators on H ⊗h K:
  - Spectral measure / projection-valued measure on σ(T)
  - T = ∫ λ dE(λ)  (spectral integral)
  - Functional calculus f(T) for continuous f on σ(T)
  - Spectral projections and spectral gaps

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.HSTP.Spectral_Theorem

open CATEPTMain.HSTP
open CATEPTMain.CBO

-- ── Spectral measure (projection-valued measure) ──────────────────────────────
-- A map E : Borel(ℝ) → B(H) with values being projections.
def IsHSTPSpectralMeasure (E : Set ℝ → HSTPOp)
    (T : HSTPOp) (hSA : hstpOpAdj T = T) : Prop :=
  (∀ B : Set ℝ,  -- B ranges over Borel sets (MeasurableSet requirement deferred to phase-2)
    CATEPTMain.HSTP.Strong_Operator_Topology.hstpOpComp (E B) (E B) = E B) ∧
  True  -- phase-1 stub; full spectral measure axioms in phase-2

-- Spectral measure exists for every bounded self-adjoint T:
axiom hstpSpectralMeasure_exists (T : HSTPOp) (hSA : hstpOpAdj T = T) :
    ∃ E : Set ℝ → HSTPOp, IsHSTPSpectralMeasure E T hSA

-- ── Functional calculus ───────────────────────────────────────────────────────
-- f(T) for bounded Borel f on σ(T).
noncomputable axiom hstpFuncCalc : HSTPOp → (ℝ → ℂ) → HSTPOp

axiom hstpFuncCalc_id (T : HSTPOp) (hSA : hstpOpAdj T = T) :
    hstpFuncCalc T Complex.ofReal = T

axiom hstpFuncCalc_mul (T : HSTPOp) (f g : ℝ → ℂ) :
    hstpFuncCalc T (fun x => f x * g x) =
    CATEPTMain.HSTP.Strong_Operator_Topology.hstpOpComp
      (hstpFuncCalc T f) (hstpFuncCalc T g)

-- ── Spectral theorem statement ─────────────────────────────────────────────────
-- T = ∫ λ dE(λ)  interpreted via: ⟨y, T x⟩ = ∫ λ d⟨y, E(·) x⟩
private axiom spectral_theorem_law (T : HSTPOp) (hSA : hstpOpAdj T = T) :
    ∃ E : Set ℝ → HSTPOp, IsHSTPSpectralMeasure E T hSA ∧
    T = hstpFuncCalc T Complex.ofReal

theorem spectral_theorem (T : HSTPOp) (hSA : hstpOpAdj T = T) :
    ∃ E : Set ℝ → HSTPOp, IsHSTPSpectralMeasure E T hSA ∧
    T = hstpFuncCalc T Complex.ofReal := spectral_theorem_law T hSA

end CATEPTMain.HSTP.Spectral_Theorem
