/-!
# AFPBridge Phase 1 — Flatten `Theories/` Layer — Worklog

Scope:
  Remove the intermediate `Theories/` subdirectory from the 17 AFP-ISA
  bridge modules that inherited it from the Isabelle AFP layout.
  Move all `*.lean` files one level up, delete the empty directory,
  and update import paths in `CATEPTMain/AFPBridge.lean`.

Parent orchestration:
  → CATEPTMain/AFPBridge/RESTRUCTURE_WORKLOG.lean  (RS-MASTER-002)

Next phase:
  → CATEPTMain/AFPBridge/PHASE2_STUBS_WORKLOG.lean

Execution order:
  Single-file modules first (lowest risk), then multi-file modules,
  largest last (NoFTL: 26 files, CBO: 18 files).

  QFT → QUAT → OCT → LSI → MODE → MTN → CPM → LAPL → MINK → ODE →
  PM → FOU → SM → IMD → HSTP → CBO → NoFTL

Per-module procedure:
  ```bash
  MOD=<module_name>
  BASE=CATEPTMain/AFPBridge

  # 1. Check for internal cross-imports (must be zero before moving)
  grep -r "AFPBridge\.$MOD\.Theories\." $BASE/$MOD/Theories/

  # 2. Move files
  mv $BASE/$MOD/Theories/*.lean $BASE/$MOD/

  # 3. Remove empty Theories/ dir
  rmdir $BASE/$MOD/Theories/

  # 4. Update barrel file (run from catept-main/)
  sed -i '' "s/AFPBridge\.$MOD\.Theories\./AFPBridge.$MOD\./g" \
      CATEPTMain/AFPBridge.lean

  # 5. Build just this module
  lake build CATEPTMain.AFPBridge.$MOD
  ```

Conventions:
  - RS-P1-{MOD}: per-module record
  - All records share Priority P1 (required for flattening milestone)
  - Status: TODO | IN-PROGRESS | DONE | BLOCKED
-/

/-!
## RS-P1-QFT  Flatten QFT/Theories/ (1 file) — P1

Target files:
  AFPBridge/QFT/Theories/QFT.lean  →  AFPBridge/QFT/QFT.lean

Barrel change (CATEPTMain/AFPBridge.lean):
  - `import CATEPTMain.AFPBridge.QFT.Theories.QFT`
  + `import CATEPTMain.AFPBridge.QFT.QFT`

Internal cross-imports to check: none expected (single file, no internal deps).

Validation:
  `lake build CATEPTMain.AFPBridge.QFT` → EXIT 0

Status: TODO
-/

/-!
## RS-P1-QUAT  Flatten QUAT/Theories/ (1 file) — P1

Target files:
  AFPBridge/QUAT/Theories/Unit_Quaternions.lean  →  AFPBridge/QUAT/Unit_Quaternions.lean

Barrel change:
  - `import CATEPTMain.AFPBridge.QUAT.Theories.Unit_Quaternions`
  + `import CATEPTMain.AFPBridge.QUAT.Unit_Quaternions`

Internal cross-imports to check: none expected.

Validation:
  `lake build CATEPTMain.AFPBridge.QUAT` → EXIT 0

Status: TODO
-/

/-!
## RS-P1-OCT  Flatten OCT/Theories/ (2 files) — P1

Target files:
  AFPBridge/OCT/Theories/Norm_Octonions.lean   →  AFPBridge/OCT/Norm_Octonions.lean
  AFPBridge/OCT/Theories/Octonion_Algebra.lean →  AFPBridge/OCT/Octonion_Algebra.lean

Barrel change (2 lines):
  - `import CATEPTMain.AFPBridge.OCT.Theories.Norm_Octonions`
  - `import CATEPTMain.AFPBridge.OCT.Theories.Octonion_Algebra`
  + `import CATEPTMain.AFPBridge.OCT.Norm_Octonions`
  + `import CATEPTMain.AFPBridge.OCT.Octonion_Algebra`

Internal cross-imports:
  Check whether `Norm_Octonions` imports `Octonion_Algebra` or vice-versa.
  Expected: `Octonion_Algebra` imported by `Norm_Octonions`. No path change
  needed for this import since both files move together.

Validation:
  `lake build CATEPTMain.AFPBridge.OCT` → EXIT 0

Status: TODO
-/

/-!
## RS-P1-LSI  Flatten LSI/Theories/ (2 files) — P1

Target files:
  AFPBridge/LSI/Theories/Lebesgue_Stieltjes_Integral.lean  →  AFPBridge/LSI/Lebesgue_Stieltjes_Integral.lean
  AFPBridge/LSI/Theories/Preliminaries_LSI.lean            →  AFPBridge/LSI/Preliminaries_LSI.lean

Barrel change (2 lines):
  - `import CATEPTMain.AFPBridge.LSI.Theories.Lebesgue_Stieltjes_Integral`
  - `import CATEPTMain.AFPBridge.LSI.Theories.Preliminaries_LSI`
  + `import CATEPTMain.AFPBridge.LSI.Lebesgue_Stieltjes_Integral`
  + `import CATEPTMain.AFPBridge.LSI.Preliminaries_LSI`

Internal cross-imports:
  `Lebesgue_Stieltjes_Integral` likely imports `Preliminaries_LSI`.
  Both move together; no path update needed for that internal import.

Validation:
  `lake build CATEPTMain.AFPBridge.LSI` → EXIT 0

Status: TODO
-/

/-!
## RS-P1-MODE  Flatten MODE/Theories/ (2 files) — P1

Target files:
  AFPBridge/MODE/Theories/Affine_ODE.lean  →  AFPBridge/MODE/Affine_ODE.lean
  AFPBridge/MODE/Theories/Matrix_Exp.lean  →  AFPBridge/MODE/Matrix_Exp.lean

Barrel change (2 lines):
  - `import CATEPTMain.AFPBridge.MODE.Theories.Affine_ODE`
  - `import CATEPTMain.AFPBridge.MODE.Theories.Matrix_Exp`
  + `import CATEPTMain.AFPBridge.MODE.Affine_ODE`
  + `import CATEPTMain.AFPBridge.MODE.Matrix_Exp`

Internal cross-imports:
  `Affine_ODE` may import `Matrix_Exp`. Both move together; no path change.

Validation:
  `lake build CATEPTMain.AFPBridge.MODE` → EXIT 0

Status: TODO
-/

/-!
## RS-P1-MTN  Flatten MTN/Theories/ (3 files) — P1

Target files:
  AFPBridge/MTN/Theories/Eigenvalues_Kron.lean  →  AFPBridge/MTN/Eigenvalues_Kron.lean
  AFPBridge/MTN/Theories/Kronecker_Product.lean →  AFPBridge/MTN/Kronecker_Product.lean
  AFPBridge/MTN/Theories/Mixed_Product.lean     →  AFPBridge/MTN/Mixed_Product.lean

Barrel change (3 lines):
  sed -i '' 's/AFPBridge\.MTN\.Theories\./AFPBridge.MTN./g' CATEPTMain/AFPBridge.lean

Internal cross-imports:
  `Eigenvalues_Kron` and `Mixed_Product` likely import `Kronecker_Product`.
  All move together; no path change for internal imports.

Validation:
  `lake build CATEPTMain.AFPBridge.MTN` → EXIT 0

Status: TODO
-/

/-!
## RS-P1-CPM  Flatten CPM/Theories/ (3 files) — P1

Target files:
  AFPBridge/CPM/Theories/Coproduct_Measure.lean            →  AFPBridge/CPM/Coproduct_Measure.lean
  AFPBridge/CPM/Theories/Coproduct_Measure_Additional.lean →  AFPBridge/CPM/Coproduct_Measure_Additional.lean
  AFPBridge/CPM/Theories/Lemmas_Coproduct_Measure.lean     →  AFPBridge/CPM/Lemmas_Coproduct_Measure.lean

Barrel change:
  sed -i '' 's/AFPBridge\.CPM\.Theories\./AFPBridge.CPM./g' CATEPTMain/AFPBridge.lean

Internal cross-imports:
  `Coproduct_Measure_Additional` and `Lemmas_Coproduct_Measure` import
  `Coproduct_Measure`. All move together; no path change.

Validation:
  `lake build CATEPTMain.AFPBridge.CPM` → EXIT 0

Status: TODO
-/

/-!
## RS-P1-LAPL  Flatten LAPL/Theories/ (3 files) — P1

Target files:
  AFPBridge/LAPL/Theories/Convolution_Theorem.lean →  AFPBridge/LAPL/Convolution_Theorem.lean
  AFPBridge/LAPL/Theories/Inversion.lean           →  AFPBridge/LAPL/Inversion.lean
  AFPBridge/LAPL/Theories/Laplace_Transform.lean   →  AFPBridge/LAPL/Laplace_Transform.lean

Barrel change:
  sed -i '' 's/AFPBridge\.LAPL\.Theories\./AFPBridge.LAPL./g' CATEPTMain/AFPBridge.lean

Internal cross-imports:
  `Convolution_Theorem` and `Inversion` likely import `Laplace_Transform`.
  All move together; no path change.

Validation:
  `lake build CATEPTMain.AFPBridge.LAPL` → EXIT 0

Status: TODO
-/

/-!
## RS-P1-MINK  Flatten MINK/Theories/ (3 files) — P1

Target files:
  AFPBridge/MINK/Theories/Convex_Body.lean   →  AFPBridge/MINK/Convex_Body.lean
  AFPBridge/MINK/Theories/Lattice_Points.lean →  AFPBridge/MINK/Lattice_Points.lean
  AFPBridge/MINK/Theories/Minkowski_Main.lean →  AFPBridge/MINK/Minkowski_Main.lean

Barrel change:
  sed -i '' 's/AFPBridge\.MINK\.Theories\./AFPBridge.MINK./g' CATEPTMain/AFPBridge.lean

Internal cross-imports:
  `Minkowski_Main` likely imports `Convex_Body` and `Lattice_Points`.
  All move together; no path change.

Validation:
  `lake build CATEPTMain.AFPBridge.MINK` → EXIT 0

Status: TODO
-/

/-!
## RS-P1-ODE  Flatten ODE/Theories/ (3 files) — P1

Target files:
  AFPBridge/ODE/Theories/Euler_Method.lean   →  AFPBridge/ODE/Euler_Method.lean
  AFPBridge/ODE/Theories/Flow.lean           →  AFPBridge/ODE/Flow.lean
  AFPBridge/ODE/Theories/Picard_Lindelof.lean →  AFPBridge/ODE/Picard_Lindelof.lean

Barrel change:
  sed -i '' 's/AFPBridge\.ODE\.Theories\./AFPBridge.ODE./g' CATEPTMain/AFPBridge.lean

Internal cross-imports:
  `Euler_Method` and `Flow` likely import `Picard_Lindelof` (base existence thm).
  All move together; no path change.

Validation:
  `lake build CATEPTMain.AFPBridge.ODE` → EXIT 0

Status: TODO
-/

/-!
## RS-P1-PM  Flatten PM/Theories/ (3 files) — P1

Target files:
  AFPBridge/PM/Theories/CHSH_Inequality.lean          →  AFPBridge/PM/CHSH_Inequality.lean
  AFPBridge/PM/Theories/Linear_Algebra_Complements.lean →  AFPBridge/PM/Linear_Algebra_Complements.lean
  AFPBridge/PM/Theories/Projective_Measurements.lean  →  AFPBridge/PM/Projective_Measurements.lean

Barrel change:
  sed -i '' 's/AFPBridge\.PM\.Theories\./AFPBridge.PM./g' CATEPTMain/AFPBridge.lean

Internal cross-imports:
  `Projective_Measurements` imports `Linear_Algebra_Complements`;
  `CHSH_Inequality` imports `Projective_Measurements`.
  All move together; no path change for internal imports.

Validation:
  `lake build CATEPTMain.AFPBridge.PM` → EXIT 0

Status: TODO
-/

/-!
## RS-P1-FOU  Flatten FOU/Theories/ (6 files) — P1

Target files:
  AFPBridge/FOU/Theories/Confine.lean          →  AFPBridge/FOU/Confine.lean
  AFPBridge/FOU/Theories/Fourier.lean          →  AFPBridge/FOU/Fourier.lean
  AFPBridge/FOU/Theories/Fourier_Aux2.lean     →  AFPBridge/FOU/Fourier_Aux2.lean
  AFPBridge/FOU/Theories/Lspace.lean           →  AFPBridge/FOU/Lspace.lean
  AFPBridge/FOU/Theories/Periodic.lean         →  AFPBridge/FOU/Periodic.lean
  AFPBridge/FOU/Theories/Square_Integrable.lean →  AFPBridge/FOU/Square_Integrable.lean

Barrel change:
  sed -i '' 's/AFPBridge\.FOU\.Theories\./AFPBridge.FOU./g' CATEPTMain/AFPBridge.lean

Internal cross-imports:
  `Fourier` imports `Periodic`, `Lspace`, `Square_Integrable`.
  `Fourier_Aux2` imports `Fourier`.
  `Confine` may import `Lspace`.
  All move together; no path change for internal imports.

Validation:
  `lake build CATEPTMain.AFPBridge.FOU` → EXIT 0

Status: TODO
-/

/-!
## RS-P1-SM  Flatten SM/Theories/ (12 files) — P1

Target files (12):
  Analysis_More, Bump_Function, Chart, Cotangent_Space,
  Differentiable_Manifold, Partition_Of_Unity, Product_Manifold,
  Projective_Space, Smooth, Sphere, Tangent_Space, Topological_Manifold

  Move: AFPBridge/SM/Theories/*.lean  →  AFPBridge/SM/

Barrel change:
  sed -i '' 's/AFPBridge\.SM\.Theories\./AFPBridge.SM./g' CATEPTMain/AFPBridge.lean

Internal cross-imports (HIGH likelihood — verify before moving):
  ```bash
  grep -r "AFPBridge\.SM\.Theories\." CATEPTMain/AFPBridge/SM/Theories/
  ```
  Expected: `Chart` ← `Smooth` ← `Differentiable_Manifold` chain.
  All move together; internal imports unchanged.

Validation:
  `lake build CATEPTMain.AFPBridge.SM` → EXIT 0

Status: TODO
-/

/-!
## RS-P1-IMD  Flatten IMD/Theories/ (13 files) — P1

Target files (13):
  Basics, Binary_Nat, Complex_Vectors, Deutsch, Deutsch_Jozsa,
  Entanglement, Measurement, More_Tensor, No_Cloning, Quantum,
  Quantum_Prisoners_Dilemma, Quantum_Teleportation, Tensor

  Move: AFPBridge/IMD/Theories/*.lean  →  AFPBridge/IMD/

Barrel change:
  sed -i '' 's/AFPBridge\.IMD\.Theories\./AFPBridge.IMD./g' CATEPTMain/AFPBridge.lean

Internal cross-imports (HIGH likelihood — verify before moving):
  ```bash
  grep -r "AFPBridge\.IMD\.Theories\." CATEPTMain/AFPBridge/IMD/Theories/
  ```
  Expected chain: `Basics` → `Tensor` / `Complex_Vectors` → `Quantum` →
  algorithm files (Deutsch, Entanglement, etc.).
  All move together; no path change for internal imports.

Validation:
  `lake build CATEPTMain.AFPBridge.IMD` → EXIT 0

Status: TODO
-/

/-!
## RS-P1-HSTP  Flatten HSTP/Theories/ (15 files) — P1

Target files (15):
  Compact_Operators, Eigenvalues, HS2Ell2, Hilbert_Space_Tensor_Product,
  Misc_TP, Misc_TP_TTS, Partial_Trace, Positive_Operators,
  Spectral_Theorem, Strong_Operator_Topology, Tensor_Product_Code,
  Trace_Class, Von_Neumann_Algebras, Weak_Operator_Topology,
  Weak_Star_Topology

  Move: AFPBridge/HSTP/Theories/*.lean  →  AFPBridge/HSTP/

Barrel change:
  sed -i '' 's/AFPBridge\.HSTP\.Theories\./AFPBridge.HSTP./g' CATEPTMain/AFPBridge.lean

Internal cross-imports (HIGH likelihood — verify before moving):
  ```bash
  grep -r "AFPBridge\.HSTP\.Theories\." CATEPTMain/AFPBridge/HSTP/Theories/
  ```
  Expected: deep import chain (`Von_Neumann_Algebras` ← `Trace_Class` ←
  `Partial_Trace` ← `Hilbert_Space_Tensor_Product` ← etc.).
  All move together; no path change for internal imports.

Validation:
  `lake build CATEPTMain.AFPBridge.HSTP` → EXIT 0

Status: TODO
-/

/-!
## RS-P1-CBO  Flatten CBO/Theories/ (18 files) — P1

Target files (18):
  Cblinfun_Code, Cblinfun_Code_Examples, Cblinfun_Matrix,
  Complex_Bounded_Linear_Function, Complex_Bounded_Linear_Function0,
  Complex_Euclidean_Space0, Complex_Inner_Product, Complex_Inner_Product0,
  Complex_L2, Complex_Vector_Spaces, Complex_Vector_Spaces0,
  Extra_General, Extra_Jordan_Normal_Form, Extra_Operator_Norm,
  Extra_Ordered_Fields, Extra_Pretty_Code_Examples, Extra_Vector_Spaces,
  One_Dimensional_Spaces

  Move: AFPBridge/CBO/Theories/*.lean  →  AFPBridge/CBO/

Barrel change:
  sed -i '' 's/AFPBridge\.CBO\.Theories\./AFPBridge.CBO./g' CATEPTMain/AFPBridge.lean

Internal cross-imports (HIGH likelihood — verify before moving):
  ```bash
  grep -r "AFPBridge\.CBO\.Theories\." CATEPTMain/AFPBridge/CBO/Theories/
  ```
  NOTE: CBO has the most internal dependencies. Expect a chain:
  `Extra_*` → `Complex_Vector_Spaces*` → `Complex_Inner_Product*` →
  `Complex_L2` → `Cblinfun_*`.
  All move together; no path change for internal imports.

  Also check if HSTP imports CBO:
  ```bash
  grep -r "AFPBridge\.CBO\.Theories\." CATEPTMain/AFPBridge/HSTP/
  ```
  If found, those imports must be updated AFTER CBO is moved.

Validation:
  `lake build CATEPTMain.AFPBridge.CBO` → EXIT 0
  `lake build CATEPTMain.AFPBridge.HSTP` → EXIT 0  (re-check after CBO move)

Status: TODO
-/

/-!
## RS-P1-NOFTL  Flatten NoFTL/Theories/ (26 files) — P1

Target files (26):
  Affine, AffineConeLemma, Cardinalities, CauchySchwarz, Classification,
  Functions, KeyLemma, LinearMaps, MainLemma, NoFTLGR, Norms,
  ObserverConeLemma, Points, Proposition1, Proposition2, Proposition3,
  Quadratics, ReverseCauchySchwarz, Sorts, Sublemma3, Sublemma4,
  TangentLineLemma, TangentLines, Translations, Vectors, WorldLine

  Move: AFPBridge/NoFTL/Theories/*.lean  →  AFPBridge/NoFTL/

Barrel change:
  sed -i '' 's/AFPBridge\.NoFTL\.Theories\./AFPBridge.NoFTL./g' CATEPTMain/AFPBridge.lean

Internal cross-imports (VERY HIGH likelihood — NoFTL has 26 files with
known deep dependency chain):
  ```bash
  grep -r "AFPBridge\.NoFTL\.Theories\." CATEPTMain/AFPBridge/NoFTL/Theories/
  ```
  All move together; no path change for internal imports.
  Notable: `NoFTL/NoFTLPrelude.lean` is at module root (not in Theories/).
  Verify it does NOT import `Theories/` paths:
  ```bash
  grep "Theories" CATEPTMain/AFPBridge/NoFTL/NoFTLPrelude.lean
  ```

Validation:
  `lake build CATEPTMain.AFPBridge.NoFTL` → EXIT 0

Status: TODO
-/

/-!
## RS-P1-BARREL  Update AFPBridge.lean barrel file — P1

After all 17 module moves are done, the barrel file must have zero remaining
`Theories.` path segments.

Verification:
  ```bash
  grep "Theories\." CATEPTMain/AFPBridge.lean
  ```
  Expected: no matches.

Also verify total import count is unchanged (only prefix changed, no imports
added or removed):
  ```bash
  grep "^import" CATEPTMain/AFPBridge.lean | wc -l
  ```
  Compare to baseline count from RS-MASTER-001.

Status: TODO
-/

/-!
## RS-P1-VALIDATE  Final Phase 1 validation — P0

After all module moves and barrel updates:

1. Full build:
   ```bash
   lake exe cache get
   lake build
   ```
   Expected: EXIT 0, no errors, no warnings about missing imports.

2. Sorry/axiom regression check:
   Compare current counts vs. baseline from RS-MASTER-001.
   ```bash
   grep -r "sorry" CATEPTMain/AFPBridge --include="*.lean" | grep -v WORKLOG | wc -l
   grep -r "^axiom" CATEPTMain/AFPBridge --include="*.lean" | wc -l
   ```
   Both counts must equal the baseline (no content changed, only paths).

3. No `Theories/` directories remain:
   ```bash
   find CATEPTMain/AFPBridge -type d -name "Theories"
   ```
   Expected: no output.

4. Commit:
   ```bash
   git add -A
   git commit -m "refactor: flatten AFPBridge Theories/ layer (Phase 1)"
   git tag phase1-flatten-done
   ```

Proceed to Phase 2:
  → CATEPTMain/AFPBridge/PHASE2_STUBS_WORKLOG.lean  (RS-P2-ASSESS)

Status: TODO
-/
