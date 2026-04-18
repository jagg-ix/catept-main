SHELL := /bin/bash
PY ?= python3
DB ?= data_pipeline/user_scripts/double_slit.sqlite3
TIDY_DIR ?= data_pipeline/user_scripts/tidy_output

.PHONY: help unit_check metric_check sympy_check data_license_check paper3_lock_check galpy_demo galpy_kernel_demo galpy_cat_ept_demo metric_demo metric_tensors metric_tensor_agreement connection_curvature entropic_step entropic_step_demo tensor_integration db_fast pipeline phase3 phase5 phase6 advanced paper_all bundle clean


help:
	@echo "Targets:"; \
	echo "  db_fast     Build SQLite DB from tidy CSVs (no XLSX parsing)"; \
	echo "  xlsx_pipeline  Parse bundled Excel files -> tidy_output -> SQLite DB"; \
	echo "  unit_check  Verify unit-normalization invariants (fs<->s, THz<->Hz)"; \
	echo "  metric_check  Verify CAT/EPT geometric-bridge invariants (no EinsteinPy required)"; \
	echo "  sympy_check  Optional: verify SymPy CAT/EPT plugin (SKIP if SymPy missing)"; \
	echo "  paper3_lock_check  Lock-check the explicit Paper3 connection formula C[phi]"; \
	echo "  galpy_demo  Optional: run galpy orbit demo with entropic-time timeline (SKIP if galpy missing)"; \
	echo "  galpy_kernel_demo  Optional: run galpy orbit demo through kernel Scenario/Engine/Clock (SKIP if galpy missing)"; \
	echo "  galpy_cat_ept_demo  Optional: run galpy CAT/EPT orbit demo (drag + tau_ent), kernel-based (SKIP if galpy missing)"; \
	echo "  qutip_demo  Optional: run QuTiP timeline demo (and complex-action mode) (SKIP if QuTiP missing)"; \
	echo "  qutip_cat_ept  Optional: run QuTiP CAT/EPT complex-action runner (Phase 6.5) (SKIP if QuTiP missing)"; \
	echo "  ogrepy_complex_efe  Optional: run Complex EFE tensor export (Phase 6.6) + OGRePy metric smoke-check"; \
	echo "  ogrepy_agreement    Optional: cross-check Ricci/Einstein tensors via OGRePy vs SymPy (Phase 6.7)"; \
	echo "  pythtb_demo  Optional: pythtb Hamiltonian timeline + optional QuTiP bridge (SKIP if pythtb missing)"; \
	echo "  metric_tensors  Verify Paper3 tensor correspondence (S_mu_nu, Lambda_mu_nu)"; \
	echo "  metric_tensor_agreement  If EinsteinPy is present, compare tensors using EinsteinPy vs SymPy"; \
	echo "  connection_curvature  Verify curvature computed from Γ vs Γ~ in equilibrium"; \
	echo "  entropic_step  Verify Paper3 adaptive entropic stepping controller"; \
	echo "  entropic_step_demo  Run adaptive entropic stepping demo scenario"; \
	echo "  tensor_integration  Evaluate Paper3 tensors along an entropic-time timeline (demo)"; \
	echo "  metric_demo  Run generalized kernel demo: metric + clocks (no EinsteinPy required)"; \
	echo "  pipeline    Verify pipeline assets exist (tidy_output + DB)"; \
	echo "  phase3      Run IFF baseline gates"; \
	echo "  phase5      Run paper-faithful predictions + PT layer"; \
	echo "  phase6      Run ADVANCED diagnostics (6.1/6.2/6.3)"; \
	echo "  paper_all   Run db_fast + phase3 + phase5 + phase6, collect logs/status"; \
	echo "  bundle      Build catsim_tirole_paper_bundle.zip";

PAPER_LOGS:
	@mkdir -p PAPER_LOGS

PAPER_TABLES:
	@mkdir -p PAPER_TABLES

unit_check: PAPER_LOGS
	@PYTHONPATH=src $(PY) scripts/unit_contract_check.py | tee PAPER_LOGS/00_unit_contract.log

galpy_demo: PAPER_LOGS PAPER_TABLES
	@PYTHONPATH=src $(PY) scripts/galpy_demo_run.py | tee PAPER_LOGS/00_galpy_demo.log

galpy_kernel_demo: PAPER_LOGS PAPER_TABLES
	@PYTHONPATH=src $(PY) scripts/galpy_kernel_demo_run.py | tee PAPER_LOGS/00_galpy_kernel_demo.log

# CAT/EPT extension demo for galpy (optional)
galpy_cat_ept_demo: PAPER_LOGS PAPER_TABLES
	@PYTHONPATH=src $(PY) scripts/galpy_cat_ept_kernel_demo_run.py --config configs/galpy_cat_ept.yaml | tee PAPER_LOGS/00_galpy_cat_ept.log

qutip_demo: PAPER_LOGS PAPER_TABLES
	@PYTHONPATH=src $(PY) scripts/qutip_timeline_demo.py --out PAPER_TABLES/ADVANCED/QUTIP_DEMO | tee PAPER_LOGS/00_qutip_demo.log
	@PYTHONPATH=src $(PY) scripts/qutip_timeline_demo.py --out PAPER_TABLES/ADVANCED/QUTIP_DEMO_COMPLEX_ACTION --complex_action | tee PAPER_LOGS/00_qutip_demo_complex_action.log

qutip_cat_ept: PAPER_LOGS PAPER_TABLES
	@PYTHONPATH=src $(PY) scripts/phase6_5_qutip_complex_action.py --config configs/qutip_cat_ept.yaml | tee PAPER_LOGS/03_phase6_5_qutip.log

ogrepy_complex_efe: PAPER_LOGS PAPER_TABLES
	@PYTHONPATH=src $(PY) scripts/phase6_6_ogrepy_complex_efe.py --out PAPER_TABLES/ADVANCED/OGREPY_COMPLEX_EFE | tee PAPER_LOGS/03_phase6_6_ogrepy_complex_efe.log

ogrepy_agreement: PAPER_LOGS PAPER_TABLES
	@PYTHONPATH=src $(PY) scripts/ogrepy_tensor_agreement_check.py --out PAPER_LOGS/ogrepy_agreement --tol 1e-6 | tee PAPER_LOGS/03_phase6_7_ogrepy_agreement.log
	@PYTHONPATH=src $(PY) scripts/phase6_8_pythtb_interop.py --out PAPER_TABLES/ADVANCED/PYTHTB_INTEROP | tee PAPER_LOGS/03_phase6_8_pythtb.log

# Phase 6.5: optional complex-action runner driven by profiles/constant lambda
qutip_cat_ept: PAPER_LOGS PAPER_TABLES
	@PYTHONPATH=src $(PY) scripts/phase6_5_qutip_complex_action.py --config configs/qutip_cat_ept.yaml | tee PAPER_LOGS/03_phase6_5_qutip.log

metric_check: PAPER_LOGS
	@PYTHONPATH=src $(PY) scripts/metric_contract_check.py | tee PAPER_LOGS/00_metric_contract.log
	@$(MAKE) sympy_check
	@$(MAKE) metric_tensors

sympy_check: PAPER_LOGS PAPER_TABLES
	@PYTHONPATH=src $(PY) scripts/sympy_ext_check.py | tee PAPER_LOGS/00_sympy_ext.log
	@$(MAKE) paper3_lock_check
	@$(MAKE) metric_tensor_agreement
	@$(MAKE) connection_curvature
	@$(MAKE) entropic_step
	@$(MAKE) entropic_step_demo
	@$(MAKE) tensor_integration

data_license_check: PAPER_LOGS
	@PYTHONPATH=src $(PY) scripts/data_license_check.py | tee PAPER_LOGS/00_data_license_check.log

tensor_integration: PAPER_LOGS PAPER_TABLES
	@PYTHONPATH=src $(PY) scripts/tensor_integration_demo_run.py | tee PAPER_LOGS/00_tensor_integration.log

paper3_lock_check: PAPER_LOGS PAPER_TABLES
	@PYTHONPATH=src $(PY) scripts/paper3_equation_lock_check.py | tee PAPER_LOGS/00_paper3_lock_check.log

connection_curvature: PAPER_LOGS PAPER_TABLES
	@PYTHONPATH=src $(PY) scripts/metric_connection_curvature_check.py | tee PAPER_LOGS/00_connection_curvature.log

metric_tensors: PAPER_LOGS PAPER_TABLES
	@PYTHONPATH=src $(PY) scripts/metric_tensor_check.py | tee PAPER_LOGS/00_metric_tensors.log

metric_tensor_agreement: PAPER_LOGS PAPER_TABLES
	@PYTHONPATH=src $(PY) scripts/metric_tensor_agreement_check.py --out PAPER_TABLES/ADVANCED/METRIC_TENSOR_AGREEMENT | tee PAPER_LOGS/00_metric_tensor_agreement.log

entropic_step: PAPER_LOGS PAPER_TABLES
	@PYTHONPATH=src $(PY) scripts/entropic_step_check.py | tee PAPER_LOGS/00_entropic_step.log

entropic_step_demo: PAPER_LOGS PAPER_TABLES
	@PYTHONPATH=src $(PY) scripts/entropic_step_demo_run.py --out PAPER_TABLES/ADVANCED/ENTROPIC_STEP_DEMO | tee PAPER_LOGS/00_entropic_step_demo.log

metric_demo: PAPER_LOGS PAPER_TABLES
	@PYTHONPATH=src $(PY) scripts/metric_demo_run.py --out PAPER_TABLES/ADVANCED/METRIC_DEMO | tee PAPER_LOGS/00_metric_demo.log

# Build DB quickly from tidy CSVs

# Full XLSX -> tidy -> SQLite pipeline (uses data_pipeline/source_data by default)
xlsx_pipeline: PAPER_LOGS
	@cd data_pipeline/user_scripts && $(PY) build_and_verify_pipeline.py run | tee ../../PAPER_LOGS/00_xlsx_pipeline.log
	@echo "[xlsx_pipeline] DB at data_pipeline/user_scripts/double_slit.sqlite3" | tee -a PAPER_LOGS/00_xlsx_pipeline.log

db_fast: PAPER_LOGS
	@$(PY) tools/build_db_from_tidy_csv.py --tidy_dir $(TIDY_DIR) --db $(DB) | tee PAPER_LOGS/00_db_fast.log

pipeline: PAPER_LOGS
	@test -d $(TIDY_DIR) || (echo "Missing $(TIDY_DIR). Provide tidy_output or run the XLSX pipeline." && exit 2)
	@test -f $(DB) || (echo "Missing DB $(DB). Run make db_fast first." && exit 2)
	@echo "OK" | tee PAPER_LOGS/00_pipeline_ok.log

phase3: PAPER_LOGS PAPER_TABLES
	@PYTHONPATH=src $(PY) scripts/phase3_iff_baseline_gates.py --db $(DB) --out PAPER_TABLES | tee PAPER_LOGS/01_phase3_iff.log

phase5: PAPER_LOGS PAPER_TABLES
	@PYTHONPATH=src $(PY) scripts/phase5_prediction_protocol.py --db $(DB) --out PAPER_TABLES | tee PAPER_LOGS/02_phase5_predictions.log

phase6: PAPER_LOGS PAPER_TABLES
	@PYTHONPATH=src $(PY) scripts/phase6_1_geometric_lambda.py --paper_tables PAPER_TABLES --config configs/enz_model.yaml --figure Fig_2b | tee PAPER_LOGS/03_phase6_1.log
	@PYTHONPATH=src $(PY) scripts/phase6_2_modular_proxy.py --obs_spectral PAPER_TABLES/OBSERVABLES/obs_spectral.csv --out PAPER_TABLES | tee PAPER_LOGS/03_phase6_2.log
	@PYTHONPATH=src $(PY) scripts/phase6_3_info_visibility_bound.py --obs_spectral PAPER_TABLES/OBSERVABLES/obs_spectral.csv --out PAPER_TABLES --deltaI_mode auto | tee PAPER_LOGS/03_phase6_3.log
	@PYTHONPATH=src $(PY) scripts/phase6_4_tensor_observables.py --bounds_csv PAPER_TABLES/ADVANCED/BOUNDS/info_visibility_bound.csv --tensor_config configs/paper3_tensors.yaml --out PAPER_TABLES | tee PAPER_LOGS/03_phase6_4.log
	@PYTHONPATH=src $(PY) scripts/phase6_5_qutip_complex_action.py --config configs/qutip_cat_ept.yaml | tee PAPER_LOGS/03_phase6_5_qutip.log
	@PYTHONPATH=src $(PY) scripts/phase6_6_ogrepy_complex_efe.py --out PAPER_TABLES/ADVANCED/OGREPY_COMPLEX_EFE | tee PAPER_LOGS/03_phase6_6_ogrepy_complex_efe.log
	@PYTHONPATH=src $(PY) scripts/phase6_6b_ogrepy_equilibrium_limit.py --out PAPER_TABLES/ADVANCED/OGREPY_COMPLEX_EFE_EQUILIBRIUM | tee PAPER_LOGS/03_phase6_6b_ogrepy_equilibrium.log
	@PYTHONPATH=src $(PY) scripts/phase6_18_complex_efe_equilibrium_test.py | tee PAPER_LOGS/03_phase6_18_complex_efe_equilibrium.log
	@PYTHONPATH=src $(PY) scripts/phase6_19_material_prior.py --emit-yaml | tee PAPER_LOGS/03_phase6_19_material_prior.log
	@PYTHONPATH=src $(PY) scripts/ogrepy_tensor_agreement_check.py --out PAPER_LOGS/ogrepy_agreement --tol 1e-6 | tee PAPER_LOGS/03_phase6_7_ogrepy_agreement.log
	@PYTHONPATH=src $(PY) scripts/phase6_8_pythtb_interop.py --out PAPER_TABLES/ADVANCED/PYTHTB_INTEROP | tee PAPER_LOGS/03_phase6_8_pythtb_interop.log
	@PYTHONPATH=src $(PY) scripts/phase6_9_qc_lattice_h_interop.py --out PAPER_TABLES/ADVANCED/QC_LATTICE_H_INTEROP | tee PAPER_LOGS/03_phase6_9_qc_lattice_h.log
	@PYTHONPATH=src $(PY) scripts/phase6_10_pyscf_interop.py --out PAPER_TABLES/ADVANCED/PYSCF_INTEROP | tee PAPER_LOGS/03_phase6_10_pyscf.log
	@PYTHONPATH=src $(PY) scripts/phase6_11_pynucastro_entropic.py --out PAPER_TABLES/ADVANCED/PYNUCASTRO_ENTROPIC | tee PAPER_LOGS/03_phase6_11_pynucastro.log
	@PYTHONPATH=src $(PY) scripts/phase6_12_pyne_entropic.py --out PAPER_TABLES/ADVANCED/PYNE_ENTROPIC | tee PAPER_LOGS/03_phase6_12_pyne.log
	@PYTHONPATH=src $(PY) scripts/phase6_12b_pyne_quantum_bridge.py --config configs/pyne_bridge.yaml --out PAPER_TABLES/ADVANCED/PYNE_BRIDGE | tee PAPER_LOGS/03_phase6_12b_pyne_bridge.log
	@PYTHONPATH=src $(PY) scripts/phase6_13_qg_path_integral.py | tee PAPER_LOGS/03_phase6_13_qg_path_integral.log
	@PYTHONPATH=src $(PY) scripts/phase6_14_complex_schrodinger_functional.py | tee PAPER_LOGS/03_phase6_14_csf.log
	@PYTHONPATH=src $(PY) scripts/phase6_16_meep_pyscf_bridge.py --out PAPER_TABLES/ADVANCED/MEEP_PYSCF_BRIDGE | tee PAPER_LOGS/03_phase6_16_meep_pyscf_bridge.log
	@PYTHONPATH=src $(PY) scripts/phase6_17_thermo_bridge.py --cat_ept_mode $(CAT_EPT_MODE) | tee PAPER_LOGS/03_phase6_17_thermo_bridge.log
	@PYTHONPATH=src $(PY) scripts/phase6_18_materials_project_cache.py --out PAPER_TABLES/ADVANCED/MP_CACHE | tee PAPER_LOGS/03_phase6_18_mp_cache.log
	@PYTHONPATH=src $(PY) scripts/phase6_19_sympy_cat_ept_smoke.py --out PAPER_TABLES/ADVANCED/SYMPY_CAT_EPT | tee PAPER_LOGS/03_phase6_19_sympy_cat_ept.log
	@PYTHONPATH=src $(PY) scripts/phase6_20_weak_field_metric_demo.py --out PAPER_TABLES/ADVANCED/WEAK_FIELD_METRIC | tee PAPER_LOGS/03_phase6_20_weak_field_metric.log
	@PYTHONPATH=src $(PY) scripts/phase6_21_optics_backends.py --out PAPER_TABLES/ADVANCED/OPTICS_INTEROP | tee PAPER_LOGS/03_phase6_21_optics.log
	@PYTHONPATH=src $(PY) scripts/phase6_22_lean_verify.py --out PAPER_TABLES/ADVANCED/LEAN_VERIFY | tee PAPER_LOGS/03_phase6_22_lean_verify.log
	@PYTHONPATH=src $(PY) scripts/phase6_23_pydyna_structural.py --out PAPER_TABLES/ADVANCED/PYDYNA_STRUCTURAL | tee PAPER_LOGS/03_phase6_23_pydyna_structural.log

advanced: phase6

paper_all: PAPER_LOGS PAPER_TABLES
	@$(PY) tools/write_config_snapshot.py
	@$(MAKE) unit_check
	@$(MAKE) metric_check
	@$(MAKE) sympy_check
	@$(MAKE) db_fast
	@$(MAKE) pipeline
	@$(MAKE) phase3
	@$(MAKE) phase5
	@$(MAKE) phase6
	@$(PY) tools/collect_status.py --paper_tables PAPER_TABLES --paper_logs PAPER_LOGS
	@echo "DONE" | tee PAPER_LOGS/99_paper_all_done.log

bundle: PAPER_LOGS
	@$(PY) tools/package_paper_bundle.py --repo . --out catsim_tirole_paper_bundle.zip | tee PAPER_LOGS/98_bundle.log
	@ls -lh catsim_tirole_paper_bundle.zip

clean:
	rm -rf PAPER_LOGS/STATUS

.PHONY: galpy_cat_ept

galpy_cat_ept:
	@echo "[galpy_cat_ept] running GALPY CAT/EPT kernel demo"
	@python scripts/galpy_cat_ept_kernel_demo_run.py > PAPER_LOGS/00_galpy_cat_ept.log 2>&1 || (cat PAPER_LOGS/00_galpy_cat_ept.log && exit 1)
	@echo "[galpy_cat_ept] done"

.PHONY: galpy_cat_ept_paper3

# Convenience: ensure Phase 6.4 tensor profiles (Paper3) exist, then run galpy CAT/EPT.
# This lets galpy auto-discover a tensor_profile_*.csv and derive lambda(t)=dphi/dt.
galpy_cat_ept_paper3: PAPER_LOGS PAPER_TABLES
	@echo "[galpy_cat_ept_paper3] building Phase 6.4 tensor profiles (Paper3)"
	@PYTHONPATH=src $(PY) scripts/phase6_4_tensor_observables.py --bounds_csv PAPER_TABLES/ADVANCED/BOUNDS/info_visibility_bound.csv --tensor_config configs/paper3_tensors.yaml --out PAPER_TABLES | tee PAPER_LOGS/03_phase6_4_for_galpy.log
	@echo "[galpy_cat_ept_paper3] running GALPY CAT/EPT demo (profile-driven if available)"
	@python scripts/galpy_cat_ept_kernel_demo_run.py > PAPER_LOGS/00_galpy_cat_ept_paper3.log 2>&1 || (cat PAPER_LOGS/00_galpy_cat_ept_paper3.log && exit 1)
	@echo "[galpy_cat_ept_paper3] done"

.PHONY: pythtb_demo

pythtb_demo: PAPER_LOGS PAPER_TABLES
	@echo "[pythtb_demo] running PYTHTB interoperability demo (profile-driven if available)"
	@PYTHONPATH=src $(PY) scripts/phase6_8_pythtb_interop.py --out PAPER_TABLES/ADVANCED/PYTHTB_INTEROP > PAPER_LOGS/00_pythtb_demo.log 2>&1 || (cat PAPER_LOGS/00_pythtb_demo.log && exit 1)
	@echo "[pythtb_demo] done"

# -----------------------------
# Option C: Material accuracy
# -----------------------------
.PHONY: material_proxy_table material_accuracy_table material_accuracy_drude

material_proxy_table:
	python scripts/materials/material_table_from_drude.py \
		--eps_inf 3.9 --omega_p 2.816683366100322e15 --gamma 1.0e14 \
		--out data/materials/ITO_eps_table_proxy.csv

material_accuracy_drude:
	python scripts/materials/material_compare_tables.py --enz_config configs/enz_model.yaml

material_accuracy_table:
	# ensure configs/enz_model.yaml is set to mode: table and eps_table_csv points to a CSV
	python scripts/materials/material_compare_tables.py --enz_config configs/enz_model.yaml



### Reproducibility (from XLSX) ###
.PHONY: repro_from_xlsx repro_clean_logs repro_show_artifacts

# Clean only reproducibility logs/artifacts (does NOT delete raw xlsx)
repro_clean_logs:
	@mkdir -p PAPER_LOGS
	@echo "Cleaning repro logs (PAPER_LOGS/*repro* and 00_xlsx_pipeline.log) ..."
	@rm -f PAPER_LOGS/*repro* PAPER_LOGS/00_xlsx_pipeline.log || true

# One-shot deterministic reproduction starting from bundled Excel sources:
# 1) Extract XLSX -> tidy CSVs -> SQLite + verification
# 2) Run full paper pipeline / gating
repro_from_xlsx:
	@mkdir -p PAPER_LOGS
	@echo "==[ Repro from XLSX ]=="
	@echo "Step 1/2: XLSX -> tidy CSVs -> SQLite (with verification)"
	@$(MAKE) xlsx_pipeline 2>&1 | tee PAPER_LOGS/01_repro_xlsx_pipeline.log
	@echo "Step 2/2: paper_all (full pipeline + gates)"
	@$(MAKE) paper_all 2>&1 | tee PAPER_LOGS/02_repro_paper_all.log
	@echo ""
	@echo "Repro completed. Key logs:"
	@echo "  - PAPER_LOGS/01_repro_xlsx_pipeline.log"
	@echo "  - PAPER_LOGS/02_repro_paper_all.log"
	@echo "Key artifacts:"
	@echo "  - data_pipeline/user_scripts/double_slit.sqlite3"
	@echo "  - data_pipeline/user_scripts/verification_report.csv"
	@echo "  - PAPER_TABLES/ (paper tables) and PAPER_FIGURES/ (if enabled)"

# Convenience: print locations of major artifacts without running anything
repro_show_artifacts:
	@echo "SQLite: data_pipeline/user_scripts/double_slit.sqlite3"
	@echo "Verification: data_pipeline/user_scripts/verification_report.csv"
	@echo "Tidy CSV dir: data_pipeline/tidy_output/"
	@echo "Paper tables: PAPER_TABLES/"
	@echo "Paper logs:   PAPER_LOGS/"


.PHONY: verify_source_data
verify_source_data:
	@python data_pipeline/verify_source_data_checksums.py


.PHONY: ui
ui:
	@echo "Install UI deps: pip install -r requirements-ui.txt"
	@streamlit run ui/app.py


### UI module CLIs (stable artifact contracts) ###
.PHONY: run_double_slit run_twin_paradox run_ringdown_fit

run_double_slit:
	@mkdir -p PAPER_TABLES/ADVANCED/UI/DOUBLE_SLIT/run_001
	@python -m scripts.ui_modules.double_slit_run --db data_pipeline/user_scripts/double_slit.sqlite3 --experiment 1 --out PAPER_TABLES/ADVANCED/UI/DOUBLE_SLIT/run_001

run_twin_paradox:
	@mkdir -p PAPER_TABLES/ADVANCED/UI/TWIN_PARADOX/run_001
	@python -m scripts.ui_modules.twin_paradox_run --out PAPER_TABLES/ADVANCED/UI/TWIN_PARADOX/run_001 --scenario out_and_back

run_ringdown_fit:
	@mkdir -p PAPER_TABLES/ADVANCED/UI/RINGDOWN/run_001
	@python -m scripts.ui_modules.ringdown_fit --out PAPER_TABLES/ADVANCED/UI/RINGDOWN/run_001 --synthetic --grid-search


.PHONY: run_double_slit_physics
run_double_slit_physics:
	@mkdir -p PAPER_TABLES/ADVANCED/UI/DOUBLE_SLIT/run_002_physics
	@python -m scripts.ui_modules.double_slit_run --db data_pipeline/user_scripts/double_slit.sqlite3 --experiment 1 --out PAPER_TABLES/ADVANCED/UI/DOUBLE_SLIT/run_002_physics --physics-enabled


.PHONY: run_double_slit_physics_multilayer
run_double_slit_physics_multilayer:
	@mkdir -p PAPER_TABLES/ADVANCED/UI/DOUBLE_SLIT/run_003_physics_multilayer
	@python -m scripts.ui_modules.double_slit_run \
	  --db data_pipeline/user_scripts/double_slit.sqlite3 \
	  --experiment 1 \
	  --out PAPER_TABLES/ADVANCED/UI/DOUBLE_SLIT/run_003_physics_multilayer \
	  --physics-enabled \
	  --eps-table data/materials/ITO_eps_table_proxy.csv \
	  --film-thickness-m 3e-7 \
	  --substrate-n 1.5 \
	  --nfft 8192 \
	  --window hann \
	  --auto-time-shift


.PHONY: run_double_slit_physics_stack
run_double_slit_physics_stack:
	@mkdir -p PAPER_TABLES/ADVANCED/UI/DOUBLE_SLIT/run_004_physics_stack
	@python -m scripts.ui_modules.double_slit_run \
	  --db data_pipeline/user_scripts/double_slit.sqlite3 \
	  --experiment 1 \
	  --out PAPER_TABLES/ADVANCED/UI/DOUBLE_SLIT/run_004_physics_stack \
	  --physics-enabled \
	  --eps-table data/materials/ITO_eps_table_proxy.csv \
	  --film-thickness-m 3e-7 \
	  --substrate-n 1.5 \
	  --stack-json data/materials/stack_example_air_ito_glass.json \
	  --nfft 8192 \
	  --window hann \
	  --preset tirole_default \
	  --auto-time-shift


.PHONY: run_double_slit_physics_stack_modes
run_double_slit_physics_stack_modes:
	@mkdir -p PAPER_TABLES/ADVANCED/UI/DOUBLE_SLIT/run_005_physics_stack_modes
	@python -m scripts.ui_modules.double_slit_run \
	  --db data_pipeline/user_scripts/double_slit.sqlite3 \
	  --experiment 1 \
	  --out PAPER_TABLES/ADVANCED/UI/DOUBLE_SLIT/run_005_physics_stack_modes \
	  --physics-enabled \
	  --eps-table data/materials/ITO_eps_table_proxy.csv \
	  --stack-json data/materials/stack_example_air_ito_glass.json \
	  --nfft 8192 \
	  --window hann \
	  --preset tirole_default \
	  --time-trace-mode auto \
	  --auto-time-shift


.PHONY: run_sgi_harness
run_sgi_harness:
	@mkdir -p PAPER_TABLES/ADVANCED/UI/SGI/run_001
	@python -m scripts.ui_modules.sgi_run \
	  --out PAPER_TABLES/ADVANCED/UI/SGI/run_001 \
	  --dt 1e-6 \
	  --mass-kg 1e-26 \
	  --mu-eff 9.2740100783e-24 \
	  --gravity 9.80665 \
	  --pulses "+200:0.002,-200:0.002,+200:0.002"


.PHONY: run_sgi_harness_close
run_sgi_harness_close:
	@mkdir -p PAPER_TABLES/ADVANCED/UI/SGI/run_002_closed
	@python -m scripts.ui_modules.sgi_run \
	  --out PAPER_TABLES/ADVANCED/UI/SGI/run_002_closed \
	  --dt 1e-6 \
	  --mass-kg 1e-26 \
	  --mu-eff 9.2740100783e-24 \
	  --gravity 9.80665 \
	  --template split_mirror_recombine \
	  --grad 200 \
	  --t1 0.002 --t2 0.002 --t3 0.002 \
	  --auto-close --auto-close-mode scale_last --close-grid 81


.PHONY: run_sgi_harness_close_shaped
run_sgi_harness_close_shaped:
	@mkdir -p PAPER_TABLES/ADVANCED/UI/SGI/run_003_closed_shaped
	@python -m scripts.ui_modules.sgi_run \
	  --out PAPER_TABLES/ADVANCED/UI/SGI/run_003_closed_shaped \
	  --dt 1e-6 \
	  --mass-kg 1e-26 \
	  --mu-eff 9.2740100783e-24 \
	  --gravity 9.80665 \
	  --template split_mirror_recombine \
	  --grad 200 \
	  --t1 0.002 --t2 0.002 --t3 0.002 \
	  --auto-close --auto-close-mode scale_last --close-grid 81 \
	  --shape tanh --ramp-frac 0.15


# --- SGI pipeline (paper-extracted txt -> sqlite) ---

.PHONY: verify_sgi_sources
verify_sgi_sources:
	@python -m scripts.sgi_verify_sources --dir data/sgi_txt

.PHONY: sgi_ingest
sgi_ingest: verify_sgi_sources
	@mkdir -p data/sgi
	@python -m scripts.sgi_ingest --in data/sgi_txt --out data/sgi/sgidb.sqlite

# Builds sgidb.sqlite, then runs the SGI harness (GR baseline) and produces manifest outputs.
.PHONY: sgi_repro
sgi_repro: sgi_ingest
	@mkdir -p PAPER_TABLES/ADVANCED/UI/SGI/run_from_db_001
	@python -m scripts.ui_modules.sgi_run \
	  --out PAPER_TABLES/ADVANCED/UI/SGI/run_from_db_001 \
	  --sgidb data/sgi/sgidb.sqlite \
	  --dt 1e-6 \
	  --mass-kg 1e-26 \
	  --mu-eff 9.2740100783e-24 \
	  --gravity 9.80665 \
	  --template split_mirror_recombine \
	  --grad 200 \
	  --t1 0.002 --t2 0.002 --t3 0.002 \
	  --auto-close --auto-close-mode scale_last --close-grid 81 \
	  --shape tanh --ramp-frac 0.15


.PHONY: sgi_export
sgi_export: sgi_ingest
	@mkdir -p PAPER_TABLES/SGI_DB_EXPORT
	@python -m scripts.sgi_export --db data/sgi/sgidb.sqlite --out PAPER_TABLES/SGI_DB_EXPORT


# --- SGI scan overlays (measured vs GR baseline proxy) ---

.PHONY: sgi_scan_fig6a
sgi_scan_fig6a: sgi_ingest
	@mkdir -p PAPER_TABLES/ADVANCED/UI/SGI/scan_fig6a_001
	@python -m scripts.ui_modules.sgi_scan \
	  --out PAPER_TABLES/ADVANCED/UI/SGI/scan_fig6a_001 \
	  --sgidb data/sgi/sgidb.sqlite \
	  --scan fig6a_dz \
	  --backend both \
	  --lambda-preset off --metric-mode minkowski \
	  --template split_mirror_recombine \
	  --auto-close --auto-close-mode scale_last --close-grid 81 \
	  --shape tanh --ramp-frac 0.15

.PHONY: sgi_scan_fig6b
sgi_scan_fig6b: sgi_ingest
	@mkdir -p PAPER_TABLES/ADVANCED/UI/SGI/scan_fig6b_001
	@python -m scripts.ui_modules.sgi_scan \
	  --out PAPER_TABLES/ADVANCED/UI/SGI/scan_fig6b_001 \
	  --sgidb data/sgi/sgidb.sqlite \
	  --scan fig6b_dv \
	  --backend both \
	  --lambda-preset off --metric-mode minkowski \
	  --template split_mirror_recombine \
	  --auto-close --auto-close-mode scale_last --close-grid 81 \
	  --shape tanh --ramp-frac 0.15

.PHONY: sgi_scan_fig8
sgi_scan_fig8: sgi_ingest
	@mkdir -p PAPER_TABLES/ADVANCED/UI/SGI/scan_fig8_001
	@python -m scripts.ui_modules.sgi_scan \
	  --out PAPER_TABLES/ADVANCED/UI/SGI/scan_fig8_001 \
	  --sgidb data/sgi/sgidb.sqlite \
	  --scan fig8_Td1 \
	  --auto-close --auto-close-mode scale_last --close-grid 81 \
	  --shape tanh --ramp-frac 0.15


# Demo targets (use nonzero lambda preset for extended backend sensitivity)
.PHONY: sgi_scan_fig6a_demo
sgi_scan_fig6a_demo: sgi_ingest
	@mkdir -p PAPER_TABLES/ADVANCED/UI/SGI/scan_fig6a_demo_001
	@python -m scripts.ui_modules.sgi_scan \
	  --out PAPER_TABLES/ADVANCED/UI/SGI/scan_fig6a_demo_001 \
	  --sgidb data/sgi/sgidb.sqlite \
	  --scan fig6a_dz \
	  --backend both \
	  --lambda-preset demo_med --metric-mode minkowski \
	  --template split_mirror_recombine \
	  --auto-close --auto-close-mode scale_last --close-grid 81 \
	  --shape tanh --ramp-frac 0.15

.PHONY: sgi_scan_fig6b_demo
sgi_scan_fig6b_demo: sgi_ingest
	@mkdir -p PAPER_TABLES/ADVANCED/UI/SGI/scan_fig6b_demo_001
	@python -m scripts.ui_modules.sgi_scan \
	  --out PAPER_TABLES/ADVANCED/UI/SGI/scan_fig6b_demo_001 \
	  --sgidb data/sgi/sgidb.sqlite \
	  --scan fig6b_dv \
	  --backend both \
	  --lambda-preset demo_med --metric-mode minkowski \
	  --template split_mirror_recombine \
	  --auto-close --auto-close-mode scale_last --close-grid 81 \
	  --shape tanh --ramp-frac 0.15


# QuTiP readout demo targets (visibility computed via path-qubit dephasing model)
.PHONY: sgi_scan_fig6a_qutip
sgi_scan_fig6a_qutip: sgi_ingest
	@mkdir -p PAPER_TABLES/ADVANCED/UI/SGI/scan_fig6a_qutip_001
	@python -m scripts.ui_modules.sgi_scan \
	  --out PAPER_TABLES/ADVANCED/UI/SGI/scan_fig6a_qutip_001 \
	  --sgidb data/sgi/sgidb.sqlite \
	  --scan fig6a_dz \
	  --backend both \
	  --lambda-preset off --metric-mode minkowski \
	  --quantum-backend qutip --channel-preset demo_med \
	  --template split_mirror_recombine \
	  --auto-close --auto-close-mode scale_last --close-grid 81 \
	  --shape tanh --ramp-frac 0.15

.PHONY: sgi_scan_fig6b_qutip
sgi_scan_fig6b_qutip: sgi_ingest
	@mkdir -p PAPER_TABLES/ADVANCED/UI/SGI/scan_fig6b_qutip_001
	@python -m scripts.ui_modules.sgi_scan \
	  --out PAPER_TABLES/ADVANCED/UI/SGI/scan_fig6b_qutip_001 \
	  --sgidb data/sgi/sgidb.sqlite \
	  --scan fig6b_dv \
	  --backend both \
	  --lambda-preset off --metric-mode minkowski \
	  --quantum-backend qutip --channel-preset demo_med \
	  --template split_mirror_recombine \
	  --auto-close --auto-close-mode scale_last --close-grid 81 \
	  --shape tanh --ramp-frac 0.15


.PHONY: sgi_db_validate
sgi_db_validate: sgi_ingest
	@python scripts/sgi_db_validate.py --repo .
	@echo "SGI DB validation report: PAPER_LOGS/SGI/sgidb_validate.json"


.PHONY: sgi_scan_fig8_qutip
sgi_scan_fig8_qutip: sgi_ingest
	@mkdir -p PAPER_TABLES/ADVANCED/UI/SGI/scan_fig8_qutip_001
	@python -m scripts.ui_modules.sgi_scan \
	  --out PAPER_TABLES/ADVANCED/UI/SGI/scan_fig8_qutip_001 \
	  --sgidb data/sgi/sgidb.sqlite \
	  --scan fig8_Td1 \
	  --backend both \
	  --lambda-preset off --metric-mode minkowski \
	  --quantum-backend qutip --channel-preset demo_med --quantum-mode timegrid \
	  --template four_pulse_close \
	  --auto-close --auto-close-mode scale_last --close-grid 81 \
	  --shape tanh --ramp-frac 0.15


# Dependency report
.PHONY: dep_report
dep_report:
	python -m scripts.dependency_report

.PHONY: sgi_scan_fig8_pi
sgi_scan_fig8_pi:
	python -m scripts.ui_modules.sgi_scan \
		--out PAPER_TABLES/ADVANCED/UI/SGI/scan_fig8_pi_001 \
		--sgidb data/sgi/sgidb.sqlite \
		--scan fig8_Td1 \
		--backend both \
		--lambda-preset off \
		--metric-mode minkowski \
		--quantum-backend path_integral --quantum-mode timegrid --channel-preset demo_med \
		--template split_mirror_recombine --auto-close --shape tanh


.PHONY: kerr_check
kerr_check:
	@python scripts/metric_kerr_einsteinpy_check.py --mass-kg 1.9885e30 --a-star 0.5 --theta-deg 90 --r-m 1e6 || true


# Kerr observer model demos (dtau/dt instead of static sqrt(-g_tt))
.PHONY: sgi_scan_fig6a_kerr_zamo
sgi_scan_fig6a_kerr_zamo: sgi_ingest
	@mkdir -p PAPER_TABLES/ADVANCED/UI/SGI/scan_fig6a_kerr_zamo_001
	@python -m scripts.ui_modules.sgi_scan \
	  --out PAPER_TABLES/ADVANCED/UI/SGI/scan_fig6a_kerr_zamo_001 \
	  --sgidb data/sgi/sgidb.sqlite \
	  --scan fig6a_dz \
	  --backend both \
	  --lambda-preset demo_med \
	  --metric-mode schwarzschild --metric-mass-kg 1.9885e30 --metric-a-star 0.9 --metric-theta-deg 90 \
	  --observer-mode zamo \
	  --template split_mirror_recombine \
	  --auto-close --auto-close-mode scale_last --close-grid 81 \
	  --shape tanh --ramp-frac 0.15

.PHONY: pi_check
pi_check:
	@python scripts/pi_check.py


.PHONY: sgi_scan_fig6a_scene_demo
sgi_scan_fig6a_scene_demo: sgi_ingest
	@mkdir -p PAPER_TABLES/ADVANCED/UI/SGI/scan_fig6a_scene_demo_001
	@python -m scripts.ui_modules.sgi_scan \
	  --out PAPER_TABLES/ADVANCED/UI/SGI/scan_fig6a_scene_demo_001 \
	  --sgidb data/sgi/sgidb.sqlite \
	  --scan fig6a_dz \
	  --backend both \
	  --lambda-preset demo_med \
	  --metric-mode schwarzschild --metric-mass-kg 1.9885e30 
	  --scene-width-m 0.02 --scene-height-m 0.02 \
	  --matter-energy-density 1e10 --matter-radius-m 0.003 --matter-placement top_right \
	  --bh-mass-kg 1e12 --bh-radius-m 0.002 --bh-placement bottom_left \
	  --scene-use-density-as-bath \
	  --quantum-backend qutip --channel-preset demo_med \
	  --template split_mirror_recombine \
	  --auto-close --auto-close-mode scale_last --close-grid 81 \
	  --shape tanh --ramp-frac 0.15

.PHONY: pi_coercivity_check
pi_coercivity_check:
	@python scripts/pi_coercivity_check.py


.PHONY: sgi_shielding_demo
sgi_shielding_demo:
	@mkdir -p PAPER_TABLES/ADVANCED/DIAG/SHIELDING/demo_kerr_center_001
	@python scripts/sgi_shielding_check.py \
	  --out PAPER_TABLES/ADVANCED/DIAG/SHIELDING/demo_kerr_center_001 \
	  --metric-mode schwarzschild --observer-mode zamo \
	  --scene-width-m 0.02 --scene-height-m 0.02 \
	  --bh-mass-kg 1e12 --bh-a-star 0.7 --bh-placement center \
	  --tmax-s 1.0 --n 2000 --r0-m 1e-2 --rmin-m 1e-6 \
	  --gamma-phi 1.0 --gamma-field constant


.PHONY: rg_flow_demo
rg_flow_demo:
	@mkdir -p PAPER_TABLES/ADVANCED/DIAG/RG/demo_001
	@python scripts/rg_flow_plot.py --out PAPER_TABLES/ADVANCED/DIAG/RG/demo_001 --registry auto


.PHONY: qutip_td_gamma_demo
qutip_td_gamma_demo:
	@mkdir -p PAPER_TABLES/ADVANCED/DIAG/QUTIP_TD_GAMMA/demo_001
	@python -m scripts.ui_modules.sgi_scan \
	  --out PAPER_TABLES/ADVANCED/DIAG/QUTIP_TD_GAMMA/demo_001 \
	  --sgidb data/sgi/sgidb.sqlite \
	  --scan fig6a_dz --backend extended \
	  --metric-mode schwarzschild --metric-mass-kg 1e12 
	  --scene-width-m 0.02 --scene-height-m 0.02 \
	  --matter-energy-density 1e10 --matter-radius-m 0.003 --matter-placement top_right \
	  --bh-mass-kg 1e12 --bh-radius-m 0.002 --bh-placement bottom_left \
	  --gamma-phi 1.0 --gamma-field scene_piecewise --gamma-region 5.0 \
	  --quantum-backend qutip --channel-preset demo_med \
	  --template split_mirror_recombine --auto-close


.PHONY: qutip_multi_bath_demo
qutip_multi_bath_demo:
	@mkdir -p PAPER_TABLES/ADVANCED/DIAG/QUTIP_MULTI_BATH/demo_001
	@python -m scripts.ui_modules.sgi_scan \
	  --out PAPER_TABLES/ADVANCED/DIAG/QUTIP_MULTI_BATH/demo_001 \
	  --sgidb data/sgi/sgidb.sqlite \
	  --scan fig6a_dz --backend extended \
	  --metric-mode schwarzschild --metric-mass-kg 1e12 
	  --scene-width-m 0.02 --scene-height-m 0.02 \
	  --matter-energy-density 1e10 --matter-radius-m 0.003 --matter-placement top_right \
	  --bh-mass-kg 1e12 --bh-radius-m 0.002 --bh-placement bottom_left \
	  --gamma-phi 1.0 --gamma-field scene_piecewise --gamma-region 5.0 \
	  --bath-model dephasing_relax_excite --bath-density-scale 1.0 \
	  --bath-dephasing-frac 1.0 --bath-relax-frac 0.2 --bath-excite-frac 0.05 \
	  --bath-density-field scene --bath-rho-ref 1.0 --bath-density-background 1.0 \
	  --quantum-backend qutip --channel-preset demo_med \
	  --template split_mirror_recombine --auto-close


.PHONY: end2end_sgi_density
end2end_sgi_density:
	@bash scripts/diag/run_end2end_sgi_density.sh


.PHONY: end2end_sgi_suite
end2end_sgi_suite:
	@bash scripts/diag/run_end2end_sgi_suite.sh

.PHONY: end2end_sgi_suite_require_qutip
    end2end_sgi_suite_require_qutip:
    	@REQUIRE_QUTIP=1 bash scripts/diag/run_end2end_sgi_suite.sh


.PHONY: end2end_sgi_suite_require_qutip_einsteinpy
    end2end_sgi_suite_require_qutip_einsteinpy:
    	@REQUIRE_QUTIP=1 REQUIRE_EINSTEINPY=1 bash scripts/diag/run_end2end_sgi_suite.sh


.PHONY: vendor_deps
vendor_deps:
	@bash scripts/third_party/build_vendor_deps.sh "$(QUTIP_REPO)" "$(EINSTEINPY_REPO)"


.PHONY: vendor_wheels
vendor_wheels:
	@bash scripts/third_party/fetch_wheels.sh

.PHONY: vendor_wheels_all_deps
vendor_wheels_all_deps:
	@PYTHON=$(PYTHON) WHEELHOUSE=third_party/wheels EXTRA_PIP_ARGS="--only-binary=:all:" PACKAGES="qutip einsteinpy numpy scipy sympy astropy matplotlib" \
		bash scripts/third_party/fetch_wheels.sh

.PHONY: vendor_wheels_here
vendor_wheels_here:
	@bash scripts/third_party/vendor_wheels_here.sh

.PHONY: install_offline_wheels
install_offline_wheels:
	@bash scripts/third_party/install_offline_wheels.sh

.PHONY: install_offline_wheels_with_requirements
install_offline_wheels_with_requirements:
	@REQUIREMENTS=1 bash scripts/third_party/install_offline_wheels.sh

.PHONY: add_wheel_tgz
add_wheel_tgz:
	@bash scripts/third_party/add_wheel_tgz.sh

.PHONY: fetch_wheelhouse_matrix
fetch_wheelhouse_matrix:
	@bash scripts/third_party/fetch_wheelhouse_matrix.sh

.PHONY: verify_wheelhouse_checksums
verify_wheelhouse_checksums:
	@bash scripts/third_party/verify_wheelhouse_checksums.sh
