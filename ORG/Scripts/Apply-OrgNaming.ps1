param(
    [string]$RootPath = ".\WINDOWS\IntuneManagement",
    [string]$OrgPrefix = "EIT"
)

$JsonFiles = Get-ChildItem -Path $RootPath -Recurse -Filter *.json

foreach ($File in $JsonFiles) {
    $Content = Get-Content $File.FullName -Raw

    try {
        $Json = $Content | ConvertFrom-Json -Depth 100
    }
    catch {
        Write-Warning "Skipping invalid JSON: $($File.FullName)"
        continue
    }

    $Changed = $false

    if ($Json.displayName -and $Json.displayName -notlike "$OrgPrefix - *") {
        $Json.displayName = "$OrgPrefix - $($Json.displayName)"
        $Changed = $true
    }

    if ($Json.name -and $Json.name -notlike "$OrgPrefix - *") {
        $Json.name = "$OrgPrefix - $($Json.name)"
        $Changed = $true
    }

    if ($Changed) {
        $Json |
            ConvertTo-Json -Depth 100 |
            Set-Content -Path $File.FullName -Encoding UTF8

        Write-Host "Updated: $($File.FullName)"
    }
}