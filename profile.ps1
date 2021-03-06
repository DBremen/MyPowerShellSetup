﻿
$scriptDir = "$env:USERPROFILE\Scripts\ps1"

if ($host.Name -eq 'Windows PowerShell ISE Host') {
    Import-Module "$scriptDir\ISEUtils\ISEUtils.psm1"
    Import-Module "$scriptDir\Scripts\ps1\ISERegex"
    $null = $psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add('ISERegex', { Start-ISERegex }, $null)
}

$PSDefaultParameterValues.Add("Get-ChildItem:Force", $true)
$PSDefaultParameterValues.Add("Receive-Job:Keep", $true)
$PSDefaultParameterValues.Add("Format-Table:AutoSize", $true)
$PSDefaultParameterValues.Add("Import-Module:Force", $true)
$PSDefaultParameterValues.Add('Export-Csv:NoTypeInformation', $true)
$PSDefaultParameterValues.Add('Get-Member:Force', $true)
$PSDefaultParameterValues.Add('Format-List:Property', '*')
$PSDefaultParameterValues.Add('Set-Location:Path', '..')

Update-TypeData -TypeName System.String -MemberName "ToB64" -MemberType ScriptProperty -Value { [System.Convert]::ToBase64String([System.Text.Encoding]::UNICODE.GetBytes($this)) }
Update-TypeData -TypeName System.String -MemberName "SplitUrl" -MemberType ScriptProperty -Value {
    $urls = $this -split '\r?\n'
    Add-Type -AssemblyName System.Web
    foreach ($url in $urls) {
        $txt = [System.Web.HttpUtility]::UrlDecode($url)
        $txt -split '\?|\&'
        write-host '_____________________________________'
    }
}
Update-TypeData -TypeName System.String -MemberName "JoinWithQuote" -MemberType ScriptProperty -Value {
    $result = ($this -split '\r?\n' | foreach { "'$_'" }) -join ','
    $result
    $result | set-clipboard
}

Remove-Item alias:cat -Force
Set-Alias -Name cat -Value bat -Force
# in case show-ui is used
Remove-Item alias:menu -Force -ErrorAction SilentlyContinue
Import-Module "$scriptDir\Utils\Utils.psm1" -DisableNameChecking
Import-Module PSColor
Import-Module "$scriptDir\helpers.psm1" -DisableNameChecking
Import-Module PS-Menu

#persistent history
$HistoryFilePath = Join-Path ([Environment]::GetFolderPath('UserProfile')) history.ps_history
$sb = [scriptblock]::Create("Get-History | Select -Unique | Export-CSV $HistoryFilePath -Append -NoTypeInformation")
Register-EngineEvent PowerShell.Exiting -Action  $sb | Out-Null
if (Test-Path $HistoryFilePath) { Import-Csv $HistoryFilePath | Add-History }

if ($host.Name -eq 'ConsoleHost' -or 'Visual Studio Code Host' ) {
    [Console]::OutputEncoding = [Text.UTF8Encoding]::UTF8
    Import-Module PSFzf -ArgumentList 'Ctrl+t', 'Ctrl+r' # or replace these strings with your preferred bindings
    Import-Module PS-Menu
    Import-Module PSReadline
    # PSReadLine Configuration goes here
    Set-Alias -Name ff -Value Invoke-Fzf
}

#did you mean? implementation
if ($host.Name -eq 'ConsoleHost') {
    $ExecutionContext.InvokeCommand.CommandNotFoundAction = {
        param($Name, $EventArgs)

        $lastCommand = Get-Content ((Get-PSReadlineOption).HistorySavePath) -Tail 1


        if ($lastCommand -match ([regex]::Escape($Name))) {
            $Result = Find-ClosestCommand $Name -ListImported

            switch ($Host.UI.PromptForChoice(
                    "Command not found '$Name'",
                    "Did you mean '$Result'?",
                    [System.Management.Automation.Host.ChoiceDescription[]]("&Yes", "&Always", "&No"), 0)) {
                2 {
                    # Nope
                    break
                }
                1 {
                    # Always
                    Set-Alias $Name $Result -Scope Global -Description "Set by user choice from CommandNotFoundAction"
                }
                { $_ -lt 2 } {
                    $EventArgs.Command = $Result
                    $EventArgs.StopSearch = $true
                }
            }
        }
    }
}
Set-ConsoleTheme 'Material Darker'
$host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size(190,5000)
cd "$env:USERPROFILE\Desktop"; Clear-Host; quote -Random
$script:exanpdArchive = Expand-ArchiveAutomamtically
"`n`n"
Get-GitTip
