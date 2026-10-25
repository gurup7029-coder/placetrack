[xml]$xml = Get-Content 'C:\projects\placetrack\gri_docx_extracted\word\document.xml'
$ns = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
$ns.AddNamespace("w", "http://schemas.openxmlformats.org/wordprocessingml/2006/main")

Write-Host "--- PARAGRAPHS OUTSIDE TABLES ---"
$paragraphs = $xml.SelectNodes("/w:document/w:body/w:p", $ns)
foreach ($p in $paragraphs) {
    $tNodes = $p.SelectNodes(".//w:t", $ns)
    $txt = ($tNodes | ForEach-Object { $_.InnerText }) -join ""
    if ($txt) { Write-Host "P: $txt" }
}
