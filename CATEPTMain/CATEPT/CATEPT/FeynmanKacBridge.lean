import CATEPTMain.CATEPT.CATEPT.Foundations
import CATEPTMain.CATEPT.CATEPT.PathIntegrals
import CATEPTMain.CATEPT.CATEPT.ComplexMeasureBridge
import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Mathlib.MeasureTheory.Integral.IntervalIntegral.Basic
import Mathlib.MeasureTheory.Integral.Bochner.Set

set_option autoImplicit false

noncomputable section

open Real Complex MeasureTheory

namespace CATEPTMain.CATEPT.CATEPT

/-! # Feynman-Kac <-> CAT/EPT Bridge (Core Surface)

This module ports stable FK bridge contracts into `catept-core`, and now
includes reusable measure-theory links through `ComplexMeasureBridge`.
-/

/-- Euclidean FK damping is strictly positive. -/
theorem euclidean_weight_is_real_positive
    {X : Type*} (V : X -> ℝ) (beta : ℝ) (x : X) :
    0 < feynman_kac_weight V beta x :=
  feynman_kac_weight_pos V beta x

/-- Constant-potential FK weight written in scalar form. -/
theorem constant_potential_fk_weight (V T : ℝ) :
    feynman_kac_weight (fun _ : Unit => V) T () = Real.exp (-(V * T)) := by
  unfold feynman_kac_weight
  ring_nf

/--
For constant potential `V` over `[0, T]`, CAT/EPT entropic time matches the
cumulative FK potential when `S_I = V * T * hbar`.
-/
theorem entropic_time_is_cumulative_potential
    (V T hbar : ℝ) (_hV : 0 <= V) (_hT : 0 < T) (hh : 0 < hbar)
    (S_I : ℝ) (hSI : S_I = V * T * hbar) :
    entropic_time hbar S_I = V * T := by
  unfold entropic_time
  rw [hSI]
  field_simp [hh.ne']

/-- FK damping `exp(-V*T)` equals CAT/EPT damping `exp(-tau_ent)`. -/
theorem fk_weight_equals_catept_damping
    (V T hbar : ℝ) (hh : 0 < hbar)
    (S_I : ℝ) (hSI : S_I = V * T * hbar) :
    Real.exp (-(V * T)) = Real.exp (-(entropic_time hbar S_I)) := by
  congr 1
  rw [neg_inj]
  unfold entropic_time
  rw [hSI]
  field_simp [hh.ne']

/-- The scalar FK damping `exp(-V*t)` satisfies `w' = -V*w`. -/
theorem damping_satisfies_decay_ODE (V : ℝ) (_hV : 0 <= V) :
    forall t : ℝ, HasDerivAt (fun t => Real.exp (-V * t))
      (-V * Real.exp (-V * t)) t := by
  intro t
  have hf : HasDerivAt (fun t => -V * t) (-V) t := by
    simpa [mul_comm, mul_left_comm, mul_assoc] using
      (hasDerivAt_id t).const_mul (-V)
  have hg : HasDerivAt (fun t => Real.exp (-V * t)) (Real.exp (-V * t) * (-V)) t := by
    simpa using hf.exp
  simpa [mul_comm, mul_left_comm, mul_assoc] using hg

/-- Initial condition `w(0) = 1` for `w(t) = exp(-V*t)`. -/
theorem decay_ODE_initial_condition (V : ℝ) (t : ℝ) (ht : t = 0) :
    Real.exp (-V * t) = 1 := by
  simp [ht]

/--
Main Euclidean FK correspondence in this core lane:
`exp(-tau_ent)` equals the constant-potential FK weight.
-/
theorem catept_fk_euclidean_correspondence
    (V T hbar : ℝ) (hh : 0 < hbar)
    (S_I : ℝ) (hSI : S_I = V * T * hbar) :
    Real.exp (-(entropic_time hbar S_I)) =
      feynman_kac_weight (fun _ : Unit => V) T () := by
  calc
    Real.exp (-(entropic_time hbar S_I))
        = Real.exp (-(V * T)) := by
          symm
          exact fk_weight_equals_catept_damping V T hbar hh S_I hSI
    _ = feynman_kac_weight (fun _ : Unit => V) T () := by
      symm
      exact constant_potential_fk_weight V T

/-- Pathwise potential integral `int_0^t V(x(tau)) dtau`. -/
def fkPathPotential (V : ℝ -> ℝ) (x : ℝ -> ℝ) (t : ℝ) : ℝ :=
  ∫ tau in (0 : ℝ)..t, V (x tau)

/-- FK path weight `exp(-int_0^t V(x(tau)) dtau)`. -/
def fkPathWeight (V : ℝ -> ℝ) (x : ℝ -> ℝ) (t : ℝ) : ℝ :=
  Real.exp (-(fkPathPotential V x t))

/-- Pathwise FK damping is always nonnegative. -/
theorem fkPathWeight_nonneg (V : ℝ -> ℝ) (x : ℝ -> ℝ) (t : ℝ) :
    0 <= fkPathWeight V x t := by
  unfold fkPathWeight
  exact le_of_lt (Real.exp_pos _)

/-- If `V >= 0` and `t >= 0`, FK path weight is bounded by `1`. -/
theorem fkPathWeight_le_one
    (V : ℝ -> ℝ) (x : ℝ -> ℝ) (t : ℝ)
    (hV : forall y, 0 <= V y) (ht : 0 <= t) :
    fkPathWeight V x t <= 1 := by
  unfold fkPathWeight fkPathPotential
  rw [<- Real.exp_zero]
  apply Real.exp_le_exp.mpr
  have hIntNonneg : 0 <= ∫ tau in (0 : ℝ)..t, V (x tau) := by
    exact intervalIntegral.integral_nonneg ht (fun tau _htau => hV (x tau))
  linarith

/-- Entropic-time identification at path level. -/
theorem entropic_time_equals_path_potential
    (hbar : ℝ) (hh : 0 < hbar)
    (V : ℝ -> ℝ) (x : ℝ -> ℝ) (t S_I : ℝ)
    (hSI : S_I = hbar * fkPathPotential V x t) :
    entropic_time hbar S_I = fkPathPotential V x t := by
  unfold entropic_time
  rw [hSI]
  field_simp [hh.ne']

/-- Equivalent damping statement in CAT/EPT notation. -/
theorem catept_damping_equals_fk_path_weight
    (hbar : ℝ) (hh : 0 < hbar)
    (V : ℝ -> ℝ) (x : ℝ -> ℝ) (t S_I : ℝ)
    (hSI : S_I = hbar * fkPathPotential V x t) :
    Real.exp (-(entropic_time hbar S_I)) = fkPathWeight V x t := by
  unfold fkPathWeight
  congr 1
  rw [entropic_time_equals_path_potential hbar hh V x t S_I hSI]

/-! ## Legacy `complex_FK_bridge` placeholder removed

Earlier drafts of this file shipped a vacuous

    theorem complex_FK_bridge {X} (_M : FeynmanKacModel X) (_obs : X → ℂ) :
        True := by trivial

as a stand-in for "the Glimm–Jaffe complex Feynman–Kac open problem."
That placeholder added no proof power and has been removed.

For the **rigorous** complex FK theorem in the catept-physics class
(entropically damped oscillatory measures over `MeasurePathIntegralModel`),
see `CATEPTMain.Integration.RigorousComplexFeynmanKac.complex_FK_rigorous`,
which leverages the Phase-12 `‖weight‖ = damping` identity together with
Mathlib's Bochner-integral theory to give a fully formal, kernel-only
result.

The fully general Glimm–Jaffe oscillatory-measure problem (arbitrary
complex measures with no real damping component) remains open in the
literature; the catept framework restricts attention to the
entropically-damped class precisely because that class admits the
rigorous treatment shipped in `RigorousComplexFeynmanKac`.
-/

/-! ## FK / Complex-Measure Reusable Bridge Theorems -/

/-- FK set integral equals CAT/EPT complex-measure evaluation on measurable sets. -/
theorem fk_path_integral_eq_complex_measure
    {alpha : Type*} [MeasurableSpace alpha]
    (m : MeasurePathIntegralModel alpha)
    (hL1 : Integrable (fun x => m.damping x) m.mu)
    (s : Set alpha) (hs : MeasurableSet s) :
    ∫ x in s, m.weight x ∂m.mu = catept_complex_measure m hL1 s := by
  exact (catept_complex_measure_apply m hL1 s hs).symm

/-- In the Euclidean sector (`S_R = 0`), the FK complex measure is real-valued. -/
theorem euclidean_fk_measure_is_real_valued
    {alpha : Type*} [MeasurableSpace alpha]
    (m : MeasurePathIntegralModel alpha)
    (hL1 : Integrable (fun x => m.damping x) m.mu)
    (hRe : ∀ x, m.actionRe x = 0)
    (s : Set alpha) (hs : MeasurableSet s) :
    (catept_complex_measure m hL1 s).im = 0 := by
  rw [catept_complex_measure_apply m hL1 s hs]
  have hweq : ∀ x, m.weight x = (m.damping x : ℂ) :=
    fun x => m.weight_eq_damping_of_actionRe_zero hRe x
  simp_rw [hweq]
  rw [show ∫ x in s, (m.damping x : ℂ) ∂m.mu =
      ↑(∫ x in s, m.damping x ∂m.mu) from
      integral_ofReal (𝕜 := ℂ)]
  exact Complex.ofReal_im _

/-- The partition function bounds total variation on the whole space. -/
theorem fk_partition_bounds_total_variation
    {alpha : Type*} [MeasurableSpace alpha]
    (m : MeasurePathIntegralModel alpha)
    (hL1 : Integrable (fun x => m.damping x) m.mu) :
    ‖catept_complex_measure m hL1 Set.univ‖ <= partitionFunction m :=
  catept_complex_measure_norm_le m hL1 Set.univ MeasurableSet.univ

/-- On finite reference spaces, the CAT/EPT complex measure exists canonically. -/
theorem fk_complex_measure_from_finite_space
    {alpha : Type*} [MeasurableSpace alpha]
    (m : MeasurePathIntegralModel alpha)
    [IsFiniteMeasure m.mu] :
    ∃ nu : VectorMeasure alpha ℂ,
      ∀ s : Set alpha, MeasurableSet s -> nu s = ∫ x in s, m.weight x ∂m.mu := by
  refine ⟨catept_complex_measure m (catept_measure_exists_from_finite_reference m), ?_⟩
  intro s hs
  exact catept_complex_measure_apply m _ s hs

end CATEPTMain.CATEPT.CATEPT
