[xml]$xml = Get-Content 'C:\projects\placetrack\gri_docx_extracted\word\document.xml'
Write-Host "InnerText of document.xml:"
Write-Host $xml.InnerText
