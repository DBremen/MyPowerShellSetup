Managed via a modified version of the Install-Extras.ps1 script in ZLoeber's WindowsSetupScripts module on [GitHub](https://github.com/zloeber/WindowsSetupScripts):

## Installation of module/packages module

Run [Install-Extras.ps1](https://github.com/DBremen/MyPowerShellSetup/blob/master/WindowsSetupScripts\Install-Extras.ps1)

## Maintaining modules/packages

- GitHub only modules release packages
- Installed Chocolatey and PowerShellGet packages/modules are updated in the file [Install-Extras.ps1](https://github.com/DBremen/MyPowerShellSetup/blob/master/WindowsSetupScripts\Install-Extras.ps1) via the script [Update-InstalledModules.ps1](https://github.com/DBremen/MyPowerShellSetup/blob/master/WindowsSetupScripts\Update-InstalledModules). The script automatically retrieves installed Chocolatey packages and PowerShellGet modules and updates the file.
