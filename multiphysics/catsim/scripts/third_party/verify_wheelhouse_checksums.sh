\
#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
WH="${ROOT}/third_party/wheelhouse"
SHA="${WH}/SHA256SUMS.txt"

if [[ ! -f "${SHA}" ]]; then
  echo "ERROR: missing ${SHA}"
  exit 2
fi

echo "Verifying wheelhouse checksums..."
cd "${WH}"
python - <<'PY'
import hashlib
from pathlib import Path

root=Path(".")
sha_path=root/"SHA256SUMS.txt"
ok=True
for line in sha_path.read_text(encoding="utf-8").splitlines():
    if not line.strip():
        continue
    h, rel = line.split(None, 1)
    rel=rel.strip()
    p=root/rel
    if not p.exists():
        print("MISSING:", rel)
        ok=False
        continue
    got=hashlib.sha256(p.read_bytes()).hexdigest()
    if got!=h:
        print("BAD:", rel)
        ok=False
print("OK" if ok else "FAIL")
raise SystemExit(0 if ok else 1)
PY
