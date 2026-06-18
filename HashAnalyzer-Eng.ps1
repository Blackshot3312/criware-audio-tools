# ==========================================
# CRI Dataminer
# ==========================================

$signatures = @{
    "AFS2" = @{
        Hex = "41465332"
        Extension = ".awb"
    }

    "@UTF" = @{
        Hex = "40555446"
        Extension = ".acf"
    }

    "CRID" = @{
        Hex = "43524944"
        Extension = ".usm"
    }

    "HCA" = @{
        Hex = "48434100"
        Extension = ".hca"
    }

    "HSA" = @{
        Hex = "48534100"
        Extension = ".hsa"
    }

    "@ACB" = @{
        Hex = "40414342"
        Extension = ".acb"
    }

    "USM" = @{
        Hex = "55534D00"
        Extension = ".usm"
    }

    "CPE" = @{
        Hex = "43504500"
        Extension = ".cpe"
    }

    "SVX2" = @{
        Hex = "53565832"
        Extension = ".svx2"
    }
}

Clear-Host

Write-Host ""
Write-Host "========== CRI DATAMINER =========="
Write-Host ""
Write-Host "1  - AFS2 (.awb)"
Write-Host "2  - @UTF (.acf)"
Write-Host "3  - CRID (.usm)"
Write-Host "4  - HCA (.hca)"
Write-Host "5  - HSA (.hsa)"
Write-Host "6  - @ACB (.acb)"
Write-Host "7  - USM (.usm)"
Write-Host "8  - CPE (.cpe)"
Write-Host "9  - SVX2 (.svx2)"
Write-Host "10 - Scan All"
Write-Host ""

$choice = Read-Host "Select option"

$selectedFormats = @()

switch ($choice){
    "1"  { $selectedFormats += "AFS2" }
    "2"  { $selectedFormats += "@UTF" }
    "3"  { $selectedFormats += "CRID" }
    "4"  { $selectedFormats += "HCA" }
    "5"  { $selectedFormats += "HSA" }
    "6"  { $selectedFormats += "@ACB" }
    "7"  { $selectedFormats += "USM" }
    "8"  { $selectedFormats += "CPE" }
    "9"  { $selectedFormats += "SVX2" }
    "10" { $selectedFormats = $signatures.Keys }
    default {
        Write-Host "Invalid option."
        return
    }
}

$foundFiles = @()
$report = @{}

foreach ($format in $selectedFormats) {
    $report[$format] = 0
}

Write-Host ""
Write-Host "Scanning..."
Write-Host ""

Get-ChildItem -Recurse -File | ForEach-Object {
    try{
        $stream = [System.IO.File]::OpenRead($_.FullName)
        $length = [Math]::Min(4096, $stream.Length)
        $buffer = New-Object byte[] $length
        $stream.Read($buffer, 0, $length) | Out-Null
        $stream.Close()
        $hex = [BitConverter]::ToString($buffer).Replace("-", "")

        foreach ($format in $selectedFormats){
            $signature = $signatures[$format]

            if ($hex.Contains($signature.Hex)){
                $foundFiles += [PSCustomObject]@{
                    File      = $_
                    Format    = $format
                    Extension = $signature.Extension
                }

                $report[$format]++
                break
            }
        }
    }
    catch{
    }
}

Write-Host ""
Write-Host "========== RESULTS =========="
Write-Host ""

foreach ($item in $report.GetEnumerator()){
    Write-Host "$($item.Key) : $($item.Value)"
}

Write-Host ""
Write-Host "Total Files Found: $($foundFiles.Count)"
Write-Host ""

if ($foundFiles.Count -eq 0){
    Write-Host "No files found."
    return
}

$response = Read-Host "Move files to DataMining folder? (Y/N)"

if ($response.ToUpper() -ne "Y"){
    Write-Host "Operation cancelled."
    return
}

$rootDestination = Join-Path (Get-Location) "DataMining"

if (-not (Test-Path $rootDestination)){
    New-Item -ItemType Directory -Path $rootDestination | Out-Null
}

foreach ($entry in $foundFiles){
    $formatFolder = Join-Path $rootDestination $entry.Format

    if (-not (Test-Path $formatFolder)){
        New-Item -ItemType Directory -Path $formatFolder | Out-Null
    }

    $destinationFile = Join-Path $formatFolder $entry.File.Name

    if (Test-Path $destinationFile){
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($entry.File.Name)
        $counter = 1

        do{
            $newName = "$baseName`_$counter"
            $destinationFile = Join-Path $formatFolder $newName
            $counter++
        }
        while (Test-Path $destinationFile)
    }

    Move-Item $entry.File.FullName $destinationFile -Force
    $movedFile = Get-Item $destinationFile

    if ([string]::IsNullOrWhiteSpace($movedFile.Extension)){
        Rename-Item `
            -Path $movedFile.FullName `
            -NewName ($movedFile.Name + $entry.Extension)
    }
}

Write-Host ""
Write-Host "========== COMPLETE =========="
Write-Host ""
Write-Host "Files moved to:"
Write-Host $rootDestination
Write-Host ""
