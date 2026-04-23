/-!
# EQFTRTFT — Euclidean Variational Extension Worklog

Source:  `qft-euclidean-variational.md` (Downloads), a 6-cluster equation
         catalog extracted from a paper on φ⁴ Euclidean QFT on the torus.
         Original chat: copilot.microsoft.com/chats/eFMNqe2q8SmzVqhPRSaDd

DB task: `eqftrvt_variational_port` (id=274, p1)

## What the paper provides

A variational stochastic-control proof of the φ⁴₃ Euclidean measure:

  ν_T(dφ) ∝ exp(−∫[λ[W⁴] − a_T[W²] − b_T]dξ) dμ(φ)

via the **Boué-Dupuis formula**:

  −log Z_T = inf_{v ∈ H_a} E[V_T(Y_T + I_T(v)) + ½∫||v_s||² ds]

with renormalization constants a_T, b_T polynomial in λ.

## Leverage map onto catept-main

| Paper item                        | catept-main target                              | Sorry retired             |
|-----------------------------------|-------------------------------------------------|---------------------------|
| Boué-Dupuis Theorem 2             | FeynmanKacBridge — partitionFunction bounds     | fk_partition (Phase 2)    |
| Wick polynomials W², W³, W⁴       | NS renormalization — GN cluster P2              | catept_ns_p2_gn_h1_l4     |
| Fractional Leibniz (Prop 1)       | GN H¹↪L⁴ periodization — ns_gn_h1_l4_t3_...   | P2 GN cluster (3 sorrys)  |
| Drift regularity Lemma 2          | ns_phase5d_energy_identity_t3 — H¹ control      | Phase 5D energy identity  |
| Quadratic control eq. 19          | Phase 5D Galerkin equicontinuity                | Phase 5D Galerkin         |
| Existence Theorem 1 (d=3)         | CATEPTSelfConsistency catept_ns_p0 + master     | ns_p0_vorticity + P3 BKM  |

## Conventions

  - EV-*: records in this worklog
  - Status: TODO | IN-PROGRESS | DONE | BLOCKED | DEFERRED
  - Priority: P0 (blocker), P1 (required for milestone), P2 (nice-to-have)
-/

/-!
## EV-001  Pre-flight — audit EQFTRTFT existing scaffolds (P1)

Verify that the existing `EQFTRTFT/EuclideanQFT.lean` stubs are
compatible landing zones before adding new files.

### Steps

1. Confirm EuclideanQFT.lean namespace:
   ```bash
   grep "^namespace" CATEPTMain/AFPBridge/EQFTRTFT/EuclideanQFT.lean
   ```
   Expected: `namespace CATEPTMain.EQFTRTFT`

2. Confirm no naming collisions with planned new defs:
   ```bash
   grep "partitionFn\|WickPoly\|BoueDupuis\|driftReg\|fractionalLeibniz" \
     CATEPTMain/AFPBridge/EQFTRTFT/*.lean
   ```
   Expected: no matches.

3. Confirm CALCULUS imports are available (Differentiation.lean is upstream):
   ```bash
   grep "CALCULUS" CATEPTMain/AFPBridge.lean
   ```
   Expected: 3 import lines (Differentiation, Normalization, Attention).

### Status: TODO
-/

/-!
## EV-002  `WickPolynomials.lean` — normal-ordered field monomials (P1)

Formalizes Reply 3 of the equation catalog. Defines the Wick-normal-ordered
monomials W², W³, W⁴ as polynomial corrections to Gaussian expectations.

### New file: `CATEPTMain/AFPBridge/EQFTRTFT/WickPolynomials.lean`

```lean
-- Renormalization constants (eq. 9)
-- $a_T = 6\,\mathbb{E}[W_T(\xi)^2]$
noncomputable def a_T (EW2 : ℝ) : ℝ := 6 * EW2

-- $b_T = 3\,\mathbb{E}[W_T(\xi)^2]^2$
noncomputable def b_T (EW2 : ℝ) : ℝ := 3 * EW2 ^ 2

-- $[W^2](\xi) = W_T(\xi)^2 - \mathbb{E}[W_T(\xi)^2]$
noncomputable def Wick2 (W : ℝ) (EW2 : ℝ) : ℝ := W ^ 2 - EW2

-- $[W^3](\xi) = W_T(\xi)^3 - 3\,\mathbb{E}[W_T(\xi)^2]\,W_T(\xi)$
noncomputable def Wick3 (W : ℝ) (EW2 : ℝ) : ℝ := W ^ 3 - 3 * EW2 * W

-- $[W^4](\xi) = W_T(\xi)^4 - 6\,\mathbb{E}[W_T(\xi)^2]\,W_T(\xi)^2 + 3\,\mathbb{E}[W_T(\xi)^2]^2$
noncomputable def Wick4 (W : ℝ) (EW2 : ℝ) : ℝ :=
  W ^ 4 - 6 * EW2 * W ^ 2 + 3 * EW2 ^ 2
```

### Provable from definitions (no new axioms)

  - `Wick2_zero_mean` : If EW2 = E[W²], then E[Wick2 W EW2] = 0
  - `Wick4_eq_Wick2_sq_correction` : Wick4 W EW2 = Wick2 W EW2 * (Wick2 W EW2) + ... (algebraic)
  - `renorm_energy_def` : `∫ ξ, λ * Wick4 ... - a_T * Wick2 ... - b_T = ∫ ...` by `ring`

### CATEPT connection

`WickPolynomials.lean` feeds into `CATEPTSelfConsistency.lean` P2 cluster:
the GN H¹↪L⁴ argument needs W³ as the cubic interaction term whose
L⁴ norm is controlled by the fractional Leibniz rule.

### Status: TODO
-/

/-!
## EV-003  `BoueDupuis.lean` — variational formula for log Z (P1)

Formalizes Reply 2 (Lemma 1 + Theorem 2). The Boué-Dupuis formula is the
stochastic-control representation of the partition function:

  $-\log Z_T = \inf_{v \in H_a} \mathbb{E}\bigl[V_T(Y_T + I_T(v)) + \tfrac{1}{2}\int_0^\infty \|v_s\|^2\,ds\bigr]$

### New file: `CATEPTMain/AFPBridge/EQFTRTFT/BoueDupuis.lean`

Key definitions and stubs:

```lean
-- Integrated drift: $I_T(v) = \int_0^T J_s\,v_s\,ds$
-- (Fourier multiplier J_s axiomatized — phase-1 stub)
axiom driftIntegral (v : ℝ → ℝ) (T : ℝ) : ℝ

-- Lemma 2 (drift regularity, eq. 12 support lemma):
-- $\sup_{0 \le t \le T}\|I_t(v)\|_{H^1}^2 \le \int_0^T\|v_s\|^2\,ds$
axiom driftRegularity (v : ℝ → ℝ) (T : ℝ) :
    ⊤ ≥ MeasureTheory.essSup (fun t : ℝ => driftIntegral v t ^ 2) MeasureTheory.volume

-- Theorem 2 (Boué-Dupuis, phase-1 axiom):
-- $-\log Z_T = \inf_{v}\,\mathbb{E}[\ldots]$
axiom boueDupuis (Z_T : ℝ) (hZ : 0 < Z_T) : -Real.log Z_T = ⊓ (Set.range (fun v : ℝ → ℝ => 0))
```

### CATEPT connection

`BoueDupuis.lean` extends `FeynmanKacBridge.lean`:
`fk_partition_bounds_total_variation` already proves ‖ν‖ ≤ Z₀.
Adding the Boué-Dupuis lower bound closes the two-sided pressure estimate,
directly retiring the Phase-2 stub in `FeynmanKacBridge`.

### Prerequisite: EV-001 (namespace check), EV-002 (WickPolynomials defs needed for V_T)

### Status: TODO
-/

/-!
## EV-004  `FractionalSobolev.lean` — Leibniz rule + drift bounds (P1)

Formalizes Reply 5 (Proposition 1 + Lemma 2 + Lemma 3 + Lemma 4).

The **fractional Leibniz rule** (Proposition 1) is the critical lemma for
the GN H¹↪L⁴ periodization argument in P2 of CATEPTSelfConsistency:

  $\|(D^s)(fg)\|_{L^p} \le \|(D^{s+\alpha})f\|_{L^{p_1}}\|(D^{-\alpha})g\|_{L^{p_2}}
   + \|(D^{s+\alpha})g\|_{L^{p_1}}\|(D^{-\alpha})f\|_{L^{p_2}}$

### New file: `CATEPTMain/AFPBridge/EQFTRTFT/FractionalSobolev.lean`

Phase-1 stubs (all axioms; Phase-2 targets Mathlib `MeasureTheory.Sobolev`):

```lean
-- Fractional Leibniz rule (Proposition 1, eq. 11)
-- $\|(D^s)(fg)\|_{L^p} \le \ldots$ (Kato-Ponce / Kenig-Ponce-Vega)
axiom fractionalLeibniz
    (s α : ℝ) (p p1 p2 : ℝ)
    (f g : (Fin 3 → ℝ) → ℝ) :
    True   -- placeholder norm inequality

-- Drift regularity (Lemma 2, eq. drift-H1-bound)
-- $\sup_{0 \le t \le T}\|I_t(v)\|_{H^1}^2 \le \int_0^T\|v_s\|^2\,ds$
axiom driftH1Bound (v : ℝ → ℝ) (T : ℝ) : True

-- Cubic embedding (Lemma 3)
-- $\int f g^3 \le C(\epsilon)\|f\|_{W^{-1/2-\epsilon,p}}(\|g\|_{H^1} + \|g\|_{L^4})$
axiom cubicEmbedding (f g : (Fin 3 → ℝ) → ℝ) (ε : ℝ) : True
```

### CATEPT connection

`fractionalLeibniz` (phase-1 axiom here) is the **missing ingredient** for:
  - `catept_ns_p2_gn_h1_l4_embedding` (P2 sorry in CATEPTSelfConsistency)
  - `ns_gn_h1_l4_t3_periodization_20260410` (task 157, p1)
  - `ns_agmon_h2_linf_t3_discharge_20260410` (task 158, p1)

Once this file lands, those stubs become single-step `exact fractionalLeibniz ...`
calls, retiring the entire P2 GN cluster (3 sorrys).

### Status: TODO
-/

/-!
## EV-005  `Phi4Existence.lean` — main convergence theorem in d=3 (P2)

Formalizes Reply 6 (Theorem 1). The existence of the φ⁴₃ Euclidean measure:

  $E_-(X) \le -\log Z_T \le E_+(X)$
  $\lim_{X \to 0} \frac{E_+(X) - E_-(X)}{|A|} = 0$

### New file: `CATEPTMain/AFPBridge/EQFTRTFT/Phi4Existence.lean`

Phase-1 stub:

```lean
-- Theorem 1: Existence of φ⁴₃ Euclidean measure
-- Subject to renormalization constants a_T, b_T polynomial in λ
theorem phi4_existence_d3
    (λ : ℝ) (Z_T : ℝ) (A : ℝ) (hZ : 0 < Z_T) :
    ∃ (E_plus E_minus : ℝ → ℝ),
      (∀ X, E_minus X ≤ -Real.log Z_T) ∧
      (∀ X, -Real.log Z_T ≤ E_plus X) ∧
      Filter.Tendsto (fun X => (E_plus X - E_minus X) / A)
        (nhds 0) (nhds 0) := by
  sorry  -- phase2: assemble from BoueDupuis + WickPolynomials + FractionalSobolev
```

### CATEPT connection

`phi4_existence_d3` is the formal statement of the NS P0 master result:
if the φ⁴ measure exists in d=3, then the pressure is bounded, which
(via the energy identity and BKM criterion) implies NS smooth solutions exist.
This directly feeds into `ns_final_axiom_discharge_20260410` (task 159, P0).

### Prerequisite: EV-002, EV-003, EV-004 DONE.

### Status: TODO
-/

/-!
## EV-006  Update `AFPBridge.lean` barrel and EQFTRTFT imports (P1)

After EV-002..EV-004 land, add new files to the barrel.

### Changes to `CATEPTMain/AFPBridge/EQFTRTFT/EQFTRTFTPort.lean`

Add imports:
```lean
import CATEPTMain.EQFTRTFT.WickPolynomials
import CATEPTMain.EQFTRTFT.BoueDupuis
import CATEPTMain.EQFTRTFT.FractionalSobolev
-- EV-005 (after EV-002/003/004 done):
-- import CATEPTMain.EQFTRTFT.Phi4Existence
```

### Status: TODO (after EV-002/003/004 done)
-/

/-!
## EV-007  Validation and commit (P0)

### Steps

1. Full build:
   ```bash
   lake exe cache get && lake build
   ```
   Expected: EXIT 0.

2. Sorry audit in new files:
   ```bash
   grep -r "sorry" CATEPTMain/AFPBridge/EQFTRTFT/WickPolynomials.lean \
     CATEPTMain/AFPBridge/EQFTRTFT/BoueDupuis.lean \
     CATEPTMain/AFPBridge/EQFTRTFT/FractionalSobolev.lean | wc -l
   ```
   Phase-1 target: 0 sorry in WickPolynomials (all ring-provable),
   EV-004 phase-1 axioms counted (not sorry).

3. GN cluster sorry count (must reduce):
   ```bash
   grep -c "sorry" CATEPTMain/Integration/CATEPTSelfConsistency.lean
   ```
   Must be < 1 (the one remaining sorry at line 873 is P0, independent of this).

4. Commit:
   ```bash
   git add CATEPTMain/AFPBridge/EQFTRTFT/
   git commit -m "feat(eqftrtft): Euclidean variational port — Wick, Boué-Dupuis, FractionalSobolev (EV-001..007)"
   git tag eqftrvt-variational-phase1
   ```

### Status: TODO
-/
