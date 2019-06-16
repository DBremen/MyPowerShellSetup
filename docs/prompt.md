My prompt is not too fancy (e.g. no PowerLine). It is showing:
- The current history item number (to reference in Get-History -ID)
- The execution time of the last command (see [here](https://gist.github.com/kelleyma49/bd03dfa82c37438a01b1) for the idea put in a function.)
- The git status, if inside a git repo using [posh-git](https://github.com/dahlbyk/posh-git) for git status. See also [here](PowerShellUtilities.md)
- I also added a line break to have to full length of the command line available:

![image](https://github.com/DBremen/MyPowerShellSetup/raw/master/screens/prompt.PNG)

To get the prompt, I put the following code into my profile:
```powershell
Import-Module posh-git
$promptPrefix = @'
#$((Get-History -Count 1).id + 1) $( 
    $lastCmd = Get-History -Count 1
    if ($lastCmd -ne $null) {
        $diff = $lastCmd.EndExecutionTime - $lastCmd.StartExecutionTime
        "{0}:{1}" -f [Math]::Round($diff.TotalSeconds), $diff.ToString('ff')
})$(">" * ($nestedPromptLevel)) 
'@
$GitPromptSettings.DefaultPromptPrefix = $promptPrefix
$GitPromptSettings.DefaultPromptSuffix = '`n>'
$GitPromptSettings.DefaultPromptAbbreviateHomeDirectory = $false
```

