$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($isAdmin) {
    $provisionedAppNames = (Get-AppxProvisionedPackage -Online -ErrorAction Stop).DisplayName
} else {
    $provisionedAppNames = Get-Content 'provisoned_packages.txt' -ErrorAction Stop
}

# Use the PowerShell native, case-insensitive "-in" operator for the check.
# This avoids all .NET constructor issues.
Get-AppxPackage | Where-Object {
    ($_.Name -in $provisionedAppNames) -and (-not $_.IsFramework)
} | ForEach-Object {
    echo $_.PackageFullName
    Remove-AppxPackage -Package $_.PackageFullName
}
