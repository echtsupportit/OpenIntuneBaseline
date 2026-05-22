\# Customer Baseline Workflow



This repository is a fork of OpenIntuneBaseline with an added customer overlay workflow.



The original upstream OpenIntuneBaseline documentation is preserved in the root `README.md`.



This file describes how we manage customer-specific Intune baselines while keeping the upstream OpenIntuneBaseline source maintainable.



\---



\## Core Principle



We use a baseline-plus-overlay model:



```text

OpenIntuneBaseline upstream source

&#x20;       +

Customer-specific overlay

&#x20;       =

Generated customer-specific Intune JSON

```



The upstream baseline remains clean.



Customer-specific changes are made in `CUSTOMERS/<Customer>` and then generated into customer-specific output folders.



\---



\## Repository Layout



```text

OpenIntuneBaseline/

├─ WINDOWS/

│  └─ IntuneManagement/

│

├─ CUSTOMERS/

│  ├─ \_Shared/

│  │  └─ Scripts/

│  │     ├─ Build-CustomerBaseline.ps1

│  │     └─ Test-OIBMetadata.ps1

│  │

│  ├─ EchtIT/

│  │  ├─ customer.config.json

│  │  ├─ Assignments/

│  │  ├─ Docs/

│  │  ├─ Overrides/

│  │  │  └─ excluded-policies.json

│  │  └─ Output/

│  │     └─ generated/

│  │

│  ├─ TestCustomer01/

│  │  ├─ customer.config.json

│  │  ├─ Assignments/

│  │  ├─ Docs/

│  │  ├─ Overrides/

│  │  │  └─ excluded-policies.json

│  │  └─ Output/

│  │     └─ generated/

│  │

│  └─ TestCustomer02/

│     ├─ customer.config.json

│     ├─ Assignments/

│     ├─ Docs/

│     ├─ Overrides/

│     │  └─ excluded-policies.json

│     └─ Output/

│        └─ generated/

```



\---



\## Folder Purposes



| Folder | Purpose |

|---|---|

| `WINDOWS/IntuneManagement` | Clean upstream OpenIntuneBaseline JSON source |

| `CUSTOMERS/<Customer>` | Customer-specific overlay |

| `CUSTOMERS/<Customer>/customer.config.json` | Customer naming and generation settings |

| `CUSTOMERS/<Customer>/Overrides` | Policy exclusions and documented deviations |

| `CUSTOMERS/<Customer>/Assignments` | Assignment model and deployment ring documentation |

| `CUSTOMERS/<Customer>/Docs` | Customer-specific operational documentation |

| `CUSTOMERS/<Customer>/Output/generated` | Generated Intune import-ready JSON |

| `CUSTOMERS/\_Shared/Scripts` | Shared scripts for generation and validation |



\---



\# Rules



\## 1. Do Not Edit Upstream Files for Customer-Specific Changes



Do not make customer-specific edits in:



```text

WINDOWS/IntuneManagement

```



This folder should stay as close as possible to the upstream OpenIntuneBaseline project.



Customer-specific changes belong in:



```text

CUSTOMERS/<Customer>

```



Examples of customer-specific changes:



```text

customer naming

policy exclusions

assignment documentation

deployment ring documentation

setting deviation documentation

customer-specific generated output

```



\---



\## 2. Import Only Generated Customer Output into Intune



For Intune import, use:



```text

CUSTOMERS/<Customer>/Output/generated

```



Do not import customer baselines directly from:



```text

WINDOWS/IntuneManagement

```



unless the intention is to deploy the unmodified upstream OpenIntuneBaseline baseline.



\---



\## 3. Preserve OIBID Metadata



Some OpenIntuneBaseline policies contain an `OIBID` value in the policy description.



Example:



```json

"description": "Some description text.\\nOIBID:64EB18DA-74A8-45B4-8A08-67BAFC82A2A0"

```



Do not remove or modify the `OIBID`.



The generated customer-specific policy name may change, but the `OIBID` must remain intact.



\---



\## 4. Generated Output Is Disposable



Files in:



```text

CUSTOMERS/<Customer>/Output/generated

```



are generated files.



They can be deleted and recreated.



Durable customer-specific configuration belongs in:



```text

CUSTOMERS/<Customer>/customer.config.json

CUSTOMERS/<Customer>/Overrides

CUSTOMERS/<Customer>/Assignments

CUSTOMERS/<Customer>/Docs

CUSTOMERS/\_Shared/Scripts

```



Avoid maintaining long-term manual edits directly in generated output.



\---



\# Working Environment



We edit this repository on Windows using Visual Studio.



Open the repository folder:



```text

C:\\Github\\OpenIntuneBaseline

```



Use either the Visual Studio integrated terminal or a normal PowerShell terminal.



All PowerShell commands in this document assume the current directory is the repository root:



```powershell

C:\\Github\\OpenIntuneBaseline

```



Check the current path:



```powershell

Get-Location

```



Expected:



```text

C:\\Github\\OpenIntuneBaseline

```



\---



\# Branch Model



Recommended branch model:



```text

main

&#x20; Clean upstream OpenIntuneBaseline source



org/customer-overlays

&#x20; Customer overlays, scripts, generated output, and workflow documentation

```



The `main` branch should remain close to the original upstream OpenIntuneBaseline repository.



Customer-specific work should happen on:



```powershell

git checkout org/customer-overlays

```



\---



\# Existing Customers



Current customer folders:



```text

CUSTOMERS/EchtIT

CUSTOMERS/TestCustomer01

CUSTOMERS/TestCustomer02

```



Expected generated naming:



```text

EchtIT          -> EIT - Win - OIB - ...

TestCustomer01 -> TC01 - Win - OIB - ...

TestCustomer02 -> TC02 - Win - OIB - ...

```



\---



\# Customer Configuration



Each customer has a configuration file:



```text

CUSTOMERS/<Customer>/customer.config.json

```



Example for Echt IT:



```json

{

&#x20; "customerName": "Echt IT",

&#x20; "customerCode": "EIT",

&#x20; "nameFormat": "{CustomerCode} - {OriginalName}",

&#x20; "preserveOibId": true,

&#x20; "sourceBaselinePath": "WINDOWS/IntuneManagement",

&#x20; "generatedOutputPath": "CUSTOMERS/EchtIT/Output/generated",

&#x20; "assignmentMode": "PilotFirst"

}

```



\## Config Properties



| Property | Description |

|---|---|

| `customerName` | Friendly customer name |

| `customerCode` | Prefix used in generated Intune policy names |

| `nameFormat` | Naming template used by the generator |

| `preserveOibId` | Indicates OIBID metadata must be preserved |

| `sourceBaselinePath` | Source baseline folder |

| `generatedOutputPath` | Customer-specific generated output folder |

| `assignmentMode` | Deployment strategy note |



\---



\# Generate Customer Baselines



\## Generate EchtIT



```powershell

.\\CUSTOMERS\\\_Shared\\Scripts\\Build-CustomerBaseline.ps1 -CustomerPath ".\\CUSTOMERS\\EchtIT" -CleanOutput

```



\## Generate TestCustomer01



```powershell

.\\CUSTOMERS\\\_Shared\\Scripts\\Build-CustomerBaseline.ps1 -CustomerPath ".\\CUSTOMERS\\TestCustomer01" -CleanOutput

```



\## Generate TestCustomer02



```powershell

.\\CUSTOMERS\\\_Shared\\Scripts\\Build-CustomerBaseline.ps1 -CustomerPath ".\\CUSTOMERS\\TestCustomer02" -CleanOutput

```



\## Generate All Existing Customers



```powershell

$Customers = @("EchtIT", "TestCustomer01", "TestCustomer02")



foreach ($Customer in $Customers) {

&#x20;   .\\CUSTOMERS\\\_Shared\\Scripts\\Build-CustomerBaseline.ps1 -CustomerPath ".\\CUSTOMERS\\$Customer" -CleanOutput

}

```



Generated output is written to:



```text

CUSTOMERS/<Customer>/Output/generated

```



\---



\# Validate Generated Output



\## Validate Metadata for One Customer



```powershell

.\\CUSTOMERS\\\_Shared\\Scripts\\Test-OIBMetadata.ps1 -Path ".\\CUSTOMERS\\EchtIT\\Output\\generated"

```



\## Validate Metadata for All Customers



```powershell

$Customers = @("EchtIT", "TestCustomer01", "TestCustomer02")



foreach ($Customer in $Customers) {

&#x20;   Write-Host "`nValidating $Customer" -ForegroundColor Cyan

&#x20;   .\\CUSTOMERS\\\_Shared\\Scripts\\Test-OIBMetadata.ps1 -Path ".\\CUSTOMERS\\$Customer\\Output\\generated"

}

```



\## Check Generated Policy Names



```powershell

$Customers = @("EchtIT", "TestCustomer01", "TestCustomer02")



foreach ($Customer in $Customers) {

&#x20;   Write-Host "`n$Customer" -ForegroundColor Cyan



&#x20;   Get-ChildItem ".\\CUSTOMERS\\$Customer\\Output\\generated" -Recurse -Filter "\*.json" |

&#x20;       Where-Object { $\_.Name -notlike "\_\*" } |

&#x20;       Select-Object -First 10 |

&#x20;       ForEach-Object {

&#x20;           $Json = Get-Content $\_.FullName -Raw | ConvertFrom-Json



&#x20;           $PolicyName = $null



&#x20;           if ($Json.PSObject.Properties.Name -contains "name") {

&#x20;               $PolicyName = $Json.name

&#x20;           }

&#x20;           elseif ($Json.PSObject.Properties.Name -contains "displayName") {

&#x20;               $PolicyName = $Json.displayName

&#x20;           }



&#x20;           \[PSCustomObject]@{

&#x20;               File = $\_.Name

&#x20;               Name = $PolicyName

&#x20;           }

&#x20;       } |

&#x20;       Format-Table -AutoSize

}

```



Expected examples:



```text

EIT - Win - OIB - SC - Device Security - D - Script File Associations - v3.4

TC01 - Win - OIB - SC - Device Security - D - Script File Associations - v3.4

TC02 - Win - OIB - SC - Device Security - D - Script File Associations - v3.4

```



Incorrect examples:



```text

EIT - EIT - Win - OIB - ...

TC01 - EIT - Win - OIB - ...

TC02 - EIT - Win - OIB - ...

```



Double prefixes usually mean that the source baseline in `WINDOWS/IntuneManagement` already contains customer-prefixed names.



\---



\# Baseline Update Workflow



Use this workflow when the upstream OpenIntuneBaseline repository changes.



\## Step 1 — Save Current Work



Check current Git state:



```powershell

git status

```



Commit current work if needed:



```powershell

git add .

git commit -m "Save current customer overlay changes"

```



\## Step 2 — Update `main` from Upstream



Switch to `main`:



```powershell

git checkout main

```



Fetch upstream changes:



```powershell

git fetch upstream

```



Merge upstream into `main`:



```powershell

git merge upstream/main

```



Push updated `main`:



```powershell

git push origin main

```



\## Step 3 — Merge `main` into the Customer Overlay Branch



Switch back to the customer overlay branch:



```powershell

git checkout org/customer-overlays

```



Merge `main`:



```powershell

git merge main

```



Resolve merge conflicts in Visual Studio if needed.



After resolving conflicts:



```powershell

git add .

git commit

```



\## Step 4 — Confirm the Upstream Baseline Is Still Clean



Check for customer prefixes inside the upstream baseline:



```powershell

Select-String -Path ".\\WINDOWS\\IntuneManagement\\\*\*\\\*.json" -Pattern '"name": "EIT -','"name": "TC01 -','"name": "TC02 -'

```



Expected result:



```text

No output

```



If results appear, restore the upstream baseline from `main`:



```powershell

git checkout main -- WINDOWS

```



Commit the correction:



```powershell

git add WINDOWS

git commit -m "Restore upstream baseline files"

```



\## Step 5 — Regenerate All Customer Baselines



```powershell

$Customers = @("EchtIT", "TestCustomer01", "TestCustomer02")



foreach ($Customer in $Customers) {

&#x20;   .\\CUSTOMERS\\\_Shared\\Scripts\\Build-CustomerBaseline.ps1 -CustomerPath ".\\CUSTOMERS\\$Customer" -CleanOutput

}

```



\## Step 6 — Validate All Customer Output



```powershell

$Customers = @("EchtIT", "TestCustomer01", "TestCustomer02")



foreach ($Customer in $Customers) {

&#x20;   Write-Host "`nValidating $Customer" -ForegroundColor Cyan

&#x20;   .\\CUSTOMERS\\\_Shared\\Scripts\\Test-OIBMetadata.ps1 -Path ".\\CUSTOMERS\\$Customer\\Output\\generated"

}

```



\## Step 7 — Review Generated Changes



```powershell

git status

git diff --stat

git diff -- CUSTOMERS

```



\## Step 8 — Commit Regenerated Baselines



```powershell

git add CUSTOMERS

git commit -m "Regenerate customer baselines after upstream update"

git push origin org/customer-overlays

```



\## Step 9 — Deploy Through Rings



Recommended deployment order:



```text

1\. Lab

2\. IT pilot

3\. Business pilot

4\. Production

```



Do not import a new or updated baseline directly to production.



\---



\# Add a New Customer



Use this workflow when onboarding a new customer.



Example:



```text

Customer name: Contoso

Customer code: CON

Folder name: Contoso

```



\## Step 1 — Create Customer Folders



```powershell

$Customer = "Contoso"



$Folders = @(

&#x20;   "CUSTOMERS\\$Customer",

&#x20;   "CUSTOMERS\\$Customer\\Docs",

&#x20;   "CUSTOMERS\\$Customer\\Assignments",

&#x20;   "CUSTOMERS\\$Customer\\Overrides",

&#x20;   "CUSTOMERS\\$Customer\\Output",

&#x20;   "CUSTOMERS\\$Customer\\Output\\generated"

)



foreach ($Folder in $Folders) {

&#x20;   New-Item -ItemType Directory -Path $Folder -Force | Out-Null

}

```



\## Step 2 — Create Customer Config



Create:



```text

CUSTOMERS/Contoso/customer.config.json

```



Content:



```json

{

&#x20; "customerName": "Contoso",

&#x20; "customerCode": "CON",

&#x20; "nameFormat": "{CustomerCode} - {OriginalName}",

&#x20; "preserveOibId": true,

&#x20; "sourceBaselinePath": "WINDOWS/IntuneManagement",

&#x20; "generatedOutputPath": "CUSTOMERS/Contoso/Output/generated",

&#x20; "assignmentMode": "PilotFirst"

}

```



\## Step 3 — Create Exclusions File



Create:



```text

CUSTOMERS/Contoso/Overrides/excluded-policies.json

```



Content:



```json

{

&#x20; "excludedPolicyNames": \[]

}

```



\## Step 4 — Generate the Baseline



```powershell

.\\CUSTOMERS\\\_Shared\\Scripts\\Build-CustomerBaseline.ps1 -CustomerPath ".\\CUSTOMERS\\Contoso" -CleanOutput

```



\## Step 5 — Validate the Baseline



```powershell

.\\CUSTOMERS\\\_Shared\\Scripts\\Test-OIBMetadata.ps1 -Path ".\\CUSTOMERS\\Contoso\\Output\\generated"

```



Check generated names:



```powershell

Get-ChildItem ".\\CUSTOMERS\\Contoso\\Output\\generated" -Recurse -Filter "\*.json" |

&#x20;   Where-Object { $\_.Name -notlike "\_\*" } |

&#x20;   Select-Object -First 10 |

&#x20;   ForEach-Object {

&#x20;       $Json = Get-Content $\_.FullName -Raw | ConvertFrom-Json



&#x20;       $PolicyName = $null



&#x20;       if ($Json.PSObject.Properties.Name -contains "name") {

&#x20;           $PolicyName = $Json.name

&#x20;       }

&#x20;       elseif ($Json.PSObject.Properties.Name -contains "displayName") {

&#x20;           $PolicyName = $Json.displayName

&#x20;       }



&#x20;       \[PSCustomObject]@{

&#x20;           File = $\_.Name

&#x20;           Name = $PolicyName

&#x20;       }

&#x20;   } |

&#x20;   Format-Table -AutoSize

```



Expected:



```text

CON - Win - OIB - ...

```



\## Step 6 — Commit the New Customer



```powershell

git add CUSTOMERS/Contoso

git commit -m "Add Contoso customer baseline overlay"

git push origin org/customer-overlays

```



\---



\# Edit an Existing Customer



Use this workflow when modifying an existing customer.



\## Change Customer Naming



Edit:



```text

CUSTOMERS/<Customer>/customer.config.json

```



Example:



```json

{

&#x20; "customerName": "Echt IT",

&#x20; "customerCode": "EIT",

&#x20; "nameFormat": "{CustomerCode} - {OriginalName}",

&#x20; "preserveOibId": true,

&#x20; "sourceBaselinePath": "WINDOWS/IntuneManagement",

&#x20; "generatedOutputPath": "CUSTOMERS/EchtIT/Output/generated",

&#x20; "assignmentMode": "PilotFirst"

}

```



After editing, regenerate:



```powershell

.\\CUSTOMERS\\\_Shared\\Scripts\\Build-CustomerBaseline.ps1 -CustomerPath ".\\CUSTOMERS\\<Customer>" -CleanOutput

```



Validate:



```powershell

.\\CUSTOMERS\\\_Shared\\Scripts\\Test-OIBMetadata.ps1 -Path ".\\CUSTOMERS\\<Customer>\\Output\\generated"

```



Commit:



```powershell

git add CUSTOMERS/<Customer>

git commit -m "Update <Customer> customer baseline"

git push origin org/customer-overlays

```



\---



\## Exclude a Policy



Edit:



```text

CUSTOMERS/<Customer>/Overrides/excluded-policies.json

```



Example:



```json

{

&#x20; "excludedPolicyNames": \[

&#x20;   "Win - OIB - SC - Device Security - D - Script File Associations - v3.4"

&#x20; ]

}

```



Use the original upstream policy name, not the generated customer-prefixed name.



Correct:



```text

Win - OIB - SC - Device Security - D - Script File Associations - v3.4

```



Incorrect:



```text

EIT - Win - OIB - SC - Device Security - D - Script File Associations - v3.4

```



Also document the reason in:



```text

CUSTOMERS/<Customer>/Overrides/ExcludedPolicies.md

```



Regenerate:



```powershell

.\\CUSTOMERS\\\_Shared\\Scripts\\Build-CustomerBaseline.ps1 -CustomerPath ".\\CUSTOMERS\\<Customer>" -CleanOutput

```



Validate and commit:



```powershell

.\\CUSTOMERS\\\_Shared\\Scripts\\Test-OIBMetadata.ps1 -Path ".\\CUSTOMERS\\<Customer>\\Output\\generated"



git add CUSTOMERS/<Customer>

git commit -m "Exclude policy from <Customer> baseline"

git push origin org/customer-overlays

```



\---



\## Document a Setting Override



If a customer requires a setting to differ from OpenIntuneBaseline, document it in:



```text

CUSTOMERS/<Customer>/Overrides/SettingOverrides.md

```



Recommended table:



```markdown

| Policy | Setting | OIB Default | Customer Value | Reason | Owner | Review Date |

|---|---|---|---|---|---|---|

| Win - OIB - SC - Network Security - D - Disable NTLM - v3.8 | NTLM restrictions | Enabled | Disabled | Legacy application dependency | Endpoint Team | 2026-08-01 |

```



If the setting override requires generated JSON to change, make the change repeatable through script or documented process.



Avoid maintaining long-term manual edits directly in generated output.



\---



\## Edit Assignment Model



Edit:



```text

CUSTOMERS/<Customer>/Assignments/AssignmentModel.md

```



Typical content:



```markdown

\# Assignment Model



| Ring | Group Name | Purpose |

|---|---|---|

| Ring 0 | INTUNE-EIT-OIB-LAB | Lab/test devices |

| Ring 1 | INTUNE-EIT-OIB-PILOT | IT pilot devices/users |

| Ring 2 | INTUNE-EIT-OIB-BUSINESS-PILOT | Friendly-user pilot |

| Ring 3 | INTUNE-EIT-OIB-PROD | Production deployment |

| Exclusion | INTUNE-EIT-OIB-EXCLUDE | General exclusions |

| Break Glass | INTUNE-EIT-OIB-BREAKGLASS-EXCLUDE | Emergency/break-glass exclusions |

```



Assignment documentation does not automatically change JSON unless assignment handling is added to the build scripts.



\---



\# Intune Import



Import policies from the generated customer output folder.



Examples:



```text

CUSTOMERS/EchtIT/Output/generated

CUSTOMERS/TestCustomer01/Output/generated

CUSTOMERS/TestCustomer02/Output/generated

```



Do not import customer baselines from:



```text

WINDOWS/IntuneManagement

```



Recommended rollout:



```text

1\. Lab

2\. IT pilot

3\. Business pilot

4\. Production

```



\---



\# Troubleshooting



\## PowerShell Script Was Pasted into the Terminal



Do not paste the contents of `.ps1` scripts directly into PowerShell.



Save the script as a `.ps1` file and run the file.



Correct:



```powershell

.\\CUSTOMERS\\\_Shared\\Scripts\\Build-CustomerBaseline.ps1 -CustomerPath ".\\CUSTOMERS\\EchtIT" -CleanOutput

```



Incorrect:



```powershell

\[CmdletBinding()]

param(

&#x20;   ...

)

```



\---



\## Script Execution Is Blocked



Run:



```powershell

Unblock-File .\\CUSTOMERS\\\_Shared\\Scripts\\Build-CustomerBaseline.ps1

Unblock-File .\\CUSTOMERS\\\_Shared\\Scripts\\Test-OIBMetadata.ps1

```



Or run with bypass:



```powershell

powershell.exe -ExecutionPolicy Bypass -File .\\CUSTOMERS\\\_Shared\\Scripts\\Build-CustomerBaseline.ps1 -CustomerPath ".\\CUSTOMERS\\EchtIT" -CleanOutput

```



\---



\## Double Prefixes Appear



Incorrect examples:



```text

EIT - EIT - Win - OIB - ...

TC01 - EIT - Win - OIB - ...

TC02 - EIT - Win - OIB - ...

```



Cause:



```text

WINDOWS/IntuneManagement already contains customer-prefixed names.

```



Fix:



```powershell

git checkout main -- WINDOWS

```



Then regenerate customer output.



\---



\## `\_build-summary.json` Has No `name` Property



This is expected.



`\_build-summary.json` is not an Intune policy.



Validation and name-checking commands should skip files starting with `\_`.



\---



\## Warning About Missing OIBID



If the warning refers to `\_build-summary.json`, ignore it.



If it refers to a real policy JSON file, inspect that policy manually.



\---



\# Commit Message Examples



Good examples:



```text

Add Contoso customer baseline overlay

Regenerate customer baselines after upstream update

Update EchtIT customer naming

Exclude script file association policy from EchtIT baseline

Restore upstream baseline files

```



Avoid vague messages:



```text

fix

updates

changes

stuff

```



\---



\# Summary



Use:



```text

WINDOWS/IntuneManagement

```



as the clean upstream OpenIntuneBaseline source.



Use:



```text

CUSTOMERS/<Customer>

```



for customer-specific configuration.



Use:



```text

CUSTOMERS/<Customer>/Output/generated

```



for Intune import-ready output.



Do not manually maintain customer-specific changes in the upstream baseline folder.

