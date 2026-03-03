from __future__ import annotations
import json
from pathlib import Path
import numpy as np
import pandas as pd

from catsim_core.spacetime.scene import RectRegion, MatterRegion, BlackHoleSpec, Scene
from catsim_core.thermo.density_field import DensityScaleKnobs, scale_field_from_scene, scale_path_from_field
from catsim_core.thermo.bath_models import BathRateKnobs, rates_from_base_gamma
from catsim_quantum.qutip_interferometer import simulate_visibility_timegrid_multi

def main():
    out = Path("PAPER_TABLES/ADVANCED/DIAG/DENSITY_FIELD_TEST/demo_001")
    out.mkdir(parents=True, exist_ok=True)

    # Build a scene with explicit placements
    reg = RectRegion(width_m=0.02, height_m=0.02)
    matter = MatterRegion(placement="top_right", radius_m=0.003, mean_energy_density_J_m3=10.0)
    bh = BlackHoleSpec(placement="bottom_left", mass_kg=1.0, a_star=0.0, radius_m=0.002)
    scene = Scene(region=reg, matter=matter, black_hole=bh)
    ctx = scene.to_context()

    # Build a path that sweeps diagonally through the region
    N = 800
    t = np.linspace(0.0, 1e-3, N)
    x = np.zeros((N,3), dtype=float)
    x[:,0] = np.linspace(-0.012, 0.012, N)
    x[:,1] = np.linspace(-0.012, 0.012, N)
    x[:,2] = 0.0

    # base gamma(t) (arbitrary for test) and a simple phase-rate
    gamma_base = np.full_like(t, 2.0)  # 1/s
    phi_final = 3.0
    phi_t = np.linspace(0.0, phi_final, N)
    dOmega = np.gradient(phi_t, t, edge_order=1)

    # Density scale field from the scene (placement-aware)
    sf = scale_field_from_scene(ctx, DensityScaleKnobs(rho_ref=1.0, background=1.0))
    scale_path = scale_path_from_field(x, sf)

    # Map to bath rates (multi-channel split)
    bknobs = BathRateKnobs(density_scale=1.0, dephasing_frac=1.0, relax_frac=0.2, excite_frac=0.05)
    rates = rates_from_base_gamma(t, gamma_base, bknobs, model="dephasing_relax_excite", scale_path=scale_path)

    # Run QuTiP multi-channel prediction
    res = simulate_visibility_timegrid_multi(t, dOmega, rates)

    # Emit diagnostics
    df = pd.DataFrame({
        "t_s": t,
        "x_m": x[:,0],
        "y_m": x[:,1],
        "scale": scale_path,
        "gamma_base": gamma_base,
        "gamma_dephasing": rates.get("dephasing", np.zeros_like(t)),
        "gamma_relax": rates.get("relax", np.zeros_like(t)),
        "gamma_excite": rates.get("excite", np.zeros_like(t)),
    })
    df.to_csv(out/"scale_path_and_rates.csv", index=False)

    (out/"summary.json").write_text(json.dumps({
        "visibility": res.visibility,
        "phi_final_rad": res.phi_final_rad,
        "gamma_int": res.gamma_int,
        "backend": res.backend,
        "channels": res.extra.get("channels"),
        "scene_ctx": ctx,
        "scale_stats": {"min": float(df["scale"].min()), "max": float(df["scale"].max()), "mean": float(df["scale"].mean())},
    }, indent=2, sort_keys=True), encoding="utf-8")

    print("Wrote:", out)
    print("Scale min/max/mean:", float(df["scale"].min()), float(df["scale"].max()), float(df["scale"].mean()))
    print("Visibility:", res.visibility, "gamma_int:", res.gamma_int, "backend:", res.backend)

if __name__ == "__main__":
    main()
