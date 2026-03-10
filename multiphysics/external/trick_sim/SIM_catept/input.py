"""
SIM_catept Trick input file — CAT/EPT entropic time simulation.

Configures:
  - GUNNS fluid network: 5-node ladder, 2.5 S conductance, 2 atm supply
  - Entropic coupling: lambda_rate=0.08, tau_ent_0=0.0
  - Simulation duration: 10 s at 0.1 s timestep
  - Data recording: tau_ent, delta_s_i, lambda_eff to binary + ASCII
  - Variable Server: port 7000 (default Trick port)

Usage:
  cd SIM_catept && trick-CP && ./S_main_*.exe input.py

Variable Server client (external, e.g., from catept bridge):
  export CATEPT_TRICK_VARIABLE_SERVER=localhost:7000
  python3 -c "
  import socket, json
  s = socket.create_connection(('localhost', 7000))
  s.send(b'{\"op\":\"query\",\"variables\":[\"catept_sim.catept.tau_ent\"]}\n')
  print(s.recv(4096).decode())
  "
"""

import trick

# ─── Simulation end time ─────────────────────────────────────────────────────
trick.exec_set_terminate_time(10.0)

# ─── Real-time settings (disable for batch runs) ─────────────────────────────
# trick.exec_set_enable_real_time(False)   # uncomment for non-real-time batch

# ─── GUNNS network configuration ─────────────────────────────────────────────
catept_sim.catept.network_kind      = "fluid"
catept_sim.catept.node_count        = 5
catept_sim.catept.conductance_s     = 2.5
catept_sim.catept.supply_pressure_pa = 202650.0
catept_sim.catept.demand_flow_kg_s  = 1.2
catept_sim.catept.lambda_rate       = 0.08
catept_sim.catept.max_iters         = 50
catept_sim.catept.tolerance         = 1e-6

# ─── C++ runner (Phase 3, optional) ─────────────────────────────────────────
# Uncomment and set path to use the native C++ runner.
# If not set, the analytical stub is used automatically.
#
# catept_sim.catept.runner_path = "/path/to/tools/native/build/gunns_catept_runner"
#
# Or use the CATEPT_GUNNS_NATIVE_RUNNER environment variable:
#   export CATEPT_GUNNS_NATIVE_RUNNER=/path/to/gunns_catept_runner
#   ./S_main_*.exe input.py

# ─── Data recording — binary (compact, for post-processing) ─────────────────
drg_bin = trick.DRBinary("catept_entropic")
drg_bin.thisown = False
drg_bin.set_cycle(0.1)
drg_bin.freq = trick.DR_Always
drg_bin.add_variable("catept_sim.catept.tau_ent",       "tau_ent_s")
drg_bin.add_variable("catept_sim.catept.delta_s_i",     "delta_s_i")
drg_bin.add_variable("catept_sim.catept.lambda_eff",    "lambda_eff")
drg_bin.add_variable("catept_sim.catept.sim_time",      "sim_time_s")
drg_bin.add_variable("catept_sim.catept.net.tau_ent_next",        "tau_ent_next")
drg_bin.add_variable("catept_sim.catept.net.total_dissipation_w", "dissipation_w")
drg_bin.add_variable("catept_sim.catept.net.mass_flow_kg_s",      "mass_flow_kg_s")
drg_bin.add_variable("catept_sim.catept.net.flow_residual",       "flow_residual")
drg_bin.add_variable("catept_sim.catept.net.iterations",          "iterations")
drg_bin.add_variable("catept_sim.catept.net.converged",           "converged")
trick.add_data_record_group(drg_bin, trick.DR_Buffer)

# ─── Data recording — ASCII (human-readable) ─────────────────────────────────
drg_ascii = trick.DRAscii("catept_entropic_ascii")
drg_ascii.thisown = False
drg_ascii.set_cycle(0.5)
drg_ascii.freq = trick.DR_Always
drg_ascii.add_variable("catept_sim.catept.tau_ent",    "tau_ent_s")
drg_ascii.add_variable("catept_sim.catept.delta_s_i",  "delta_s_i")
drg_ascii.add_variable("catept_sim.catept.lambda_eff", "lambda_eff")
trick.add_data_record_group(drg_ascii, trick.DR_Buffer)

# ─── Variable Server configuration ───────────────────────────────────────────
# Default port 7000; override with:
# trick.var_server_set_port(7001)
#
# Subscribe to tau_ent from external client:
#   import socket
#   s = socket.create_connection(("localhost", 7000))
#   s.send(b"var_add catept_sim.catept.tau_ent\n")
#   s.send(b"var_cycle 0.1\n")

# ─── Freeze control (optional) ───────────────────────────────────────────────
# Freeze at t=5.0 to inspect state mid-sim:
# trick.exec_set_freeze_time(5.0)

# ─── Diagnostic print at shutdown ────────────────────────────────────────────
trick.add_read(9.9, """
print(f"[catept] t=9.9s  tau_ent={catept_sim.catept.tau_ent:.4f}  "
      f"delta_s_i={catept_sim.catept.delta_s_i:.4f}  "
      f"lambda_eff={catept_sim.catept.lambda_eff:.4f}")
""")
