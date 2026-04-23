import CATEPTMain.GaugeTheory.FEYNCALC.FCPrelude
/-!
# FeynCalc Port — Dirac Algebra (Phase 1)

Formal statements of the Clifford algebra relations satisfied by the Dirac
gamma matrices.  All proofs are `sorry`-discharged stubs (`-- phase2_high`).

Source: FeynCalc `DiracTrick.m` (Mertig, Orellana, Shtabovenko 1990–2024)
  Rules extracted: anti-commutation, γ^5 algebra, chiral projectors,
  contraction in D dimensions.

## Phase-2 upgrade path

Replace opaque `FCEnd` with `CliffordAlgebra minkowskiQF` where
  `minkowskiQF : QuadraticForm ℝ (Fin 4 → ℝ)`  (signature +−−−).
Then:
  `gamma μ ↦ CliffordAlgebra.ι minkowskiQF (Pi.single μ 1)`
  Anti-commutation follows from `CliffordAlgebra.ι_sq_scalar` + polarization.

Mathlib references (phase-2):
  Mathlib.LinearAlgebra.CliffordAlgebra.Basic   (ι_sq_scalar, rel)
  Mathlib.LinearAlgebra.Matrix.Trace            (Matrix.trace)
  Mathlib.Data.Complex.Basic                    (ℂ, Complex.I)

## Record

| Theorem                  | Source                     | Phase | Status         |
|--------------------------|----------------------------|-------|----------------|
| gamma_anticommute        | DiracTrick.m L439-440      | p2    | sorry-stub     |
| gamma_sq                 | derived                    | p1    | proved         |
| gamma0_sq                | derived                    | p1    | proved         |
| gammaI_sq                | derived                    | p1    | proved         |
| gamma5_sq_one            | DiracTrick.m L387-389      | p2    | sorry-stub     |
| gamma5_anticommute       | DiracTrick.m L401, L439    | p2    | sorry-stub     |
| chiralP6_idempotent      | DiracTrick.m L390-394      | p1    | proved         |
| chiralP7_idempotent      | derived                    | p1    | proved         |
| chiralP6_chiralP7_zero   | DiracTrick.m L393          | p1    | proved         |
| chiralP7_chiralP6_zero   | derived                    | p1    | proved         |
| gamma5_pass1             | derived                    | p1    | proved         |
| gamma5_pass2             | derived                    | p1    | proved         |
| gamma5_pass3             | derived                    | p1    | proved         |
| gamma_sandwich_one       | DiracTrick.m L812-830      | p2    | sorry-stub     |
| gamma_sandwich_two       | DiracTrick.m L812-830      | p2    | sorry-stub     |
-/

set_option autoImplicit false

-- Note: TacticStubs NOT opened here — real Mathlib proofs required
-- (FCEnd is now concrete; all operations are proved from Matrix algebra).

namespace CATEPTMain.GaugeTheory.FEYNCALC

-- ── Section 1: Clifford anti-commutation relations ────────────────────────────
-- Source: DiracTrick.m, diracTrickEvalFast rules, Lorentz sector
-- FeynCalc implements: g[mu] . g[nu] + g[nu] . g[mu] = 2 g^{mu nu} * Unit4
-- where Unit4 = 4×4 identity matrix (TraceOfOne = 4 normalisation).

/-- **Anti-commutation relation** for Dirac gamma matrices.
  `γ^μ γ^ν + γ^ν γ^μ = 2 g^μν · 1₄`
  (Clifford algebra relation; FeynCalc: `DiracTrick` Lorentz sector)
  Phase-2: follows from `CliffordAlgebra.ι_sq_scalar` + polarization identity. -/
theorem gamma_anticommute (μ ν : FCIdx) :
    gamma μ * gamma ν + gamma ν * gamma μ =
    smulEnd (2 * (eta μ ν : ℂ)) oneEnd := by
  -- gamma = diracGamma, smulEnd c A = c • A, oneEnd = 1 (all by def)
  -- eta and minkEta are definitionally equal (same body)
  simp only [gamma, smulEnd, oneEnd]
  have heta : eta μ ν = minkEta μ ν := rfl
  rw [heta]
  exact diracGamma_anticommute μ ν

/-- `A + A = smulEnd 2 A` (helper lemma for FCEnd). -/
private lemma fcend_add_self (A : FCEnd) : A + A = smulEnd 2 A := by
  rw [show (2 : ℂ) = 1 + 1 from by norm_num, smulEnd_addScalar, smulEnd_one_right]

/-- Diagonal: `(γ^μ)² = g^μμ · 1₄`  (corollary of anti-commutation). -/
theorem gamma_sq (μ : FCIdx) :
    gamma μ * gamma μ = smulEnd ((eta μ μ : ℂ)) oneEnd := by
  have h := gamma_anticommute μ μ
  -- h : γ^μ·γ^μ + γ^μ·γ^μ = smulEnd (2 * ↑(eta μ μ)) oneEnd
  apply smulEnd_cancel 2 (by norm_num : (2 : ℂ) ≠ 0)
  -- Goal: smulEnd 2 (gamma μ * gamma μ) = smulEnd 2 (smulEnd ↑(eta μ μ) oneEnd)
  rw [← smulEnd_comp]
  -- Goal: smulEnd 2 (gamma μ * gamma μ) = smulEnd (2 * ↑(eta μ μ)) oneEnd
  rw [← h, fcend_add_self]

/-- `(γ^0)² = +1₄`  (time component, metric signature +−−−). -/
theorem gamma0_sq : gamma 0 * gamma 0 = oneEnd := by
  have h := gamma_sq 0
  have heta : (eta (0 : FCIdx) (0 : FCIdx) : ℂ) = 1 := by simp [eta]
  rw [heta] at h
  rw [h, smulEnd_one_right]

/-- `(γ^i)² = −1₄`  for spatial indices i ∈ {1,2,3}. -/
theorem gammaI_sq (i : Fin 3) :
    let μ : FCIdx := ⟨i.val + 1, by omega⟩
    gamma μ * gamma μ = negEnd oneEnd := by
  intro μ
  have hval : μ.val ≠ 0 := by simp only [μ]; omega
  have heta : (eta μ μ : ℂ) = -1 := by
    simp only [eta, if_pos (show μ = μ from rfl), if_neg hval]
    norm_cast
  have h := gamma_sq μ
  rw [heta] at h
  rw [h, ← negEnd_eq_smulNeg]

-- ── Section 2: γ^5 algebra ────────────────────────────────────────────────────
-- Source: DiracTrick.m, "Neighboring g^5 and chiral projectors" (L385–395)
-- Key identities: (γ^5)² = 1, {γ^5, γ^μ} = 0 (NDR/4D)

/-- `(γ^5)² = 1₄`
  FeynCalc source: `diracTrickEvalFast[holdDOT[b___,DiracGamma[5],DiracGamma[5],d___]]` → `holdDOT[b,d]`
  which implements the rule `γ^5 · γ^5 = 1`. -/
theorem gamma5_sq_one : gamma5 * gamma5 = oneEnd := by
  simp only [gamma5, oneEnd]
  exact diracGamma5_sq

/-- **Anti-commutation of γ^5 with γ^μ** (NDR/4-dimensional scheme).
  `γ^5 γ^μ + γ^μ γ^5 = 0` for all μ ∈ {0,1,2,3}.
  FeynCalc source: `diracTrickEvalFast` rules L437–440:
    `DiracGamma[5], c:DiracGamma[_[__]].. → (-1)^Length[{c}] * ... * DiracGamma[5]`
  i.e. each γ^μ anti-commutes with γ^5 in 4D NDR. -/
theorem gamma5_anticommute (μ : FCIdx) :
    gamma5 * gamma μ + gamma μ * gamma5 = zeroEnd := by
  simp only [gamma5, gamma, zeroEnd]
  exact diracGamma5_anticommute μ

/-- γ^5 is hermitian: (γ^5)† = γ^5 (after conventional normalisation). -/
axiom gamma5_hermitian : True  -- placeholder; requires dagger structure in FCEnd

-- ── Section 3: Chiral projectors ─────────────────────────────────────────────
-- Source: DiracTrick.m L385–395
-- FeynCalc: DiracGamma[6] = (1 + γ^5)/2, DiracGamma[7] = (1 - γ^5)/2

/-- `(1 + g)² = 2·(1 + g)` when `g² = 1` (helper for chiral idempotency). -/
private lemma fcend_one_plus_sq (g : FCEnd) (hg : g * g = oneEnd) :
    (oneEnd + g) * (oneEnd + g) = smulEnd 2 (oneEnd + g) := by
  rw [compEnd_distrib_right, compEnd_one_left, compEnd_distrib_left,
      compEnd_one_right, hg, addEnd_comm g oneEnd, fcend_add_self]

/-- `(-g)² = 1` when `g² = 1` (helper for chiralP7). -/
private lemma fcend_neg_sq_one (g : FCEnd) (hg : g * g = oneEnd) :
    negEnd g * negEnd g = oneEnd := by
  rw [negEnd_eq_smulNeg, smulEnd_mul_right, smulEnd_mul_left, ← smulEnd_comp, hg,
      show (-1 : ℂ) * -1 = 1 from by norm_num, smulEnd_one_right]

/-- `P_R² = P_R`  (right-chiral projector is idempotent).
  FeynCalc: `holdDOT[b___,DiracGamma[6],DiracGamma[6],d___]` → `holdDOT[b,DiracGamma[6],d]` -/
theorem chiralP6_idempotent : chiralP6 * chiralP6 = chiralP6 := by
  simp only [chiralP6]
  rw [smulEnd_mul_right, smulEnd_mul_left, ← smulEnd_comp,
      fcend_one_plus_sq gamma5 gamma5_sq_one, ← smulEnd_comp]
  congr 1
  norm_num

/-- `P_L² = P_L`  (left-chiral projector is idempotent). -/
theorem chiralP7_idempotent : chiralP7 * chiralP7 = chiralP7 := by
  simp only [chiralP7]
  rw [smulEnd_mul_right, smulEnd_mul_left, ← smulEnd_comp,
      fcend_one_plus_sq (negEnd gamma5) (fcend_neg_sq_one gamma5 gamma5_sq_one),
      ← smulEnd_comp]
  congr 1
  norm_num

/-- `smulEnd c zeroEnd = zeroEnd` for any scalar c. -/
private lemma smulEnd_zero_right (c : ℂ) : smulEnd c zeroEnd = zeroEnd := by
  rw [show zeroEnd = smulEnd 0 oneEnd from (smulEnd_zero_scalar oneEnd).symm,
      ← smulEnd_comp, show c * 0 = 0 from mul_zero c, smulEnd_zero_scalar]

/-- `P_R · P_L = 0`  (orthogonal chiral projectors).
  FeynCalc: `holdDOT[b___,DiracGamma[6],DiracGamma[7],c___]` → `0` -/
theorem chiralP6_chiralP7_zero : chiralP6 * chiralP7 = zeroEnd := by
  simp only [chiralP6, chiralP7]
  have hprod : gamma5 * negEnd gamma5 = negEnd oneEnd := by
    rw [negEnd_eq_smulNeg, smulEnd_mul_right, gamma5_sq_one, ← negEnd_eq_smulNeg]
  have hzero : (oneEnd + gamma5) * (oneEnd + negEnd gamma5) = zeroEnd := by
    rw [compEnd_distrib_right, compEnd_one_left, compEnd_distrib_left,
        compEnd_one_right, hprod, ← addEnd_assoc,
        addEnd_assoc oneEnd (negEnd gamma5) gamma5, addEnd_comm (negEnd gamma5) gamma5,
        add_negEnd_self gamma5, add_zeroEnd_right, add_negEnd_self]
  rw [smulEnd_mul_right, smulEnd_mul_left, ← smulEnd_comp, hzero, smulEnd_zero_right]

/-- `P_L · P_R = 0`. -/
theorem chiralP7_chiralP6_zero : chiralP7 * chiralP6 = zeroEnd := by
  simp only [chiralP6, chiralP7]
  have hprod : negEnd gamma5 * gamma5 = negEnd oneEnd := by
    rw [negEnd_eq_smulNeg, smulEnd_mul_left, gamma5_sq_one, ← negEnd_eq_smulNeg]
  have hzero : (oneEnd + negEnd gamma5) * (oneEnd + gamma5) = zeroEnd := by
    rw [compEnd_distrib_right, compEnd_one_left, compEnd_distrib_left,
        compEnd_one_right, hprod, ← addEnd_assoc,
        addEnd_assoc oneEnd gamma5 (negEnd gamma5), add_negEnd_self gamma5,
        add_zeroEnd_right, add_negEnd_self]
  rw [smulEnd_mul_right, smulEnd_mul_left, ← smulEnd_comp, hzero, smulEnd_zero_right]

-- ── γ^5 anticommutation helpers (for odd-trace vanishing) ─────────────────────

/-- γ^5 passes through γ^μ with sign flip (left-multiplication form):
  γ^5 γ^μ = (−γ^μ) · γ^5.
  Derived from `gamma5_anticommute μ : γ^5 γ^μ + γ^μ γ^5 = 0`. -/
lemma gamma5_anticomm_left (μ : FCIdx) :
    gamma5 * gamma μ = negEnd (gamma μ) * gamma5 := by
  have h := gamma5_anticommute μ
  have key : gamma5 * gamma μ = negEnd (gamma μ * gamma5) :=
    calc gamma5 * gamma μ
        = gamma5 * gamma μ + (gamma μ * gamma5 + negEnd (gamma μ * gamma5)) := by
            rw [add_negEnd_self, add_zeroEnd_right]
      _ = (gamma5 * gamma μ + gamma μ * gamma5) + negEnd (gamma μ * gamma5) := by
            rw [← addEnd_assoc]
      _ = zeroEnd + negEnd (gamma μ * gamma5) := by rw [h]
      _ = negEnd (gamma μ * gamma5) := zeroEnd_add_left _
  rw [key, negEnd_eq_smulNeg, ← smulEnd_mul_left, ← negEnd_eq_smulNeg]

/-- Negation distributes over multiplication: (−A)(−B) = AB. -/
private lemma negEnd_mul_negEnd (A B : FCEnd) : negEnd A * negEnd B = A * B := by
  simp only [negEnd_eq_smulNeg]
  rw [smulEnd_mul_left, smulEnd_mul_right, ← smulEnd_comp,
      show (-1 : ℂ) * -1 = 1 from by norm_num, smulEnd_one_right]

/-- **γ^5 sandwich over a single gamma flips sign**:
  γ^5 γ^μ γ^5 = −γ^μ.
  Proof: use `gamma5_anticomm_left` to pass γ^5 past γ^μ, then (γ^5)²=1. -/
theorem gamma5_pass1 (μ : FCIdx) :
    gamma5 * gamma μ * gamma5 = negEnd (gamma μ) := by
  calc gamma5 * gamma μ * gamma5
      = (gamma5 * gamma μ) * gamma5 := rfl
    _ = (negEnd (gamma μ) * gamma5) * gamma5 := by rw [gamma5_anticomm_left]
    _ = negEnd (gamma μ) * (gamma5 * gamma5) := compEnd_assoc _ _ _
    _ = negEnd (gamma μ) * oneEnd := by rw [gamma5_sq_one]
    _ = negEnd (gamma μ) := compEnd_one_right _

/-- **γ^5 sandwich over a pair of gammas is transparent** (even sign):
  γ^5 γ^μ γ^ν γ^5 = γ^μ γ^ν.
  Two anticommutations give (−1)² = 1. -/
theorem gamma5_pass2 (μ ν : FCIdx) :
    gamma5 * gamma μ * gamma ν * gamma5 = gamma μ * gamma ν := by
  have step1 : gamma5 * gamma μ * gamma ν = negEnd (gamma μ) * negEnd (gamma ν) * gamma5 :=
    calc gamma5 * gamma μ * gamma ν
        = (gamma5 * gamma μ) * gamma ν := rfl
      _ = (negEnd (gamma μ) * gamma5) * gamma ν := by rw [gamma5_anticomm_left]
      _ = negEnd (gamma μ) * (gamma5 * gamma ν) := compEnd_assoc _ _ _
      _ = negEnd (gamma μ) * (negEnd (gamma ν) * gamma5) := by rw [gamma5_anticomm_left]
      _ = negEnd (gamma μ) * negEnd (gamma ν) * gamma5 := (compEnd_assoc _ _ _).symm
  calc gamma5 * gamma μ * gamma ν * gamma5
      = (gamma5 * gamma μ * gamma ν) * gamma5 := rfl
    _ = (negEnd (gamma μ) * negEnd (gamma ν) * gamma5) * gamma5 := by rw [step1]
    _ = negEnd (gamma μ) * negEnd (gamma ν) * (gamma5 * gamma5) := compEnd_assoc _ _ _
    _ = negEnd (gamma μ) * negEnd (gamma ν) * oneEnd := by rw [gamma5_sq_one]
    _ = negEnd (gamma μ) * negEnd (gamma ν) := compEnd_one_right _
    _ = gamma μ * gamma ν := negEnd_mul_negEnd _ _

/-- **γ^5 sandwich over an odd triple flips sign**:
  γ^5 γ^μ γ^ν γ^ρ γ^5 = −(γ^μ γ^ν γ^ρ).
  Proof: each γ^5 pass anticommutes (sign flip), three passes give (−1)³ = −1;
  the two γ^5 at the ends annihilate via (γ^5)² = 1. -/
theorem gamma5_pass3 (μ ν ρ : FCIdx) :
    gamma5 * gamma μ * gamma ν * gamma ρ * gamma5 = negEnd (gamma μ * gamma ν * gamma ρ) := by
  have ha : gamma5 * gamma μ = negEnd (gamma μ) * gamma5 := gamma5_anticomm_left μ
  have hb : gamma5 * gamma ν = negEnd (gamma ν) * gamma5 := gamma5_anticomm_left ν
  have hc : gamma5 * gamma ρ = negEnd (gamma ρ) * gamma5 := gamma5_anticomm_left ρ
  -- pass gamma5 left of γ^μ, γ^ν together
  have step1 : gamma5 * gamma μ * gamma ν = negEnd (gamma μ) * negEnd (gamma ν) * gamma5 :=
    calc gamma5 * gamma μ * gamma ν
        = (gamma5 * gamma μ) * gamma ν := rfl
      _ = (negEnd (gamma μ) * gamma5) * gamma ν := by rw [ha]
      _ = negEnd (gamma μ) * (gamma5 * gamma ν) := compEnd_assoc _ _ _
      _ = negEnd (gamma μ) * (negEnd (gamma ν) * gamma5) := by rw [hb]
      _ = negEnd (gamma μ) * negEnd (gamma ν) * gamma5 := (compEnd_assoc _ _ _).symm
  -- pass gamma5 left of γ^μ, γ^ν, γ^ρ together
  have step2 : gamma5 * gamma μ * gamma ν * gamma ρ =
      negEnd (gamma μ) * negEnd (gamma ν) * negEnd (gamma ρ) * gamma5 :=
    calc gamma5 * gamma μ * gamma ν * gamma ρ
        = (gamma5 * gamma μ * gamma ν) * gamma ρ := rfl
      _ = (negEnd (gamma μ) * negEnd (gamma ν) * gamma5) * gamma ρ := by rw [step1]
      _ = negEnd (gamma μ) * negEnd (gamma ν) * (gamma5 * gamma ρ) := compEnd_assoc _ _ _
      _ = negEnd (gamma μ) * negEnd (gamma ν) * (negEnd (gamma ρ) * gamma5) := by rw [hc]
      _ = negEnd (gamma μ) * negEnd (gamma ν) * negEnd (gamma ρ) * gamma5 :=
              (compEnd_assoc _ _ _).symm
  -- close the outer gamma5 with gamma5² = 1, then reduce triple negation
  calc gamma5 * gamma μ * gamma ν * gamma ρ * gamma5
      = (gamma5 * gamma μ * gamma ν * gamma ρ) * gamma5 := rfl
    _ = (negEnd (gamma μ) * negEnd (gamma ν) * negEnd (gamma ρ) * gamma5) * gamma5 := by
            rw [step2]
    _ = negEnd (gamma μ) * negEnd (gamma ν) * negEnd (gamma ρ) * (gamma5 * gamma5) :=
            compEnd_assoc _ _ _
    _ = negEnd (gamma μ) * negEnd (gamma ν) * negEnd (gamma ρ) * oneEnd := by
            rw [gamma5_sq_one]
    _ = negEnd (gamma μ) * negEnd (gamma ν) * negEnd (gamma ρ) := compEnd_one_right _
    _ = (gamma μ * gamma ν) * negEnd (gamma ρ) := by rw [negEnd_mul_negEnd]
    _ = negEnd (gamma μ * gamma ν * gamma ρ) := by
            rw [negEnd_eq_smulNeg (gamma ρ), smulEnd_mul_right, ← negEnd_eq_smulNeg]

/-- `P_R + P_L = 1₄`  (completeness of chiral projectors).
  Proof uses the new FCEnd module axioms: smulEnd_add, smulEnd_addScalar, smulEnd_one_right.
  Key steps: (1+γ⁵)/2 + (1-γ⁵)/2 = (1/2)•((1+γ⁵)+(1-γ⁵)) = (1/2)•(1+1) = 1. -/
theorem chiralP6_add_chiralP7_one : chiralP6 + chiralP7 = oneEnd := by
  simp only [chiralP6, chiralP7]
  -- Combine the two smul terms: c•A + c•B = c•(A+B)
  rw [← smulEnd_add]
  -- Simplify the inner sum: (1+γ⁵) + (1+(-γ⁵))
  have hinner : (oneEnd + gamma5) + (oneEnd + negEnd gamma5) = oneEnd + oneEnd := by
    -- step 1: reassociate
    have step1 : (oneEnd + gamma5) + (oneEnd + negEnd gamma5)
                = oneEnd + (gamma5 + (oneEnd + negEnd gamma5)) :=
      addEnd_assoc oneEnd gamma5 (oneEnd + negEnd gamma5)
    -- step 2: pull gamma5 past oneEnd
    have step2 : gamma5 + (oneEnd + negEnd gamma5) = oneEnd + (gamma5 + negEnd gamma5) := by
      rw [← addEnd_assoc gamma5 oneEnd, addEnd_comm gamma5 oneEnd, addEnd_assoc]
    -- step 3: γ⁵ + (-γ⁵) = 0
    have step3 : gamma5 + negEnd gamma5 = zeroEnd := add_negEnd_self gamma5
    rw [step1, step2, step3, add_zeroEnd_right]
  rw [hinner]
  -- Now: smulEnd (1/2) (oneEnd + oneEnd) = oneEnd
  rw [smulEnd_add, ← smulEnd_addScalar]
  have hnum : ((1 : ℂ)/2 + 1/2) = 1 := by norm_num
  rw [hnum, smulEnd_one_right]

-- ── Section 4: Contraction in D dimensions ───────────────────────────────────
-- Source: DiracTrick.m, explicit-index contraction rules (L812–830)
-- FeynCalc: g^mu_mu = D (Lorentz index contracted with metric)

/-- Gamma matrix contraction: `∑_μ γ^μ γ_μ = D · 1₄` (in D = 4 spacetime dims).
  In 4D: γ^μ γ_μ = g^{μν} γ_μ γ_ν (sum over μ,ν with metric).
  FeynCalc result: `Contract[DiracGamma[LorentzIndex[mu]] DiracGamma[LorentzIndex[mu]]]` → `D`.
  The result is D as a scalar times the identity. -/
axiom gamma_contraction_val :
    -- Σ_{μ,ν} eta(μ,ν) • (gamma μ * gamma ν)  =  (4 : ℂ) • oneEnd
    -- in 4 dimensions: g^μν γ_μ γ_ν = 4 · 1₄
    (Finset.univ (α := FCIdx)).sum (fun μ =>
      (Finset.univ (α := FCIdx)).sum (fun ν =>
        smulEnd ((eta μ ν : ℂ)) (gamma μ * gamma ν)))
    = smulEnd 4 oneEnd

-- Helper: off-diagonal eta values vanish (used in sandwich proofs).
private lemma eta_offdiag (α β : FCIdx) (h : α ≠ β) : (eta α β : ℂ) = 0 := by
  have : eta α β = 0 := by unfold eta; exact if_neg h
  exact_mod_cast this

-- Helper: η^{αα}² = 1 (Minkowski metric diagonal entries are ±1).
private lemma eta_sq_one (α : FCIdx) : (eta α α : ℂ) ^ 2 = 1 := by
  fin_cases α <;> simp only [eta] <;> norm_num

-- Shared diagonal-reduction utility: collapses double sum Σ_{α,β} η^{αβ} f(α,β)
-- to single sum Σ_α η^{αα} f(α,α) using eta_offdiag.
private lemma diag_reduce (f : FCIdx → FCIdx → FCEnd) :
    (Finset.univ (α := FCIdx)).sum (fun α =>
      (Finset.univ (α := FCIdx)).sum (fun β => smulEnd ((eta α β : ℂ)) (f α β)))
    = (Finset.univ (α := FCIdx)).sum (fun α => smulEnd ((eta α α : ℂ)) (f α α)) :=
  Finset.sum_congr rfl fun α _ =>
    Finset.sum_eq_single α
      (fun β _ hne => by rw [eta_offdiag α β (Ne.symm hne)]; simp only [smulEnd, zero_smul])
      (fun h => absurd (Finset.mem_univ α) h)

set_option maxHeartbeats 400000 in
/-- Sandwiched contraction: `γ^α γ^μ γ_α = -2 γ^μ` (4D, West/FeynCalc convention).
  Algebraic proof: α=μ gives (η^{μμ})²·γ^μ = γ^μ; α≠μ gives -(η^{αα})²·γ^μ = -γ^μ;
  sum = 1 + 3·(-1) = -2.  No matrix computation. -/
theorem gamma_sandwich_one (μ : FCIdx) :
    (Finset.univ (α := FCIdx)).sum (fun α =>
      (Finset.univ (α := FCIdx)).sum (fun β =>
        smulEnd ((eta α β : ℂ)) (gamma α * gamma μ * gamma β)))
    = smulEnd (-2 : ℂ) (gamma μ) := by
  rw [diag_reduce]
  -- Each diagonal term evaluates algebraically to ±γ^μ.
  have each_term : ∀ α : FCIdx,
      smulEnd ((eta α α : ℂ)) (gamma α * gamma μ * gamma α) =
      smulEnd (if α = μ then (1 : ℂ) else -1) (gamma μ) := by
    intro α
    by_cases h : α = μ
    · -- α = μ: η^{μμ}·(γ^μ·γ^μ)·γ^μ = η^{μμ}·(η^{μμ}·1)·γ^μ = (η^{μμ})²·γ^μ = γ^μ.
      rw [if_pos h, h, gamma_sq, smulEnd_mul_left, compEnd_one_left, ← smulEnd_comp, ← sq,
          eta_sq_one, smulEnd_one_right]
    · -- α ≠ μ: η^{αμ}=0, so {γ^α,γ^μ}=0, i.e. γ^α·γ^μ = -γ^μ·γ^α.
      -- Then η^{αα}·γ^α·γ^μ·γ^α = -η^{αα}·γ^μ·(γ^α)²·1 = -(η^{αα})²·γ^μ = -γ^μ.
      simp only [if_neg h]
      have hoff : (eta α μ : ℂ) = 0 :=
        eta_offdiag α μ h
      have hac := gamma_anticommute α μ
      rw [hoff, mul_zero] at hac
      simp only [smulEnd_zero_scalar] at hac
      -- hac : gamma α * gamma μ + gamma μ * gamma α = zeroEnd = 0
      have hzero : gamma α * gamma μ + gamma μ * gamma α = 0 := hac
      have hamu : gamma α * gamma μ = -(gamma μ * gamma α) :=
        eq_neg_of_add_eq_zero_left hzero
      rw [hamu, neg_mul, mul_assoc, gamma_sq, smulEnd_mul_right, compEnd_one_right]
      -- Goal: smulEnd (eta α α : ℂ) (-(smulEnd (eta α α : ℂ) (gamma μ))) = smulEnd (-1 : ℂ) (gamma μ)
      have hsq := eta_sq_one α
      simp only [smulEnd, smul_neg, ← mul_smul, ← sq, hsq, one_smul, neg_one_smul]
  -- Sum the scalar coefficients: (if α=μ then 1 else -1) over all α ∈ Fin 4 = -2.
  simp_rw [each_term, smulEnd]
  suffices h : (Finset.univ (α := FCIdx)).sum (fun α => if α = μ then (1 : ℂ) else -1) = -2 by
    rw [← Finset.sum_smul, h]
  -- Algebraic: rewrite body via sum_congr, split, then use sum_ite_eq + card.
  have hsum : (Finset.univ (α := FCIdx)).sum (fun α => if α = μ then (1 : ℂ) else -1) =
      (Finset.univ (α := FCIdx)).sum (fun α => (if α = μ then (2 : ℂ) else 0) + (-1)) :=
    Finset.sum_congr rfl (fun α _ => by split_ifs <;> ring)
  have hsplit : (Finset.univ (α := FCIdx)).sum (fun α => (if α = μ then (2 : ℂ) else 0) + (-1)) =
      (Finset.univ (α := FCIdx)).sum (fun α => if α = μ then (2 : ℂ) else 0) +
      (Finset.univ (α := FCIdx)).sum (fun _ : FCIdx => (-1 : ℂ)) := Finset.sum_add_distrib
  rw [hsum, hsplit]
  simp only [Finset.sum_ite_eq, Finset.mem_univ, if_true, Finset.sum_const,
             Finset.card_univ, Fintype.card_fin]
  norm_num

-- Helper: Σ_α η^{αα}·η^{αν}·(γ^α·γ^μ) = γ^ν·γ^μ
-- Only the α=ν term survives because η is diagonal.
private lemma sum_eta_gamma (μ ν : FCIdx) :
    (Finset.univ (α := FCIdx)).sum (fun α =>
      smulEnd ((eta α α : ℂ) * (eta α ν : ℂ)) (gamma α * gamma μ))
    = gamma ν * gamma μ := by
  rw [Finset.sum_eq_single ν
        (fun α _ hne => by
          rw [eta_offdiag α ν hne, mul_zero, smulEnd_zero_scalar]; rfl)
        (fun h => absurd (Finset.mem_univ ν) h)]
  rw [← sq, eta_sq_one, smulEnd_one_right]

-- Helper: Σ_α η^{αα}·(γ^α·γ^μ·γ^α) = smulEnd (-2) (γ^μ).
-- Extracted from gamma_sandwich_one after diagonal reduction.
private lemma sum_diag_sandwich (μ : FCIdx) :
    (Finset.univ (α := FCIdx)).sum (fun α =>
      smulEnd ((eta α α : ℂ)) (gamma α * gamma μ * gamma α))
    = smulEnd (-2 : ℂ) (gamma μ) := by
  have h := gamma_sandwich_one μ
  rwa [diag_reduce] at h

set_option maxHeartbeats 800000 in
/-- Sandwiched contraction (2 gammas): `γ^α γ^μ γ^ν γ_α = 4 g^μν · 1₄` (4D).
  Algebraic proof using anticommutator split and gamma_sandwich_one.  No matrix comp. -/
theorem gamma_sandwich_two (μ ν : FCIdx) :
    (Finset.univ (α := FCIdx)).sum (fun α =>
      (Finset.univ (α := FCIdx)).sum (fun β =>
        smulEnd ((eta α β : ℂ)) (gamma α * gamma μ * gamma ν * gamma β)))
    = smulEnd (4 * (eta μ ν : ℂ)) oneEnd := by
  rw [diag_reduce]
  -- Per-α split: η^{αα}·γ^α·γ^μ·γ^ν·γ^α
  --   = 2·η^{αα}·η^{αν}·(γ^α·γ^μ) - η^{αα}·(γ^α·γ^μ·γ^α)·γ^ν
  -- via γ^ν·γ^α = smulEnd(2η^{αν})·1 - γ^α·γ^ν  (from anticommutator).
  have each_split : ∀ α : FCIdx,
      smulEnd ((eta α α : ℂ)) (gamma α * gamma μ * gamma ν * gamma α) =
      smulEnd (2 * (eta α α : ℂ) * (eta α ν : ℂ)) (gamma α * gamma μ) -
      smulEnd ((eta α α : ℂ)) (gamma α * gamma μ * gamma α) * gamma ν := by
    intro α
    have hac := gamma_anticommute α ν
    -- γ^ν·γ^α = smulEnd(2·η^{αν})·1 - γ^α·γ^ν
    have hna : gamma ν * gamma α =
        smulEnd (2 * (eta α ν : ℂ)) oneEnd - gamma α * gamma ν :=
      eq_sub_of_add_eq (show gamma ν * gamma α + gamma α * gamma ν =
          smulEnd (2 * (eta α ν : ℂ)) oneEnd from by rw [add_comm]; exact hac)
    -- Group and substitute
    calc smulEnd ((eta α α : ℂ)) (gamma α * gamma μ * gamma ν * gamma α)
        = smulEnd ((eta α α : ℂ)) (gamma α * gamma μ * (gamma ν * gamma α)) := by
            rw [mul_assoc (gamma α * gamma μ)]
      _ = smulEnd ((eta α α : ℂ)) (gamma α * gamma μ *
              (smulEnd (2 * (eta α ν : ℂ)) oneEnd - gamma α * gamma ν)) := by
            rw [hna]
      _ = smulEnd ((eta α α : ℂ)) (gamma α * gamma μ * smulEnd (2 * (eta α ν : ℂ)) oneEnd) -
          smulEnd ((eta α α : ℂ)) (gamma α * gamma μ * (gamma α * gamma ν)) := by
            rw [mul_sub]; simp only [smulEnd, smul_sub]
      _ = smulEnd ((eta α α : ℂ)) (smulEnd (2 * (eta α ν : ℂ)) (gamma α * gamma μ)) -
          smulEnd ((eta α α : ℂ)) ((gamma α * gamma μ * gamma α) * gamma ν) := by
            congr 1
            · rw [smulEnd_mul_right, compEnd_one_right]
            · rw [← mul_assoc]
      _ = smulEnd ((eta α α : ℂ) * (2 * (eta α ν : ℂ))) (gamma α * gamma μ) -
          smulEnd ((eta α α : ℂ)) ((gamma α * gamma μ * gamma α) * gamma ν) := by
            rw [← smulEnd_comp]
      _ = smulEnd ((eta α α : ℂ) * (2 * (eta α ν : ℂ))) (gamma α * gamma μ) -
          smulEnd ((eta α α : ℂ)) (gamma α * gamma μ * gamma α) * gamma ν := by
            conv_lhs => arg 2; rw [← smulEnd_mul_left]
      _ = smulEnd (2 * (eta α α : ℂ) * (eta α ν : ℂ)) (gamma α * gamma μ) -
          smulEnd ((eta α α : ℂ)) (gamma α * gamma μ * gamma α) * gamma ν := by
            congr 2; ring
  -- Aggregate over α using the split.
  simp_rw [each_split]
  rw [Finset.sum_sub_distrib]
  -- First sum: Σ_α smulEnd(2·η^{αα}·η^{αν})(γ^α·γ^μ) = smulEnd 2 (γ^ν·γ^μ).
  have sum1 : (Finset.univ (α := FCIdx)).sum (fun α =>
      smulEnd (2 * (eta α α : ℂ) * (eta α ν : ℂ)) (gamma α * gamma μ)) =
      smulEnd 2 (gamma ν * gamma μ) := by
    -- Factor out the scalar 2 without letting smulEnd_comp fire on the inner (eta·eta) product.
    have key : ∀ α : FCIdx, smulEnd (2 * (eta α α : ℂ) * (eta α ν : ℂ)) (gamma α * gamma μ) =
        smulEnd 2 (smulEnd ((eta α α : ℂ) * (eta α ν : ℂ)) (gamma α * gamma μ)) := fun α => by
      rw [show 2 * (eta α α : ℂ) * (eta α ν : ℂ) = 2 * ((eta α α : ℂ) * (eta α ν : ℂ)) from by ring]
      exact smulEnd_comp 2 _ _
    simp_rw [key]
    rw [show (Finset.univ (α := FCIdx)).sum (fun α =>
              smulEnd 2 (smulEnd ((eta α α : ℂ) * (eta α ν : ℂ)) (gamma α * gamma μ)))
            = smulEnd 2 ((Finset.univ (α := FCIdx)).sum (fun α =>
                smulEnd ((eta α α : ℂ) * (eta α ν : ℂ)) (gamma α * gamma μ))) from by
          simp only [smulEnd, ← Finset.smul_sum]]
    rw [sum_eta_gamma]
  -- Second sum: Σ_α smulEnd(η^{αα})(γ^α·γ^μ·γ^α)·γ^ν = smulEnd(-2)(γ^μ)·γ^ν.
  have sum2 : (Finset.univ (α := FCIdx)).sum (fun α =>
      smulEnd ((eta α α : ℂ)) (gamma α * gamma μ * gamma α) * gamma ν) =
      smulEnd (-2 : ℂ) (gamma μ) * gamma ν := by
    rw [← Finset.sum_mul, sum_diag_sandwich]
  -- Combine: 2(γ^νγ^μ) - (-2γ^μ)γ^ν = 2γ^νγ^μ + 2γ^μγ^ν = 2·{γ^μ,γ^ν} = 4η^{μν}·1.
  rw [sum1, sum2, smulEnd_mul_left]
  -- smulEnd 2 (γ^νγ^μ) - smulEnd(-2)(γ^μγ^ν) = smulEnd 2 (γ^μγ^ν + γ^νγ^μ) = smulEnd(4η^{μν})·1
  have combo : smulEnd 2 (gamma ν * gamma μ) - smulEnd (-2 : ℂ) (gamma μ * gamma ν) =
               smulEnd 2 (gamma μ * gamma ν + gamma ν * gamma μ) := by
    rw [smulEnd_add]
    simp only [smulEnd]
    rw [show (-2 : ℂ) = -(2 : ℂ) from by norm_num, neg_smul, sub_neg_eq_add, add_comm]
  rw [combo, gamma_anticommute, ← smulEnd_comp]
  congr 1; ring

end CATEPTMain.GaugeTheory.FEYNCALC
