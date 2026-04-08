# Directory-Scan
PowerShell script that recursively scans a directory and exports a CSV report of all files and folders, including name, type, date modified, and full path.

## Features
- Recursively scans files and folders
- Includes the root directory
- Exports results to CSV
- Creates a log file for scan details and errors

## Output
The script generates:
- **CSV report** — list of files and folders
- **Log file** — scan summary and any errors encountered

## Usage
Run the script in PowerShell:
```powershell
.\directory-scan.ps1