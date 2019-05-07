I don't use Host or User specific profiles but the AllUsersAllHosts profile instead:

```powershell
$profile.AllUsersAllHosts
```

Host specific commands are put inside
`if ($host.Name -eq ''){}`
blocks (ConsoleHost,'Visual Studio Code Host', 'Windows PowerShell ISE Host')
