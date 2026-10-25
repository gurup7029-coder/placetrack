$adb = "C:\Users\USER\AppData\Local\Android\Sdk\platform-tools\adb.exe"
$apk = "build\app\outputs\flutter-apk\app-debug.apk"
$targetOnPhone = "/data/local/tmp/placetrack.apk"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " PLACETRACK DEFAULT APK INSTALLER WITH REALTIME MONITOR   " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# Check connection
$deviceRaw = (& $adb devices 2>&1) -join "`n"
if ($deviceRaw -notmatch "10BF8M38QZ004PL\s+device") {
    Write-Host "[ERROR] Device 10BF8M38QZ004PL is not connected or offline." -ForegroundColor Red
    exit 1
}

# Wake up screen and keep awake during install
Write-Host "`n[1/4] Waking up mobile screen to prevent USB sleep..." -ForegroundColor Yellow
& $adb shell input keyevent 224 | Out-Null

# Remove any old temp file
& $adb shell rm -f $targetOnPhone | Out-Null

$apkItem = Get-Item $apk
$totalBytes = $apkItem.Length
$totalMB = [math]::Round($totalBytes / 1MB, 2)
Write-Host "`n[2/4] Uploading Default APK ($totalMB MB)..." -ForegroundColor Yellow

# Start adb push as background process
$pinfo = New-Object System.Diagnostics.ProcessStartInfo
$pinfo.FileName = $adb
$pinfo.Arguments = "push `"$apk`" $targetOnPhone"
$pinfo.RedirectStandardOutput = $true
$pinfo.RedirectStandardError = $true
$pinfo.UseShellExecute = $false
$pinfo.CreateNoWindow = $true

$pushProcess = New-Object System.Diagnostics.Process
$pushProcess.StartInfo = $pinfo
$pushProcess.Start() | Out-Null

$startTime = Get-Date
$lastReportTime = Get-Date

while (-not $pushProcess.HasExited) {
    Start-Sleep -Seconds 10
    
    # Query current size on phone
    $remoteSizeStr = (& $adb shell stat -c %s $targetOnPhone 2>$null)
    $remoteBytes = 0
    if ($remoteSizeStr -match "^\d+$") {
        $remoteBytes = [int64]$remoteSizeStr
    }
    
    $percent = 0
    if ($totalBytes -gt 0) {
        $percent = [math]::Round(($remoteBytes / $totalBytes) * 100, 1)
    }
    $currentMB = [math]::Round($remoteBytes / 1MB, 2)
    $elapsed = [math]::Round(((Get-Date) - $startTime).TotalSeconds, 0)
    
    $now = Get-Date -Format "HH:mm:ss"
    Write-Host "[$now] Upload Progress: $percent% ($currentMB MB / $totalMB MB) - Elapsed: ${elapsed}s" -ForegroundColor Cyan
    
    # Prevent phone from sleeping
    & $adb shell input keyevent 224 | Out-Null
}

$pushProcess.WaitForExit()
$pushExitCode = $pushProcess.ExitCode
$pushErr = $pushProcess.StandardError.ReadToEnd()
$pushOut = $pushProcess.StandardOutput.ReadToEnd()

if ($pushExitCode -ne 0) {
    Write-Host "`n[ERROR] Push failed: $pushErr $pushOut" -ForegroundColor Red
    exit 1
}

Write-Host "`n[3/4] 100% Uploaded successfully! Now Installing APK on phone..." -ForegroundColor Green
$installStartTime = Get-Date

# Start install
$installOutput = & $adb shell pm install -r $targetOnPhone
Write-Host "Install Output: $installOutput" -ForegroundColor Cyan

if ($installOutput -match "Success") {
    Write-Host "`n[4/4] Installation COMPLETE! Launching PlaceTrack..." -ForegroundColor Green
    & $adb shell am start -n com.example.placetrack/.MainActivity
    Write-Host "`n[READY] PlaceTrack opened on your phone successfully!" -ForegroundColor Green
} else {
    Write-Host "`n[NOTICE] Installation returned: $installOutput" -ForegroundColor Yellow
}
