@echo off
echo ========================================================
echo   PlaceTrack Web - Netlify Fast Deployment Console
echo ========================================================
echo.

if not exist "build\web\index.html" (
    echo [ERROR] Web build not found. Running build first...
    call flutter build web --release
)

echo [1/2] Connecting to Netlify...
echo If this is your first time, Netlify will prompt to login in your browser.
echo Select "Create & configure a new project" or link existing.
echo.

call npx netlify deploy --prod --dir=build\web

echo.
echo ========================================================
echo   Deployment completed!
echo ========================================================
pause
