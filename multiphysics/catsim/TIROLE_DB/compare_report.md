# Tirole temporal double-slit: ingest + compare (tool-generated)

## Ingested constants (from PDF text)

- **probe_carrier_THz**: 230.2 THz
- **probe_fwhm_fs**: 794.0 fs
- **rise_time_10_90_fs**: 7.0 fs
- **rise_time_range_fs**: 1-10 fs
- **second_peak_percent**: 0.93 %

## Simulation comparisons

Each run reports fringe spacing (THz), paper-like visibility, and a simple extent proxy (THz).

| mode | S (fs) | alpha (1/fs) | CAT | spacing (THz) | vis | extent (THz) | notes |
|---|---:|---:|---:|---:|---:|---:|---|
| cat | 500 | 0.500 | 1 | 2.000 | 0.000 | 10.0 | CAT/EPT toggle: amplitude-weight exp(-gamma*tau_ent) |
| cat | 800 | 0.500 | 1 | 1.833 | 0.003 | 10.0 | CAT/EPT toggle: amplitude-weight exp(-gamma*tau_ent) |
| standard | 500 | 0.500 | 0 | 2.000 | 0.000 | 10.0 |  |
| standard | 800 | 0.500 | 0 | 1.833 | 0.003 | 10.0 |  |