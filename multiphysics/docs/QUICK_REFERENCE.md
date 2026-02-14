# Derivation System Quick Reference

**Fast lookup for common tasks and patterns**

---

## Quick Start

### Minimal Derivation (3 lines)

```mathematica
deriv = StartDerivation["EqN_Name"];
deriv = AddStep[deriv, expr, "Explanation"];
ExportDerivation[deriv, "LaTeX"]
```

### Standard Derivation Pattern

```mathematica
(* 1. Start *)
deriv = StartDerivation["Eq22_ComplexAction",
  Assumptions -> {ℏ > 0, τ_ent >= 0}
];

(* 2. Add steps *)
deriv = AddStep[deriv, S_classical, "Starting definition"];
deriv = ApplyRule[deriv, rule, "Apply rule"];
deriv = SimplifyStep[deriv, "Algebraic", "Simplify"];

(* 3. Finalize *)
deriv = FinalizeDerivation[deriv, result, "QED"];

(* 4. Export *)
ExportDerivation[deriv, "LaTeX", File -> "output.tex"]
ExportDerivation[deriv, "Notebook", File -> "output.nb"]
```

---

## Core Functions

### StartDerivation
```mathematica
StartDerivation[name, opts]
```
**Options:**
- `Assumptions -> {list}`
- `PhysicalPrinciple -> "name"`
- `RelatedEquations -> {numbers}`

**Example:**
```mathematica
deriv = StartDerivation["Eq113_ComplexEinstein",
  Assumptions -> {κ > 0, T ∈ Reals},
  PhysicalPrinciple -> "General Relativity"
]
```

---

### AddStep
```mathematica
AddStep[deriv, expr, explanation, opts]
```
**Parameters:**
- `deriv`: Derivation object
- `expr`: Mathematical expression
- `explanation`: Human-readable text

**Options:**
- `Rule -> transformation`
- `FromPrevious -> True/False`
- `Justification -> "reason"`

**Example:**
```mathematica
deriv = AddStep[deriv,
  G_μν + I*Λ_μν,
  "Complex Einstein tensor",
  Justification -> "Definition from Eq 112"
]
```

---

### ApplyRule
```mathematica
ApplyRule[deriv, rule, explanation]
```
**Applies transformation rule to last expression**

**Example:**
```mathematica
deriv = ApplyRule[deriv,
  ∫ L dt -> S_R,
  "Evaluate integral to get real action"
]
```

---

### SimplifyStep
```mathematica
SimplifyStep[deriv, method, explanation]
```
**Methods:**
- `"Algebraic"`: Simplify
- `"Trigonometric"`: TrigReduce  
- `"Exponential"`: ExpToTrig
- `"Factor"`: Factor
- `"Full"`: FullSimplify

**Example:**
```mathematica
deriv = SimplifyStep[deriv, "Algebraic",
  "Combine like terms"
]
```

---

### FinalizeDerivation
```mathematica
FinalizeDerivation[deriv, result, conclusion]
```
**Marks derivation complete**

**Example:**
```mathematica
deriv = FinalizeDerivation[deriv,
  χ = S_R + I*ℏ*τ_ent,
  "QED: Complex action derived from first principles"
]
```

---

### ExportDerivation
```mathematica
ExportDerivation[deriv, format, opts]
```
**Formats:**
- `"LaTeX"`: .tex file
- `"Notebook"`: .nb file
- `"PDF"`: .pdf (requires LaTeX)

**Options:**
- `File -> "path/to/output"`
- `Style -> "professional"/"minimal"`
- `IncludeMetadata -> True/False`

**Example:**
```mathematica
ExportDerivation[deriv, "LaTeX",
  File -> "outputs/derivations/latex/eq22.tex",
  Style -> "professional"
]
```

---

## Common Patterns

### Pattern 1: Direct Calculation

```mathematica
deriv = StartDerivation["EqN"];
deriv = AddStep[deriv, start, "Start"];
deriv = ApplyRule[deriv, rule, "Apply"];
deriv = SimplifyStep[deriv, "Algebraic", "Simplify"];
deriv = FinalizeDerivation[deriv, result, "Done"];
```

---

### Pattern 2: Multi-Part Derivation

```mathematica
(* Part 1 *)
deriv = AddStep[deriv, lemma, "Prove lemma"];
deriv = ProveSubresult[deriv, lemma];

(* Part 2 *)
deriv = AddStep[deriv, apply, "Apply lemma"];
deriv = SubstituteResult[deriv, lemma];

(* Part 3 *)
deriv = SimplifyStep[deriv, "Full", "Final form"];
```

---

### Pattern 3: Physical Principle

```mathematica
deriv = AddPhysicalPrinciple[deriv,
  "Conservation of energy: dE/dt = 0"
];

deriv = ApplyToSystem[deriv, system,
  "Apply to quantum system"
];

deriv = SolveEquation[deriv, variable,
  "Solve for X"
];
```

---

## LaTeX Environments

### Assumptions
```latex
\begin{assumptions}
\item $\hbar > 0$
\item $\tau_{\text{ent}} \geq 0$
\end{assumptions}
```

### Derivation Steps
```latex
\begin{derivation}
\step{Description}
\begin{equation}
...
\end{equation}
\end{derivation}
```

### Result
```latex
\begin{result}
\begin{equation}
\boxed{final result}
\end{equation}
\end{result}
```

---

## Mathematica Symbols

### Greek Letters
```mathematica
α β γ δ ε ζ η θ ι κ λ μ ν ξ π ρ σ τ φ χ ψ ω
Γ Δ Θ Λ Ξ Π Σ Φ Ψ Ω
```

### Special Symbols
```mathematica
ℏ  (* \[HBar] *)
∞  (* \[Infinity] *)
∂  (* \[PartialD] *)
∫  (* \[Integral] *)
∇  (* \[Del] *)
⊗  (* \[TensorProduct] *)
```

### Common Functions
```mathematica
Exp[x]          (* e^x *)
Log[x]          (* ln(x) *)
Sin[x], Cos[x]  (* Trig *)
Sqrt[x]         (* √x *)
```

---

## File Locations

### Input Files
```
derivations/batch8_derivations.wl
derivations/batch9_derivations.wl
...
```

### Output Files
```
outputs/derivations/latex/batchN.tex
outputs/derivations/notebooks/BatchN.nb
outputs/derivations/pdf/batchN.pdf
```

### Templates
```
derivations/lib/Templates/preamble.tex
derivations/lib/Templates/single_equation_template.tex
```

---

## Validation

### Check Derivation
```mathematica
ValidateDerivation[deriv]
```
Returns True/False

### Compare with Numerical
```mathematica
CompareWithNumerical[deriv, numericalValue]
```
Checks agreement within tolerance

### Compare with Lean
```mathematica
CompareWithLean[deriv, "theorem_name"]
```
Checks symbolic equivalence

---

## Debugging

### Print Steps
```mathematica
PrintDerivationSteps[deriv]
```

### Show Intermediate
```mathematica
ShowIntermediateStep[deriv, stepNumber]
```

### Validate Each Step
```mathematica
ValidateEachStep[deriv]
```

---

## Tips & Tricks

### Tip 1: Clear Explanations
✅ Good: "Apply product rule to differentiate"
❌ Bad: "Do math"

### Tip 2: Small Steps
Break complex derivations into many small steps rather than few large jumps.

### Tip 3: Justify Everything
Every transformation should have clear mathematical or physical justification.

### Tip 4: Test Often
Validate derivation after each major section, not just at end.

### Tip 5: Export Early
Export to LaTeX frequently to check formatting.

---

## Common Errors

### Error: "Step doesn't follow"
**Cause:** Transformation invalid
**Fix:** Add intermediate steps

### Error: "LaTeX compilation failed"
**Cause:** Special characters
**Fix:** Escape with backslash

### Error: "Result doesn't match numerical"
**Cause:** Symbolic != numerical substitution
**Fix:** Check substitution rules

---

## Getting Help

**Documentation:**
- Full guide: `derivations/ARCHITECTURE.md`
- Examples: `derivations/batch8_derivations.wl`
- Templates: `derivations/lib/Templates/`

**Support:**
- Check existing derivations
- Review template files
- Consult architecture doc

---

## Quick Commands Cheat Sheet

```mathematica
(* Start *)
d = StartDerivation["Name"]

(* Add steps *)
d = AddStep[d, expr, "text"]
d = ApplyRule[d, rule, "text"]
d = SimplifyStep[d, method, "text"]

(* Finish *)
d = FinalizeDerivation[d, result, "text"]

(* Export *)
ExportDerivation[d, "LaTeX"]
ExportDerivation[d, "Notebook"]

(* Validate *)
ValidateDerivation[d]
CompareWithNumerical[d, value]
```

---

**Last Updated:** 2026-02-09  
**Version:** 1.0  
**For:** CAT/EPT Derivation System
