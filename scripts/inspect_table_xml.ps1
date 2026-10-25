$txt = Get-Content 'C:\projects\placetrack\gri_docx_extracted\word\document.xml' -Raw
Write-Host "Length: $($txt.Length)"
$tableStart = $txt.IndexOf("<w:tbl>")
if ($tableStart -lt 0) { $tableStart = $txt.IndexOf("<w:tbl ") }
$tableEnd = $txt.IndexOf("</w:tbl>")
Write-Host "TableStart: $tableStart, TableEnd: $tableEnd"
if ($tableStart -ge 0) {
    Write-Host "Before Table:"
    Write-Host $txt.Substring(0, $tableStart)
}
