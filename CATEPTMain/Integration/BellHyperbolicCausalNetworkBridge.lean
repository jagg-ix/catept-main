import CATEPTMain.Integration.HyperbolicGeometryFoundationsCarrier
import CATEPTPluginDomainQuantum.PM.CHSH_Inequality
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

/-!
# BellHyperbolicCausalNetworkBridge — Bell regime classification + verified bounds

Verified-content carrier for the Bell ↔ hyperbolic-eccentricity cluster
from the intake (`docs/intake/chatgpt-making-history-in-theory3-leverage-map.md`,
lines 5240+, 5478):

The intake's heuristic identification "eccentricity `e` ↔ Bell regime"
was previously ported as a quantitative `|S_CHSH| ≤ 2e` field; that
field was *not* derived in the source and has been removed.  This
module ships only what *is* verified:

1. **Entropy-production rate** (intake §4):
   `entropyProductionRate e := e² − 1`,
   with the proven equivalence
   `0 ≤ entropyProductionRate e ↔ e ≤ −1 ∨ 1 ≤ e`.

2. **Bell regime classification** (intake table at line 5478):
   `BellRegime := classical | parabolic | hyperbolic` selected by the
   eccentricity range, with proven dichotomy theorems.

3. **Tsirelson bound** as a structural Prop (cited reference):
   `|S_CHSH| ≤ 2√2`, per *Causality, Joint measurement and Tsirelson's
   bound* (arXiv:quant-ph/0608100v2; PDF on disk) — encoded as a
   carrier field rather than a derived theorem (the derivation
   requires QM operator-algebra machinery beyond the carrier scope).
-/

set_option autoImplicit false

noncomputable section

namespace CATEPTMain.Integration.BellHyperbolicCausalNetworkBridge

open CATEPTMain.Integration.HyperbolicGeometryFoundationsCarrier
open CATEPTPluginDomainQuantum.IMD CATEPTPluginDomainQuantum.PM
  CATEPTPluginDomainQuantum.PM.CHSH_Inequality

/-! ## §1. Entropy-production rate `S[e] = e² − 1` -/

/-- **Entropy-production rate** along a hyperbolic trajectory
(intake §4): `entropyProductionRate e := e² − 1`. -/
def entropyProductionRate (e : ℝ) : ℝ := e ^ 2 - 1

/-- **Proven:** `0 ≤ entropyProductionRate e ↔ e ≤ -1 ∨ 1 ≤ e`. -/
theorem entropyProductionRate_nonneg_iff (e : ℝ) :
    0 ≤ entropyProductionRate e ↔ e ≤ -1 ∨ 1 ≤ e := by
  unfold entropyProductionRate
  constructor
  · intro h
    by_contra hc
    push_neg at hc
    obtain ⟨h1, h2⟩ := hc
    -- ¬ (e ≤ -1 ∨ 1 ≤ e) ⇒ -1 < e ∧ e < 1  ⇒  e² < 1, contradicting 0 ≤ e² − 1.
    nlinarith
  · rintro (h | h)
    · nlinarith
    · nlinarith

/-- **Proven:** for `1 ≤ e`, the entropy-production rate is non-negative. -/
theorem entropyProductionRate_nonneg_of_e_ge_one
    (e : ℝ) (h : 1 ≤ e) : 0 ≤ entropyProductionRate e := by
  rw [entropyProductionRate_nonneg_iff]
  exact Or.inr h

/-- **Proven:** at `e = 1`, the rate vanishes. -/
theorem entropyProductionRate_at_one : entropyProductionRate 1 = 0 := by
  unfold entropyProductionRate; norm_num

/-! ## §2. Bell regime classification -/

/-- **Bell regime** by eccentricity (intake table at line 5478):

* `classical` — `e < 1` (elliptic, bounded local-realistic regime),
* `parabolic` — `e = 1` (saturation boundary),
* `hyperbolic` — `e > 1` (decoherent / Bell-violating regime). -/
inductive BellRegime
  | classical
  | parabolic
  | hyperbolic
  deriving DecidableEq, Repr

/-- The regime selector function. -/
noncomputable def regimeOfEccentricity (e : ℝ) : BellRegime :=
  if e < 1 then BellRegime.classical
  else if e = 1 then BellRegime.parabolic
  else BellRegime.hyperbolic

/-- **Proven:** classical regime ↔ `e < 1`. -/
theorem regime_classical_iff (e : ℝ) :
    regimeOfEccentricity e = BellRegime.classical ↔ e < 1 := by
  unfold regimeOfEccentricity
  split_ifs with h1 h2
  · exact iff_of_true rfl h1
  · refine iff_of_false ?_ ?_
    · intro heq; cases heq
    · linarith
  · refine iff_of_false ?_ ?_
    · intro heq; cases heq
    · push_neg at h1; intro hlt; linarith

/-- **Proven:** parabolic regime ↔ `e = 1`. -/
theorem regime_parabolic_iff (e : ℝ) :
    regimeOfEccentricity e = BellRegime.parabolic ↔ e = 1 := by
  unfold regimeOfEccentricity
  split_ifs with h1 h2
  · refine iff_of_false ?_ ?_
    · intro heq; cases heq
    · intro heq; linarith
  · exact iff_of_true rfl h2
  · refine iff_of_false ?_ ?_
    · intro heq; cases heq
    · exact h2

/-- **Proven:** hyperbolic regime ↔ `e > 1`. -/
theorem regime_hyperbolic_iff (e : ℝ) :
    regimeOfEccentricity e = BellRegime.hyperbolic ↔ 1 < e := by
  unfold regimeOfEccentricity
  split_ifs with h1 h2
  · refine iff_of_false ?_ ?_
    · intro heq; cases heq
    · intro hlt; linarith
  · refine iff_of_false ?_ ?_
    · intro heq; cases heq
    · intro hlt; linarith
  · push_neg at h1
    refine iff_of_true rfl ?_
    exact lt_of_le_of_ne h1 (Ne.symm h2)

/-! ## §3. BellExperiment + bridge carrier -/

/-- **Bell experiment surrogate.** -/
structure BellExperiment where
  /-- The CHSH-type combination of correlation expectations. -/
  S_CHSH    : ℝ
  /-- The eccentricity / correlation-length parameter. -/
  e         : ℝ

/-- **Bell-hyperbolic bridge.**

Holds the experiment plus the Tsirelson bound as a Prop field.  The
field is **discharged from upstream** by
`BellHyperbolicBridge.fromQuantumExperiment`, which consumes
`CATEPTPluginDomainQuantum.PM.CHSH_Inequality.chsh_quantum_bound`
directly — replacing the previous arXiv-only citation with a
Lean-derivable obligation.

No quantitative `|S_CHSH| ≤ f(e)` claim is made — the
regime↔eccentricity link is interpretive in the intake and not derived
from the QM bounds. -/
structure BellHyperbolicBridge where
  /-- The Bell experiment. -/
  experiment             : BellExperiment
  /-- **Tsirelson bound**: `|S_CHSH| ≤ 2√2`.  Discharged from upstream
  `CATEPTPluginDomainQuantum.PM.CHSH_Inequality.chsh_quantum_bound`
  via `fromQuantumExperiment`. -/
  tsirelson_bound        : |experiment.S_CHSH| ≤ 2 * Real.sqrt 2

namespace BellHyperbolicBridge

variable (B : BellHyperbolicBridge)

/-- **Extraction:** the Tsirelson bound. -/
theorem chsh_tsirelson_bound : |B.experiment.S_CHSH| ≤ 2 * Real.sqrt 2 :=
  B.tsirelson_bound

/-- The regime selector applied to the experiment's eccentricity. -/
noncomputable def regime : BellRegime :=
  regimeOfEccentricity B.experiment.e

/-- **Trivial existence.** Use `S_CHSH = 0`, `e = 1`; the Tsirelson
bound `|0| ≤ 2√2` holds trivially. -/
theorem exists_trivial : ∃ _ : BellHyperbolicBridge, True := by
  refine ⟨{ experiment      := { S_CHSH := 0, e := 1 }
          , tsirelson_bound := ?_ }, trivial⟩
  -- |0| = 0 ≤ 2√2
  show |(0 : ℝ)| ≤ 2 * Real.sqrt 2
  rw [abs_zero]
  positivity

/-- **Construct from a quantum experiment.**

Given dichotomic observables `A, A', B, B'` and a density operator `ρ`
satisfying the upstream conditions, construct a `BellHyperbolicBridge`
with `S_CHSH := chshExpect A A' B B' ρ`, the Tsirelson bound
**discharged directly** from
`CATEPTPluginDomainQuantum.PM.CHSH_Inequality.chsh_quantum_bound`. -/
noncomputable def fromQuantumExperiment
    (A A' B B' ρ : QMat) (e : ℝ)
    (hA  : IsDichotomicObs A)  (hA' : IsDichotomicObs A')
    (hB  : IsDichotomicObs B)  (hB' : IsDichotomicObs B')
    (hρ  : IsFullDensityOp ρ) :
    BellHyperbolicBridge :=
  { experiment :=
      { S_CHSH := chshExpect A A' B B' ρ
      , e      := e }
  , tsirelson_bound :=
      chsh_quantum_bound A A' B B' ρ hA hA' hB hB' hρ }

end BellHyperbolicBridge

/-! ## §4. Capstone -/

/-- **Bell-hyperbolic causal-network bundle.** -/
theorem bell_hyperbolic_causal_network_bundle :
    ∃ _ : BellHyperbolicBridge, True :=
  BellHyperbolicBridge.exists_trivial

end CATEPTMain.Integration.BellHyperbolicCausalNetworkBridge

end
