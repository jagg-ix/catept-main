import CATEPTMain.CATEPT.ElectromagnetismCoreAbstractions
import CATEPTMain.CATEPT.GravitasCoreBridge
import CATEPTMain.CATEPT.QEDCoreAbstractions
import CATEPTMain.CATEPT.QCDCoreAbstractions

set_option autoImplicit false

namespace CATEPTMain.CATEPT

/-- Aggregate witness covering EM, Gravitas, QED, and QCD core lanes. -/
structure FundamentalInteractionsCompatibilityWitness where
  electromagnetism : ElectromagnetismCompatibilityWitness
  gravitas : GravitasCompatibilityWitness
  qed : QEDCompatibilityWitness
  qcd : QCDCompatibilityWitness

def fundamentalInteractionsCompatibilityContract
    (w : FundamentalInteractionsCompatibilityWitness) : Prop :=
  electromagnetismCompatibilityContract w.electromagnetism ∧
    gravitasCompatibilityContract w.gravitas ∧
    qedCompatibilityContract w.qed ∧
    qcdCompatibilityContract w.qcd

theorem fundamentalInteractionsCompatibility_of_contract_fields
    (w : FundamentalInteractionsCompatibilityWitness)
    (hEM : electromagnetismCompatibilityContract w.electromagnetism)
    (hGr : gravitasCompatibilityContract w.gravitas)
    (hQED : qedCompatibilityContract w.qed)
    (hQCD : qcdCompatibilityContract w.qcd) :
    fundamentalInteractionsCompatibilityContract w :=
  ⟨hEM, hGr, hQED, hQCD⟩

end CATEPTMain.CATEPT
