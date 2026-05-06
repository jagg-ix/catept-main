# Theorem inventory for `feat/publication` curation

48 theorems audited:

- **Pool A — currently on `feat/publication`**: 24 theorems across 6 files.
- **Pool B — substance candidates on `public/main`**: 24 theorems audited by `scripts/verify/{07,08,09,10}_*.sh`.

For each: file, line, statement (one-liner), and the full proof body verbatim. Verdicts are in `VERDICTS.md`.

> **Caveat**: this inventory captures the *outermost* proof body only. A theorem flagged BUNDLING here may delegate to a helper lemma whose body is substantive. Reviewing those helpers is a follow-up — see worklog task `catept_pub_classify_20260505`.

---

## Pool A — currently on `feat/publication` (24 theorems)

### `CATEPT/Bridges/GR.lean`

#### A1. `schwarzschild_f_pos` (L41)

```lean
theorem schwarzschild_f_pos (s : SchwarzschildExterior) :
    0 < schwarzschild_f s.M s.r :=
  eq046_schwarzschild_positive s.M s.r s.M_pos s.r_gt_horizon
```

#### A2. `bh_entropy_pos` (L54)

```lean
theorem bh_entropy_pos (b : BHMass) :
    0 < bekenstein_hawking_entropy b.G b.M :=
  eq147_152_bh_entropy_positive b.G b.M b.G_pos b.M_pos
```

#### A3. `tauEnt_eq_div` (L68)

```lean
theorem tauEnt_eq_div (a : ADMInput) (ℏ : ℝ) (hℏ : 0 < ℏ) :
    tauEnt a ℏ = a.S_I / ℏ :=
  eq003_entropic_time_def ℏ a.S_I hℏ
```

#### A4. `tauEnt_nonneg` (L73)

```lean
theorem tauEnt_nonneg (a : ADMInput) (ℏ : ℝ) (hℏ : 0 < ℏ) :
    0 ≤ tauEnt a ℏ :=
  eq003_entropic_time_nonneg ℏ a.S_I hℏ a.S_I_nonneg
```

#### A5. `unruh_temperature_pos` (L90)

```lean
theorem unruh_temperature_pos (u : UnruhInput) :
    0 < unruh_temperature u.ℏ u.κ_B u.c u.k_B :=
  eq049_unruh_temperature_positive u.ℏ u.κ_B u.c u.k_B
    u.ℏ_pos u.κ_B_pos u.c_pos u.k_B_pos
```

### `CATEPT/Bridges/Gravitas.lean`

#### A6. `bh_entropy_pos` (L42)

```lean
theorem bh_entropy_pos (b : PosMassBH) :
    0 < bekenstein_hawking_entropy b.G b.M :=
  eq147_152_bh_entropy_positive b.G b.M b.G_pos b.M_pos
```

#### A7. `bh_entropy_ratio` (L55)

```lean
theorem bh_entropy_ratio (m : MassRatioInput) :
    bekenstein_hawking_entropy m.G m.M₂ / bekenstein_hawking_entropy m.G m.M₁
      = (m.M₂ / m.M₁) ^ 2 :=
  eq147_152_bh_entropy_scaling m.G m.M₁ m.M₂ m.G_pos m.M₁_pos
```

#### A8. `bh_entropy_doubling` (L61)

```lean
theorem bh_entropy_doubling (b : PosMassBH) :
    bekenstein_hawking_entropy b.G (2 * b.M)
      = 4 * bekenstein_hawking_entropy b.G b.M :=
  eq147_152_bh_entropy_doubling b.G b.M b.G_pos b.M_pos
```

#### A9. `catept_gravitas_coherence` (L70)

```lean
theorem catept_gravitas_coherence
    (b : PosMassBH) (ℏ : ℝ) (hℏ : 0 < ℏ) (S_I : ℝ) (_hS : 0 ≤ S_I) :
    entropic_time ℏ S_I = S_I / ℏ ∧ 0 < bekenstein_hawking_entropy b.G b.M :=
  ⟨eq003_entropic_time_def ℏ S_I hℏ,
   eq147_152_bh_entropy_positive b.G b.M b.G_pos b.M_pos⟩
```

### `CATEPT/Bridges/Pphi2N.lean`

#### A10. `tauEnt_eq_div` (L44)

```lean
theorem tauEnt_eq_div (p : Pphi2NInput) (ℏ : ℝ) (hℏ : 0 < ℏ) :
    tauEnt p ℏ = p.S_I / ℏ :=
  eq003_entropic_time_def ℏ p.S_I hℏ
```

#### A11. `tauEnt_nonneg` (L49)

```lean
theorem tauEnt_nonneg (p : Pphi2NInput) (ℏ : ℝ) (hℏ : 0 < ℏ) :
    0 ≤ tauEnt p ℏ :=
  eq003_entropic_time_nonneg ℏ p.S_I hℏ p.S_I_nonneg
```

#### A12. `tauEnt_linear` (L55)

```lean
theorem tauEnt_linear (p₁ p₂ : Pphi2NInput) (ℏ : ℝ) (hℏ : 0 < ℏ) :
    entropic_time ℏ (p₁.S_I + p₂.S_I)
      = entropic_time ℏ p₁.S_I + entropic_time ℏ p₂.S_I :=
  eq003_entropic_time_linear ℏ p₁.S_I p₂.S_I hℏ
```

### `CATEPT/Bridges/QFT.lean`

#### A13. `tauEnt_eq_div` (L53)

```lean
theorem tauEnt_eq_div (q : EuclideanQFTInput) (ℏ : ℝ) (hℏ : 0 < ℏ) :
    tauEnt q ℏ = q.S_I / ℏ :=
  eq003_entropic_time_def ℏ q.S_I hℏ
```

#### A14. `tauEnt_nonneg` (L58)

```lean
theorem tauEnt_nonneg (q : EuclideanQFTInput) (ℏ : ℝ) (hℏ : 0 < ℏ) :
    0 ≤ tauEnt q ℏ :=
  eq003_entropic_time_nonneg ℏ q.S_I hℏ q.S_I_nonneg
```

#### A15. `damping_abs_le_one` (L63)

```lean
theorem damping_abs_le_one (q : EuclideanQFTInput) (ℏ : ℝ) (hℏ : 0 < ℏ) :
    abs (path_integral_damping ℏ q.S_I) ≤ 1 :=
  eq054_damping_magnitude ℏ q.S_I hℏ q.S_I_nonneg
```

#### A16. `kinetic_pos` (L68)

```lean
theorem kinetic_pos (q : EuclideanQFTInput) :
    0 < q.k_sq + q.m_sq + q.lam :=
  eq075_propagator_well_defined q.k_sq q.m_sq q.lam
    q.k_sq_nonneg q.m_sq_nonneg q.lam_pos
```

#### A17. `propagator_pos` (L74)

```lean
theorem propagator_pos (q : EuclideanQFTInput) :
    0 < euclidean_propagator q.k_sq q.m_sq q.lam :=
  eq075_propagator_positive q.k_sq q.m_sq q.lam
    q.k_sq_nonneg q.m_sq_nonneg q.lam_pos
```

### `CATEPT/Bridges/OSReconstruction.lean`

#### A18. `minkowski_signature_coincides` (L42)

```lean
theorem minkowski_signature_coincides (d : ℕ) [NeZero d] :
    LorentzLieGroup.minkowskiSignature d = MinkowskiSpace.metricSignature d :=
  minkowskiSignature_eq_metricSignature
```

#### A19. `is_lorentz_matrix_coincides` (L49)

```lean
theorem is_lorentz_matrix_coincides (d : ℕ) [NeZero d]
    (Λ : Matrix (Fin (d + 1)) (Fin (d + 1)) ℝ) :
    LorentzLieGroup.IsLorentzMatrix d Λ ↔ IsLorentzMatrix d Λ :=
  isLorentzMatrix_iff Λ
```

#### A20. `spacelike_condition_coincides` (L57)

```lean
theorem spacelike_condition_coincides (d : ℕ) [NeZero d]
    (v : Fin (d + 1) → ℝ) :
    (∑ μ, LorentzLieGroup.minkowskiSignature d μ * v μ ^ 2 > 0) ↔
    (MinkowskiSpace.minkowskiNormSq d v > 0) :=
  spacelike_condition_iff v
```

### `CATEPT/Showcase/QMGRUnification.lean`

#### A21. `qm_satisfies_catept_spine` (L44)

```lean
theorem qm_satisfies_catept_spine (n : ℕ) :
    cateptConsistencyConstraint (quantumCATEPTSlot n) :=
  quantumCATEPTSlot_consistent n
```

#### A22. `gr_minkowski_satisfies_catept_spine` (L50)

```lean
theorem gr_minkowski_satisfies_catept_spine :
    cateptConsistencyConstraint gravitasMinkowskiSlot :=
  gravitasMinkowskiSlot_consistent
```

#### A23. `gr_electrovacuum_satisfies_catept_spine` (L56)

```lean
theorem gr_electrovacuum_satisfies_catept_spine :
    cateptSpineConstraint gravitasElectrovacuumPlugin :=
  gravitasElectrovacuumPlugin_consistent
```

#### A24. `qm_gr_unified_via_entropic_proper_time` (L67)

```lean
theorem qm_gr_unified_via_entropic_proper_time (n : ℕ) :
    cateptConsistencyConstraint (quantumCATEPTSlot n) ∧
    cateptConsistencyConstraint gravitasMinkowskiSlot :=
  ⟨qm_satisfies_catept_spine n, gr_minkowski_satisfies_catept_spine⟩
```

---

## Pool B — substance candidates on `public/main` (24 theorems)

### `CATEPTMain/Integration/UnificationSpine.lean` (capstone family)

#### B1. `catept_unifies_QM_Thermo_EM_GR` (L243)

```lean
theorem catept_unifies_QM_Thermo_EM_GR :
    B.pwClock.relationalTime = B.crClock.thermalTime
    ∧ B.crClock.thermalTime = B.qmClock.entropicTime
    ∧ B.qmClock.entropicTime = B.spine.pwMat.matsubara.τ_ent
    ∧ B.qmClock.entropicTime = emEntropicTime B.emHbar B.emMu0 B.emRefPotential
    ∧ B.qmClock.entropicTime = B.grSymmetry.action B.grRefParam
    ∧ B.spine.pwMat.matsubara.τ_ent = B.spine.kmsBridge.tauEnt 0 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩
  · exact relational_time_eq_thermal_time B.qmClock B.pwClock B.crClock
  · exact B.crClock.thermalTime_eq_entropic
  · exact B.qm_tauEnt_eq_matsubara
  · exact B.qm_tauEnt_eq_em
  · exact B.qm_tauEnt_eq_gr
  · exact B.spine.matsubara_eq_kms
```

#### B2. `unification_via_modular_flow` (L264)

```lean
theorem unification_via_modular_flow :
    B.qmClock.entropicTime = B.spine.kmsBridge.tauEnt 0 := by
  rw [B.qm_tauEnt_eq_matsubara, B.spine.matsubara_eq_kms]
```

#### B3. `unification_QM_thermo_pillar` (L193)

```lean
theorem unification_QM_thermo_pillar :
    B.pwClock.relationalTime = B.crClock.thermalTime :=
  relational_time_eq_thermal_time B.qmClock B.pwClock B.crClock
```

#### B4. `unification_QM_EM_pillar` (L205)

```lean
theorem unification_QM_EM_pillar :
    B.qmClock.entropicTime = emEntropicTime B.emHbar B.emMu0 B.emRefPotential :=
  B.qm_tauEnt_eq_em
```

#### B5. `unification_QM_GR_pillar` (L216)

```lean
theorem unification_QM_GR_pillar :
    B.qmClock.entropicTime = B.grSymmetry.action B.grRefParam :=
  B.qm_tauEnt_eq_gr
```

#### B6. `unification_QM_Matsubara` (L224)

```lean
theorem unification_QM_Matsubara :
    B.qmClock.entropicTime = B.spine.pwMat.matsubara.τ_ent :=
  B.qm_tauEnt_eq_matsubara
```

### `CATEPTMain/Integration/RigorousComplexFeynmanKac.lean`

#### B7. `complex_FK_rigorous` (L220)

```lean
theorem complex_FK_rigorous
    (m : MeasurePathIntegralModel α)
    (hL1 : Integrable (fun x => m.damping x) m.mu)
    (obs : α → ℂ) (hMeas : Measurable obs)
    (C : ℝ) (hC : 0 ≤ C)
    (hBound : ∀ᵐ x ∂m.mu, ‖obs x‖ ≤ C) :
    Integrable (fun x => obs x * m.weight x) m.mu ∧
      ‖complexFKExpectation m obs‖ ≤ C * partitionFunction m :=
  ⟨complexFKExpectation_integrable m hL1 obs hMeas C hC hBound,
   complexFKExpectation_norm_le m hL1 obs hMeas C hC hBound⟩
```

### `CATEPTMain/Integration/PhysicalUVConvergenceCertificate.lean`

#### B8. `physical_uv_certificate_no_counterterm_needed` (L180)

```lean
theorem physical_uv_certificate_no_counterterm_needed
    (m : PhysicalEntropicModel) :
    Tendsto
        (ofUVConvergenceCertificate
            (physical_uv_convergence_certificate m)).cutoffPartition
        atTop
        (𝓝 (ofUVConvergenceCertificate
            (physical_uv_convergence_certificate m)).continuumPartition) ∧
      (ofUVConvergenceCertificate
          (physical_uv_convergence_certificate m)).counterterm = 0 :=
  ofUVConvergenceCertificate_no_counterterm_needed _
```

### `CATEPTMain/Integration/TomitaMatsubaraEquivBridge.lean`

#### B9. `matsubara_S_I_eq_hbar_logDelta_zero` (L86)

```lean
theorem matsubara_S_I_eq_hbar_logDelta_zero :
    B.matsubara.S_I
      = B.matsubara.ℏ * B.obligation.tomita.modularSpectralLogScale 0 := by
  rw [B.matsubara.S_I_eq_hbar_tauEnt, B.matsubara_tauEnt_eq_logDelta_zero]
```

#### B10. `tauEnt_zero_iff_logDelta_zero` (L94)

```lean
theorem tauEnt_zero_iff_logDelta_zero :
    B.matsubara.τ_ent = 0 ↔ B.obligation.tomita.modularSpectralLogScale 0 = 0 := by
  rw [B.matsubara_tauEnt_eq_logDelta_zero]
```

### `CATEPTMain/Integration/KMSModularParameterBridge.lean`

#### B11. `kms_strip_separate_from_entropicProperTime` (L157)

```lean
theorem kms_strip_separate_from_entropicProperTime :
    ∃ (gammaI tauEnt : ℝ → ℝ) (t : ℝ),
      tauEnt t ≠ kmsStripWidth gammaI t := by
  refine ⟨fun _ => (1 : ℝ), fun t => t, 2, ?_⟩
  unfold kmsStripWidth ImaginaryActionDissipationDictionary.kmsStripWidth
  norm_num
```

### `CATEPTMain/Integration/QuantumInfoEntropyConsistencyBridge.lean`

#### B12. `shannon_entropy_zero_via_plugin` (L61)

```lean
theorem shannon_entropy_zero_via_plugin {n : ℕ} :
    shannonEntropy (fun _ : Fin n => (0 : ℝ)) = 0 :=
  proved_shannon_entropy_zero
```

#### B13. `renyi_at_one_eq_shannon_via_plugin` (L71)

```lean
theorem renyi_at_one_eq_shannon_via_plugin {n : ℕ} (p : Fin n → ℝ) :
    renyiEntropy 1 p = shannonEntropy p :=
  proved_renyi_at_one_eq_shannon p
```

### `CATEPTMain/Integration/MatsubaraLuttingerWardCarrier.lean`

#### B14. `tauEnt_eq_beta_Omega` (L108)

```lean
theorem tauEnt_eq_beta_Omega : M.τ_ent = M.β * M.Ω := M.τ_ent_eq
```

#### B15. `S_I_eq_hbar_tauEnt` (L117)

```lean
theorem S_I_eq_hbar_tauEnt : M.S_I = M.ℏ * M.τ_ent := by
  rw [M.S_I_eq, M.τ_ent_eq]
  ring
```

#### B16. `tauEnt_eq_neg_log_Z` (L125)

```lean
theorem tauEnt_eq_neg_log_Z : M.τ_ent = - Real.log M.Z := by
  rw [M.τ_ent_eq, M.Z_eq_exp, Real.log_exp]
  ring
```

#### B17. `S_I_eq_hbar_neg_log_Z` (L130)

```lean
theorem S_I_eq_hbar_neg_log_Z : M.S_I = -(M.ℏ * Real.log M.Z) := by
  rw [M.S_I_eq_hbar_tauEnt, M.tauEnt_eq_neg_log_Z]
  ring
```

### `CATEPTMain/Integration/TomitaMatsubaraAQFTSpineBridge.lean`

#### B18. `four_way_equivalence_at_zero` (L186)

```lean
theorem four_way_equivalence_at_zero :
    B.tomitaMatsubara.matsubara.τ_ent = B.tauEntKMS 0
    ∧ B.tauEntKMS 0 = B.tauEntChannel 0
    ∧ B.tauEntChannel 0
        = B.tomitaMatsubara.obligation.tomita.modularSpectralLogScale 0 :=
  ⟨B.matsubara_eq_kmsStrip_at_zero,
   B.kmsStrip_eq_channel_at_zero,
   B.channel_eq_logDelta_zero⟩
```

#### B19. `S_I_eq_hbar_logDelta_eq_hbar_channel` (L199)

```lean
theorem S_I_eq_hbar_logDelta_eq_hbar_channel :
    B.tomitaMatsubara.matsubara.S_I
      = B.tomitaMatsubara.matsubara.ℏ
          * B.tomitaMatsubara.obligation.tomita.modularSpectralLogScale 0
    ∧ B.tomitaMatsubara.matsubara.S_I
      = B.tomitaMatsubara.matsubara.ℏ * B.tauEntChannel 0 := by
  refine ⟨B.tomitaMatsubara.matsubara_S_I_eq_hbar_logDelta_zero, ?_⟩
  rw [B.tomitaMatsubara.matsubara.S_I_eq_hbar_tauEnt,
      B.matsubara_tauEnt_eq_channel]
```

#### B20. `matsubara_tauEnt_eq_one_over_gammaI` (L157)

```lean
theorem matsubara_tauEnt_eq_one_over_gammaI :
    B.tomitaMatsubara.matsubara.τ_ent = 1 / B.gammaI 0 := by
  rw [B.matsubara_eq_kmsStrip_at_zero, B.tauEntKMS_eq_kmsStripWidth 0,
      KMSStripWidthSurrogate_eq]
```

### `CATEPTMain/Integration/GravitasBridge.lean`

#### B21. `bohmianEM_action_expansion` (L234)

```lean
theorem bohmianEM_action_expansion (A_bg v : Fin 4 → ℝ) :
    (bohmianEMCATEPTSlot A_bg).actionIm v =
      (∑ μ : Fin 4, v μ ^ 2) / 2
      - (∑ μ : Fin 4, v μ * A_bg μ)
      + (∑ μ : Fin 4, A_bg μ ^ 2) / 2 := by
  simp only [bohmianEMCATEPTSlot,
    CATEPTMain.Domains.SuperiorMethodSlot.toCATEPTSlot, bohmianEMSuperiorSlot,
    Fin.sum_univ_four]
  ring
```

#### B22. `bohmianEM_nonneg` (L227)

```lean
theorem bohmianEM_nonneg (A_bg : Fin 4 → ℝ) (v : Fin 4 → ℝ) :
    0 ≤ (bohmianEMCATEPTSlot A_bg).actionIm v :=
  (bohmianEMCATEPTSlot A_bg).actionIm_nonneg v
```

#### B23. `vml_vacuum_em_action_zero` (L154)

```lean
theorem vml_vacuum_em_action_zero (μ₀ : ℝ) (hμ₀ : 0 < μ₀) :
    (gravitasEMCATEPTSlot μ₀ hμ₀).actionIm (fun _ => 0) = 0 := by
  simp [gravitasEMCATEPTSlot,
    CATEPTMain.Domains.SuperiorMethodSlot.toCATEPTSlot, emSuperiorSlot]
```

#### B24. `gravitasEMCATEPTSlot_consistent` (L142)

```lean
theorem gravitasEMCATEPTSlot_consistent (μ₀ : ℝ) (hμ₀ : 0 < μ₀) :
    cateptConsistencyConstraint (gravitasEMCATEPTSlot μ₀ hμ₀) :=
  (emSuperiorSlot μ₀ hμ₀).consistent
```
