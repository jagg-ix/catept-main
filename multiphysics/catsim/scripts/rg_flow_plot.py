"""Registry-driven RG-flow plotter.

Reads existing preset registries and plots the registry's lambda/gamma values vs a scale axis.

This is a visualization of *configured* model families (presets) — no new physics.
"""
from __future__ import annotations
import argparse, os, json, glob
import numpy as np
import matplotlib.pyplot as plt

def find_registry_files(repo_root: str):
    candidates = []
    for pat in [
        os.path.join(repo_root, "src", "**", "*lambda*preset*.json"),
        os.path.join(repo_root, "src", "**", "*preset*.json"),
        os.path.join(repo_root, "src", "**", "*presets*.json"),
    ]:
        candidates += glob.glob(pat, recursive=True)
    # unique, stable order
    out=[]
    seen=set()
    for c in candidates:
        if c not in seen:
            seen.add(c); out.append(c)
    return out

def load_presets(path: str):
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)
    if isinstance(data, dict) and "presets" in data:
        return data["presets"]
    return data

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", required=True)
    ap.add_argument("--registry", default="auto")
    args = ap.parse_args()
    os.makedirs(args.out, exist_ok=True)

    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    if args.registry == "auto":
        files = find_registry_files(repo_root)
        if not files:
            raise SystemExit("No preset registry JSON files found.")
        reg_path = files[0]
    else:
        reg_path = args.registry

    presets = load_presets(reg_path)
    rows=[]
    for i,p in enumerate(presets):
        if not isinstance(p, dict):
            continue
        name=str(p.get("name", f"preset_{i}"))
        scale=float(p.get("scale", i))
        lam = p.get("lambda") if "lambda" in p else p.get("gamma") if "gamma" in p else p.get("lambda_s_inv") if "lambda_s_inv" in p else p.get("gamma_s_inv") if "gamma_s_inv" in p else None
        rows.append((scale, name, None if lam is None else float(lam)))
    csv_path=os.path.join(args.out,"rg_points.csv")
    with open(csv_path,"w",encoding="utf-8") as f:
        f.write("scale,name,lambda_or_gamma\n")
        for s,n,lam in rows:
            f.write(f"{s},{n},{'' if lam is None else lam}\n")
    scales=np.array([r[0] for r in rows],dtype=float)
    lams=np.array([np.nan if r[2] is None else r[2] for r in rows],dtype=float)
    plt.figure()
    plt.plot(scales,lams,marker="o")
    plt.xlabel("scale (registry)")
    plt.ylabel("lambda/gamma (registry)")
    plt.title(os.path.basename(reg_path))
    plt.grid(True)
    plt.tight_layout()
    png_path=os.path.join(args.out,"rg_points.png")
    plt.savefig(png_path,dpi=150)
    with open(os.path.join(args.out,"rg_meta.json"),"w",encoding="utf-8") as f:
        json.dump({"registry_path":reg_path,"n_points":len(rows)},f,indent=2)
    print("Wrote:", csv_path, png_path)

if __name__=="__main__":
    main()
