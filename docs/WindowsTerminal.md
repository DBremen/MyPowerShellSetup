## Windows Terminal Profile

This is the place to store windows terminal specific customizations (which is still in preview at this point).

## Windows Terminal Profile

This is the place to store windows terminal specific customizations (which is still in preview at this point).

### Installation through Chocolatey to avoid Windows Store
```powershell
choco install microsoft-windows-terminal --y
```
Settings are driven through the profile JSON file ($env:LOCALAPPDATA\\Packages\Microsoft.WindowsTerminal_WEIRDNUMBER\LocalState\profiles.json) at this point.

My [profiles.json file](https://github.com/DBremen/MyPowerShellSetup/blob/master/profiles.json) contains the following customizations:
- Copy & Paste with CTRL+C and CTRL+V (as it should be)
- Powershell (5.1) profile
  - Color scheme
  - Opacity
  - Background (image file can be found [here](https://github.com/DBremen/MyPowerShellSetup/blob/master/metal.jpg), remember to adjust the path in profiles.json accordingly)
  - PowerShell 7 profile according to [this](https://briantjackett.com/2019/06/24/windows-terminal-with-powershell-v7-preview/) tutorial
  
  Instructions on how to run windows terminal as admin (until I find a better option) can be found at [http://nuts4.net/post/windows-terminal-run-as-admin](http://nuts4.net/post/windows-terminal-run-as-admin)