@echo off
setlocal EnableDelayedExpansion
color 0B

:: Self-elevate to admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:: Set default config file path
set "CONFIG_FILE=%~dp0config.txt"

:: Load saved IPs or default to the primary cloud save IP
if exist "%CONFIG_FILE%" (
    set /p BLOCKED_IPS=<"%CONFIG_FILE%"
) else (
    set "BLOCKED_IPS=192.81.241.171"
    (echo 192.81.241.171)> "%CONFIG_FILE%"
)

:MENU
cls
color 0B
echo.
echo  =========================================================================			
echo    __   __     ______        ______     ______     __   __   ______    			
echo   /\ "-.\ \   /\  __ \      /\  ___\   /\  __ \   /\ \ / /  /\  ___\   			
echo   \ \ \-.  \  \ \ \/\ \     \ \___  \  \ \  __ \  \ \ \'/   \ \  __\   		
echo    \ \_\\"\_\  \ \_____\     \/\_____\  \ \_\ \_\  \ \__|    \ \_____\ 
echo     \/_/ \/_/   \/_____/      \/_____/   \/_/\/_/   \/_/      \/_____/
echo.
echo    By MXG					    Version - 1.1
echo  ========================================================================= 
echo.
:: Check and display status with inline colors
powershell -NoProfile -Command "if (Get-NetFirewallRule -DisplayName '123456' -ErrorAction SilentlyContinue) { Write-Host '   Status:  [' -NoNewline; Write-Host ' ACTIVE ' -ForegroundColor Green -NoNewline; Write-Host ']  Cloud saves are BLOCKED' } else { Write-Host '   Status:  [' -NoNewline; Write-Host ' INACTIVE ' -ForegroundColor Red -NoNewline; Write-Host ']  Cloud saves are ALLOWED' }"

echo.
echo   Target IPs: !BLOCKED_IPS!
echo.
echo   +------------------------------------+
echo   ^|  1  ^>  Activate   No Save Mode    ^|
echo   ^|  2  ^>  Deactivate No Save Mode    ^|
echo   ^|  S  ^>  Settings (Change Target)   ^|
echo   ^|  Q  ^>  Quit                       ^|
echo   +------------------------------------+
echo.
set "choice="
set /p choice=  Choose: 

if /i "!choice!"=="1" goto ACTIVATE
if /i "!choice!"=="2" goto DEACTIVATE
if /i "!choice!"=="S" goto SETTINGS
if /i "!choice!"=="Q" goto QUIT
goto MENU

:SETTINGS
cls
color 0E
echo.
echo  =====================================================
echo        TARGET IP SETTINGS
echo  =====================================================
echo.
echo   Current Target: !BLOCKED_IPS!
echo.
echo   Select Cloud Save IP preset:
echo.
echo   [1] Standard Save Endpoint (192.81.241.171)
echo   [2] Primary + Mirrors (192.81.241.170, 192.81.241.171, 192.81.241.172)
echo   [3] All ROS Cloud Nodes (192.81.241.100, .11, .170, .171, .172)
echo   [4] Telemetry Block (104.255.106.0/24)
echo   [C] Custom IP List / Range
echo   [B] Back to Menu
echo.
set "set_choice="
set /p set_choice=  Choose Option: 

if "!set_choice!"=="1" goto SET_1
if "!set_choice!"=="2" goto SET_2
if "!set_choice!"=="3" goto SET_3
if "!set_choice!"=="4" goto SET_4
if /i "!set_choice!"=="C" goto SET_C
if /i "!set_choice!"=="B" goto MENU
goto SETTINGS

:SET_1
set "NEW_IPS=192.81.241.171"
goto SAVE_SETTINGS

:SET_2
set "NEW_IPS=192.81.241.170,192.81.241.171,192.81.241.172"
goto SAVE_SETTINGS

:SET_3
set "NEW_IPS=192.81.241.100,192.81.241.11,192.81.241.170,192.81.241.171,192.81.241.172"
goto SAVE_SETTINGS

:SET_4
set "NEW_IPS=104.255.106.0/24"
goto SAVE_SETTINGS

:SET_C
echo.
set "NEW_IPS="
set /p NEW_IPS=  Enter custom IP(s) separated by commas: 
if not defined NEW_IPS goto SETTINGS
goto SAVE_SETTINGS

:SAVE_SETTINGS
set "BLOCKED_IPS=!NEW_IPS!"
(echo !NEW_IPS!)> "%CONFIG_FILE%"
color 0A
echo.
echo   Settings updated and saved!
timeout /t 2 >nul
goto MENU

:ACTIVATE
cls
color 0E
echo.
echo   Activating No Save Mode...
echo   Blocking: !BLOCKED_IPS!
echo.
powershell -NoProfile -Command "Remove-NetFirewallRule -DisplayName '123456' -ErrorAction SilentlyContinue; New-NetFirewallRule -DisplayName '123456' -Direction Outbound -Action Block -RemoteAddress ('!BLOCKED_IPS!'.Split(',')) -ErrorAction SilentlyContinue | Out-Null"
color 0A
echo   Done! Cloud saves are now BLOCKED.
powershell -NoProfile -Command "Add-Type -AssemblyName System.Windows.Forms,System.Drawing; $n = New-Object System.Windows.Forms.NotifyIcon; $n.Icon = [System.Drawing.SystemIcons]::Warning; $n.BalloonTipTitle = 'No Save Mode'; $n.BalloonTipText = 'ACTIVATED - Cloud saves are now BLOCKED.'; $n.Visible = $true; $n.ShowBalloonTip(3000); Start-Sleep 1; $n.Dispose()"
echo.
echo   Press any key to return to menu...
pause >nul
goto MENU

:DEACTIVATE
cls
color 0E
echo.
echo   Deactivating No Save Mode...
echo.
powershell -NoProfile -Command "Remove-NetFirewallRule -DisplayName '123456' -ErrorAction SilentlyContinue"
color 0A
echo   Done! Cloud saves are now ALLOWED.
powershell -NoProfile -Command "Add-Type -AssemblyName System.Windows.Forms,System.Drawing; $n = New-Object System.Windows.Forms.NotifyIcon; $n.Icon = [System.Drawing.SystemIcons]::Information; $n.BalloonTipTitle = 'No Save Mode'; $n.BalloonTipText = 'DEACTIVATED - Cloud saves are now ALLOWED.'; $n.Visible = $true; $n.ShowBalloonTip(3000); Start-Sleep 1; $n.Dispose()"
echo.
echo   Press any key to return to menu...
pause >nul
goto MENU

:QUIT
color 0B
echo.
echo   Goodbye.
timeout /t 1 >nul
exit /b