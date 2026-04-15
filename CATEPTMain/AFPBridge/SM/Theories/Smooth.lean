import CATEPTMain.AFPBridge.SM.Theories.Analysis_More
/-!
# Smooth — AFP Smooth_Manifolds → Lean 4 (Phase 1)

Source: `Smooth_Manifolds/Smooth.thy` (Immler, Zhan — 2018)
Dependencies: Analysis_More

Content: Core smooth function theory on manifolds:
  - ContMDiff characterizations
  - Composition of smooth maps
  - Smooth constant and identity maps
  - Local smoothness criterion

Phase: 1 (all proofs `sorry`; B39 applied)
-/

set_option autoImplicit false

namespace CATEPTMain.AFPBridge.SM.Theories.Smooth

open CATEPTMain.AFPBridge.SM

-- ── Identity map is smooth ────────────────────────────────────────────────────
theorem smooth_id {H M : Type*}
    [NormedAddCommGroup H] [NormedSpace ℝ H]
    [TopologicalSpace M] [ChartedSpace H M]
    (I : ModelWithCorners ℝ H M) [IsManifold I ⊤ M] :
    IsSmooth I I (id : M → M) := by
  exact contMDiff_id

-- ── Smooth composition ────────────────────────────────────────────────────────
theorem smooth_comp {H H' H'' M M' M'' : Type*}
    [NormedAddCommGroup H] [NormedSpace ℝ H]
    [NormedAddCommGroup H'] [NormedSpace ℝ H']
    [NormedAddCommGroup H''] [NormedSpace ℝ H'']
    [TopologicalSpace M] [ChartedSpace H M] (I : ModelWithCorners ℝ H M) [IsManifold I ⊤ M]
    [TopologicalSpace M'] [ChartedSpace H' M'] (I' : ModelWithCorners ℝ H' M') [IsManifold I' ⊤ M']
    [TopologicalSpace M''] [ChartedSpace H'' M''] (I'' : ModelWithCorners ℝ H'' M'') [IsManifold I'' ⊤ M'']
    (f : M' → M'') (g : M → M') (hf : IsSmooth I' I'' f) (hg : IsSmooth I I' g) :
    IsSmooth I I'' (f ∘ g) := by
  exact hf.comp hg

-- ── Constant map is smooth ────────────────────────────────────────────────────
theorem smooth_const {H H' M M' : Type*}
    [NormedAddCommGroup H] [NormedSpace ℝ H]
    [NormedAddCommGroup H'] [NormedSpace ℝ H']
    [TopologicalSpace M] [ChartedSpace H M] (I : ModelWithCorners ℝ H M) [IsManifold I ⊤ M]
    [TopologicalSpace M'] [ChartedSpace H' M'] (I' : ModelWithCorners ℝ H' M') [IsManifold I' ⊤ M']
    (c : M') : IsSmooth I I' (fun _ : M => c) := by
  exact contMDiff_const

-- ── Smooth iff smooth on open cover ──────────────────────────────────────────
theorem smooth_iff_smooth_on_open_cover {H H' M M' : Type*}
    [NormedAddCommGroup H] [NormedSpace ℝ H]
    [NormedAddCommGroup H'] [NormedSpace ℝ H']
    [TopologicalSpace M] [ChartedSpace H M] (I : ModelWithCorners ℝ H M) [IsManifold I ⊤ M]
    [TopologicalSpace M'] [ChartedSpace H' M'] (I' : ModelWithCorners ℝ H' M') [IsManifold I' ⊤ M']
    (f : M → M') :
    IsSmooth I I' f ↔ ∀ x : M, ∃ U : Set M, IsOpen U ∧ x ∈ U ∧ ContMDiffOn I I' ⊤ f U := by
  constructor
  · intro h x; exact ⟨Set.univ, isOpen_univ, Set.mem_univ x, h.contMDiffOn⟩
  · intro h
    -- IsSmooth = ContMDiff = ∀ x, ContMDiffAt (by definition)
    intro x
    obtain ⟨U, hU, hxU, hfU⟩ := h x
    exact hfU.contMDiffAt (hU.mem_nhds hxU)

end CATEPTMain.AFPBridge.SM.Theories.Smooth
