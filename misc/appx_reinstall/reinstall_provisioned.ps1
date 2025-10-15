$successCount = 0

Get-AppxPackage -AllUsers | ForEach-Object {
    if ($_.InstallLocation) {
        $manifestPath = "$($_.InstallLocation)\AppXManifest.xml"
        
        # Attempt the registration. Suppress normal output but allow errors to pass to stderr.
        Add-AppxPackage -DisableDevelopmentMode -Register $manifestPath -ErrorAction SilentlyContinue | Out-Null

        # The automatic variable $? is $true if the last command succeeded.
        if ($?) {
            Write-Host "OK: $($_.Name)"
            $successCount++
        }
    }
}

Write-Host "`nTotal successful reinstalls: $successCount"
