# ================================
# Bootstrap Developer Machine
# ================================

$logFile = "$PSScriptRoot\setup.log"

function Log {
    param([string]$message)

    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "$time - $message"

    Write-Host $entry
    Add-Content -Path $logFile -Value $entry
}

Log "Starting setup..."

# Reset winget sources
Log "Resetting Winget sources..."
winget source reset --force | Out-Null
winget source update | Out-Null
winget list --accept-source-agreements | Out-Null

# Define applications to install
$apps = @(
    @{Name="Visual Studio Code"; Id="Microsoft.VisualStudioCode"}
    @{Name="Visual Studio Community"; Id="Microsoft.VisualStudio.Community"}
    @{Name="Git"; Id="Git.Git"}
    @{Name="OBS Studio"; Id="OBSProject.OBSStudio"}
    @{Name="Local"; Id="Flywheel.Local"}
    @{Name="pgAdmin"; Id="PostgreSQL.pgAdmin"}
    @{Name="Microsoft SQL Server Management Studio"; Id="Microsoft.SQLServerManagementStudio.22"}
    @{Name="Foxit PDF Reader"; Id="Foxit.FoxitReader"}
)

# Limit parallel installations
$maxParallel = 3
$jobs = @()

Log "Checking installed applications..."
$installedPackages = winget list --accept-source-agreements

foreach ($app in $apps) {

    if ($installedPackages -match $app.Id) {
        Log "$($app.Name) already installed. Skipping."
        continue
    }

    Log "Starting install: $($app.Name)"

    while (($jobs | Where-Object { $_.State -eq "Running" }).Count -ge $maxParallel) {
        Start-Sleep -Seconds 2
    }

    $jobs += Start-Job -ScriptBlock {
        param($name,$id)

        Write-Host "Installing $name ..."

        winget install --id $id `
            --exact `
            --silent `
            --disable-interactivity `
            --accept-package-agreements `
            --accept-source-agreements
    } -ArgumentList $app.Name,$app.Id
}

Log "Waiting for installations to complete..."

$jobs | Wait-Job | Receive-Job

Log "All installations finished."

Log "Running upgrade pass..."
winget upgrade --all `
    --silent `
    --accept-package-agreements `
    --accept-source-agreements

Log "Setup finished."

Write-Host ""
Write-Host "======================================"
Write-Host " Git configuration required"
Write-Host "======================================"
Write-Host ""
Write-Host "Restart your terminal then run:"
Write-Host ""
Write-Host 'git config --global user.name "Your Name"'
Write-Host 'git config --global user.email "your@email.com"'
Write-Host ""
Write-Host "Verify with:"
Write-Host "git config --list"
Write-Host ""

Log "Log file saved to $logFile"