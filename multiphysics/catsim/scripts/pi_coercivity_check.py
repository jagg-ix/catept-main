from __future__ import annotations
import numpy as np
from catsim_core.qg.phase_path_integral import visibility_from_phase_pi

def main() -> int:
    t = np.linspace(0.0, 1.0, 200)
    x = np.zeros((len(t),3), dtype=float)
    def gamma(_t, _x): return 1.0
    out = visibility_from_phase_pi(phi_final_rad=1.0, T_s=1.0, t_s=t, dphi_dt_rad_s=np.ones_like(t),
                                  gamma_t_x=gamma, x_path_m=x, diagnostics=True)
    Gamma = float(out["Gamma"])
    ok = (Gamma >= 0.0) and np.isfinite(Gamma)
    print("PASS" if ok else "FAIL", "Gamma=", Gamma)
    return 0 if ok else 1

if __name__ == "__main__":
    raise SystemExit(main())
