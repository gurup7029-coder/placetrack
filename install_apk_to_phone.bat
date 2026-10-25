@echo off
echo ===================================================
echo   PlaceTrack Mobile - USB Auto Deploy to Phone
echo ===================================================
echo.
set ADB="C:\Users\USER\AppData\Local\Android\Sdk\platform-tools\adb.exe"

echo [1/3] Checking connected Android devices...
%ADB% devices

echo.
echo [2/3] Checking APK and installing directly on phone...
if not exist "build\app\outputs\flutter-apk\app-debug.apk" (
    echo Building fresh APK...
    call flutter build apk --debug
)

%ADB% -s 10BF8M38QZ004PL install -r build\app\outputs\flutter-apk\app-debug.apk

echo.
echo [3/3] Launching PlaceTrack on phone screen...
%ADB% -s 10BF8M38QZ004PL shell am start -n com.example.placetrack/.MainActivity

echo.
echo ===================================================
echo   PlaceTrack is now running on your phone!
echo ===================================================
pause
