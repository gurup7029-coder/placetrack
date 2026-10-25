Get-ChildItem 'C:\projects\placetrack\gri_docx_extracted\word\*.xml' | ForEach-Object {
    $c = Get-Content $_.FullName -Raw
    Write-Host "FILE: $($_.Name) (length: $($c.Length))"
    $matches = [regex]::Matches($c, '<w:t[^>]*>(.*?)</w:t>')
    $texts = ($matches | ForEach-Object { $_.Groups[1].Value }) -join " "
    if ($texts) {
        Write-Host "  TEXT: $texts"
    }
}
