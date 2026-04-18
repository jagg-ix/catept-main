# CAT/EPT SQLite Database - Quick Reference

**File:** `catept_complete.db`  
**Size:** 140 KB  
**Format:** SQLite 3  
**Total Equations:** 192  
**Implemented:** 25 (13.0%)  
**Last Updated:** 2026-02-07

---

## 🚀 Quick Start

### Open Database

```bash
sqlite3 catept_complete.db
```

### Set Nice Display

```sql
.mode column
.headers on
.width 5 10 35 50
```

---

## 📊 Essential Queries

### 1. Overall Progress

```sql
SELECT * FROM v_status;
```

**Output:**
```
total_equations  implemented  verified  remaining  impl_percent
192              25           0         167        13.0
```

### 2. Section Progress

```sql
SELECT * FROM v_section_progress;
```

**Output:**
```
section_name                                      total  impl  verified  percent
Foundations of Complex Action and Entropic Time   31     20    0         64.5
Quantum Reference Frames in Stationary...         16     5     0         31.3
...
```

### 3. Implemented Equations

```sql
SELECT equation_id, equation_number, label 
FROM v_implemented 
LIMIT 10;
```

### 4. Find Equation by Label

```sql
SELECT * FROM equations 
WHERE label = 'eq:complex_action';
```

### 5. Get Dependencies

```sql
SELECT * FROM v_dependencies 
WHERE equation_id = 2;
```

### 6. Priority List (Next to Implement)

```sql
SELECT * FROM v_priority LIMIT 10;
```

---

## 📋 Database Schema

### Tables (6)

| Table | Rows | Description |
|-------|------|-------------|
| **equations** | 192 | All equations with metadata |
| **dependencies** | 32 | Equation dependencies |
| **sections** | 19 | Section statistics |
| **tags** | 14 | Categorization tags |
| **equation_tags** | 0 | Many-to-many junction |
| **metadata** | 6 | Database metadata |

### Views (5)

| View | Description |
|------|-------------|
| **v_status** | Overall statistics |
| **v_section_progress** | Progress by section |
| **v_implemented** | All implemented equations |
| **v_dependencies** | Dependency graph |
| **v_priority** | Unimplemented by priority |

---

## 🔍 Common Searches

### Search by Description

```sql
SELECT equation_id, label, description 
FROM equations 
WHERE description LIKE '%entropic%' 
LIMIT 5;
```

### Equations in Section

```sql
SELECT equation_id, equation_number, label 
FROM equations 
WHERE section = 'Foundations of Complex Action and Entropic Time';
```

### Equations with Dependencies

```sql
SELECT e.equation_id, e.label, COUNT(d.depends_on_id) as dep_count
FROM equations e
LEFT JOIN dependencies d ON e.equation_id = d.equation_id
GROUP BY e.equation_id
HAVING dep_count > 0
ORDER BY dep_count DESC;
```

---

## 💻 Python Example

```python
import sqlite3

# Connect
conn = sqlite3.connect('catept_complete.db')
cursor = conn.cursor()

# Get status
cursor.execute("SELECT * FROM v_status")
total, impl, ver, remaining, pct = cursor.fetchone()

print(f"Progress: {impl}/{total} ({pct}%)")

# Get implemented equations
cursor.execute("SELECT * FROM v_implemented")
for row in cursor.fetchall():
    print(f"Eq {row[0]}: {row[2] or 'unlabeled'}")

conn.close()
```

---

## 📈 Update Examples

### Mark Equation as Implemented

```sql
UPDATE equations 
SET implemented_python = 1, 
    updated_at = CURRENT_TIMESTAMP 
WHERE equation_id = 50;
```

### Add Dependency

```sql
INSERT INTO dependencies (equation_id, depends_on_id) 
VALUES (50, 1);
```

### Update Section Stats

```sql
UPDATE sections 
SET implemented_equations = (
    SELECT COUNT(*) 
    FROM equations 
    WHERE section = sections.section_name 
      AND implemented_python = 1
);
```

---

## 📤 Export Data

### Export to CSV

```bash
sqlite3 catept_complete.db <<EOF
.mode csv
.headers on
.output equations.csv
SELECT * FROM equations;
.output stdout
.quit
EOF
```

### Export Section Progress

```bash
sqlite3 catept_complete.db <<EOF
.mode csv
.output section_progress.csv
SELECT * FROM v_section_progress;
.quit
EOF
```

---

## 🔧 Maintenance

### Compact Database

```sql
VACUUM;
```

### Rebuild Statistics

```sql
ANALYZE;
```

### Check Integrity

```sql
PRAGMA integrity_check;
```

---

## 📊 Key Statistics (Current)

| Metric | Value |
|--------|-------|
| **Total Equations** | 192 |
| **Implemented** | 25 (13.0%) |
| **Verified** | 0 (0.0%) |
| **Remaining** | 167 (87.0%) |
| **Dependencies** | 32 relationships |
| **Sections** | 19 |
| **Tags** | 14 |

---

## 🎯 Top Sections by Progress

1. **Foundations** - 20/31 (64.5%)
2. **Quantum Reference Frames** - 5/16 (31.3%)
3. Other sections - 0% (not started)

---

## 🏷️ Available Tags

- `foundational` - Core equations
- `complex_action` - Complex action theory
- `complex_hamiltonian` - Complex Hamiltonian
- `entropic_time` - Entropic time
- `path_integral` - Path integral formulation
- `lindblad` - Lindblad/GKLS equations
- `master_equation` - Master equations
- `density_matrix` - Density matrix
- `metric` - Spacetime metric
- `thermodynamics` - Thermodynamics
- `quantum_gravity` - Quantum gravity
- `experimental` - Experimental predictions
- `page_wootters` - Page-Wootters framework
- `renormalization` - RG flow

---

## 🔗 Useful Links

**Documentation:**
- Complete equation list: `COMPLETE_EQUATION_LIST.md`
- Full database guide: `DATABASE_USER_GUIDE.md`
- Verification status: `VERIFICATION_STATUS_REPORT.md`

**Tools:**
- SQLite Browser: https://sqlitebrowser.org/
- Python sqlite3: https://docs.python.org/3/library/sqlite3.html

---

## ⚡ Power User Tips

### 1. Create Custom View

```sql
CREATE VIEW v_my_view AS
SELECT e.equation_id, e.label, e.section
FROM equations e
WHERE e.implemented_python = 0
  AND e.equation_id <= 50;
```

### 2. Recursive Dependency Query

```sql
WITH RECURSIVE deps(id) AS (
  SELECT 1
  UNION ALL
  SELECT depends_on_id FROM dependencies 
  JOIN deps ON deps.id = dependencies.equation_id
)
SELECT DISTINCT e.* FROM deps 
JOIN equations e ON deps.id = e.equation_id;
```

### 3. Batch Update

```sql
UPDATE equations 
SET importance = 1 
WHERE equation_id IN (1, 2, 3, 4, 5);
```

---

**Database Version:** 1.0.0  
**Created:** 2026-02-07  
**Author:** Jorge A. Garcia-Gonzalez  
**Framework:** CAT/EPT Formal Verification
