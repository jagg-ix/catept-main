# AMSS-NCKU EPT Integration Checklist

Complete step-by-step guide for integrating EPT into AMSS-NCKU.

**Estimated time:** 1-2 weeks  
**Difficulty:** Moderate  
**Prerequisites:** C++ knowledge, AMSS source code access

---

## Phase 1: Setup and Preparation (Day 1)

### 1.1 Environment Setup

- [ ] Clone AMSS-NCKU repository
- [ ] Verify AMSS compiles and runs without EPT
- [ ] Install Python dependencies for validation:
  ```bash
  pip install numpy scipy h5py matplotlib pytest
  ```
- [ ] Create EPT development branch:
  ```bash
  git checkout -b ept-integration
  ```

### 1.2 Directory Structure

- [ ] Create EPT directories in AMSS source tree:
  ```bash
  cd /path/to/AMSS-NCKU
  mkdir -p src/ept
  mkdir -p include/ept
  mkdir -p tests/ept
  ```

### 1.3 Copy Implementation Files

- [ ] Copy C++ headers:
  ```bash
  cp cpp_implementation/ept_fields.h include/ept/
  ```
- [ ] Copy C++ implementations:
  ```bash
  cp cpp_implementation/equation36.cpp src/ept/
  cp cpp_implementation/equation37.cpp src/ept/
  ```
- [ ] Copy Makefile modifications:
  ```bash
  cp cpp_implementation/Makefile src/ept/Makefile
  ```

**Verification:** Files in place
```bash
ls -la src/ept/
ls -la include/ept/
```

---

## Phase 2: Compilation Integration (Days 2-3)

### 2.1 Modify Main Makefile

- [ ] Add EPT source files to `src/Makefile`:
  ```makefile
  EPT_SOURCES = \
      ept/equation36.cpp \
      ept/equation37.cpp
  
  EPT_OBJECTS = $(EPT_SOURCES:.cpp=.o)
  
  OBJECTS += $(EPT_OBJECTS)
  ```

- [ ] Add include path:
  ```makefile
  INCLUDES += -I./include/ept
  ```

- [ ] Add compilation rule:
  ```makefile
  ept/%.o: ept/%.cpp include/ept/ept_fields.h
  	$(CXX) $(CXXFLAGS) $(INCLUDES) -c $< -o $@
  ```

### 2.2 Test Compilation

- [ ] Clean build:
  ```bash
  cd src
  make clean
  ```

- [ ] Compile EPT modules:
  ```bash
  make ept/equation36.o
  make ept/equation37.o
  ```

- [ ] Full compilation:
  ```bash
  make
  ```

**Verification:** No compilation errors
```bash
ls -la ept/*.o
```

---

## Phase 3: BSSN Integration (Days 4-6)

### 3.1 Add EPT Members to bssn_class

**File:** `include/bssn_class.h`

- [ ] Add EPT includes:
  ```cpp
  #include "ept/ept_fields.h"
  ```

- [ ] Add private members:
  ```cpp
  private:
      // EPT fields
      AMSS::EPT::EPTFields ept_fields;
      AMSS::EPT::StressTensor ept_stress;
      AMSS::EPT::EPTParams ept_params;
      
      // EPT RK staging
      AMSS::EPT::EPTFields ept_k1, ept_k2, ept_k3, ept_k4;
  ```

- [ ] Add EPT methods:
  ```cpp
  private:
      void init_ept_fields();
      void evolve_ept_rk4(double dt);
      void compute_ept_stress();
      void inject_ept_into_rhs();
  ```

### 3.2 Initialize EPT in Constructor

**File:** `src/bssn_class.C`

- [ ] In `bssn_class::bssn_class()` constructor:
  ```cpp
  // Allocate EPT fields
  ept_fields.allocate(npts);
  ept_stress.allocate(npts);
  
  ept_k1.allocate(npts);
  ept_k2.allocate(npts);
  ept_k3.allocate(npts);
  ept_k4.allocate(npts);
  
  // Set EPT parameters (read from input file)
  ept_params.lambda_0 = params.get_double("lambda_0", 1.0);
  ept_params.sigma_tau = params.get_double("sigma_tau", 0.1);
  ept_params.enable_eq36 = params.get_bool("enable_equation_36", true);
  ept_params.enable_eq37 = params.get_bool("enable_equation_37", true);
  ```

- [ ] Call initialization:
  ```cpp
  init_ept_fields();
  ```

### 3.3 Implement EPT Evolution Method

**File:** `src/bssn_class.C`

- [ ] Add method (see `bssn_ept_integration.patch` for full code):
  ```cpp
  void bssn_class::evolve_ept_rk4(double dt) {
      // Implement RK4 for phi, Pi, tau
      // See patch file for complete implementation
  }
  ```

### 3.4 Implement Stress Computation

- [ ] Add method:
  ```cpp
  void bssn_class::compute_ept_stress() {
      // Compute gradients
      AMSS::EPT::compute_phi_gradient(ept_fields, nx, ny, nz, dx, dy, dz);
      AMSS::EPT::compute_tau_gradient(ept_fields, nx, ny, nz, dx, dy, dz);
      
      // Zero stress
      ept_stress.zero();
      
      // Equation 36
      if (ept_params.enable_eq36) {
          AMSS::EPT::compute_equation36_flat(
              ept_fields, ept_stress, nx, ny, nz, dx, dy, dz
          );
      }
      
      // Equation 37
      if (ept_params.enable_eq37) {
          AMSS::EPT::compute_equation37_flat(
              ept_fields, ept_stress, ept_params.lambda_0, nx, ny, nz
          );
      }
      
      // Transform to BSSN conformal variables
      // S̃_ij = e^{-4φ} T_ij
      for (int i = 0; i < npts; i++) {
          double e4phi = exp(4.0 * phi[i]);
          double factor = 1.0 / e4phi;
          
          ept_stress.S_11[i] *= factor;
          ept_stress.S_12[i] *= factor;
          ept_stress.S_13[i] *= factor;
          ept_stress.S_22[i] *= factor;
          ept_stress.S_23[i] *= factor;
          ept_stress.S_33[i] *= factor;
      }
  }
  ```

### 3.5 Implement RHS Injection

- [ ] Add method:
  ```cpp
  void bssn_class::inject_ept_into_rhs() {
      const double EIGHT_PI = 8.0 * M_PI;
      
      for (int i = 0; i < npts; i++) {
          // Compute trace
          double trace = ept_stress.S_11[i] + ept_stress.S_22[i] + ept_stress.S_33[i];
          double one_third_trace = trace / 3.0;
          
          // Traceless part
          double S11_TF = ept_stress.S_11[i] - one_third_trace;
          double S22_TF = ept_stress.S_22[i] - one_third_trace;
          double S33_TF = ept_stress.S_33[i] - one_third_trace;
          
          // Inject into BSSN RHS
          KRF11[i] += EIGHT_PI * S11_TF;
          KRF12[i] += EIGHT_PI * ept_stress.S_12[i];
          KRF13[i] += EIGHT_PI * ept_stress.S_13[i];
          KRF22[i] += EIGHT_PI * S22_TF;
          KRF23[i] += EIGHT_PI * ept_stress.S_23[i];
          KRF33[i] += EIGHT_PI * S33_TF;
      }
  }
  ```

### 3.6 Integrate into RK Loop

**File:** `src/bssn_class.C`, method `bssn_class::rhs()`

- [ ] After BSSN RHS computation, add:
  ```cpp
  // Compute EPT stress
  compute_ept_stress();
  
  // Inject into RHS
  inject_ept_into_rhs();
  ```

**File:** `src/bssn_class.C`, method `bssn_class::step()`

- [ ] After BSSN time update, add:
  ```cpp
  // Evolve EPT fields
  evolve_ept_rk4(dt);
  ```

**Verification:** Code compiles
```bash
cd src
make clean && make
```

---

## Phase 4: Initial Data (Day 7)

### 4.1 Add EPT Initial Data Generator

**File:** `src/initial_data.C`

- [ ] Add Gaussian initial data:
  ```cpp
  if (params.initial_data_type == "ept_gaussian") {
      double amplitude = params.get_double("ept_gaussian_amplitude", 0.1);
      double width = params.get_double("ept_gaussian_width", 1.0);
      
      for (int i = 0; i < npts; i++) {
          double x = get_x(i);
          double y = get_y(i);
          double z = get_z(i);
          
          double r2 = x*x + y*y + z*z;
          
          ept_fields.phi_ent[i] = amplitude * exp(-r2 / (width*width));
          ept_fields.Pi_ent[i] = 0.0;
          ept_fields.tau_ent[i] = 1.0;
      }
  }
  ```

**Verification:** Initial data loads
```bash
./amss gaussian_wave_ept.par --check-initial-data
```

---

## Phase 5: Testing (Days 8-10)

### 5.1 Unit Tests

- [ ] Create test file: `tests/ept/test_equation36.cpp`
- [ ] Compile tests:
  ```bash
  cd tests/ept
  make
  ```
- [ ] Run tests:
  ```bash
  ./test_equation36
  ./test_equation37
  ```

**Verification:** All tests pass

### 5.2 Validation Against Python

- [ ] Run small test case:
  ```bash
  ./amss gaussian_wave_ept.par
  ```

- [ ] Validate output:
  ```bash
  python3 validation/validation_suite.py --cpp-output output/gaussian_wave_ept/data_0000.h5
  ```

**Verification:** Validation passes

### 5.3 Convergence Test

- [ ] Run at multiple resolutions: 32³, 64³, 128³
- [ ] Check convergence order:
  ```bash
  python3 tools/check_convergence.py output/*/
  ```

**Verification:** 4th-order convergence

---

## Phase 6: Production Testing (Days 11-14)

### 6.1 Gaussian Wave

- [ ] Run: `./run_amss_ept.sh gaussian_wave_ept.par`
- [ ] Check:
  - Fields remain finite
  - Energy conserved
  - No constraint violations
- [ ] Analyze:
  ```bash
  python3 tools/analyze_output.py output/gaussian_wave_ept/
  ```

### 6.2 Binary Black Hole

- [ ] Run: `./run_amss_ept.sh bbh_ept.par --nproc 32`
- [ ] Monitor:
  - Apparent horizons tracked
  - Waveforms extracted
  - EPT contribution measured
- [ ] Compare: BH-only vs BH+EPT

**Verification:** Physically reasonable results

---

## Phase 7: Performance Optimization (Optional)

### 7.1 Profile

- [ ] Compile with profiling:
  ```bash
  make CXXFLAGS="-O3 -pg"
  ```

- [ ] Run and analyze:
  ```bash
  ./amss test.par
  gprof amss gmon.out > profile.txt
  ```

### 7.2 Optimize

- [ ] Enable vectorization
- [ ] Cache derivatives
- [ ] Try GPU acceleration (if available)

**Target:** <20% overhead from EPT

---

## Phase 8: Documentation (Day 14)

### 8.1 Code Documentation

- [ ] Add Doxygen comments to EPT functions
- [ ] Update AMSS user manual

### 8.2 Science Documentation

- [ ] Document EPT parameters
- [ ] Provide example parameter files
- [ ] Write usage guide

---

## Final Checklist

### Code Quality

- [ ] All tests pass
- [ ] No memory leaks (run with valgrind)
- [ ] No compiler warnings
- [ ] Code formatted consistently

### Validation

- [ ] Python validation passes
- [ ] Convergence order correct (4th)
- [ ] Energy conservation verified
- [ ] Constraint violations acceptable

### Performance

- [ ] EPT overhead <25%
- [ ] Scales well with MPI
- [ ] Memory usage acceptable

### Documentation

- [ ] Parameter file examples provided
- [ ] README updated
- [ ] Integration guide complete

### Production Readiness

- [ ] Tested on multiple systems
- [ ] Reproducible results
- [ ] Error handling robust
- [ ] Output format documented

---

## Troubleshooting

### Common Issues

**Q: Compilation fails with "ept_fields.h not found"**
```bash
# Check include path in Makefile
INCLUDES += -I./include/ept
```

**Q: Linker error: undefined reference to compute_equation36**
```bash
# Ensure EPT objects are linked
OBJECTS += $(EPT_OBJECTS)
```

**Q: Simulation crashes immediately**
```bash
# Check EPT fields allocated
gdb ./amss
> run test.par
> backtrace
```

**Q: Fields grow exponentially**
```bash
# Increase damping
sigma_tau = 0.5  # in parameter file

# Or reduce timestep
dt = 0.001
```

**Q: Validation fails**
```bash
# Check grid spacing matches between C++ and Python
# Verify boundary conditions
# Compare field-by-field
```

---

## Success Criteria

✅ **Phase 1-2:** Code compiles  
✅ **Phase 3:** Integration complete, code runs  
✅ **Phase 4:** Initial data loads correctly  
✅ **Phase 5:** Tests pass, validation passes  
✅ **Phase 6:** Production runs complete  
✅ **Phase 7:** Performance acceptable  
✅ **Phase 8:** Documented  

**Status:** Ready for science! 🚀

---

## Next Steps After Integration

1. Run parameter study (vary λ₀, σ_τ)
2. Compare EPT vs no-EPT simulations
3. Analyze EPT contribution to GW signal
4. Write up results for publication
5. Submit to AMSS-NCKU main branch

---

**Total Time:** 1-2 weeks for experienced developer  
**Support:** Contact [maintainer] for help

**Last Updated:** February 12, 2026
