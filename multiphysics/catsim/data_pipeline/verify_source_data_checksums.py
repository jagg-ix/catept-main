    """Verify MD5 checksums of Figshare Excel source-data files.

    These files are used as inputs to the repo's Excel→SQLite pipeline.
    Verification prevents silent upstream changes or local corruption.

    Expected source:
      https://figshare.com/articles/dataset/Double-slit_time_diffraction_at_optical_frequencies_-_Source_Data/21968435?file=38972183

    Expected MD5 (lowercase hex):
    {
  "Extended_Data_Fig_1_Source data.xlsx": "7c551f2d34fc79e756de28cf983bec8f",
  "Extended_Data_Fig_2_Source_Data.xlsx": "0e6855333b65e1ae49bb9d1d48496a5b",
  "Extended_Data_Fig_3_Source_data.xlsx": "0fbdd11b1dc81555782bc1bfd54d3423",
  "Fig_1_Source_data.xlsx": "594ed5f0d43d718fc314bb28dd0928c5",
  "Fig_2_Source_data.xlsx": "a089b19319995849d61b33d6dfa84d07"
}

    Usage:
      python data_pipeline/verify_source_data_checksums.py

    Exit codes:
      0 = all present + match
      2 = one or more missing
      3 = one or more checksum mismatches
    """

    from __future__ import annotations
    import hashlib
    from pathlib import Path
    import json
    import sys

    EXPECTED_URL = 'https://figshare.com/articles/dataset/Double-slit_time_diffraction_at_optical_frequencies_-_Source_Data/21968435?file=38972183'
    EXPECTED_MD5 = {
  "Extended_Data_Fig_1_Source data.xlsx": "7c551f2d34fc79e756de28cf983bec8f",
  "Extended_Data_Fig_2_Source_Data.xlsx": "0e6855333b65e1ae49bb9d1d48496a5b",
  "Extended_Data_Fig_3_Source_data.xlsx": "0fbdd11b1dc81555782bc1bfd54d3423",
  "Fig_1_Source_data.xlsx": "594ed5f0d43d718fc314bb28dd0928c5",
  "Fig_2_Source_data.xlsx": "a089b19319995849d61b33d6dfa84d07"
}

    def md5_file(path: Path, chunk: int = 1024*1024) -> str:
        h = hashlib.md5()
        with path.open("rb") as f:
            while True:
                b = f.read(chunk)
                if not b:
                    break
                h.update(b)
        return h.hexdigest()

    def main() -> int:
        base = Path(__file__).resolve().parent / "source_data"
        missing = []
        mismatch = []

        print("Source data directory:", base)
        print("Expected source URL:", EXPECTED_URL)
        print()

        for name, exp in EXPECTED_MD5.items():
            p = base / name
            if not p.exists():
                missing.append(name)
                continue
            got = md5_file(p)
            ok = (got.lower() == exp.lower())
            status = "OK" if ok else "MISMATCH"
            print(f"{status:8}  {got}  {name}")
            if not ok:
                mismatch.append((name, exp, got))

        if missing:
            print("\nMissing files:")
            for n in missing:
                print(" -", n)
            return 2

        if mismatch:
            print("\nChecksum mismatches:")
            for n, exp, got in mismatch:
                print(f" - {n}: expected {exp} got {got}")
            return 3

        print("\nAll expected source-data files are present and match expected MD5.")
        return 0

    if __name__ == "__main__":
        raise SystemExit(main())
