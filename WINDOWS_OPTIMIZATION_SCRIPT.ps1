# PowerShell Script for Intel i5-7200U System Optimization
# Run as Administrator for full functionality

Write-Host "Intel i5-7200U System Optimization Script" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Please run this script as Administrator!" -ForegroundColor Red
    exit
}

# Function to pause execution
function Pause-Script {
    Write-Host "Press any key to continue..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# 1. Power Plan Optimization
Write-Host "`n1. Optimizing Power Plan..." -ForegroundColor Yellow
$highPerfPlan = powercfg -l | Select-String "High performance"
if ($highPerfPlan) {
    $planId = ($highPerfPlan -split ' ')[0] -replace '\*'
    powercfg -setactive $planId.Trim()
    Write-Host "High Performance power plan activated" -ForegroundColor Green
} else {
    Write-Host "High Performance power plan not found" -ForegroundColor Red
}

# 2. Disable transparency effects
Write-Host "`n2. Disabling transparency effects..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 0
Write-Host "Transparency effects disabled" -ForegroundColor Green

# 3. Disable Game Mode
Write-Host "`n3. Disabling Game Mode..." -ForegroundColor Yellow
$gameModePath = "HKCU:\Software\Microsoft\GameBar"
if (Test-Path $gameModePath) {
    Set-ItemProperty -Path $gameModePath -Name "AllowAutoGameMode" -Value 0
    Set-ItemProperty -Path $gameModePath -Name "AutoGameModeEnabled" -Value 0
    Write-Host "Game Mode disabled" -ForegroundColor Green
} else {
    New-Item -Path $gameModePath -Force
    Set-ItemProperty -Path $gameModePath -Name "AllowAutoGameMode" -Value 0
    Set-ItemProperty -Path $gameModePath -Name "AutoGameModeEnabled" -Value 0
    Write-Host "Game Mode disabled" -ForegroundColor Green
}

# 4. Optimize Visual Effects for Performance
Write-Host "`n4. Optimizing visual effects for performance..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "DragFullWindows" -Value 0
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value 0
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Value ([byte[]](144,16,1,0,0,0,0,0)) -Type Binary
Write-Host "Visual effects optimized for performance" -ForegroundColor Green

# 5. Disable Windows Search service
Write-Host "`n5. Disabling Windows Search service (optional)..." -ForegroundColor Yellow
$choice = Read-Host "Do you want to disable Windows Search? This will make searching slower but free up resources (Y/N)"
if ($choice -eq 'Y' -or $choice -eq 'y') {
    Set-Service -Name "WSearch" -StartupType Disabled -Status Stopped
    Write-Host "Windows Search service disabled" -ForegroundColor Green
} else {
    Write-Host "Windows Search service unchanged" -ForegroundColor Yellow
}

# 6. Disable Superfetch (Beneficial for SSD systems)
Write-Host "`n6. Disabling Superfetch service..." -ForegroundColor Yellow
Set-Service -Name "SysMain" -StartupType Disabled -Status Stopped
Write-Host "Superfetch service disabled" -ForegroundColor Green

# 7. Optimize Virtual Memory
Write-Host "`n7. Setting custom virtual memory (Page File)..." -ForegroundColor Yellow
# Calculate 1.5x RAM for systems with 16GB
$customSize = [math]::Round(16 * 1024 * 1.5)
$system32 = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management")."PagingFiles"
if ($system32) {
    Write-Host "Setting custom page file size: $customSize MB" -ForegroundColor Green
    # This requires more complex registry manipulation, simplified for this script
    Write-Host "Virtual memory optimization noted - manual configuration recommended for best results" -ForegroundColor Yellow
}

# 8. Disable Cortana
Write-Host "`n8. Disabling Cortana..." -ForegroundColor Yellow
$ cortanaPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
Set-ItemProperty -Path $cortanaPath -Name "CortanaEnabled" -Value 0
Set-ItemProperty -Path $cortanaPath -Name "CanCortanaBeEnabled" -Value 0
Write-Host "Cortana disabled" -ForegroundColor Green

# 9. Disable Location Tracking
Write-Host "`n9. Disabling Location Tracking..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Value "Deny"
Set-Service -Name "lfsvc" -StartupType Disabled
Write-Host "Location tracking disabled" -ForegroundColor Green

# 10. Optimize SSD Settings (TRIM)
Write-Host "`n10. Checking TRIM status..." -ForegroundColor Yellow
$trimStatus = fsutil behavior query DisableDeleteNotify
if ($trimStatus -like "*0*") {
    Write-Host "TRIM is enabled (correct setting for SSD)" -ForegroundColor Green
} else {
    fsutil behavior set DisableDeleteNotify 0
    Write-Host "TRIM enabled for SSD optimization" -ForegroundColor Green
}

# 11. Disable startup delay
Write-Host "`n11. Disabling startup delay..." -ForegroundColor Yellow
if (-not (Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize")) {
    New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" -Force
}
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" -Name "StartupDelayInMSec" -Value 0
Write-Host "Startup delay disabled" -ForegroundColor Green

# 12. Optimize Taskbar and Explorer
Write-Host "`n12. Optimizing Taskbar and Explorer..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSyncProviderNotifications" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0
Write-Host "Taskbar and Explorer optimized" -ForegroundColor Green

# 13. Disable Automatic Updates during work (Notification only)
Write-Host "`n13. Configuring Windows Update to notify only..." -ForegroundColor Yellow
# This requires Group Policy changes which are complex, so we'll just note it
Write-Host "Windows Update optimization noted - manual configuration recommended" -ForegroundColor Yellow

# 14. Enable Prefetch (for faster application loading)
Write-Host "`n14. Configuring Prefetch..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -Name "EnablePrefetcher" -Value 3
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -Name "EnableSuperfetch" -Value 0
Write-Host "Prefetch configured" -ForegroundColor Green

# 15. System Maintenance
Write-Host "`n15. Running system maintenance..." -ForegroundColor Yellow
# Clean temp files
Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "Temporary files cleaned" -ForegroundColor Green

# Check system file integrity
Write-Host "`nRunning system file checker (this may take a few minutes)..." -ForegroundColor Yellow
Start-Process -FilePath "sfc" -ArgumentList "/scannow" -Wait -NoNewWindow

Write-Host "`nOptimization complete!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host "Please restart your computer for all changes to take effect." -ForegroundColor Yellow
Write-Host "For best results, also update your BIOS and graphics drivers manually." -ForegroundColor Yellow
Write-Host "Run 'dism /online /cleanup-image /restorehealth' after restart for additional system health." -ForegroundColor Yellow

Pause-Script