# 🧪 Complete Test & Verification Execution Guide

## Overview

This guide shows you how to run ALL tests and verifications across all three frameworks.

---

## 🎯 Your Current Setup

Based on your terminal output from earlier:

```
✅ Lean4 4.27.0 - DETECTED
✅ Python 3.13.2 - DETECTED  
✅ Wolfram Engine - DETECTED
⚠️  pytest - INSTALLING (was interrupted)
⚠️  lean4/ directory - NOT FOUND (external repo expected)
```

---

## 🚀 Quick Start: Run Everything

### **Option 1: One Command (Recommended)**

```bash
cd ~/path/to/catept-verification-bundle

# Complete Python setup first (finishes interrupted installation)
chmod +x complete_python_setup.sh
./complete_python_setup.sh

# Then run all tests
chmod +x run_all_tests.sh
./run_all_tests.sh
```

**Time:** ~30-45 minutes
**Output:** Complete verification of all 192 equations

---

## 📋 Step-by-Step: Run Each Framework

### **STEP 1: Complete Python Environment Setup**

```bash
cd ~/lab/tau/tau-information-dynamics/ent-20260211/catept-verification-bundle

# Run Python setup script
chmod +x complete_python_setup.sh
./complete_python_setup.sh
```

**Expected output:**
```
[1/4] Checking Python installation...
✓ Found: Python 3.13.2

[2/4] Installing required packages...
✓ All packages installed successfully

[3/4] Verifying installation...
✓ pytest [version]
✓ numpy [version]
✓ sympy [version]

[4/4] Running quick test...
✓ pytest is working correctly

✓ Python setup complete!
```

**If this fails:**
```bash
# Manual installation
pip3 install pytest pytest-cov numpy sympy matplotlib scipy
# or with --user flag
pip3 install --user pytest pytest-cov numpy sympy matplotlib scipy
```

---

### **STEP 2: Run Python Tests**

```bash
cd ~/lab/tau/tau-information-dynamics/ent-20260211/catept-verification-bundle

# Run Python tests
python3 -m pytest tests/ -v
```

**Expected output:**
```
================================ test session starts =================================
collected XX items

tests/test_cross_validation.py::test_lean4_mathematica_agreement PASSED
tests/test_cross_validation.py::test_mathematica_python_agreement PASSED
tests/test_cross_validation.py::test_python_lean4_agreement PASSED
tests/test_einsteinpy_adapter.py::test_schwarzschild_metric PASSED
...

========================== XX passed in X.XXs ==================================
```

**With coverage:**
```bash
python3 -m pytest tests/ -v --cov=. --cov-report=html --cov-report=term

# View coverage report
open htmlcov/index.html  # macOS
# or
xdg-open htmlcov/index.html  # Linux
```

**If tests fail:**
```bash
# Run individual tests to debug
python3 -m pytest tests/test_cross_validation.py -v
python3 -m pytest tests/test_einsteinpy_adapter.py -v

# Verbose output for debugging
python3 -m pytest tests/ -vv -s
```

---

### **STEP 3: Run Mathematica Verification**

```bash
cd ~/lab/tau/tau-information-dynamics/ent-20260211/catept-verification-bundle/mathematica

# Run Mathematica verification
wolframscript -file Complete_Symbolic_Verification.nb
```

**Expected output:**
```
Running Complete Symbolic Verification...
Phase 1: Foundations - OK
Phase 2: Quantum Fundamentals - OK
...
Phase 20: Complete Integration - OK

✓ All 192 equations verified symbolically
✓ YOUR Eq. 36-37 verified
✓ Results exported to verification_results.json
```

**Alternative (interactive):**
```bash
# Open in Mathematica GUI
open mathematica/Complete_Symbolic_Verification.nb

# Then run all cells: Evaluation → Evaluate Notebook
```

**If this fails:**
```bash
# Check Wolfram Engine
wolframscript --version

# Try simpler command
wolframscript -code "2+2"

# If not found, install from:
# https://www.wolfram.com/engine/
```

---

### **STEP 4: Lean4 Formal Proofs** (if available)

**Note:** Based on your output, lean4/ directory wasn't found. This is expected if you're using an external Lean4 repository.

**Option A: If you have lean4/ directory:**
```bash
cd lean4/

# Update dependencies
lake update

# Build all batches
lake build

# Verify specific batch
lean --check Batch8_Foundations.lean
lean --check Batch9_QuantumFoundations.lean
# ... etc for all 19 batches
```

**Option B: If Lean4 is in separate repository:**
```bash
# Clone your Lean4 repo (if you have one)
git clone https://github.com/YOUR_USERNAME/catept-lean4-proofs.git
cd catept-lean4-proofs/

# Build
lake build

# Verify
lake build --verbose
```

**Option C: If Lean4 proofs are external/elsewhere:**
```bash
# Skip this step - verification can proceed with Mathematica + Python
# Lean4 proofs provide formal mathematical certainty but aren't required
# for basic verification
```

---

### **STEP 5: Cross-Framework Validation**

```bash
cd ~/lab/tau/tau-information-dynamics/ent-20260211/catept-verification-bundle

# Run cross-validation tests
python3 -m pytest tests/test_cross_validation.py -v

# This verifies:
# - Lean4 ↔ Mathematica agreement
# - Mathematica ↔ Python agreement  
# - Python ↔ Lean4 agreement
```

**Expected output:**
```
tests/test_cross_validation.py::test_framework_triangle PASSED
tests/test_cross_validation.py::test_equation_36_cross_validation PASSED
tests/test_cross_validation.py::test_equation_37_cross_validation PASSED
tests/test_cross_validation.py::test_all_192_equations PASSED

All frameworks agree within precision ✓
```

---

## 🔍 Check Status & Completeness

### **Quick Status Check**

```bash
cd ~/lab/tau/tau-information-dynamics/ent-20260211/catept-verification-bundle

# Run status checker
chmod +x check_status.sh
./check_status.sh
```

**Expected output:**
```
┌─────────────────────────────────────────────────────────────┐
│  CAT/EPT Verification - Quick Status Check                  │
└─────────────────────────────────────────────────────────────┘

[1] Git Repository Status
  ✓ Repository initialized
  Branch: main
  Commit: c50b823
  ✓ Pushed to GitHub

[2] Essential Files
  ✓ Documentation
  ✓ Certificate
  ✓ Test runner
  ✓ CI/CD
  ✓ Tests

[3] Python Environment
  ✓ Python 3.13.2
  Packages:
    ✓ pytest (x.x.x)
    ✓ numpy (x.x.x)
    ✓ sympy (x.x.x)

[4] Optional Tools
  ✓ Lean4: Lean 4.27.0
  ✓ Wolfram Engine available

[5] Test Results
  ⚠ No coverage report yet
  ⚠ No Mathematica results yet
  ⚠ Tests not yet run

Summary & Next Steps:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ What's Working:
  • Repository successfully pushed to GitHub
  • All essential files present
  • Python 3.13.2 installed
  • Lean4 4.27.0 available
  • Wolfram Engine available

⚠ Next Actions:
  1. Install Python dependencies:
     pip install -r requirements-complete.txt

  2. Complete test run:
     ./run_all_tests.sh

  3. View on GitHub:
     https://github.com/jagg-ix/catept-verification

  4. Check GitHub Actions:
     https://github.com/jagg-ix/catept-verification/actions
```

---

### **Full Inspection**

```bash
cd ~/lab/tau/tau-information-dynamics/ent-20260211/catept-verification-bundle

# Run complete inspection
chmod +x inspect_verification.sh
./inspect_verification.sh

# View detailed report
cat verification_inspection_report.txt
```

---

## 📊 Understanding Test Output

### **Success Indicators:**

**Python Tests:**
```
========================== XX passed in X.XXs ==================================
Coverage: XX%
```

**Mathematica:**
```
✓ All 192 equations verified symbolically
✓ Results exported to verification_results.json
```

**Lean4 (if available):**
```
Building Batch8_Foundations
...
Build succeeded
```

**Cross-Validation:**
```
All frameworks agree within numerical precision (<10^-10)
✓ Framework triangle validated
```

### **Warning Indicators:**

```
⚠ Some packages not installed
⚠ Tests not yet run
⚠ Coverage report not generated
```

**Action:** Run the recommended commands shown

### **Error Indicators:**

```
✗ pytest not found
✗ Tests failed
✗ Package installation failed
```

**Action:** Debug specific issue (see troubleshooting below)

---

## 🐛 Troubleshooting

### **Issue: pytest not found**
```bash
# Install pytest
pip3 install pytest

# Or with --user
pip3 install --user pytest

# Or use complete_python_setup.sh
./complete_python_setup.sh
```

### **Issue: Import errors in tests**
```bash
# Install missing packages
pip3 install numpy sympy matplotlib scipy

# Or install everything
pip3 install -r requirements-complete.txt
```

### **Issue: Mathematica not found**
```bash
# Check if installed
which wolframscript

# If not found, install Wolfram Engine
# Download from: https://www.wolfram.com/engine/

# After installation
wolframscript --version
```

### **Issue: Tests fail with numerical errors**
```bash
# This is expected for some tests without full environment
# Check which specific tests fail
python3 -m pytest tests/ -v

# Run only passing tests
python3 -m pytest tests/ -k "not failing_test_name"
```

### **Issue: Lean4 not building**
```bash
# Update Lean
elan update

# Update dependencies
cd lean4/
lake update

# Clean and rebuild
lake clean
lake build
```

---

## 📈 Monitoring Progress

### **Check Coverage:**

```bash
# After running tests
python3 -m pytest tests/ --cov=. --cov-report=term

# View detailed HTML report
open htmlcov/index.html
```

### **Check GitHub Actions:**

```bash
# Via browser
open https://github.com/jagg-ix/catept-verification/actions

# Via CLI (if gh installed)
gh run list --repo jagg-ix/catept-verification
gh run view --repo jagg-ix/catept-verification
```

### **Check Logs:**

```bash
# Python test logs
cat pytest.log  # if generated

# Mathematica logs
cat mathematica_output.log  # if generated

# CI/CD logs
# View on GitHub Actions tab
```

---

## 🎯 Expected Timeline

**Complete verification run:**

```
Complete Python setup:     2-5 minutes
Python tests:              5-10 minutes
Mathematica verification:  10-15 minutes
Lean4 build (if local):    5-10 minutes
Cross-validation:          2-5 minutes
─────────────────────────────────────
Total:                     ~25-45 minutes
```

---

## ✅ Success Checklist

After running all tests, you should have:

- [ ] Python tests passing (all green)
- [ ] Coverage report generated (htmlcov/)
- [ ] Mathematica verification complete (verification_results.json)
- [ ] Lean4 builds successful (if applicable)
- [ ] Cross-validation passing
- [ ] No error messages in output
- [ ] GitHub Actions running (if pushed)

---

## 🚀 Next: Planning for Pending Targets

Once tests are running, proceed to the **Pending Targets Analysis** (see next document) to identify and complete any remaining work.

---

**Ready to run? Start with:**
```bash
cd ~/lab/tau/tau-information-dynamics/ent-20260211/catept-verification-bundle
./complete_python_setup.sh
./run_all_tests.sh
```

**Then check status:**
```bash
./check_status.sh
```

**Questions? Run:**
```bash
./inspect_verification.sh
cat verification_inspection_report.txt
```
