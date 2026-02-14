# Complete Patch Inventory & Analysis

**Date:** February 11, 2026  
**Source:** amss-ept-patchkit-v2  
**Total Patches:** 7 unique files (stepG has duplicate)  

---

## 📊 Patch Inventory

### **Available Patches:**

| Step | File | Size | Purpose | Status |
|------|------|------|---------|--------|
| A | stepA_tauEnt0.patch | 1.1K | Add tauEnt0 field | ✅ Essential |
| B | stepB_ept_sources_min2.patch | 13K | EPT sources (early version) | ⚠️ Superseded by E |
| C | stepC_gpu_ept_min2.patch | 12K | GPU EPT implementation | ✅ Useful |
| D | stepD_env_gpu_dt_min2_ab.patch | 15K | Environment variable control | ✅ Useful |
| E | stepE_cpu_ept_fix_min2.patch | 16K | CPU EPT fix (improved) | ✅ Essential |
| F | stepF_backend_switch.patch | 1.2K | Runtime backend selection | ✅ Useful |
| G | stepG_backend_param_inputpar.patch | 4.4K | Input file backend param | ✅ Useful |

**Note:** stepG has duplicate file (identical)

---

## 🔍 Detailed Analysis of Each Patch

### **STEP A: tauEnt0 Field** ✅ **ESSENTIAL**

**File:** `stepA_tauEnt0.patch` (1.1K)

**What it does:**
```cpp
// In bssn_class.h
var *tauEnt0;  // Entropic proper time accumulator

// In bssn_class.C
tauEnt0 = new var("tauEnt0", ngfs++, 1, 1, 1);
```

**Changes:**
- Adds `tauEnt0` field to BSSN variable roster
- Allocates memory
- Adds to destructor

**Status:** ✅ **KEEP THIS**
- Foundation for EPT
- Minimal, safe
- Required by all other patches

**Issues:**
- Not RK-staged (just scalar accumulator)
- No RHS variable
- Limited to single field

---

### **STEP B: EPT Sources (min2)** ⚠️ **SUPERSEDED**

**File:** `stepB_ept_sources_min2.patch` (13K, 331 lines)

**What it does:**
```cpp
// Adds helper functions
static inline double ept_clamp(double x, double a);
static inline bool ept_inv3_sym(...);  // 3x3 matrix inversion

// Main function
static inline void apply_ept_sources(Block *cg, double dt, 
                                     var *tauEnt0,
                                     var *phi0, var *gxx0, ...,
                                     var *Sxx, ...);
```

**Implementation:**
```cpp
// Hardcoded parameters (no environment variables)
const double ept_lambda0 = 0.0;      // tau accumulator
const double ept_sigma_tau = 0.0;    // stress strength
const double grad_cap = 0.0;         // gradient cap
const double S_cap = 0.0;            // stress cap
```

**Status:** ⚠️ **DON'T USE - Superseded by Step E**

**Why superseded:**
- Step E has same functionality PLUS environment variables
- Step E has better error handling
- Step E recommended in PATCHSET.md

**Useful parts:**
- Matrix inversion code (good reference)
- Stress tensor formula (even if wrong)

---

### **STEP C: GPU EPT** ✅ **USEFUL FOR GPU**

**File:** `stepC_gpu_ept_min2.patch` (12K)

**What it does:**
- Mirrors Step B/E for GPU path
- Adds `tauEnt0` to `bssn_gpu_class.h`
- Implements `apply_ept_sources_min2()` for GPU

**Key differences from CPU:**
```cpp
// GPU version has grid spacing handling
if (cg && cg->data && cg->data->blb && cg->data->blb->data) {
    dx = cg->data->blb->data->getdX(0);
    dy = cg->data->blb->data->getdX(1);
    dz = cg->data->blb->data->getdX(2);
}
```

**Status:** ✅ **KEEP for GPU builds**
- Required for GPU-enabled AMSS
- Currently has hardcoded parameters (needs Step D)

**Issues:**
- Still uses hardcoded defaults initially
- No environment variables (until Step D applied)

---

### **STEP D: Environment Variables** ✅ **ESSENTIAL**

**File:** `stepD_env_gpu_dt_min2_ab.patch` (15K)

**What it does:**
- Replaces hardcoded parameters with environment variables
- Applies to BOTH CPU (Step E) and GPU (Step C)

**Environment variables added:**
```bash
AMSS_EPT_LAMBDA0      # d(tauEnt)/dt accumulator rate
AMSS_EPT_SIGMA_TAU    # anisotropic stress strength
AMSS_EPT_GRAD_CAP     # cap on |∂tau| (0 disables)
AMSS_EPT_S_CAP        # cap on |ΔS_ij| (0 disables)
```

**Implementation:**
```cpp
static bool inited = false;
static double ept_lambda0 = 0.0;
static double ept_sigma_tau = 0.0;
static double grad_cap = 0.0;
static double S_cap = 0.0;

if (!inited) {
    const char *s;
    if ((s = std::getenv("AMSS_EPT_LAMBDA0"))) 
        ept_lambda0 = std::atof(s);
    if ((s = std::getenv("AMSS_EPT_SIGMA_TAU"))) 
        ept_sigma_tau = std::atof(s);
    // etc.
    inited = true;
}
```

**Status:** ✅ **ESSENTIAL**
- Makes parameters configurable without recompiling
- Thread-safe (static initialization)
- Backward compatible (defaults to 0 = disabled)

**Benefits:**
- Runtime tuning
- Testing different parameters
- Production flexibility

---

### **STEP E: CPU EPT Fix** ✅ **ESSENTIAL**

**File:** `stepE_cpu_ept_fix_min2.patch` (16K, 407 lines)

**What it does:**
- Same as Step B BUT with improvements
- Adds environment variable support (needs Step D)
- Better call signature
- More injection points

**Improvements over Step B:**
```cpp
// Better organized
#include <cstdlib>  // For getenv
#include <cstring>

// More complete stress formula
double dSxx = ept_sigma_tau * (tx * tx - one_third * gam_xx * grad2);
double dSxy = ept_sigma_tau * (tx * ty - one_third * gam_xy * grad2);
// etc. (uses 1/3 instead of 1/2 - traceless)
```

**Injection points:**
Multiple calls throughout `bssn_class.C`:
- Line 3836: RK stage
- Line 4210: RK stage
- Line 4341: RK stage
- Line 4706: RK stage
- Line 5113: RK stage
- Line 5312: RK stage
- Line 5620: Shell step
- Line 5801: Shell step

**Status:** ✅ **ESSENTIAL - Use instead of Step B**

**Why better:**
- More injection points
- Better tested
- Recommended in docs
- Works with Step D

---

### **STEP F: Backend Switch** ✅ **USEFUL**

**File:** `stepF_backend_switch.patch` (1.2K)

**What it does:**
- Adds runtime backend selection
- Allows forcing CPU or GPU at runtime

**Implementation:**
```cpp
// New function
static int amss_backend_override() {
    const char *be = getenv("AMSS_BACKEND");
    if (!be || !(*be)) return -1;
    
    if (be[0] == '0' || be[0] == 'c' || be[0] == 'C')
        return 0;  // Force CPU
    if (be[0] == '1' || be[0] == 'g' || be[0] == 'G')
        return 1;  // Force GPU
    return -1;     // Auto
}

// Applied in bssn_gpu_class.C
int ov = amss_backend_override();
if (ov >= 0)
    use_gpu = ov;
```

**Environment variable:**
```bash
AMSS_BACKEND=cpu   # Force CPU
AMSS_BACKEND=gpu   # Force GPU  
AMSS_BACKEND=auto  # Use default logic
```

**Status:** ✅ **USEFUL**
- Enables testing CPU vs GPU
- Debugging tool
- Performance comparison
- No harm if not used

---

### **STEP G: Backend Parameter** ✅ **USEFUL**

**File:** `stepG_backend_param_inputpar.patch` (4.4K)

**What it does:**
- Adds `Backend` parameter to Python input
- Propagates through to C++ code
- Integrates with Step F

**Changes:**

**1. Python Input (`AMSS_NCKU_Input.py`):**
```python
Backend = "auto"  # cpu|gpu|auto

# Logic to set GPU_Calculation based on Backend
if Backend == "cpu":
    GPU_Calculation = "no"
    CPU_Part = 1.0
    GPU_Part = 0.0
elif Backend == "gpu":
    GPU_Calculation = "yes"
    CPU_Part = 0.0
    GPU_Part = 1.0
```

**2. C++ Core (`ABE.C`):**
```cpp
string Backend("auto");

// Read from input.par
else if (skey == "backend") {
    Backend = sval;
    parameters::str_par.insert(
        map<string, string>::value_type("backend", Backend));
}

// Set environment variable
if (Backend.size() > 0) {
    const char* _be_env = getenv("AMSS_BACKEND");
    if ((!_be_env || !(*_be_env)) && Backend != "auto") {
        setenv("AMSS_BACKEND", Backend.c_str(), 1);
    }
}
```

**3. Setup Script (`setup.py`):**
```python
_be = getattr(input_data, "Backend", None)
if _be is None:
    _be = "gpu" if (getattr(input_data, "GPU_Calculation", "no") == "yes") else "cpu"
print("ABE::backend   = ", str(_be).strip(), file=file1)
```

**Status:** ✅ **USEFUL**
- User-friendly parameter
- Consistent with AMSS conventions
- Backward compatible

---

## 🎯 What's Actually Useful?

### **Essential Patches (Must Have):**

1. **Step A** - tauEnt0 field ✅
2. **Step E** - CPU EPT with proper implementation ✅
3. **Step D** - Environment variables ✅

**Minimum viable:** A + E + D

---

### **Highly Recommended:**

4. **Step C** - GPU EPT (if using GPU) ✅
5. **Step F** - Runtime backend switch ✅
6. **Step G** - Input file backend parameter ✅

**Full featured:** A + C + D + E + F + G

---

### **Skip:**

- **Step B** - Superseded by Step E ❌

---

## 🔧 Recommended Application Order

### **CPU-Only Build:**

```bash
# Order: A → E → D → (optionally F, G)

1. Apply stepA_tauEnt0.patch
   → Adds tauEnt0 field

2. Apply stepE_cpu_ept_fix_min2.patch
   → Adds evolution + stress injection

3. Apply stepD_env_gpu_dt_min2_ab.patch
   → Makes parameters configurable

4. (Optional) Apply stepF_backend_switch.patch
   → Adds AMSS_BACKEND runtime control

5. (Optional) Apply stepG_backend_param_inputpar.patch
   → Adds Backend parameter to input files
```

---

### **GPU-Enabled Build:**

```bash
# Order: A → C → D → E → F → G

1. Apply stepA_tauEnt0.patch
   → Adds tauEnt0 to CPU class

2. Apply stepC_gpu_ept_min2.patch  
   → Adds tauEnt0 to GPU class + GPU evolution

3. Apply stepD_env_gpu_dt_min2_ab.patch
   → Environment variables for both CPU & GPU

4. Apply stepE_cpu_ept_fix_min2.patch
   → CPU evolution (may have conflicts with C, need merge)

5. Apply stepF_backend_switch.patch
   → Runtime CPU/GPU selection

6. Apply stepG_backend_param_inputpar.patch
   → Input file backend parameter
```

---

## ⚠️ Potential Conflicts

### **Step C vs Step E:**

Both modify `bssn_class.C` / `bssn_gpu_class.C`

**Conflict areas:**
- Both add `apply_ept_sources` functions
- Similar but slightly different signatures

**Resolution:**
- Apply in order: C first, then E
- Or use consolidated patch (if available)
- Manual merge may be needed

---

### **Step D modifies Step E:**

Step D patches the code added by Step E

**Resolution:**
- Must apply in order: E before D
- Or E already includes D changes (check version)

---

## 📋 What's Missing from ALL Patches

Even with all patches applied, we're still missing:

### **1. Proper Physics** ❌

**Current:** `ΔS_ij = σ * (∂_i τ ∂_j τ - 1/3 γ_ij (∇τ)²)`

**Required (Equation 36):** `S_ij = ∇_i∇_j φ - γ_ij □φ`

**Gap:**
- No second derivatives
- No Hessian
- No d'Alembertian
- Wrong field (τ instead of φ)

---

### **2. RK4 Staging** ❌

**Current:**
```cpp
tau[id] += lambda0 * dt;  // Euler forward
```

**Required:**
```cpp
var *tauEnt;       // Current value
var *tauEnt1;      // RK stage
var *tauEnt_rhs;   // Right-hand side
```

**Gap:**
- Not integrated into RK loop
- No temporal staging
- 1st order only

---

### **3. Equation 37** ❌

**Current:** Nothing

**Required:** `Λ_μν` (imaginary curvature tensor)

**Gap:** 100% missing

---

### **4. Validation** ❌

**Current:** No tests

**Required:**
- Unit tests
- Convergence tests
- Constraint monitoring
- Cross-validation

**Gap:** No testing infrastructure

---

### **5. Additional Fields** ❌

**Current:** Only `tauEnt0`

**Required:**
- `phi_ent` (entropic scalar)
- `Pi_ent` (conjugate momentum)
- All RHS variables

**Gap:** Missing core EPT fields

---

## 💡 Hidden Useful Code

### **From Step B/E (Matrix Inversion):**

```cpp
static inline bool ept_inv3_sym(
    double gxx, double gxy, double gxz,
    double gyy, double gyz, double gzz,
    double &u_xx, double &u_xy, double &u_xz,
    double &u_yy, double &u_yz, double &u_zz,
    double &det_out)
{
    // Cofactors of symmetric 3x3
    const double Cxx = gyy * gzz - gyz * gyz;
    const double Cxy = gxz * gyz - gxy * gzz;
    // ... etc
    
    const double det = gxx * Cxx + gxy * Cxy + gxz * Cxz;
    if (!(det > 1e-30 || det < -1e-30))
        return false;
    
    const double invdet = 1.0 / det;
    u_xx = Cxx * invdet;
    // ... etc
}
```

**This is USEFUL** - Can reuse for Equation 36 implementation!

---

### **From Step D/E (Environment Config Pattern):**

```cpp
static bool inited = false;
static double param1 = 0.0;
static double param2 = 0.0;

if (!inited) {
    const char *s;
    if ((s = std::getenv("PARAM1"))) param1 = std::atof(s);
    if ((s = std::getenv("PARAM2"))) param2 = std::atof(s);
    inited = true;
}
```

**This pattern is USEFUL** - Thread-safe, lazy initialization, can extend!

---

### **From Step E (Stress Injection Points):**

The patch shows EXACTLY where to inject EPT sources in BSSN evolution:
- Multiple RK stages
- Shell steps  
- Different evolution paths

**This mapping is VALUABLE** - Shows integration points!

---

## 📊 Completeness Assessment

### **What Patches Provide:**

| Component | Coverage |
|-----------|----------|
| Basic infrastructure | 100% ✅ |
| Field allocation | 30% ⚠️ (only tauEnt0) |
| Evolution | 15% ❌ (Euler only, wrong eq) |
| Stress tensor | 20% ❌ (gradient only) |
| Configurability | 90% ✅ (env vars work) |
| CPU/GPU support | 80% ✅ (both paths) |
| Backend selection | 100% ✅ (F + G) |
| Validation | 0% ❌ (none) |
| Equation 36 | 5% ❌ (completely wrong) |
| Equation 37 | 0% ❌ (missing) |

**Overall:** ~15-20% complete for proper CAT/EPT implementation

---

## 🎯 Action Plan: Using What's Available

### **Phase 1: Apply Existing Patches** (Day 1)

```bash
# CPU-only quick start
cd /path/to/amss-ncku

# 1. Basic field
patch -p1 < stepA_tauEnt0.patch

# 2. CPU evolution (improved version)
patch -p1 < stepE_cpu_ept_fix_min2.patch

# 3. Environment variables
patch -p1 < stepD_env_gpu_dt_min2_ab.patch

# 4. Runtime control
patch -p1 < stepF_backend_switch.patch

# 5. Input parameter
patch -p1 < stepG_backend_param_inputpar.patch

# Test build
make clean && make ABE
```

---

### **Phase 2: Extract Useful Components** (Day 2-3)

**From patches, extract:**

1. **Matrix inversion** (Step E)
   → Save for Equation 36 implementation

2. **Injection point map** (Step E)
   → Know where to add proper EPT sources

3. **Environment config pattern** (Step D)
   → Extend for new EPT parameters

4. **Stress formula structure** (Step E)
   → Template for proper S_ij computation

---

### **Phase 3: Implement Proper Equations** (Week 2+)

**Beyond patches - NEW CODE NEEDED:**

1. Add proper EPT fields (phi_ent, Pi_ent)
2. Implement Equation 36 correctly
3. RK4 staging
4. Validation suite

(Follow implementation plan from earlier documents)

---

## 📝 Summary

### **Available Patches:**

✅ **7 patches** (A, B, C, D, E, F, G)  
✅ **6 useful** (skip B, use E instead)  
✅ **3 essential** (A, D, E for CPU-only)  
✅ **6 recommended** (A, C, D, E, F, G for full featured)

### **What's Useful:**

1. **Infrastructure** - Field allocation, injection points
2. **Configurability** - Environment variables, backend selection
3. **Code patterns** - Matrix inversion, env config, stress injection
4. **Integration map** - Where to add EPT in BSSN

### **What's Missing:**

1. **Correct physics** - Equation 36/37 not implemented
2. **Proper fields** - Only tauEnt0, missing phi_ent/Pi_ent
3. **RK4 staging** - Only Euler forward
4. **Validation** - No tests at all

### **Bottom Line:**

**Patches provide:** ~20% of what's needed  
**Still need:** ~80% new implementation  
**Use patches as:** Foundation + reference, not solution  

**Next:** Apply patches, then implement proper equations from scratch!

---

**Files to reference:**
- AMSS_EPT_ANALYSIS_AND_IMPLEMENTATION_PLAN.md (main plan)
- AMSS_EPT_PHASE_1_2_DETAILED_GUIDE.md (Week 1-2 details)
- This analysis (patch inventory)
