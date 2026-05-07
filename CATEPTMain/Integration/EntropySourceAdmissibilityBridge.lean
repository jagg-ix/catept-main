import CATEPTMain.Integration.LocalFisherEntropicGeneratorBridge
import CATEPTMain.Integration.EuclideanFeynmanKacAdmissibility
import Mathlib.MeasureTheory.Integral.IntervalIntegral.Basic
import Mathlib.Tactic.Linarith

set_option autoImplicit false

/-!
# Entropy-source admissibility (KMS / Petz / Fisher)

Classifies when each entropy source is admissible as a nonnegative
rate for Euclidean killing or Lorentzian damping.
-/

namespace CATEPTMain.Integration.EntropySourceAdmissibilityBridge

noncomputable section

open CATEPTMain.Integration.LocalFisherEntropicGeneratorBridge
open CATEPTMain.Integration.EuclideanFeynmanKacAdmissibility
open MeasureTheory

/-- KMS thermal rate `lambda_kms = kB * T / hbar`. -/
structure KMSThermalRate where
  kB : ℝ
  T : ℝ
  hbar : ℝ
  kB_nonneg : 0 ≤ kB
  T_nonneg : 0 ≤ T
  hbar_pos : 0 < hbar

namespace KMSThermalRate

/-- KMS rate value. -/
def value (K : KMSThermalRate) : ℝ :=
  K.kB * K.T / K.hbar

/-- KMS rate is nonnegative for `T ≥ 0`. -/
theorem value_nonneg (K : KMSThermalRate) : 0 ≤ K.value := by
  unfold value
  have hmul : 0 ≤ K.kB * K.T := mul_nonneg K.kB_nonneg K.T_nonneg
  exact div_nonneg hmul (le_of_lt K.hbar_pos)

end KMSThermalRate

/-- Petz-information rate `lambda_petz = c_alpha * dI_dt`. -/
structure PetzInformationRate where
  c_alpha : ℝ
  dI_dt : ℝ

namespace PetzInformationRate

/-- Petz rate value. -/
def value (P : PetzInformationRate) : ℝ :=
  P.c_alpha * P.dI_dt

/-- Petz rate is nonnegative when `c_alpha ≥ 0` and `dI_dt ≥ 0`. -/
theorem value_nonneg
    (P : PetzInformationRate) (hc : 0 ≤ P.c_alpha) (hI : 0 ≤ P.dI_dt) :
    0 ≤ P.value := by
  unfold value
  exact mul_nonneg hc hI

/-- Positive/negative split of a Petz rate. -/
structure Split where
  pos : ℝ
  neg : ℝ
  pos_nonneg : 0 ≤ pos
  neg_nonneg : 0 ≤ neg
  recombine : value P = pos - neg

end PetzInformationRate

/-- Fisher admissibility: the local Fisher rate is nonnegative. -/
theorem fisher_rate_admissible (L : LocalFisherRate) : 0 ≤ L.value :=
  LocalFisherRate.value_nonneg L

/-- Build an Euclidean-admissible constant rate from a three-component rate. -/
def euclideanAdmissibleFromThreeComponentRate
    (R : ThreeComponentRate)
    (hInt : ∀ a b : ℝ,
      IntervalIntegrable (fun _ => R.total) MeasureTheory.volume a b) :
    EuclideanAdmissibleRate :=
  { rate := fun _ => R.total
  , rate_nonneg := fun _ => R.total_nonneg
  , rate_integrable := hInt }

-- --------------------------------------------------------------------
-- Reply 16: admissibility classification skeleton (KMS / Petz / Fisher)
-- --------------------------------------------------------------------

/-- Admissibility carrier for a single entropy source. -/
structure EntropySource where
  rate : ℝ
  nonnegative : Prop
  localMarkov : Prop
  scalarDensityCompatible : Prop
  admitsEuclideanKilling : Prop
  admitsLorentzianDamping : Prop
  requiresSK : Prop

/-- KMS source: admissible if temperature is nonnegative. -/
def KMS_Source (kB T hbar : ℝ) : EntropySource :=
  { rate := kB * T / hbar
  , nonnegative := 0 ≤ T ∧ 0 < hbar ∧ 0 < kB
  , localMarkov := True
  , scalarDensityCompatible := True
  , admitsEuclideanKilling := 0 ≤ T
  , admitsLorentzianDamping := 0 ≤ T
  , requiresSK := False }

/-- Petz source: sign-sensitive information-flow rate. -/
def Petz_Source (c_alpha dI_dt : ℝ) : EntropySource :=
  { rate := c_alpha * dI_dt
  , nonnegative := 0 ≤ c_alpha * dI_dt
  , localMarkov := False
  , scalarDensityCompatible := True
  , admitsEuclideanKilling := 0 ≤ c_alpha * dI_dt
  , admitsLorentzianDamping := 0 ≤ c_alpha * dI_dt
  , requiresSK := c_alpha * dI_dt < 0 }

/-- Fisher source: admissible if eta >= 0 and Fisher density >= 0. -/
def Fisher_Source (eta hbar I_F : ℝ) : EntropySource :=
  { rate := eta / hbar * I_F
  , nonnegative := 0 ≤ eta ∧ 0 < hbar ∧ 0 ≤ I_F
  , localMarkov := True
  , scalarDensityCompatible := True
  , admitsEuclideanKilling := 0 ≤ eta ∧ 0 < hbar ∧ 0 ≤ I_F
  , admitsLorentzianDamping := 0 ≤ eta ∧ 0 < hbar ∧ 0 ≤ I_F
  , requiresSK := False }

theorem fisher_source_admissible
    (eta hbar I_F : ℝ)
    (h_eta : 0 ≤ eta)
    (h_hbar : 0 < hbar)
    (h_IF : 0 ≤ I_F) :
    (Fisher_Source eta hbar I_F).admitsEuclideanKilling := by
  exact And.intro h_eta (And.intro h_hbar h_IF)

end

end CATEPTMain.Integration.EntropySourceAdmissibilityBridge
