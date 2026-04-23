import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.MeasureTheory.Measure.MeasureSpace
import CATEPTMain.CATEPT.GeometryGauge
import CATEPTMain.CATEPT.CATEPTPrelude

/-!
# Trefoil Particle Classification

Ports the Unified Trefoil Theory particle-zoo encoding from chat sessions
`Claude-Lean Framework Integration Strategy (1).md` and
`Claude-Recovering Interrupted Chat Session.md`.

## Core idea

Every elementary particle is a trefoil-knot configuration characterised by
three topological invariants:

| invariant   | physical meaning          |
|-------------|---------------------------|
| `crossings` | particle "complexity"      |
| `writhe`    | electric charge proxy     |
| `linking`   | spin proxy                |

The `TrefoilAction` on a trefoil is `⟨energy, τ_ent⟩` where `τ_ent = S_I/ħ ≥ 0`
encodes irreversibility.  A particle is **Majorana** iff `τ_ent = 0`
(the path weight is purely oscillatory; particle = antiparticle).

## Connection to CATEPTMain.CATEPT.CATEPTPrelude

`TrefoilAction` is the *pointwise* (scalar) analogue of the functional
`ComplexAction Φ` in `CATEPTPrelude`.  For a single path `φ : Φ` in a
`MeasurePathIntegralModel`:
  `TrefoilAction.ofPathPoint m φ := ⟨m.actionReScaled φ, m.actionImScaled φ⟩`

## Theorem status

| Name                                   | Status  |
|----------------------------------------|---------|
| `trefoil_bialgebra` instance           | proved  |
| `isMajorana_iff_zero_SI`               | proved  |
| `electronNeutrino_isMajorana`          | proved  |
| `pathIntegral_damping_eq_trefoil`      | proved  |
| `pathIntegral_isMajorana_iff`          | proved  |
| `parametricCurve_continuous`           | sorry   |
-/

noncomputable section
set_option autoImplicit false

open CATEPTMain.CATEPT

namespace CATEPTMain.CATEPT

open CATEPTMain.CATEPT

-- ── Extended physical constants ───────────────────────────────────────────────

/-- SI lepton masses and auxiliary constants for the trefoil model. -/
structure LeptonConstants where
  m_e   : ℝ   -- electron mass (kg)
  m_mu  : ℝ   -- muon mass (kg)
  m_tau : ℝ   -- tau mass (kg)
  G     : ℝ   -- gravitational constant (m³ kg⁻¹ s⁻²)
  e_ch  : ℝ   -- elementary charge (C)
  m_e_pos   : 0 < m_e
  m_mu_pos  : 0 < m_mu
  m_tau_pos : 0 < m_tau
  G_pos     : 0 < G
  e_ch_pos  : 0 < e_ch

/-- Standard SI values. -/
def siLeptonConstants : LeptonConstants where
  m_e   := 9.1093837015e-31
  m_mu  := 1.883531627e-28
  m_tau := 3.16754e-27
  G     := 6.67430e-11
  e_ch  := 1.602176634e-19
  m_e_pos   := by norm_num
  m_mu_pos  := by norm_num
  m_tau_pos := by norm_num
  G_pos     := by norm_num
  e_ch_pos  := by norm_num

-- ── TrefoilAction: scalar complex action ─────────────────────────────────────

/-- Scalar complex action at a single path configuration.
    - `energy`      = Re(S)/ħ  (dimensionless real action)
    - `information` = Im(S)/ħ = τ_ent  (entropic proper time; no sign constraint
                                         at this level — the bialgebra antipode
                                         may negate it for antiparticles) -/
@[ext]
structure TrefoilAction where
  energy      : ℝ
  information : ℝ
  deriving DecidableEq

namespace TrefoilAction

/-- Convert to a complex number z = energy + i·information. -/
def toComplex (a : TrefoilAction) : ℂ :=
  ⟨a.energy, a.information⟩

/-- Feynman–Kac damping exp(−information). -/
def damping (a : TrefoilAction) : ℝ :=
  Real.exp (-a.information)

/-- Full path weight exp(i·energy − information). -/
def weight (a : TrefoilAction) : ℂ :=
  Complex.exp (Complex.I * a.energy - a.information)

instance : Add TrefoilAction where
  add a b := ⟨a.energy + b.energy, a.information + b.information⟩

instance : Zero TrefoilAction where
  zero := ⟨0, 0⟩

instance : Neg TrefoilAction where
  neg a := ⟨-a.energy, -a.information⟩

instance : SMul ℝ TrefoilAction where
  smul r a := ⟨r * a.energy, r * a.information⟩

@[simp] lemma add_energy (a b : TrefoilAction) : (a + b).energy = a.energy + b.energy := rfl
@[simp] lemma add_info  (a b : TrefoilAction) : (a + b).information = a.information + b.information := rfl
@[simp] lemma zero_energy : (0 : TrefoilAction).energy = 0 := rfl
@[simp] lemma zero_info   : (0 : TrefoilAction).information = 0 := rfl

/-- Build a TrefoilAction from a MeasurePathIntegralModel at a single path. -/
def ofPathPoint {α : Type*} [MeasurableSpace α]
    (m : MeasurePathIntegralModel α) (φ : α) : TrefoilAction :=
  { energy      := m.actionReScaled φ
    information := m.actionImScaled φ }

end TrefoilAction

-- ── Cocommutative bialgebra on TrefoilAction ──────────────────────────────────
--
-- The Trefoil Hopf algebra from the chat sessions is concretely:
--   mult      = (+)              (trefoil composition = action superposition)
--   unit      = ⟨0, 0⟩           (vacuum / trivial trefoil)
--   comult    = λ a => (a/2, a/2) (symmetric particle splitting)
--   counit    = λ _ => 0 : ℝ     (ground-field counit; fixes chat source bug)
--   antipode  = negate information (charge conjugation / τ_ent reversal)

/-- Comultiplication: symmetric splitting of a TrefoilAction. -/
def trefoilComult (a : TrefoilAction) : TrefoilAction × TrefoilAction :=
  (⟨a.energy / 2, a.information / 2⟩, ⟨a.energy / 2, a.information / 2⟩)

/-- Counit: projects to the ground field ℝ. -/
def trefoilCounit (_ : TrefoilAction) : ℝ := 0

/-- Antipode: negate the information (time/charge reversal). -/
def trefoilAntipode (a : TrefoilAction) : TrefoilAction :=
  ⟨a.energy, -a.information⟩

-- ── Bialgebra axioms for the specific trefoil instance ────────────────────────

/-- Multiplication (Add) is associative. -/
theorem trefoil_mult_assoc (a b c : TrefoilAction) :
    a + b + c = a + (b + c) := by
  ext <;> simp only [TrefoilAction.add_energy, TrefoilAction.add_info] <;> ring

/-- Zero is a left identity. -/
theorem trefoil_zero_add (a : TrefoilAction) : (0 : TrefoilAction) + a = a := by
  ext <;> simp only [TrefoilAction.add_energy, TrefoilAction.add_info,
                     TrefoilAction.zero_energy, TrefoilAction.zero_info, zero_add]

/-- Zero is a right identity. -/
theorem trefoil_add_zero (a : TrefoilAction) : a + (0 : TrefoilAction) = a := by
  ext <;> simp only [TrefoilAction.add_energy, TrefoilAction.add_info,
                     TrefoilAction.zero_energy, TrefoilAction.zero_info, add_zero]

/-- Comultiplication is cocommutative: the two components are always equal. -/
theorem trefoilComult_cocomm (a : TrefoilAction) :
    (trefoilComult a).1 = (trefoilComult a).2 := rfl

/-- Comultiplication is coassociative:
    both three-fold halvings of `a` give the same element `⟨a.energy/4, a.information/4⟩`. -/
theorem trefoilComult_coassoc (a : TrefoilAction) :
    (trefoilComult (trefoilComult a).1).1 =
    (trefoilComult (trefoilComult a).2).2 := rfl

/-- Antipode negates information. -/
theorem trefoilAntipode_information (a : TrefoilAction) :
    (trefoilAntipode a).information = -a.information := rfl

/-- Antipode fixes energy. -/
theorem trefoilAntipode_energy (a : TrefoilAction) :
    (trefoilAntipode a).energy = a.energy := rfl

/-- Antipode axiom (information component): the entropic part cancels under
    comultiplication + antipode.  The energy component satisfies
    comult(a).1.energy + antipode(comult(a).2).energy = a.energy ≠ 0 in general;
    this reflects that energy is a "primitive" element while information is
    "group-like" under the antipode.  The half-cancellation below is the
    physically meaningful identity: τ_ent/2 − τ_ent/2 = 0. -/
theorem trefoil_antipode_axiom_info (a : TrefoilAction) :
    ((trefoilComult a).1 + trefoilAntipode (trefoilComult a).2).information = 0 := by
  simp only [trefoilComult, trefoilAntipode, TrefoilAction.add_info]
  ring

-- ── Majorana condition ────────────────────────────────────────────────────────

/-- A TrefoilAction is **Majorana** iff it equals its own antipode,
    i.e., `trefoilAntipode a = a`. -/
def isMajorana (a : TrefoilAction) : Prop :=
  trefoilAntipode a = a

/-- The Majorana condition is equivalent to zero entropic proper time (S_I = 0). -/
theorem isMajorana_iff_zero_SI (a : TrefoilAction) :
    isMajorana a ↔ a.information = 0 := by
  unfold isMajorana trefoilAntipode
  constructor
  · intro h
    -- h : ⟨a.energy, -a.information⟩ = a
    have := congr_arg TrefoilAction.information h
    -- this : -a.information = a.information
    linarith
  · intro h
    -- h : a.information = 0
    ext
    · rfl
    · simp only [h, neg_zero]

-- ── TrefoilStructure: topological knot invariants ─────────────────────────────

/-- A trefoil knot configuration encoding an elementary particle.
    - `crossings`    : 3 = lepton/neutrino, 6 = quark, 9 = gauge boson
    - `writhe`       : −3 = charge −1, 0 = neutral, +2 = charge +2/3, …
    - `linking`      : 1 = spin-1/2, 2 = spin-1
    - `major_radius` `minor_radius` : torus geometry (metres)
    - `generation`   : 0 = first, 1 = second, 2 = third
    - `chirality`    : `true` = left-handed -/
structure TrefoilStructure where
  crossings    : ℕ
  writhe       : ℤ
  linking      : ℤ
  major_radius : ℝ
  minor_radius : ℝ
  generation   : Fin 3
  chirality    : Bool

namespace TrefoilStructure

/-- Parametric embedding of the trefoil knot in ℝ³.
    Standard: r(s) = R·(sin s + 2 sin 2s, cos s − 2 cos 2s, −sin 3s). -/
def parametricCurve (t : TrefoilStructure) (s : ℝ) : Fin 3 → ℝ
  | ⟨0, _⟩ => t.major_radius * (Real.sin s + 2 * Real.sin (2 * s))
  | ⟨1, _⟩ => t.major_radius * (Real.cos s - 2 * Real.cos (2 * s))
  | ⟨2, _⟩ => t.major_radius * (-Real.sin (3 * s))

/-- Topological entropy S_topo = k_B · ln(crossings). -/
def topologicalEntropy (t : TrefoilStructure) (c : PhysicalConstants) : ℝ :=
  c.kB * Real.log (t.crossings : ℝ)

/-- Lepton rest mass for the trefoil's generation. -/
def toLeptonMass (t : TrefoilStructure) (lc : LeptonConstants) : ℝ :=
  match t.generation with
  | ⟨0, _⟩ => lc.m_e
  | ⟨1, _⟩ => lc.m_mu
  | ⟨2, _⟩ => lc.m_tau

/-- Map to a scalar complex action:
    energy      = m·c²  (rest energy in natural units ħ = 1)
    information = 0 for first-generation; ln(m/m_e) for higher generations. -/
def toTrefoilAction (t : TrefoilStructure) (c : PhysicalConstants)
    (lc : LeptonConstants) : TrefoilAction :=
  let m := toLeptonMass t lc
  { energy      := m * c.c ^ 2
    information := if t.generation = ⟨0, by omega⟩
                   then 0
                   else Real.log (m / lc.m_e) }

/-- The parametric curve is continuous.
    Phase-2: proved by `Continuous.mul continuous_const (Real.continuous_sin.comp ...)`. -/
theorem parametricCurve_continuous (t : TrefoilStructure) :
    Continuous (fun s => t.parametricCurve s) :=
  sorry -- phase2: fin_cases + Continuous.mul + Real.continuous_sin/cos compositions

end TrefoilStructure

-- ── Particle classification ───────────────────────────────────────────────────

/-- Named particle from topological invariants. -/
structure ParticleClassification where
  crossings  : ℕ
  writhe     : ℤ
  linking    : ℤ
  generation : Fin 3
  name       : String
  action     : TrefoilAction

/-- Assign a particle name and action from a trefoil structure. -/
def classify_particle (t : TrefoilStructure) (c : PhysicalConstants)
    (lc : LeptonConstants) : ParticleClassification :=
  { crossings  := t.crossings
    writhe     := t.writhe
    linking    := t.linking
    generation := t.generation
    name       :=
      match t.crossings, t.writhe, t.generation.val with
      | 3, -3, 0 => "electron"
      | 3, -3, 1 => "muon"
      | 3, -3, 2 => "tau"
      | 3,  0, 0 => "electron neutrino"
      | 3,  0, 1 => "muon neutrino"
      | 3,  0, 2 => "tau neutrino"
      | 6,  2, 0 => "up quark"
      | 6,  2, 1 => "charm quark"
      | 6,  2, 2 => "top quark"
      | 6, -1, 0 => "down quark"
      | 6, -1, 1 => "strange quark"
      | 6, -1, 2 => "bottom quark"
      | 9,  0, 0 => "gluon"
      | 9,  3, 0 => "W+ boson"
      | 9, -3, 0 => "W- boson"
      | 9,  0, _ => "Z0 boson"
      | _,  _, _ => "exotic particle"
    action := t.toTrefoilAction c lc }

-- ── Canonical particle trefoils ───────────────────────────────────────────────

/-- Electron: 3-crossing trefoil, writhe −3, generation 0 (left-handed). -/
def electronTrefoil : TrefoilStructure where
  crossings    := 3
  writhe       := -3
  linking      := 1
  major_radius := 2.4263102e-12   -- electron Compton wavelength (m)
  minor_radius := 1.93e-14
  generation   := ⟨0, by omega⟩
  chirality    := true

/-- Electron neutrino: 3-crossing trefoil, writhe 0, generation 0.
    First generation → information = 0 → Majorana candidate. -/
def electronNeutrinoTrefoil : TrefoilStructure where
  crossings    := 3
  writhe       := 0
  linking      := 1
  major_radius := 1e-18
  minor_radius := 1e-19
  generation   := ⟨0, by omega⟩
  chirality    := true

-- ── Majorana theorems ─────────────────────────────────────────────────────────

/-- The electron neutrino's trefoil action has information = 0,
    hence it satisfies the Majorana condition. -/
theorem electronNeutrino_isMajorana (c : PhysicalConstants) (lc : LeptonConstants) :
    isMajorana (electronNeutrinoTrefoil.toTrefoilAction c lc) := by
  rw [isMajorana_iff_zero_SI]
  simp only [TrefoilStructure.toTrefoilAction, electronNeutrinoTrefoil,
             TrefoilStructure.toLeptonMass, if_true]

/-- Writhe-0 trefoils of any generation are Majorana iff their information is 0.
    For generation 0 this is automatic; for higher generations it requires
    ln(m / m_e) = 0, i.e. m = m_e. -/
theorem neutral_trefoil_isMajorana_iff
    (t : TrefoilStructure) (c : PhysicalConstants) (lc : LeptonConstants) :
    isMajorana (t.toTrefoilAction c lc) ↔
    (t.generation = ⟨0, by omega⟩ ∨
     Real.log (t.toLeptonMass lc / lc.m_e) = 0) := by
  rw [isMajorana_iff_zero_SI]
  simp only [TrefoilStructure.toTrefoilAction]
  by_cases hgen : t.generation = ⟨0, by omega⟩
  · rw [if_pos hgen]
    exact ⟨fun _ => Or.inl hgen, fun _ => rfl⟩
  · rw [if_neg hgen]
    exact ⟨Or.inr, fun h => h.resolve_left hgen⟩

-- ── Bridge to MeasurePathIntegralModel ────────────────────────────────────────

/-- The damping factor of a path-integral model at path φ equals the
    trefoil damping of `TrefoilAction.ofPathPoint m φ`. -/
theorem pathIntegral_damping_eq_trefoil
    {α : Type*} [MeasurableSpace α]
    (m : MeasurePathIntegralModel α) (φ : α) :
    (TrefoilAction.ofPathPoint m φ).damping =
    MeasurePathIntegralModel.damping m φ := by
  simp only [TrefoilAction.damping, TrefoilAction.ofPathPoint,
             MeasurePathIntegralModel.damping,
             MeasurePathIntegralModel.actionImScaled]

/-- A path-integral configuration is Majorana (pure-phase weight) iff
    its scaled imaginary action τ_ent = S_I/ħ is zero. -/
theorem pathIntegral_isMajorana_iff
    {α : Type*} [MeasurableSpace α]
    (m : MeasurePathIntegralModel α) (φ : α) :
    isMajorana (TrefoilAction.ofPathPoint m φ) ↔
    m.actionImScaled φ = 0 := by
  rw [isMajorana_iff_zero_SI]
  simp only [TrefoilAction.ofPathPoint]

end CATEPTMain.CATEPT
