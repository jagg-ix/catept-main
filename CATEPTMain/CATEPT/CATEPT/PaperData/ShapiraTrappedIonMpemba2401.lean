/-!
# Shapira et al. 2024 — Inverse Mpemba Effect on Trapped-Ion Qubit

## Paper

S. Aharony Shapira, Y. Shapira, J. Markov, G. Teza, N. Akerman, O. Raz, R. Ozeri:
**"The inverse Mpemba effect demonstrated on a single trapped ion qubit"**
arXiv:2401.05830v2 [quant-ph] 12 May 2024.
Department of Physics of Complex Systems, Weizmann Institute of Science.

## System

Single ⁸⁸Sr⁺ trapped-ion qubit, Zeeman ground-state manifold 5S₁/₂.
Coherently driven by Rabi Hamiltonian `H = Ω σ_x` (field Rabi frequency Ω),
coupled to a Markovian bath producing decay and dephasing:

  L[ρ] = −(iΩ/2) [σ_x, ρ] + γ_decay · L_|↓⟩⟨↑|[ρ] + γ_dephase · L_|↑⟩⟨↑|[ρ]
  γ_decay   = α · γ(T)
  γ_dephase = (1−α) · γ(T)
  α ∈ [0,1]  (decay/dephasing branching)
  γ(T)      = temperature-dependent decoherence rate

## Key experimental findings

- Demonstrated an **inverse Mpemba effect**: a cold qubit reaches a hot
  steady state faster than a hot qubit — and for sufficiently coherent
  systems, **exponentially faster** (strong inverse-ME).
- Effect exists ONLY for sufficiently coherent qubits — classical limit
  (α = 0, no coherence) does not exhibit strong-ME.

## Values extracted from paper text

All values verbatim from the PDF body, pages 2–5, with figure references.

## Relevance to CAT/EPT

CAT/EPT's entropic rate λ = k_BT/ℏ generalizes the paper's γ(T). The
existence of the strong inverse-ME at α = 0.94 and its absence at
α = 1/3 (boundary for strong effect) is a testable CAT/EPT prediction:
the framework's coherence-sensitive damping should reproduce the
slow-mode cancellation at γ_i ≈ 0.07 for γ_f = 15.
-/

namespace CATEPTMain.CATEPT.CATEPT.PaperData.ShapiraTrappedIonMpemba2401

/-! ## Fitted decay/dephasing branching ratios α -/

/-- α fit to the orange calibration curve (lowest coherence). -/
def alpha_orange : Float := 0.21
def alpha_orange_sigma : Float := 0.03

/-- α fit to the brown calibration curve (intermediate coherence). -/
def alpha_brown : Float := 0.51
def alpha_brown_sigma : Float := 0.04

/-- α fit to the blue calibration curve (highest coherence). -/
def alpha_blue : Float := 0.94
def alpha_blue_sigma : Float := 0.07

/-- α threshold for strong-ME existence (no strong-ME below this). -/
def alpha_strong_me_threshold : Float := 1.0 / 3.0

/-! ## Decoherence-rate state diagram -/

/-- Final steady-state decoherence rate (dimensionless, γ' = γ/γ_ref)
    used in Fig 3 of the paper. -/
def gamma_f_prime_fig3 : Float := 15.0

/-- Initial cold-qubit rate in Fig 3 (strong inverse-ME regime). -/
def gamma_i_prime_cold_fig3 : Float := 0.116

/-- Initial hot-qubit rate in Fig 3. -/
def gamma_i_prime_hot_fig3 : Float := 0.776

/-- Vanishing point of the slow-relaxation-mode coefficient a_- at γ_f' = 15:
    proves strong-ME existence (coefficient of slow mode cancels). -/
def gamma_i_prime_strong_me_cancellation : Float := 0.07

/-! ## Fig 4 configuration (γ_f' = 100) -/

/-- Final rate used in Fig 4 (faster regime). -/
def gamma_f_prime_fig4 : Float := 100.0

/-- Cold initial rate for Fig 4, approximately zero. -/
def gamma_i_prime_cold_fig4 : Float := 0.0

/-- Hot initial rate for Fig 4. -/
def gamma_i_prime_hot_fig4 : Float := 0.390

/-- Crossover time where cold trajectory passes hot trajectory
    (in units of γ_f^{-1}). -/
def t_cross_over_gamma_f_inv : Float := 0.6

/-! ## CAT/EPT-testable consequences -/

/-- The paper's result implies γ_hot > γ_cold at t = t_cross, which
    under CAT/EPT corresponds to λ_hot > λ_cold (entropic-rate
    ordering matches paper's decoherence-rate ordering).
    This gives the `hotFaster`-in-arrow-of-time fact even when the
    initial populations are inverted — the signature of the inverse
    quantum Mpemba effect. -/
def cat_ept_lambda_ratio_strong_me : Float :=
  gamma_i_prime_hot_fig3 / gamma_i_prime_cold_fig3

/-- Strong-ME condition: α > α_threshold. -/
def alpha_blue_above_threshold : Bool :=
  alpha_blue > alpha_strong_me_threshold

end CATEPTMain.CATEPT.CATEPT.PaperData.ShapiraTrappedIonMpemba2401
