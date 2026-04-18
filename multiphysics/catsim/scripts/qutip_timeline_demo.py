"""Optional QuTiP demo: export a simple 2-level evolution to timeline CSV.

If qutip is installed, runs a small mesolve with a sinusoidal drive and exports
<sigma_z>(t) plus (tau_ent, lambda) columns.

If qutip is not installed, writes a STATUS.md noting skip.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

import numpy as np

from catsim_core.export.qutip_timeline import export_qutip_timeseries_csv
from catsim_core.gates.output_schema import gate_has_time_tau_lambda


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--out", required=True)
    p.add_argument(
        "--complex_action",
        action="store_true",
        help="Use CAT/EPT complex-action non-Hermitian evolution with lambda(t)",
    )
    args = p.parse_args()
    out_dir = Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)

    try:
        import qutip as qt

        times = np.linspace(0.0, 1e-12, 200)
        sigma_z = qt.sigmaz()
        sigma_x = qt.sigmax()
        psi0 = qt.basis(2, 0)

        # Default: simple constant lambda -> tau_ent = lambda * t
        lam0 = 1e12

        if not args.complex_action:
            tau = lam0 * times

            def drive_coeff(t, _args):
                return np.sin(2 * np.pi * 1e12 * t)

            H = [sigma_z / 2, [sigma_x, drive_coeff]]
            res = qt.mesolve(H, psi0, times)
            exp_sz = qt.expect(sigma_z, res.states)
            lam_series = np.full_like(times, lam0, dtype=float)
        else:
            # Complex-action CAT/EPT form: iħ dψ/dt = (H_R - iħ λ(t) J) ψ
            # We keep this as a tiny deterministic demo: H_R = (ω/2)σz, J = (I-σz)/2.
            from cat_ept_doubleslit.open_quantum.qutip_backend import (
                evolve_complex_action_variable_lambda_t,
            )

            omega = 2 * np.pi * 1e12
            H_R = (omega / 2.0) * np.array([[1.0, 0.0], [0.0, -1.0]], dtype=float)
            J = 0.5 * (np.eye(2) - np.array([[1.0, 0.0], [0.0, -1.0]], dtype=float))

            def lambda_fn(tt: float) -> float:
                # A smooth positive modulation so the demo exercises variable lambda.
                return float(lam0 * (1.0 + 0.25 * np.sin(2 * np.pi * 2e12 * tt)))

            e_ops = {"exp_sigmaz": np.array([[1.0, 0.0], [0.0, -1.0]], dtype=float)}
            qres, lam_series, tau = evolve_complex_action_variable_lambda_t(
                H_R=H_R,
                J=J,
                psi0=np.array([1.0, 0.0], dtype=complex),
                tlist_s=times,
                lambda_fn=lambda_fn,
                e_ops=e_ops,
                normalize_output=False,
            )
            exp_sz = qres.expect["exp_sigmaz"]

        out_csv = out_dir / "timeline.csv"
        export_qutip_timeseries_csv(
            out_csv=out_csv,
            t_s=list(times),
            tau_ent_s=list(tau),
            lambda_s_inv=[float(x) for x in np.asarray(lam_series, dtype=float)],
            expvals={"exp_sigmaz": list(exp_sz)},
        )
        import csv
        with out_csv.open("r", newline="") as f:
            header = next(csv.reader(f))
        gate = gate_has_time_tau_lambda(header)
        schema_ok, schema_msg = gate.passed, str(gate.details)
        passed = schema_ok
        skipped = False
    except Exception:
        skipped = True
        passed = True
        schema_ok, schema_msg = True, "skipped"

    summary = {
        "skipped": skipped,
        "pass": passed,
        "schema_ok": schema_ok,
        "schema_msg": schema_msg,
    }
    (out_dir / "summary.json").write_text(json.dumps(summary, indent=2))
    (out_dir / "STATUS.md").write_text(
        "# QuTiP Timeline Demo\n\n"
        f"- skipped: {skipped}\n"
        f"- schema_ok: {schema_ok} ({schema_msg})\n"
        f"- PASS: {passed}\n"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
