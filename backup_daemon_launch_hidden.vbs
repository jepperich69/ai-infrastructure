Set WshShell = CreateObject("WScript.Shell")
WshShell.Run "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File ""C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\AI_auto\backup_daemon.ps1""", 0, False
