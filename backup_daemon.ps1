$BackupScript = "C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\AI_auto\backup_to_gdrive.ps1"

while ($true) {
    $Now = Get-Date
    
    # Check if it's exactly 12:00
    if ($Now.Hour -eq 12 -and $Now.Minute -eq 0) {
        # Run the backup script silently
        powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File $BackupScript
        
        # Sleep for 61 seconds so it doesn't trigger multiple times within the 12:00 minute
        Start-Sleep -Seconds 61
    }
    else {
        # Sleep until the start of the next minute to minimize CPU usage
        Start-Sleep -Seconds (60 - $Now.Second)
    }
}
