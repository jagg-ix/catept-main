# Troubleshooting Guide

Solutions to common issues encountered when using the Wolfram Verification Infrastructure.

---

## Installation Issues

### Issue: "wolframscript: command not found"

**Symptom:**
```bash
$ wolframscript --version
bash: wolframscript: command not found
```

**Causes:**
1. WolframScript not installed
2. Not in system PATH

**Solutions:**

**Solution 1: Install WolframEngine**
```bash
# Download from https://www.wolfram.com/engine/
# Run installer
# Activate license
```

**Solution 2: Add to PATH**
```bash
# Find WolframScript
find / -name wolframscript 2>/dev/null

# Add to PATH (Linux/macOS)
export PATH="/path/to/wolfram/bin:$PATH"

# Make permanent
echo 'export PATH="/path/to/wolfram/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

**Solution 3: Use full path**
```bash
/usr/local/Wolfram/WolframEngine/13.3/Executables/wolframscript --version
```

---

### Issue: License Activation Failed

**Symptom:**
```
License activation failed
Invalid Wolfram ID or password
```

**Solutions:**

**Solution 1: Verify Credentials**
- Check Wolfram ID at wolfram.com
- Reset password if needed
- Ensure account is active

**Solution 2: Network Issues**
```bash
# Check internet connection
ping wolfram.com

# Check firewall settings
# Ensure ports 80, 443 open
```

**Solution 3: Manual Activation**
```bash
# Run wolframscript
wolframscript

# Follow activation wizard
# Choose "Free Wolfram Engine for Developers"
```

**Solution 4: Contact Wolfram**
- Email: support@wolfram.com
- Include activation ID from error message

---

### Issue: "Permission denied" on Scripts

**Symptom:**
```bash
$ ./pipeline/run_all_verifications.sh
bash: ./pipeline/run_all_verifications.sh: Permission denied
```

**Solution:**
```bash
# Make executable
chmod +x pipeline/run_all_verifications.sh
chmod +x scripts/*.wls
chmod +x tests/*.wls

# Or run with wolframscript
wolframscript scripts/batch8_foundations.wls
```

---

## Execution Issues

### Issue: "File not found" Error

**Symptom:**
```
Cannot open lib/ComplexActionLib.wl
File not found
```

**Cause:** Running from wrong directory

**Solution:**
```bash
# Always run from WolframVerification/ root
cd /path/to/WolframVerification

# Then run scripts
wolframscript scripts/batch8_foundations.wls
```

**Verify directory structure:**
```bash
ls -la
# Should see: lib/ scripts/ tests/ pipeline/ etc.
```

---

### Issue: Import/Get Fails

**Symptom:**
```mathematica
Get::noopen: Cannot open lib/ComplexActionLib.wl
```

**Solutions:**

**Solution 1: Check file exists**
```bash
ls lib/ComplexActionLib.wl
# Should show file
```

**Solution 2: Check file path**
```mathematica
(* Debug script directory *)
Print["Script dir: ", $ScriptDir];
Print["Root dir: ", $RootDir];
Print["Library path: ", FileNameJoin[{$RootDir, "lib", "ComplexActionLib.wl"}]];
```

**Solution 3: Use absolute path**
```mathematica
Get["/full/path/to/lib/ComplexActionLib.wl"]
```

---

### Issue: Syntax Errors

**Symptom:**
```
Syntax::sntxf: "(" cannot be followed by ")".
```

**Solutions:**

**Solution 1: Check Wolfram Language Version**
```bash
wolframscript --version
# Need version >= 12.0
```

**Solution 2: Validate Syntax**
```mathematica
(* Use Mathematica to check *)
SyntaxQ["your code here"]
```

**Solution 3: Check for typos**
- Missing brackets: `( ) [ ]`
- Missing commas in lists
- Unmatched quotes

---

## Test Failures

### Issue: Numerical Test Fails

**Symptom:**
```
✗ Eq113_ComplexEinstein - FAILED
  Expected: 2.0
  Got: 1.9999999999
  Difference: 1.0e-10
```

**Causes:**
1. Tolerance too strict
2. Numerical precision issues
3. Actual error in computation

**Solutions:**

**Solution 1: Adjust Tolerance**
```mathematica
(* Before *)
VerifyNumerically[result, 2.0, 10^-15, "Too strict"]

(* After *)
VerifyNumerically[result, 2.0, 10^-10, "Reasonable"]
```

**Solution 2: Use Higher Precision**
```mathematica
(* Use arbitrary precision *)
x = 2.0`20;  (* 20 digits *)
y = 3.0`20;
result = x + y;
```

**Solution 3: Check Computation**
```mathematica
(* Add debug output *)
Print["Intermediate values: ", intermediate];
Print["Final result: ", result];
Print["Expected: ", expected];
Print["Difference: ", Abs[result - expected]];
```

---

### Issue: All Tests Fail

**Symptom:**
```
========================================
SUMMARY: 0/20 tests PASSED
========================================
```

**Possible Causes:**
1. Library not loaded
2. Wrong directory
3. Corrupted files
4. Version incompatibility

**Solutions:**

**Solution 1: Verify Installation**
```bash
# Check files exist
ls lib/*.wl
ls scripts/*.wls

# Redownload if needed
```

**Solution 2: Check Dependencies**
```mathematica
(* Test loading libraries *)
Get["lib/ComplexActionLib.wl"]
Get["lib/TestFramework.wl"]

(* Should load without errors *)
```

**Solution 3: Minimal Test**
```mathematica
(* Create minimal test *)
TestCase["Basic",
  VerifyNumerically[2+2, 4, 10^-10, "Sanity check"]
]
```

---

### Issue: Intermittent Failures

**Symptom:**
Tests pass sometimes, fail other times

**Causes:**
1. Numerical instability
2. Uninitialized variables
3. Random number generators
4. Race conditions

**Solutions:**

**Solution 1: Seed Random Numbers**
```mathematica
SeedRandom[12345];  (* Fixed seed *)
```

**Solution 2: Initialize All Variables**
```mathematica
Module[{x, y, z},
  x = 0.0;  (* Initialize *)
  y = 0.0;
  z = 0.0;
  (* ... *)
]
```

**Solution 3: Increase Precision**
```mathematica
(* Use exact arithmetic where possible *)
x = 2;  (* Exact *)
y = 1/3;  (* Exact rational *)
```

---

## Performance Issues

### Issue: Slow Execution

**Symptom:**
Tests take much longer than expected

**Solutions:**

**Solution 1: Profile Code**
```mathematica
Timing[
  (* Your code here *)
]
```

**Solution 2: Optimize Loops**
```mathematica
(* Before: Slow *)
Do[result = ComputeValue[i], {i, 1, 1000}]

(* After: Fast *)
result = ComputeValue /@ Range[1000];
```

**Solution 3: Clear Unnecessary Data**
```mathematica
ClearAll[largeData];
```

---

### Issue: Out of Memory

**Symptom:**
```
General::nomem: The current computation was aborted because there was 
insufficient memory available to complete the computation.
```

**Solutions:**

**Solution 1: Clear Variables**
```mathematica
ClearAll["Global`*"];
```

**Solution 2: Use Streaming**
```mathematica
(* Instead of storing all results *)
results = Table[Compute[i], {i, 1, 10000}];

(* Stream and process *)
Do[
  result = Compute[i];
  Process[result];
  , {i, 1, 10000}
]
```

**Solution 3: Increase Memory Limit**
```bash
# Run with more memory (if available)
wolframscript -script batch.wls
```

---

## Platform-Specific Issues

### Linux Issues

**Issue: Library Not Found**
```bash
error while loading shared libraries: libz.so.1
```

**Solution:**
```bash
# Install missing library
sudo apt-get install zlib1g  # Ubuntu/Debian
sudo dnf install zlib  # Fedora
```

---

**Issue: GTK Warnings**
```
Gtk-WARNING **: cannot open display
```

**Solution:**
```bash
# Run in non-interactive mode
wolframscript -noprompt -script batch.wls
```

---

### macOS Issues

**Issue: "Unidentified Developer" Warning**

**Solution:**
```bash
# Allow WolframScript
sudo spctl --add /Applications/Wolfram\ Engine.app

# Or in System Preferences → Security & Privacy
```

---

**Issue: PATH Not Persisting**

**Solution:**
```bash
# Add to .zshrc (macOS Catalina+)
echo 'export PATH="/Applications/Wolfram Engine.app/Contents/MacOS:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

---

### Windows Issues

**Issue: PowerShell Execution Policy**

**Symptom:**
```
cannot be loaded because running scripts is disabled
```

**Solution:**
```powershell
# Run as Administrator
Set-ExecutionPolicy RemoteSigned

# Or for current user
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

**Issue: Line Ending Problems**

**Symptom:**
Scripts fail with strange errors

**Solution:**
```bash
# Convert to Unix line endings
dos2unix scripts/*.wls
dos2unix tests/*.wls

# Or use Git
git config core.autocrlf input
```

---

## Common Error Messages

### "Divide by zero"

**Symptom:**
```
Power::infy: Infinite expression 1/0 encountered
```

**Solution:**
```mathematica
(* Add checks *)
If[denominator != 0,
  result = numerator/denominator,
  Print["Warning: Division by zero"];
  result = 0
]
```

---

### "Recursion limit exceeded"

**Symptom:**
```
$RecursionLimit::reclim: Recursion depth of 1024 exceeded
```

**Solution:**
```mathematica
(* Increase limit *)
$RecursionLimit = 2048;

(* Or fix recursive function *)
```

---

### "Maximum iteration count exceeded"

**Symptom:**
```
NIntegrate::maxp: Maximum number of iterations reached
```

**Solution:**
```mathematica
(* Increase precision goal *)
NIntegrate[f[x], {x, 0, 1}, 
  MaxRecursion -> 20,
  PrecisionGoal -> 6
]
```

---

## Debugging Strategies

### Strategy 1: Isolate the Problem

**Steps:**
1. Identify failing test
2. Extract to minimal example
3. Test in isolation
4. Fix issue
5. Re-integrate

**Example:**
```mathematica
(* Original failing test *)
TestCase["Complex_Test", ...]

(* Minimal reproduction *)
x = 2.0;
y = 3.0;
result = x + y;
Print[result];  (* Debug *)
```

---

### Strategy 2: Add Diagnostic Output

**Before:**
```mathematica
result = ComputeValue[x, y];
VerifyNumerically[result, expected, tol, "Test"]
```

**After:**
```mathematica
Print["Input x: ", x];
Print["Input y: ", y];
result = ComputeValue[x, y];
Print["Result: ", result];
Print["Expected: ", expected];
Print["Difference: ", Abs[result - expected]];
VerifyNumerically[result, expected, tol, "Test"]
```

---

### Strategy 3: Binary Search

**For multiple failures:**
1. Comment out half the tests
2. See if failures persist
3. Narrow down problematic region
4. Repeat until found

---

### Strategy 4: Check Dependencies

**Verify:**
```mathematica
(* What's loaded? *)
?Global`*

(* Clear and reload *)
ClearAll["Global`*"];
Get["lib/ComplexActionLib.wl"];
Get["lib/TestFramework.wl"];
```

---

## Getting Additional Help

### Check Documentation

1. **This guide** (TROUBLESHOOTING.md)
2. **Installation guide** (INSTALLATION.md)
3. **Usage guide** (USAGE_GUIDE.md)
4. **Architecture** (ARCHITECTURE.md)

---

### Search Issues

**Look for similar problems:**
- Check closed issues
- Search error messages
- Look in documentation

---

### Ask for Help

**When asking:**
- Include error message
- Include steps to reproduce
- Include WolframScript version
- Include operating system
- Include what you've tried

**Where to ask:**
- Project issue tracker
- Wolfram Community forum
- Stack Exchange (Mathematica)

---

### Report Bugs

**Include:**
- Minimal reproducible example
- Expected behavior
- Actual behavior
- Environment details
- Logs/screenshots

**Template:**
```markdown
## Bug Report

**Description:**
Brief description of issue

**Steps to Reproduce:**
1. Step 1
2. Step 2
3. ...

**Expected:**
What should happen

**Actual:**
What actually happens

**Environment:**
- OS: 
- WolframScript version:
- Batch:

**Logs:**
```
Paste error messages
```
```

---

## Quick Diagnostic Checklist

**Before asking for help, check:**

- [ ] WolframScript installed and in PATH
- [ ] License activated
- [ ] Running from correct directory
- [ ] All files present
- [ ] Correct file permissions
- [ ] Latest version of scripts
- [ ] Checked this troubleshooting guide
- [ ] Searched existing issues
- [ ] Created minimal reproduction

---

## Common Solutions Summary

| Problem | Quick Fix |
|---------|-----------|
| Command not found | Add to PATH or use full path |
| Permission denied | `chmod +x` |
| File not found | Run from root directory |
| Test fails | Check tolerance, verify computation |
| Slow execution | Profile and optimize |
| Out of memory | Clear variables, use streaming |
| License issues | Re-activate, check network |
| Syntax error | Check version, validate syntax |

---

## Emergency Procedures

### Complete Reset

```bash
# 1. Remove installation
rm -rf WolframVerification

# 2. Redownload
git clone <repository-url>

# 3. Verify installation
cd WolframVerification
wolframscript scripts/batch8_foundations.wls
```

---

### Nuclear Option

```bash
# Uninstall and reinstall WolframEngine
# (Only if nothing else works)

# 1. Uninstall WolframEngine
# 2. Remove configuration
rm -rf ~/.Wolfram
# 3. Reinstall fresh
# 4. Reactivate license
# 5. Test
```

---

## Still Having Issues?

If problems persist after trying these solutions:

1. ✅ Check all documentation
2. ✅ Search closed issues
3. ✅ Create minimal example
4. ✅ Report bug with details

**We're here to help!** 🎉

---

**Remember:** Most issues are simple to fix with the right approach. Stay calm, methodical debugging will solve it!
