# PHASE 1 QUICK START GUIDE
## Foundation Equations Verification (Equations 1-31)

**Goal:** Verify all 31 foundation equations and establish verification workflow  
**Timeline:** Week 1-2  
**Current Status:** 20/31 implemented, 0/31 verified

---

## PRE-FLIGHT CHECKLIST

### Environment Setup
```bash
# 1. Navigate to verification directory
cd /tmp/v3.0_workspace/CATEPT-Complete-v3.3/verification

# 2. Check Python dependencies
python3 -c "import sympy, numpy; print('Dependencies OK')"

# 3. Check database
python3 -c "import sqlite3; conn=sqlite3.connect('../database/catept_verification.db'); print(f'Database OK: {conn.execute(\"SELECT COUNT(*) FROM equations\").fetchone()[0]} equations')"

# 4. Test existing verification
python3 verify_all.py --equation 1 --verbose
```

### Expected Output
```
[HH:MM:SS] INFO: Running Python verification...
[HH:MM:SS] INFO: Verifying eq:complex_action...
[HH:MM:SS] INFO: Python verification: 1/1 passed
```

---

## IMPLEMENTATION STRATEGY

### Step 1: Inventory Check (15 minutes)

**Find what's already implemented:**
```python
import sqlite3

conn = sqlite3.connect('../database/catept_verification.db')
cursor = conn.cursor()

# Get foundation equations status
cursor.execute("""
    SELECT equation_number, label, implemented_python, python_module
    FROM equations
    WHERE section = 'Foundations of Complex Action and Entropic Time'
    ORDER BY equation_id
""")

for row in cursor.fetchall():
    num, label, impl, module = row
    status = "✅ DONE" if impl else "❌ TODO"
    print(f"{status} | Eq {num}: {label} | {module or 'NOT ASSIGNED'}")

conn.close()
```

**Output:** List of 31 equations with implementation status

---

### Step 2: Implement Missing Equations (11 remaining)

**Priority Order:**
1. **Eq 11-15:** Lindblad structure (CRITICAL - needed for all dynamics)
2. **Eq 20-25:** Conservation laws (CRITICAL - consistency checks)
3. **Eq 26-31:** Equilibrium conditions (HIGH - needed for limits)

**Implementation Template:**
```python
# File: verification/python/sections/foundations.py

class EqXXX_EquationName(EquationBase):
    """
    [Brief description from paper]
    
    LaTeX: [copy from paper, line YYYY]
    """
    
    def __init__(self):
        metadata = EquationMetadata(
            equation_id=XXX,
            equation_number="XXX",
            label="eq:label_from_paper",
            section="Foundations of Complex Action and Entropic Time",
            description="[Full description]",
            dependencies=[],  # Add equation_ids this depends on
            tags=["foundational"]  # Add relevant tags
        )
        super().__init__(metadata)
    
    def sympy_expression(self):
        """Implement the equation in SymPy."""
        if self._sympy_expr is None:
            # Define symbols
            # Build expression
            # Set self._sympy_expr, _sympy_lhs, _sympy_rhs
            pass
        return self._sympy_expr
    
    def verify_dimensions(self) -> bool:
        """Check dimensional consistency."""
        # Implement dimensional check
        return True
    
    def verify_positivity(self) -> bool:
        """Check positivity constraints (if applicable)."""
        # Implement positivity check if S_I, H_I, or λ
        return True
```

---

### Step 3: Verification Checks (Per Equation)

**For each equation, implement these checks:**

#### 1. Dimensional Analysis
```python
def verify_dimensions(self) -> bool:
    """
    Check that all terms have same dimensions.
    
    Example for action: [S] = [energy × time] = [ℏ]
    """
    from sympy.physics.units import dimension_system
    
    # Get expression
    expr = self.sympy_expression()
    
    # Extract terms
    terms = expr.as_ordered_terms() if hasattr(expr, 'as_ordered_terms') else [expr]
    
    # Check each term has same dimension
    base_dim = get_dimension(terms[0])
    for term in terms[1:]:
        if get_dimension(term) != base_dim:
            return False
    
    return True
```

#### 2. Positivity Check (for S_I, H_I, λ)
```python
def verify_positivity(self) -> bool:
    """
    Verify that imaginary parts are non-negative.
    
    Applies to:
    - S_I ≥ 0 (imaginary action)
    - H_I ≥ 0 (anti-Hermitian Hamiltonian part)  
    - λ ≥ 0 (entropic rate)
    """
    expr = self.sympy_expression()
    
    # For S_I or H_I: check that it's defined as positive
    if 'S_I' in str(expr) or 'H_I' in str(expr):
        # Symbolic check: is it defined with positivity assumption?
        return True  # Axiomatic
    
    # For derived quantities: verify algebraically
    # This depends on the specific equation
    
    return True
```

#### 3. Hermiticity Check (for operators)
```python
def verify_hermiticity(self) -> bool:
    """
    Verify operator Hermiticity properties.
    
    - H_R should be Hermitian: H_R = H_R†
    - H_I should be Hermitian: H_I = H_I†
    """
    expr = self.sympy_expression()
    
    # For operators: check dagger (conjugate transpose) property
    # This is often symbolic/axiomatic
    
    return True
```

#### 4. Trace Preservation (for density matrices)
```python
def verify_trace(self) -> bool:
    """
    Verify trace preservation: Tr(ρ) = 1
    
    For Lindblad equations: d(Tr ρ)/dt = 0
    """
    expr = self.sympy_expression()
    
    # Check trace properties
    # This is equation-specific
    
    return True
```

---

### Step 4: Run Verification Suite

**Verify all foundation equations:**
```bash
cd /tmp/v3.0_workspace/CATEPT-Complete-v3.3/verification

# Verify all foundation equations
python3 verify_all.py --section "Foundations" --verbose

# Or verify individually
for i in {1..31}; do
    python3 verify_all.py --equation $i
done
```

**Expected output for each:**
```
[19:30:15] INFO: Verifying eq:complex_action...
[19:30:15] INFO: ✅ Dimensions: PASS
[19:30:15] INFO: ✅ Positivity: PASS  
[19:30:15] INFO: ✅ Hermiticity: PASS
[19:30:15] INFO: ✅ Trace: PASS
[19:30:15] INFO: Equation 1: VERIFIED
```

---

### Step 5: Update Database

**After each successful verification:**
```python
import sqlite3
from datetime import datetime

def mark_verified(equation_id: int):
    """Mark equation as verified in database."""
    conn = sqlite3.connect('../database/catept_verification.db')
    cursor = conn.cursor()
    
    # Update verification status
    cursor.execute("""
        UPDATE equations 
        SET verified_python = 1,
            updated_at = ?
        WHERE equation_id = ?
    """, (datetime.now().isoformat(), equation_id))
    
    # Log verification
    cursor.execute("""
        INSERT INTO verification_log 
        (equation_id, system, status, timestamp, notes)
        VALUES (?, 'python', 1, ?, 'Automated verification passed')
    """, (equation_id, datetime.now().isoformat()))
    
    conn.commit()
    conn.close()
    
    print(f"✅ Equation {equation_id} marked as verified")

# Use after each equation verifies
mark_verified(1)
mark_verified(2)
# ... etc
```

---

### Step 6: Generate Phase 1 Report

**Run complete verification and generate report:**
```bash
# Generate comprehensive report
python3 verify_all.py --section "Foundations" --export-results

# This creates:
# - results/foundations_verification.json
# - results/foundations_verification.html
# - results/foundations_summary.txt
```

**Report should show:**
```
======================================================================
PHASE 1: FOUNDATIONS VERIFICATION REPORT
======================================================================

Section: Foundations of Complex Action and Entropic Time

Total Equations: 31
Implemented: 31/31 (100%)
Verified: 31/31 (100%)

Verification Checks:
  ✅ Dimensional analysis: 31/31
  ✅ Positivity constraints: 12/12 applicable
  ✅ Hermiticity: 15/15 applicable
  ✅ Trace preservation: 8/8 applicable

Critical Equations:
  ✅ Eq 1: Complex action axiom
  ✅ Eq 2: Complex Hamiltonian  
  ✅ Eq 3: Entropic time definition
  ✅ Eq 11-15: Lindblad structure
  ✅ Eq 20-25: Conservation laws

Status: ✅ PHASE 1 COMPLETE
Next: Proceed to Phase 2 (Complex Action & Path Integral)

======================================================================
```

---

## EXPECTED TIMELINE

### Day 1: Setup & Inventory (2-3 hours)
- [x] Set up environment
- [ ] Run existing verification suite
- [ ] Inventory what's implemented vs missing
- [ ] Prioritize missing equations

### Day 2-3: Implementation (6-8 hours)
- [ ] Implement Eq 11-15 (Lindblad structure)
- [ ] Implement Eq 20-25 (Conservation laws)
- [ ] Implement Eq 26-31 (Equilibrium conditions)

### Day 4-5: Verification (4-6 hours)
- [ ] Run verification on all 31 equations
- [ ] Fix any failing tests
- [ ] Document issues found
- [ ] Update database

### Day 6-7: Documentation (2-3 hours)
- [ ] Generate Phase 1 report
- [ ] Document methodology
- [ ] Write Phase 1 completion summary
- [ ] Plan Phase 2 kickoff

**Total Estimated Time:** 15-20 hours across 1 week

---

## TROUBLESHOOTING

### Problem: Equation implementation fails verification

**Solution:**
1. Check paper equation (line number in database)
2. Verify SymPy expression matches paper exactly
3. Check assumptions (positivity, Hermiticity, etc.)
4. Add edge case handling
5. Document if paper equation has issues

### Problem: Database update fails

**Solution:**
```python
# Check database integrity
import sqlite3
conn = sqlite3.connect('../database/catept_verification.db')
cursor = conn.cursor()

# Verify table structure
cursor.execute("PRAGMA table_info(equations)")
print(cursor.fetchall())

# Check for locks
cursor.execute("PRAGMA busy_timeout = 5000")
```

### Problem: Dependency missing

**Solution:**
```bash
# Install all Python dependencies
pip install sympy numpy scipy matplotlib

# Check imports
python3 -c "from core import *; print('Core module OK')"
```

---

## SUCCESS CRITERIA

**Phase 1 is complete when:**
- ✅ All 31 foundation equations implemented
- ✅ All 31 equations verified in Python
- ✅ Database shows 100% verified status
- ✅ Phase 1 report generated
- ✅ No critical issues remaining
- ✅ Ready to begin Phase 2

**Stretch goals:**
- ✅ Begin Lean4 axiom proofs (Eq 1-3)
- ✅ Set up CI/CD pipeline
- ✅ Create verification tutorial

---

## DELIVERABLES CHECKLIST

### Code
- [ ] `sections/foundations.py` complete (all 31 equations)
- [ ] All verification methods implemented
- [ ] Tests passing

### Database
- [ ] All 31 equations marked `implemented_python = 1`
- [ ] All 31 equations marked `verified_python = 1`
- [ ] Verification log entries created

### Documentation
- [ ] Phase 1 completion report (Markdown)
- [ ] Any issues found documented
- [ ] Verification methodology documented

### Reports
- [ ] `results/foundations_verification.json`
- [ ] `results/foundations_verification.html`
- [ ] `results/foundations_summary.txt`

---

## NEXT PHASE PREVIEW

After Phase 1 completes, Phase 2 begins:

**Phase 2: Complex Action & Path Integral (Equations 56-78)**
- 23 equations to implement
- Focus: CFL theorem verification
- Timeline: 2 weeks
- Dependencies: Phase 1 axioms

---

## QUICK COMMANDS REFERENCE

```bash
# Check status
python3 verify_all.py --section "Foundations" --verbose

# Verify single equation
python3 verify_all.py --equation 1

# Verify range
for i in {1..31}; do python3 verify_all.py --equation $i; done

# Generate report
python3 verify_all.py --section "Foundations" --export-results

# Update database
python3 << EOF
import sqlite3
conn = sqlite3.connect('../database/catept_verification.db')
cursor = conn.cursor()
cursor.execute("SELECT COUNT(*) FROM equations WHERE section LIKE '%Foundation%' AND verified_python = 1")
print(f"Verified: {cursor.fetchone()[0]}/31")
conn.close()
EOF
```

---

**STATUS:** READY TO BEGIN  
**ACTION:** Start with inventory check, then implement missing equations  
**MILESTONE:** Week 2 - All 31 foundation equations verified ✅
