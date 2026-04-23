import CATEPTMain.CATEPT.CATEPT.KolmogorovCoreAbstractions
import CATEPTMain.CATEPT.CATEPT.UnitsDimensionalAnalysis

set_option autoImplicit false

namespace CATEPTMain.CATEPT.CATEPT

/-- Lift a channel to `Option` states so `none` behaves as a vacuum absorber. -/
def liftChannel
    {backend : QTMQuantumBackend}
    (Phi : backend.Channel) : Option backend.State -> Option backend.State :=
  Option.map (backend.applyChannel Phi)

@[simp] theorem liftChannel_none
    {backend : QTMQuantumBackend}
    (Phi : backend.Channel) :
    liftChannel Phi (none : Option backend.State) = none := rfl

@[simp] theorem liftChannel_some
    {backend : QTMQuantumBackend}
    (Phi : backend.Channel) (rho : backend.State) :
    liftChannel Phi (some rho) = some (backend.applyChannel Phi rho) := rfl

/-- Sequential lifting commutes with backend channel composition. -/
theorem liftChannel_sequential
    {backend : QTMQuantumBackend}
    (Phi Psi : backend.Channel)
    (s : Option backend.State) :
    liftChannel Phi (liftChannel Psi s) =
      liftChannel (backend.channelCompose Phi Psi) s := by
  cases s with
  | none => rfl
  | some rho =>
      simp [liftChannel, backend.channelCompose_apply]

/-- If computation has no fixed point on occupied states, only `none` can be fixed. -/
theorem qtm_no_halting_in_occupied_state
    {backend : QTMQuantumBackend}
    {R : SpacetimeRegionQTM backend}
    (hNoFixed : forall rho : backend.State,
      backend.applyChannel R.computationChannel rho ≠ rho)
    (s : Option backend.State)
    (hFixed : liftChannel R.computationChannel s = s) :
    s = none := by
  cases s with
  | none =>
      rfl
  | some rho =>
      have hEq : backend.applyChannel R.computationChannel rho = rho := by
        exact Option.some.inj (by simpa [liftChannel] using hFixed)
      exact False.elim ((hNoFixed rho) hEq)

/-- Successor has no fixed point on naturals. -/
theorem nat_succ_no_fixed_point (n : Nat) : Nat.succ n ≠ n :=
  Nat.succ_ne_self n

/-- Option-fixed-point form of Chaitin-style no finite successor certificate. -/
theorem chaitin_omega_no_finite_certificate
    (c : Option Nat)
    (h : c.map Nat.succ = c) :
    c = none := by
  cases c with
  | none =>
      rfl
  | some n =>
      have hEq : Nat.succ n = n := by
        exact Option.some.inj (by simpa using h)
      exact False.elim ((nat_succ_no_fixed_point n) hEq)

/-- Dimensional origin law: any dimension divided by itself is dimensionless. -/
theorem dim_origin_absorbs (d : Dimension) :
    Dimension.div d d = Dimension.one := by
  simpa using Dimension.div_self d

/-- CAT/EPT entropic-clock origin identity. -/
theorem catept_origin_entropic_clock :
    dimEntropicTime = Dimension.one :=
  dim_entropic_time_dimensionless

/-- CAT/EPT path-integral exponent origin identity. -/
theorem catept_origin_path_integral_exponent :
    dimPathIntegralExponent = Dimension.one :=
  dim_path_integral_exponent_dimensionless

end CATEPTMain.CATEPT.CATEPT
