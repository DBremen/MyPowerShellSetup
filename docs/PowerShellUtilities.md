> ### List of PowerShell utilities used on the command-line
Several PowerShell modules and functions that I use to improve productivity on the PowerShell prompt. Those that I created/customized are either in a module (helpers.psm1) that I load from my profile (with -DisableNameChecking). Or in separate .ps1/.psm1 files that I also load from my profile (from a folder called \Utils).

### Modules build by others

| Name | Type | Source | Description | Installation |
| --- | --- | --- | --- | --- |
| PSConsoleTheme | module | [GitHub](https://github.com/mmims/PSConsoleTheme) | Module to set colors in console based on themes (e.g. Dracula) | Install-Module PSConsoleTheme |
| ps-menu | module | [GitHub](https://github.com/chrisseroka/ps-menu) | Simple powershell menu to render interactive console menu (used to build tools) | Install-Module PS-Menu |
| Find-ClosestCommand | function | [GitHub Gist](https://gist.github.com/Jaykul/b8ed295d32ec2500b7becfed38308521) | Implementation of 'Did you mean?' for commands typed with the option to create aliases for mistyped commands via CommandNotFoundAction | [helpers.psm1/Measure-LevenshteinDistance](https://github.com/DBremen/MyPowerShellSetup/blob/master/helpers.psm1) and [Find-ClosestCommand](https://github.com/DBremen/MyPowerShellSetup/blob/master/helpers.psm1) , [profile.ps1](https://github.com/DBremen/MyPowerShellSetup/blob/master/profile.ps1) for custom CommandNotFoundAction |
| PSColor | module | [GitHub](https://github.com/Davlind/PSColor) | Provides basic color highlighting for ~~files~~(I have removed this in order to make it compatible with Terminal-Icons), services, select-string etc. | Install-Module -Name PSColor [Modified version](https://github.com/DBremen/MyPowerShellSetup/blob/master/PSColor) |
| posh-git | module | [GitHub](https://github.com/dahlbyk/posh-git) | Provides custom git prompt and general ability to customize prompt see([Prompt](https://dbremen.github.io/MyPowerShellSetup/#/prompt)) | Install-Module -Name posh-git |
| Terminal-Icons | module | [GitHub](https://github.com/devblackops/Terminal-Icons) | Provides custom terminal icons. Modified [Terminal-Icons.format.ps1xml](https://github.com/DBremen/MyPowerShellSetup/blob/master/Terminal-Icons.format.ps1xml). (On Windows replace 'LF' by 'CRLF' <pre>((Get-Content $path) -join "`r`n") + "`r`n" &#124; Set-Content -NoNewline $path -encoding utf8)</pre>) file to Format Length output into B,KB,MB,GB  | Install-Module -Name Terminal-Icons; get appropriate font (see [quick guide by Mark Wragg](https://gist.github.com/markwragg/6301bfcd56ce86c3de2bd7e2f09a8839) |

### Modules or functions I created or customized

| Name | Type | Source | Description | Installation |
| --- | --- | --- | --- | --- |
| Get-GitTip | function | [GitHub Gist](https://gist.github.com/jdhitsolutions/9676ec57fb28af96c08589e3e1a5b72c) | Get a random Git tip on PowerShell console startup | shorter version of the script in [helpers.psm1](https://github.com/DBremen/MyPowerShellSetup/blob/master/helpers.psm1) |
| weather | function | [Idera Power Tips](https://community.idera.com/database-tools/powershell/powertips/b/tips/posts/creating-colorful-weather-report) | Get colorful weather info from wttr.in | weather function in [helpers.psm1](https://github.com/DBremen/MyPowerShellSetup/blob/master/helpers.psm1) |
| cds | function | cds function in [helpers.psm1](https://github.com/DBremen/MyPowerShellSetup/blob/master/helpers.psm1) | **cd** into one of the "**s**pecial folders" (e.g. Desktop, "My Documents"...) using fzf.exe (requires PSFzf module | via helpers.psm1 |
| cdd | function | cdd function in [helpers.psm1](https://github.com/DBremen/MyPowerShellSetup/blob/master/helpers.psm1) | **cd** into one of the sub-**d**irectories of the current folder (requires ps-menu module) | via helpers.psm1 |
| touch | function | touch function in [helpers.psm1](https://github.com/DBremen/MyPowerShellSetup/blob/master/helpers.psm1) | PowerShell implementation of UNIX touch | via helpers.psm1 |
| s+ | function | s+ function in [helpers.psm1](https://github.com/DBremen/MyPowerShellSetup/blob/master/helpers.psm1) | Build a comma-separated list of quoted strings from the provided arguments | via helpers.psm1 |
| ql | function | ql function in [helpers.psm1](https://github.com/DBremen/MyPowerShellSetup/blob/master/helpers.psm1) | **q**uoted **l**ist -> build string array w/o the need to provide arguments in quotes | via helpers.psm1 |
| qs | function | qs function in [helpers.psm1](https://github.com/DBremen/MyPowerShellSetup/blob/master/helpers.psm1) | **q**uoted **s**tring -> build a string based on "words" provided as an argument | via helpers.psm1 |
| Get-RegExHelp | function | Get-RegexHelp function in [helpers.psm1](https://github.com/DBremen/MyPowerShellSetup/blob/master/helpers.psm1) and [regexHelptxt.csv](https://github.com/DBremen/MyPowerShellSetup/blob/master/files/regexHelptxt.csv) | Opens a .csv file with RegEx documenation via Out-GridView | via helpers.psm1 |
| pro | function | pro function in [helpers.psm1](https://github.com/DBremen/MyPowerShellSetup/blob/master/helpers.psm1) | Opens my profile (AllUsersAllHosts) in VSCode | via helpers.psm1 |


