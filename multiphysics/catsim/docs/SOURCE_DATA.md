# Source data provenance + checksum verification

This repository ingests Excel source-data files (Figshare) and regenerates SQLite databases
via the provided pipeline. To ensure reproducibility, we pin expected **MD5** checksums.

## Upstream URL
https://figshare.com/articles/dataset/Double-slit_time_diffraction_at_optical_frequencies_-_Source_Data/21968435?file=38972183

## Expected MD5 checksums
```text
7c551f2d34fc79e756de28cf983bec8f  Extended_Data_Fig_1_Source data.xlsx
0e6855333b65e1ae49bb9d1d48496a5b  Extended_Data_Fig_2_Source_Data.xlsx
0fbdd11b1dc81555782bc1bfd54d3423  Extended_Data_Fig_3_Source_data.xlsx
594ed5f0d43d718fc314bb28dd0928c5  Fig_1_Source_data.xlsx
a089b19319995849d61b33d6dfa84d07  Fig_2_Source_data.xlsx
```

## Verify locally
From the repo root:
```bash
python data_pipeline/verify_source_data_checksums.py
```

Or via Make:
```bash
make verify_source_data
```

If checksums mismatch, re-download the Excel files from the upstream URL and replace the
copies under `data_pipeline/source_data/`.
