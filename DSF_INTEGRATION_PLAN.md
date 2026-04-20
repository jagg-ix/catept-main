# DSF Legacy Equation Integration Plan

This document tracks the integration of legacy `DSF` (Dual Sphere Fiber), holographic, and measurement equations extracted from historical chat artifacts (e.g. `mie_qcf_dsf.lean` and `dsf_orbit_rg.lean`) into the active rigorous `NavierStokesClean/CATEPT` framework.

These implementations target closing the remaining mathematical gaps (such as the spatial 1/2-derivative gap) by mapping fluid mechanics explicitly to thermodynamic geometry and refractive holographic metrics.

## Target 1: Thermodynamic Measurement Geometry
* **Source:** `mie_qcf_dsf.lean` (`thermoMetric`, `thermodynamicLength`)
* **Goal:** Implement the dynamic thermodynamic metric $g_{\text{thermo}} = (\Omega^2) \cdot \text{Hessian}(E_{\text{int}}(T, S))$ where $\Omega = n \cdot \rho$.
* **Application:** Relate the thermodynamic path-length to the `entropicProperTime` integral. This bounds spatial variations via thermodynamic phase-space distances.
* **Target Destination:** `NavierStokesClean/CATEPT/External/DSFThermoMetric.lean`

## Target 2: Holographic Refractive Metric (DSF Optical Analogy)
* **Source:** `mie_qcf_dsf.lean` (`n_squared_dyn`, `g_ij`)
* **Goal:** Model spatial metric structure $g_{ij}$ as an effective refractive index $n_{\text{dyn}}^2(Field) = \lambda_A \cdot (\Delta x)^2 + \lambda_B$.
* **Application:** Use the refractive gradient $n_{\text{dyn}}^2$ shaped by the entropy field to close the **spatial open sector** (the 1/2-derivative gap). The field state provides the effective isotropic metric.
* **Target Destination:** `NavierStokesClean/CATEPT/External/DSFRefractiveMetric.lean`

## Target 3: Emergent Time from Weyl-Symbols & Spin Networks
* **Source:** `mie_qcf_dsf.lean` (`EmergentTimeFromCurvature`, `emergentTimeSymbol`)
* **Goal:** Map the local Entropy Field ($\mathbb{R} \to \mathbb{R}$) directly to a Weyl Symbol via `computeLocalClockFromEntropy(x, p)`.
* **Application:** Perform the specific "Entanglement Action Bijection" mechanically for variables in spin networks. Formalize $\theta_W(e) = \text{Arg}(\text{complexTracedHolonomy}(e))$.
* **Target Destination:** `NavierStokesClean/CATEPT/External/DSFWeylTime.lean`

## Target 4: Renormalization Group (RG) Orbit Flow Path
* **Source:** `dsf_orbit_rg.lean`
* **Goal:** Transform the placeholder RG flow Beta function ($\beta(\mu) = \mu \log(1 + \mu^2)$) into the physical rate for Coadjoint Orbits.
* **Application:** Insert the actual enstrophy dissipation rate `(-2ν * P)` bounds we proved from `NavierStokes/NSVorticityCoadjointBridge.lean`. Frame it functionally so that states flow algebraically to regular states via standard analytical tools.
* **Target Destination:** `NavierStokesClean/CATEPT/External/DSFOrbitRGFlow.lean`

## Implementation Status
* **Target 1:** Completed in `NavierStokesClean/CATEPT/External/DSFThermoMetric.lean`
* **Target 2:** Completed in `NavierStokesClean/CATEPT/External/DSFRefractiveMetric.lean`
* **Target 3:** Completed in `NavierStokesClean/CATEPT/External/DSFWeylTime.lean`
* **Target 4:** Completed in `NavierStokesClean/CATEPT/External/DSFOrbitRGFlow.lean`

## Integration Wiring
* Added DSF imports to `NavierStokesClean/CATEPT/External/OptInSurface.lean`:
	* `NavierStokesClean.CATEPT.External.DSFThermoMetric`
	* `NavierStokesClean.CATEPT.External.DSFRefractiveMetric`
	* `NavierStokesClean.CATEPT.External.DSFWeylTime`
	* `NavierStokesClean.CATEPT.External.DSFOrbitRGFlow`
* Added dedicated narrow import surface:
	* `NavierStokesClean/CATEPT/External/DSFOptInSurface.lean`

## Validation Snapshot
* `lake env lean NavierStokesClean/CATEPT/External/DSFThermoMetric.lean` : pass
* `lake env lean NavierStokesClean/CATEPT/External/DSFRefractiveMetric.lean` : pass
* `lake env lean NavierStokesClean/CATEPT/External/DSFWeylTime.lean` : pass
* `lake env lean NavierStokesClean/CATEPT/External/DSFOrbitRGFlow.lean` : pass
* `lake build NavierStokesClean.CATEPT.External.DSFOptInSurface` : pass
* `lake build NavierStokesClean.CATEPT.External.OptInSurface` : pass

## External Build Chain Status
The previous external dependency blocker is now resolved in this workspace.

The following integration-path blockers were removed during validation:
* Missing `spectralPhysics` manifest entry (resolved with `lake update spectralPhysics`)
* PhysLean/Physlib import path mismatch in Div-Curl bridge files
* Curl notation mismatch (`×` vs Physlib's `⨯`) across Bianchi compatibility layers

Current status:
* DSF-only import surface (`DSFOptInSurface`) builds successfully
* Global external opt-in surface (`OptInSurface`) builds successfully

## Target 5: Leverage Lean-QuantumInfo for Thermodynamic & Holographic Distances
* **Source:** `/Users/macbookpro/lab/tau/tau-information-dynamics/Lean-QuantumInfo`
* **Goal:** Directly connect the thermodynamic metric and emergent time variables to foundational quantum information structures (Entropy, Entanglement, and Channels).
* **Integration Nodes:**
   1. **`ArakiRelativeEntropyBridge.lean`:** Import `QuantumInfo.Finite.Entropy.Relative` and `QuantumInfo.Finite.Entropy.DPI` (Data Processing Inequality). Replace axiomatic Araki relative entropy with exact algebraic forms of $S(\rho || \sigma) = \text{Tr}(\rho(\log\rho - \log\sigma))$. This closes the entropy generation bounds exactly.
   2. **`DSFThermoMetric.lean` (Target 1 further rigor):** Map the fluid element distance to the Bures / Trace Distance via `QuantumInfo.Finite.Distance.TraceDistance`.
   3. **`DSFOrbitRGFlow.lean` (Target 4 further rigor):** Model viscous enstrophy dissipation as a Completely Positive Trace-Preserving Map (`QuantumInfo.Finite.CPTPMap`). Dissipation formally reduces to contractivity under CPTP mapping, yielding topological zero-viscosity bounds via Strong Subadditivity (`QuantumInfo.Finite.Entropy.SSA`).
   4. **`DSFWeylTime.lean` (Target 3 further rigor):** Represent the entanglement entropy responsible for "emergent physical time" via structural Von Neumann formulations in `QuantumInfo.Finite.Entropy.VonNeumann`.
## Target 6: Spinor Path Integral & Eigenstate Thermalization Hypothesis (ETH) Bridge
* **Source:** `$HOME/Downloads/eth2.md`
* **Goal:** Map the proposed relativistic spinor path integral $K_R = \hat R \sum e^{i S_R/\hbar}$ into the CAT/EPT framework's entropy-damped path integral $\sum e^{i S_R/\hbar - S_I/\hbar}$. Formalize the Eigenstate Thermalization Hypothesis (ETH) within CAT/EPT.
* **Integration Nodes:**
   1. **Operator-Valued Entropy:** Reinterpret the spinor path integral's prefactor $\hat R$ as the exponentiated imaginary action/entropy sector $e^{-S_I/\hbar}$ in CAT/EPT. Investigate if the imaginary sector survives as a correction to Dirac evolution or vanishes in the single-particle limit.
   2. **Thermalization Criterion (`thermalizationCriterion`):** Formalize the statement that macroscopic thermalization occurs when entropic corrections (e.g. $e^{-\tau_{\text{ent}}}\epsilon \to 0$) and off-diagonal coherences ($O_{ij} \to 0$) vanish. This dictates that `longTimeShellObservable = diagonalThermalContribution`.
   3. **Origin of Spin and Nonlocality:** Test whether the \(\beta\)-coupled structure is genuinely explanatory of spin or just Clifford packaging, and map path-integral nonlocality to entropic proper-time coupling.
   4. **Target Destination:** `NavierStokesClean/CATEPT/External/ETHSpinorBridge.lean`

## Target 7: Open-System Quantum Gravity Path Integral & $\alpha$-Divergence Bridge
* **Source:** `$HOME/Downloads/ChatGPT-Mathematica_Code_Extraction (3).md`
* **Goal:** Formalize the quantum-gravitational path integral as an open-system extension, substituting the standard phase weight with an $\alpha$-divergence dampened imaginary action: $Z = \int \mathcal{D}\Phi \exp(\frac{i}{\hbar} S_R[\Phi] - \frac{1}{\hbar} S_I[\Phi])$.
* **Integration Nodes:**
   1. **Total Partition Functional ($Z_{\text{tot}}$):** Implement the symbolic functional integrating over $\{g, A, \psi, \bar\psi\}$ combining the Einstein-Hilbert + QCD real action ($S_R$) with the information/entropy functional ($S_I$).
   2. **Jenčová/Petz $\alpha$-Divergence ($S_I$):** Define the imaginary action explicitly as $S_I = \kappa D_\alpha(\phi || \phi_0)$, where $D_\alpha$ is the Petz/Jenčová divergence depending on the modular operator $\mathcal{M}_{1-\alpha}(\phi, \phi_0)$. Connect this strictly to the von Neumann algebra and density matrix logic in `Lean-QuantumInfo`.
   3. **Entropic Proper Time ($\tau_{\text{ent}}$):** Formalize the relationship $\tau_{\text{ent}} = S_I/\hbar$ as the effective clock variable for open quantum dynamics, validating its scale and testing how minimizing $S_I$ (minimal entropy production) mathematically recovers the geodesic motion and Einstein Equivalence Principle (EEP).
   4. **Target Destination:** `NavierStokesClean/CATEPT/External/QGAlphaDivergenceBridge.lean`

## Target 8: Variational Rate Functional & Boué-Dupuis Shell Schema
* **Source:** `$HOME/Downloads/ChatGPT-Mathematica_Code_Extraction (3).md` (Last 40%)
* **Goal:** Exactly derive $\tau_{\text{ent}}(E) \approx S_{\text{eff}}(E)$ utilizing the Euclidean free-energy variational representation, formalizing the identity string $\tau_{\text{ent}}(E) \leftrightarrow \mathcal{I}_{\text{BD}}(E) \leftrightarrow S_{\text{eff}}(E)$.
* **Integration Nodes:**
   1. **Definition of Effective Shell Functional ($\mathcal{I}_{\text{BD}}$):** Instantiate the rate functional mapping strictly as the Boué-Dupuis-type variational formulation: $\mathcal{I}_{\text{BD}}(E) = \inf_{v \in \mathcal{A}(E)} \mathbb{E}\left[V_T(\text{shiftedField}(v)) + \text{controlCost}(v)\right]$.
   2. **Euclidean Variational Instantiation:** Bridge the shell-restricted variational infimum directly from the pressure / expected value formulas associated with macroscopic large-deviation limits.
   3. **ETH Formal Mapping:** Validate `tauEqBoueDupuis_is_euclidean` and map it logically so that $O_{ij} = e^{-\tau_{\text{ent}}(E_i,E_j)/2} f(E_i, E_j)R_{ij}$ resolves properly under $e^{-\mathcal{I}(E)}$, securing the full ETH equivalence.
   4. **Target Destination:** `NavierStokesClean/CATEPT/External/ETHBoueDupuisRateBridge.lean`
