import Mathlib
set_option autoImplicit true

-- Opaque with explicit universe polymorphism
noncomputable opaque sum_vvv {α β γ : Type*} : α → β → γ
noncomputable opaque continuous_vvv_p {α : Type*} : α → Prop

theorem sum_vvv_cont : continuous_vvv_p (sum_vvv ffvc ggvc) := by sorry
theorem sum_vvv_cont2 : ¬continuous_vvv_p (sum_vvv ffvc ggvc) := by sorry
theorem sum_vvv_cont3 : continuous_vvv_p (sum_vvv ffvc ggvc) ∨ continuous_vvv_p (sum_vvv hhvc kk) := by sorry
