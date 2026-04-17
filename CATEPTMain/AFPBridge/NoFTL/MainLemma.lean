import CATEPTMain.AFPBridge.NoFTL.NoFTLPrelude
set_option autoImplicit true

namespace AFPIsabellePilot.MainLemma

/-!
Auto-generated theorem-indexed pilot file.
Theory: MainLemma
Theorem id: No_FTL_observers_Gen_Rel.MainLemma.lemMainLemmaBasic#1
Theorem name: lemMainLemmaBasic
Lean tactic class: arithmetic_norm_num
-/

theorem lemMainLemmaBasic (tangentLine : NoFTLSet → NoFTLSet → NoFTLObj → Prop) (l' : NoFTLSet) (f : NoFTLObj) (wl : NoFTLSet) (origin : NoFTLObj) (tgt : tangentLine l wl origin) (injf : injective f) (affapp : affineApprox A f origin) (f00 : f origin = origin) (ctsf'0 : cts (invFunc f) origin) (affline : applyAffineToLine A l l') : tangentLine l' (applyToSet f wl) origin := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: MainLemma
Theorem id: No_FTL_observers_Gen_Rel.MainLemma.lemMainLemmaOrigin#1
Theorem name: lemMainLemmaOrigin
Lean tactic class: arithmetic_norm_num
-/

theorem lemMainLemmaOrigin (tangentLine : NoFTLSet → NoFTLSet → NoFTLObj → Prop) (l' : NoFTLSet) (f : NoFTLObj) (wl : NoFTLSet) (origin : NoFTLObj) (tgtx : tangentLine l wl x) (injf : injective f) (affappx : affineApprox A f x) (fx0 : f x = origin) (ctsf'0 : cts (invFunc f) origin) (affline : applyAffineToLine A l l') : tangentLine l' (applyToSet f wl) origin := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: MainLemma
Theorem id: No_FTL_observers_Gen_Rel.MainLemma.lemMainLemma#1
Theorem name: lemMainLemma
Lean tactic class: arithmetic_norm_num
-/

theorem lemMainLemma (tangentLine : NoFTLSet → NoFTLSet → NoFTLObj → Prop) (l' : NoFTLSet) (f : NoFTLObj) (wl : NoFTLSet) (y : NoFTLObj) (tgtx : tangentLine l wl x) (injf : injective f) (affappx : affineApprox A f x) (fxy : f x = y) (ctsf'y : cts (invFunc f) y) (affline : applyAffineToLine A l l') : tangentLine l' (applyToSet f wl) y := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry

end AFPIsabellePilot.MainLemma
