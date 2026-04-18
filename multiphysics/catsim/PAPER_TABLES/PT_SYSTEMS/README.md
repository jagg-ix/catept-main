# PT_SYSTEMS (Phase 4D)

This folder contains a **reduced 2×2 PT-symmetric bookkeeping export** driven by extracted visibility.

- Input visibility is taken from `PAPER_TABLES/OBSERVABLES/obs_spectral.csv` (Fig_2f).
- The classical visibility prefactor `Vcl` is taken from `PAPER_TABLES/CAT_PAPER_FAITHFUL/fit_params.json` if present:
  \(V_{cl}=2\eta/(1+\eta^2)\).
- We define \(q(S)=\max(0,-\ln(V/V_{cl}))\), and then export
  - \(\eta_{op}=e^{-Q}\) with \(Q=q\sigma_y\)
  - \(C=e^{Q}P\)

This is **not** a claim that the full optical system is exactly PT-symmetric. It is a compact operator export
that lets you track the standard PT objects (metric and C-operator) as a function of the extracted decoherence
quantity \(q(S)\).
