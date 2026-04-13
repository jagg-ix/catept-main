import NavierStokesClean.CATEPT.BianchiComplexEFEContracts
import NavierStokesClean.CATEPT.ComplexEinsteinMTPIBridge
import NavierStokesClean.CATEPT.WeylComplexDiracCompatibility
import MaxwellWave.VectorCalculus

/-!
# Lean-MWE Interop Bridge (theorem interface)

This module provides a theorem-level interoperability layer between:

- `entropic-time/lean-mwe` vector-calculus theorem surface, and
- CAT/EPT Complex-EFE + Weyl/Dirac equations already formalized here.

`lean-mwe` is now pinned to Lean `v4.26.0` and imported directly as a local
Lake dependency (`MaxwellWave` package). We keep the existing mirrored contract
surface, and additionally provide direct wrappers over native `MaxwellWave`
theorems so downstream modules can rely on real package-level reuse.

The key `lean-mwe` targets mirrored here are:

- `MaxwellWave.divergence_curl_eq_zero`
- `MaxwellWave.curl_curl_eq_grad_div_sub_laplacian`
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT

noncomputable section

open Space

/-- Native `lean-mwe` theorem reuse: divergence of curl is zero
for `MaxwellWave` vector fields. -/
theorem lean_mwe_native_divergence_curl_eq_zero
    (F : MaxwellWave.VectorField)
    (hF : MaxwellWave.IsC2Vector F)
    (x : MaxwellWave.Vec3) :
    MaxwellWave.divergence (MaxwellWave.curl F) x = 0 := by
  simpa using MaxwellWave.divergence_curl_eq_zero F hF x

/-- Native `lean-mwe` theorem reuse: curl-curl identity
for `MaxwellWave` vector fields. -/
theorem lean_mwe_native_curl_curl_eq_grad_div_sub_laplacian
    (F : MaxwellWave.VectorField)
    (hF : MaxwellWave.IsC2Vector F)
    (x : MaxwellWave.Vec3) :
    MaxwellWave.curl (MaxwellWave.curl F) x =
      (fun j =>
        MaxwellWave.partialDeriv (MaxwellWave.divergence F) j x -
          MaxwellWave.vectorLaplacian F x j) := by
  simpa using MaxwellWave.curl_curl_eq_grad_div_sub_laplacian F hF x

/-- The theorem-level interface mirroring the core vector-calculus identities
used throughout `lean-mwe/MaxwellWave`. -/
structure LeanMWEVectorCalculusInterface where
  divergence_curl_eq_zero :
    ∀ (f : Space → EuclideanSpace ℝ (Fin 3)),
      ContDiff ℝ 2 f → (∇ ⬝ (∇ × f) = 0)
  curl_curl_eq_grad_div_sub_laplacian :
    ∀ (f : Space → EuclideanSpace ℝ (Fin 3)),
      ContDiff ℝ 2 f → (∇ × (∇ × f) = ∇ (∇ ⬝ f) - Δ f)

/-- Derive the `lean-mwe` vector-calculus theorem interface directly from the
quantum/Weyl equation bridge theorem base in this repo. -/
def leanMWEInterface_of_quantum_equations : LeanMWEVectorCalculusInterface where
  divergence_curl_eq_zero := by
    intro f hf
    exact (weyl_physlean_bianchi_seed_pair f hf).1
  curl_curl_eq_grad_div_sub_laplacian := by
    intro f hf
    exact (weyl_physlean_bianchi_seed_pair f hf).2

/-- From CAT/EPT quantum equations we can recover the `lean-mwe` theorem
`divergence_curl_eq_zero` contract. -/
theorem lean_mwe_divergence_curl_from_quantum
    (f : Space → EuclideanSpace ℝ (Fin 3))
    (hf : ContDiff ℝ 2 f) :
    ∇ ⬝ (∇ × f) = 0 := by
  exact (leanMWEInterface_of_quantum_equations.divergence_curl_eq_zero f hf)

/-- From CAT/EPT quantum equations we can recover the `lean-mwe` theorem
`curl_curl_eq_grad_div_sub_laplacian` contract. -/
theorem lean_mwe_curl_curl_from_quantum
    (f : Space → EuclideanSpace ℝ (Fin 3))
    (hf : ContDiff ℝ 2 f) :
    ∇ × (∇ × f) = ∇ (∇ ⬝ f) - Δ f := by
  exact (leanMWEInterface_of_quantum_equations.curl_curl_eq_grad_div_sub_laplacian f hf)

/-- Conversely, if the `lean-mwe` theorem interface is available, the Complex-EFE
Bianchi seed theorem (`physlean_bianchi_seed`) follows immediately. -/
theorem complex_efe_physlean_seed_of_lean_mwe
    (L : LeanMWEVectorCalculusInterface)
    (f : Space → EuclideanSpace ℝ (Fin 3))
    (hf : ContDiff ℝ 2 f) :
    ∇ ⬝ (∇ × f) = 0 := by
  exact L.divergence_curl_eq_zero f hf

/-- If the `lean-mwe` interface holds, we recover the full dual-Bianchi seed
pair used by the Complex-EFE program. -/
theorem dual_bianchi_seed_pair_of_lean_mwe
    (L : LeanMWEVectorCalculusInterface)
    (f : Space → EuclideanSpace ℝ (Fin 3))
    (hf : ContDiff ℝ 2 f) :
    (∇ ⬝ (∇ × f) = 0) ∧ (∇ × (∇ × f) = ∇ (∇ ⬝ f) - Δ f) := by
  exact ⟨L.divergence_curl_eq_zero f hf, L.curl_curl_eq_grad_div_sub_laplacian f hf⟩

end

end NavierStokesClean.CATEPT
