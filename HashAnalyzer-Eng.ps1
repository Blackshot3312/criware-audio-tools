# AFS2 signature
$afs2Hex = "41465332"
$foundFiles = @()

Get-ChildItem -Recurse -File | ForEach-Object {

    $bytes = Get-Content $_.FullName -Encoding Byte -TotalCount 4 -ErrorAction SilentlyContinue

    if ($bytes.Count -eq 4) {
        $hex = ($bytes | ForEach-Object { "{0:X2}" -f $_ }) -join ""

        if ($hex -eq $afs2Hex) {
            $foundFiles += $_
        }
    }
}

Write-Host ""
Write-Host "AFS2 files found: $($foundFiles.Count)"
Write-Host ""

$foundFiles | Select-Object Name, FullName

if ($foundFiles.Count -eq 0) {
    Write-Host "No files found."
    return
}

$response = Read-Host "Move files to DataMining folder? (Y/N)"
if ($response -ne "Y") {
    Write-Host "Operation cancelled."
    return
}

$destination = Join-Path (Get-Location) "DataMining"

if (-not (Test-Path $destination)) {
    New-Item -ItemType Directory -Path $destination | Out-Null
}

foreach ($file in $foundFiles) {
    $newPath = Join-Path $destination $file.Name
    Move-Item $file.FullName $newPath -Force
    $movedFile = Get-Item $newPath

    if ([string]::IsNullOrWhiteSpace($movedFile.Extension)) {
        Rename-Item `
            -Path $movedFile.FullName `
            -NewName ($movedFile.Name + ".awb")
    }
}

Write-Host ""
Write-Host "Process completed."
Write-Host "Files moved to:"
Write-Host $destination