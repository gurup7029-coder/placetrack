[xml]$xml = Get-Content 'C:\projects\placetrack\gri_docx_extracted\word\document.xml'
$ns = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
$ns.AddNamespace("w", "http://schemas.openxmlformats.org/wordprocessingml/2006/main")

$rows = $xml.SelectNodes("//w:tbl/w:tr", $ns)
for ($i = 0; $i -lt $rows.Count; $i++) {
    $row = $rows[$i]
    $cells = $row.SelectNodes(".//w:tc", $ns)
    Write-Host "================== ROW $i (Cells: $($cells.Count)) =================="
    for ($c = 0; $c -lt $cells.Count; $c++) {
        $pList = $cells[$c].SelectNodes(".//w:p", $ns)
        $tList = @()
        foreach ($p in $pList) {
            $tNodes = $p.SelectNodes(".//w:t", $ns)
            $tStr = ($tNodes | ForEach-Object { $_.InnerText }) -join ""
            if ($tStr) { $tList += $tStr }
        }
        Write-Host ("  Cell " + $c + ": " + ($tList -join ' /// '))
    }
}
