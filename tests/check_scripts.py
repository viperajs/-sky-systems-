"""Syntax checks for every Lua script and UI bundle; run from the workspace root."""
from pathlib import Path
import subprocess

roots = [Path(name) for name in ("sky_base", "sky_jobs_base", "sky_mechanicjob")]
lua_count = 0
js_count = 0
for root in roots:
    for path in root.rglob("*.lua"):
        source = path.read_text()
        # The removed runtime instrumentation flooded the F8 console; keep it out.
        assert "SkyDiagnostics" not in source, f"Diagnostics instrumentation is back: {path}"
        # This existing CfxLua optional-chain expression is not supported by stock luac.
        # Normalize only this known expression in-memory; never rewrite the source file.
        if path == Path("sky_base/config/phone/lb-unique.lua"):
            original = "phone?.metadata?.lbPhoneNumber == phoneNumber"
            assert source.count(original) == 1
            source = source.replace(original, "phone and phone.metadata and phone.metadata.lbPhoneNumber == phoneNumber")
        result = subprocess.run(["luac", "-p", "-"], input=source, text=True, capture_output=True)
        assert result.returncode == 0, f"{path}: {result.stderr}"
        lua_count += 1
    assert "diagnostics" not in (root / "fxmanifest.lua").read_text(), f"Diagnostics script still in manifest: {root}"
    assert "sky-diagnostics.js" not in (root / "source/html/index.html").read_text()
    for path in (root / "source/html/assets").glob("*.js"):
        result = subprocess.run(["node", "--input-type=module", "--check"], input=path.read_text(), text=True, capture_output=True)
        assert result.returncode == 0, f"{path}: {result.stderr}"
        js_count += 1
print(f"PASS: {lua_count} Lua scripts/manifests and {js_count} JS files compile; no diagnostics instrumentation.")
print("One pre-existing CfxLua optional-chain expression was normalized in-memory for the stock Lua syntax check.")
