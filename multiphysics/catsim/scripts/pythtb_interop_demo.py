"""Optional pythtb interoperability demo.

What this demo proves
---------------------
1) pythtb can generate a Bloch Hamiltonian H(k)
2) catsim can attach the standard CAT/EPT timeline contract:
   (t_s, tau_ent_s, lambda_s_inv)
3) the same H(t) samples can be handed to QuTiP (if installed) to run
   non-Hermitian / complex-action evolution consistent with our QuTiP adapter.

We keep this demo *small* and *deterministic*.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

import numpy as np

from catsim_core.export.io import write_csv_rows
from catsim_core.gates.timeline_schema import gate_has_time_tau_lambda
from catsim_core.fields.phi_profile import PhiProfile
from catsim_core.pythtb.adapter import SSHParams, build_ssh_model, hamiltonian_matrix, pythtb_available
from catsim_core.pythtb.interop import build_timeline, pack_matrix_elements, qutip_available, to_qutip_qobj


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--out", required=True)
    p.add_argument("--k", type=float, default=0.23)
    p.add_argument("--dt_s", type=float, default=1e-15)
    p.add_argument("--n_steps", type=int, default=200)
    p.add_argument("--lambda_const", type=float, default=1e12)
    p.add_argument("--phi_profile_csv", default="")
    p.add_argument("--enable_qutip", action="store_true")
    args = p.parse_args()

    out_dir = Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)

    if not pythtb_available():
        (out_dir / "STATUS.md").write_text("# PYTHTB Interop Demo\n\n- skipped: true\n- reason: pythtb not installed\n", encoding="utf-8")
        (out_dir / "summary.json").write_text(json.dumps({"skipped": True, "pass": True}, indent=2), encoding="utf-8")
        return 0

    params = SSHParams()
    model = build_ssh_model(params)

    phi_prof = None
    if args.phi_profile_csv:
        prof_path = Path(args.phi_profile_csv)
        if prof_path.exists():
            phi_prof = PhiProfile.from_csv(prof_path)

    # Simple modulation: vary t2 slightly over time (a stand-in for coupling to other fields).
    def H_of_t(t: float) -> np.ndarray:
        # shallow deterministic modulation
        base = 1.0 + 0.05 * np.sin(2 * np.pi * t / (args.dt_s * args.n_steps))
        if phi_prof is not None:
            # Use a bounded contribution from the external Paper3 profile.
            # This demonstrates interop with the tensor/profile pipeline.
            phi_val = float(phi_prof.amplitude(t))
            base *= (1.0 + 0.01 * np.tanh(phi_val))
        t2 = float(params.t2 * base)
        model_local = build_ssh_model(SSHParams(t1=params.t1, t2=t2, onsite_a=params.onsite_a, onsite_b=params.onsite_b))
        return hamiltonian_matrix(model_local, args.k)

    if phi_prof is not None:
        lambda_fn = lambda t: float(phi_prof.lambda_eff(t))
    else:
        lambda_fn = lambda t: float(args.lambda_const)
    t_grid = np.arange(args.n_steps, dtype=float) * float(args.dt_s)
    samples = build_timeline(t_grid_s=t_grid, lambda_fn=lambda_fn, H_fn=H_of_t)

    rows = []
    for s in samples:
        row = {"t_s": s.t_s, "tau_ent_s": s.tau_ent_s, "lambda_s_inv": s.lambda_s_inv}
        row.update(pack_matrix_elements(s.H))
        rows.append(row)
    write_csv_rows(out_dir / "hamiltonian_timeline.csv", rows)

    gate_ok, gate_msg = gate_has_time_tau_lambda(rows[0])
    qutip_ran = False
    qutip_skipped = True
    if args.enable_qutip and qutip_available():
        qutip_skipped = False
        import qutip as qt

        # Build a piecewise-constant Hamiltonian list for mesolve
        H0 = to_qutip_qobj(samples[0].H)
        H_list = [H0]

        def coeff_factory(idx: int):
            return lambda t, _args=None: 1.0 if idx == int(t / args.dt_s) else 0.0

        for i in range(1, len(samples)):
            Hi = to_qutip_qobj(samples[i].H)
            H_list.append([Hi, coeff_factory(i)])

        psi0 = qt.basis(2, 0)
        tlist = t_grid
        res = qt.sesolve(H_list, psi0, tlist)
        # record a simple observable
        exp_z = qt.expect(qt.sigmaz(), res.states)
        write_csv_rows(out_dir / "qutip_expect.csv", [{"t_s": float(t), "exp_sigmaz": float(exp_z[i])} for i, t in enumerate(tlist)])
        qutip_ran = True

    summary = {
        "skipped": False,
        "gate_has_time_tau_lambda": gate_ok,
        "gate_msg": gate_msg,
        "enable_qutip": bool(args.enable_qutip),
        "qutip_skipped": qutip_skipped,
        "qutip_ran": qutip_ran,
        "pass": bool(gate_ok),
    }
    (out_dir / "summary.json").write_text(json.dumps(summary, indent=2), encoding="utf-8")
    (out_dir / "STATUS.md").write_text(
        "# PYTHTB Interop Demo\n\n"
        f"- gate_has_time_tau_lambda: {gate_ok} ({gate_msg})\n"
        f"- qutip: {'ran' if qutip_ran else ('skipped' if qutip_skipped else 'disabled')}\n"
        f"- PASS: {gate_ok}\n",
        encoding="utf-8",
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
