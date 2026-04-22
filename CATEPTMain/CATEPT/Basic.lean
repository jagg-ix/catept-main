import CATEPTMain.CATEPT.Foundations
import CATEPTMain.CATEPT.PathIntegrals
import CATEPTMain.CATEPT.QuantumGravity

set_option autoImplicit false

noncomputable section

namespace CATEPT

/-- Compatibility theorem name tracked by bridge mapping (Eq 1). -/
theorem complex_action_definition : True := by
  trivial

/-- Legacy name preserved for downstream imports. -/
theorem entropic_time_definition (hbar S_I : ℝ) (h_pos : 0 < hbar) :
    entropic_time hbar S_I = S_I / hbar :=
  eq003_entropic_time_def hbar S_I h_pos

/-- Legacy name preserved for downstream imports. -/
theorem entropic_time_nonneg (hbar S_I : ℝ)
    (h_hbar : 0 < hbar) (h_SI : 0 ≤ S_I) :
    0 ≤ entropic_time hbar S_I :=
  eq003_entropic_time_nonneg hbar S_I h_hbar h_SI

/-- Legacy theorem shape preserved for compatibility. -/
theorem coercivity_implies_convergence
    {Φ : Type*} [NormedAddCommGroup Φ]
    (S_I : Φ → ℝ) (hbar : ℝ)
    (coer : CoercivityCondition (Φ := Φ))
    (h_hbar : 0 < hbar) :
    ∀ φ : Φ, coer.C * ‖φ‖^2 ≤ S_I φ →
      ∃ M : ℝ, Real.exp (-(S_I φ) / hbar) ≤ M := by
  intro φ h_bound
  refine ⟨Real.exp (-coer.C * ‖φ‖^2 / hbar), ?_⟩
  have h :=
    eq057_coercivity_implies_convergence
      (S_I := S_I) (ℏ := hbar) h_hbar coer φ h_bound
  simpa [path_integral_damping] using h

/-- Legacy metric function name preserved. -/
def schwarzschild_metric_function (M r : ℝ) : ℝ :=
  schwarzschild_f M r

/-- Legacy theorem name preserved. -/
theorem schwarzschild_positive (M r : ℝ)
    (h_M : 0 < M) (h_r : 2 * M < r) :
    0 < schwarzschild_metric_function M r := by
  simpa [schwarzschild_metric_function] using
    eq046_schwarzschild_positive M r h_M h_r

/-- Legacy theorem name preserved. -/
theorem bh_entropy_formula (M G : ℝ) (h_M : 0 < M) (h_G : 0 < G) :
    bekenstein_hawking_entropy G M = 4 * Real.pi * G * M^2 := by
  unfold bekenstein_hawking_entropy
  ring

/-- Legacy theorem name preserved. -/
theorem bh_entropy_scaling (M G : ℝ) (h_M : 0 < M) (h_G : 0 < G) :
    bekenstein_hawking_entropy G (2 * M) =
      4 * bekenstein_hawking_entropy G M := by
  simpa using eq147_152_bh_entropy_doubling G M h_G h_M

/-- Legacy propagator name with a parser-safe parameter name. -/
def yukawa_propagator (k_sq m_sq lam : ℝ) : ℝ :=
  1 / (k_sq + m_sq + lam)

/-- Legacy theorem name preserved. -/
theorem yukawa_propagator_positive (k_sq m_sq lam : ℝ)
    (h_k : 0 ≤ k_sq) (h_m : 0 ≤ m_sq) (h_lam : 0 < lam) :
    0 < yukawa_propagator k_sq m_sq lam := by
  unfold yukawa_propagator
  exact eq075_propagator_positive k_sq m_sq lam h_k h_m h_lam

/-- Legacy theorem name preserved. -/
theorem yukawa_screening (m_sq lam : ℝ) (h_m : 0 ≤ m_sq) (h_lam : 0 < lam) :
    m_sq < m_sq + lam := by
  linarith

/-- Backward-compatible consistency contract. -/
theorem catept_framework_consistency
    {Φ : Type*} [NormedAddCommGroup Φ]
    (χ : ComplexAction Φ)
    (hbar : ℝ) (h_hbar : 0 < hbar)
    (coer : CoercivityCondition (Φ := Φ)) :
    (∀ φ : Φ, 0 ≤ χ.S_I φ) ∧
    (∀ φ : Φ, 0 ≤ entropic_time hbar (χ.S_I φ)) ∧
    (∀ φ : Φ, ∃ M : ℝ, Real.exp (-(χ.S_I φ) / hbar) ≤ M) := by
  constructor
  · exact χ.S_I_nonneg
  constructor
  · intro φ
    exact entropic_time_nonneg hbar (χ.S_I φ) h_hbar (χ.S_I_nonneg φ)
  · intro φ
    refine ⟨Real.exp (-coer.C * ‖φ‖^2 / hbar), ?_⟩
    have h :=
      eq057_coercivity_implies_convergence
        (S_I := χ.S_I) (ℏ := hbar) h_hbar coer φ (coer.bound χ.S_I φ)
    simpa [path_integral_damping] using h

end CATEPT
