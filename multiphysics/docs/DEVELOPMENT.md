# Development Guide

Guide for contributing to and extending the Wolfram Verification Infrastructure.

---

## Getting Started

### Prerequisites

**Required:**
- WolframScript installed
- Git for version control
- Text editor or IDE
- Understanding of Wolfram Language

**Recommended:**
- Familiarity with CAT/EPT theory
- Experience with Lean 4
- Physics/mathematics background

---

## Development Setup

### Clone Repository

```bash
git clone <repository-url>
cd CATEPT-Complete-v3.3/WolframVerification
```

### Configure Git

```bash
git config user.name "Your Name"
git config user.email "your.email@example.com"
```

### Create Development Branch

```bash
git checkout -b feature/my-new-feature
```

---

## Code Standards

### Naming Conventions

**Functions:**
```mathematica
PascalCase
Examples: VerifyNumerically, ComputeComplexAction
```

**Variables:**
```mathematica
camelCase
Examples: complexAction, entropicTime
```

**Constants:**
```mathematica
SCREAMING_SNAKE_CASE
Examples: PLANCK_CONSTANT, GOLDEN_RATIO
```

**Test Cases:**
```mathematica
Category_EquationNumber_Description
Examples: Eq113_ComplexEinstein, Regression_EntropicTime
```

---

### Code Style

**Formatting:**
```mathematica
(* Good *)
Module[{x, y, result},
  x = 2.0;
  y = 3.0;
  result = x + y;
  VerifyNumerically[result, 5.0, 10^-12, "Addition"]
]

(* Bad *)
Module[{x,y,result},x=2.0;y=3.0;result=x+y;VerifyNumerically[result,5.0,10^-12,"Addition"]]
```

**Comments:**
```mathematica
(* Good: Explain why *)
(* Use entropic damping to ensure convergence *)
damping = Exp[-entropicTime];

(* Bad: State the obvious *)
(* Set x to 2.0 *)
x = 2.0;
```

**Documentation:**
```mathematica
(* 
 * Function: ComputeComplexAction
 * 
 * Computes the complex action χ = S_R + iℏτ_ent
 * 
 * Parameters:
 *   S_R  - Real part of action
 *   S_I  - Imaginary part (entropic)
 * 
 * Returns:
 *   Complex number representing action
 *)
ComputeComplexAction[S_R_, S_I_] := S_R + I*S_I
```

---

## Adding New Equations

### Step 1: Identify Equation

```mathematica
(* Example: New equation for batch 13 *)
(* Eq 113b: Extended Einstein equation *)
```

### Step 2: Create Test Case

```mathematica
TestCase["Eq113b_ExtendedEinstein",
  Module[{G, Λ, T, S, κ, correction},
    (* Implementation *)
    G = 2.0;
    Λ = 0.5;
    T = 2.0;
    S = 0.5;
    κ = 1.0;
    correction = 0.01;
    
    LHS = G + I*Λ + correction;
    RHS = κ*(T + I*S);
    
    VerifyNumerically[LHS, RHS + correction, 10^-12,
                     "Extended Einstein with correction"]
  ]
]
```

### Step 3: Add to Batch Script

**Edit:** `scripts/batch13_einstein_time.wls`

```mathematica
(* Add before "RUN ALL TESTS" section *)
TestCase["Eq113b_ExtendedEinstein",
  (* ... test code ... *)
]
```

### Step 4: Add Regression Test

**Edit:** `tests/test_batch13.wls`

```mathematica
TestCase["Regression_Eq113b",
  Module[{result},
    result = ComputeExtendedEinstein[...];
    VerifyNumerically[result, $GoldenResults["Eq113b"],
                     10^-12, "Matches golden value"]
  ]
]
```

### Step 5: Update Documentation

**Edit:** `subdocs/BATCH_DETAILS.md`

Add equation description.

### Step 6: Test

```bash
wolframscript scripts/batch13_einstein_time.wls
wolframscript tests/test_batch13.wls
```

### Step 7: Commit

```bash
git add scripts/batch13_einstein_time.wls
git add tests/test_batch13.wls
git add subdocs/BATCH_DETAILS.md
git commit -m "Add Eq 113b: Extended Einstein equation"
```

---

## Adding New Batches

### Step 1: Create Batch Script

**Template:**
```mathematica
#!/usr/bin/env wolframscript
(* ========================================= *)
(* BATCH XX: DESCRIPTION                    *)
(* Executable verification script           *)
(* Equations: XXX-YYY (ZZ equations)        *)
(* ========================================= *)

$ScriptDir = DirectoryName[$InputFileName];
$RootDir = ParentDirectory[$ScriptDir];

(* Load dependencies *)
Get[FileNameJoin[{$RootDir, "lib", "ComplexActionLib.wl"}]]
Get[FileNameJoin[{$RootDir, "lib", "TestFramework.wl"}]]

Print["========================================"]
Print["BATCH XX: DESCRIPTION"]
Print["========================================"]

(* Test cases *)
TestCase["EqXXX_Name",
  Module[{...},
    (* ... *)
  ]
]

(* Run tests *)
results = RunAllTests[];
PrintTestSummary[results];

(* Exit *)
If[AllTestsPassed[results], Exit[0], Exit[1]]
```

**Save as:** `scripts/batchXX_description.wls`

---

### Step 2: Create Test Suite

**Template:**
```mathematica
#!/usr/bin/env wolframscript
(* ========================================= *)
(* TEST SUITE: BATCH XX                     *)
(* Automated regression testing             *)
(* ========================================= *)

$ScriptDir = DirectoryName[$InputFileName];
$RootDir = ParentDirectory[$ScriptDir];

Get[FileNameJoin[{$RootDir, "lib", "TestFramework.wl"}]]

Print["========================================"]
Print["BATCH XX TEST SUITE"]
Print["========================================"]

(* Golden values *)
$GoldenResults = <|
  "Result1" -> 1.0,
  "Result2" -> 2.0
|>;

(* Regression tests *)
TestCase["Regression_...", ...]

(* Run tests *)
results = RunAllTests[];
PrintTestSummary[results];

If[AllTestsPassed[results], Exit[0], Exit[1]]
```

**Save as:** `tests/test_batchXX.wls`

---

### Step 3: Update Pipeline

**Edit:** `pipeline/run_all_verifications.sh`

```bash
BATCHES=(
    # ... existing batches ...
    "batchXX_description.wls"
)
```

---

### Step 4: Update Documentation

**Edit documentation files:**
- `README.md`
- `subdocs/BATCH_DETAILS.md`
- `subdocs/USAGE_GUIDE.md`

---

## Adding Library Functions

### Step 1: Implement Function

**Edit:** `lib/ComplexActionLib.wl`

```mathematica
(*
 * Function: MyNewFunction
 * Description: Does something useful
 * Parameters: x, y
 * Returns: result
 *)
MyNewFunction[x_, y_] := Module[{result},
  result = x + y;
  result
]
```

---

### Step 2: Document Function

Add documentation in file header and inline.

---

### Step 3: Test Function

**Create test:**
```mathematica
TestCase["Test_MyNewFunction",
  Module[{result},
    result = MyNewFunction[2.0, 3.0];
    VerifyNumerically[result, 5.0, 10^-12, "Addition works"]
  ]
]
```

---

### Step 4: Use Function

Now available in all batches:

```mathematica
(* In any batch script *)
result = MyNewFunction[x, y];
```

---

## Testing Workflow

### Before Committing

**Run all tests:**
```bash
./pipeline/run_all_verifications.sh
```

**Expected:**
```
All batches PASSED ✓
```

---

### During Development

**Run specific batch:**
```bash
wolframscript scripts/batch13_einstein_time.wls
```

**Run specific test:**
```bash
wolframscript tests/test_batch13.wls
```

---

## Version Control

### Branching Strategy

**Main branches:**
- `main`: Stable, all tests passing
- `develop`: Integration branch

**Feature branches:**
- `feature/equation-xxx`: New equations
- `feature/batch-xx`: New batches
- `fix/issue-description`: Bug fixes

---

### Commit Messages

**Format:**
```
Type: Short description

Detailed explanation if needed.

- Bullet points for changes
- Reference issues: #123
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `test`: Tests
- `refactor`: Code restructuring
- `perf`: Performance improvement

**Examples:**
```
feat: Add Eq 113b Extended Einstein equation

Implements extended Einstein equation with correction term.
Tests included and passing.

fix: Correct tolerance in Eq 113 test

Previous tolerance too strict, causing spurious failures.
Relaxed to 10^-10 based on numerical analysis.

docs: Update BATCH_DETAILS.md with new equations

Added descriptions for equations 113a-113c.
```

---

### Pull Request Process

**1. Create PR**
```bash
git push origin feature/my-feature
```
Then create PR on GitHub/GitLab.

**2. PR Checklist**
- [ ] All tests pass
- [ ] Code follows style guide
- [ ] Documentation updated
- [ ] No merge conflicts
- [ ] Reviewed by peer

**3. Review Process**
- Code review by maintainer
- Address feedback
- Update as needed

**4. Merge**
- Squash and merge or rebase
- Delete feature branch

---

## Code Review Guidelines

### As Reviewer

**Check:**
- ✅ Tests pass
- ✅ Code is readable
- ✅ No duplication
- ✅ Follows conventions
- ✅ Documentation clear
- ✅ Edge cases handled

**Provide:**
- Constructive feedback
- Specific suggestions
- Examples if needed
- Praise for good work

---

### As Author

**Respond to:**
- All review comments
- Questions promptly
- Criticism constructively

**Update:**
- Code based on feedback
- Tests as needed
- Documentation if unclear

---

## Debugging

### Common Issues

**Issue: Test fails intermittently**
```mathematica
(* Add debugging *)
TestCase["Debug",
  Module[{x, y},
    Print["x = ", x];
    Print["y = ", y];
    (* ... *)
  ]
]
```

**Issue: Numerical precision**
```mathematica
(* Use arbitrary precision *)
x = 2.0`20;  (* 20 digits precision *)
```

**Issue: Memory leaks**
```mathematica
(* Clear variables *)
ClearAll[x, y, z];
```

---

### Profiling

**Time profiling:**
```mathematica
Timing[ComputeComplexAction[...]]
```

**Memory profiling:**
```mathematica
MaxMemoryUsed[ComputeComplexAction[...]]
```

---

## Performance Optimization

### Best Practices

**DO:**
- ✅ Use built-in functions
- ✅ Vectorize operations
- ✅ Compile critical sections
- ✅ Profile before optimizing

**DON'T:**
- ❌ Premature optimization
- ❌ Sacrifice readability
- ❌ Optimize without measuring
- ❌ Break tests for speed

---

### Example Optimization

**Before:**
```mathematica
result = Table[ComputeValue[i], {i, 1, 1000}];
```

**After:**
```mathematica
result = ComputeValue /@ Range[1000];  (* Vectorized *)
```

---

## Documentation

### Required Documentation

**For Functions:**
- Purpose
- Parameters
- Return value
- Example usage

**For Tests:**
- What is being tested
- Expected behavior
- Edge cases covered

**For Batches:**
- Equation range
- Key results
- Scientific significance

---

### Documentation Tools

**Inline comments:**
```mathematica
(* This computes... *)
```

**Section headers:**
```mathematica
(* ─────────────────────────────────────── *)
(* SECTION NAME                            *)
(* ─────────────────────────────────────── *)
```

**Documentation strings:**
```mathematica
MyFunction::usage = "MyFunction[x, y] computes x+y";
```

---

## Release Process

### Version Numbering

**Format:** `MAJOR.MINOR.PATCH`

**Examples:**
- `3.0.0`: Major release
- `3.1.0`: Minor release (new features)
- `3.3.1`: Patch release (bug fixes)

---

### Release Checklist

- [ ] All tests pass
- [ ] Documentation updated
- [ ] CHANGELOG updated
- [ ] Version numbers updated
- [ ] Tag created
- [ ] Release notes written

---

## Getting Help

### Resources

**Documentation:**
- README.md
- subdocs/ directory
- Inline comments

**Wolfram Resources:**
- https://reference.wolfram.com/
- https://community.wolfram.com/

**Project Resources:**
- Issue tracker
- Discussion forum
- Development chat

---

## Summary

**Development Workflow:**

1. ✅ Create feature branch
2. ✅ Implement changes
3. ✅ Write tests
4. ✅ Update documentation
5. ✅ Run all tests
6. ✅ Commit with clear message
7. ✅ Create pull request
8. ✅ Address review feedback
9. ✅ Merge to main

**Quality Standards:**

- ✅ All tests pass
- ✅ Code follows conventions
- ✅ Documentation complete
- ✅ No duplication
- ✅ Peer reviewed

**You're ready to contribute!** 🎉
