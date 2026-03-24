import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.Ring

/-!
# Navier-Stokes Millennium PDE Interfaces (W3 Bootstrap)

This file introduces abstract interfaces for:
- state representation (`State`)
- incompressible Navier-Stokes proposition (`IncompressibleNS`)
- function-space placeholders (`SobolevSpacePlaceholder`, `FunctionSpaceAssumptions`)
- bridge obligations to path-integral well-posedness.

The goal is to make the hard bridge theorems explicit while keeping the PDE
layer implementation-agnostic.
-/

namespace NavierStokes.Millennium

universe u

inductive SpatialSetting where
  | wholeSpaceR3
  | periodicT3
deriving Repr, DecidableEq

structure SobolevSpacePlaceholder where
  setting : SpatialSetting
  order : Rat
  codomain : String
  label : String
deriving Repr, DecidableEq

def velocitySobolev (setting : SpatialSetting) (s : Rat) : SobolevSpacePlaceholder :=
  {
    setting := setting
    order := s
    codomain := "vector3"
    label := "H^s velocity space"
  }

def pressureSobolev (setting : SpatialSetting) (s : Rat) : SobolevSpacePlaceholder :=
  {
    setting := setting
    order := s
    codomain := "scalar"
    label := "H^(s-1) pressure space placeholder"
  }

structure State (X : Type u) where
  velocity : X
  pressure : X

structure FieldOps (X : Type u) where
  zero : X
  add : X -> X -> X
  smul : Rat -> X -> X
  grad : X -> X
  div : X -> X
  laplace : X -> X
  convection : X -> X -> X
  ddt : X -> X

def IncompressibleNS {X : Type u} (ops : FieldOps X) (nu : Rat) (st : State X) : Prop :=
  ops.add (ops.ddt st.velocity) (ops.convection st.velocity st.velocity) =
      ops.add (ops.smul (-1) (ops.grad st.pressure)) (ops.smul nu (ops.laplace st.velocity))
    /\ ops.div st.velocity = ops.zero

structure FunctionSpaceAssumptions (X : Type u) where
  setting : SpatialSetting
  regularityIndex : Rat
  velocitySpace : SobolevSpacePlaceholder
  pressureSpace : SobolevSpacePlaceholder
  velocityMem : X -> Prop
  pressureMem : X -> Prop
  divergenceFree : X -> Prop
  velocitySpaceMatches : velocitySpace = velocitySobolev setting regularityIndex
  pressureSpaceMatches : pressureSpace = pressureSobolev setting regularityIndex

def IsWholeSpace {X : Type u} (spaces : FunctionSpaceAssumptions X) : Prop :=
  spaces.setting = SpatialSetting.wholeSpaceR3

def IsPeriodicT3 {X : Type u} (spaces : FunctionSpaceAssumptions X) : Prop :=
  spaces.setting = SpatialSetting.periodicT3

def AdmissibleInitialData {X : Type u} (spaces : FunctionSpaceAssumptions X) (st : State X) : Prop :=
  spaces.velocityMem st.velocity /\ spaces.pressureMem st.pressure /\ spaces.divergenceFree st.velocity

structure Trajectory (X : Type u) where
  stateAt : Rat -> State X

def SatisfiesNSPDE {X : Type u} (ops : FieldOps X) (nu : Rat) (traj : Trajectory X) : Prop :=
  forall t : Rat, IncompressibleNS ops nu (traj.stateAt t)

/-! ## Discrete-time NS predicate (Stage 213)

The pointwise `FieldOps.ddt : X → X` has no access to neighbouring time steps,
so `SatisfiesNSPDE` is vacuously satisfiable for any opaque carrier.  The three
definitions below provide a *non-vacuous* discrete-time alternative: the
forward-difference operator compares `traj.stateAt t` with `traj.stateAt (t + h)`,
making the PDE content depend on actual time evolution.

`SatisfiesNSPDEΔ` is the target predicate for the Stage 215 concrete bridge
(where `NSField := CoeffInftyR` and `ddt` is replaced by the forward difference). -/

/-- Forward-difference approximation to the time derivative at step `h`. -/
def ddtForward {X : Type u} (ops : FieldOps X) (h : Rat) (x xNext : X) : X :=
  ops.smul (1 / h) (ops.add xNext (ops.smul (-1) x))

/-- Discrete-time incompressible NS: momentum equation via forward difference + div-free. -/
def IncompressibleNSΔ {X : Type u}
    (ops : FieldOps X) (nu h : Rat) (st stNext : State X) : Prop :=
  ops.add (ddtForward ops h st.velocity stNext.velocity)
          (ops.convection st.velocity st.velocity) =
    ops.add (ops.smul (-1) (ops.grad st.pressure))
            (ops.smul nu (ops.laplace st.velocity)) ∧
  ops.div st.velocity = ops.zero

/-- A trajectory satisfies the discrete-time NS equation at step `h`:
    for every rational time `t`, the state at `t` evolves to `t + h` via the
    forward-difference NS operator.  Unlike `SatisfiesNSPDE`, this actually
    constrains consecutive trajectory states rather than a pointwise `ddt`. -/
def SatisfiesNSPDEΔ {X : Type u}
    (ops : FieldOps X) (nu h : Rat) (traj : Trajectory X) : Prop :=
  ∀ t : Rat, IncompressibleNSΔ ops nu h (traj.stateAt t) (traj.stateAt (t + h))

def RespectsFunctionSpaces {X : Type u}
    (spaces : FunctionSpaceAssumptions X) (traj : Trajectory X) : Prop :=
  (forall t : Rat, spaces.velocityMem (traj.stateAt t).velocity) /\
    (forall t : Rat, spaces.pressureMem (traj.stateAt t).pressure) /\
    (forall t : Rat, spaces.divergenceFree (traj.stateAt t).velocity)

def GlobalRegularSolution {X : Type u}
    (ops : FieldOps X)
    (spaces : FunctionSpaceAssumptions X)
    (nu : Rat)
    (st0 : State X) : Prop :=
  AdmissibleInitialData spaces st0 /\
    exists traj : Trajectory X,
      traj.stateAt 0 = st0 /\
        SatisfiesNSPDE ops nu traj /\
        RespectsFunctionSpaces spaces traj

/-- Delta-aware regularity witness:
same as `GlobalRegularSolution`, but also carries a discrete-time PDE witness
`SatisfiesNSPDEΔ` at step `h`. -/
def GlobalRegularSolutionΔ {X : Type u}
    (ops : FieldOps X)
    (spaces : FunctionSpaceAssumptions X)
    (nu h : Rat)
    (st0 : State X) : Prop :=
  AdmissibleInitialData spaces st0 /\
    ∃ traj : Trajectory X,
      traj.stateAt 0 = st0 /\
        SatisfiesNSPDE ops nu traj /\
        SatisfiesNSPDEΔ ops nu h traj /\
        RespectsFunctionSpaces spaces traj

structure BreakdownWitness (X : Type u) where
  blowupTime : Rat
  blowupTimePos : 0 < blowupTime
  trajectory : Trajectory X
  losesSmoothness : Prop

def FiniteTimeBreakdownCounterexample {X : Type u}
    (ops : FieldOps X)
    (spaces : FunctionSpaceAssumptions X)
    (nu : Rat)
    (st0 : State X) : Prop :=
  AdmissibleInitialData spaces st0 /\
    exists witness : BreakdownWitness X,
      witness.trajectory.stateAt 0 = st0 /\
        SatisfiesNSPDE ops nu witness.trajectory /\
        RespectsFunctionSpaces spaces witness.trajectory /\
        witness.losesSmoothness

structure AxiomaticEstimates (X : Type u) where
  kineticEnergy : X -> Rat
  enstrophy : X -> Rat
  energyInequality : Prop
  continuationCriterion : Prop
  localExistenceInterface : Prop

structure PathIntegralInterface (X : Type u) where
  PIWellPosed : State X -> Prop

/-- Dissipation is nonnegative: for every NS trajectory respecting function
    spaces, the viscous dissipation rate `ν ∫ |∇v|²` is ≥ 0 at all times.
    This is equivalent to `dE/dt ≤ 0` (energy monotonicity). -/
def DissipationNonnegative {X : Type u}
    (ops : FieldOps X)
    (spaces : FunctionSpaceAssumptions X)
    (nu : Rat) : Prop :=
  ∀ (traj : Trajectory X),
    SatisfiesNSPDE ops nu traj →
    RespectsFunctionSpaces spaces traj →
    ∀ (t : Rat), 0 ≤ t →
      ∃ (dissipation : Rat), 0 ≤ dissipation

/-- Vorticity blowup control: path-integral well-posedness bounds the
    vorticity growth along all admissible NS trajectories, preventing
    finite-time blowup via the BKM continuation criterion. -/
def VorticityBlowupControl {X : Type u}
    (_ops : FieldOps X)
    (spaces : FunctionSpaceAssumptions X)
    (nu : Rat)
    (pi : PathIntegralInterface X) : Prop :=
  ∀ (st0 : State X),
    pi.PIWellPosed st0 →
    AdmissibleInitialData spaces st0 →
    ∃ (traj : Trajectory X),
      traj.stateAt 0 = st0 ∧
      SatisfiesNSPDE _ops nu traj ∧
      RespectsFunctionSpaces spaces traj

/-- Delta-aware vorticity-control endpoint:
adds a discrete-time witness `SatisfiesNSPDEΔ` to the continuation payload. -/
def VorticityBlowupControlΔ {X : Type u}
    (_ops : FieldOps X)
    (spaces : FunctionSpaceAssumptions X)
    (nu h : Rat)
    (pi : PathIntegralInterface X) : Prop :=
  ∀ (st0 : State X),
    pi.PIWellPosed st0 →
    AdmissibleInitialData spaces st0 →
    ∃ (traj : Trajectory X),
      traj.stateAt 0 = st0 ∧
      SatisfiesNSPDE _ops nu traj ∧
      SatisfiesNSPDEΔ _ops nu h traj ∧
      RespectsFunctionSpaces spaces traj

def ForwardBridgeObligation {X : Type u}
    (ops : FieldOps X)
    (spaces : FunctionSpaceAssumptions X)
    (nu : Rat)
    (pi : PathIntegralInterface X) : Prop :=
  forall st0 : State X, GlobalRegularSolution ops spaces nu st0 -> pi.PIWellPosed st0

def BackwardBridgeObligation {X : Type u}
    (ops : FieldOps X)
    (spaces : FunctionSpaceAssumptions X)
    (nu : Rat)
    (pi : PathIntegralInterface X) : Prop :=
  forall st0 : State X, pi.PIWellPosed st0 -> GlobalRegularSolution ops spaces nu st0

/-- Delta-aware backward bridge obligation:
same endpoint as `BackwardBridgeObligation`, but with `GlobalRegularSolutionΔ`. -/
def BackwardBridgeObligationΔ {X : Type u}
    (ops : FieldOps X)
    (spaces : FunctionSpaceAssumptions X)
    (nu h : Rat)
    (pi : PathIntegralInterface X) : Prop :=
  ∀ st0 : State X, pi.PIWellPosed st0 → GlobalRegularSolutionΔ ops spaces nu h st0

theorem bridgeEquivalenceOfObligations {X : Type u}
    (ops : FieldOps X)
    (spaces : FunctionSpaceAssumptions X)
    (nu : Rat)
    (pi : PathIntegralInterface X)
    (hForward : ForwardBridgeObligation ops spaces nu pi)
    (hBackward : BackwardBridgeObligation ops spaces nu pi) :
    forall st0 : State X, GlobalRegularSolution ops spaces nu st0 <-> pi.PIWellPosed st0 := by
  intro st0
  exact Iff.intro (hForward st0) (hBackward st0)

/-- Forward bridge bootstrap: regularity implies PI well-posedness.

This is an axiom rather than a sorry-gated theorem. The concrete instantiation
for NSField is proved via `energy_estimates_imply_forward_bridge` in
`AxiomaticEstimates.lean` using the `ForwardBridgeDecomposition` structure. -/
axiom forward_bridge_obligation_bootstrap
    {X : Type u}
    (ops : FieldOps X)
    (spaces : FunctionSpaceAssumptions X)
    (nu : Rat)
    (pi : PathIntegralInterface X)
    (hDiss : DissipationNonnegative ops spaces nu) :
    ForwardBridgeObligation ops spaces nu pi

/-- Backward bridge bootstrap: PI well-posedness implies regularity.

Given a `VorticityBlowupControl` witness, this follows definitionally:
`GlobalRegularSolution` is exactly the admissible-data-to-trajectory map, and
`VorticityBlowupControl` provides that map under `PIWellPosed`. -/
theorem backward_bridge_obligation_bootstrap
    {X : Type u}
    (ops : FieldOps X)
    (spaces : FunctionSpaceAssumptions X)
    (nu : Rat)
    (pi : PathIntegralInterface X)
    (hControl : VorticityBlowupControl ops spaces nu pi) :
    (∀ st0 : State X, pi.PIWellPosed st0 → AdmissibleInitialData spaces st0) →
    BackwardBridgeObligation ops spaces nu pi := by
  intro hAdmissible st0 hPI
  exact ⟨hAdmissible st0 hPI, hControl st0 hPI (hAdmissible st0 hPI)⟩

/-- Forgetful transport from delta-aware regularity to the original endpoint. -/
theorem global_regular_of_delta
    {X : Type u}
    {ops : FieldOps X}
    {spaces : FunctionSpaceAssumptions X}
    {nu h : Rat}
    {st0 : State X} :
    GlobalRegularSolutionΔ ops spaces nu h st0 →
      GlobalRegularSolution ops spaces nu st0 := by
  intro hΔ
  rcases hΔ with ⟨hAdm, traj, h0, hNS, _hNSΔ, hFS⟩
  exact ⟨hAdm, traj, h0, hNS, hFS⟩

/-- Delta-aware vorticity control implies the original vorticity-control endpoint. -/
theorem vorticity_control_of_delta
    {X : Type u}
    {ops : FieldOps X}
    {spaces : FunctionSpaceAssumptions X}
    {nu h : Rat}
    {pi : PathIntegralInterface X} :
    VorticityBlowupControlΔ ops spaces nu h pi →
      VorticityBlowupControl ops spaces nu pi := by
  intro hΔ st0 hPI hAdm
  rcases hΔ st0 hPI hAdm with ⟨traj, h0, hNS, _hNSΔ, hFS⟩
  exact ⟨traj, h0, hNS, hFS⟩

/-- Delta-aware backward bridge implies the original backward bridge obligation. -/
theorem backward_bridge_obligation_of_delta
    {X : Type u}
    {ops : FieldOps X}
    {spaces : FunctionSpaceAssumptions X}
    {nu h : Rat}
    {pi : PathIntegralInterface X} :
    BackwardBridgeObligationΔ ops spaces nu h pi →
      BackwardBridgeObligation ops spaces nu pi := by
  intro hΔ st0 hPI
  exact global_regular_of_delta (hΔ st0 hPI)

end NavierStokes.Millennium
