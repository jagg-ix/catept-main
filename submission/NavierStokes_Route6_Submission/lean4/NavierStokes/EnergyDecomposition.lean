import NavierStokes.PDEInterfaces

/-!
# Navier-Stokes Energy Decomposition

This module exposes a scoped-assumption decomposition for the Leray energy
inequality so downstream files can use a transparent proof chain.
-/

namespace NavierStokes.Millennium

set_option autoImplicit false

noncomputable section

/-- For `Rat`, `0 ≤ a` implies `-a ≤ 0`. -/
theorem rat_neg_nonpos (a : Rat) (h : 0 ≤ a) : -a ≤ 0 := by linarith

/--
Scoped assumptions for decomposing the NS energy inequality.

The PDE-heavy content is represented as fields of this structure, so users can
see exactly which steps are assumed.
-/
structure EnergyDecompositionAssumptions
    (X : Type)
    (ops : FieldOps X)
    (spaces : FunctionSpaceAssumptions X)
    (nu : Rat)
    (kineticEnergy enstrophy : X → Rat) where
  nu_pos : 0 < nu
  enstrophy_nonneg : ∀ v : X, 0 ≤ enstrophy v
  energyRate : Trajectory X → Rat → Rat
  energy_balance :
    ∀ (traj : Trajectory X) (t : Rat),
      SatisfiesNSPDE ops nu traj →
      RespectsFunctionSpaces spaces traj →
      energyRate traj t = -(nu * enstrophy (traj.stateAt t).velocity)
  ftc_nonpositive_rate :
    ∀ (traj : Trajectory X),
      (∀ (t : Rat), 0 ≤ t → energyRate traj t ≤ 0) →
      ∀ (t : Rat), 0 ≤ t →
        kineticEnergy (traj.stateAt t).velocity ≤
          kineticEnergy (traj.stateAt 0).velocity

/-- The energy rate is nonpositive from `dE/dt = -nu*enstrophy` and positivity. -/
theorem energy_rate_nonpositive
    {X : Type}
    {ops : FieldOps X}
    {spaces : FunctionSpaceAssumptions X}
    {nu : Rat}
    {kineticEnergy enstrophy : X → Rat}
    (E : EnergyDecompositionAssumptions X ops spaces nu kineticEnergy enstrophy)
    (traj : Trajectory X) (t : Rat)
    (hNS : SatisfiesNSPDE ops nu traj)
    (hFS : RespectsFunctionSpaces spaces traj) :
    E.energyRate traj t ≤ 0 := by
  rw [E.energy_balance traj t hNS hFS]
  have := E.nu_pos
  have := E.enstrophy_nonneg (traj.stateAt t).velocity
  linarith [mul_nonneg (le_of_lt E.nu_pos) (E.enstrophy_nonneg (traj.stateAt t).velocity)]

/--
Energy inequality from the decomposition chain.

This theorem is sorry-free once the decomposition assumptions are supplied.
-/
theorem energy_inequality_of_decomposition
    {X : Type}
    {ops : FieldOps X}
    {spaces : FunctionSpaceAssumptions X}
    {nu : Rat}
    {kineticEnergy enstrophy : X → Rat}
    (E : EnergyDecompositionAssumptions X ops spaces nu kineticEnergy enstrophy)
    (traj : Trajectory X)
    (hNS : SatisfiesNSPDE ops nu traj)
    (hFS : RespectsFunctionSpaces spaces traj) :
    ∀ (t : Rat), 0 ≤ t →
      kineticEnergy (traj.stateAt t).velocity ≤
        kineticEnergy (traj.stateAt 0).velocity := by
  have hNonpos : ∀ (t : Rat), 0 ≤ t → E.energyRate traj t ≤ 0 :=
    fun t ht => energy_rate_nonpositive E traj t hNS hFS
  exact E.ftc_nonpositive_rate traj hNonpos

end

end NavierStokes.Millennium
