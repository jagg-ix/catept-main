"""Temporal physics predictor: multilayer transfer matrix + time-trace presets.

Capabilities (normal incidence):
- General N-layer stack using characteristic (transfer) matrix method:
  incident | layer1 | layer2 | ... | substrate
- Each layer can be specified by:
  - constant n (real) OR
  - ε(ω) table CSV (complex), converted via n(ω)=sqrt(ε)
- Substrate can be constant n or ε_sub(ω) table.

Time-domain construction:
- Interpolate r(ω) onto uniform positive-frequency grid
- Apply windowing (hann/none) OR preset (e.g., tirole_default)
- Build Hermitian spectrum, IFFT -> real time trace
- Optionally fftshift so delay axis is centered around 0 fs (recommended for interferograms)

Alignment utilities:
- affine match (scale+offset): y_meas ≈ a*y_pred + b
- optional time-shift by cross-correlation

This module is intentionally conservative: normal incidence, non-magnetic media, scalar ε.
"""

from __future__ import annotations
from dataclasses import dataclass
from pathlib import Path
import numpy as np
import csv, json, math

c0 = 299792458.0
pi = math.pi

@dataclass
class LayerSpec:
    name: str
    thickness_m: float
    n: float|None = None
    eps_table: str|None = None  # path to CSV

@dataclass
class StackSpec:
    incident_n: float = 1.0
    substrate_n: float|None = 1.5
    substrate_eps_table: str|None = None
    layers: list[LayerSpec] = None  # films only (no incident/substrate)

@dataclass
class TimeTraceParams:
    nfft: int = 4096
    window: str = "hann"      # hann|none
    preset: str = "custom"    # custom|tirole_default
    center_time: bool = True  # if True, fftshift and center delay axis
    t0_shift_fs: float = 0.0  # manual delay shift (added after centering)

def _load_eps_table_csv(path: Path):
    """Load ε(ω) table from CSV. Requires frequency_thz (or frequency_hz) + eps_real + eps_imag."""
    with path.open("r", newline="", encoding="utf-8") as f:
        r = csv.DictReader(f)
        cols = r.fieldnames or []
        def pick(*names):
            for n in names:
                if n in cols:
                    return n
            return None
        fk = pick("frequency_thz","freq_thz","f_thz","frequency_hz","freq_hz","f_hz")
        er = pick("eps_real","epsilon_real","re_eps","re_epsilon","eps_re")
        ei = pick("eps_imag","epsilon_imag","im_eps","im_epsilon","eps_im")
        if fk is None or er is None or ei is None:
            raise ValueError(f"eps table missing required cols; got {cols}")
        fvals=[]; eps=[]
        for row in r:
            fv=float(row[fk])
            fhz = fv*1e12 if "thz" in fk else fv
            e = complex(float(row[er]), float(row[ei]))
            fvals.append(fhz); eps.append(e)
    f=np.asarray(fvals, float); eps=np.asarray(eps, complex)
    idx=np.argsort(f)
    return f[idx], eps[idx]

def _complex_n_from_eps(eps: np.ndarray):
    return np.sqrt(eps.astype(complex))

def _interp_complex(f_src, z_src, f_tgt):
    re = np.interp(f_tgt, f_src, np.real(z_src))
    im = np.interp(f_tgt, f_src, np.imag(z_src))
    return re + 1j*im

def _layer_n_of_f(layer: LayerSpec, f_use: np.ndarray, repo_root: Path):
    if layer.eps_table:
        p = (repo_root / layer.eps_table) if not Path(layer.eps_table).is_absolute() else Path(layer.eps_table)
        f, eps = _load_eps_table_csv(p)
        eps_u = _interp_complex(f, eps, f_use)
        return _complex_n_from_eps(eps_u)
    if layer.n is not None:
        return np.full_like(f_use, complex(float(layer.n), 0.0))
    raise ValueError(f"Layer {layer.name} needs n or eps_table")

def _substrate_n_of_f(stack: StackSpec, f_use: np.ndarray, repo_root: Path):
    if stack.substrate_eps_table:
        p = (repo_root / stack.substrate_eps_table) if not Path(stack.substrate_eps_table).is_absolute() else Path(stack.substrate_eps_table)
        f, eps = _load_eps_table_csv(p)
        eps_u = _interp_complex(f, eps, f_use)
        return _complex_n_from_eps(eps_u)
    if stack.substrate_n is None:
        raise ValueError("substrate_n or substrate_eps_table required")
    return np.full_like(f_use, complex(float(stack.substrate_n), 0.0))

def r_stack_transfer_matrix(f_hz: np.ndarray, stack: StackSpec, repo_root: Path) -> np.ndarray:
    """Compute r(ω) for general stack using characteristic matrices at normal incidence."""
    f = np.asarray(f_hz, float)
    w = 2*pi*f
    k0 = w/c0

    n0 = complex(float(stack.incident_n), 0.0)
    ns = _substrate_n_of_f(stack, f, repo_root)

    # Initialize overall matrix M = I
    M11 = np.ones_like(f, dtype=complex)
    M12 = np.zeros_like(f, dtype=complex)
    M21 = np.zeros_like(f, dtype=complex)
    M22 = np.ones_like(f, dtype=complex)

    layers = stack.layers or []
    for layer in layers:
        n1 = _layer_n_of_f(layer, f, repo_root)
        d = float(layer.thickness_m)
        delta = k0 * n1 * d
        cdel = np.cos(delta)
        sdel = np.sin(delta)
        # normal incidence, non-magnetic: optical admittance η = n
        eta = n1

        A11 = cdel
        A12 = 1j * sdel / eta
        A21 = 1j * eta * sdel
        A22 = cdel

        # M = M @ A (elementwise for each frequency)
        N11 = M11*A11 + M12*A21
        N12 = M11*A12 + M12*A22
        N21 = M21*A11 + M22*A21
        N22 = M21*A12 + M22*A22
        M11, M12, M21, M22 = N11, N12, N21, N22

    eta0 = n0
    etas = ns
    num = (eta0*M11 + eta0*etas*M12 - M21 - etas*M22)
    den = (eta0*M11 + eta0*etas*M12 + M21 + etas*M22)
    r = num/den
    return r

def _window(n: int, kind: str):
    if kind == "none":
        return np.ones(n)
    if kind == "hann":
        return np.hanning(n)
    raise ValueError(f"unknown window {kind}")

def _apply_preset(tp: TimeTraceParams):
    # Pipeline-ish defaults for interferogram-like traces:
    if tp.preset == "tirole_default":
        tp.window = "hann"
        tp.center_time = True
    return tp

def build_time_trace_from_r(f_hz: np.ndarray, r_w: np.ndarray, tp: TimeTraceParams):
    """Construct real-valued time trace from complex r(ω) on positive frequencies."""
    tp = _apply_preset(tp)
    f = np.asarray(f_hz, float)
    r = np.asarray(r_w, complex)

    # Use positive-frequency uniform grid over measured support
    fmin = float(f.min()); fmax=float(f.max())
    npos = tp.nfft//2 + 1
    f_uniform = np.linspace(fmin, fmax, npos)

    r_u = _interp_complex(f, r, f_uniform)

    # window on positive frequencies
    win = _window(npos, tp.window)
    r_u = r_u * win

    # Hermitian spectrum for real time-domain
    spec = np.zeros(tp.nfft, dtype=complex)
    spec[:npos] = r_u
    spec[npos:] = np.conj(r_u[1:-1][::-1])

    time_c = np.fft.ifft(spec)
    time = time_c.real

    # time axis
    df = (fmax - fmin)/(npos-1)
    dt = 1.0/(tp.nfft*df)
    t = np.arange(tp.nfft)*dt  # seconds

    if tp.center_time:
        time = np.fft.fftshift(time)
        time_c = np.fft.fftshift(time_c)
        t = (np.arange(tp.nfft) - tp.nfft//2)*dt

    # apply manual shift
    if abs(tp.t0_shift_fs) > 0:
        t = t + tp.t0_shift_fs*1e-15

    return f_uniform, r_u, t, time, time_c

def affine_match(y_pred, y_meas):
    yp=np.asarray(y_pred, float); ym=np.asarray(y_meas, float)
    A=np.vstack([yp, np.ones_like(yp)]).T
    coef, *_ = np.linalg.lstsq(A, ym, rcond=None)
    a,b = float(coef[0]), float(coef[1])
    resid = ym - (a*yp + b)
    rmse = float(np.sqrt(np.mean(resid**2))) if len(resid) else float("nan")
    return a,b,rmse,resid

def best_time_shift(pred_t, pred_y, meas_t, meas_y):
    mt=np.asarray(meas_t,float); my=np.asarray(meas_y,float)
    pt=np.asarray(pred_t,float); py=np.asarray(pred_y,float)
    py_i = np.interp(mt, pt, py)
    a = my - my.mean()
    b = py_i - py_i.mean()
    corr = np.correlate(a, b, mode="full")
    lag = np.argmax(corr) - (len(a)-1)
    dt = float(mt[1]-mt[0]) if len(mt)>1 else 0.0
    shift = -lag*dt
    return shift

def load_stack_json(path: Path) -> StackSpec:
    obj = json.loads(path.read_text(encoding="utf-8"))
    layers = []
    for L in obj.get("layers", []):
        layers.append(LayerSpec(
            name=L.get("name","layer"),
            thickness_m=float(L["thickness_m"]),
            n=L.get("n", None),
            eps_table=L.get("eps_table", None),
        ))
    return StackSpec(
        incident_n=float(obj.get("incident_n", 1.0)),
        substrate_n=obj.get("substrate_n", None),
        substrate_eps_table=obj.get("substrate_eps_table", None),
        layers=layers,
    )
