#helper functions
function Measure-LevenshteinDistance {
    <#
        .SYNOPSIS
            Measure the Levenshtein edit distance between two strings.
        .DESCRIPTION
            The Levenshtein Distance is a way of quantifying how dissimilar two strings (e.g., words) are to one another by counting the minimum number of operations required to transform one string into the other.
        .EXAMPLE
            Get-LevenshteinDistance 'kitten' 'sitting'
        .LINK
            http://en.wikibooks.org/wiki/Algorithm_Implementation/Strings/Levenshtein_distance#C.23
            http://en.wikipedia.org/wiki/Edit_distance
            https://communary.wordpress.com/
            https://github.com/gravejester/Communary.PASM
        .NOTES
            Author: Øyvind Kallstad
            From: https://github.com/gravejester/Communary.PASM
            Date: 07.11.2014
            Version: 1.0
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$String1,

        [Parameter(Position = 1)]
        [string]$String2,

        # Makes matches case-sensitive. By default, matches are not case-sensitive.
        [Parameter()]
        [switch] $CaseSensitive,

        # A normalized output will fall in the range 0 (perfect match) to 1 (no match).
        [Parameter()]
        [switch] $NormalizeOutput
    )

    if (-not($CaseSensitive)) {
        $String1 = $String1.ToLowerInvariant()
        $String2 = $String2.ToLowerInvariant()
    }

    $d = New-Object 'Int[,]' ($String1.Length + 1), ($String2.Length + 1)

    try {
        for ($i = 0; $i -le $d.GetUpperBound(0); $i++) {
            $d[$i, 0] = $i
        }

        for ($i = 0; $i -le $d.GetUpperBound(1); $i++) {
            $d[0, $i] = $i
        }

        for ($i = 1; $i -le $d.GetUpperBound(0); $i++) {
            for ($j = 1; $j -le $d.GetUpperBound(1); $j++) {
                $cost = [Convert]::ToInt32((-not($String1[$i - 1] -ceq $String2[$j - 1])))
                $min1 = $d[($i - 1), $j] + 1
                $min2 = $d[$i, ($j - 1)] + 1
                $min3 = $d[($i - 1), ($j - 1)] + $cost
                $d[$i, $j] = [Math]::Min([Math]::Min($min1, $min2), $min3)
            }
        }

        $distance = ($d[$d.GetUpperBound(0), $d.GetUpperBound(1)])

        if ($NormalizeOutput) {
            Write-Output (1 - ($distance) / ([Math]::Max($String1.Length, $String2.Length)))
        }

        else {
            Write-Output $distance
        }
    }

    catch {
        Write-Warning $_.Exception.Message
    }
}

function Find-ClosestCommand {
    <#
        .SYNOPSIS
            Find the most similar command (based on edit distance)
        .DESCRIPTION
            Uses Levenshtein distance to determine the command with the closest name. Returns that command with a NoteProperty detailing the `Distance`.
        .EXAMPLE
            Find-ClosestCommand gct -ListImported
            Will find 'gc' (the alias to 'Get-Content'), without searching commands from modules that haven't been imported.
            The -ListImported switch can make a huge difference in search time, because it doesn't consider modules that aren't already imported.
    #>
    [CmdletBinding()]
    param(
        # The name of the command to search for
        [Parameter(Mandatory)]
        [string]$Name,

        # If set, ignores commands in modules that aren't already imported (making the search much faster)
        [switch]$ListImported,

        # Limit the search to certain command types (defaults to all)
        [System.Management.Automation.CommandTypes]$CommandType = "All"
    )
    begin {
        $closest = @{ Distance = [int]::MaxValue }
    }
    process {
        foreach ($Command in Get-Command -ListImported:$ListImported -CommandType:$CommandType) {
            $Distance = Measure-LevenshteinDistance $command.Name $Name

            if ($Distance -le 1) {
                # Shortcut for the closest we can get
                $Command |
                Add-Member -NotePropertyName Distance -NotePropertyValue 1 -PassThru -Force
                break
            }
            if ($closest.Distance -gt $Distance) {
                $closest.Distance = $Distance
                $closest.Command = $command
            }
        }
    }
    end {
        if ($Distance -gt 1) {
            $Closest.Command |
            Add-Member -NotePropertyName Distance -NotePropertyValue $closest.Distance -PassThru -Force
        }
    }
}

function Get-GitTip {
    $path = "$PSScriptRoot\tools\tips\tips.json"
    $title = @"
**********************
* Git Tip of The Day *
**********************
"@
    Write-Host $title

    #Get all of the tips
    Get-Content -path $path | ConvertFrom-Json |
    Get-Random -Count 1 |
    ForEach-Object {
        Write-Host "$($_.Title):"
        Write-Host $_.tip -BackgroundColor Black
    }
}

function weather ($Location = "53.4345597,-6.3795018") {
    (Invoke-WebRequest "http://wttr.in/$location" -UserAgent curl).content -split "`n"
}


function cds {
    Set-Location ([System.Enum]::GetNames([System.Environment+SpecialFolder]) | fzf.exe | ForEach-Object { [System.Environment]::GetFolderPath($_) })
}

function cdd {
    $path = PSMenu ((Get-ChildItem -Directory).Name)
    if ($path) {
        Set-Location $path
    }
}

function touch([string]$path) {
    Set-Content -Path $path -value $null;
}

function s+ { "'$($args -join "','")'" }
function ql { $args }
function qs { "$args" }
#ql = build string array without using quotation marks
#qs = build string of words without using quotation marks
#s+ = build comma-separated list of quoted strings

function pro {
    code.cmd C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1 -r
}

function Get-RegexHelp {
    Import-Csv "$PSScriptRoot\files\regexHelptxt.csv" | Out-GridView
    #ii "http://regexrenamer.sourceforge.net/help/regex_quickref.html"
}

Export-ModuleMember -Function * -Alias *