import CATEPTMain.Certification.RelativityGR

open CATEPTMain.Certification.RelativityGR
open Gravitas

theorem full_hodge_claim_test :
    hodgeDualEM (hodgeDualEM gravitasFaradayMinkowski) = gravitasFaradayMinkowski := by
  rfl
