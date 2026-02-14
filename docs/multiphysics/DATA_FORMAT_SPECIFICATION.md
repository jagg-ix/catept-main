# EPT Data Format Specification

**Version:** 1.0  
**Date:** February 12, 2026  
**Format:** HDF5

This document specifies the HDF5 file format for EPT simulation output,
checkpoints, and diagnostics.

---

## 1. Output Files (`data_NNNN.h5`)

Output files contain field snapshots at regular intervals.

### File Structure

```
data_NNNN.h5
├── metadata/
│   └── attributes:
│       ├── version: "1.0"
│       ├── created: timestamp
│       └── run_name: string
├── time (scalar): simulation time
├── grid/
│   ├── nx, ny, nz (scalars): grid dimensions
│   ├── dx, dy, dz (scalars): grid spacing
│   └── coordinates/
│       ├── x (1D array)
│       ├── y (1D array)
│       └── z (1D array)
├── fields/
│   ├── phi_ent (3D array): φ_ent field
│   ├── Pi_ent (3D array): Π_ent field
│   └── tau_ent (3D array): τ_ent field
├── stress/
│   ├── T_11 (3D array): T_xx component
│   ├── T_12 (3D array): T_xy component
│   ├── T_13 (3D array): T_xz component
│   ├── T_22 (3D array): T_yy component
│   ├── T_23 (3D array): T_yz component
│   └── T_33 (3D array): T_zz component
└── diagnostics/ (optional)
    ├── phi_L2 (scalar)
    ├── Pi_L2 (scalar)
    ├── tau_mean (scalar)
    └── stress_max (scalar)
```

### Data Types

- **Scalars:** `float64`
- **3D arrays:** `float64`, shape `(nx, ny, nz)`
- **1D arrays:** `float64`
- **Strings:** UTF-8

### Array Indexing

Arrays use **C ordering**: `array[i][j][k]`
- `i`: x-direction (0 to nx-1)
- `j`: y-direction (0 to ny-1)
- `k`: z-direction (0 to nz-1)

### Coordinates

```
x[i] = dx * i - (nx * dx) / 2
y[j] = dy * j - (ny * dy) / 2
z[k] = dz * k - (nz * dz) / 2
```

Domain: `[-Lx/2, Lx/2] × [-Ly/2, Ly/2] × [-Lz/2, Lz/2]`

### Compression

- **Algorithm:** gzip
- **Level:** 6 (default), adjustable
- **Chunking:** Automatic (HDF5 default)

---

## 2. Checkpoint Files (`checkpoint_NNNNNN.h5`)

Checkpoints contain complete state for restart.

### File Structure

```
checkpoint_NNNNNN.h5
├── metadata/
│   └── attributes:
│       ├── version: "1.0"
│       ├── step: int (timestep number)
│       ├── time: float (simulation time)
│       └── checksum_algorithm: "sha256"
├── grid/
│   └── attributes: nx, ny, nz, dx, dy, dz
├── parameters/
│   └── attributes:
│       ├── lambda_0: float
│       ├── sigma_tau: float
│       ├── enable_eq36: bool
│       └── enable_eq37: bool
├── fields/
│   ├── phi_ent (3D array)
│   │   └── attributes:
│   │       ├── checksum: string (SHA-256)
│   │       ├── dtype: "float64"
│   │       └── shape: (nx, ny, nz)
│   ├── Pi_ent (3D array + checksums)
│   └── tau_ent (3D array + checksums)
└── bssn/ (optional, for full BSSN state)
    ├── phi (3D array)
    ├── K (3D array)
    └── ... (other BSSN variables)
```

### Checksums

Each field has a SHA-256 checksum stored as an attribute:
```
checksum = sha256(field_data.tobytes()).hexdigest()
```

Verified on load to detect corruption.

### Restart Procedure

1. Load checkpoint file
2. Verify all checksums
3. Extract step, time, fields
4. Continue evolution from this state

---

## 3. Diagnostic Files (`diagnostics.h5`)

Time series of diagnostic quantities.

### File Structure

```
diagnostics.h5
├── metadata/
│   └── attributes: version, run_name
├── time (1D array): list of output times
├── fields/
│   ├── phi_L2 (1D array): L² norm of φ
│   ├── Pi_L2 (1D array): L² norm of Π
│   └── tau_mean (1D array): mean of τ
├── stress/
│   ├── max (1D array): max |T_ij|
│   ├── trace_mean (1D array): mean of Tr(T)
│   └── trace_max (1D array): max |Tr(T)|
├── energy_conditions/
│   ├── NEC_violations (1D array): fraction violating
│   ├── WEC_violations (1D array): fraction violating
│   └── DEC_violations (1D array): fraction violating
└── constraints/ (optional)
    ├── hamiltonian (1D array)
    └── momentum (1D array)
```

### Time Alignment

All arrays have same length, aligned with `time` array:
```
phi_L2[i] corresponds to time[i]
```

---

## 4. Waveform Files (`waveforms.h5`)

Extracted gravitational waveforms.

### File Structure

```
waveforms.h5
├── metadata/
│   └── attributes:
│       ├── extraction_radii: [50.0, 75.0, 100.0]
│       └── lmax: 4
├── radius_50/
│   ├── time (1D array)
│   ├── psi4_l2m2_real (1D array)
│   ├── psi4_l2m2_imag (1D array)
│   ├── psi4_l2m0_real (1D array)
│   └── ... (all modes)
├── radius_75/
│   └── ... (same structure)
└── radius_100/
    └── ... (same structure)
```

### Mode Naming

Modes named as: `psi4_lLmM_[real|imag]`
- L: orbital angular momentum
- M: azimuthal number (-L ≤ M ≤ L)

---

## 5. Python Reading Examples

### Read Output File

```python
import h5py
import numpy as np

with h5py.File('data_0100.h5', 'r') as f:
    # Read time
    time = f['time'][()]
    
    # Read grid info
    nx = f['grid/nx'][()]
    dx = f['grid/dx'][()]
    
    # Read fields
    phi = f['fields/phi_ent'][:]
    Pi = f['fields/Pi_ent'][:]
    tau = f['fields/tau_ent'][:]
    
    # Read stress
    T_xx = f['stress/T_11'][:]
    T_xy = f['stress/T_12'][:]
```

### Read Checkpoint

```python
from checkpoint_restart import EPTCheckpoint

checkpoint = EPTCheckpoint()
step, time, fields, grid, params = checkpoint.load('checkpoint_000100.h5')

print(f"Loaded step {step} at time {time}")
print(f"Grid: {grid.nx}×{grid.ny}×{grid.nz}")
print(f"λ₀ = {params.lambda_0}")
```

### Read Diagnostics

```python
with h5py.File('diagnostics.h5', 'r') as f:
    times = f['time'][:]
    phi_L2 = f['fields/phi_L2'][:]
    
    import matplotlib.pyplot as plt
    plt.plot(times, phi_L2)
    plt.xlabel('Time')
    plt.ylabel(r'$\|\phi\|_{L^2}$')
    plt.show()
```

---

## 6. C++ Writing Examples

### Write Output

```cpp
#include "ept_output.h"

// Setup configuration
AMSS::EPT::OutputConfig config;
config.output_dir = "output/bbh_ept";
config.run_name = "bbh_m0.5";
config.output_every_n_steps = 10;
config.use_compression = true;

// Create writer
AMSS::EPT::EPTOutputWriter writer(config);

// Write output
writer.write_output(
    step,           // timestep number
    time,           // simulation time
    ept_fields,     // EPT fields
    ept_stress,     // stress tensor
    nx, ny, nz,     // grid dimensions
    dx, dy, dz      // grid spacing
);
```

### Write Checkpoint

```cpp
// Write checkpoint
writer.write_checkpoint(
    step, time, ept_fields,
    nx, ny, nz, dx, dy, dz
);
```

### Read Checkpoint

```cpp
// Read for restart
int step;
double time;
AMSS::EPT::EPTFields fields;
int nx, ny, nz;
double dx, dy, dz;

bool success = writer.read_checkpoint(
    "checkpoint_000100.h5",
    step, time, fields,
    nx, ny, nz, dx, dy, dz
);

if (success) {
    std::cout << "Restart from step " << step << std::endl;
}
```

---

## 7. Data Validation

### File Integrity

Checkpoints include SHA-256 checksums:
```
Expected: dset.attrs['checksum']
Actual:   sha256(data.tobytes()).hexdigest()
```

Mismatch indicates corruption.

### Physical Consistency

Check for:
- Fields are finite (no NaN/Inf)
- Energy conditions satisfied
- Constraint violations small
- Stress tensor symmetric

### Tools

```bash
# Verify checkpoint
python checkpoint_restart.py --verify checkpoint_000100.h5

# List all checkpoints
python checkpoint_restart.py --list output/checkpoints/

# Analyze output
python ept_analysis.py output/bbh_ept/ --report analysis.pdf
```

---

## 8. Naming Conventions

### Output Files
```
data_NNNN.h5        where NNNN = 0000, 0001, 0002, ...
```

### Checkpoints
```
checkpoint_NNNNNN.h5   where NNNNNN = step number (000000, 000100, ...)
```

### Diagnostics
```
diagnostics.h5         (single file, appended)
waveforms.h5          (single file)
```

---

## 9. File Size Estimates

### Without Compression

For N³ grid:
```
Output file:  9 × N³ × 8 bytes  (3 fields + 6 stress components)
              ≈ 72 N³ bytes

Examples:
  64³:   ≈ 19 MB per output
  128³:  ≈ 150 MB per output
  256³:  ≈ 1.2 GB per output
```

### With Compression (level 6)

Typical compression ratio: 3-5×
```
  64³:   ≈ 4-6 MB per output
  128³:  ≈ 30-50 MB per output
  256³:  ≈ 250-400 MB per output
```

---

## 10. Best Practices

### Output Frequency

Balance storage vs analysis needs:
```
High res (256³):    Every 50-100 steps
Medium res (128³):  Every 20-50 steps
Low res (64³):      Every 10-20 steps
```

### Checkpoint Frequency

Based on computation time:
```
Fast runs (<1 hour):     Every 500-1000 steps
Medium runs (1-10 hr):   Every 100-500 steps
Long runs (>10 hr):      Every 50-100 steps
```

### Storage Management

Clean old checkpoints:
```python
from checkpoint_restart import EPTCheckpoint
checkpoint = EPTCheckpoint()
checkpoint.clean_old_checkpoints(
    "output/checkpoints",
    keep_every=5,      # Keep every 5th
    keep_last=3        # Always keep last 3
)
```

### Archival

For long-term storage:
- Keep checkpoints at key times (merger, ringdown)
- Compress with higher level (9)
- Archive to tape/cloud storage
- Keep diagnostics and waveforms (small)

---

## 11. Version Compatibility

**Current Version:** 1.0

Future versions will maintain backward compatibility for reading.
Write format may evolve.

Check version:
```python
with h5py.File('data_0000.h5', 'r') as f:
    version = f['metadata'].attrs['version']
    print(f"File format version: {version}")
```

---

## 12. Error Handling

### Missing Fields

If optional fields missing:
```python
if 'diagnostics/phi_L2' in f:
    phi_L2 = f['diagnostics/phi_L2'][:]
else:
    print("Diagnostics not available")
```

### Corrupted Files

Checksums detect corruption:
```python
try:
    step, time, fields, grid, params = checkpoint.load('checkpoint.h5')
except RuntimeError as e:
    print(f"Checkpoint corrupted: {e}")
```

---

**Questions?**  
See: `ept_analysis.py`, `checkpoint_restart.py` for working examples.

**Last Updated:** February 12, 2026
