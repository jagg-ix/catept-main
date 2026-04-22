import CATEPTMain.CATEPT.LoopIntegrationReduction
import Mathlib.Data.Real.Basic
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic

namespace CATEPT

/-!
# Muon Anomalous Magnetic Moment ($a_\mu$)

This module implements the one-loop entropic calculation for the muon g-2 anomaly
from Paper 2: "Symmetry-Conserving Complex Action and Applications to Particle Physics".

The entropic contribution to $a_\mu$ is given by:
$$ a_\mu^{\Theta} = \frac{g_H^2 e^2}{8\pi^2 m_\mu^2} \int_0^1 dx\, x(1-x) \ln\frac{\Lambda^2}{m_\mu^2 x + m_\Theta^2(1-x)} $$
which simplifies for $m_\Theta \ll m_\mu$ to:
$$ a_\mu^{\Theta} \approx \frac{g_H^2}{96\pi^2}\ln\frac{\Lambda}{m_\mu} $$
-/

open Real

/-- The fermion-entropic coupling constant $g_H$. -/
opaque g_H : ℝ

/-- The entropic cutoff scale $\Lambda$ in MeV. -/
opaque Lambda_scale : ℝ

/-- The mass of the muon $m_\mu$ in MeV. -/
opaque m_mu : ℝ

/-- The mass of the entropic field $\Theta$. -/
opaque m_Theta : ℝ

/--
The elementary pseudoscalar entropic coupling vertex:
$V_{f\Theta} = -ig_f \gamma^\mu k_\mu$
-/
opaque EntropicVertex : DiracAlgebra

/--
The unreduced one-loop vertex correction integral from Paper 2:
$\Lambda^\mu_{\Theta} = -g_f^2 \int \frac{d^4k}{(2\pi)^4} \frac{\gamma_\nu k^\nu (\slashed{p}' - \slashed{k} + m_\mu)\gamma^\mu(\slashed{p} - \slashed{k} + m_\mu)\gamma_\rho k^\rho}{((p'-k)^2 - m_\mu^2)((p-k)^2 - m_\mu^2)(k^2 - m_\Theta^2)}$
-/
opaque MuonOneLoopVertexCorrection : DiracAlgebra

/--
The Passarino-Veltman reduced scalar integral integrand for the anomalous magnetic moment piece:
$\frac{g_H^2 e^2}{8\pi^2 m_\mu^2} \int_0^1 dx\, x(1-x) \ln\frac{\Lambda^2}{m_\mu^2 x + m_\Theta^2(1-x)}$
-/
noncomputable def a_mu_entropic_integrand (x e : ℝ) : ℝ :=
  let prefactor := (g_H^2 * e^2) / (8 * Real.pi^2 * m_mu^2)
  let log_arg := (Lambda_scale^2) / (m_mu^2 * x + m_Theta^2 * (1 - x))
  prefactor * x * (1 - x) * log log_arg

/--
The final simplified Gordon identity reduction for $a_\mu^{\Theta}$ assuming $m_\Theta \ll m_\mu$:
$a_\mu^{\Theta} \approx \frac{g_H^2}{96\pi^2}\ln\frac{\Lambda}{m_\mu}$
-/
noncomputable def a_mu_entropic_simplified : ℝ :=
  (g_H^2 / (96 * Real.pi^2)) * log (Lambda_scale / m_mu)

end CATEPT
