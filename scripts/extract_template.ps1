Add-Type -AssemblyName System.IO.Compression.FileSystem
$zipPath = 'C:\projects\placetrack\GRI Resume Format.docx'
$dest = 'C:\projects\placetrack\gri_docx_extracted'
if (Test-Path $dest) { Remove-Item -Recurse -Force $dest }
[System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $dest)
Write-Host "Extracted successfully to $dest"
Get-ChildItem $dest -Recurse | Select-Object FullName
