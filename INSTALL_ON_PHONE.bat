@echo off
echo ========================================================
echo  PlaceTrack - Installing Release APK on Mobile Device
echo ========================================================
echo.
set ADB="C:\Users\USER\AppData\Local\Android\Sdk\platform-tools\adb.exe"

echo [1/3] Checking connected Android devices...
%ADB% devices -l
echo.

echo [2/3] Installing PlaceTrack_Release.apk to device...
%ADB% install -r -d "%~dp0PlaceTrack_Release.apk"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================================
    echo  [SUCCESS] PlaceTrack installed successfully!
    echo  Launching PlaceTrack on your phone...
    echo ========================================================
    %ADB% shell am start -n com.placetrack.app/com.placetrack.app.MainActivity
) else (
    echo.
    echo ========================================================
    echo  [NOTE] If your phone is locked, please:
    echo  1. Unlock your phone screen.
    echo  2. If prompted "Allow USB Debugging?", tap "Allow".
    echo  3. Run this script again!
    echo ========================================================
)
echo.
pause
