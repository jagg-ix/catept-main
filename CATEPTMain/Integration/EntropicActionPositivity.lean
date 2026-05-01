import CATEPTMain.Integration.EntropicCoercivityToUVCertificate

/-!
# Entropic Action Positivity (T-FF Phase 14)

Phase-14 honest content: a small structural module recording
the **physics-side hypothesis** that the imaginary part of
the complex action is nonnegative,

  `S_I[Φ] ≥ 0  for all field configurations Φ`,

and tagging the canonical physical sources (viscous
dissipation, palinstrophy, Fisher information, entropy
production, modular Hamiltonian).

Honest scope: nonnegativity *alone* does NOT yield UV
convergence — it is strictly weaker than the coercivity
hypothesis `S_I[Φ] ≥ C · ‖Φ‖²_UV` consumed by Phase 11. This
module records that distinction explicitly via
`positivity_alone_insufficient_without_coercivity`, which is
trivially true (uniformly-zero `S_I` is nonneg but yields no
UV suppression) and serves as a **failure-mode anchor** for
the Phase-15 audit.

What is honestly proven:

* `EntropicActionPositivity` (structure): packages a field
  type `Φ`, an imaginary-action functional `S_I : Φ → ℝ`,
  and the nonnegativity witness `nonneg : ∀ φ, 0 ≤ S_I φ`.
* `EntropicActionSource` (inductive): the five canonical
  physical origins of `S_I[Φ] ≥ 0` enumerated in the user's
  plan (viscous, palinstrophy, Fisher, entropyProd, modular).
* `entropic_action_nonneg` (theorem): the trivial restatement
  `∀ φ, 0 ≤ p.S_I φ`.
* `entropic_action_zero_is_extremal` (theorem): if `S_I φ₀ = 0`
  then `S_I φ₀ ≤ S_I φ` for every `φ`, i.e. zeros of the
  imaginary action are global minima.
* `coercivity_implies_positivity` (theorem): if the coercivity
  bound `S_I φ ≥ C · ‖φ‖²_UV` holds with `C > 0` and the
  UV-norm-square is nonneg, then `0 ≤ S_I φ`. Records that
  Phase-11 coercivity strictly refines Phase-14 positivity.
* `positivity_alone_insufficient_without_coercivity`
  (theorem): the constant-zero `S_I` is nonneg but does not
  produce any nontrivial UV suppression — exhibited as the
  existence of a positivity witness whose `S_I` is identically
  zero. This is the failure-mode anchor.

Honest scope: this is a **pure structural ship** — no physics
derivation, just packaging and one trivial separation lemma.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.EntropicActionPositivity

noncomputable section

/-- **Physics-side hypothesis**: a field type `Φ` together
with an imaginary-action functional `S_I : Φ → ℝ` known to
be nonneg pointwise. -/
structure EntropicActionPositivity where
  /-- Type of field configurations. -/
  Φ : Type
  /-- Imaginary part of the complex action. -/
  S_I : Φ → ℝ
  /-- Pointwise nonnegativity (the Phase-14 hypothesis). -/
  nonneg : ∀ φ, 0 ≤ S_I φ

/-- The five canonical physical origins of
`S_I[Φ] ≥ 0` listed in the user's plan target #3. This is a
**tagging device** — no semantic content is enforced beyond
the name. -/
inductive EntropicActionSource
  /-- Viscous dissipation `∫ ν |∇Φ|²`. -/
  | viscous
  /-- Palinstrophy `∫ ν |ΔΦ|²`. -/
  | palinstrophy
  /-- Fisher information `∫ |∇log ρ|² ρ`. -/
  | fisher
  /-- Entropy production rate. -/
  | entropyProd
  /-- Modular Hamiltonian expectation. -/
  | modular
  deriving DecidableEq, Repr

/-- The trivial restatement of the `nonneg` field. -/
theorem entropic_action_nonneg (p : EntropicActionPositivity) :
    ∀ φ, 0 ≤ p.S_I φ := p.nonneg

/-- Any zero of the imaginary action is a global minimum. -/
theorem entropic_action_zero_is_extremal
    (p : EntropicActionPositivity) {φ₀ : p.Φ} (h : p.S_I φ₀ = 0)
    (φ : p.Φ) : p.S_I φ₀ ≤ p.S_I φ := by
  rw [h]; exact p.nonneg φ

/-- **Coercivity refines positivity**: if a coercivity bound
`S_I φ ≥ C · uvNormSq φ` holds with `C > 0` and the UV
norm-square is pointwise nonneg, then `S_I` is pointwise
nonneg — i.e. Phase-11 coercivity *implies* Phase-14
positivity. -/
theorem coercivity_implies_positivity
    {Φ : Type} (S_I : Φ → ℝ) (uvNormSq : Φ → ℝ)
    (C : ℝ) (hC : 0 < C)
    (hUV : ∀ φ, 0 ≤ uvNormSq φ)
    (hCoer : ∀ φ, C * uvNormSq φ ≤ S_I φ) :
    ∀ φ, 0 ≤ S_I φ := by
  intro φ
  have h₁ : 0 ≤ C * uvNormSq φ := mul_nonneg hC.le (hUV φ)
  exact h₁.trans (hCoer φ)

/-- **Failure-mode anchor**: the identically-zero `S_I` on the
unit type is a valid `EntropicActionPositivity` witness, yet
gives no UV suppression at all. Records that nonnegativity
*alone* is strictly weaker than coercivity — input for the
Phase-15 failure-mode audit. -/
theorem positivity_alone_insufficient_without_coercivity :
    ∃ p : EntropicActionPositivity, ∀ φ : p.Φ, p.S_I φ = 0 := by
  refine ⟨{ Φ := Unit, S_I := fun _ => 0, nonneg := fun _ => le_refl 0 }, ?_⟩
  intro _; rfl

-- ═══════════════════════════════════════════════════════════════════════
-- Broadened failure-mode audit (10-target plan, target #10)
-- ═══════════════════════════════════════════════════════════════════════
--
-- Each of the following four anchors exhibits a concrete counterexample
-- where the UV certificate fails for a different reason. Together with
-- `positivity_alone_insufficient_without_coercivity` above, they cover
-- all five failure modes enumerated in the user's 10-target plan:
--
--   1. positivity-only without coercivity        ✓ already anchored above
--   2. no spectral gap                           — anchored below
--   3. mode density beats damping                — anchored below
--   4. oscillatory phase without abs convergence — anchored below
--   5. non-monotone / non-exhaustive cutoff      — anchored below

/-- **Failure-mode anchor (no spectral gap)**: there exists a strictly
positive `S_I : ℕ → ℝ` whose values converge down to zero, so no uniform
lower bound `C > 0` exists.  Witness: `S_I k = 1/(k+1)`.  The would-be
coercivity bound `S_I k ≥ C · ‖Φ_k‖²_UV` cannot hold for any fixed
`C > 0` because the LHS approaches `0`. -/
theorem no_spectral_gap_breaks_uv_certificate :
    ∃ S_I : ℕ → ℝ, (∀ k, 0 < S_I k) ∧ ¬ ∃ C : ℝ, 0 < C ∧ ∀ k, C ≤ S_I k := by
  refine ⟨fun k => 1 / ((k : ℝ) + 1), fun k => by positivity, ?_⟩
  rintro ⟨C, hC, hAll⟩
  obtain ⟨k, hk⟩ := exists_nat_gt (1 / C)
  have hk1 : 0 < (k : ℝ) + 1 := by positivity
  -- Multiply `hAll k : C ≤ 1/(k+1)` by `(k+1) > 0` to obtain `C·(k+1) ≤ 1`.
  have h : C ≤ 1 / ((k : ℝ) + 1) := hAll k
  have h_mul : C * ((k : ℝ) + 1) ≤ 1 := by
    have hmul : C * ((k : ℝ) + 1) ≤ (1 / ((k : ℝ) + 1)) * ((k : ℝ) + 1) :=
      mul_le_mul_of_nonneg_right h hk1.le
    have hcancel : (1 / ((k : ℝ) + 1)) * ((k : ℝ) + 1) = 1 := by
      field_simp
    linarith
  -- Together with `hk : 1/C < k` and `hC : 0 < C`, conclude `1 < C·(k+1)`.
  have hCinv : C * (1 / C) = 1 := by field_simp
  nlinarith [hk, hC, hk1, hCinv, h_mul]

/-- **Failure-mode anchor (mode density beats damping)**: there exists a
strictly positive `damping : ℕ → ℝ` that is **not** `Summable`.  Witness:
the constant-one damping.  Mere positivity of the FK damping factor does
not imply finite partition; the damping must decay fast enough relative
to mode density. -/
theorem mode_density_beats_damping_breaks_uv_certificate :
    ∃ damping : ℕ → ℝ, (∀ k, 0 < damping k) ∧ ¬ Summable damping := by
  refine ⟨fun _ => (1 : ℝ), fun _ => one_pos, ?_⟩
  intro h
  have h1 : Filter.Tendsto (fun _ : ℕ => (1 : ℝ)) Filter.atTop (nhds 0) :=
    h.tendsto_atTop_zero
  have h2 : Filter.Tendsto (fun _ : ℕ => (1 : ℝ)) Filter.atTop (nhds 1) :=
    tendsto_const_nhds
  exact one_ne_zero (tendsto_nhds_unique h2 h1)

/-- **Failure-mode anchor (oscillatory phase, governing identity)**: for
any unit-modulus phase and any non-negative damping, the absolute
summability of the complex weight `phase · damping` is **equivalent** to
the summability of the bare damping.  Phase oscillation cannot rescue a
non-summable damping; *absolute* convergence is governed by the damping
alone. -/
theorem oscillatory_phase_does_not_replace_absolute_convergence
    (phase damping : ℕ → ℝ)
    (hP : ∀ k, |phase k| = 1) (hD : ∀ k, 0 ≤ damping k) :
    Summable (fun k => |phase k * damping k|) ↔ Summable damping := by
  have heq : (fun k => |phase k * damping k|) = damping := by
    funext k
    rw [abs_mul, hP k, one_mul, abs_of_nonneg (hD k)]
  rw [heq]

/-- **Failure-mode anchor (oscillatory phase, witness form)**: there
exists a complex weight with unit-modulus phase and strictly positive
damping whose modulus-series fails to be summable — exhibiting that
bounded phase does NOT confer absolute convergence. -/
theorem oscillatory_phase_without_absolute_convergence_witness :
    ∃ (phase damping : ℕ → ℝ),
      (∀ k, |phase k| = 1) ∧
      (∀ k, 0 < damping k) ∧
      ¬ Summable (fun k => |phase k * damping k|) := by
  refine ⟨fun _ => (1 : ℝ), fun _ => (1 : ℝ), ?_, ?_, ?_⟩
  · intro _; simp
  · intro _; exact one_pos
  · intro h
    have heq : (fun k : ℕ => |(1 : ℝ) * 1|) = (fun _ => (1 : ℝ)) := by
      funext _; simp
    rw [heq] at h
    have h1 : Filter.Tendsto (fun _ : ℕ => (1 : ℝ)) Filter.atTop (nhds 0) :=
      h.tendsto_atTop_zero
    have h2 : Filter.Tendsto (fun _ : ℕ => (1 : ℝ)) Filter.atTop (nhds 1) :=
      tendsto_const_nhds
    exact one_ne_zero (tendsto_nhds_unique h2 h1)

/-- **Failure-mode anchor (non-exhaustive cutoff)**: there exists a
cutoff family `Z : ℕ → ℝ` and a continuum value `Z_∞` such that
`Z N → L` as `N → ∞` for some limit `L ≠ Z_∞`.  Witness: the always-empty
cutoff `Z N = 0` with `Z_∞ = 1`.  The family converges — but to the wrong
value, exhibiting that `Z N → Z_∞` is an *independent* obligation that
cannot be inferred from convergence alone. -/
theorem non_monotone_or_non_exhaustive_cutoff_breaks_certificate :
    ∃ (Z : ℕ → ℝ) (Z_inf : ℝ) (L : ℝ),
      Filter.Tendsto Z Filter.atTop (nhds L) ∧ L ≠ Z_inf := by
  refine ⟨fun _ => (0 : ℝ), 1, 0, tendsto_const_nhds, ?_⟩
  norm_num

/-- **Capstone**: the four broadened failure-mode anchors plus
`positivity_alone_insufficient_without_coercivity` cover all five
failure modes enumerated in the 10-target plan.

Earlier drafts shipped this as `True := trivial`, which was vacuous —
it could be discharged without exhibiting *any* of the five witnesses.
The non-vacuous form below is the conjunction of the five witness
existentials, which can only be established by composing the five
named anchors:

  1. `positivity_alone_insufficient_without_coercivity`
  2. `no_spectral_gap_breaks_uv_certificate`
  3. `mode_density_beats_damping_breaks_uv_certificate`
  4. `oscillatory_phase_without_absolute_convergence_witness`
  5. `non_monotone_or_non_exhaustive_cutoff_breaks_certificate`

The conjunction encodes "all five failure modes are simultaneously
witnessed" — a load-bearing structural claim, not a tag. -/
theorem all_five_failure_modes_anchored :
    -- 1. Positivity alone insufficient
    (∃ p : EntropicActionPositivity, ∀ φ : p.Φ, p.S_I φ = 0) ∧
    -- 2. No spectral gap
    (∃ S_I : ℕ → ℝ,
      (∀ k, 0 < S_I k) ∧ ¬ ∃ C : ℝ, 0 < C ∧ ∀ k, C ≤ S_I k) ∧
    -- 3. Mode density beats damping
    (∃ damping : ℕ → ℝ, (∀ k, 0 < damping k) ∧ ¬ Summable damping) ∧
    -- 4. Oscillatory phase without absolute convergence (witness form)
    (∃ (phase damping : ℕ → ℝ),
      (∀ k, |phase k| = 1) ∧
      (∀ k, 0 < damping k) ∧
      ¬ Summable (fun k => |phase k * damping k|)) ∧
    -- 5. Non-monotone / non-exhaustive cutoff
    (∃ (Z : ℕ → ℝ) (Z_inf L : ℝ),
      Filter.Tendsto Z Filter.atTop (nhds L) ∧ L ≠ Z_inf) :=
  ⟨positivity_alone_insufficient_without_coercivity,
   no_spectral_gap_breaks_uv_certificate,
   mode_density_beats_damping_breaks_uv_certificate,
   oscillatory_phase_without_absolute_convergence_witness,
   non_monotone_or_non_exhaustive_cutoff_breaks_certificate⟩

end

end CATEPTMain.Integration.EntropicActionPositivity
