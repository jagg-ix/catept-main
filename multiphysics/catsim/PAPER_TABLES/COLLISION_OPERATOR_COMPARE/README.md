# COLLISION_OPERATOR_COMPARE (Phase 4D)

This folder contains a **relaxation-time (RTA) proxy** comparison that connects the time-domain decay
extracted from Fig_2g to a collision-operator rate layer.

- From each time-domain trace we extract a decay constant \(	au_{decay}(S)\) and define
  \(eta_{eff}(S)=1/	au_{decay}(S)\).
- In the simplest relaxation-time approximation (RTA) to a linear Boltzmann collision operator,
  the collision frequency \(
u\) acts as a single exponential relaxation rate. The proxy mapping is
  \(
u_{RTA}(S)=eta_{eff}(S)\).

We also record the CAT/EPT **coherence decay** rate \(\lambda_{ent}\) from the spectral calibration
(Phase 4C) for side-by-side comparison.

## Tool summaries
- median decay tau (fs): 396.085
- median beta_eff (1/s): 2.524709e+12
- lambda_ent from spectral fit (1/s): 1525423728813.5593

**Note:** This is not a full collision integral (kernel) implementation. It provides the rate layer
needed to compare to a collision-operator picture (e.g., Saveliev-style linear Boltzmann operators)
without over-claiming details that are not encoded in the dataset.
