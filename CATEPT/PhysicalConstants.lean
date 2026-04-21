import Mathlib.Data.Real.Basic

namespace CATEPT

/-- Shared physical constants used across CAT/EPT bridge modules. -/
structure PhysicalConstants where
  hbar : ℝ
  kB   : ℝ
  c    : ℝ
  hbar_pos : 0 < hbar
  kB_pos   : 0 < kB
  c_pos    : 0 < c

end CATEPT
