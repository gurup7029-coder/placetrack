$adb = "C:\Users\USER\AppData\Local\Android\Sdk\platform-tools\adb.exe"
$apk = "build\app\outputs\flutter-apk\app-debug.apk"

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "   PLACETRACK REALTIME INSTALLATION MONITOR  " -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

# Step 1: Device Check
Write-Host "`n[Step 1/3] Checking connected Android device..." -ForegroundColor Yellow
$deviceRaw = (& $adb devices 2>&1) -join "`n"
Write-Host $deviceRaw

if ($deviceRaw -match "10BF8M38QZ004PL\s+device") {
    Write-Host "`n[OK] Device is ONLINE and Ready: 10BF8M38QZ004PL" -ForegroundColor Green
} elseif ($deviceRaw -match "offline") {
    Write-Host "`n[WAIT] Device is OFFLINE! Please unlock phone or reconnect USB." -ForegroundColor Red
    exit 1
} else {
    Write-Host "`n[ERROR] No authorized device detected. Connect your phone." -ForegroundColor Red
    exit 1
}

# Wake up screen now
& $adb shell input keyevent 224 | Out-Null

# Setup periodic screen keep-awake timer (every 25 seconds)
$timer = [System.Timers.Timer]::new(25000)
$timer.AutoReset = $true
Register-ObjectEvent -InputObject $timer -EventName Elapsed -SourceIdentifier KeepAlive -Action {
    & "C:\Users\USER\AppData\Local\Android\Sdk\platform-tools\adb.exe" shell input keyevent 224 | Out-Null
} | Out-Null
$timer.Start()

try {
    # Step 2: Push APK with live transfer progress
    $apkItem = Get-Item $apk
    $apkSizeMB = [math]::Round($apkItem.Length / 1MB, 2)
    Write-Host "`n[Step 2/3] Uploading PlaceTrack Default APK ($apkSizeMB MB) to mobile..." -ForegroundColor Yellow
    Write-Host "Transferring to /data/local/tmp/placetrack.apk (Keep phone unlocked)..." -ForegroundColor Gray
    
    $pushStart = Get-Date
    & $adb push $apk /data/local/tmp/placetrack.apk
    $pushDuration = [math]::Round(((Get-Date) - $pushStart).TotalSeconds, 1)

    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n[OK] APK upload complete! 100% transferred in ${pushDuration}s." -ForegroundColor Green
    } else {
        Write-Host "`n[ERROR] Failed to upload APK (Exit code: $LASTEXITCODE)." -ForegroundColor Red
        exit 1
    }

    # Step 3: Install Package
    Write-Host "`n[Step 3/3] Installing APK on mobile device (pm install -r)..." -ForegroundColor Yellow
    $installOutput = & $adb shell pm install -r /data/local/tmp/placetrack.apk
    Write-Host "Install Result: $installOutput" -ForegroundColor Cyan

    if ($installOutput -match "Success") {
        Write-Host "`n[SUCCESS] PlaceTrack successfully installed on mobile!" -ForegroundColor Green
        Write-Host "Launching PlaceTrack app on phone screen..." -ForegroundColor Yellow
        & $adb shell am start -n com.example.placetrack/.MainActivity
        Write-Host "[LAUNCHED] PlaceTrack is now open on your mobile screen!" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] Installation failed or requires user permission on phone screen: $installOutput" -ForegroundColor Red
    }
}
finally {
    $timer.Stop()
    $timer.Dispose()
    Unregister-Event -SourceIdentifier KeepAlive -ErrorAction SilentlyContinue
}
