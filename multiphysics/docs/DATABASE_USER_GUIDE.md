# CAT/EPT Verification Database - User Guide

**Database File:** `catept_verification.db`  
**Size:** ~280 KB  
**Equations:** 192  
**Implemented:** 25 (13.0%)  
**Last Updated:** 2026-02-07

---

## 📊 Database Schema

### Tables

1. **equations** (192 rows)
   - Primary table with all equation data
   - Columns: equation_id, equation_number, label, section, description
   - Implementation status: implemented_python, implemented_lean, implemented_mathematica
   - Verification status: verified_python, verified_lean, verified_coq

2. **sections** (19 rows)
   - Section metadata and statistics
   - Columns: section_name, total_equations, implemented_equations, completion_percentage

3. **dependencies** (32 rows)
   - Equation dependency relationships
   - Columns: equation_id, depends_on_id, dependency_type

4. **tags** (13 rows)
   - Tags for categorizing equations
   - Columns: tag_name, description, color, category

5. **equation_tags** (many-to-many)
   - Links equations to tags

6. **verification_log** (0 rows)
   - Log of verification attempts
   - Will be populated as verification progresses

7. **milestones** (6 rows)
   - Project milestones and progress tracking

### Views

1. **v_implementation_summary** - Section progress overview
2. **v_priority_equations** - Unimplemented equations by priority
3. **v_verification_status** - Per-equation verification status
4. **v_dependency_graph** - Equation dependency relationships

---

## 🔍 Common Queries

### 1. Overall Progress

```sql
SELECT 
    COUNT(*) as total,
    SUM(CASE WHEN implemented_python = 1 THEN 1 ELSE 0 END) as implemented,
    SUM(CASE WHEN verified_python = 1 THEN 1 ELSE 0 END) as verified,
    ROUND(100.0 * SUM(CASE WHEN implemented_python = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) as completion_pct
FROM equations;
```

### 2. Section Progress

```sql
SELECT * FROM v_implementation_summary;
```

### 3. List All Implemented Equations

```sql
SELECT equation_id, equation_number, label, section
FROM equations
WHERE implemented_python = 1
ORDER BY equation_id;
```

### 4. Find Equation by Label

```sql
SELECT * FROM equations
WHERE label = 'eq:complex_action';
```

### 5. Get Dependencies for an Equation

```sql
SELECT * FROM v_dependency_graph
WHERE equation_id = 2;
```

### 6. Priority Unimplemented Equations

```sql
SELECT equation_id, equation_number, label, priority, section
FROM equations
WHERE implemented_python = 0
ORDER BY priority ASC, equation_id ASC
LIMIT 10;
```

### 7. Equations by Section

```sql
SELECT section, COUNT(*) as count,
       SUM(CASE WHEN implemented_python = 1 THEN 1 ELSE 0 END) as implemented
FROM equations
GROUP BY section
ORDER BY count DESC;
```

### 8. Search Equations by Description

```sql
SELECT equation_id, equation_number, label, description
FROM equations
WHERE description LIKE '%entropic%'
LIMIT 10;
```

### 9. Dependency Chain (Equations that depend on Eq 1)

```sql
WITH RECURSIVE deps AS (
  SELECT equation_id, depends_on_id FROM dependencies WHERE depends_on_id = 1
  UNION ALL
  SELECT d.equation_id, d.depends_on_id 
  FROM dependencies d 
  JOIN deps ON d.depends_on_id = deps.equation_id
)
SELECT DISTINCT e.equation_id, e.label 
FROM deps 
JOIN equations e ON deps.equation_id = e.equation_id
ORDER BY e.equation_id;
```

### 10. Milestone Progress

```sql
SELECT 
    m.milestone_name,
    m.target_equations,
    (SELECT COUNT(*) FROM equations WHERE implemented_python = 1) as current_implemented,
    m.target_percentage,
    m.achieved,
    m.achieved_date
FROM milestones m
ORDER BY m.target_equations;
```

---

## 💻 Python Usage

### Connect to Database

```python
import sqlite3
import pandas as pd

# Connect
conn = sqlite3.connect('catept_verification.db')

# Query with pandas
df = pd.read_sql_query("SELECT * FROM v_implementation_summary", conn)
print(df)

# Or with cursor
cursor = conn.cursor()
cursor.execute("SELECT COUNT(*) FROM equations WHERE implemented_python = 1")
print(f"Implemented: {cursor.fetchone()[0]}")

conn.close()
```

### Get Implementation Status

```python
import sqlite3

def get_status():
    conn = sqlite3.connect('catept_verification.db')
    cursor = conn.cursor()
    
    cursor.execute("""
        SELECT 
            COUNT(*) as total,
            SUM(CASE WHEN implemented_python = 1 THEN 1 ELSE 0 END) as impl,
            SUM(CASE WHEN verified_python = 1 THEN 1 ELSE 0 END) as ver
        FROM equations
    """)
    
    total, impl, ver = cursor.fetchone()
    
    print(f"Total:       {total}")
    print(f"Implemented: {impl} ({impl/total*100:.1f}%)")
    print(f"Verified:    {ver} ({ver/total*100:.1f}%)")
    
    conn.close()

get_status()
```

### Update Implementation Status

```python
import sqlite3

def mark_implemented(equation_id, system='python'):
    conn = sqlite3.connect('catept_verification.db')
    cursor = conn.cursor()
    
    if system == 'python':
        cursor.execute("""
            UPDATE equations 
            SET implemented_python = 1, updated_at = datetime('now')
            WHERE equation_id = ?
        """, (equation_id,))
    
    conn.commit()
    conn.close()
    print(f"✓ Marked equation {equation_id} as implemented ({system})")

# Example
mark_implemented(50)
```

### Add Verification Log Entry

```python
import sqlite3
import json

def log_verification(equation_id, system, status, notes=""):
    conn = sqlite3.connect('catept_verification.db')
    cursor = conn.cursor()
    
    cursor.execute("""
        INSERT INTO verification_log (
            equation_id, verification_type, status, notes
        ) VALUES (?, ?, ?, ?)
    """, (equation_id, system, status, notes))
    
    conn.commit()
    conn.close()
    print(f"✓ Logged verification for equation {equation_id}")

# Example
log_verification(1, 'python', 'passed', 'All tests passed')
```

---

## 📈 Advanced Queries

### Dependency Analysis

```sql
-- Find equations with most dependencies
SELECT 
    e.equation_id,
    e.label,
    COUNT(d.depends_on_id) as dependency_count
FROM equations e
LEFT JOIN dependencies d ON e.equation_id = d.equation_id
GROUP BY e.equation_id
ORDER BY dependency_count DESC
LIMIT 10;
```

### Implementation Velocity

```sql
-- Assuming implementation dates are tracked
SELECT 
    DATE(created_at) as date,
    COUNT(*) as equations_implemented
FROM equations
WHERE implemented_python = 1
GROUP BY DATE(created_at)
ORDER BY date;
```

### Critical Path (Equations blocking others)

```sql
SELECT 
    e.equation_id,
    e.label,
    COUNT(d.equation_id) as blocks_count
FROM equations e
JOIN dependencies d ON e.equation_id = d.depends_on_id
WHERE e.implemented_python = 0
GROUP BY e.equation_id
ORDER BY blocks_count DESC
LIMIT 10;
```

---

## 🛠️ Command Line Usage

### SQLite CLI

```bash
# Open database
sqlite3 catept_verification.db

# Set nice output format
.mode column
.headers on
.width 5 10 35 50

# Run query
SELECT equation_id, equation_number, label, section 
FROM equations 
WHERE implemented_python = 1 
LIMIT 10;

# Export to CSV
.mode csv
.output implemented_equations.csv
SELECT * FROM equations WHERE implemented_python = 1;
.output stdout

# Quit
.quit
```

### Export Section Statistics

```bash
sqlite3 catept_verification.db << 'SQL'
.mode csv
.headers on
.output section_progress.csv
SELECT * FROM v_implementation_summary;
.quit
SQL
```

---

## 📊 Database Maintenance

### Vacuum Database

```sql
VACUUM;
```

### Rebuild Statistics

```sql
ANALYZE;
```

### Update Section Statistics

```sql
UPDATE sections
SET 
    implemented_equations = (
        SELECT COUNT(*) 
        FROM equations 
        WHERE section = sections.section_name 
        AND implemented_python = 1
    ),
    completion_percentage = (
        SELECT 100.0 * COUNT(*) / total_equations
        FROM equations 
        WHERE section = sections.section_name 
        AND implemented_python = 1
    );
```

---

## 🔒 Backup and Restore

### Backup

```bash
# Create backup
cp catept_verification.db catept_verification_backup_$(date +%Y%m%d).db

# Or export to SQL
sqlite3 catept_verification.db .dump > backup.sql
```

### Restore

```bash
# From backup file
cp catept_verification_backup_20260207.db catept_verification.db

# From SQL dump
sqlite3 new_database.db < backup.sql
```

---

## 📝 Schema Information

### Show All Tables

```sql
SELECT name FROM sqlite_master 
WHERE type='table' 
ORDER BY name;
```

### Show Table Schema

```sql
PRAGMA table_info(equations);
```

### Show All Indexes

```sql
SELECT name, tbl_name 
FROM sqlite_master 
WHERE type='index';
```

---

## 🎯 Use Cases

### 1. Daily Progress Tracking

```python
def daily_progress():
    conn = sqlite3.connect('catept_verification.db')
    cursor = conn.cursor()
    
    cursor.execute("""
        SELECT 
            section_name,
            total_equations,
            implemented_equations,
            completion_percentage
        FROM sections
        WHERE completion_percentage > 0
        ORDER BY completion_percentage DESC
    """)
    
    print("Daily Progress Report")
    print("=" * 70)
    for section, total, impl, pct in cursor.fetchall():
        print(f"{section[:50]:<50} {impl:>3}/{total:<3} ({pct:>5.1f}%)")
    
    conn.close()
```

### 2. Find Next Equations to Implement

```python
def next_to_implement(n=10):
    conn = sqlite3.connect('catept_verification.db')
    cursor = conn.cursor()
    
    cursor.execute("""
        SELECT equation_id, label, section, priority
        FROM equations
        WHERE implemented_python = 0
        ORDER BY priority ASC, equation_id ASC
        LIMIT ?
    """, (n,))
    
    print(f"Next {n} equations to implement:")
    for eq_id, label, section, priority in cursor.fetchall():
        print(f"  {eq_id:>3}. {label or 'unlabeled':<30} [P{priority}]")
    
    conn.close()
```

### 3. Dependency Checker

```python
def check_dependencies(equation_id):
    conn = sqlite3.connect('catept_verification.db')
    cursor = conn.cursor()
    
    cursor.execute("""
        SELECT d.depends_on_id, e.label, e.implemented_python
        FROM dependencies d
        JOIN equations e ON d.depends_on_id = e.equation_id
        WHERE d.equation_id = ?
    """, (equation_id,))
    
    deps = cursor.fetchall()
    
    if not deps:
        print(f"Equation {equation_id} has no dependencies")
        return True
    
    all_met = all(impl for _, _, impl in deps)
    
    print(f"Dependencies for equation {equation_id}:")
    for dep_id, label, impl in deps:
        status = "✓" if impl else "✗"
        print(f"  {status} Eq {dep_id}: {label or 'unlabeled'}")
    
    conn.close()
    return all_met
```

---

## 📚 Additional Resources

- **Verification Framework:** `/verification/python/`
- **Lean4 Proofs:** `/verification/lean/`
- **Documentation:** `README.md`
- **Progress Report:** `VERIFICATION_STATUS_REPORT.md`

---

**Database Version:** 1.0  
**Created:** 2026-02-07  
**Format:** SQLite 3  
**Encoding:** UTF-8
