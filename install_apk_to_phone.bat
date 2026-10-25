@echo off
echo ===================================================
echo   PlaceTrack Mobile - USB Auto Deploy to Phone
echo ===================================================
echo.
set ADB="C:\Users\USER\AppData\Local\Android\Sdk\platform-tools\adb.exe"

echo [1/3] Checking connected Android devices...
%ADB% devices

echo.
echo [2/3] Building & installing directly on device...
flutter run -d 10BF8M38QZ004PL

pause
