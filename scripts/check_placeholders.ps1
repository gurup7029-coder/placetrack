$txt = Get-Content 'C:\projects\placetrack\gri_docx_extracted\word\document.xml' -Raw
Write-Host "Looking for placeholders in document.xml..."
if ($txt.Contains("YOUR")) { Write-Host "Contains 'YOUR'" }
if ($txt.Contains("NAME")) { Write-Host "Contains 'NAME'" }
if ($txt.Contains("Bachelors in Computer Science")) { Write-Host "Contains Career Summary placeholder text" }
if ($txt.Contains("Pursuing  Bachelor of Science in Computer Science")) { Write-Host "Contains Education placeholder text" }
if ($txt.Contains("Possess fundamental knowledge on the programming languages")) { Write-Host "Contains Skills placeholder text" }
if ($txt.Contains("Worked as a Front End Tester")) { Write-Host "Contains Work experience placeholder text" }
