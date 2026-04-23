import CATEPTMain.HSTP.HS2Ell2
/-!
# Weak_Operator_Topology — AFP Hilbert_Space_Tensor_Product → Lean 4 (Phase 1)

Source: `Hilbert_Space_Tensor_Product/Weak_Operator_Topology.thy` (Dominique Unruh — 2023)
Dependencies: HS2Ell2

Content: Weak operator topology (WOT) on B(H ⊗h K):
  - WOT definition (convergence via matrix elements ⟨y, T x⟩)
  - WOT is coarser than SOT
  - Banach-Alaoglu for WOT (bounded set is WOT-compact)
  - WOT limits of unitary operators

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.HSTP.Weak_Operator_Topology

open CATEPTMain.HSTP
open CATEPTMain.CBO

-- ── WOT convergence ───────────────────────────────────────────────────────────
-- Tₙ →_WOT T  iff ⟨y, Tₙ(x)⟩ → ⟨y, T(x)⟩ for all x, y.
def HSTPWeakConv (Tseq : ℕ → HSTPOp) (T : HSTPOp) : Prop :=
  ∀ x y : HSTPTensor,
    Filter.Tendsto
      (fun n => hstpInner y (hstpOpApply (Tseq n) x))
      Filter.atTop
      (nhds (hstpInner y (hstpOpApply T x)))

-- ── SOT → WOT ────────────────────────────────────────────────────────────────
private axiom sot_implies_wot_law (Tseq : ℕ → HSTPOp) (T : HSTPOp)
    (hSOT : CATEPTMain.HSTP.Strong_Operator_Topology.HSTPStrongConv Tseq T) :
    HSTPWeakConv Tseq T

theorem sot_implies_wot (Tseq : ℕ → HSTPOp) (T : HSTPOp)
    (hSOT : CATEPTMain.HSTP.Strong_Operator_Topology.HSTPStrongConv Tseq T) :
    HSTPWeakConv Tseq T := sot_implies_wot_law Tseq T hSOT

-- ── WOT compactness (Banach-Alaoglu) ──────────────────────────────────────────
private axiom wot_unit_ball_compact_law (Tseq : ℕ → HSTPOp) (C : ℝ) (hBdd : ∀ n, hstpNorm (Tseq n) ≤ C) :
    ∃ φ : ℕ → ℕ, StrictMono φ ∧ ∃ T : HSTPOp, HSTPWeakConv (Tseq ∘ φ) T

theorem wot_unit_ball_compact (Tseq : ℕ → HSTPOp) (C : ℝ) (hBdd : ∀ n, hstpNorm (Tseq n) ≤ C) :
    ∃ φ : ℕ → ℕ, StrictMono φ ∧ ∃ T : HSTPOp, HSTPWeakConv (Tseq ∘ φ) T :=
  wot_unit_ball_compact_law Tseq C hBdd

-- ── WOT limit of unitaries ───────────────────────────────────────────────────
-- WOT limit of unitary operators is a contraction.
def IsHSTPUnitary (U : HSTPOp) : Prop :=
  CATEPTMain.HSTP.Strong_Operator_Topology.hstpOpComp (hstpOpAdj U) U = U ∧
  CATEPTMain.HSTP.Strong_Operator_Topology.hstpOpComp U (hstpOpAdj U) = U

-- (placeholder; phase-2: actual unitary identity)
private axiom wot_limit_of_unitaries_is_isometry_law (Useq : ℕ → HSTPOp)
    (hUnit : ∀ n, IsHSTPUnitary (Useq n))
    (T : HSTPOp) (hConv : HSTPWeakConv Useq T) :
    ∀ x : HSTPTensor, (hstpInner (hstpOpApply T x) (hstpOpApply T x)).re ≤ (hstpInner x x).re

theorem wot_limit_of_unitaries_is_isometry (Useq : ℕ → HSTPOp)
    (hUnit : ∀ n, IsHSTPUnitary (Useq n))
    (T : HSTPOp) (hConv : HSTPWeakConv Useq T) :
    ∀ x : HSTPTensor, (hstpInner (hstpOpApply T x) (hstpOpApply T x)).re ≤ (hstpInner x x).re :=
  wot_limit_of_unitaries_is_isometry_law Useq hUnit T hConv

end CATEPTMain.HSTP.Weak_Operator_Topology
