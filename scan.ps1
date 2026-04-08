$InputPath = Read-Host "Enter the path you want to scan"

$outputsCsv = "C:\Users\ccrodua\Documents\directory-scan\outputs\scan-$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').csv"
$LogFile   = "C:\Users\ccrodua\Documents\directory-scan\logs\log-$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').txt"

# Validate Input Path
if (-not (Test-Path -Path $InputPath)) {
    "ERROR: Input path not found: $InputPath" | Out-File -FilePath $LogFile -Encoding UTF8
    Write-Error "Input path not found: $InputPath"
    exit 1
}

# Ensure outputs folders exist
$csvFolder = Split-Path -Path $outputsCsv -Parent
$logFolder = Split-Path -Path $LogFile -Parent

if ($csvFolder -and -not (Test-Path $csvFolder)) {
    New-Item -Path $csvFolder -ItemType Directory -Force | Out-Null
}

if ($logFolder -and -not (Test-Path $logFolder)) {
    New-Item -Path $logFolder -ItemType Directory -Force | Out-Null
}

# Start log
"Scan started: $(Get-Date)" | Out-File -FilePath $LogFile -Encoding UTF8
"Input path: $InputPath" | Out-File -FilePath $LogFile -Append -Encoding UTF8

$items = @()

try {
    # Include root folder
    $items += Get-Item -Path $InputPath -Force

    # Include all child folders and files
    $scanErrors = $null
    $items += Get-ChildItem -Path $InputPath -Recurse -Force -ErrorAction SilentlyContinue -ErrorVariable scanErrors

    $items |
    Select-Object `
        @{Name='Name';Expression={ $_.Name }},
        @{Name='Date Modified';Expression={ $_.LastWriteTime }},
        @{Name='Type';Expression={ if ($_.PSIsContainer) { 'Folder' } else { 'File' } }},
        @{Name='Path';Expression={ $_.FullName }} |
    Export-Csv -Path $outputsCsv -NoTypeInformation -Encoding UTF8

    if ($scanErrors) {
        "Errors encountered:" | Out-File -FilePath $LogFile -Append -Encoding UTF8
        $scanErrors | ForEach-Object { $_.ToString() } | Out-File -FilePath $LogFile -Append -Encoding UTF8
    }

    "Total items exported: $($items.Count)" | Out-File -FilePath $LogFile -Append -Encoding UTF8
    "outputs CSV: $outputsCsv" | Out-File -FilePath $LogFile -Append -Encoding UTF8
    "Scan completed: $(Get-Date)" | Out-File -FilePath $LogFile -Append -Encoding UTF8

    Write-Host ""
    Write-Host "Completed!"
    Write-Host ""
    Write-Host "CSV: $outputsCsv"
    Write-Host "Log: $LogFile"
    Write-Host ""
}
catch {
    "FATAL ERROR: $($_.Exception.Message)" | Out-File -FilePath $LogFile -Append -Encoding UTF8
    Write-Error $_.Exception.Message
    exit 1
}