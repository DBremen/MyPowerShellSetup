## PSFZF -> PowerShell Fuzzy Finder

[PSFzF](https://github.com/kelleyma49/PSFzf) is great PowerShell wrapper around [fzf.exe](https://github.com/junegunn) I made some customizations to the module with a few more utility functions and usage of the built-in -Preview option for some of the functions with [bat.exe](https://github.com/sharkdp/bat) as the preview handler.

Customized PSFzf.psm1, PSFzf.psd1, PSFzf.Functions.ps1, and z.psm1 can be found [here](https://github.com/DBremen/MyPowerShellSetup/blob/master/PSFzf) (for module version 1.1.24)

## Additional and customized helper functions:

| Name | Alias | Description |
| --- | --- | --- |
| Invoke-FuzzyOpen | fo | Search for keyword using Everything cmd [es.exe](https://www.voidtools.com/downloads/#cli) open filtered result with default program (Invoke-Item) |
| Invoke-FuzzyEdit | fe | Search for keyword using Everything cmd [es.exe](https://www.voidtools.com/downloads/#cli) open filtered result with VSCode |
| Invoke-FuzzyZ | fz | Like Invoke-FuzzyZLocation but working with the [z](https://github.com/vincpa/z) (slight changed since it did use Format-Table for -ListFiles) Module I use |


CTRL + t = search current directory with preview window (bat.exe):


![image](https://github.com/DBremen/MyPowerShellSetup/raw/master/screens/ctrltscreen.PNG)
        
