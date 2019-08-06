## PSReadline

Make sure latest version is installed:


```powershell
# Make sure all powershell instances are closed
gps powershell* | kill
# Run below from "Run prompt" Windows-Key + R
powershell -noprofile -command "Install-Module PSReadLine -Force -SkipPublisherCheck -allowprerelease"  
```

Configuration loaded via profile [PSReadLine configuration](https://github.com/DBremen/MyPowerShellSetup/blob/master/PSReadlineConfiguration.ps1)
