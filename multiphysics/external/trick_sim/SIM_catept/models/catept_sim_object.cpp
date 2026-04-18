/**
 * catept_sim_object.cpp — CAT/EPT Trick SimObject implementation
 *
 * Implements CateptSimObject scheduled Trick jobs:
 *   default_data()  — defaults matching gunns_native_strict_sample_target.json
 *   initialize()    — first solve to establish initial network state
 *   step(dt)        — per-timestep entropic coupling update
 *   shutdown()      — no-op cleanup hook
 *
 * Runner dispatch strategy (checked in order):
 *   1. runner_path != "python" and binary exists → gunns_catept_runner subprocess
 *   2. Otherwise → analytical ladder-network stub (same numerics as Python bridge)
 *
 * The analytical stub is numerically identical to:
 *   gunns_entropic_bridge._nodal_admittance_solve()
 *   gunns_entropic_bridge._run_bridge_model()
 */

#include "catept_sim_object.hh"

#include <cerrno>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <sstream>
#include <string>

// ─── Utility ──────────────────────────────────────────────────────────────────

void CateptSimObject::_safe_copy(char* dst, const char* src, int maxlen) {
    std::strncpy(dst, src, maxlen - 1);
    dst[maxlen - 1] = '\0';
}

// ─── Constructor ──────────────────────────────────────────────────────────────

CateptSimObject::CateptSimObject() {
    default_data();
}

// ─── default_data ─────────────────────────────────────────────────────────────

void CateptSimObject::default_data() {
    _safe_copy(runner_path, "python", sizeof(runner_path));
    _safe_copy(network_kind, "fluid", sizeof(network_kind));
    node_count       = 5;
    conductance_s    = 2.5;
    supply_pressure_pa = 202650.0;
    demand_flow_kg_s   = 1.2;
    lambda_rate      = 0.08;
    max_iters        = 50.0;
    tolerance        = 1e-6;
    tau_ent          = 0.0;
    delta_s_i        = 0.0;
    lambda_eff       = 0.0;
    sim_time         = 0.0;

    std::memset(&net, 0, sizeof(net));
    _safe_copy(net.network_kind, network_kind, sizeof(net.network_kind));
    _safe_copy(net.backend_used, "uninitialized", sizeof(net.backend_used));
    _safe_copy(net.native_hook_status, "pending", sizeof(net.native_hook_status));
    net.node_count = node_count;
}

// ─── initialize ───────────────────────────────────────────────────────────────

void CateptSimObject::initialize() {
    if (node_count < 2) {
        std::fprintf(stderr, "[CateptSimObject] node_count=%d < 2; clamping to 2\n", node_count);
        node_count = 2;
    }
    if (node_count > CATEPT_MAX_NODES) {
        std::fprintf(stderr, "[CateptSimObject] node_count=%d > %d; clamping\n",
                     node_count, CATEPT_MAX_NODES);
        node_count = CATEPT_MAX_NODES;
    }

    // Initial solve with dt=0 (establish baseline state)
    step(0.0);
    tau_ent = 0.0;  // Reset accumulated tau after init solve
    std::fprintf(stderr,
        "[CateptSimObject] initialized: network=%s nodes=%d backend=%s\n",
        network_kind, node_count, net.backend_used);
}

// ─── Analytical solver (mirrors Python bridge) ────────────────────────────────

bool CateptSimObject::_solve_analytical(double dt) {
    int n       = node_count;
    double g_e  = conductance_s / std::max(1, n - 1);
    double dP   = supply_pressure_pa / static_cast<double>(n);

    // Uniform-drop initial guess
    double phi[CATEPT_MAX_NODES];
    for (int i = 0; i < n; ++i)
        phi[i] = supply_pressure_pa - i * dP;

    // Gauss-Seidel iterations
    int iters = 0;
    double res = 0.0;
    int max_it = static_cast<int>(max_iters);
    for (int it = 0; it < max_it; ++it) {
        double phi_new[CATEPT_MAX_NODES];
        phi_new[0] = supply_pressure_pa;
        for (int j = 1; j < n - 1; ++j)
            phi_new[j] = (g_e * phi[j-1] + g_e * phi[j+1]) / (2.0 * g_e);
        phi_new[n-1] = std::max(0.0, supply_pressure_pa - (n-1) * dP);

        res = 0.0;
        for (int j = 0; j < n; ++j)
            res += std::fabs(phi_new[j] - phi[j]);
        for (int j = 0; j < n; ++j)
            phi[j] = phi_new[j];
        ++iters;
        if (res < tolerance) break;
    }

    // Edge flows and dissipation
    double flows[CATEPT_MAX_NODES];
    double dissipation = 0.0;
    double kcl = 0.0;
    for (int j = 0; j < n - 1; ++j) {
        double dP_edge = phi[j] - phi[j+1];
        flows[j] = g_e * dP_edge;
        dissipation += g_e * dP_edge * dP_edge;
    }
    for (int j = 1; j < n - 1; ++j)
        kcl += std::fabs(flows[j-1] - flows[j]);

    // Fill net state
    net.node_count          = n;
    net.edge_count          = n - 1;
    net.iterations          = iters;
    net.converged           = (res < tolerance * 10.0);
    net.flow_residual       = res;
    net.constraint_norm     = kcl;
    net.total_dissipation_w = dissipation;
    net.mass_flow_kg_s      = (std::strcmp(net.network_kind, "fluid") == 0)
                                ? demand_flow_kg_s * (1.0 + 0.05 * flows[0] / std::max(1e-9, demand_flow_kg_s))
                                : 0.0;
    net.thermal_power_w     = (std::strcmp(net.network_kind, "thermal") == 0)
                                ? dissipation * 0.1 : 0.0;
    net.electric_current_a  = (std::strcmp(net.network_kind, "electrical") == 0)
                                ? flows[0] : 0.0;

    for (int i = 0; i < n; ++i)        net.potentials[i] = phi[i];
    for (int i = 0; i < n - 1; ++i)    net.flows[i]      = flows[i];

    // Entropic coupling
    double p_ref      = supply_pressure_pa * demand_flow_kg_s;
    double p_ratio    = dissipation / std::max(1e-9, p_ref);
    net.lambda_rate   = lambda_rate;
    net.lambda_eff    = lambda_rate * (1.0 + std::log1p(p_ratio));
    net.tau_ent_0     = tau_ent;
    net.delta_s_i     = net.lambda_eff * dt * (1.0 + 0.05 * (n - 2));
    net.tau_ent_next  = tau_ent + net.delta_s_i;

    _safe_copy(net.backend_used,      "analytical_trick_simobject", sizeof(net.backend_used));
    _safe_copy(net.native_hook_status,"native_ok",                  sizeof(net.native_hook_status));
    return true;
}

// ─── Runner subprocess dispatch ───────────────────────────────────────────────

bool CateptSimObject::_solve_via_runner(double dt) {
    // Build JSON request
    char req[1024];
    std::snprintf(req, sizeof(req),
        "{\"op\":\"gunns_network_step\","
        "\"contract_version\":1,"
        "\"node_count\":%d,"
        "\"conductance_s\":%.6f,"
        "\"supply_pressure_pa\":%.4f,"
        "\"demand_flow_kg_s\":%.6f,"
        "\"network_kind\":\"%s\","
        "\"lambda_rate\":%.8f,"
        "\"tau_ent_0\":%.8f,"
        "\"dt\":%.8f,"
        "\"max_iters\":%d,"
        "\"tolerance\":%.2e}",
        node_count, conductance_s, supply_pressure_pa, demand_flow_kg_s,
        network_kind, lambda_rate, tau_ent, dt, static_cast<int>(max_iters), tolerance);

    // Pipe request to runner and capture stdout
    char cmd[512];
    std::snprintf(cmd, sizeof(cmd), "echo '%s' | %s", req, runner_path);
    FILE* pipe = popen(cmd, "r");
    if (!pipe) {
        std::fprintf(stderr, "[CateptSimObject] popen failed: %s\n", strerror(errno));
        return false;
    }

    char response[8192];
    size_t n_read = fread(response, 1, sizeof(response) - 1, pipe);
    pclose(pipe);
    response[n_read] = '\0';

    // Parse key values from response JSON (minimal extraction)
    auto extract_double = [&](const char* key, double def) -> double {
        char pattern[64];
        std::snprintf(pattern, sizeof(pattern), "\"%s\":", key);
        const char* pos = std::strstr(response, pattern);
        if (!pos) return def;
        pos += std::strlen(pattern);
        while (*pos == ' ') ++pos;
        return std::atof(pos);
    };
    auto extract_int = [&](const char* key, int def) -> int {
        char pattern[64];
        std::snprintf(pattern, sizeof(pattern), "\"%s\":", key);
        const char* pos = std::strstr(response, pattern);
        if (!pos) return def;
        pos += std::strlen(pattern);
        while (*pos == ' ') ++pos;
        return std::atoi(pos);
    };
    auto extract_bool = [&](const char* key, bool def) -> bool {
        char pattern[64];
        std::snprintf(pattern, sizeof(pattern), "\"%s\":", key);
        const char* pos = std::strstr(response, pattern);
        if (!pos) return def;
        pos += std::strlen(pattern);
        while (*pos == ' ') ++pos;
        return std::strncmp(pos, "true", 4) == 0;
    };

    // Check for error response
    if (std::strstr(response, "\"gunns_network_step_error\"") != nullptr) {
        std::fprintf(stderr, "[CateptSimObject] runner returned error: %.200s\n", response);
        return false;
    }

    net.node_count          = extract_int("node_count",          node_count);
    net.edge_count          = extract_int("edge_count",          node_count - 1);
    net.iterations          = extract_int("iterations",          0);
    net.converged           = extract_bool("converged",          false);
    net.flow_residual       = extract_double("flow_residual",    0.0);
    net.constraint_norm     = extract_double("constraint_norm",  0.0);
    net.total_dissipation_w = extract_double("total_dissipation_w", 0.0);
    net.mass_flow_kg_s      = extract_double("mass_flow_kg_s",   0.0);
    net.thermal_power_w     = extract_double("thermal_power_w",  0.0);
    net.electric_current_a  = extract_double("electric_current_a", 0.0);
    net.lambda_rate         = lambda_rate;
    net.lambda_eff          = extract_double("lambda_eff",       0.0);
    net.tau_ent_0           = tau_ent;
    net.delta_s_i           = extract_double("delta_s_i",        0.0);
    net.tau_ent_next        = extract_double("tau_ent_next",     tau_ent);

    _safe_copy(net.backend_used,      "gunns_catept_runner_cpp", sizeof(net.backend_used));
    _safe_copy(net.native_hook_status,"native_ok",               sizeof(net.native_hook_status));
    return true;
}

// ─── step ─────────────────────────────────────────────────────────────────────

void CateptSimObject::step(double dt) {
    _safe_copy(net.network_kind, network_kind, sizeof(net.network_kind));

    bool ok = false;

    // Try C++ runner if configured and not "python"
    if (std::strcmp(runner_path, "python") != 0 && runner_path[0] != '\0') {
        ok = _solve_via_runner(dt);
        if (!ok) {
            std::fprintf(stderr,
                "[CateptSimObject] runner failed; falling back to analytical stub\n");
        }
    }

    if (!ok) {
        ok = _solve_analytical(dt);
    }

    if (ok) {
        tau_ent    = net.tau_ent_next;
        delta_s_i  = net.delta_s_i;
        lambda_eff = net.lambda_eff;
    }
    sim_time += dt;
}

// ─── shutdown ─────────────────────────────────────────────────────────────────

void CateptSimObject::shutdown() {
    std::fprintf(stderr,
        "[CateptSimObject] shutdown: tau_ent=%.6f delta_s_i=%.6f lambda_eff=%.6f\n",
        tau_ent, delta_s_i, lambda_eff);
}
