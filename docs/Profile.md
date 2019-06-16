## Profile

I don't use Host or User specific profiles but the AllUsersAllHosts profile instead:

```powershell
$profile.AllUsersAllHosts
```

Host specific commands are put inside
`if ($host.Name -eq ''){}`
blocks (e.g. ConsoleHost,'Visual Studio Code Host', 'Windows PowerShell ISE Host')
The [profile](https://github.com/DBremen/MyPowerShellSetup/blog/master/profile.ps1) imports/contains:
- Imports helpers.psm1 module (for small utility functions)
- The .ps1/.psm1 files in my Utils folder (for more comprehensive functions or modules)
- Contains some useful PSDefaultParameterValues
- Loads the PSReadLine Configuration
- Imports any other module/function that I'd like to be available in my PowerShell sessions
