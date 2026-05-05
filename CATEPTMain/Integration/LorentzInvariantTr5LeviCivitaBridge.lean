import CATEPTMain.Integration.LorentzInvariantInvariants

set_option autoImplicit false

/-!
# tr5 / Levi-Civita bridge

Provides the explicit Levi-Civita expansion of `tr5` as a named lemma.
-/-

namespace CATEPTMain.Integration.LorentzInvariantTr5LeviCivitaBridge

noncomputable section

open CATEPTMain.GaugeTheory.FEYNCALC
open CATEPTMain.Integration.LorentzInvariantInvariants

/-- Expanded Levi-Civita form of `tr5`. -/
theorem tr5_eq_leviCivita_sum (p1 p2 p3 p4 : FourMomentum) :
    tr5 p1 p2 p3 p4 =
      (Finset.univ (α := FCIdx)).sum (fun μ =>
        (Finset.univ (α := FCIdx)).sum (fun ν =>
          (Finset.univ (α := FCIdx)).sum (fun ρ =>
            (Finset.univ (α := FCIdx)).sum (fun σ =>
              leviCivita μ ν ρ σ * p1 μ * p2 ν * p3 ρ * p4 σ)))) :=
  rfl

end

end CATEPTMain.Integration.LorentzInvariantTr5LeviCivitaBridge
