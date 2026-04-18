# Derivation System Specification

**Technical specification for implementing the symbolic derivation infrastructure**

---

## Data Structures

### Derivation Object

**Type:** Association

**Fields:**
```mathematica
Derivation = <|
  (* Identification *)
  "Name" -> String,
  "EquationNumber" -> Integer,
  "BatchNumber" -> Integer,
  
  (* Content *)
  "Assumptions" -> List[Rule],
  "Steps" -> List[Step],
  "Result" -> Expression,
  "Conclusion" -> String,
  
  (* Metadata *)
  "StartTime" -> DateObject,
  "EndTime" -> DateObject,
  "Complete" -> Boolean,
  "Version" -> String,
  
  (* Validation *)
  "Validated" -> Boolean,
  "NumericalAgreement" -> Boolean,
  "LeanConsistency" -> Boolean,
  
  (* References *)
  "LeanTheorem" -> String,
  "NumericalTest" -> String,
  "RelatedEquations" -> List[Integer],
  "PhysicalPrinciple" -> String
|>
```

---

### Step Object

**Type:** Association

**Fields:**
```mathematica
Step = <|
  (* Identification *)
  "Number" -> Integer,
  "Type" -> "Definition"|"Application"|"Simplification"|"Result",
  
  (* Content *)
  "Expression" -> Expression,
  "Explanation" -> String,
  "Justification" -> String,
  
  (* Transformation *)
  "Rule" -> TransformationRule,
  "Method" -> String,
  "FromPrevious" -> Boolean,
  
  (* Metadata *)
  "Timestamp" -> DateObject,
  "Valid" -> Boolean
|>
```

---

## Function Signatures

### Core API

#### StartDerivation
```mathematica
StartDerivation[
  name_String,
  opts:OptionsPattern[]
] /; StringMatchQ[name, "Eq" ~~ DigitCharacter.. ~~ "__"] := 
  Module[{deriv},
    (* Implementation *)
  ]

Options[StartDerivation] = {
  Assumptions -> {},
  PhysicalPrinciple -> None,
  RelatedEquations -> {},
  BatchNumber -> Automatic
}
```

**Returns:** Derivation Association

---

#### AddStep
```mathematica
AddStep[
  deriv_Association /; KeyExistsQ[deriv, "Name"],
  expr_,
  explanation_String,
  opts:OptionsPattern[]
] := Module[{step, newDeriv},
    (* Implementation *)
  ]

Options[AddStep] = {
  Rule -> None,
  FromPrevious -> True,
  Justification -> "",
  Type -> "Application"
}
```

**Returns:** Updated Derivation

---

#### ApplyRule
```mathematica
ApplyRule[
  deriv_Association,
  rule_Rule | rule_RuleDelayed,
  explanation_String
] := Module[{lastExpr, newExpr},
    (* Implementation *)
  ]
```

**Returns:** Updated Derivation

---

#### SimplifyStep
```mathematica
SimplifyStep[
  deriv_Association,
  method_String:"Algebraic",
  explanation_String
] := Module[{lastExpr, simplified},
    (* Implementation *)
  ]
```

**Methods:**
- `"Algebraic"` → Simplify
- `"Trigonometric"` → TrigReduce
- `"Exponential"` → ExpToTrig
- `"Factor"` → Factor
- `"Full"` → FullSimplify
- `"Together"` → Together
- `"Apart"` → Apart

**Returns:** Updated Derivation

---

#### FinalizeDerivation
```mathematica
FinalizeDerivation[
  deriv_Association,
  result_,
  conclusion_String
] := Module[{finalDeriv},
    (* Implementation *)
  ]
```

**Returns:** Finalized Derivation

---

### Export Functions

#### ExportDerivation
```mathematica
ExportDerivation[
  deriv_Association,
  format_String:"LaTeX",
  opts:OptionsPattern[]
] := Module[{output},
    (* Implementation *)
  ]

Options[ExportDerivation] = {
  File -> Automatic,
  Style -> "professional",
  IncludeMetadata -> True,
  IncludeValidation -> True
}
```

**Formats:**
- `"LaTeX"` → .tex file
- `"Notebook"` → .nb file
- `"PDF"` → .pdf (requires pdflatex)
- `"Markdown"` → .md file

**Returns:** File path or Null

---

#### ExportToLaTeX
```mathematica
ExportToLaTeX[
  deriv_Association,
  file_String,
  opts:OptionsPattern[]
] := Module[{latex},
    (* Build LaTeX string *)
    latex = BuildLaTeXDocument[deriv];
    (* Export *)
    Export[file, latex, "Text"]
  ]

Options[ExportToLaTeX] = {
  Template -> "single_equation_template.tex",
  IncludePreamble -> True,
  Style -> "professional"
}
```

---

#### ExportToNotebook
```mathematica
ExportToNotebook[
  deriv_Association,
  file_String,
  opts:OptionsPattern[]
] := Module[{cells},
    (* Build cell structure *)
    cells = BuildNotebookCells[deriv];
    (* Create notebook *)
    nb = Notebook[cells];
    (* Export *)
    Export[file, nb]
  ]
```

---

### Validation Functions

#### ValidateDerivation
```mathematica
ValidateDerivation[
  deriv_Association
] := Module[{steps, consistency, completeness},
    (* Check step consistency *)
    consistency = ValidateStepConsistency[deriv];
    
    (* Check completeness *)
    completeness = ValidateCompleteness[deriv];
    
    (* Overall validation *)
    consistency && completeness
  ]
```

**Checks:**
1. Each step follows from previous
2. Transformations are valid
3. Result matches last step
4. Assumptions sufficient
5. No circular reasoning

**Returns:** Boolean

---

#### CompareWithNumerical
```mathematica
CompareWithNumerical[
  deriv_Association,
  numericalValue_,
  tolerance_:10^-10
] := Module[{symbolicValue, numericEval},
    symbolicValue = deriv["Result"];
    numericEval = N[symbolicValue /. numericalSubstitutions];
    
    Abs[numericEval - numericalValue] < tolerance
  ]
```

**Returns:** Boolean

---

#### CompareWithLean
```mathematica
CompareWithLean[
  deriv_Association,
  leanTheorem_String
] := Module[{symbolicResult, leanStatement},
    symbolicResult = deriv["Result"];
    leanStatement = ParseLeanTheorem[leanTheorem];
    
    SymbolicEquivalent[symbolicResult, leanStatement]
  ]
```

**Returns:** Boolean

---

### Helper Functions

#### AddPhysicalPrinciple
```mathematica
AddPhysicalPrinciple[
  deriv_Association,
  principle_String
] := Module[{step},
    step = <|
      "Type" -> "Principle",
      "Explanation" -> principle,
      "Expression" -> Hold[principle]
    |>;
    
    deriv["PhysicalPrinciple"] = principle;
    AddStep[deriv, Hold[principle], principle, Type -> "Principle"]
  ]
```

---

#### ProveSubresult
```mathematica
ProveSubresult[
  deriv_Association,
  lemma_
] := Module[{subDeriv},
    (* Create sub-derivation *)
    subDeriv = StartDerivation["Lemma_" <> ToString[lemma]];
    
    (* Add to main derivation *)
    AddStep[deriv, lemma, "Lemma proven", Type -> "Lemma"]
  ]
```

---

#### SubstituteResult
```mathematica
SubstituteResult[
  deriv_Association,
  lemma_ -> value_
] := Module[{lastExpr, substituted},
    lastExpr = Last[deriv["Steps"]]["Expression"];
    substituted = lastExpr /. (lemma -> value);
    
    AddStep[deriv, substituted, 
      "Substitute lemma result",
      Rule -> (lemma -> value)
    ]
  ]
```

---

## LaTeX Generation

### Document Structure

```mathematica
BuildLaTeXDocument[deriv_Association] := Module[
  {doc, preamble, body},
  
  (* Preamble *)
  preamble = ImportString[
    FileNameJoin[{$TemplateDir, "preamble.tex"}],
    "Text"
  ];
  
  (* Body *)
  body = StringJoin[
    BuildTitle[deriv],
    BuildStatement[deriv],
    BuildAssumptions[deriv],
    BuildDerivationSteps[deriv],
    BuildResult[deriv],
    BuildValidation[deriv]
  ];
  
  (* Combine *)
  doc = StringJoin[
    preamble,
    "\\begin{document}\n",
    body,
    "\\end{document}"
  ];
  
  doc
]
```

---

### LaTeX Building Blocks

#### BuildTitle
```mathematica
BuildTitle[deriv_] := StringTemplate[
  "\\derivationtitle{CAT/EPT Derivations}{`1`}{`2`}\n\n"
][
  deriv["EquationNumber"],
  deriv["Name"]
]
```

---

#### BuildAssumptions
```mathematica
BuildAssumptions[deriv_] := Module[
  {assumptions, items},
  
  assumptions = deriv["Assumptions"];
  items = StringJoin[
    Table[
      "\\item " <> ToLaTeX[assum] <> "\n",
      {assum, assumptions}
    ]
  ];
  
  StringJoin[
    "\\begin{assumptions}\n",
    items,
    "\\end{assumptions}\n\n"
  ]
]
```

---

#### BuildDerivationSteps
```mathematica
BuildDerivationSteps[deriv_] := Module[
  {steps, stepStrings},
  
  steps = deriv["Steps"];
  stepStrings = Table[
    BuildSingleStep[step],
    {step, steps}
  ];
  
  StringJoin[
    "\\begin{derivation}\n\n",
    StringJoin[stepStrings],
    "\\end{derivation}\n\n"
  ]
]
```

---

#### BuildSingleStep
```mathematica
BuildSingleStep[step_] := StringTemplate[
  "\\step{`1`}\n" <>
  "\\begin{equation}\n" <>
  "`2`\n" <>
  "\\end{equation}\n" <>
  "`3`\n\n"
][
  step["Explanation"],
  ToLaTeX[step["Expression"]],
  If[step["Justification"] != "", 
    "Justification: " <> step["Justification"],
    ""
  ]
]
```

---

### Expression to LaTeX Conversion

```mathematica
ToLaTeX[expr_] := Module[{latex},
  latex = ToString[expr, TeXForm];
  
  (* Custom replacements *)
  latex = StringReplace[latex, {
    "\\hbar" -> "\\hslash",
    "tau_ent" -> "\\tau_{\\text{ent}}",
    "S_R" -> "S_{\\mathrm{R}}",
    "S_I" -> "S_{\\mathrm{I}}"
  }];
  
  latex
]
```

---

## Notebook Generation

### Cell Structure

```mathematica
BuildNotebookCells[deriv_] := Module[
  {cells},
  
  cells = Flatten[{
    (* Title *)
    BuildTitleCell[deriv],
    
    (* Sections *)
    BuildStatementSection[deriv],
    BuildAssumptionsSection[deriv],
    BuildDerivationSection[deriv],
    BuildResultSection[deriv]
  }];
  
  cells
]
```

---

### Cell Builders

```mathematica
BuildTitleCell[deriv_] := Cell[
  TextData[{
    StyleBox["Equation " <> ToString[deriv["EquationNumber"]],
      FontSize->24,
      FontWeight->"Bold"
    ],
    "\n",
    StyleBox[deriv["Name"],
      FontSize->18
    ]
  }],
  "Title"
]
```

---

## Error Handling

### Validation Errors

```mathematica
ValidateDerivation::incomplete = 
  "Derivation `1` is incomplete. Missing fields: `2`";

ValidateDerivation::inconsistent = 
  "Step `1` does not follow from previous step";

ValidateDerivation::mismatch = 
  "Result does not match final step";
```

---

### Export Errors

```mathematica
ExportDerivation::nofile = 
  "Cannot export to `1`: file path invalid";

ExportDerivation::badformat = 
  "Format `1` not recognized. Use LaTeX, Notebook, or PDF";

ExportToLaTeX::compile = 
  "LaTeX compilation failed. Check log: `1`";
```

---

## Testing Infrastructure

### Unit Tests

```mathematica
TestDerivationFramework[] := Module[{results},
  results = {
    TestStartDerivation[],
    TestAddStep[],
    TestApplyRule[],
    TestSimplifyStep[],
    TestFinalizeDerivation[],
    TestValidation[],
    TestExport[]
  };
  
  AllTrue[results, Identity]
]
```

---

### Test Cases

```mathematica
TestStartDerivation[] := Module[{deriv},
  deriv = StartDerivation["Test"];
  
  KeyExistsQ[deriv, "Name"] &&
  KeyExistsQ[deriv, "Steps"] &&
  deriv["Steps"] === {}
]
```

---

## Performance Specifications

### Timing Requirements

- StartDerivation: < 1ms
- AddStep: < 10ms
- ExportToLaTeX: < 100ms per equation
- ExportToNotebook: < 200ms per equation
- ValidateDerivation: < 50ms

### Memory Requirements

- Derivation object: < 1MB
- LaTeX export: < 10KB per equation
- Notebook export: < 50KB per equation

---

## File Format Specifications

### LaTeX Output (.tex)

**Encoding:** UTF-8  
**Line endings:** LF (Unix)  
**Max line length:** 120 characters  
**Indentation:** 2 spaces

---

### Notebook Output (.nb)

**Format:** Mathematica Notebook Format  
**Version:** 13.0+  
**Encoding:** UTF-8

---

### PDF Output (.pdf)

**Format:** PDF/A-1b  
**Page size:** US Letter (8.5" × 11")  
**Margins:** 1 inch all sides  
**Font:** Computer Modern (LaTeX default)

---

## Version Control

**API Version:** 1.0  
**Specification Version:** 1.0  
**Last Updated:** 2026-02-09

**Compatibility:**
- Mathematica: ≥ 13.0
- WolframScript: ≥ 1.7
- LaTeX: TeX Live 2020+

---

## Summary

This specification provides complete technical details for implementing the derivation system. All data structures, functions, and formats are fully specified and ready for implementation.

**Next:** Implement core framework (DerivationFramework.wl)
