#.ExternalHelp PSFzf.psm1-help.xml

$addedAliases = @()
function script:SetPsFzfAlias {
    param($Name,$Function)

    # prevent Get-Command from loading PSFzf
    $script:PSModuleAutoLoadingPreferencePrev=$PSModuleAutoLoadingPreference
    $PSModuleAutoLoadingPreference='None'

    if (-not (Get-Command -Name $Name -ErrorAction Ignore)) {
        New-Alias -Name $Name -Scope Global -Value $Function -ErrorAction Ignore
        $addedAliases += $Name
    }    

    # restore module auto loading
    $PSModuleAutoLoadingPreference=$script:PSModuleAutoLoadingPreferencePrev
}

function script:RemovePsFzfAliases {
    $addedAliases | ForEach-Object {
        Remove-Item -Path Alias:$_
    }
}

$esPath = 'C:\Program Files*\es\es.exe'
if ((Test-Path (Resolve-Path $esPath).Path)) {
    function Invoke-FuzzyEdit() {
        param($SearchTerm)

        $files = @()
        try {
            & (Resolve-Path 'C:\Program Files*\es\es.exe').Path $SearchTerm |
                Invoke-Fzf -Multi | ForEach-Object { $files += """$_""" }
        }
        catch {
        }
        finally {
            if ($prevDir) {
                cd $prevDir
            }
        }

        # HACK to check to see if we're running under Visual Studio Code.
        # If so, reuse Visual Studio Code currently open windows:
        $editorOptions = ''
        if ($env:VSCODE_PID -ne $null) {
            $editor = 'code'
            $editorOptions += '--reuse-window'
        }
        else {
            $editor = $env:EDITOR
            if ($editor -eq $null) {
                if (!$IsWindows) {
                    $editor = 'vim'
                }
                else {
                    $editor = 'code'
                }
            }
        }

        if ($files -ne $null) {
            Invoke-Expression -Command ("$editor $editorOptions {0}" -f ($files -join ' '))
        }
    }

    SetPsFzfAlias "fe" Invoke-FuzzyEdit

    function Invoke-FuzzyOpen() {
        param($SearchTerm)

        $files = @()
        try {
            & (Resolve-Path 'C:\Program Files*\es\es.exe').Path $SearchTerm |
                Invoke-Fzf -Multi | ForEach-Object { $files += $_ }
        }
        catch {
        }
        finally {
            if ($prevDir) {
                cd $prevDir
            }
        }

        if ($files -ne $null) {
            foreach ($file in $files) {
                ii $file.Trim()
            }
        }
    }

    SetPsFzfAlias "fo" Invoke-FuzzyOpen
}

if (Get-Command Get-Frecents -ErrorAction SilentlyContinue) {
    #.ExternalHelp PSFzf.psm1-help.xml
    function Invoke-FuzzyFasd() {
        $result = $null
        try {
            Get-Frecents | ForEach-Object { $_.FullPath } | Invoke-Fzf -ReverseInput -NoSort | ForEach-Object { $result = $_ }
        }
        catch {

        }
        if ($result -ne $null) {
            # use cd in case it's aliased to something else:
            cd $result
        }
    }
    SetPsFzfAlias "ff" Invoke-FuzzyFasd
}
elseif (Get-Command fasd -ErrorAction Ignore) {
    #.ExternalHelp PSFzf.psm1-help.xml
    function Invoke-FuzzyFasd() {
        $result = $null
        try {
            fasd -l | Invoke-Fzf -ReverseInput -NoSort | ForEach-Object { $result = $_ }
        } catch {
            
        }
        if ($null -ne $result) {
            # use cd in case it's aliased to something else:
            cd $result
        }
    }
    SetPsFzfAlias "ff" Invoke-FuzzyFasd
}

#.ExternalHelp PSFzf.psm1-help.xml
function Invoke-FuzzyHistory() {
    $result = Get-History | ForEach-Object { $_.CommandLine } | Invoke-Fzf -Reverse -NoSort
    if ($null -ne $result) {
        Write-Output "Invoking '$result'`n"
        Invoke-Expression "$result" -Verbose
    }
}
SetPsFzfAlias "fh" Invoke-FuzzyHistory

#.ExternalHelp PSFzf.psm1-help.xml
function Invoke-FuzzyKillProcess() {
    $result = Get-Process | Where-Object { ![string]::IsNullOrEmpty($_.ProcessName) } | ForEach-Object { "{0}: {1}" -f $_.Id,$_.ProcessName } | Invoke-Fzf -Multi
    $result | ForEach-Object {
        $id = $_ -replace "([0-9]+)(:)(.*)",'$1' 
        Stop-Process $id -Verbose
    }
}
SetPsFzfAlias "fkill" Invoke-FuzzyKillProcess

#.ExternalHelp PSFzf.psm1-help.xml
function Invoke-FuzzySetLocation() {
    param($Directory=$null)

    if ($null -eq $Directory) { $Directory = $PWD.Path }
    $result = $null
    try {
        if ([string]::IsNullOrWhiteSpace($env:FZF_DEFAULT_COMMAND)) {
            Get-ChildItem $Directory -Recurse -ErrorAction Ignore | Where-Object{ $_.PSIsContainer } | Invoke-Fzf | ForEach-Object { $result = $_ }
        } else {
            Invoke-Fzf | ForEach-Object { $result = $_ }
        }
    } catch {
        
    }

    if ($null -ne $result) {
        Set-Location $result
    } 
}
SetPsFzfAlias "fd" Invoke-FuzzySetLocation

if (Get-Command Search-Everything -ErrorAction Ignore) {
    #.ExternalHelp PSFzf.psm1-help.xml
    function Set-LocationFuzzyEverything() {
        param($Directory=$null)
        if ($null -eq $Directory) {
            $Directory = $PWD.Path
            $Global = $False
        } else {
            $Global = $True
        }
        $result = $null
        try {
            Search-Everything -Global:$Global -PathInclude $Directory -FolderInclude @('') | Invoke-Fzf | ForEach-Object { $result = $_ }
        } catch {
            
        }
        if ($null -ne $result) {
            # use cd in case it's aliased to something else:
            cd $result
        }
    }
    SetPsFzfAlias "cde" Set-LocationFuzzyEverything 
}

if (Get-Command z -ErrorAction SilentlyContinue) {
    #.ExternalHelp PSFzf.psm1-help.xml
    function Invoke-FuzzyZ() {
        $result = $null
        try {
            ((z -ListFiles) | Sort-Object Rank -Descending).Path | Invoke-Fzf -NoSort | ForEach-Object { $result = $_ }
        }
        catch {

        }
        if ($result -ne $null) {
            cd $result
        }
    }

    SetPsFzfAlias "fz" Invoke-FuzzyZ
}

if (Get-Command git -ErrorAction Ignore) {
    #.ExternalHelp PSFzf.psm1-help.xml
    function Invoke-FuzzyGitStatus() {
        $result = @()
        try {
            $gitRoot = git rev-parse --show-toplevel
            git status --porcelain | Invoke-Fzf -Multi -Bind 'ctrl-a:select-all,ctrl-d:deselect-all,ctrl-t:toggle-all' | ForEach-Object { $result += Join-Path $gitRoot $('{0}' -f $_.Substring('?? '.Length)) }
        } catch {
            # do nothing
        }
        if ($null -ne $result) {
            $result
        }
    }
    SetPsFzfAlias "fgs" Invoke-FuzzyGitStatus
}
