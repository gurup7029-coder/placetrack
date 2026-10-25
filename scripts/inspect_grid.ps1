$txt = Get-Content 'C:\projects\placetrack\gri_docx_extracted\word\document.xml' -Raw
$tblStart = $txt.IndexOf("<w:tbl>")
if ($tblStart -lt 0) { $tblStart = $txt.IndexOf("<w:tbl ") }
$gridEnd = $txt.IndexOf("</w:tblGrid>")
Write-Host "TABLE PROPS & GRID:"
Write-Host $txt.Substring($tblStart, $gridEnd - $tblStart + 12)
