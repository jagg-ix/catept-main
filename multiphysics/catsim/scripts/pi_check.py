from __future__ import annotations
from catsim_core.qg.phase_path_integral import visibility_from_phase_pi

def main() -> int:
    r0 = visibility_from_phase_pi(phi_final_rad=1.0, T_s=1.0, gamma_phi_s_inv=0.0, diagnostics=True)
    r1 = visibility_from_phase_pi(phi_final_rad=1.0, T_s=1.0, gamma_phi_s_inv=1.0, diagnostics=True)
    r2 = visibility_from_phase_pi(phi_final_rad=1.0, T_s=1.0, gamma_phi_s_inv=10.0, diagnostics=True)
    v0, v1, v2 = r0["visibility_pred"], r1["visibility_pred"], r2["visibility_pred"]
    ok = (0.0 <= v2 <= v1 <= v0 <= 2.0+1e-9) and ("diagnostics" in r0)
    print("PASS" if ok else "FAIL", "PI", v0, v1, v2)
    return 0 if ok else 1

if __name__ == "__main__":
    raise SystemExit(main())
