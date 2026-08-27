# add_qgis.ps1
# Adds PyQGIS support to an existing project folder.
#
# QGIS is a tool, not a project type. There is no standing QGIS folder and no
# central QGIS workspace: a project that needs a map gets the interpreter
# plumbing dropped in, and projects that never touch QGIS carry nothing.
#
# Writes three files into the target project:
#   .vscode/settings.json   interpreter, envFile, Pylance extraPaths, terminal env
#   .env                    PYTHONPATH (the only variable that may be set)
#   qgis_smoketest.py       proves the stack imports and processing initializes
#
# Everything written is workspace-scoped. No global VS Code setting, no user
# PYTHONPATH, and no change to miniconda. Open any other folder and it behaves
# exactly as before.
#
# The QGIS install path is discovered at run time, not hardcoded, so this
# survives a QGIS upgrade. Re-run it after upgrading QGIS to refresh the paths.
#
# Usage:
#   add_qgis.ps1                        # adds PyQGIS to the current directory
#   add_qgis.ps1 -Project Pub_Foo       # resolves via Resolve-ProjectRoot
#   add_qgis.ps1 -Force                 # overwrite without backing up
#
# See known_issues.md #50 for the three traps this configuration works around.

param(
    [string]$Project = "",
    [switch]$Force
)

. "$PSScriptRoot\config.ps1"

# -- Resolve the target project ----------------------------------------
$projectRoot = if (!$Project) {
    (Get-Location).Path
} elseif ([System.IO.Path]::IsPathRooted($Project)) {
    $Project
} else {
    Resolve-ProjectRoot $Project
}

if (!(Test-Path -LiteralPath $projectRoot -PathType Container)) {
    Write-Host "ERR  | No such folder: $projectRoot" -ForegroundColor Red
    exit 1
}

$projectName = Split-Path $projectRoot -Leaf
Write-Host "Adding PyQGIS to: $projectName"
Write-Host "  $projectRoot"

# -- Discover the QGIS install -----------------------------------------
# Look for "QGIS <version>" and OSGeo4W under the usual roots. Both LTR and
# regular installs are handled: LTR puts its Python under apps\qgis-ltr,
# the regular build under apps\qgis.
$searchBases = @()
if ($env:ProgramFiles)        { $searchBases += $env:ProgramFiles }
if (${env:ProgramFiles(x86)}) { $searchBases += ${env:ProgramFiles(x86)} }
$searchBases += "C:\"

$installs = @()
foreach ($base in $searchBases) {
    if (!(Test-Path -LiteralPath $base -PathType Container)) { continue }
    foreach ($pattern in @("QGIS *", "OSGeo4W*")) {
        Get-ChildItem -LiteralPath $base -Directory -Filter $pattern -ErrorAction SilentlyContinue |
            ForEach-Object { $installs += $_.FullName }
    }
}

$found = @()
foreach ($root in ($installs | Select-Object -Unique)) {

    # QGIS ships its own Python. Use apps\Python3xx\python.exe, never
    # bin\python.exe -- see known_issues.md #50, trap 1.
    $pyExe = Get-ChildItem -LiteralPath (Join-Path $root "apps") -Directory -Filter "Python3*" -ErrorAction SilentlyContinue |
             ForEach-Object { Join-Path $_.FullName "python.exe" } |
             Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } |
             Select-Object -First 1
    if (!$pyExe) { continue }

    $qgisApp = @("qgis-ltr", "qgis") |
               ForEach-Object { Join-Path $root "apps\$_" } |
               Where-Object { Test-Path -LiteralPath (Join-Path $_ "python") -PathType Container } |
               Select-Object -First 1
    if (!$qgisApp) { continue }

    $ver = if ((Split-Path $root -Leaf) -match '(\d+)\.(\d+)\.(\d+)') {
        [version]$Matches[0]
    } elseif ((Split-Path $root -Leaf) -match '(\d+)\.(\d+)') {
        [version]"$($Matches[0]).0"
    } else {
        [version]"0.0.0"
    }

    $found += [PSCustomObject]@{
        Root    = $root
        PyExe   = $pyExe
        QgisApp = $qgisApp
        PyDir   = Join-Path $qgisApp "python"
        Plugins = Join-Path $qgisApp "python\plugins"
        Site    = Join-Path (Split-Path $pyExe -Parent) "Lib\site-packages"
        Version = $ver
    }
}

if ($found.Count -eq 0) {
    Write-Host "ERR  | No QGIS install found." -ForegroundColor Red
    Write-Host "     | Looked for 'QGIS *' and 'OSGeo4W*' under:"
    $searchBases | ForEach-Object { Write-Host "     |   $_" }
    Write-Host "     | Install QGIS LTR, then re-run: helpi 28"
    exit 1
}

$q = $found | Sort-Object Version -Descending | Select-Object -First 1
Write-Host "OK   | QGIS found: $($q.Root)"
Write-Host "     | interpreter: $($q.PyExe)"
if ($found.Count -gt 1) {
    Write-Host "WARN | $($found.Count) installs present; using the highest version."
}

# -- Helper: back up a file before replacing it ------------------------
function Backup-IfExists([string]$path) {
    if (!(Test-Path -LiteralPath $path -PathType Leaf)) { return }
    if ($Force) {
        Write-Host "WARN | Overwriting (-Force): $(Split-Path $path -Leaf)"
        return
    }
    $bak = "$path.bak-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Copy-Item -LiteralPath $path -Destination $bak -Force
    Write-Host "WARN | Existing file backed up: $(Split-Path $bak -Leaf)"
}

# -- .vscode/settings.json ---------------------------------------------
# Forward slashes throughout: a single backslash before P, Q or a is not a
# legal JSON escape, and VS Code accepts forward slashes on Windows.
$vscodeDir = Join-Path $projectRoot ".vscode"
New-Item -ItemType Directory -Path $vscodeDir -Force | Out-Null
$settingsPath = Join-Path $vscodeDir "settings.json"
Backup-IfExists $settingsPath

$settingsTemplate = @'
{
  // PyQGIS -- WORKSPACE-SCOPED ONLY. Generated by helpi 28.
  // These settings apply only when this folder is open in VS Code. Global
  // settings (%APPDATA%\Code\User\settings.json) are untouched, so every
  // other project keeps using miniconda as before.
  //
  // Regenerate after a QGIS upgrade: helpi 28

  // QGIS's own Python. Must be apps/Python3xx/python.exe, not bin/python.exe
  // -- the latter has no valid sys.prefix of its own and dies with
  // "ModuleNotFoundError: No module named 'encodings'".
  "python.defaultInterpreterPath": "__PY_EXE__",

  // Run/debug environment comes from .env in this folder.
  "python.envFile": "${workspaceFolder}/.env",

  // Pylance IntelliSense for qgis.*, processing.*, osgeo.*, PyQt5.*
  "python.analysis.extraPaths": [
    "__PY_DIR__",
    "__PLUGINS__",
    "__SITE__"
  ],

  // Do not let the Python extension run conda/venv activation over the
  // QGIS interpreter.
  "python.terminal.activateEnvironment": false,

  // Integrated terminals opened in this folder get PYTHONPATH too, so a
  // manual "python script.py" works. Scoped to this workspace.
  "terminal.integrated.env.windows": {
    "PYTHONPATH": "__PYTHONPATH_FWD__"
  }
}
'@

$fwd = { param($p) $p -replace '\\', '/' }
$settings = $settingsTemplate.
    Replace('__PY_EXE__',         (& $fwd $q.PyExe)).
    Replace('__PY_DIR__',         (& $fwd $q.PyDir)).
    Replace('__PLUGINS__',        (& $fwd $q.Plugins)).
    Replace('__SITE__',           (& $fwd $q.Site)).
    Replace('__PYTHONPATH_FWD__', ((& $fwd $q.PyDir) + ";" + (& $fwd $q.Plugins)))

Set-Content -Path $settingsPath -Value $settings -Encoding UTF8
Write-Host "OK   | .vscode/settings.json written"

# -- .env ---------------------------------------------------------------
$envPath = Join-Path $projectRoot ".env"
Backup-IfExists $envPath

$envTemplate = @'
# PyQGIS environment -- loaded ONLY by VS Code in this workspace folder.
# Generated by helpi 28. Nothing here is global; miniconda is untouched
# everywhere else. Regenerate after a QGIS upgrade: helpi 28
#
# Exactly one variable is needed. qgis/__init__.py::setupenv() reads
# __BIN_ENV__ on import and sets the other ~28 variables itself
# (PATH, GDAL_DATA, PROJ_DATA, QT_PLUGIN_PATH, ...).
#
# DO NOT set QGIS_PREFIX_PATH here. setupenv() returns early if it is
# already set, skips its own env file, and "import qgis.core" then fails
# with "DLL load failed while importing _core". See known_issues.md #50.
PYTHONPATH=__PY_DIR__;__PLUGINS__
'@

$binEnv = Get-ChildItem -LiteralPath (Join-Path $q.Root "bin") -Filter "*-bin.env" -ErrorAction SilentlyContinue |
          Select-Object -First 1 -ExpandProperty FullName
if (!$binEnv) { $binEnv = Join-Path $q.Root "bin\qgis-bin.env" }

$envText = $envTemplate.
    Replace('__BIN_ENV__',  $binEnv).
    Replace('__PY_DIR__',   $q.PyDir).
    Replace('__PLUGINS__',  $q.Plugins)

Set-Content -Path $envPath -Value $envText -Encoding UTF8
Write-Host "OK   | .env written"

# -- qgis_smoketest.py --------------------------------------------------
$smokePath = Join-Path $projectRoot "qgis_smoketest.py"
if ((Test-Path -LiteralPath $smokePath -PathType Leaf) -and !$Force) {
    Write-Host "SKIP | qgis_smoketest.py already exists (use -Force to replace)"
} else {
    $smokeTemplate = @'
"""Smoke test for the PyQGIS setup. Run with F5 in VS Code.

Generated by helpi 28. Expected output is version numbers, a non-zero
processing algorithm count, and "memory layer valid: True".
"""

import sys

from qgis.core import QgsApplication, QgsVectorLayer, Qgis
from osgeo import gdal, ogr
from PyQt5.QtCore import QT_VERSION_STR

QGIS_PREFIX = r"__QGIS_APP__"


def main() -> int:
    print(f"Python      {sys.version.split()[0]}")
    print(f"QGIS        {Qgis.QGIS_VERSION}")
    print(f"GDAL        {gdal.__version__}")
    print(f"Qt          {QT_VERSION_STR}")

    # Silences "Application path not initialized" and enables the provider registry.
    QgsApplication.setPrefixPath(QGIS_PREFIX, True)
    app = QgsApplication([], False)
    app.initQgis()

    # The processing framework needs its own init; without it the registry is empty.
    import processing  # noqa: F401  (must import before Processing.initialize)
    from processing.core.Processing import Processing

    Processing.initialize()
    reg = QgsApplication.processingRegistry()
    print(f"processing  {len(reg.providers())} providers, {len(reg.algorithms())} algorithms")

    # Build a tiny in-memory layer to prove the provider registry works.
    layer = QgsVectorLayer("Point?crs=EPSG:25832&field=id:integer", "scratch", "memory")
    print(f"memory layer valid: {layer.isValid()}")
    print(f"OGR drivers: {ogr.GetDriverCount()}")

    app.exitQgis()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
'@
    $smoke = $smokeTemplate.Replace('__QGIS_APP__', $q.QgisApp)
    Set-Content -Path $smokePath -Value $smoke -Encoding UTF8
    Write-Host "OK   | qgis_smoketest.py written"
}

# -- Next steps ---------------------------------------------------------
Write-Host ""
Write-Host "Next:" -ForegroundColor Cyan
Write-Host "  1. Open THIS folder in VS Code (File > Open Folder)."
Write-Host "  2. Run qgis_smoketest.py (F5)."
Write-Host "  3. If a different interpreter is offered, pick:"
Write-Host "     $($q.PyExe)"
Write-Host ""
Write-Host "Notes:" -ForegroundColor Cyan
Write-Host "  - Extra packages go into the QGIS interpreter, not miniconda:"
Write-Host "      & '$($q.PyExe)' -m pip install <pkg>"
Write-Host "  - Headless, outside VS Code:"
Write-Host "      & '$(Join-Path $q.Root "bin")\python-qgis*.bat' script.py"
Write-Host "  - In QGIS Desktop set Project Properties > General > Save paths"
Write-Host "    to 'relative', or the project breaks when the folder moves."
Write-Host "  - OneDrive holds locks on open .gpkg files and can produce"
Write-Host "    conflict copies. Close the project before it syncs."
Write-Host "  - Three PyQGIS traps are documented in known_issues.md #50."
