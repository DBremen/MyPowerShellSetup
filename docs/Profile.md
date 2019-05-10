I don't use Host or User specific profiles but the AllUsersAllHosts profile instead:

```powershell
$profile.AllUsersAllHosts
```

Host specific commands are put inside
`if ($host.Name -eq ''){}`
blocks (e.g. ConsoleHost,'Visual Studio Code Host', 'Windows PowerShell ISE Host')
The [profile](https://github.com/DBremen/MyPowerShellSetup/blog/master/profile.ps1) loads the helpers.psm1 module (for small utility functions) and the .ps1/.psm1 files in my Utils folder (for more comprehensive functions or modules), it also contains some useful PSDefaultParameterValues
