# EPT Quick Start Guide

**Get running in 30 minutes!**

This guide gets you from zero to running EPT simulations as quickly as possible.

---

## Prerequisites (5 minutes)

### Software Requirements

```bash
# Python (for reference and validation)
python >= 3.8
numpy >= 1.20
scipy >= 1.7
h5py >= 3.0
matplotlib >= 3.3

# C++ compiler
g++ >= 9.0 or clang >= 10.0

# HDF5 library
libhdf5-dev

# Optional (for animations)
ffmpeg
```

### Install Python Dependencies

```bash
pip install numpy scipy h5py matplotlib pytest
```

### Install HDF5 (Ubuntu/Debian)

```bash
sudo apt-get install libhdf5-dev
```

---

## Step 1: Verify Python Reference (5 minutes)

```bash
# Navigate to reference implementation
cd /path/to/amss-ept-impl/reference

# Run all tests
cd ../tests
python -m pytest test_equation36.py -v
python -m pytest test_equation37_evolution.py -v
python -m pytest test_integration.py -v

# Expected: 29/29 tests PASSING ✅
```

**If tests fail:** Check Python version and dependencies.

---

## Step 2: Test Validation Suite (5 minutes)

```bash
# Create sample data
cd /path/to/amss-ept-impl/validation
python validation_suite.py --create-sample

# Run validation
python validation_suite.py --cpp-output sample_output.h5

# Expected output:
# ✅ Polynomial exactness
# ✅ Field-by-field comparison
# ✅ Stress tensor symmetry
# 🎉 ALL TESTS PASSED
```

---

## Step 3: Integrate into AMSS (10 minutes)

### Copy Files

```bash
# Navigate to AMSS source
cd /path/to/AMSS-NCKU

# Create EPT directories
mkdir -p src/ept
mkdir -p include/ept

# Copy C++ files
cp /path/to/cpp_implementation/ept_fields.h include/ept/
cp /path/to/cpp_implementation/equation36.cpp src/ept/
cp /path/to/cpp_implementation/equation37.cpp src/ept/
cp /path/to/cpp_implementation/ept_output.h include/ept/
```

### Modify Makefile

Add to `src/Makefile`:

```makefile
# EPT source files
EPT_SOURCES = \
    ept/equation36.cpp \
    ept/equation37.cpp

EPT_OBJECTS = $(EPT_SOURCES:.cpp=.o)

# Add to existing OBJECTS
OBJECTS += $(EPT_OBJECTS)

# Add include path
INCLUDES += -I./include/ept

# Compilation rule
ept/%.o: ept/%.cpp include/ept/ept_fields.h
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c $< -o $@
```

### Test Compilation

```bash
cd src
make clean
make ept/equation36.o
make ept/equation37.o

# Should compile without errors ✅
```

---

## Step 4: Run First Simulation (10 minutes)

### Copy Parameter File

```bash
cp /path/to/run_examples/gaussian_wave_ept.par .
```

### Edit for Quick Test

Modify `gaussian_wave_ept.par`:
```
# Smaller for quick test
nx = 32
ny = 32
nz = 32

t_final = 10.0
output_every_n_steps = 5
```

### Run

```bash
# Make run script executable
chmod +x /path/to/run_examples/run_amss_ept.sh

# Run simulation
./run_amss_ept.sh gaussian_wave_ept.par --nproc 4
```

**Expected:** Simulation completes in 1-2 minutes.

---

## Step 5: Analyze Results (5 minutes)

```bash
# Navigate to output directory
cd output/gaussian_wave_ept/

# Generate analysis report
python /path/to/tools/ept_analysis.py . --report analysis.pdf

# View report
evince analysis.pdf  # or your PDF viewer
```

**You should see:**
- Field evolution plots
- Stress tensor visualization
- Energy condition checks
- All looking physically reasonable ✅

---

## Quick Reference Card

### Run Simulation

```bash
./run_amss_ept.sh <parameter_file> [--nproc N] [--restart checkpoint.h5]
```

### Analyze Output

```bash
python ept_analysis.py <output_dir> --report results.pdf
```

### Check Convergence

```bash
python convergence_test.py --output output/run_*
```

### Validate C++ vs Python

```bash
python validation_suite.py --cpp-output data_0000.h5
```

### Manage Checkpoints

```bash
# List checkpoints
python checkpoint_restart.py --list output/checkpoints/

# Clean old ones
python checkpoint_restart.py --clean output/checkpoints/

# Verify integrity
python checkpoint_restart.py --verify checkpoint_000100.h5
```

---

## Common Issues and Solutions

### Issue: "module not found" errors

**Solution:**
```bash
# Add reference to Python path
export PYTHONPATH="/path/to/amss-ept-impl/reference:$PYTHONPATH"
```

### Issue: Compilation fails with HDF5 errors

**Solution:**
```bash
# Install HDF5 development headers
sudo apt-get install libhdf5-dev

# Or specify HDF5 path in Makefile
INCLUDES += -I/path/to/hdf5/include
LDFLAGS += -L/path/to/hdf5/lib -lhdf5
```

### Issue: Simulation crashes immediately

**Solution:**
```bash
# Check EPT fields are allocated
# In bssn_class constructor:
ept_fields.allocate(npts);

# Check parameters are read
# In parameter file:
enable_ept = true
```

### Issue: Fields grow exponentially

**Solution:**
```bash
# Increase damping
sigma_tau = 0.5  # was 0.1

# Reduce timestep
dt = 0.001  # was 0.01

# Check CFL condition
cfl_factor = 0.25
```

---

## Performance Tips

### For Testing (Fast)
```
nx = 32, dt = 0.01, t_final = 10.0
Runtime: ~1 minute
```

### For Production (Accurate)
```
nx = 128, dt = 0.005, t_final = 200.0
Runtime: ~hours (depends on CPU)
```

### Optimize Compilation
```makefile
CXXFLAGS = -O3 -march=native -fopenmp
```

### Use Multiple Cores
```bash
./run_amss_ept.sh params.par --nproc 16
```

---

## Next Steps

### 1. Run Binary Black Hole
```bash
./run_amss_ept.sh bbh_ept.par --nproc 32
```

### 2. Parameter Study
Vary λ₀, σ_τ to explore EPT effects

### 3. Compare with No-EPT
Run same IC with `enable_ept = false`

### 4. Analyze Waveforms
Extract gravitational waves at multiple radii

### 5. Write Paper! 🎉

---

## Documentation Reference

**Full Integration Guide:** `INTEGRATION_CHECKLIST.md`  
**Data Format:** `DATA_FORMAT_SPECIFICATION.md`  
**Performance:** `tools/performance_guide.py`  
**Examples:** `run_examples/`

---

## Getting Help

1. Check documentation in `/outputs/`
2. Run validation suite to verify setup
3. Check test suite: all should pass
4. Review example parameter files
5. Contact AMSS-NCKU team

---

## Success Checklist

- [x] Python tests pass (29/29)
- [x] Validation suite passes
- [x] C++ code compiles
- [x] AMSS runs with EPT
- [x] Output files created
- [x] Analysis tools work
- [x] Results look physical

**If all checked:** You're ready for production! 🚀

---

**Time to Science:** ~30 minutes from zero to first results!

**Last Updated:** February 12, 2026
