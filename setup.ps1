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

$commonArgs = "--exact --accept-package-agreements --accept-source-agreements"

# Define applications to install
$apps = @(
    @{Name="Steam"; Id="Valve.Steam"}
    @{Name="Visual Studio Code"; Id="Microsoft.VisualStudioCode"}
    @{Name="Visual Studio Community"; Id="Microsoft.VisualStudio.Community"}
    @{Name="Git"; Id="Git.Git"}
    @{Name="Brave Browser"; Id="BraveSoftware.BraveBrowser"}
    @{Name="Battle.net"; Id="Blizzard.BattleNet"}
    @{Name="WinRAR"; Id="RARLab.WinRAR"}
    @{Name="Discord"; Id="Discord.Discord"}
    @{Name="OBS Studio"; Id="OBSProject.OBSStudio"}
)

# Limit parallel installations
$maxParallel = 3
$jobs = @()

Log "Checking installed applications..."

foreach ($app in $apps) {

    $installed = winget list --id $app.Id --exact | Select-String $app.Id

    if ($installed) {
        Log "$($app.Name) already installed. Skipping."
        continue
    }

    while (($jobs | Where-Object { $_.State -eq "Running" }).Count -ge $maxParallel) {
        Start-Sleep -Seconds 2
    }

    Log "Starting install: $($app.Name)"

    $jobs += Start-Job -ScriptBlock {
        param($name,$id,$installArgs,$log)

        function JobLog {
            param($msg,$file)
            $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Add-Content -Path $file -Value "$time - $msg"
        }

        JobLog "Installing $name" $log
        winget install --id $id $installArgs
        JobLog "$name install finished" $log

    } -ArgumentList $app.Name,$app.Id,$commonArgs,$logFile
}

Log "Waiting for installations to complete..."

$jobs | Wait-Job | Out-Null

Log "All installations finished."

Log "Running upgrade pass..."
winget upgrade --all --accept-package-agreements --accept-source-agreements

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