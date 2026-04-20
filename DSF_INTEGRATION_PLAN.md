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