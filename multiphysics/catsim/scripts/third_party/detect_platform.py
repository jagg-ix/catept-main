from __future__ import annotations
import platform, sys, json

def platform_key() -> str:
    sp=sys.platform
    arch=platform.machine().lower()
    if sp.startswith("linux"):
        return "linux_x86_64" if arch in ("x86_64","amd64") else f"linux_{arch}"
    if sp=="darwin":
        return "macos_arm64" if arch in ("arm64","aarch64") else "macos_x86_64"
    if sp.startswith("win"):
        return "windows_x86_64" if arch in ("x86_64","amd64") else f"windows_{arch}"
    return f"{sp}_{arch}"

def python_tag() -> str:
    v=sys.version_info
    return f"cp{v.major}{v.minor}"

if __name__=="__main__":
    print(json.dumps({"platform": platform_key(), "python_tag": python_tag()}, indent=2))
