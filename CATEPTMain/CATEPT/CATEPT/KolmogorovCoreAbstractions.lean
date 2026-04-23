import CATEPTMain.CATEPT.CATEPT.QTMCoreAbstractions

set_option autoImplicit false

namespace CATEPTMain.CATEPT.CATEPT

/-- Kolmogorov-style complexity certificate over a QTM region. -/
structure QTMKolmogorovCert
    (backend : QTMQuantumBackend)
    (R : SpacetimeRegionQTM backend) where
  complexityOf : backend.State -> Nat
  computation_increases :
    forall rho : backend.State,
      complexityOf (backend.applyChannel R.computationChannel rho) >=
        complexityOf rho + 1
  communication_preserving :
    forall rho : backend.State,
      complexityOf (backend.applyChannel R.communicationChannel rho) >=
        complexityOf rho

/-- Strict increase implies nondecrease on the computation lane. -/
theorem QTMKolmogorovCert.computation_nondecreasing
    {backend : QTMQuantumBackend}
    {R : SpacetimeRegionQTM backend}
    (cert : QTMKolmogorovCert backend R)
    (rho : backend.State) :
    cert.complexityOf (backend.applyChannel R.computationChannel rho) >=
      cert.complexityOf rho := by
  exact le_trans (Nat.le_add_right (cert.complexityOf rho) 1)
    (cert.computation_increases rho)

/-- Complexity depth lower bound after `n` computation steps. -/
theorem applyCompN_complexity_ge_depth
    {backend : QTMQuantumBackend}
    {R : SpacetimeRegionQTM backend}
    (cert : QTMKolmogorovCert backend R)
    (n : Nat) (rho : backend.State) :
    cert.complexityOf (applyCompN R n rho) >= n := by
  induction n with
  | zero =>
      exact Nat.zero_le _
  | succ k ih =>
      have hstep :
          cert.complexityOf (applyCompN R (Nat.succ k) rho) >=
            cert.complexityOf (applyCompN R k rho) + 1 := by
        simpa [applyCompN] using cert.computation_increases (applyCompN R k rho)
      have hk : cert.complexityOf (applyCompN R k rho) + 1 >= k + 1 :=
        Nat.succ_le_succ ih
      exact le_trans hk hstep

/-- One rung of a Kolmogorov ladder at depth `n`. -/
structure KolmogorovLadderRung
    (backend : QTMQuantumBackend)
    (R : SpacetimeRegionQTM backend)
    (cert : QTMKolmogorovCert backend R)
    (n : Nat) where
  complexityFloor : Nat
  rungBound : forall rho : backend.State,
    cert.complexityOf (applyCompN R n rho) >= complexityFloor
  floorPositive : n <= complexityFloor

/-- Canonical rung: floor equals depth (`complexityFloor = n`). -/
def canonicalLadderRung
    {backend : QTMQuantumBackend}
    {R : SpacetimeRegionQTM backend}
    (cert : QTMKolmogorovCert backend R)
    (n : Nat) : KolmogorovLadderRung backend R cert n where
  complexityFloor := n
  rungBound := applyCompN_complexity_ge_depth cert n
  floorPositive := le_rfl

/-- Full ladder family indexed by depth. -/
structure KolmogorovLadder
    (backend : QTMQuantumBackend)
    (R : SpacetimeRegionQTM backend)
    (cert : QTMKolmogorovCert backend R) where
  rung : forall n : Nat, KolmogorovLadderRung backend R cert n
  monotone : forall m n : Nat, m <= n ->
    (rung m).complexityFloor <= (rung n).complexityFloor

/-- Canonical ladder induced by `canonicalLadderRung`. -/
def canonicalKolmogorovLadder
    {backend : QTMQuantumBackend}
    {R : SpacetimeRegionQTM backend}
    (cert : QTMKolmogorovCert backend R) :
    KolmogorovLadder backend R cert where
  rung := canonicalLadderRung cert
  monotone := by
    intro m n hmn
    simpa [canonicalLadderRung] using hmn

/-- Canonical rung bound viewed through the rung record. -/
theorem canonicalLadderRung_covers_depth
    {backend : QTMQuantumBackend}
    {R : SpacetimeRegionQTM backend}
    (cert : QTMKolmogorovCert backend R)
    (n : Nat) (rho : backend.State) :
    cert.complexityOf (applyCompN R n rho) >=
      (canonicalLadderRung cert n).complexityFloor := by
  simpa [canonicalLadderRung] using applyCompN_complexity_ge_depth cert n rho

end CATEPTMain.CATEPT.CATEPT
