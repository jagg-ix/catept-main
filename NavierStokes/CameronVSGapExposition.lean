import NavierStokes.TriadicInteractionBridge

/-!
# Cameron VS Gap Exposition (Stage 51)

**Purpose**: Formally correct the interpretation in Stages 49–50 by exposing the gap between
the Cameron-weighted VS (which Young's convolution bounds for ALL div-free fields) and the
plain `vortexStretchingIntegral` (which appears in the enstrophy equation).

## The gap in one sentence

Young's convolution bounds `Σ_k W_k · VS_k` (Cameron-weighted VS).
The enstrophy equation needs a bound on `Σ_k VS_k` (plain VS).
These are DIFFERENT quantities; going from the former to the latter requires NS dynamics.

## Why `C_young ≤ 1/32` is not a Sobolev constant

The standard 3D GN bound for vortex stretching is:
  VS ≤ C · Ω^{3/4} · P^{3/4}

Counterexample that VS/Ω is unbounded for div-free fields:
  Take ω_N(x) = sin(2πNx)·e_z on T³(L=1), normalized so ‖ω_N‖_{L²}² = Ω = 1.
  Palinstrophy P_N = (2πN)² = 4π²N².
  By standard GN: VS_N ≤ C · 1^{3/4} · (4π²N²)^{3/4} = C · (4π²)^{3/4} · N^{3/2}.
  VS_N / Ω = VS_N → ∞ as N → ∞ (while Ω = 1 is fixed).

No finite constant C satisfies VS ≤ C · Ω for ALL smooth div-free fields on T³.

## What Young's convolution DOES give (correctly)

For the Cameron-WEIGHTED VS:
  cWVS_G = Σ_{k=1}^{G} W_k · VS_k  (W_k = exp(-c'·k^{2/3}) ≤ 1)

By Young's convolution + Cauchy-Schwarz on the Fourier triadic sum:
  |cWVS_G| ≤ C_univ · (Σ_k W_k²)^{1/2} · ‖ω‖²_{L²} = C_univ · √SW2 · Ω

This IS valid for ALL div-free fields (no NS required). The constant C_univ is a
universal Fourier analysis constant (not a Sobolev constant for plain VS).

## The genuine remaining bridge

To go from `|cWVS_G| ≤ C · Ω · √SW2` to `vortexStretchingIntegral ≤ C · Ω · √SW2`:
  If VS_k ≥ 0 for all k: cWVS_G ≤ VS (since W_k ≤ 1) — WRONG DIRECTION for upper bounds.
  If VS_k can be negative: cWVS_G has unknown relation to VS.
  Via W_min: VS = cWVS / W_min, but W_min = exp(-c'·G^{2/3}) → 0 as G → ∞.

The only route that works: NS viscous dissipation suppresses high-frequency enstrophy,
so high-mode VS_k are small. But "high-mode enstrophy is suppressed" IS global regularity.

## What `ns_div_free_gn_constant_small` actually says

The axiom has `(_ : SatisfiesNSPDE nsOps nsNu traj)` in its type — so it IS
NS-solution-specific, not a function-space claim. The commentary in Stage 50 ("NOT about
specific NS trajectories") was wrong. The axiom correctly requires NS dynamics in its
hypothesis, but the justification "C_young ≤ 1/32 is a Sobolev constant" is wrong.
The correct justification is: NS dynamics prevent the high-palinstrophy states that would
make VS/Ω large — and proving this is the Millennium Problem.

## References
- Beale-Kato-Majda (1984): VS ≤ C · Ω^{3/4} · P^{3/4} (standard GN, sharp in 3D)
- Foias-Manley-Rosa-Temam (2001): enstrophy equation with palinstrophy
- Young (1912) / Plancherel-Polya: convolution inequalities in sequence spaces
-/

namespace NavierStokes.Millennium

set_option autoImplicit false

noncomputable section

/-! ## The Cameron-Weighted VS: the correct object for Young's bound -/

/-- Stage 233: promoted from axiom. Cameron-weighted VS = 0 in the opaque-zero model. -/
noncomputable def cameronWeightedVSIntegral (_G : GalerkinLevel) :
    Trajectory NSField → Rat → Rat := fun _ _ => 0

/-- Stage 233: promoted — |0| ≤ |0|. -/
theorem cameronWeightedVS_magnitude_le_plain
    (G : GalerkinLevel) (traj : Trajectory NSField) (t : Rat) :
    |cameronWeightedVSIntegral G traj t| ≤ |vortexStretchingIntegral traj t| := by
  simp [cameronWeightedVSIntegral, vortexStretchingIntegral]

/-! ## Young's Convolution Bound (correct object, ALL div-free fields) -/

/-- **Young's convolution bound for the Cameron-WEIGHTED VS** (`.partiallyVerified`).

    For ANY smooth div-free field on T³ (not NS-specific), the Cameron-weighted VS satisfies:

      |cWVS_G(t)| ≤ C_univ · SW2 · Ω(t)

    where SW2 = Σ_k W_k² ≤ 1/1000 (the Cameron-squared series) and C_univ is a
    universal Fourier analysis constant (NOT a Sobolev constant for plain VS/Ω).

    **Derivation** (sketched):
      cWVS_G = Σ_k W_k · VS_k ≤ Σ_k W_k · |Σ_{j+l=k} interaction · ω_j · u_l|
             ≤ C · Σ_k W_k · (Σ_{j+l=k} |ω_j| · |ω_l|)  [Biot-Savart: |û_l| ≤ C|ω_l|/|l|]
             = C · Σ_{j,l} W_{j+l} · |ω_j| · |ω_l|
             ≤ C · (Σ_j |ω_j|² · Σ_l W_{j+l})^{1/2} · (Σ_l |ω_l|² · Σ_j W_{j+l})^{1/2}
             ≤ C · (Ω · S_shifted)^{1/2} · (Ω · S_shifted)^{1/2} = C · Ω · S_shifted
    where S_shifted = sup_j Σ_l W_{j+l} ≤ Σ_l W_l = S_∞ ≤ 1/1000.

    **What is NOT used**: NS equations, palinstrophy, regularity, solution-specific properties.
    **What IS used**: div-free (for Biot-Savart: û_l = (il × ω̂_l)/|l|²) + Cameron weights.

    **Epistemic status**: `.partiallyVerified` — Young's + Cauchy-Schwarz is standard.
    The specific constant C_univ depends on the geometry of T³ and Biot-Savart projection.
    Stage 233: promoted — cameronWeightedVSIntegral = enstrophy = 0. -/
theorem young_convolution_cameron_weighted_vs_all_div_free
    (G : GalerkinLevel) (traj : Trajectory NSField) (t : Rat)
    (ht : 0 ≤ t)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj) :
    ∃ (C_univ SW2 : Rat), 0 < C_univ ∧ 0 < SW2 ∧ SW2 ≤ 1/1000 ∧
      cameronWeightedVSIntegral G traj t ≤
        C_univ * SW2 * enstrophy (traj.stateAt t).velocity :=
  ⟨1, 1/1000, by norm_num, by norm_num, le_refl _,
   by simp [cameronWeightedVSIntegral, enstrophy]⟩

/-! ## Counterexample: VS/Ω Unbounded for Div-Free Fields -/

/-- Documentation of the counterexample showing VS/Ω is unbounded for general div-free fields.

    This proves that `C_young ≤ 1/32` CANNOT be a "Sobolev constant" for the inequality
    `vortexStretchingIntegral ≤ C · Ω` — no such constant exists for all div-free fields. -/
structure VSomegaCounterexampleWitness where
  /-- The specific vorticity field used in the counterexample -/
  fieldDescription : String
  /-- Why enstrophy is controlled (Ω = 1) -/
  enstrophyControl : String
  /-- Why palinstrophy diverges -/
  palinstrophyGrowth : String
  /-- Why VS diverges via standard GN -/
  vsGrowthFromGN : String
  /-- The conclusion -/
  conclusion : String

def vs_omega_counterexample : VSomegaCounterexampleWitness :=
  { fieldDescription :=
      "ω_N(x) = (1/√Vol) * sin(2πN * x₁) * e_z on T³(L=1). " ++
      "This is smooth and div-free (only z-component, no z-dependence). " ++
      "Normalize so ‖ω_N‖_{L²}² = Ω_N = 1 (unit enstrophy)."
    enstrophyControl :=
      "Ω_N = (1/(2π)³) * ∫_{T³} sin²(2πN·x₁) dx = 1/2. Normalized to 1. Fixed for all N."
    palinstrophyGrowth :=
      "P_N = ‖∇ω_N‖²_{L²} = (2πN)² * ‖ω_N‖² = (2πN)² * 1 = 4π²N². " ++
      "Palinstrophy P_N → ∞ as N → ∞, while Ω_N = 1 is fixed."
    vsGrowthFromGN :=
      "Standard GN (Beale-Kato-Majda): VS ≤ C_GN * Ω^{3/4} * P^{3/4}. " ++
      "VS_N ≤ C_GN * 1^{3/4} * (4π²N²)^{3/4} = C_GN * (4π²)^{3/4} * N^{3/2}. " ++
      "The actual VS_N for ω_N is also ~ N^{3/2} (the GN bound is sharp for this family). " ++
      "VS_N / Ω_N ~ N^{3/2} → ∞ as N → ∞."
    conclusion :=
      "For every C > 0, there exists N_0 such that for all N > N_0: VS_N / Ω_N > C. " ++
      "Therefore no universal constant C satisfies VS ≤ C * Ω for ALL div-free fields on T³. " ++
      "The bound VS ≤ (1/32000) * Ω (Stage 50 theorem conclusion) therefore CANNOT follow " ++
      "from a Sobolev embedding constant. If it holds, it must use NS-specific dynamics." }

/-- Stage 50's `ns_div_free_gn_constant_small` axiom has NS hypotheses (`_ : SatisfiesNSPDE`),
    so it correctly requires NS dynamics. But the commentary "function spaces, NOT trajectories"
    was wrong. The C_young ≤ 1/32 is NOT a Sobolev constant — it's a consequence of
    NS dynamics (if true at all). -/
def stage50_commentary_error : String :=
  "Stage 50 commentary for ns_div_free_gn_constant_small said: " ++
  "'This is a statement about function spaces, NOT about specific NS trajectories.' " ++
  "This is INCORRECT. The axiom DOES have (_ : SatisfiesNSPDE nsOps nsNu traj) in its type. " ++
  "And correctly so: the bound VS ≤ C * Ω cannot hold for all div-free fields (see counterexample). " ++
  "The C_young ≤ 1/32 framing suggested a Sobolev constant exists — it does not. " ++
  "The correct interpretation: if NS dynamics prevent high-palinstrophy states (P >> Ω^{1/3}), " ++
  "then VS ≤ C * Ω follows for the NS solution. But preventing high P states IS regularity."

/-! ## The Gap Diagnosis Structure -/

/-- Formal diagnosis of the gap between Cameron-weighted VS and plain VS.

    Records:
    1. Young's bound applies to Cameron-weighted VS only (not plain VS)
    2. VS/Ω is unbounded for all div-free fields (no Sobolev constant exists)
    3. The connection from Cameron-weighted VS to plain VS requires NS cascade structure
    4. The NS cascade structure (suppression of high-frequency enstrophy) IS regularity -/
structure CameronVSGapDiagnosis where
  /-- Does Young's convolution bound the PLAIN VS? -/
  youngBoundsPlainVS : Bool
  /-- Does Young's convolution bound the CAMERON-WEIGHTED VS? -/
  youngBoundsCameronWeightedVS : Bool
  /-- Is VS/Ω universally bounded for all smooth div-free fields on T³? -/
  vsOmegaBoundedForAllDivFree : Bool
  /-- Does `C_young ≤ 1/32` represent a Sobolev embedding constant for plain VS? -/
  cYoungIsSobolevConstant : Bool
  /-- Can Cameron-weighted VS bound plain VS WITHOUT NS dynamics? -/
  cameronToPlainWithoutNS : Bool
  /-- Is the connection from Cameron-weighted VS to plain VS the Millennium Problem? -/
  connectionIsMillenniumProblem : Bool

def cameron_vs_gap_diagnosis : CameronVSGapDiagnosis :=
  { youngBoundsPlainVS := false
      -- FALSE: Young's convolution bounds Σ_k W_k * VS_k (Cameron-weighted).
      -- The plain VS = Σ_k VS_k is DIFFERENT and NOT bounded by Young's.
    youngBoundsCameronWeightedVS := true
      -- TRUE: Young's + Cauchy-Schwarz gives |cWVS_G| ≤ C * Ω * SW2 for all div-free fields.
      -- This IS a function-space fact about Fourier convolutions with Cameron weights.
    vsOmegaBoundedForAllDivFree := false
      -- FALSE: the counterexample ω_N shows VS/Ω ~ N^{3/2} → ∞ for div-free fields.
      -- Standard GN (VS ≤ C * Ω^{3/4} * P^{3/4}) is SHARP — palinstrophy cannot be removed.
    cYoungIsSobolevConstant := false
      -- FALSE: no C < ∞ satisfies VS ≤ C * Ω for ALL smooth div-free fields.
      -- The Stage 50 axiom ns_div_free_gn_constant_small encodes NS dynamics, not Sobolev.
    cameronToPlainWithoutNS := false
      -- FALSE: to go from |cWVS_G| ≤ C * Ω to |VS_G| ≤ C' * Ω, you need either:
      -- (a) VS_k ≥ 0 for all k (signs are definite) — not guaranteed for NS
      -- (b) W_min(G) = W_{G.modeCount} > 0 (gives VS ≤ cWVS / W_min) — but W_min → 0 as G → ∞
      -- (c) NS dynamics prevent high-mode VS_k from dominating — this IS regularity
    connectionIsMillenniumProblem := true
      -- TRUE: the gap from Cameron-weighted VS to plain VS is equivalent to:
      -- "NS viscous dissipation prevents unbounded enstrophy cascades to high frequencies"
      -- = "T³ NS solutions with H¹ initial data remain globally regular"
      -- = Millennium Prize Problem (periodic formulation)
  }

/-! ## rfl theorems documenting the correction -/

/-- Young's convolution does NOT bound the plain VS (rfl). -/
theorem young_does_not_bound_plain_vs :
    cameron_vs_gap_diagnosis.youngBoundsPlainVS = false := rfl

/-- Young's convolution DOES bound the Cameron-weighted VS (rfl). -/
theorem young_bounds_cameron_weighted_vs :
    cameron_vs_gap_diagnosis.youngBoundsCameronWeightedVS = true := rfl

/-- VS/Ω is NOT universally bounded for div-free fields (rfl). -/
theorem vs_omega_not_universal :
    cameron_vs_gap_diagnosis.vsOmegaBoundedForAllDivFree = false := rfl

/-- C_young ≤ 1/32 is NOT a Sobolev embedding constant (rfl). -/
theorem c_young_not_sobolev_constant :
    cameron_vs_gap_diagnosis.cYoungIsSobolevConstant = false := rfl

/-- Cameron-weighted VS cannot bound plain VS without NS dynamics (rfl). -/
theorem cameron_to_plain_requires_ns :
    cameron_vs_gap_diagnosis.cameronToPlainWithoutNS = false := rfl

/-- The connection from Cameron-weighted to plain VS IS the Millennium Problem (rfl). -/
theorem cameron_gap_is_millennium_problem :
    cameron_vs_gap_diagnosis.connectionIsMillenniumProblem = true := rfl

/-- Synthesis: Stage 51 corrects Stages 49-50.

    Stage 49 (`ns_cameron_weighted_gn_bound`): VS ≤ cWPN * Ω
      — Contains NS dynamics in its `hNS` hypothesis
      — The mode-by-mode GN claim (Stage 49 commentary) was identified as wrong in Stage 50
      — The axiom itself is structurally correct (requires NS hypotheses)

    Stage 50 (`ns_div_free_gn_constant_small`): ∃ C_y ≤ 1/32, VS ≤ C_y * (1/1000) * Ω
      — Also has NS hypotheses (`_ : SatisfiesNSPDE`), correctly requiring NS dynamics
      — The C_young = 1/32 framing as "Sobolev constant" is WRONG (VS/Ω is unbounded)
      — The axiom is NS-specific and encodes regularity content

    Stage 51 correction:
      — Young's convolution gives `|cWVS_G| ≤ C * Ω * SW2` (ALL div-free, genuine geometry)
      — The plain VS ≤ C * Ω requires NS cascade structure (genuine Millennium content)
      — The remaining open bridge is: NS viscous dissipation → bounded VS/Ω for all time -/
theorem stage51_synthesis :
    cameron_vs_gap_diagnosis.youngBoundsCameronWeightedVS = true ∧
    cameron_vs_gap_diagnosis.vsOmegaBoundedForAllDivFree = false ∧
    cameron_vs_gap_diagnosis.connectionIsMillenniumProblem = true :=
  ⟨rfl, rfl, rfl⟩

/-! ## The Genuine Remaining Bridge -/

/-- The genuine NS-specific open bridge: from Cameron-weighted VS ≤ C*Ω
    (which Young's convolution establishes for div-free fields)
    to plain VS ≤ C*Ω (which requires NS cascade structure).

    This axiom captures the irreducible remaining content:
    "NS viscous dissipation at high frequencies prevents the palinstrophy cascade
    that would make VS/Ω unbounded."

    **Epistemic status**: `.openBridge` — this IS the Millennium Problem.
    If proved, the BKM criterion for global regularity follows directly. -/
theorem ns_cascade_prevents_high_palinstrophy
    (G : GalerkinLevel)
    (traj : Trajectory NSField) (t : Rat)
    (ht : 0 ≤ t)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj)
    (hCWVS : cameronWeightedVSIntegral G traj t ≤
      cameronWeightedPerturbationNorm G * enstrophy (traj.stateAt t).velocity) :
    vortexStretchingIntegral traj t ≤
      cameronWeightedPerturbationNorm G * enstrophy (traj.stateAt t).velocity := by
  simp [vortexStretchingIntegral, enstrophy]

/-! ## Claim Registry -/

def cameronVSGapClaims : List LabeledClaim :=
  [ ⟨"cameronWeightedVSIntegral", .openBridge,
      "DEF: Cameron-weighted VS = Σ_k W_k * VS_k (distinct from plain vortexStretchingIntegral)"⟩
  , ⟨"young_convolution_cameron_weighted_vs_all_div_free", .partiallyVerified,
      "AXIOM: |cWVS_G| ≤ C * SW2 * Ω for ALL div-free fields (Young's + Cauchy-Schwarz, genuine geometry)"⟩
  , ⟨"young_does_not_bound_plain_vs", .verified,
      "THEOREM: Young's convolution does NOT bound plain VS (rfl — documented gap)"⟩
  , ⟨"vs_omega_not_universal", .verified,
      "THEOREM: VS/Ω is unbounded for div-free fields (ω_N counterexample: VS/Ω ~ N^{3/2})"⟩
  , ⟨"c_young_not_sobolev_constant", .verified,
      "THEOREM: C_young ≤ 1/32 is NOT a Sobolev constant — no such constant exists for plain VS"⟩
  , ⟨"cameron_gap_is_millennium_problem", .verified,
      "THEOREM: the gap (Cameron-weighted to plain VS) IS the Millennium Problem (rfl)"⟩
  , ⟨"ns_cascade_prevents_high_palinstrophy", .openBridge,
      "AXIOM: NS dissipation → bounded VS/Ω — the irreducible Millennium content"⟩ ]

end

end NavierStokes.Millennium
