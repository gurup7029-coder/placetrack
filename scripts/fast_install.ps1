$adb = "C:\Users\USER\AppData\Local\Android\Sdk\platform-tools\adb.exe"
$apk = "build\app\outputs\flutter-apk\app-debug.apk"
$targetOnPhone = "/data/local/tmp/placetrack.apk"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   PLACETRACK DEFAULT APK LIVE INSTALLATION MONITOR      " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Check connection
$dev = (& $adb devices) -join "`n"
Write-Host $dev
if ($dev -notmatch "10BF8M38QZ004PL\s+device") {
    Write-Host "[ERROR] Phone not connected or offline." -ForegroundColor Red
    exit 1
}

# 2. Keep screen awake for 30 minutes so USB never sleeps
Write-Host "`n[1/4] Enabling Screen Stay-Awake & waking up screen..." -ForegroundColor Yellow
& $adb shell svc power stayon true
& $adb shell input keyevent 224

# 3. Clean up old tmp
& $adb shell rm -f $targetOnPhone

$apkItem = Get-Item $apk
$totalBytes = $apkItem.Length
$totalMB = [math]::Round($totalBytes / 1MB, 2)
Write-Host "`n[2/4] Uploading Default APK ($totalMB MB) to mobile..." -ForegroundColor Yellow

$logFile = "$PSScriptRoot\push.log"
if (Test-Path $logFile) { Remove-Item $logFile -Force }

# Launch adb push redirecting to log file (no pipe deadlocks!)
$p = Start-Process -FilePath $adb -ArgumentList "push `"$apk`" $targetOnPhone" -RedirectStandardOutput $logFile -RedirectStandardError "$PSScriptRoot\push_err.log" -NoNewWindow -PassThru

$startTime = Get-Date
$expectedTotalSeconds = 195  # ~3.25 minutes at 0.7 MB/s

while (-not $p.HasExited) {
    Start-Sleep -Seconds 15
    $elapsed = [math]::Round(((Get-Date) - $startTime).TotalSeconds, 0)
    
    # Calculate estimated progress based on transfer rate
    $estPercent = [math]::Min(98, [math]::Round(($elapsed / $expectedTotalSeconds) * 100, 1))
    $estMB = [math]::Round(($estPercent / 100) * $totalMB, 1)
    
    $now = Get-Date -Format "HH:mm:ss"
    Write-Host "[$now] Uploading: ~$estPercent% completed (~$estMB MB / $totalMB MB) | Elapsed: ${elapsed}s" -ForegroundColor Cyan
    
    # Touch screen wakeup
    & $adb shell input keyevent 224 | Out-Null
}

$exitCode = $p.ExitCode
$pushLog = ""
if (Test-Path $logFile) { $pushLog = Get-Content $logFile -Raw }

Write-Host "`nPush Result: $pushLog" -ForegroundColor Gray

if ($exitCode -eq 0 -or $pushLog -match "file pushed") {
    Write-Host "`n[OK] 100% Upload Complete ($totalMB MB transferred)!" -ForegroundColor Green
} else {
    Write-Host "`n[WARN] Push ended with code $exitCode, checking file on phone..." -ForegroundColor Yellow
}

# 4. Install APK
Write-Host "`n[3/4] Installing PlaceTrack default APK on mobile device..." -ForegroundColor Yellow
$installRes = (& $adb shell pm install -r $targetOnPhone 2>&1) -join "`n"
Write-Host "pm install result: $installRes" -ForegroundColor Cyan

if ($installRes -match "Success") {
    Write-Host "`n[4/4] Installation SUCCESSFUL!" -ForegroundColor Green
    Write-Host "Launching PlaceTrack app..." -ForegroundColor Yellow
    & $adb shell am start -n com.example.placetrack/.MainActivity
    Write-Host "[DONE] PlaceTrack launched on your mobile screen!" -ForegroundColor Green
} else {
    Write-Host "`n[NOTICE] Install response: $installRes" -ForegroundColor Yellow
}

# Restore screen timeout
& $adb shell svc power stayon false
Write-Host "Screen stay-awake reset to normal." -ForegroundColor Gray
