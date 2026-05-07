import Mathlib.Data.Finset.Basic
import CATEPTMain.GaugeTheory.FEYNCALC.LorentzAlgebra
import CATEPTMain.GaugeTheory.FEYNCALC.FCPrelude

set_option autoImplicit false

/-!
# Lorentz-invariant kinematics carriers

Defines basic invariant carriers (Mandelstam, Gram, tr5) in terms of the
FEYNCALC Lorentz product and Levi-Civita tensor.
-/

namespace CATEPTMain.Integration.LorentzInvariantInvariants

noncomputable section

open CATEPTMain.GaugeTheory.FEYNCALC

/-- Four-momentum carrier aligned with FEYNCALC indexing. -/
abbrev FourMomentum : Type := FCIdx → ℝ

/-- Mandelstam `s = (p1 + p2)^2`. -/
def mandelstamS (p1 p2 : FourMomentum) : ℝ :=
  lorentzProduct (fun μ => p1 μ + p2 μ) (fun μ => p1 μ + p2 μ)

/-- Mandelstam `t = (p1 - p3)^2`. -/
def mandelstamT (p1 p3 : FourMomentum) : ℝ :=
  lorentzProduct (fun μ => p1 μ - p3 μ) (fun μ => p1 μ - p3 μ)

/-- Mandelstam `u = (p1 - p4)^2`. -/
def mandelstamU (p1 p4 : FourMomentum) : ℝ :=
  lorentzProduct (fun μ => p1 μ - p4 μ) (fun μ => p1 μ - p4 μ)

/-- 2x2 Gram determinant from Lorentz products. -/
def gramDet2 (p q : FourMomentum) : ℝ :=
  lorentzProduct p p * lorentzProduct q q - (lorentzProduct p q) ^ 2

/-- tr5-style Levi-Civita contraction of four momenta (real carrier). -/
def tr5 (p1 p2 p3 p4 : FourMomentum) : ℝ :=
  (Finset.univ (α := FCIdx)).sum (fun μ =>
    (Finset.univ (α := FCIdx)).sum (fun ν =>
      (Finset.univ (α := FCIdx)).sum (fun ρ =>
        (Finset.univ (α := FCIdx)).sum (fun σ =>
          leviCivita μ ν ρ σ * p1 μ * p2 ν * p3 ρ * p4 σ))))

/-- Sigma5 carrier with primary/alternate polynomial forms. -/
structure Sigma5Carrier where
  primary : ℝ
  alternate : ℝ

/-- The primary Sigma5 value. -/
def sigma5 (s : Sigma5Carrier) : ℝ := s.primary

/-- Alternate Sigma5 polynomial form. -/
def sigma5Alt (s : Sigma5Carrier) : ℝ := s.alternate

/-- Claim that the primary and alternate Sigma5 forms agree. -/
def sigma5Identity (s : Sigma5Carrier) : Prop := sigma5 s = sigma5Alt s

theorem sigma5Identity_same (x : ℝ) : sigma5Identity ⟨x, x⟩ := rfl

end

end CATEPTMain.Integration.LorentzInvariantInvariants
