$InputPath = Read-Host "Enter the directory path you want to scan"

$OutputCsv = "C:\Users\ccrodua\Documents\directory-scan\outputs\folder-structure-$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').csv"

# Validate input path
if (-not (Test-Path -Path $InputPath -PathType Container)) {
    Write-Error "Input directory not found: $InputPath"
    exit 1
}

# Ensure output folder exists
$OutputFolder = Split-Path -Path $OutputCsv -Parent
if (-not (Test-Path -Path $OutputFolder)) {
    New-Item -Path $OutputFolder -ItemType Directory -Force | Out-Null
}

# Get the top folder name
$RootItem = Get-Item -Path $InputPath
$RootFolder = $RootItem.Name

$Results = @()

# Get all subfolders recursively
$Folders = Get-ChildItem -Path $InputPath -Directory -Recurse -Force

foreach ($Folder in $Folders) {
    # Get path relative to the selected top folder
    $RelativePath = $Folder.FullName.Substring($InputPath.Length).TrimStart('\')

    if ([string]::IsNullOrWhiteSpace($RelativePath)) {
        continue
    }

    # Split into folder levels
    $Parts = $RelativePath -split '\\'

    # Only keep up to Level 6 columns
    $Results += [PSCustomObject]@{
        'Root Folder'      = $RootFolder
        'Level 2 folders' = if ($Parts.Count -ge 1) { $Parts[0] } else { '' }
        'Level 3 folders' = if ($Parts.Count -ge 2) { $Parts[1] } else { '' }
        'Level 4 folders' = if ($Parts.Count -ge 3) { $Parts[2] } else { '' }
        'Level 5 folders' = if ($Parts.Count -ge 4) { $Parts[3] } else { '' }
        'Level 6 folders' = if ($Parts.Count -ge 5) { $Parts[4] } else { '' }
    }
}

# Export results to CSV
$Results | Export-Csv -Path $OutputCsv -NoTypeInformation -Encoding UTF8

Write-Host ""
Write-Host "Completed!"
Write-Host ""
Write-Host "CSV: $OutputCsv"
Write-Host ""