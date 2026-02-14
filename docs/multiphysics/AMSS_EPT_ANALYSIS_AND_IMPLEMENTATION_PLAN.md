# AMSS-NCKU Entropic Proper Time: Analysis & Implementation Plan

**Date:** February 11, 2026  
**Project:** CAT/EPT Verification Framework - AMSS-NCKU Adapter  
**Status:** Analysis Complete → Implementation Planning  

---

## 📊 Executive Summary

**Current State:**
- ✅ Patchkit exists (`amss-ept-patchkit-v2`)
- ✅ Basic `tauEnt0` field implementation
- ✅ Stress tensor injection mechanism
- ⚠️ **INCOMPLETE**: Missing full theoretical alignment
- ⚠️ **POTENTIALLY WRONG**: Simplified approximations

**Goal:**
Create a **production-grade adapter** that:
1. Implements YOUR entropic proper time equations (36-37) correctly
2. Integrates with catept-verification framework
3. Provides validation against Lean4/Mathematica/Python
4. Enables numerical experiments for the paper

---

## 🔍 Part 1: Critical Analysis of Existing Patchkit

### **What's Currently Implemented**

#### **A. Field Introduction** ✅ (CORRECT)
```cpp
// In bssn_class.h
var *tauEnt0;  // Entropic proper time accumulator
```

**Status:** ✅ **CORRECT**  
**Rationale:** Properly adds scalar field to BSSN infrastructure

---

#### **B. Tau Evolution** ⚠️ (OVERSIMPLIFIED)

**Current Implementation:**
```cpp
// Option B-min-2: Simplified accumulation
tau[id] += ept_lambda0 * dt;  // Constant rate!
```

**Formula Claimed:**
```
∂τ/∂t = λ₀ + α |∇τ|²
```

**Problems:**
1. ❌ **MISSING**: The `α |∇τ|²` term is NOT implemented
2. ❌ **WRONG**: Uses Euler forward (unstable)
3. ❌ **INCOMPLETE**: No coupling to lapse α
4. ❌ **MISSING**: Should be `∂τ/∂t = α(λ₀ + ...)`

**What YOUR Paper Actually Says (Equation 36):**
```
S_μν = ∇_μ∇_ν φ - g_μν □φ
```
Where φ is related to entropic potential, NOT directly τ.

**Verdict:** ⚠️ **NEEDS MAJOR REVISION**

---

#### **C. Stress Tensor Injection** ⚠️ (PARTIALLY CORRECT)

**Current Implementation:**
```cpp
// Physical stress tensor addition
ΔS_ij = σ * (∂_i τ ∂_j τ - 1/3 γ_ij (∇τ)²)
```

**Analysis:**

**Correct Elements:**
- ✅ Uses physical metric γ_ij (with e^{4φ} factor)
- ✅ Computes gradient properly (centered differences)
- ✅ Inverts conformal metric correctly
- ✅ Traceless part construction (using 1/3 instead of 1/2)

**Problems:**
1. ⚠️ **DIFFERENT FROM PAPER**: Paper has `S_μν = ∇_μ∇_ν φ - g_μν □φ`
2. ⚠️ **SIMPLIFIED**: Missing second derivatives (∇∇ term)
3. ⚠️ **MISSING**: No connection to Equation 37 (Λ_μν)
4. ⚠️ **HARDCODED**: Uses 1/3 (should derive from theory)

**What Paper Says:**
```
Equation 36: S_μν = ∇_μ∇_ν φ - g_μν □φ
Equation 37: Λ_μν (imaginary curvature tensor)
```

**Verdict:** ⚠️ **NEEDS THEORETICAL ALIGNMENT**

---

#### **D. Numerical Stability** ❌ (POOR)

**Current Issues:**

1. **Euler Forward Integration:**
   ```cpp
   tau[id] += ept_lambda0 * dt;  // UNSTABLE!
   ```
   - ❌ First-order accuracy
   - ❌ No RK4 integration
   - ❌ Not staged like other BSSN variables

2. **Boundary Handling:**
   ```cpp
   const int bw = 1;  // Only 1 ghost zone
   ```
   - ❌ Insufficient for 4th-order stencils
   - ❌ No Kreiss-Oliger dissipation
   - ❌ No constraint damping

3. **No Conservation Checks:**
   - ❌ No Hamiltonian constraint monitoring
   - ❌ No momentum constraint monitoring
   - ❌ No energy conservation check

**Verdict:** ❌ **NUMERICALLY UNSTABLE**

---

### **What's MISSING**

#### **1. Full RK4 Integration** ❌

**Problem:** `tauEnt0` is not RK-staged

**Should Have:**
```cpp
var *tauEnt0;     // Current value
var *tauEnt;      // Evolved value
var *tauEnt1;     // RK stage 1
var *tauEnt_rhs;  // Right-hand side
```

**Impact:** ❌ Cannot maintain 4th-order temporal accuracy

---

#### **2. Second Derivative Terms** ❌

**Missing from Equation 36:**
```
S_μν = ∇_μ∇_ν φ - g_μν □φ
       ^^^^^^^^^^   (missing!)
```

**Required:**
- Hessian of φ: ∇_μ∇_ν φ
- d'Alembertian: □φ = ∇^μ ∇_μ φ
- Connection coefficients Γ^λ_{μν}

**Impact:** ❌ Wrong stress-energy tensor

---

#### **3. Equation 37 Implementation** ❌

**Completely Missing:**
```
Λ_μν = imaginary curvature tensor
```

**Required:**
- Complex-valued curvature modification
- Imaginary time coupling
- Phase space structure

**Impact:** ❌ Missing half of the theory!

---

#### **4. Lapse Coupling** ❌

**Problem:** Evolution should be:
```
∂τ/∂t = α * (λ₀ + α_coeff * |∇τ|²)
        ^
        Missing!
```

Not just:
```
∂τ/∂t = λ₀  // Current (wrong)
```

**Impact:** ❌ Wrong relationship to coordinate time

---

#### **5. Validation Infrastructure** ❌

**Missing:**
- Unit tests for entropic equations
- Convergence tests
- Comparison with analytic solutions
- Integration with catept-verification framework

**Impact:** ❌ Cannot verify correctness!

---

## 🎯 Part 2: Theoretical Requirements

### **From YOUR CAT/EPT Paper**

#### **Core Equations to Implement:**

**Equation 36 - Entropic Stress Tensor:**
```
S_μν = ∇_μ∇_ν φ - g_μν □φ

Where:
  φ = entropic scalar field
  ∇_μ∇_ν = covariant second derivative
  □ = d'Alembertian operator
  g_μν = spacetime metric
```

**Equation 37 - Imaginary Curvature Tensor:**
```
Λ_μν = (complex-valued curvature modification)

Couples to:
  - Imaginary proper time
  - Phase space structure
  - Quantum-classical transition
```

**Modified Einstein Equations:**
```
G_μν + Λ_μν = 8πG (T_μν + S_μν)
              ^^^^         ^^^^
              New!         From Eq. 36
```

---

### **3+1 Decomposition Requirements**

**BSSN Variables Needed:**

1. **Scalar Field:**
   ```
   φ (entropic potential)
   Π_φ (conjugate momentum)
   ```

2. **3+1 Split of S_μν:**
   ```
   ρ_ent = n^μ n^ν S_μν         (energy density)
   j^i_ent = -γ^{iμ} n^ν S_μν   (momentum density)
   S^{ij}_ent = γ^{iμ} γ^{jν} S_μν  (stress tensor)
   ```

3. **Connection to τ:**
   ```
   ∂_t τ = α L(τ)
   
   Where L(τ) includes:
     - Lapse-weighted accumulation
     - Nonlinear gradient terms
     - Curvature coupling
   ```

---

## 🔧 Part 3: Implementation Plan (10 Phases)

### **Phase 1: Code Audit & Documentation** (Week 1)

**Tasks:**
1. ✅ Extract and analyze patchkit (DONE)
2. ⏳ Map all BSSN-EPT touchpoints
3. ⏳ Document current vs. required equations
4. ⏳ Create gap analysis
5. ⏳ Write architecture guide

**Deliverable:** `AMSS_EPT_ARCHITECTURE.md`

---

### **Phase 2: Theoretical Foundation** (Week 1-2)

**Tasks:**
1. ⏳ Derive 3+1 form of Equations 36-37
2. ⏳ Express in BSSN variables
3. ⏳ Identify coupling terms
4. ⏳ Create reference implementation in Python
5. ⏳ Validate against Lean4 proofs

**Deliverable:** 
- `ept_equations_3plus1.md`
- `ept_reference_implementation.py`

---

### **Phase 3: Adapter Design** (Week 2)

**Tasks:**
1. ⏳ Design AMSS-EPT adapter class
2. ⏳ Define interface with catept-verification
3. ⏳ Specify data exchange protocol
4. ⏳ Create validation hooks
5. ⏳ Plan test infrastructure

**Deliverable:** `amss_ept_adapter_design.md`

---

### **Phase 4: Core Field Implementation** (Week 2-3)

**Tasks:**
1. ⏳ Add φ (scalar) and Π_φ (momentum)
2. ⏳ Implement RK4 staging for entropic fields
3. ⏳ Add boundary condition handlers
4. ⏳ Implement constraint monitoring
5. ⏳ Test with simple evolution

**Deliverable:** `ept_fields.patch`

**Code Structure:**
```cpp
// New fields
var *phi_ent;      // Entropic scalar
var *Pi_ent;       // Conjugate momentum
var *phi_ent1;     // RK stage 1
var *Pi_ent1;      // RK stage 1
var *phi_ent_rhs;  // RHS
var *Pi_ent_rhs;   // RHS
var *tauEnt;       // Proper time accumulator (RK-staged)
```

---

### **Phase 5: Equation 36 Implementation** (Week 3-4)

**Tasks:**
1. ⏳ Compute ∇_μ∇_ν φ (Hessian)
2. ⏳ Compute □φ (d'Alembertian)
3. ⏳ Construct S_μν properly
4. ⏳ 3+1 decompose to (ρ_ent, j^i_ent, S^{ij}_ent)
5. ⏳ Inject into BSSN RHS

**Deliverable:** `ept_eq36_sources.patch`

**Key Implementation:**
```cpp
void compute_S_munu_ept(Block *cg,
                        var *phi_ent, var *Pi_ent,
                        var *phi0, var *gxx0, ...,
                        var *rho_ent, var *jx_ent, ...,
                        var *Sxx_ent, ...)
{
  // Compute Hessian ∇_i∇_j φ
  // Compute d'Alembertian □φ
  // Construct S_ij = ∇_i∇_j φ - γ_ij □φ
  // Decompose to (ρ, j^i, S^{ij})
}
```

---

### **Phase 6: Equation 37 Scaffolding** (Week 4-5)

**Tasks:**
1. ⏳ Design Λ_μν data structure
2. ⏳ Implement complex arithmetic support
3. ⏳ Add imaginary time coupling hooks
4. ⏳ Create placeholder RHS contributions
5. ⏳ Document full implementation path

**Deliverable:** `ept_eq37_scaffold.patch`

**Note:** Full Eq. 37 is complex; start with real part only.

---

### **Phase 7: Numerical Stability** (Week 5-6)

**Tasks:**
1. ⏳ Implement Kreiss-Oliger dissipation
2. ⏳ Add constraint damping terms
3. ⏳ Implement adaptive timestep control
4. ⏳ Add NaN/inf detection
5. ⏳ Test stability across parameter space

**Deliverable:** `ept_stability.patch`

---

### **Phase 8: Validation Suite** (Week 6-7)

**Tasks:**
1. ⏳ Unit tests for each EPT component
2. ⏳ Convergence tests (2nd/4th order)
3. ⏳ Minkowski space test (should be flat)
4. ⏳ Schwarzschild comparison
5. ⏳ Cross-validate with Python adapter

**Deliverable:**
- `tests/test_amss_ept_adapter.py`
- `tests/test_ept_convergence.py`
- `tests/test_ept_constraints.py`

---

### **Phase 9: Catept-Verification Integration** (Week 7-8)

**Tasks:**
1. ⏳ Create AMSS-EPT adapter class
2. ⏳ Implement data extraction interface
3. ⏳ Connect to verification framework
4. ⏳ Run 192-equation verification suite
5. ⏳ Generate verification certificate

**Deliverable:**
```python
# adapters/amss_ept_adapter.py

class AMSSEPTAdapter(NumericalRelativityAdapter):
    """
    Adapter for AMSS-NCKU EPT implementation
    Connects to catept-verification framework
    """
    
    def extract_metric(self, data_file):
        """Extract metric from AMSS output"""
        pass
    
    def extract_stress_energy(self, data_file):
        """Extract T_μν + S_μν"""
        pass
    
    def verify_equations(self):
        """Verify Equations 36-37"""
        pass
```

---

### **Phase 10: Production & Publication** (Week 8-10)

**Tasks:**
1. ⏳ Performance optimization
2. ⏳ GPU implementation
3. ⏳ Large-scale test runs
4. ⏳ Generate paper figures
5. ⏳ Write methods section for paper

**Deliverable:**
- Production-ready patchkit
- Simulation data for paper
- Methods documentation
- Performance benchmarks

---

## 📋 Part 4: Immediate Action Items

### **Week 1 Tasks (START NOW)**

#### **1. Create Working Directory Structure**
```bash
catept-verification/
├── adapters/
│   ├── amss_ept_adapter.py       # NEW
│   ├── amss_ept_equations.py     # NEW
│   └── amss_ept_validation.py    # NEW
├── amss-integration/
│   ├── patches/
│   │   ├── 01_ept_fields_rk4.patch       # NEW
│   │   ├── 02_ept_eq36_hessian.patch     # NEW
│   │   ├── 03_ept_eq36_stress.patch      # NEW
│   │   ├── 04_ept_constraints.patch      # NEW
│   │   └── 05_ept_validation.patch       # NEW
│   ├── reference/
│   │   ├── ept_equations_3plus1.md       # NEW
│   │   └── bssn_ept_mapping.md           # NEW
│   └── tests/
│       ├── test_ept_unit.py              # NEW
│       ├── test_ept_convergence.py       # NEW
│       └── test_ept_constraints.py       # NEW
└── docs/
    ├── AMSS_EPT_ARCHITECTURE.md          # NEW
    ├── EPT_IMPLEMENTATION_GUIDE.md       # NEW
    └── EPT_VALIDATION_PROTOCOL.md        # NEW
```

---

#### **2. Derive 3+1 Equations**

**Task:** Express Equations 36-37 in BSSN form

**Input:** Paper equations
**Output:** `ept_equations_3plus1.md`

**Key Derivations:**
```
1. ADM decomposition of S_μν:
   ρ_ent = n^μ n^ν S_μν
   j^i_ent = -n_ν γ^{iμ} S_μν
   S^{ij}_ent = γ^{iμ} γ^{jν} S_μν

2. BSSN conformal split:
   S^{ij} = e^{-4φ} S̃^{ij}
   
3. Evolution equations:
   ∂_t φ_ent = α Π_ent + β^i ∂_i φ_ent
   ∂_t Π_ent = α (□φ_ent + sources) + β^i ∂_i Π_ent
```

---

#### **3. Create Reference Implementation**

**File:** `ept_reference_implementation.py`

**Purpose:** Pure Python implementation for validation

```python
"""
Reference implementation of CAT/EPT equations
For validation against AMSS-NCKU numerical code
"""

import numpy as np
from typing import Tuple

class EPTReferenceImplementation:
    """
    Reference implementation of Equations 36-37
    """
    
    def compute_S_munu(self, 
                       phi: np.ndarray,
                       g_munu: np.ndarray,
                       christoffel: np.ndarray) -> np.ndarray:
        """
        Compute S_μν = ∇_μ∇_ν φ - g_μν □φ
        
        Parameters:
        -----------
        phi : array
            Scalar field φ
        g_munu : array
            Metric tensor
        christoffel : array
            Connection coefficients
            
        Returns:
        --------
        S_munu : array
            Entropic stress tensor
        """
        # Compute Hessian ∇_μ∇_ν φ
        hessian = self._compute_hessian(phi, christoffel)
        
        # Compute d'Alembertian □φ
        box_phi = self._compute_dalembertian(phi, g_munu, christoffel)
        
        # Construct S_μν
        S_munu = hessian - g_munu * box_phi
        
        return S_munu
    
    def _compute_hessian(self, phi, christoffel):
        """Compute covariant Hessian"""
        # ∇_μ∇_ν φ = ∂_μ∂_ν φ - Γ^λ_{μν} ∂_λ φ
        pass
    
    def _compute_dalembertian(self, phi, g_munu, christoffel):
        """Compute d'Alembertian □φ = g^{μν} ∇_μ∇_ν φ"""
        pass
```

---

#### **4. Gap Analysis Document**

**File:** `AMSS_EPT_GAP_ANALYSIS.md`

**Contents:**
```markdown
# Gap Analysis: Current vs. Required

## Equation 36: S_μν

### Current Implementation:
- Uses simplified gradient-based stress
- Missing second derivatives
- Wrong trace prescription

### Required Implementation:
- Full Hessian ∇_μ∇_ν φ
- Proper d'Alembertian □φ
- Correct metric coupling

### Gap: 70% incomplete

## Equation 37: Λ_μν

### Current Implementation:
- Not implemented at all

### Required Implementation:
- Complex-valued curvature modification
- Imaginary time coupling
- Phase space structure

### Gap: 100% missing

## Numerical Stability

### Current Implementation:
- Euler forward (1st order)
- No constraint damping
- Poor boundary conditions

### Required Implementation:
- RK4 staging (4th order)
- Constraint damping
- Proper dissipation

### Gap: 80% inadequate
```

---

## 🎯 Part 5: Success Criteria

### **Phase 1-2 Success (Weeks 1-2)**
- ✅ Complete audit documented
- ✅ 3+1 equations derived
- ✅ Python reference implementation working
- ✅ Validates against simple test cases

### **Phase 3-5 Success (Weeks 3-4)**
- ✅ Equation 36 fully implemented
- ✅ Matches Python reference to 10^-10
- ✅ Passes convergence tests
- ✅ 2nd and 4th order accurate

### **Phase 6-8 Success (Weeks 5-7)**
- ✅ Equation 37 scaffolded (real part)
- ✅ Numerically stable
- ✅ Passes all unit tests
- ✅ Hamiltonian constraint < 10^-6

### **Phase 9-10 Success (Weeks 8-10)**
- ✅ Integrated with catept-verification
- ✅ 192/192 equations verified
- ✅ Ready for production runs
- ✅ Publication-quality results

---

## 📊 Part 6: Risk Assessment

### **High Risks** 🔴

1. **Complexity of Equation 37**
   - **Risk:** Full implementation may be intractable
   - **Mitigation:** Start with real part, defer imaginary

2. **Numerical Stability**
   - **Risk:** EPT evolution may be stiff
   - **Mitigation:** Adaptive timestepping, implicit methods

3. **Performance Impact**
   - **Risk:** Extra fields slow down simulation
   - **Mitigation:** GPU optimization, selective enabling

### **Medium Risks** 🟡

1. **Integration Complexity**
   - **Risk:** AMSS-NCKU codebase is large
   - **Mitigation:** Modular patches, extensive testing

2. **Validation Difficulty**
   - **Risk:** No analytic solutions for EPT
   - **Mitigation:** Weak-field tests, convergence studies

### **Low Risks** 🟢

1. **Python Adapter**
   - **Risk:** Interface changes
   - **Mitigation:** Well-defined adapter protocol

2. **Documentation**
   - **Risk:** Incomplete specs
   - **Mitigation:** Comprehensive docs from start

---

## 🚀 Part 7: Next Steps (THIS WEEK)

### **Immediate Actions (Today - Day 3)**

**Priority 1: Set Up Infrastructure**
```bash
# 1. Create directory structure
mkdir -p catept-verification/amss-integration/{patches,reference,tests}
mkdir -p catept-verification/adapters

# 2. Extract and organize patchkit
cd amss-integration/reference/
cp /path/to/patchkit .

# 3. Start documentation
touch AMSS_EPT_ARCHITECTURE.md
touch EPT_IMPLEMENTATION_GUIDE.md
```

**Priority 2: Theoretical Foundation**
```bash
# 1. Create 3+1 derivation document
# 2. Write Python reference implementation
# 3. Validate against known cases
```

**Priority 3: Code Analysis**
```bash
# 1. Map all BSSN-EPT touchpoints
# 2. Document data flow
# 3. Identify injection points for Eq. 36-37
```

---

### **This Week Deliverables**

**By Friday (Day 5):**

1. ✅ `AMSS_EPT_ARCHITECTURE.md` - Complete architecture map
2. ✅ `ept_equations_3plus1.md` - 3+1 decomposition done
3. ✅ `ept_reference_implementation.py` - Working Python version
4. ✅ `AMSS_EPT_GAP_ANALYSIS.md` - Detailed gap analysis
5. ✅ `amss_ept_adapter_design.md` - Adapter specification

**By Next Friday (Day 12):**

1. ✅ First patch: `01_ept_fields_rk4.patch`
2. ✅ Unit tests passing
3. ✅ Convergence tests designed
4. ✅ Integration with catept-verification started

---

## 📝 Part 8: Documentation Standards

### **All Code Must Include:**

1. **Header Comments:**
   ```cpp
   /**
    * @file ept_sources.cpp
    * @brief Implementation of Equation 36 stress tensor
    * @author CAT/EPT Team
    * @date 2026-02-11
    * 
    * Implements S_μν = ∇_μ∇_ν φ - g_μν □φ from Equation 36
    * 
    * References:
    * - Paper Equation 36
    * - BSSN formulation in ept_equations_3plus1.md
    * - Python reference: ept_reference_implementation.py
    */
   ```

2. **Function Documentation:**
   ```cpp
   /**
    * Compute entropic stress tensor S_ij in BSSN form
    * 
    * @param[in]  cg      Current grid block
    * @param[in]  phi_ent Entropic scalar field
    * @param[in]  Pi_ent  Conjugate momentum
    * @param[out] Sxx_ent Output stress component xx
    * @param[out] Sxy_ent Output stress component xy
    * ...
    * 
    * @details
    * Implements the 3+1 decomposition of Equation 36:
    * S_ij = ∇_i∇_j φ - γ_ij □φ
    * 
    * Uses 4th-order finite differencing for derivatives.
    * Includes Christoffel symbol corrections.
    * 
    * @note Must be called after computing phi_ent RHS
    * @see ept_equations_3plus1.md for full derivation
    */
   void compute_Sij_ept(Block *cg, ...);
   ```

3. **Validation Comments:**
   ```cpp
   // Validated against:
   // - Python reference: ept_reference_implementation.py
   // - Unit test: test_ept_stress_tensor()
   // - Convergence: 4th order confirmed
   // - Cross-check: matches Lean4 proof Batch8_Eq36.lean
   ```

---

## 🏆 Part 9: Long-Term Vision

### **6-Month Roadmap**

**Month 1-2:** Core Implementation
- Complete Equation 36
- Validate thoroughly
- Integrate with framework

**Month 3-4:** Advanced Features
- Equation 37 (real part)
- GPU acceleration
- Large-scale tests

**Month 5:** Production Runs
- Schwarzschild + EPT
- Binary black holes + EPT
- Generate paper figures

**Month 6:** Publication
- Write methods section
- Prepare supplementary material
- Submit to Phys. Rev. X

---

## 📞 Part 10: Getting Started NOW

### **Run These Commands:**

```bash
# 1. Create working directory
cd ~/catept-verification
mkdir -p amss-integration/{patches,reference,tests}
mkdir -p adapters

# 2. Copy patchkit to reference
cp -r /path/to/amss-ept-patchkit-v2 amss-integration/reference/

# 3. Create first documents
cat > amss-integration/reference/README.md << 'EOF'
# AMSS-EPT Integration Reference

This directory contains reference materials for implementing
CAT/EPT in AMSS-NCKU.

## Contents

- `amss-ept-patchkit-v2/` - Original patchkit (for reference)
- `ept_equations_3plus1.md` - 3+1 decomposition
- `ept_reference_implementation.py` - Python reference
- `bssn_ept_mapping.md` - BSSN variable mapping

## Status

See AMSS_EPT_ANALYSIS_AND_IMPLEMENTATION_PLAN.md for details.
EOF

# 4. Start the work!
echo "✅ Infrastructure ready. Start implementing!"
```

---

## 🎯 Summary

**Current Status:**
- Patchkit analyzed ✅
- Problems identified ✅
- Solution designed ✅
- Plan created ✅

**Next Step:**
- Start Week 1 tasks NOW
- Focus on theoretical foundation first
- Build incrementally and validate continuously

**Expected Outcome:**
- Production-quality AMSS-EPT implementation
- Full integration with catept-verification
- Publication-ready numerical results
- Framework for future extensions

---

**Let's build this properly!** 🚀
