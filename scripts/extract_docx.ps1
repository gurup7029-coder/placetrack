Add-Type -AssemblyName System.IO.Compression.FileSystem

$docxPath = "C:\projects\placetrack\GRI Resume Format.docx"
$zip = [System.IO.Compression.ZipFile]::OpenRead($docxPath)
$entry = $zip.GetEntry("word/document.xml")
$reader = New-Object System.IO.StreamReader($entry.Open())
$rawXml = $reader.ReadToEnd()
$reader.Close()
$zip.Dispose()

$xml = [xml]$rawXml

Write-Host "=== TABLES IN DOCX ==="
$tables = $xml.SelectNodes("//*[local-name()='tbl']")
Write-Host "Found $($tables.Count) tables."
foreach ($tbl in $tables) {
    Write-Host "--- TABLE ---"
    $rows = $tbl.SelectNodes(".//*[local-name()='tr']")
    foreach ($r in $rows) {
        $cells = $r.SelectNodes(".//*[local-name()='tc']")
        $cellTexts = @()
        foreach ($c in $cells) {
            $t = ($c.SelectNodes(".//*[local-name()='t']") | ForEach-Object { $_.InnerText }) -join ""
            $cellTexts += $t.Trim()
        }
        Write-Host ($cellTexts -join " | ")
    }
}

Write-Host "`n=== PARAGRAPHS IN DOCX ==="
$paragraphs = $xml.SelectNodes("//*[local-name()='p']")
foreach ($p in $paragraphs) {
    $t = ($p.SelectNodes(".//*[local-name()='t']") | ForEach-Object { $_.InnerText }) -join ""
    if ($t.Trim().Length -gt 0) {
        Write-Host $t.Trim()
    }
}
