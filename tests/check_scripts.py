"""Syntax and instrumentation coverage checks; run from the workspace root."""
from pathlib import Path
import re
import subprocess

roots = [Path(name) for name in ("sky_base", "sky_jobs_base", "sky_mechanicjob")]
marked = 0
lua_count = 0
js_count = 0
for root in roots:
    manifest = (root / "fxmanifest.lua").read_text()
    first_shared = re.search(r"shared_scripts\s*\{\s*'([^']+)'", manifest).group(1)
    expected = "source/diagnostics.lua"
    assert first_shared == expected, f"Diagnostics must load first: {root}"
    assert (root / expected).read_bytes() == (roots[0] / expected).read_bytes(), f"Keep local Lua diagnostics copies synchronized: {root}"
    for path in root.rglob("*.lua"):
        source = path.read_text()
        if path.name != "fxmanifest.lua" and path != root / "source/diagnostics.lua":
            marker = f'if SkyDiagnostics then SkyDiagnostics.FileStarted("{path}") end'
            assert source.count(marker) == 1, f"Missing or duplicate startup marker: {path}"
            assert "SkyDiagnostics.Export(" not in source, f"Export registration must tolerate missing diagnostics: {path}"
            marked += 1
        # This existing CfxLua optional-chain expression is not supported by stock luac.
        # Normalize only this known expression in-memory; never rewrite the source file.
        if path == Path("sky_base/config/phone/lb-unique.lua"):
            original = "phone?.metadata?.lbPhoneNumber == phoneNumber"
            assert source.count(original) == 1
            source = source.replace(original, "phone and phone.metadata and phone.metadata.lbPhoneNumber == phoneNumber")
        result = subprocess.run(["luac", "-p", "-"], input=source, text=True, capture_output=True)
        assert result.returncode == 0, f"{path}: {result.stderr}"
        lua_count += 1
    html = (root / "source/html/index.html").read_text()
    assert html.count("assets/sky-diagnostics.js") == 1
    assert html.index("assets/sky-diagnostics.js") < html.index('type="module"')
    assert f'data-sky-resource="{root.name}"' in html
    for path in (root / "source/html/assets").glob("*.js"):
        result = subprocess.run(["node", "--input-type=module", "--check"], input=path.read_text(), text=True, capture_output=True)
        assert result.returncode == 0, f"{path}: {result.stderr}"
        js_count += 1
assert "'source/diagnostics.lua'" in (roots[0] / "fxmanifest.lua").read_text()
assert marked == 226, f"Update the documented coverage count if scripts are added or removed: {marked}"
print(f"PASS: {marked} startup markers, {lua_count} Lua scripts/manifests, {js_count} JS files, and diagnostic load order.")
print("One pre-existing CfxLua optional-chain expression was normalized in-memory for the stock Lua syntax check.")
