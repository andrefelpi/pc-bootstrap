# PC Bootstrap Script

Automates first-time setup of a Windows developer/gaming machine using `winget`.

This script is intended for personal use and can be customized by modifying the list of apps to install. It is not meant for enterprise deployment or production use without further enhancements (e.g. error handling, configuration management).

This README explains in the context of the `setup.ps1` script, other scripts may have different purposes and requirements(generaly only the programs that are installed).

## What this script does

`setup.ps1` performs the following actions:

1. Creates/updates a log file at `setup.log` in the script folder.
2. Resets and updates Winget sources.
3. Checks whether each target app is already installed.
4. Installs missing apps in parallel (up to 3 at a time).
5. Waits for all install jobs to complete.
6. Runs `winget upgrade --all`.
7. Prints Git global configuration commands to run manually.

## Apps installed

- Steam (`Valve.Steam`)
- Visual Studio Code (`Microsoft.VisualStudioCode`)
- Visual Studio Community (`Microsoft.VisualStudio.Community`)
- Git (`Git.Git`)
- Brave Browser (`BraveSoftware.BraveBrowser`)
- Battle.net (`Blizzard.BattleNet`)
- WinRAR (`RARLab.WinRAR`)
- Discord (`Discord.Discord`)
- OBS Studio (`OBSProject.OBSStudio`)
- Foxit PDF Reader (`Foxit.FoxitReader`)

## Prerequisites

- Windows 10/11
- PowerShell 5.1+ (or PowerShell 7+)
- `winget` available in PATH
- Internet connection
- Recommended: run in an elevated terminal (Run as Administrator)

## Usage

From this folder, run:

```powershell
powershell -ExecutionPolicy Bypass -File .\setup.ps1
```

Or from an already-open PowerShell session:

```powershell
.\setup.ps1
```

In case you want to run the script without downloading it, you can execute it directly with the RAW GitHub URL in a powershell session:
```
irm https://raw.githubusercontent.com/andrefelpi/pc-bootstrap/main/"FileName"".ps1 | iex
```

## Logging

The script writes progress and status messages to:

- `setup.log`

Useful for checking install progress and troubleshooting failures.

## After setup

The script prints the following Git commands at the end. Run them after restarting your terminal:

```powershell
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
git config --list
```

## Notes

- Existing installations are skipped.
- Package installs use Winget package/source agreement flags automatically.
- If a package fails, review `setup.log` and re-run the script.
