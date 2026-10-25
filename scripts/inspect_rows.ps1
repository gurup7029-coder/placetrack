[xml]$xml = Get-Content 'C:\projects\placetrack\gri_docx_extracted\word\document.xml'
$ns = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
$ns.AddNamespace("w", "http://schemas.openxmlformats.org/wordprocessingml/2006/main")

$rows = $xml.SelectNodes("//w:tbl/w:tr", $ns)
Write-Host "Total rows: $($rows.Count)"
for ($i = 0; $i -lt $rows.Count; $i++) {
    $row = $rows[$i]
    $firstCell = $row.SelectSingleNode(".//w:tc", $ns)
    $text = ""
    if ($firstCell) {
        $tNodes = $firstCell.SelectNodes(".//w:t", $ns)
        $text = ($tNodes | ForEach-Object { $_.InnerText }) -join ""
    }
    Write-Host "Row $i Header: '$text'"
}
