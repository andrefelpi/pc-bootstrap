# ================================
# Bootstrap Developer Machine
# ================================

$logFile = "$PSScriptRoot\setup.log"
$results = @()

function Log {
    param([string]$message)

    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "$time - $message"

    Write-Host $entry
    Add-Content -Path $logFile -Value $entry
}

Log "Starting setup..."

Log "Resetting Winget sources..."
winget source reset --force | Out-Null
winget source update | Out-Null
winget list --accept-source-agreements | Out-Null

# Applications
$apps = @(
    @{Name="Visual Studio Code"; Id="Microsoft.VisualStudioCode"}
    @{Name="Visual Studio Community"; Id="Microsoft.VisualStudio.Community"}
    @{Name="Git"; Id="Git.Git"}
    @{Name="OBS Studio"; Id="OBSProject.OBSStudio"}
    @{Name="Local"; Id="Flywheel.Local"}
    @{Name="pgAdmin"; Id="PostgreSQL.pgAdmin"}
    @{Name="Microsoft SQL Server Management Studio"; Id="Microsoft.SQLServerManagementStudio.22"}
    @{Name="Foxit PDF Reader"; Id="Foxit.FoxitReader"}
    @{Name="Postman"; Id="Postman.Postman"}
    @{Name="PostgreSQL18"; Id="PostgreSQL.PostgreSQL.18"}
)

$maxParallel = 3
$jobs = @()
$statusTable = @{}

Log "Checking installed applications..."
$installedPackages = winget list --accept-source-agreements

foreach ($app in $apps) {

    if ($installedPackages -match $app.Id) {

        Log "$($app.Name) already installed. Skipping."

        $results += [PSCustomObject]@{
            Name   = $app.Name
            Status = "Skipped"
        }

        $statusTable[$app.Name] = "Skipped"
        continue
    }

    while (($jobs | Where-Object { $_.State -eq "Running" }).Count -ge $maxParallel) {
        Start-Sleep -Milliseconds 500
    }

    Log "Queueing install: $($app.Name)"
    $statusTable[$app.Name] = "Installing"

    $jobs += Start-Job -ScriptBlock {

        param($name,$id)

        winget install --id $id `
            --exact `
            --silent `
            --disable-interactivity `
            --accept-package-agreements `
            --accept-source-agreements

        if ($LASTEXITCODE -eq 0) {
            return [PSCustomObject]@{ Name=$name; Status="Installed" }
        }
        else {
            return [PSCustomObject]@{ Name=$name; Status="Failed" }
        }

    } -ArgumentList $app.Name,$app.Id
}

# ================================
# LIVE DASHBOARD
# ================================

while (($jobs | Where-Object { $_.State -eq "Running" }).Count -gt 0) {

    foreach ($job in $jobs) {

        if ($job.State -eq "Completed" -and -not $job.HasMoreData) { continue }

        if ($job.State -eq "Completed") {

            $result = Receive-Job $job
            $statusTable[$result.Name] = $result.Status

            $results += $result
        }
    }

    Clear-Host

    Write-Host ""
    Write-Host "===================================="
    Write-Host " Developer Machine Setup Dashboard"
    Write-Host "===================================="
    Write-Host ""

    foreach ($app in $apps) {

        $name = $app.Name

        if ($statusTable.ContainsKey($name)) {
            $state = $statusTable[$name]
        } else {
            $state = "Waiting"
        }

        "{0,-45} {1}" -f $name, $state
    }

    Start-Sleep -Seconds 1
}

$jobs | Wait-Job | Receive-Job | ForEach-Object { $results += $_ }

Log "All installations finished."

Log "Running upgrade pass..."
winget upgrade --all `
    --silent `
    --accept-package-agreements `
    --accept-source-agreements

Log "Setup finished."

Write-Host ""
Write-Host "================================="
Write-Host " INSTALL REPORT"
Write-Host "================================="

$results | Sort-Object Name | Format-Table -AutoSize

Write-Host ""
Write-Host "======================================"
Write-Host " Git configuration required"
Write-Host "======================================"
Write-Host ""

Write-Host 'git config --global user.name "Your Name"'
Write-Host 'git config --global user.email "your@email.com"'
Write-Host ""
Write-Host "Verify with:"
Write-Host "git config --list"
Write-Host ""

Log "Log file saved to $logFile"
