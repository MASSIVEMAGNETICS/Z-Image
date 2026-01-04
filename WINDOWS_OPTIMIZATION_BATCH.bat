@echo off
echo Intel i5-7200U System Optimization Batch Script
echo ================================================

echo.
echo 1. Optimizing Network Settings...
netsh int tcp set global autotuninglevel=normal
netsh int tcp set global chimney=enabled
netsh int tcp set global rss=enabled
netsh int tcp set global dca=enabled
netsh int tcp set global netdma=enabled
echo Network settings optimized

echo.
echo 2. Optimizing Power Settings via Command Line...
powercfg /change monitor-timeout-ac 0
powercfg /change monitor-timeout-dc 0
powercfg /change disk-timeout-ac 0
powercfg /change disk-timeout-dc 0
powercfg /change standby-timeout-ac 0
powercfg /change standby-timeout-dc 0
powercfg /change hibernate-timeout-ac 0
powercfg /change hibernate-timeout-dc 0
echo Power settings optimized

echo.
echo 3. Cleaning Temporary Files...
del /q /f /s %temp%\* 2>nul
rd /s /q %temp% 2>nul
md %temp% 2>nul
del /q /f /s %systemroot%\temp\* 2>nul
rd /s /q %systemroot%\temp 2>nul
md %systemroot%\temp 2>nul
del /q /f /s %systemroot%\prefetch\* 2>nul
echo Temporary files cleaned

echo.
echo 4. Optimizing DNS Cache...
ipconfig /flushdns
echo DNS cache flushed

echo.
echo 5. Optimizing Windows Services (Disabling non-essential)...
sc config "diagnosticexecution" start= disabled
sc config "DiagTrack" start= disabled
sc config "dmwappushservice" start= disabled
sc config "RetailDemo" start= disabled
sc config "Fax" start= disabled
sc config "MapsBroker" start= disabled
sc config "lfsvc" start= disabled
echo Selected Windows services optimized

echo.
echo 6. Optimizing Windows Features...
dism /online /disable-feature /featurename:"MediaPlayback" /quiet /norestart
dism /online /disable-feature /featurename:"WindowsMediaPlayer" /quiet /norestart
dism /online /disable-feature /featurename:"Internet-Explorer-Optional-amd64" /quiet /norestart
echo Selected Windows features disabled

echo.
echo 7. Running Disk Cleanup...
cleanmgr /sagerun:1 2>nul

echo.
echo 8. Optimizing System Restore (Reducing space allocation)...
echo Note: This requires manual configuration through System Properties
echo You can reduce System Restore space to 1-3% of disk size for SSD optimization

echo.
echo 9. Checking and Optimizing SSD TRIM...
fsutil behavior query DisableDeleteNotify
echo If the result is 1, TRIM is disabled. Run 'fsutil behavior set DisableDeleteNotify 0' as administrator to enable it.

echo.
echo 10. Updating Windows Search Index (after disabling)...
echo Note: This is only if you chose to keep Windows Search enabled

echo.
echo Optimization batch complete!
echo ================================================
echo.
echo Please restart your computer for all changes to take effect.
echo For best performance on your Intel i5-7200U with 16GB RAM:
echo 1. Run this script as Administrator
echo 2. Update your BIOS to the latest version
echo 3. Update Intel graphics drivers to the latest version
echo 4. Consider using Process Lasso or similar tools for CPU optimization
echo 5. Monitor temperatures with HWiNFO64 to ensure stability

pause