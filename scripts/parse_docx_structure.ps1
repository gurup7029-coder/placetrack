[xml]$xml = Get-Content 'C:\projects\placetrack\gri_docx_extracted\word\document.xml'
$ns = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
$ns.AddNamespace("w", "http://schemas.openxmlformats.org/wordprocessingml/2006/main")

Write-Host "--- TABLES FOUND ---"
$tables = $xml.SelectNodes("//w:tbl", $ns)
Write-Host "Table count: $($tables.Count)"

foreach ($tbl in $tables) {
    Write-Host "`n>>> NEW TABLE <<<"
    $rows = $tbl.SelectNodes(".//w:tr", $ns)
    foreach ($row in $rows) {
        $cells = $row.SelectNodes(".//w:tc", $ns)
        $cellTexts = @()
        foreach ($c in $cells) {
            $pList = $c.SelectNodes(".//w:p", $ns)
            $pTexts = @()
            foreach ($p in $pList) {
                $tNodes = $p.SelectNodes(".//w:t", $ns)
                $txt = ($tNodes | ForEach-Object { $_.InnerText }) -join ""
                if ($txt) { $pTexts += $txt }
            }
            $cellTexts += ($pTexts -join " | ")
        }
        Write-Host "ROW: $($cellTexts -join '  ===>  ')"
    }
}
