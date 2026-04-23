import Mathlib.Data.Real.Basic

set_option autoImplicit false

namespace CATEPTMain.CATEPT.CATEPT

/-- Abstract quantum backend used by core-safe QTM bridges. -/
structure QTMQuantumBackend where
  State : Type
  Channel : Type
  applyChannel : Channel -> State -> State
  channelCompose : Channel -> Channel -> Channel
  channelId : Channel
  channelCompose_apply :
    forall (Phi Psi : Channel) (rho : State),
      applyChannel (channelCompose Phi Psi) rho =
        applyChannel Phi (applyChannel Psi rho)
  channelId_apply :
    forall rho : State, applyChannel channelId rho = rho
  channelCompose_assoc :
    forall (Phi1 Phi2 Phi3 : Channel) (rho : State),
      applyChannel (channelCompose Phi1 (channelCompose Phi2 Phi3)) rho =
        applyChannel (channelCompose (channelCompose Phi1 Phi2) Phi3) rho

/-- Minimal QTM region split into computation and communication channels. -/
structure SpacetimeRegionQTM (backend : QTMQuantumBackend) where
  computationChannel : backend.Channel
  communicationChannel : backend.Channel

/-- n-fold application of the computation channel. -/
def applyCompN
    {backend : QTMQuantumBackend}
    (R : SpacetimeRegionQTM backend) (n : Nat) (rho : backend.State) : backend.State :=
  Nat.rec rho (fun _ acc => backend.applyChannel R.computationChannel acc) n

/-- n-fold application of the communication channel. -/
def applyCommN
    {backend : QTMQuantumBackend}
    (R : SpacetimeRegionQTM backend) (n : Nat) (rho : backend.State) : backend.State :=
  Nat.rec rho (fun _ acc => backend.applyChannel R.communicationChannel acc) n

@[simp] theorem applyCompN_zero
    {backend : QTMQuantumBackend}
    (R : SpacetimeRegionQTM backend) (rho : backend.State) :
    applyCompN R 0 rho = rho := rfl

@[simp] theorem applyCompN_succ
    {backend : QTMQuantumBackend}
    (R : SpacetimeRegionQTM backend) (n : Nat) (rho : backend.State) :
    applyCompN R (Nat.succ n) rho =
      backend.applyChannel R.computationChannel (applyCompN R n rho) := rfl

@[simp] theorem applyCommN_zero
    {backend : QTMQuantumBackend}
    (R : SpacetimeRegionQTM backend) (rho : backend.State) :
    applyCommN R 0 rho = rho := rfl

@[simp] theorem applyCommN_succ
    {backend : QTMQuantumBackend}
    (R : SpacetimeRegionQTM backend) (n : Nat) (rho : backend.State) :
    applyCommN R (Nat.succ n) rho =
      backend.applyChannel R.communicationChannel (applyCommN R n rho) := rfl

/-- Identity region using backend identity channels. -/
def identityRegion (backend : QTMQuantumBackend) : SpacetimeRegionQTM backend where
  computationChannel := backend.channelId
  communicationChannel := backend.channelId

/-- Sequential composition of regions (`R1` then `R2`). -/
def sequentialCompose
    {backend : QTMQuantumBackend}
    (R1 R2 : SpacetimeRegionQTM backend) : SpacetimeRegionQTM backend where
  computationChannel := backend.channelCompose R2.computationChannel R1.computationChannel
  communicationChannel := backend.channelCompose R2.communicationChannel R1.communicationChannel

/-- Computation lane of composed region equals channel composition on states. -/
theorem sequentialCompose_computation_apply
    {backend : QTMQuantumBackend}
    (R1 R2 : SpacetimeRegionQTM backend) (rho : backend.State) :
    backend.applyChannel (sequentialCompose R1 R2).computationChannel rho =
      backend.applyChannel R2.computationChannel
        (backend.applyChannel R1.computationChannel rho) := by
  simpa [sequentialCompose] using
    backend.channelCompose_apply R2.computationChannel R1.computationChannel rho

/-- Communication lane of composed region equals channel composition on states. -/
theorem sequentialCompose_communication_apply
    {backend : QTMQuantumBackend}
    (R1 R2 : SpacetimeRegionQTM backend) (rho : backend.State) :
    backend.applyChannel (sequentialCompose R1 R2).communicationChannel rho =
      backend.applyChannel R2.communicationChannel
        (backend.applyChannel R1.communicationChannel rho) := by
  simpa [sequentialCompose] using
    backend.channelCompose_apply R2.communicationChannel R1.communicationChannel rho

/-- Left identity of sequential composition on the computation lane. -/
theorem sequentialCompose_left_identity_computation
    {backend : QTMQuantumBackend}
    (R : SpacetimeRegionQTM backend) (rho : backend.State) :
    backend.applyChannel (sequentialCompose (identityRegion backend) R).computationChannel rho =
      backend.applyChannel R.computationChannel rho := by
  have h := backend.channelCompose_apply R.computationChannel backend.channelId rho
  simpa [identityRegion, sequentialCompose, backend.channelId_apply rho] using h

/-- Right identity of sequential composition on the computation lane. -/
theorem sequentialCompose_right_identity_computation
    {backend : QTMQuantumBackend}
    (R : SpacetimeRegionQTM backend) (rho : backend.State) :
    backend.applyChannel (sequentialCompose R (identityRegion backend)).computationChannel rho =
      backend.applyChannel R.computationChannel rho := by
  have h := backend.channelCompose_apply backend.channelId R.computationChannel rho
  simpa [identityRegion, sequentialCompose,
    backend.channelId_apply (backend.applyChannel R.computationChannel rho)] using h

end CATEPTMain.CATEPT.CATEPT
