"""Example: TeNPy TEBD with an entropic-clock stepping option.

Run:
  pip install -e '.[tenpy]'
  PYTHONPATH=src python examples/tensor_networks/run_tenpy_tebd_entropic.py

This runs a small XXZ chain and prints average magnetization over time.
If `use_entropic_time=True`, we interpret `dt_tau` as d\tau per step and map
into coordinate time using a constant `lambda_eff`.
"""

from __future__ import annotations

import argparse

from cat_ept_doubleslit.tensor_networks.tenpy_backend import TEBDRunConfig, run_xxz_tebd


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--L", type=int, default=16)
    ap.add_argument("--t_final", type=float, default=2.0)
    ap.add_argument("--dt", type=float, default=0.02, help="step size (t or tau depending on flag)")
    ap.add_argument("--use_entropic_time", action="store_true")
    ap.add_argument("--lambda_eff", type=float, default=1.0, help="effective lambda used for dt = dTau/lambda")
    ap.add_argument("--Jxy", type=float, default=1.0)
    ap.add_argument("--Jz", type=float, default=1.0)
    ap.add_argument("--hz", type=float, default=0.0)
    args = ap.parse_args()

    cfg = TEBDRunConfig(
        L=args.L,
        dt=complex(args.dt, 0.0),
        t_final=args.t_final,
        Jxy=args.Jxy,
        Jz=args.Jz,
        hz=args.hz,
        use_entropic_time=args.use_entropic_time,
        lambda_eff=args.lambda_eff,
    )

    out = run_xxz_tebd(cfg)
    t = out["t"]
    tau = out["tau"]
    sz = out["sz"]

    print("# idx\tt\ttau\t<sz>_avg")
    for i in range(len(t)):
        print(f"{i}\t{t[i]:.6g}\t{tau[i]:.6g}\t{sz[i]:.6g}")


if __name__ == "__main__":
    main()
