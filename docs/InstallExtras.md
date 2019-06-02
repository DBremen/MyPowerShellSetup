Packages refers to PowerShell modules that can be installed via Install-Module, or Scripts that can be installed via Install-Script, or chocolatey packages. Managed via a modified version of the Install-Extras.ps1 script in ZLoeber's WindowsSetupScripts module on [GitHub](https://github.com/zloeber/WindowsSetupScripts):

## Installation of packages module

Run [Install-Extras.ps1](https://github.com/DBremen/MyPowerShellSetup/blob/master/WindowsSetupScripts\Install-Extras.ps1)

## Maintaining packages

- GitHub only modules release packages
- Installed Chocolatey and PowerShellGet packages/modules are updated in the file [Install-Extras.ps1](https://github.com/DBremen/MyPowerShellSetup/blob/master/WindowsSetupScripts\Install-Extras.ps1) via the script [Update-InstalledModules.ps1](https://github.com/DBremen/MyPowerShellSetup/blob/master/WindowsSetupScripts\Update-InstalledModules.ps1). The script automatically retrieves installed Chocolatey packages and PowerShellGet scripts/modules and updates the file.
