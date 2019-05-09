> ### List of PowerShell utilities used on the command-line
Several PowerShell modules and functions that I use to improve productivity on the PowerShell prompt. Those that I created/customized are either in a module (helpers.psm1) that I load from my profile. Or in separate .ps1/.psm1 files that I also load from my profile (from a folder called \Utils).

| Name | Type | Source | Description | Installation |
| --- | --- | --- | --- | --- |
| ps-menu | module | [GitHub](https://github.com/chrisseroka/ps-menu) | Simple powershell menu to render interactive console menu (used to build tools) | Install-Module PS-Menu |
| Find-ClosestCommand | function | [GitHub Gist](https://gist.github.com/Jaykul/b8ed295d32ec2500b7becfed38308521) | Implementation of 'Did you mean?' for commands typed with the option to create aliases for mistyped commands via CommandNotFoundAction | [helpers.psm1/Measure-LevenshteinDistance and Find-ClosestCommand](https://github.com/DBremen/MyPowerShellSetup/blob/master/helpers.psm1), [profile.ps1 for CommandNotFoundAction](https://github.com/DBremen/MyPowerShellSetup/blob/master/profile.ps1) |
| Get-GitTip | function | [GitHub Gist](https://gist.github.com/jdhitsolutions/9676ec57fb28af96c08589e3e1a5b72c) | Get a random Git tip on PowerShell console startup | shorter version of the script in [helpers.psm1](https://github.com/DBremen/MyPowerShellSetup/blob/master/helpers.psm1) |
| weather | function | [Idera Power Tips](https://community.idera.com/database-tools/powershell/powertips/b/tips/posts/creating-colorful-weather-report) | Get colorful weather info from wttr.in | weather function in [helpers.psm1](https://github.com/DBremen/MyPowerShellSetup/blob/master/helpers.psm1) |
| cds | function | via helpers.psm1 | **cd** into one of the "**s**pecial folders" (e.g. Desktop, "My Documents"...) using fzf.exe (requires PSFzf module | cds function in [helpers.psm1](https://github.com/DBremen/MyPowerShellSetup/blob/master/helpers.psm1) |
| cdd | function | via helpers.psm1 | **cd** into one of the sub-**d**irectories of the current folder (requires ps-menu module) | cdd function in [helpers.psm1](https://github.com/DBremen/MyPowerShellSetup/blob/master/helpers.psm1) |
| touch | function | via helpers.psm1 | PowerShell implementation of UNIX touch | touch function in [helpers.psm1](https://github.com/DBremen/MyPowerShellSetup/blob/master/helpers.psm1) |
| s+ | function | via helpers.psm1 | Build a comma-separated list of quoted strings from the provided arguments | s+ function in [helpers.psm1](https://github.com/DBremen/MyPowerShellSetup/blob/master/helpers.psm1) |
| ql | function | via helpers.psm1 | **q**uoted **l**ist -> build string array w/o the need to provide arguments in quotes | ql function in [helpers.psm1](https://github.com/DBremen/MyPowerShellSetup/blob/master/helpers.psm1) |
| qs | function | via helpers.psm1 | **q**uoted **s**ist -> build a string based on "words" provided as an argument | qs function in [helpers.psm1](https://github.com/DBremen/MyPowerShellSetup/blob/master/helpers.psm1) |
| Get-RegExHelp | function | via helpers.psm1 | opens a .csv file with RegEx documenation via Out-GridView | Get-RegexHelp function in [helpers.psm1](https://github.com/DBremen/MyPowerShellSetup/blob/master/helpers.psm1) and [regexHelptxt.csv](https://github.com/DBremen/MyPowerShellSetup/blob/master/files/regexHelptxt.csv) |

