# helpi.ps1  --  Backward-compatibility shim
# The implementation lives in scripts/helpi.ps1.
# This file exists so that profiles with 'function helpi { & "$aiRoot\helpi.ps1" @args }'
# continue to work after the scripts/ restructure.
& "$PSScriptRoot\scripts\helpi.ps1" @args
