[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ })]
    [string]$Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$JsonFiles = Get-ChildItem -Path $Path -Recurse -Filter "*.json"

$Results = foreach ($File in $JsonFiles) {
    try {
        $Json = Get-Content -Path $File.FullName -Raw | ConvertFrom-Json -Depth 100
    }
    catch {
        [PSCustomObject]@{
            File = $File.FullName
            Name = $null
            HasDescription = $false
            HasOibId = $false
            Status = "InvalidJson"
        }
        continue
    }

    $Description = $null
    $Name = $null

    if ($Json.PSObject.Properties.Name -contains "description") {
        $Description = $Json.description
    }

    if ($Json.PSObject.Properties.Name -contains "name") {
        $Name = $Json.name
    }
    elseif ($Json.PSObject.Properties.Name -contains "displayName") {
        $Name = $Json.displayName
    }

    [PSCustomObject]@{
        File = $File.FullName
        Name = $Name
        HasDescription = [bool]$Description
        HasOibId = ($Description -match "OIBID:")
        Status = if ($Description -match "OIBID:") { "OK" } else { "MissingOibId" }
    }
}

$Results | Sort-Object Status, File | Format-Table -AutoSize

$Missing = @($Results | Where-Object { $_.Status -eq "MissingOibId" })

if ($Missing.Count -gt 0) {
    Write-Warning "$($Missing.Count) JSON files do not contain OIBID in description."
}
else {
    Write-Host "All checked JSON files contain OIBID metadata where detected." -ForegroundColor Green
}