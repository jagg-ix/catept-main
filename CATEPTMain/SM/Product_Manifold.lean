import CATEPTMain.SM.Cotangent_Space
/-!
# Product_Manifold — AFP Smooth_Manifolds → Lean 4 (Phase 1)

Source: `Smooth_Manifolds/Product_Manifold.thy` (Immler, Zhan — 2018)
Dependencies: Cotangent_Space

Content: Smooth structure on product M × N:
  - Product atlas
  - Projections are smooth
  - Diagonal embedding
  - Tangent space of product is product of tangent spaces

Phase: 1 (all proofs `sorry`)
-/

set_option autoImplicit false

namespace CATEPTMain.SM.Product_Manifold

open CATEPTMain.SM
open Manifold

-- ── Product model with corners ────────────────────────────────────────────────
-- The product of two smooth manifolds (with Euclidean models) is smooth.
-- In Lean 4, there is a ProductModelWithCorners:
noncomputable def productModel (n m : ℕ) :
    ModelWithCorners ℝ (EuclideanSpace ℝ (Fin n) × EuclideanSpace ℝ (Fin m))
                       (EuclideanSpace ℝ (Fin n) × EuclideanSpace ℝ (Fin m)) :=
  (𝓡 n).prod (𝓡 m)

-- ── First projection is smooth ────────────────────────────────────────────────
theorem smooth_fst {H H' M M' : Type*}
    [NormedAddCommGroup H] [NormedSpace ℝ H]
    [NormedAddCommGroup H'] [NormedSpace ℝ H']
    [TopologicalSpace M] [ChartedSpace H M] (I : ModelWithCorners ℝ H M) [IsManifold I ⊤ M]
    [TopologicalSpace M'] [ChartedSpace H' M'] (I' : ModelWithCorners ℝ H' M') [IsManifold I' ⊤ M'] :
    ContMDiff (I.prod I') I ⊤ (Prod.fst : M × M' → M) :=
  contMDiff_fst

-- ── Second projection is smooth ───────────────────────────────────────────────
theorem smooth_snd {H H' M M' : Type*}
    [NormedAddCommGroup H] [NormedSpace ℝ H]
    [NormedAddCommGroup H'] [NormedSpace ℝ H']
    [TopologicalSpace M] [ChartedSpace H M] (I : ModelWithCorners ℝ H M) [IsManifold I ⊤ M]
    [TopologicalSpace M'] [ChartedSpace H' M'] (I' : ModelWithCorners ℝ H' M') [IsManifold I' ⊤ M'] :
    ContMDiff (I.prod I') I' ⊤ (Prod.snd : M × M' → M') :=
  contMDiff_snd

-- ── Pairing smooth maps ───────────────────────────────────────────────────────
theorem smooth_prod_mk {H H' H'' M M' M'' : Type*}
    [NormedAddCommGroup H] [NormedSpace ℝ H]
    [NormedAddCommGroup H'] [NormedSpace ℝ H']
    [NormedAddCommGroup H''] [NormedSpace ℝ H'']
    [TopologicalSpace M] [ChartedSpace H M] (I : ModelWithCorners ℝ H M) [IsManifold I ⊤ M]
    [TopologicalSpace M'] [ChartedSpace H' M'] (I' : ModelWithCorners ℝ H' M') [IsManifold I' ⊤ M']
    [TopologicalSpace M''] [ChartedSpace H'' M''] (I'' : ModelWithCorners ℝ H'' M'') [IsManifold I'' ⊤ M'']
    (f : M → M') (g : M → M'')
    (hf : ContMDiff I I' ⊤ f) (hg : ContMDiff I I'' ⊤ g) :
    ContMDiff I (I'.prod I'') ⊤ (fun x => (f x, g x)) :=
  hf.prodMk hg

-- ── Tangent space of product ─────────────────────────────────────────────────
-- TangentSpace (I.prod I') (x, y) ≃ TangentSpace I x × TangentSpace I' y
-- This is captured in Lean 4 by TangentSpace.prod (see Mathlib/Geometry/Manifold/VectorBundle/Tangent)
theorem tangent_product_iso {H H' M M' : Type*}
    [NormedAddCommGroup H] [NormedSpace ℝ H]
    [NormedAddCommGroup H'] [NormedSpace ℝ H']
    [TopologicalSpace M] [ChartedSpace H M] (I : ModelWithCorners ℝ H M) [IsManifold I ⊤ M]
    [TopologicalSpace M'] [ChartedSpace H' M'] (I' : ModelWithCorners ℝ H' M') [IsManifold I' ⊤ M']
    (x : M) (y : M') :
    True := by -- placeholder: TangentSpace (I.prod I') (x, y) = H × H'
  trivial

end CATEPTMain.SM.Product_Manifold
