# Practical Patch Application Guide

**Goal:** Apply existing patches correctly as foundation for full implementation  
**Duration:** 1-2 hours  
**Result:** Working baseline EPT infrastructure in AMSS-NCKU  

---

## 🎯 Quick Decision Matrix

### **Choose Your Path:**

```
Do you need GPU support?
│
├─ NO (CPU-only development/testing)
│  └─ Apply: A → E → D → F → G
│     Time: 30 minutes
│     Complexity: LOW
│
└─ YES (GPU-enabled production)
   └─ Apply: A → C → D → E → F → G
      Time: 1 hour
      Complexity: MEDIUM (potential conflicts)
```

---

## 🔧 Path 1: CPU-Only (Recommended for Development)

### **Step-by-Step Application**

#### **Prerequisites:**
```bash
# 1. Have clean AMSS-NCKU source
cd ~/amss-ncku
git status  # Should be clean

# 2. Have patches accessible
ls ~/catept-verification/amss-integration/current/amss-ept-patchkit/patches/

# 3. Backup original
cp -r ~/amss-ncku ~/amss-ncku-original
```

---

#### **Patch 1: Add tauEnt0 Field**

```bash
cd ~/amss-ncku

# Apply
patch -p1 --dry-run < ~/path/to/stepA_tauEnt0.patch
# If dry-run succeeds:
patch -p1 < ~/path/to/stepA_tauEnt0.patch

# Verify
grep "tauEnt0" AMSS_NCKU_source/bssn_class.h
# Expected: var *tauEnt0;

echo "✅ Step A applied"
```

**What changed:**
- `AMSS_NCKU_source/bssn_class.h` - Added field declaration
- `AMSS_NCKU_source/bssn_class.C` - Added allocation/deallocation

---

#### **Patch 2: CPU EPT Evolution**

```bash
# Apply
patch -p1 --dry-run < ~/path/to/stepE_cpu_ept_fix_min2.patch

# Check for conflicts
# (Should apply cleanly after Step A)

patch -p1 < ~/path/to/stepE_cpu_ept_fix_min2.patch

# Verify
grep "apply_ept_sources" AMSS_NCKU_source/bssn_class.C | head -3
# Expected: function definition + multiple calls

echo "✅ Step E applied"
```

**What changed:**
- Added `apply_ept_sources()` function
- Added helper functions (matrix inversion, clamping)
- Inserted calls at RK integration points

---

#### **Patch 3: Environment Variables**

```bash
# Apply
patch -p1 < ~/path/to/stepD_env_gpu_dt_min2_ab.patch

# Verify
grep "AMSS_EPT_LAMBDA0" AMSS_NCKU_source/bssn_class.C
# Expected: getenv("AMSS_EPT_LAMBDA0")

echo "✅ Step D applied"
```

**What changed:**
- Replaced hardcoded parameters with env var reads
- Added static initialization pattern
- Made runtime configurable

---

#### **Patch 4: Backend Runtime Switch**

```bash
# Apply
patch -p1 < ~/path/to/stepF_backend_switch.patch

# Verify
grep "amss_backend_override" AMSS_NCKU_source/bssn_gpu_class.C
# Expected: function definition

echo "✅ Step F applied"
```

**What changed:**
- Added `AMSS_BACKEND` environment variable support
- Runtime CPU/GPU selection

---

#### **Patch 5: Input File Backend Parameter**

```bash
# Apply
patch -p1 < ~/path/to/stepG_backend_param_inputpar.patch

# Verify
grep "Backend" AMSS_NCKU_Input.py
# Expected: Backend = "auto"

echo "✅ Step G applied"
```

**What changed:**
- `AMSS_NCKU_Input.py` - Added Backend parameter
- `AMSS_NCKU_source/ABE.C` - Read backend from input
- `setup.py` - Propagate backend parameter

---

#### **Build & Test:**

```bash
# Clean build
make clean

# Build CPU version
make ABE

# Test that it compiles
./ABE --version  # or whatever works

echo "✅ All patches applied and built successfully!"
```

---

## 🔧 Path 2: GPU-Enabled (For Production)

### **Step-by-Step with Conflict Resolution**

#### **Steps 1-2: Same as CPU-Only**

```bash
# Apply A
patch -p1 < stepA_tauEnt0.patch

# Apply C (GPU version - before E!)
patch -p1 < stepC_gpu_ept_min2.patch

echo "✅ Steps A, C applied"
```

---

#### **Step 3: Environment Variables (Both CPU & GPU)**

```bash
# This patches BOTH bssn_class.C and bssn_gpu_class.C
patch -p1 < stepD_env_gpu_dt_min2_ab.patch

echo "✅ Step D applied to both CPU and GPU"
```

---

#### **Step 4: CPU EPT** ⚠️ **Potential Conflict**

```bash
# Try dry-run first
patch -p1 --dry-run < stepE_cpu_ept_fix_min2.patch

# If conflicts:
#   Option A: Skip Step E (use Step C GPU version for CPU too)
#   Option B: Manual merge
#   Option C: Apply with --merge flag

# Recommended: Try applying
patch -p1 < stepE_cpu_ept_fix_min2.patch

# If it fails, check what failed:
patch -p1 --dry-run < stepE_cpu_ept_fix_min2.patch 2>&1 | grep "FAILED"

# Manual fix if needed
```

**Conflict Resolution:**

If Step E conflicts with C, you have options:

1. **Keep GPU version for both** (simpler)
   ```bash
   # Skip Step E
   echo "Using GPU implementation for CPU path"
   ```

2. **Manual merge** (better, but harder)
   ```bash
   # Edit bssn_class.C manually
   # Ensure apply_ept_sources matches GPU version signature
   ```

---

#### **Steps 5-6: Backend Selection**

```bash
# These should apply cleanly
patch -p1 < stepF_backend_switch.patch
patch -p1 < stepG_backend_param_inputpar.patch

echo "✅ Steps F, G applied"
```

---

#### **Build GPU Version:**

```bash
# Clean
make clean

# Build GPU version
make ABEGPU

# Test
./ABEGPU --version

echo "✅ GPU build successful!"
```

---

## 🧪 Testing the Patched Code

### **Test 1: Baseline (EPT Disabled)**

```bash
# Run without EPT
./ABE

# Should work exactly as before
# No EPT effects (all parameters default to 0)
```

**Expected:** Normal BSSN evolution, no errors

---

### **Test 2: EPT Enabled (Minimal)**

```bash
# Enable with minimal parameters
export AMSS_EPT_LAMBDA0=1.0
export AMSS_EPT_SIGMA_TAU=0.1

./ABE

# Check output for tauEnt field
```

**Expected:** 
- Simulation runs
- tauEnt0 accumulates
- Small stress injection

---

### **Test 3: Backend Selection**

```bash
# Force CPU
export AMSS_BACKEND=cpu
./ABE
# Or ./ABEGPU (will use CPU path)

# Force GPU
export AMSS_BACKEND=gpu
./ABEGPU

# Auto (default)
unset AMSS_BACKEND
./ABEGPU
```

**Expected:** Backend switching works

---

## 🐛 Troubleshooting

### **Problem: Patch fails to apply**

```bash
# Error: "patch: **** malformed patch"

# Solution 1: Check patch format
file stepA_tauEnt0.patch
# Should be: ASCII text

# Solution 2: Check line endings
dos2unix stepA_tauEnt0.patch  # If needed

# Solution 3: Check patch level
patch -p0 < ...  # Try different -p levels
patch -p1 < ...
patch -p2 < ...
```

---

### **Problem: Conflicts between patches**

```bash
# Error: "Hunk #X FAILED"

# Solution 1: Check application order
# Must be: A → (C) → D → E → F → G

# Solution 2: Check if patch already applied
grep "tauEnt0" AMSS_NCKU_source/bssn_class.h
# If found, Step A already applied

# Solution 3: Reverse wrongly applied patch
patch -p1 -R < stepB_ept_sources_min2.patch
```

---

### **Problem: Compilation errors**

```bash
# Error: "undefined reference to..."

# Solution 1: Check all includes
grep "#include" AMSS_NCKU_source/bssn_class.C | grep -i ept
# Should have: <cmath>, <cstdlib>, <cstring>

# Solution 2: Check function definitions
grep "apply_ept_sources" AMSS_NCKU_source/bssn_class.C
# Should have: definition + calls

# Solution 3: Clean rebuild
make clean
rm -rf *.o
make ABE
```

---

### **Problem: Runtime errors**

```bash
# Error: Segfault or NaN

# Check 1: EPT parameters reasonable?
export AMSS_EPT_LAMBDA0=1.0   # Not 1e10!
export AMSS_EPT_SIGMA_TAU=0.1 # Not 1e20!

# Check 2: tauEnt0 allocated?
# Add debug output to verify

# Check 3: Try without EPT
unset AMSS_EPT_LAMBDA0
unset AMSS_EPT_SIGMA_TAU
./ABE  # Should work
```

---

## 📋 Verification Checklist

After applying all patches, verify:

### **Code Changes:**

- [ ] `bssn_class.h` has `var *tauEnt0;`
- [ ] `bssn_class.C` has `apply_ept_sources()` function
- [ ] `bssn_class.C` has multiple `apply_ept_sources()` calls
- [ ] `bssn_class.C` has `getenv("AMSS_EPT_LAMBDA0")`
- [ ] `AMSS_NCKU_Input.py` has `Backend = "auto"`
- [ ] `ABE.C` reads backend parameter
- [ ] If GPU: `bssn_gpu_class.h/.C` also modified

### **Build:**

- [ ] `make clean` succeeds
- [ ] `make ABE` succeeds (CPU)
- [ ] If GPU: `make ABEGPU` succeeds
- [ ] No compilation warnings about EPT code
- [ ] Executable runs

### **Functionality:**

- [ ] Runs with EPT disabled (default)
- [ ] Runs with EPT enabled (AMSS_EPT_LAMBDA0=1.0)
- [ ] Backend selection works (AMSS_BACKEND=cpu/gpu)
- [ ] Can set parameters via environment
- [ ] Can set backend via input file

---

## 📊 What You Have Now

### **After All Patches Applied:**

✅ **Infrastructure:**
- tauEnt0 field allocated
- Evolution hooks in place
- Stress injection points identified

✅ **Configurability:**
- Runtime parameters via env vars
- Backend selection (CPU/GPU)
- Input file parameters

✅ **Baseline Functionality:**
- Simplified EPT evolution
- Gradient-based stress tensor
- Backward compatible (disabled by default)

### **What's Still Missing:**

❌ **Correct Physics:**
- Equation 36 (proper Hessian + d'Alembertian)
- Equation 37 (imaginary curvature)
- Proper φ_ent field

❌ **Numerical Quality:**
- RK4 staging
- Constraint monitoring
- Convergence tests

❌ **Validation:**
- Unit tests
- Integration tests
- Comparison with theory

---

## 🎯 Next Steps

### **Immediate (After Patches):**

1. **Test baseline** - Ensure patches don't break anything
2. **Familiarize** - Understand code structure
3. **Document** - Note all injection points

### **Week 1 (Analysis):**

1. **Audit touchpoints** - Map all EPT code locations
2. **Derive equations** - 3+1 form of Equations 36-37
3. **Python reference** - Implement correct equations

### **Week 2+ (Implementation):**

1. **Add proper fields** - φ_ent, Π_ent with RK4
2. **Implement Eq 36** - Correct Hessian + □φ
3. **Validation** - Test against Python

(See AMSS_EPT_ANALYSIS_AND_IMPLEMENTATION_PLAN.md for full roadmap)

---

## 🔗 Related Documents

- **COMPLETE_PATCH_INVENTORY_AND_ANALYSIS.md** - Detailed patch analysis
- **AMSS_EPT_ANALYSIS_AND_IMPLEMENTATION_PLAN.md** - 10-phase plan
- **AMSS_EPT_PHASE_1_2_DETAILED_GUIDE.md** - Week 1-2 details
- **AMSS_EPT_EXECUTIVE_SUMMARY.md** - Quick start guide

---

## ✅ Success Criteria

**You've successfully applied patches if:**

1. ✅ Code compiles without errors
2. ✅ Runs with EPT disabled (backward compatible)
3. ✅ Can enable EPT with environment variables
4. ✅ Can switch CPU/GPU backend
5. ✅ All 6 useful patches applied (A, C, D, E, F, G) or (A, D, E, F, G for CPU-only)

**Then you're ready to:**
- Understand the code structure
- Begin proper implementation
- Follow the 10-week plan

---

**Time Investment:**
- CPU-only: 30 minutes
- GPU-enabled: 1 hour
- Troubleshooting: +30 minutes (if needed)

**Result:**
- Working EPT infrastructure
- Foundation for proper implementation
- Understanding of code structure

**Let's get those patches applied! 🚀**
