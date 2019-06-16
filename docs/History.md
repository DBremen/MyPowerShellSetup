## Persistent History

Even though PSReadline already features a persistent history, I like to built-in History with it's additional attributes and the format of a .csv file. Therefore I like PowerShell to automatically save the current's session history (i.e. Get-History) to a file and load it at the start of the session (this is not my idea, but I don't remember where I got if from). This is achieved by the following lines sitting my profile:
```powershell
#persistent history
$HistoryFilePath = Join-Path ([Environment]::GetFolderPath('UserProfile')) history.ps_history
$sb = [scriptblock]::Create("Get-History | Select -Unique | Export-CSV $HistoryFilePath -Append -NoTypeInformation")
Register-EngineEvent PowerShell.Exiting -Action  $sb | Out-Null
if (Test-path $HistoryFilePath) { Import-CSV $HistoryFilePath | Add-History }
```
