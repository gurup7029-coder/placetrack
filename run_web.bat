@echo off
echo ===================================================
echo   Starting PlaceTrack Web Application
echo   URL: http://localhost:8080
echo ===================================================
echo.
echo Launching local server on port 8080...
start "" "http://localhost:8080"
python -m http.server 8080 -d build\web
pause
