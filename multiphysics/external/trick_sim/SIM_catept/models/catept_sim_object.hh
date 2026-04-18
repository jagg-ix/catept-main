/**
 * catept_sim_object.hh — CAT/EPT Trick SimObject
 *
 * Integrates the CAT/EPT entropic time framework into a Trick simulation.
 * Wraps the GUNNS catept runner (or analytical stub) as a scheduled Trick job.
 *
 * The SimObject exposes tau_ent, delta_s_i, lambda_eff, and the full GUNNS
 * network state as Trick-managed variables accessible via the Variable Server.
 *
 * Build requirements:
 *   Trick 17.x+ with C++17 support
 *   gunns_catept_runner binary (Phase 3) or Python bridge fallback
 *
 * Usage (S_define):
 *   ##include "models/catept_sim_object.hh"
 *   CateptSimObject catept("fluid", 5, 2.5, 202650.0, 1.2, 0.08, 0.0, 0.1);
 *
 * Variable Server access (from input.py or external client):
 *   trick.var_send("catept.tau_ent")
 *   trick.var_send("catept.delta_s_i")
 *   trick.var_send("catept.lambda_eff")
 */

#pragma once

#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>
#include <vector>

// Maximum number of network nodes supported
static constexpr int CATEPT_MAX_NODES = 64;

/**
 * CateptNetworkState — full GUNNS network output, Trick-compatible (POD types).
 * POD arrays allow Trick's variable server to access individual elements.
 */
struct CateptNetworkState {
    int    node_count;                     // Number of network nodes
    int    edge_count;                     // Number of edges (= node_count - 1)
    int    iterations;                     // Solver iterations used
    bool   converged;                      // Convergence flag

    double flow_residual;                  // Residual norm of flow equations
    double constraint_norm;                // KCL constraint violation norm
    double total_dissipation_w;            // Total network power dissipation (W)
    double mass_flow_kg_s;                 // Mass flow at demand node (kg/s)
    double thermal_power_w;                // Thermal power (W, thermal nets)
    double electric_current_a;            // Electrical current (A, elec nets)

    double potentials[CATEPT_MAX_NODES];   // Nodal potentials (Pa, K, or V)
    double flows[CATEPT_MAX_NODES];        // Edge flow rates (kg/s, W, or A)

    // Entropic coupling outputs
    double lambda_rate;                    // Configured entropic rate
    double lambda_eff;                     // Effective entropic rate
    double tau_ent_0;                      // Entropic time at step start
    double tau_ent_next;                   // Entropic time at step end
    double delta_s_i;                      // Irreversible entropy increment

    char   network_kind[16];               // "fluid", "thermal", "electrical"
    char   backend_used[64];               // Backend identifier string
    char   native_hook_status[16];         // "native_ok" or "error"
};

/**
 * CateptSimObject — Trick SimObject wrapping CAT/EPT GUNNS integration.
 *
 * Trick-scheduled jobs:
 *   default_data()   — set default parameters
 *   initialize()     — validate params, first network solve
 *   step(dt)         — dynamic job: advance one timestep
 *   shutdown()       — cleanup
 */
class CateptSimObject {
public:
    // ── Public configuration (set via Trick input file) ──────────────────────
    char   runner_path[256];     // Path to gunns_catept_runner binary (or "python")
    char   network_kind[16];     // "fluid", "thermal", "electrical"
    int    node_count;           // Number of nodes (2 ≤ node_count ≤ CATEPT_MAX_NODES)
    double conductance_s;        // Network conductance (S, W/K, or kg/Pa/s)
    double supply_pressure_pa;   // Supply potential (Pa, K, or V)
    double demand_flow_kg_s;     // Demand flow at sink node (kg/s, W, or A)
    double lambda_rate;          // CAT/EPT entropic coupling rate
    double max_iters;            // Solver iteration limit
    double tolerance;            // Convergence tolerance

    // ── Trick-tracked state variables ─────────────────────────────────────────
    double tau_ent;              // Current entropic time (accumulated)
    double delta_s_i;            // Last step entropy increment
    double lambda_eff;           // Last step effective lambda
    double sim_time;             // Trick simulation time at last step

    // ── Full network state (accessible via Variable Server) ───────────────────
    CateptNetworkState net;

    // ── Constructor ───────────────────────────────────────────────────────────
    CateptSimObject();

    // ── Trick job methods ─────────────────────────────────────────────────────
    void default_data();
    void initialize();
    void step(double dt);
    void shutdown();

private:
    bool _solve_via_runner(double dt);
    bool _solve_analytical(double dt);
    void _apply_result(const CateptNetworkState& result);
    static void _safe_copy(char* dst, const char* src, int maxlen);
};
