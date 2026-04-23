# Prompt for the root folder to scan
$InputPath = Read-Host "Enter the directory path you want to scan"

# Generate timestamp for unique output file name
$Timestamp = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'

# Set CSV output path
$OutputCsv = "C:\Users\ccrodua\Documents\directory-scan\outputs\folder-structure-$Timestamp.csv"

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

# Resolve full input path and remove trailing slash
$ResolvedInputPath = (Resolve-Path -Path $InputPath).Path.TrimEnd('\')

# Get the root folder name only
$RootFolder = (Get-Item -Path $ResolvedInputPath).Name

$Columns = @(
    'Root Folder',
    'Level 2 folders',
    'Level 3 folders',
    'Level 4 folders',
    'Level 5 folders',
    'Level 6 folders'
)

# Store output rows efficiently
$Results = [System.Collections.Generic.List[object]]::new()

# Track whether the root folder name has already been written
$script:RootWritten = $false

function New-BlankRow {
    # Create an ordered row so CSV columns stay in sequence
    $row = [ordered]@{}

    foreach ($column in $Columns) {
        # Initialize each column with a blank value
        $row[$column] = ''
    }

    return $row
}

function Add-FolderRows {
    param(
        [string]$Path,
        [int]$Level
    )

    if ($Level -gt 6) {
        # Stop recursion after Level 6
        return
    }

    # Get child folders only and sort them by name
    $Children = Get-ChildItem -Path $Path -Directory -Force |
        Sort-Object Name

    foreach ($Child in $Children) {
        # Start a new blank output row
        $Row = New-BlankRow

        if (-not $script:RootWritten) {
            # Write the root folder name only once
            $Row['Root Folder'] = $RootFolder
            $script:RootWritten = $true
        }

        # Place the folder name in the matching level column
        $Row["Level $Level folders"] = $Child.Name

        # Add the row to the output collection
        $Results.Add([PSCustomObject]$Row)

        # Recursively process child folders
        Add-FolderRows -Path $Child.FullName -Level ($Level + 1)
    }
}

# Start scanning from Level 2 under the root folder
Add-FolderRows -Path $ResolvedInputPath -Level 2

# Export results to CSV
$Results | Export-Csv -Path $OutputCsv -NoTypeInformation -Encoding UTF8

Write-Host ""
Write-Host "Completed!"
Write-Host ""

# Display the generated CSV file path
Write-Host "CSV: $OutputCsv"
Write-Host ""