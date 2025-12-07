# Register abplanner:// protocol scheme for Windows
# Run this script as Administrator (or just User if writing to HKCU)

$Protocol = "abplanner"
$AppPath = "$PSScriptRoot\build\windows\x64\runner\Debug\ab_planner.exe"

# Check if build exists (if not, we point to strict path or warn)
if (-not (Test-Path $AppPath)) {
    Write-Warning "Executable not found at $AppPath. Please run 'flutter run -d windows' at least once to build the debug executable."
    # Fallback to forcing it if user knows it will exist
}

$RegistryPath = "HKCU:\Software\Classes\$Protocol"

Write-Host "Registering $Protocol protocol to $AppPath..."

# Create protocol key
New-Item -Path $RegistryPath -Force | Out-Null
New-ItemProperty -Path $RegistryPath -Name "(default)" -Value "URL:AB Planner Protocol" -PropertyType String -Force | Out-Null
New-ItemProperty -Path $RegistryPath -Name "URL Protocol" -Value "" -PropertyType String -Force | Out-Null

# Create command key
$CommandPath = "$RegistryPath\shell\open\command"
New-Item -Path $CommandPath -Force | Out-Null
New-ItemProperty -Path $CommandPath -Name "(default)" -Value "`"$AppPath`" `"%1`"" -PropertyType String -Force | Out-Null

Write-Host "Done! You can now test it by opening $Protocol://test in your browser."
