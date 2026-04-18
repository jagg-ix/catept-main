# Usage Guide

Complete guide for using the Wolfram Verification Infrastructure to verify CAT/EPT equations.

---

## Quick Start

### Your First Verification

```bash
# Navigate to root directory
cd WolframVerification

# Run a single batch
wolframscript scripts/batch8_foundations.wls
```

**That's it!** The script will:
1. Load necessary libraries
2. Run all verification tests
3. Display results
4. Exit with status code (0 = success, 1 = failure)

---

## Basic Usage

### Running Individual Batches

**Syntax:**
```bash
wolframscript scripts/batch<N>_<name>.wls
```

**Examples:**
```bash
# Batch 8: Foundations
wolframscript scripts/batch8_foundations.wls

# Batch 13: Complex Einstein (Core Theory)
wolframscript scripts/batch13_einstein_time.wls

# Batch 17: ENZ/SGI Predictions
wolframscript scripts/batch17_final_enz.wls
```

**Output:**
```
========================================
BATCH 13: COMPLEX EINSTEIN & TIME
⭐⭐⭐ MOST IMPORTANT BATCH! ⭐⭐⭐
========================================

Running all Batch 13 tests...

✓ Test 1: Eq113_ComplexEinstein_FUNDAMENTAL - PASSED
✓ Test 2: Eq119_SI_FromMeasure_ORIGIN - PASSED
...

========================================
SUMMARY: 16/16 tests PASSED
========================================

✓ All Batch 13 verifications PASSED
✓ CORE THEORETICAL RESULTS CONFIRMED!
```

---

### Running Test Suites

Test suites provide comprehensive regression testing:

```bash
# Navigate to tests directory
cd tests

# Run test suite for a batch
wolframscript test_batch8.wls
```

**Output:**
```
========================================
BATCH 8 FOUNDATIONS TEST SUITE
========================================

Running Batch 8 regression tests...

✓ Regression_ComplexAction - PASSED
✓ Regression_EntropicTime - PASSED
✓ EdgeCase_ZeroLambda - PASSED
...

========================================
SUMMARY: 30/30 tests PASSED
========================================
```

---

### Running Full Pipeline

Execute all batches in sequence:

```bash
# From root directory
./pipeline/run_all_verifications.sh
```

**This will:**
1. Run Batch 8 through Batch 17 sequentially
2. Display progress for each batch
3. Show final summary
4. Exit with overall status

**Output:**
```
========================================
RUNNING ALL VERIFICATIONS
========================================

[Batch 8/10] Running batch8_foundations.wls...
✓ Batch 8: 20/20 tests PASSED

[Batch 9/10] Running batch9_qrf.wls...
✓ Batch 9: 20/20 tests PASSED

...

[Batch 17/10] Running batch17_final_enz.wls...
✓ Batch 17: 19/19 tests PASSED

========================================
ALL VERIFICATIONS COMPLETE
========================================

Total: 192/192 equations verified
Status: ALL PASSED ✓
```

---

## Advanced Usage

### Custom Output Location

**Redirect output to file:**
```bash
wolframscript scripts/batch8_foundations.wls > my_results.log 2>&1
```

**Both stdout and stderr:**
```bash
wolframscript scripts/batch8_foundations.wls 2>&1 | tee results.txt
```

---

### Running Specific Tests

**From within Mathematica:**
```mathematica
(* Load the batch script *)
Get["scripts/batch8_foundations.wls"]

(* Or run specific test *)
Get["lib/TestFramework.wl"]
Get["lib/ComplexActionLib.wl"]

TestCase["MyTest",
  Module[{...},
    VerifyNumerically[2+2, 4, 10^-10, "Basic math"]
  ]
]
```

---

### Batch-by-Batch Guide

#### Batch 8: Foundations (Equations 22-41)

**What it tests:**
- Complex action definition
- Entropic time
- Damping factors
- Norm evolution

**Run:**
```bash
wolframscript scripts/batch8_foundations.wls
```

**Key equations:**
- Eq 22: χ = S_R + iℏτ_ent
- Eq 24: τ_ent = ∫λdt
- Eq 25: Damping exp(-τ_ent)

---

#### Batch 9: Quantum Reference Frames (Equations 42-61)

**What it tests:**
- QRF transformations
- Observer-dependent physics
- Frame-dependent entanglement

**Run:**
```bash
wolframscript scripts/batch9_qrf.wls
```

**Key equations:**
- Eq 42: Unitary transformations
- Eq 47: Frame-dependent τ_ent
- Eq 59: Quantum Fisher info conserved

---

#### Batch 10: Path Integrals (Equations 62-81)

**What it tests:**
- Path integral formulation
- Wick rotation
- Convergence properties

**Run:**
```bash
wolframscript scripts/batch10_pathintegrals.wls
```

**Key equations:**
- Eq 62: Path weight |exp(iχ/ℏ - τ_ent)|
- Eq 72: Euclidean action
- Eq 81: Convergence via entropic damping

---

#### Batch 13: Complex Einstein (Equations 112-127) ⭐⭐⭐

**What it tests:**
- **CORE THEORY**
- Complex Einstein equations
- Dissipation origin
- Anomaly cancellation

**Run:**
```bash
wolframscript scripts/batch13_einstein_time.wls
```

**Critical equations:**
- **Eq 113:** G + iΛ = κ(T + iS) ⭐⭐⭐
- **Eq 119:** S_I = ℏ∫μ̇/μ ⭐⭐⭐
- **Eq 127:** Ω^std + Ω^ent ≈ 0 ⭐⭐⭐

---

#### Batch 14: Black Holes (Equations 128-142) ⭐⭐⭐

**What it tests:**
- Schwarzschild solution
- Π hierarchy
- Black hole thermodynamics

**Run:**
```bash
wolframscript scripts/batch14_blackholes.wls
```

**Critical equations:**
- **Eq 137:** Π = 1 exactly at horizon ⭐⭐⭐
- **Eq 141:** Π hierarchy 10^-29 → 1 ⭐⭐⭐

---

#### Batch 17: ENZ/SGI (Equations 173-192) ⭐⭐⭐

**What it tests:**
- **EXPERIMENTAL PREDICTIONS**
- Visibility decay
- Geometric enhancement

**Run:**
```bash
wolframscript scripts/batch17_final_enz.wls
```

**Critical equations:**
- **Eq 174:** V(S) = V_cl·exp(-λS) ⭐⭐⭐
- **Eq 178:** λ_ent = λ_thermal·n_g ⭐⭐⭐

---

## Interpreting Results

### Success Output

```
✓ Test Name - PASSED
```

**Meaning:** Equation verified numerically, agrees with expected value

---

### Failure Output

```
✗ Test Name - FAILED
  Expected: 1.0
  Got: 0.999
  Difference: 0.001
```

**Action:** 
1. Check if tolerance too strict
2. Verify equation implementation
3. Cross-check with Lean proof
4. Report if genuine error

---

### Summary Statistics

```
========================================
SUMMARY: X/Y tests PASSED
========================================
```

- **X/Y:** Tests passed / Total tests
- **100%:** All tests passed ✓
- **< 100%:** Some failures, investigate

---

## Common Workflows

### Workflow 1: Verify Specific Equation

```bash
# 1. Find which batch contains equation
# See BATCH_DETAILS.md for mapping

# 2. Run that batch
wolframscript scripts/batch13_einstein_time.wls

# 3. Check output for specific equation
# Look for Eq113 in output
```

---

### Workflow 2: Full Verification

```bash
# Run complete pipeline
./pipeline/run_all_verifications.sh

# Check exit code
echo $?
# 0 = all passed
# 1 = some failed
```

---

### Workflow 3: Continuous Testing

```bash
# Run tests on file change (requires entr or similar)
ls scripts/*.wls tests/*.wls | entr -c ./pipeline/run_all_verifications.sh
```

---

### Workflow 4: Regression Testing

```bash
# Save baseline results
./pipeline/run_all_verifications.sh > baseline.log

# Make changes...

# Compare with baseline
./pipeline/run_all_verifications.sh > new.log
diff baseline.log new.log
```

---

## Integration with Other Tools

### Git Hooks

**Pre-commit hook:**
```bash
#!/bin/bash
# .git/hooks/pre-commit

cd WolframVerification
./pipeline/run_all_verifications.sh

if [ $? -ne 0 ]; then
    echo "Verification failed! Commit aborted."
    exit 1
fi
```

---

### Make Integration

**Makefile:**
```makefile
.PHONY: verify test clean

verify:
	./pipeline/run_all_verifications.sh

test:
	cd tests && for f in test_*.wls; do wolframscript $$f || exit 1; done

clean:
	rm -f outputs/logs/*.log
```

**Usage:**
```bash
make verify  # Run all verifications
make test    # Run all test suites
make clean   # Clean log files
```

---

### CI/CD Integration

**GitHub Actions:**
```yaml
name: Verify Equations
on: [push, pull_request]

jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Install WolframEngine
        run: |
          # Install steps here
          
      - name: Run Verification
        run: |
          cd WolframVerification
          ./pipeline/run_all_verifications.sh
```

---

## Performance Tips

### Optimize Runtime

**Sequential (default):**
- Run one batch at a time
- ~2 minutes total
- Deterministic output

**Parallel (advanced):**
```bash
# Run batches in parallel (experimental)
for batch in scripts/batch*.wls; do
    wolframscript "$batch" &
done
wait
```
- Faster (~30 seconds)
- May have race conditions
- Use with caution

---

### Memory Management

**For large runs:**
```bash
# Increase memory limit (if needed)
wolframscript -noprompt -script batch13_einstein_time.wls
```

**Monitor usage:**
```bash
# Linux/macOS
time wolframscript scripts/batch8_foundations.wls
```

---

## Troubleshooting

### Common Issues

**Issue:** "File not found"
**Solution:** Always run from `WolframVerification/` root

**Issue:** "Test failed"
**Solution:** Check TROUBLESHOOTING.md

**Issue:** "Permission denied"
**Solution:** `chmod +x pipeline/run_all_verifications.sh`

See [Troubleshooting Guide](TROUBLESHOOTING.md) for more.

---

## Next Steps

After mastering basic usage:

1. ✅ Read [Batch Details](BATCH_DETAILS.md) for equation breakdown
2. ✅ Review [Testing Guide](TESTING_GUIDE.md) for writing tests
3. ✅ Explore [Development](DEVELOPMENT.md) for contributing
4. ✅ Check scientific results in milestone documents

---

## Summary

**Essential Commands:**

```bash
# Single batch
wolframscript scripts/batch8_foundations.wls

# Test suite
wolframscript tests/test_batch8.wls

# Full pipeline
./pipeline/run_all_verifications.sh

# With logging
./pipeline/run_all_verifications.sh > results.log 2>&1
```

**Remember:**
- Always run from `WolframVerification/` root
- Check exit codes (0 = success, 1 = failure)
- Review output for specific equation results
- Use test suites for comprehensive checking

**You're ready to verify 192 equations!** 🎉
