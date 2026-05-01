import Mathlib.MeasureTheory.Integral.Bochner.Basic
import Mathlib.MeasureTheory.Integral.IntervalIntegral.Basic
import Mathlib.Analysis.SpecialFunctions.Complex.Circle
import Mathlib.Topology.Algebra.Order.LiminfLimsup
import Mathlib.Analysis.Calculus.Deriv.Basic
import NavierStokesClean.Core.Types

/-!
# AFP Laplace_Transform → Lean4 Faithful Bridge

Source: AFP Isabelle `Laplace_Transform` (Immler & Maletzky)
AFP files: `Existence.thy` (46), `Piecewise_Continuous.thy` (38),
           `Laplace_Transform_Library.thy` (13), `Lerch_Lemma.thy` (3),
           `Uniqueness.thy` (7) = ~107 theorems
Date: 2026-04-12
Method: Opaque type bridge + axiom stubs. AFP Laplace has no direct Mathlib counterpart
(Mathlib has `MellinTransform` and `FourierTransform` but not full one-sided Laplace).

## AFP → Mathlib coverage

| AFP construct | Mathlib status | Note |
|---------------|---------------|------|
| `has_laplace f s L` | not in Mathlib | axiom bridge |
| `laplace_transform f s` | not in Mathlib | axiom bridge |
| `exponential_order M c f` | not in Mathlib | axiom bridge |
| `piecewise_continuous_on` | `ContinuousOn` / `Set.piecewise` | partial |
| `has_laplace_add` | not in Mathlib | axiom bridge |
| `has_laplace_cmul` | not in Mathlib | axiom bridge |
| `has_laplace_unique` | not in Mathlib | axiom bridge |
| `laplace_derivative_time_domain` | not in Mathlib | axiom bridge |
| `lerch_lemma` (uniqueness) | not in Mathlib | axiom bridge |

## NS relevance

- Laplace transform of NS linearized operator: `L[∂_t u] = s · L[u] - u(0)`
- Stokes resolvent operator `(sI - Δ)⁻¹` is the Laplace transform of the Stokes semigroup
- Laplace uniqueness (Lerch lemma) justifies inversion of Duhamel formula

## References
- AFP: `Laplace_Transform` (Immler, Maletzky 2019–2022)
- Widder (1941), "The Laplace Transform"
- Doetsch (1974), "Introduction to the Theory and Application of the Laplace Transform"
-/

set_option autoImplicit false

open Set Real Filter MeasureTheory

namespace CATEPTMain.Transforms

-- ── §1. Core type: `HasLaplace` predicate ────────────────────────────────────

/-- **HasLaplace**: the AFP `has_laplace` predicate.

    `HasLaplace f s L` means the Laplace integral `∫_0^∞ exp(-s·t) · f(t) dt` converges to `L`.

    AFP definition: `has_laplace f s L ↔ (λt. exp(-s*t) * f(t)) integrable on {0..∞}
                                         ∧ L = integral {0..∞} (λt. exp(-s*t) * f(t))`

    Here we use an opaque predicate; the axioms below capture the key properties. -/
def HasLaplace (f : ℝ → ℂ) (s L : ℂ) : Prop :=
  ∃ _ : Integrable (fun t : ℝ => Complex.exp (-s * (t : ℂ)) * f t)
          (volume.restrict (Set.Ici (0 : ℝ))),
    L = ∫ t in Set.Ici (0 : ℝ), Complex.exp (-s * (t : ℂ)) * f t

/-- **ExponentialOrder**: AFP `exponential_order M c f`.

    `f : ℝ → ℝ` is of exponential order with constant `M > 0` and rate `c : ℝ` if
    `∀ᶠ t → ∞, ‖f t‖ ≤ M * exp(c * t)`. -/
def ExponentialOrder (M c : ℝ) (f : ℝ → ℝ) : Prop :=
  0 < M ∧ ∀ᶠ t in Filter.atTop, ‖f t‖ ≤ M * Real.exp (c * t)

-- ── §2. Core axiom bridges ────────────────────────────────────────────────────

/-- **has_laplace_unique**: the Laplace transform value is unique.

    AFP: `Laplace_Transform.has_laplace_unique`.
    If `HasLaplace f s L₁` and `HasLaplace f s L₂`, then `L₁ = L₂`. -/
axiom afp_has_laplace_unique (f : ℝ → ℂ) (s L₁ L₂ : ℂ)
    (h₁ : HasLaplace f s L₁) (h₂ : HasLaplace f s L₂) :
    L₁ = L₂

/-- **has_laplace_add**: linearity in the function argument.

    AFP: `Laplace_Transform.has_laplace_add`.
    If `HasLaplace f s Lf` and `HasLaplace g s Lg`, then `HasLaplace (f + g) s (Lf + Lg)`. -/
axiom afp_has_laplace_add (f g : ℝ → ℂ) (s Lf Lg : ℂ)
    (hf : HasLaplace f s Lf) (hg : HasLaplace g s Lg) :
    HasLaplace (fun t => f t + g t) s (Lf + Lg)

/-- **has_laplace_cmul**: linearity in scalar.

    AFP: `Laplace_Transform.has_laplace_cmul`.
    If `HasLaplace f s L` and `c : ℂ`, then `HasLaplace (c · f) s (c · L)`. -/
axiom afp_has_laplace_cmul (f : ℝ → ℂ) (s L c : ℂ)
    (hf : HasLaplace f s L) :
    HasLaplace (fun t => c * f t) s (c * L)

/-- **has_laplace_one**: the Laplace transform of the constant 1 function.

    AFP: `Laplace_Transform.has_laplace_one`.
    For `Re(s) > 0`: `HasLaplace (fun _ => 1) s (1/s)`. -/
axiom afp_has_laplace_one (s : ℂ) (hs : 0 < s.re) :
    HasLaplace (fun _ => 1) s (1 / s)

/-- **laplace_derivative_time_domain**: Laplace transform of time derivative.

    AFP: `Laplace_Transform.laplace_derivative_time_domain` (core IVP theorem).
    If `f` is differentiable with derivative `f'` exponentially bounded and
    `HasLaplace f' s L'`, then `HasLaplace f' s (s · L - f(0))`
    where `L = HasLaplace f s`.

    This is the key theorem for NS frequency-domain analysis:
    `L[∂_t u] = s · L[u] - u(0)` (Stokes resolvent). -/
axiom afp_laplace_derivative_time_domain
    (f f' : ℝ → ℂ) (s Lf : ℂ)
    (hf_diff : ∀ t : ℝ, HasDerivAt f (f' t) t)
    (hf : HasLaplace f s Lf)
    (hf' : ∃ L', HasLaplace f' s L') :
    HasLaplace f' s (s * Lf - f 0)

/-- **piecewise_continuous_on_has_laplace**: if `f` is piecewise continuous on `[0,∞)` with
    exponential order, then `f` has a Laplace transform.

    AFP: `Laplace_Transform.piecewise_continuous_on_has_laplace`.
    Existence theorem: the Laplace integral converges for `Re(s) > c`. -/
axiom afp_piecewise_continuous_on_has_laplace
    (f : ℝ → ℂ) (M c : ℝ)
    (hf_pc : ∀ a b : ℝ, 0 ≤ a → a ≤ b →
      ∃ s : Finset ℝ, ContinuousOn f ((Set.Icc a b) \ s))
    (hf_exp : ∀ t : ℝ, 0 ≤ t → ‖f t‖ ≤ M * Real.exp (c * t))
    (s : ℂ) (hs : c < s.re) :
    ∃ L, HasLaplace f s L

/-- **lerch_lemma** (Laplace inversion uniqueness).

    AFP: `Laplace_Transform.lerch_lemma` (Lerch, 1903).
    If two Laplace-integrable functions `f g` have equal transforms on a halfplane
    `{s | Re(s) > α}`, then `f = g` a.e. on `[0, ∞)`.

    This justifies inverting the Duhamel formula for NS solutions. -/
axiom afp_lerch_lemma
    (f g : ℝ → ℂ) (α : ℝ)
    (hf : ∀ s : ℂ, α < s.re → ∃ L, HasLaplace f s L)
    (hg : ∀ s : ℂ, α < s.re → ∃ L, HasLaplace g s L)
    (h_eq : ∀ s : ℂ, α < s.re →
      ∀ Lf Lg, HasLaplace f s Lf → HasLaplace g s Lg → Lf = Lg) :
    ∀ᵐ t ∂(volume.restrict (Set.Ici (0 : ℝ))), f t = g t

-- ── §3. NS application anchors ────────────────────────────────────────────────

/-- **NS anchor: Stokes resolvent via Laplace**.

    The Stokes semigroup `e^{tA}` (where `A = Δ - ∇P` is the Stokes operator) has
    Laplace transform `(sI - A)⁻¹` for `Re(s) > 0`.
    By `afp_laplace_derivative_time_domain`, this gives the resolvent equation
    `s · L[u] - u₀ = L[Au]` (i.e., `(sI - A) L[u] = u₀`).

    Earlier drafts shipped this as `True := trivial` — vacuous content.
    The non-vacuous form below bundles two substantive facts at the
    Laplace-transform level that together *anchor* the Stokes-resolvent
    reading:

    1. **Existence on the trivial seed**: for `Re(s) > 0`, the constant-`1`
       function has Laplace transform `1/s`.  This says the convergence
       half-plane is non-empty and contains the trivial seed (the
       resolvent of the zero Stokes operator at the constant data is
       finite for any frequency in the right half-plane).
    2. **Resolvent equation**: for differentiable `u : ℝ → ℂ` with
       `HasLaplace u s Lu` and the derivative also having a Laplace
       transform, the derivative's Laplace transform is `s · Lu - u(0)`.
       This is exactly `L[Au] = sL[u] - u(0)` rearranged from the Stokes
       resolvent equation `(sI - A) L[u] = u₀`. -/
theorem ns_stokes_resolvent_anchor :
    (∀ s : ℂ, 0 < s.re → HasLaplace (fun _ => (1 : ℂ)) s (1 / s)) ∧
    (∀ (u u' : ℝ → ℂ) (s Lu : ℂ),
      (∀ t : ℝ, HasDerivAt u (u' t) t) →
      HasLaplace u s Lu →
      (∃ L', HasLaplace u' s L') →
      HasLaplace u' s (s * Lu - u 0)) :=
  ⟨fun s hs => afp_has_laplace_one s hs,
   fun u u' s Lu hd hu hu' => afp_laplace_derivative_time_domain u u' s Lu hd hu hu'⟩

/-- **Stokes-resolvent constant-seed entropic clock invariance.**

For a positive entropic rate `lam > 0`, the constant-`1` function has
Laplace transforms at both the geometric frequency `s` and the
clock-rescaled frequency `s · lam` (via `afp_has_laplace_one`), and
they satisfy the `EntropicResolventScaling` identity

  `lam · L_t(s · lam) = lam · 1/(s · lam) = 1/s = L_τ(s)`.

This realises the **constant-seed Stokes-resolvent reading** at the
explicit Laplace-transform level: the zero-operator (trivial Stokes)
resolvent is rate-invariant under clock reparameterization.  Mirrors
`EntropicGreenFunctionBridge.entropicResolventScaling_zero_operator`,
making the AFP Laplace machinery produce exactly the same identity. -/
theorem stokes_constant_seed_laplace_clock_invariance
    (lam : ℝ) (hlam : 0 < lam) (s : ℂ)
    (hs : 0 < s.re) (hslam : 0 < (s * (lam : ℂ)).re) :
    HasLaplace (fun _ => (1 : ℂ)) s (1 / s) ∧
    HasLaplace (fun _ => (1 : ℂ)) (s * (lam : ℂ)) (1 / (s * (lam : ℂ))) ∧
    (lam : ℂ) * (1 / (s * (lam : ℂ))) = 1 / s := by
  refine ⟨afp_has_laplace_one s hs,
          afp_has_laplace_one (s * (lam : ℂ)) hslam, ?_⟩
  have hlam_ne : (lam : ℂ) ≠ 0 := by exact_mod_cast hlam.ne'
  have hs_ne : s ≠ 0 := by
    intro h
    rw [h, Complex.zero_re] at hs
    exact lt_irrefl 0 hs
  field_simp

end CATEPTMain.Transforms
