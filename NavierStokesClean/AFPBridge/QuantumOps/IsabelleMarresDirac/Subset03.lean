import NavierStokesClean.AFPBridge.QuantumOps.IsabelleMarresDirac.SubsetDefs

/-!
# AFP Isabelle_Marries_Dirac → Lean4 Faithful Port — Subset 3
Theories: Quantum (continued), Deutsch_Jozsa (continued)
Theorems: 30 (indices 61–90)
Port date: 2026-04-07
Status: H_is_gate proved; iter_tensor gate-preservation delegated to SubsetDefs;
        all_zero_state proved; Deutsch_Jozsa circuit theorems scaffolded (needs_human)

Key: `kron` and `iter_tensor` defined in SubsetDefs unblock this subset.
-/

open NavierStokesClean.AFPBridge.QuantumOps.IsabelleMarresDirac
open IMD

namespace NavierStokesClean.AFPBridge.QuantumOps.IsabelleMarresDirac.Subset03

-- ===== Quantum: H is a gate =====

-- AFP: H_is_gate — Hadamard is a 1-qubit unitary gate  (✓)
-- Proof: H * H† = I; diagonal entries via field_simp + Real.sq_sqrt; off-diagonal by simp
-- AFP: Isabelle_Marries_Dirac.Quantum.H_is_gate#1
theorem H_is_gate : IMD.QGate 1 IMD.H_gate := by
  rw [IMD.QGate, Matrix.mem_unitaryGroup_iff]
  have hsqrt_ne : (Real.sqrt 2 : ℂ) ≠ 0 :=
    Complex.ofReal_ne_zero.mpr (Real.sqrt_pos.mpr (by norm_num)).ne'
  have hsq : (Real.sqrt 2 : ℂ)^2 = 2 := by norm_cast; exact Real.sq_sqrt (by norm_num)
  ext i j
  fin_cases i <;> fin_cases j
  all_goals simp [IMD.H_gate, Matrix.mul_apply, Matrix.conjTranspose_apply, Finset.univ_fin2]
  all_goals push_cast
  all_goals (try { field_simp [hsqrt_ne]; rw [hsq]; norm_num })
  all_goals ring

-- AFP: iter_tensor_H_n_is_gate — H⊗^n is an n-qubit gate
-- AFP: Isabelle_Marries_Dirac.Quantum.iter_tensor_of_H_is_gate#1
theorem iter_tensor_H_n_is_gate (n : ℕ) : IMD.QGate n (IMD.iter_tensor IMD.H_gate n) :=
  IMD.iter_tensor_of_H_is_gate n

-- AFP: tensor_is_gate — Kronecker product of two qubit-gates is a gate
-- AFP: Isabelle_Marries_Dirac.Quantum.tensor_is_gate#1
theorem tensor_is_gate (a b : ℕ)
    (A : Matrix (Fin (2^a)) (Fin (2^a)) ℂ) (B : Matrix (Fin (2^b)) (Fin (2^b)) ℂ)
    (hA : IMD.QGate a A) (hB : IMD.QGate b B) :
    IMD.QGate (a + b)
      (Matrix.reindex
        (finCongr (show 2^a * 2^b = 2^(a + b) by ring))
        (finCongr (show 2^a * 2^b = 2^(a + b) by ring))
        (IMD.kron A B)) :=
  IMD.kron_is_gate a b A B hA hB

-- ===== Quantum: n-qubit all-zero state =====

-- n-qubit all-zero state |0...0⟩ (standard basis vector e_0)
noncomputable def ket_zero_n (n : ℕ) : Matrix (Fin (2^n)) (Fin 1) ℂ :=
  Matrix.single ⟨0, pow_pos (show 0 < 2 by norm_num) n⟩ 0 1

-- AFP: all_zero_state — |0...0⟩ is a valid n-qubit state  (✓)
-- AFP: Isabelle_Marries_Dirac.Quantum.all_zero_state#1
theorem all_zero_state (n : ℕ) : IMD.QState n (ket_zero_n n) := by
  simp only [IMD.QState]
  have key : ∀ i : Fin (2^n), Complex.normSq (ket_zero_n n i 0) =
      if i = ⟨0, pow_pos (show 0 < 2 by norm_num) n⟩ then 1 else 0 := by
    intro i
    simp [ket_zero_n, Matrix.single, Matrix.of_apply, Complex.normSq_one, Complex.normSq_zero,
          eq_comm, and_iff_left_iff_imp, Fin.mk.injEq]
  simp_rw [key, Finset.sum_ite_eq', Finset.mem_univ, if_true]

-- ===== Deutsch_Jozsa: algorithm theorems =====
-- AFP indices 65-90: Deutsch_Jozsa circuit correctness
-- All require:
--   • Oracle U_f: runtime matrix from f (needs runtime-dim matrix construction from Boolean f)
--   • H⊗^n |0⟩^n: uniform superposition (iter_tensor now available via iter_tensor_H_n_is_gate)
--   • Measurement: Born rule probability computation (norm-squared of amplitudes)
-- Status: needs_human — oracle U_f construction deferred

-- AFP: is_balanced_card — |f⁻¹(0)| = |f⁻¹(1)| = 2^(n-1) for balanced f on {0,..,2^n-1}
-- AFP: Isabelle_Marries_Dirac.Deutsch_Jozsa.is_balanced_card#1
-- needs_human: requires locale cardinality axioms about balanced f
-- theorem is_balanced_card ...

-- AFP: deutsch_jozsa_correct — measurement gives all-zero register iff f is constant
-- AFP: Isabelle_Marries_Dirac.Deutsch_Jozsa.deutsch_jozsa_correct#1
-- needs_human: full circuit simulation with oracle + Born rule measurement
-- theorem deutsch_jozsa_correct ...

end NavierStokesClean.AFPBridge.QuantumOps.IsabelleMarresDirac.Subset03
