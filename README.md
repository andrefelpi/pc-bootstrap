# PC Bootstrap Script

Automates first-time setup of a Windows developer/gaming machine using `winget`.

This script is intended for personal use and can be customized by modifying the list of apps to install. It is not meant for enterprise deployment or production use without further enhancements (e.g. error handling, configuration management).

This README explains in the context of the `setup.ps1` script, other scripts may have different purposes and requirements(generaly only the programs that are installed).

## What this script does

1. Starts logging to `setup.log` in the same folder as the script.
2. Resets and updates Winget sources.
3. Reads the current installed package list.
4. Queues missing apps for installation (up to 3 parallel jobs).
5. Shows a live dashboard in the console with each app status:
	- `Waiting`
	- `Installing`
	- `Installed`
	- `Failed`
	- `Skipped`
6. Waits for all jobs to finish and prints an install report.
7. Runs a full upgrade pass with `winget upgrade --all`.
8. Prints Git global config commands for manual setup.

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

Optional (run directly from GitHub raw URL):

```powershell
irm https://raw.githubusercontent.com/andrefelpi/pc-bootstrap/main/setup.ps1 | iex
```
Can change setup.ps1 to worksetup for different app sets(maybe diferent ones in the future{for a custom list consider downloading the setup.ps1 file and modifying it}).

## Logs and troubleshooting

- Log file: `setup.log`
- Re-run the script to retry any failed installations.
- Existing apps are skipped automatically.

## Post-setup (Git identity)

At the end, the script prints these commands:

```powershell
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
git config --list
```

## Notes

- Existing installations are skipped.
- Package installs use Winget package/source agreement flags automatically.
- If a package fails, review `setup.log` and re-run the script.
