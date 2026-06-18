# =====================================================
# AWB Stream Extractor
# =====================================================
#
# REQUIREMENTS:
# This script requires vgmstream-cli.exe to be present
# in the same directory where the script is executed.
#
# Due to licensing and distribution considerations,
# vgmstream-cli.exe is NOT included with this project.
#
# Download vgmstream separately and place
# vgmstream-cli.exe next to this script before running.
#
# =====================================================

Write-Host "AWB STREAM EXTRACTOR"
Clear-Host

Write-Host "File:"
Write-Host $file
Write-Host ""

Write-Host "vgmstream exists:"
Write-Host (Test-Path ".\vgmstream-cli.exe")
Write-Host ""


Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "        AWB STREAM EXTRACTOR" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verify vgmstream exists
if (-not (Test-Path ".\vgmstream-cli.exe"))
{
    Write-Host ""
    Write-Host "vgmstream-cli.exe was not found." -ForegroundColor Yellow
    Write-Host ""

    $response = Read-Host "Would you like to open the official vgmstream download page? (Y/N)"

    if ($response.ToUpper() -eq "Y")
    {
        Start-Process "https://github.com/vgmstream/vgmstream/releases"

        Write-Host ""
        Write-Host "Browser opened. Please download vgmstream-cli.exe and place it in this folder." -ForegroundColor Cyan
    }
    else
    {
        Write-Host ""
        Write-Host "Execution terminated. vgmstream-cli.exe not found." -ForegroundColor Red
    }

    return
}


$awbFiles = Get-ChildItem *.awb

if ($awbFiles.Count -eq 0)
{
    Write-Host "No AWB files were found." -ForegroundColor Yellow
    Pause
    return
}

Write-Host "Found $($awbFiles.Count) AWB file(s)." -ForegroundColor Green
Write-Host ""

$totalExtracted = 0

foreach ($awb in $awbFiles)
{
    $file = $awb.FullName
    $baseName = $awb.BaseName

    Write-Host ""
    Write-Host "----------------------------------------" -ForegroundColor DarkCyan
    Write-Host "Scanning: $baseName.awb" -ForegroundColor Cyan
    Write-Host "----------------------------------------" -ForegroundColor DarkCyan

    # Get stream information
    $info = & .\vgmstream-cli.exe -i -- "$file" 2>&1

    $streamCountLine = $info | Select-String "stream count:"

    if (-not $streamCountLine)
    {
        Write-Host "Unable to determine stream count." -ForegroundColor Yellow
        continue
    }

    $totalStreams = [int]($streamCountLine -replace '[^\d]')

    Write-Host "Streams detected: $totalStreams" -ForegroundColor Green

    # Create output folder
    $outputFolder = Join-Path (Get-Location) $baseName

    if (-not (Test-Path $outputFolder))
    {
        New-Item `
            -ItemType Directory `
            -Path $outputFolder | Out-Null
    }

    for ($i = 1; $i -le $totalStreams; $i++)
    {
        Write-Progress `
            -Activity "Extracting $baseName" `
            -Status "Stream $i of $totalStreams" `
            -PercentComplete (($i / $totalStreams) * 100)

        $outputFile = Join-Path `
            $outputFolder `
            "${baseName}_stream_$i.wav"

        .\vgmstream-cli.exe `
            -s $i `
            -o $outputFile `
            $file | Out-Null

        $totalExtracted++
    }

    Write-Progress -Activity "Extracting $baseName" -Completed

    Write-Host "Completed: $baseName" -ForegroundColor Green
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "EXTRACTION COMPLETE" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "AWB files processed : $($awbFiles.Count)"
Write-Host "Total WAV exported  : $totalExtracted"
Write-Host ""

Pause