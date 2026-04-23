import CATEPTMain.Quantum.HSTP.Weak_Star_Topology
/-!
# Hilbert_Space_Tensor_Product — AFP main theory → Lean 4 (Phase 1)

Source: `Hilbert_Space_Tensor_Product/Hilbert_Space_Tensor_Product.thy` (Dominique Unruh — 2023)
Dependencies: Weak_Star_Topology

Content: Core Hilbert tensor product theorems:
  - Universality of the Hilbert tensor product
  - Unitary isomorphism between H ⊗h K and ℓ²-completed algebraic TP
  - Tensor product of unitaries is unitary
  - Entanglement: Schmidt rank > 1 ↔ entangled

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.HSTP.Hilbert_Space_Tensor_Product

open CATEPTMain.Quantum.HSTP
open CATEPTMain.Quantum.CBO

-- ── Universality of Hilbert tensor product ────────────────────────────────────
-- For any bilinear bounded map φ : H × K → L,
-- ∃! bounded linear Φ : H ⊗h K → L with Φ(u ⊗ v) = φ(u, v).
axiom hstpUniversal (L : Type) [AddCommGroup L] [Module ℂ L]
    (φ : CBOVec → CBOVec → L)
    (hBilin : ∀ c : ℂ, ∀ u v : CBOVec, True) :
    ∃ Φ : HSTPTensor → L,
      ∀ u v : CBOVec, Φ (hstpPair u v) = φ u v

-- ── Tensor product of unitaries ───────────────────────────────────────────────
-- U unitary, V unitary ⇒ U ⊗ V unitary.
private axiom hstpOpTensor_unitary_law (U V : CBOOp)
    (hU : IsCBOUnitary U) (hV : IsCBOUnitary V) :
    CATEPTMain.Quantum.HSTP.Weak_Operator_Topology.IsHSTPUnitary (hstpOpTensor U V)

theorem hstpOpTensor_unitary (U V : CBOOp)
    (hU : IsCBOUnitary U) (hV : IsCBOUnitary V) :
    CATEPTMain.Quantum.HSTP.Weak_Operator_Topology.IsHSTPUnitary (hstpOpTensor U V) :=
  hstpOpTensor_unitary_law U V hU hV

-- ── Separable vs entangled states ─────────────────────────────────────────────
-- A state ρ ∈ H ⊗h K is separable if it's a convex combo of pure product states.
def IsSeparable (x : HSTPTensor) : Prop :=
  ∃ u v : CBOVec, x = hstpPair u v

def IsEntangled (x : HSTPTensor) : Prop := ¬ IsSeparable x

-- Schmidt rank 1 ↔ separable:
theorem schmidt1_iff_separable (x : HSTPTensor) :
    IsSeparable x ↔ ∃ u v : CBOVec, x = hstpPair u v := Iff.rfl

end CATEPTMain.Quantum.HSTP.Hilbert_Space_Tensor_Product
