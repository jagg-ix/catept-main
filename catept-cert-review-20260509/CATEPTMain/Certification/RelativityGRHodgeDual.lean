import CATEPTMain.Certification.RelativityGR

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.RelativityGR

open Gravitas
open CATEPTMain.Integration.GravitasBridge

/-- A symbolic expression with an explicit sign bit.
Keeping sign separate avoids nested constructor terms like `Expr.neg (Expr.neg e)`
when composing linear operators such as the Hodge dual twice. -/
structure SignedExpr where
  sign : Bool
  payload : Expr
  deriving Repr, Inhabited

namespace SignedExpr

/-- Embed an unsigned symbolic expression. -/
def ofExpr (e : Expr) : SignedExpr :=
  { sign := false, payload := e }

/-- Flip the sign bit. -/
def negate (s : SignedExpr) : SignedExpr :=
  { s with sign := !s.sign }

/-- Materialize the sign bit back into an expression. -/
def eval (s : SignedExpr) : Expr :=
  if s.sign then Expr.neg s.payload else s.payload

@[simp] theorem negate_negate (s : SignedExpr) : negate (negate s) = s := by
  cases s
  simp [negate]

end SignedExpr

/-- 4D electromagnetic 2-form represented by its six independent components:
`F01, F02, F03, F12, F13, F23`. -/
structure Bivector4 where
  f01 : SignedExpr
  f02 : SignedExpr
  f03 : SignedExpr
  f12 : SignedExpr
  f13 : SignedExpr
  f23 : SignedExpr
  deriving Repr, Inhabited

namespace Bivector4

/-- Extract the six independent components from an electromagnetic tensor. -/
def ofElectromagneticTensor (F : ElectromagneticTensor) : Bivector4 where
  f01 := SignedExpr.ofExpr (matGet F.components 0 1)
  f02 := SignedExpr.ofExpr (matGet F.components 0 2)
  f03 := SignedExpr.ofExpr (matGet F.components 0 3)
  f12 := SignedExpr.ofExpr (matGet F.components 1 2)
  f13 := SignedExpr.ofExpr (matGet F.components 1 3)
  f23 := SignedExpr.ofExpr (matGet F.components 2 3)

/-- Kernel-transparent Hodge star on 2-forms in 4D, encoded on bivector
components with explicit sign bits. -/
def hodgeStar (F : Bivector4) : Bivector4 where
  f01 := F.f23
  f02 := SignedExpr.negate F.f13
  f03 := F.f12
  f12 := F.f03
  f13 := SignedExpr.negate F.f02
  f23 := F.f01

/-- `★★F = F` at the bivector level. -/
@[simp] theorem hodgeStar_involutive (F : Bivector4) :
    hodgeStar (hodgeStar F) = F := by
  cases F
  simp [hodgeStar, SignedExpr.negate_negate]

end Bivector4

/-- The canonical Gravitas Faraday tensor viewed as a six-component bivector. -/
def gravitasFaradayBivector : Bivector4 :=
  Bivector4.ofElectromagneticTensor gravitasFaradayMinkowski

/-- Concrete `★★F = F` certificate for the canonical Gravitas Faraday tensor,
in a kernel-transparent bivector representation. -/
theorem gravitasFaraday_hodgeStar_involutive :
    Bivector4.hodgeStar (Bivector4.hodgeStar gravitasFaradayBivector) =
      gravitasFaradayBivector := by
  simp [gravitasFaradayBivector]

end CATEPTMain.Certification.RelativityGR

end
