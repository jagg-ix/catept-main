\
#!/usr/bin/env bash
set -euo pipefail

PYTHON="${PYTHON:-python3}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
WHEELROOT="${WHEELROOT:-${ROOT}/third_party/wheelhouse}"

PACKAGES="${PACKAGES:-qutip einsteinpy}"
PYTAGS="${PYTAGS:-cp310 cp311 cp312}"
PLATFORMS="${PLATFORMS:-linux_x86_64 macos_x86_64 macos_arm64 windows_x86_64}"

EXTRA_PIP_ARGS="${EXTRA_PIP_ARGS:---only-binary=:all: --no-deps}"

platform_tag() {
  case "$1" in
    linux_x86_64) echo "manylinux2014_x86_64" ;;
    macos_x86_64) echo "macosx_10_9_x86_64" ;;
    macos_arm64)  echo "macosx_11_0_arm64" ;;
    windows_x86_64) echo "win_amd64" ;;
    *) echo "" ;;
  esac
}

python_version_from_tag() {
  case "$1" in
    cp310) echo "3.10" ;;
    cp311) echo "3.11" ;;
    cp312) echo "3.12" ;;
    *) echo "" ;;
  esac
}

abi_from_tag() {
  case "$1" in
    cp310) echo "cp310" ;;
    cp311) echo "cp311" ;;
    cp312) echo "cp312" ;;
    *) echo "" ;;
  esac
}

echo "== Building offline wheelhouse matrix =="
"${PYTHON}" -V
"${PYTHON}" -m pip --version
echo "PACKAGES:  ${PACKAGES}"
echo "PYTAGS:    ${PYTAGS}"
echo "PLATFORMS: ${PLATFORMS}"
echo

mkdir -p "${WHEELROOT}"

FAIL=0
REPORT="${WHEELROOT}/_matrix_report.txt"
: > "${REPORT}"

for plat in ${PLATFORMS}; do
  PTAG="$(platform_tag "${plat}")"
  if [[ -z "${PTAG}" ]]; then
    echo "Unknown platform key: ${plat}" | tee -a "${REPORT}"
    FAIL=1
    continue
  fi

  for pytag in ${PYTAGS}; do
    PYVER="$(python_version_from_tag "${pytag}")"
    ABI="$(abi_from_tag "${pytag}")"
    if [[ -z "${PYVER}" || -z "${ABI}" ]]; then
      echo "Unknown python tag: ${pytag}" | tee -a "${REPORT}"
      FAIL=1
      continue
    fi

    DEST="${WHEELROOT}/${plat}/${pytag}"
    mkdir -p "${DEST}"

    echo "---- ${plat}/${pytag} (platform=${PTAG} py=${PYVER} abi=${ABI})" | tee -a "${REPORT}"
    set +e
    "${PYTHON}" -m pip download ${EXTRA_PIP_ARGS} \
      --platform "${PTAG}" \
      --python-version "${PYVER}" \
      --implementation "cp" \
      --abi "${ABI}" \
      -d "${DEST}" \
      ${PACKAGES} >> "${REPORT}" 2>&1
    RC=$?
    set -e

    if [[ ${RC} -ne 0 ]]; then
      echo "WARNING: download failed for ${plat}/${pytag} (rc=${RC})." | tee -a "${REPORT}"
      FAIL=1
      continue
    fi

    COUNT=$(ls -1 "${DEST}"/*.whl 2>/dev/null | wc -l | tr -d ' ')
    echo "OK: ${COUNT} wheels in ${DEST}" | tee -a "${REPORT}"
    echo | tee -a "${REPORT}"
  done
done

echo "== Writing MANIFEST.txt + SHA256SUMS.txt =="
"${PYTHON}" - <<'PY'
import hashlib
from pathlib import Path

root=Path("third_party/wheelhouse")
manifest=[]
sha=[]
for p in sorted(root.rglob("*.whl")):
    rel=p.relative_to(root)
    manifest.append(str(rel))
    h=hashlib.sha256(p.read_bytes()).hexdigest()
    sha.append(f"{h}  {rel}")
(root/"MANIFEST.txt").write_text("\n".join(manifest)+"\n", encoding="utf-8")
(root/"SHA256SUMS.txt").write_text("\n".join(sha)+"\n", encoding="utf-8")
print(f"Wrote {len(manifest)} wheel entries.")
PY

echo "Done. Reports:"
echo " - ${REPORT}"
echo " - ${WHEELROOT}/MANIFEST.txt"
echo " - ${WHEELROOT}/SHA256SUMS.txt"

if [[ "${FAIL}" -ne 0 ]]; then
  echo "NOTE: some matrix entries failed. Adjust PACKAGES/PYTAGS/PLATFORMS or pin versions."
  exit 1
fi
