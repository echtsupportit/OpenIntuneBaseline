[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ })]
    [string]$CustomerPath,

    [switch]$CleanOutput
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Read-JsonFile {
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    if (-not (Test-Path $Path)) {
        throw "JSON file not found: $Path"
    }

    Get-Content -Path $Path -Raw | ConvertFrom-Json -Depth 100
}

function Write-JsonFile {
    param(
        [Parameter(Mandatory)]
        [object]$InputObject,

        [Parameter(Mandatory)]
        [string]$Path
    )

    $Directory = Split-Path -Path $Path -Parent

    if (-not (Test-Path $Directory)) {
        New-Item -ItemType Directory -Path $Directory -Force | Out-Null
    }

    $InputObject |
        ConvertTo-Json -Depth 100 |
        Set-Content -Path $Path -Encoding UTF8
}

function Get-RelativePathSafe {
    param(
        [Parameter(Mandatory)]
        [string]$BasePath,

        [Parameter(Mandatory)]
        [string]$FullPath
    )

    $BaseResolved = (Resolve-Path $BasePath).Path
    $FullResolved = (Resolve-Path $FullPath).Path

    return [System.IO.Path]::GetRelativePath($BaseResolved, $FullResolved)
}

$RepoRoot = Resolve-Path "."
$CustomerPathResolved = Resolve-Path $CustomerPath

$ConfigPath = Join-Path $CustomerPathResolved "customer.config.json"
$Config = Read-JsonFile -Path $ConfigPath

$SourceBaselinePath = Join-Path $RepoRoot $Config.sourceBaselinePath
$OutputPath = Join-Path $RepoRoot $Config.generatedOutputPath
$ExclusionPath = Join-Path $CustomerPathResolved "Overrides\excluded-policies.json"

if (-not (Test-Path $SourceBaselinePath)) {
    throw "Source baseline path not found: $SourceBaselinePath"
}

if ($CleanOutput -and (Test-Path $OutputPath)) {
    Remove-Item -Path $OutputPath -Recurse -Force
}

New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null

$ExcludedPolicyNames = @()

if (Test-Path $ExclusionPath) {
    $Exclusions = Read-JsonFile -Path $ExclusionPath

    if ($Exclusions.excludedPolicyNames) {
        $ExcludedPolicyNames = @($Exclusions.excludedPolicyNames)
    }
}

$JsonFiles = Get-ChildItem -Path $SourceBaselinePath -Recurse -Filter "*.json"

$Processed = 0
$Skipped = 0
$Renamed = 0
$MissingOibId = 0

foreach ($JsonFile in $JsonFiles) {
    $RelativePath = Get-RelativePathSafe -BasePath $SourceBaselinePath -FullPath $JsonFile.FullName
    $DestinationPath = Join-Path $OutputPath $RelativePath

    try {
        $Json = Read-JsonFile -Path $JsonFile.FullName
    }
    catch {
        Write-Warning "Skipping invalid JSON: $($JsonFile.FullName)"
        $Skipped++
        continue
    }

    $OriginalName = $null

    if ($Json.PSObject.Properties.Name -contains "name") {
        $OriginalName = $Json.name
    }
    elseif ($Json.PSObject.Properties.Name -contains "displayName") {
        $OriginalName = $Json.displayName
    }

    if ($OriginalName -and $ExcludedPolicyNames -contains $OriginalName) {
        Write-Host "Excluded: $OriginalName"
        $Skipped++
        continue
    }

    if ($Config.preserveOibId -eq $true) {
        if ($Json.PSObject.Properties.Name -contains "description") {
            if ($Json.description -notmatch "OIBID:") {
                $MissingOibId++
                Write-Warning "No OIBID found in description: $($JsonFile.FullName)"
            }
        }
    }

    if ($OriginalName) {
        $NewName = $Config.nameFormat
        $NewName = $NewName.Replace("{CustomerCode}", $Config.customerCode)
        $NewName = $NewName.Replace("{CustomerName}", $Config.customerName)
        $NewName = $NewName.Replace("{OriginalName}", $OriginalName)

        if ($Json.PSObject.Properties.Name -contains "name") {
            if ($Json.name -ne $NewName) {
                $Json.name = $NewName
                $Renamed++
            }
        }

        if ($Json.PSObject.Properties.Name -contains "displayName") {
            if ($Json.displayName -ne $NewName) {
                $Json.displayName = $NewName
                $Renamed++
            }
        }
    }

    Write-JsonFile -InputObject $Json -Path $DestinationPath
    $Processed++
}

$Summary = [PSCustomObject]@{
    CustomerName = $Config.customerName
    CustomerCode = $Config.customerCode
    SourceBaselinePath = $SourceBaselinePath
    OutputPath = $OutputPath
    ProcessedJsonFiles = $Processed
    SkippedJsonFiles = $Skipped
    RenamedProperties = $Renamed
    MissingOibIdWarnings = $MissingOibId
    GeneratedAtUtc = (Get-Date).ToUniversalTime().ToString("o")
}

$SummaryPath = Join-Path $OutputPath "_build-summary.json"
Write-JsonFile -InputObject $Summary -Path $SummaryPath

$Summary | Format-List