using namespace System
using namespace System.Management.Automation.Language
using namespace Microsoft.PowerShell
if ($host.Name -eq 'ConsoleHost' -or  $host.Name -eq 'Visual Studio Code Host' ) {
    Import-Module PSReadline -RequiredVersion 2.2.0
    Set-PSReadLineOption -EditMode Windows
    if ($host.Version.Major -eq 7){
        Set-PSReadLineOption -PredictionSource HistoryAndPlugin
    }
    else{
        Set-PSReadLineOption -PredictionSource History
    }
    Set-PSReadLineOption -Colors @{InlinePrediction = "$([char]0x1b)[36;7;238m]"}
    Set-PSReadLineKeyHandler -Function AcceptSuggestion -Key 'ALT+r'
	Set-PSReadlineOption -PromptText "$("$([char]27)")[22;38;5;15;48;5;34m>_$("$([char]27)")[0m","$("$([char]27)")[22;38;5;15;48;5;13m>_$("$([char]27)")[0m"
    [Console]::OutputEncoding = [Text.UTF8Encoding]::UTF8
    Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadlineOption -BellStyle None
    Set-PSReadlineKeyHandler -Chord CTRL+9 -Function GotoBrace
    Set-PSReadlineKeyHandler -Chord Ctrl+A `
        -BriefDescription SelectEntireCommandLine `
        -Description "Selects the entire command line" `
        -ScriptBlock {
        param($key, $arg)

        [Microsoft.PowerShell.PSConsoleReadLine]::BeginningOfLine($key, $arg)

        $line = $null
        $cursor = $null
        [Microsoft.PowerShell.PSConsoleReadline]::GetBufferState([ref]$line, [ref]$cursor)

        while ($cursor -lt $line.Length) {
            [Microsoft.PowerShell.PSConsoleReadLine]::SelectForwardChar($key, $arg)
            [Microsoft.PowerShell.PSConsoleReadline]::GetBufferState([ref]$line, [ref]$cursor)
        }
    }
    <#Set-PSReadlineKeyHandler -Key Ctrl+D -BriefDescription Get-Process -LongDescription "Example on how to assign shortcut keys" -ScriptBlock {
			  [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine	#go back
			  [Microsoft.PowerShell.PSConsoleReadLine]::Insert("psscript;cd internet;.\get-downloadstats.ps1")	#inset commands
			  [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()	#press Enter
	}#>

    # Sometimes you want to get a property of invoke a member on what you've entered so far
    # but you need parens to do that.  This binding will help by putting parens around the current selection,
    # or if nothing is selected, the whole line.
    Set-PSReadlineKeyHandler -Key 'Alt+9' `
        -BriefDescription ParenthesizeSelection `
        -LongDescription "Put parenthesis around the selection or entire line and move the cursor to after the closing parenthesis" `
        -ScriptBlock {
        param($key, $arg)

        $selectionStart = $null
        $selectionLength = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)

        $line = $null
        $cursor = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
        if ($selectionStart -ne -1) {
            [Microsoft.PowerShell.PSConsoleReadLine]::Replace($selectionStart, $selectionLength, '(' + $line.SubString($selectionStart, $selectionLength) + ')')
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selectionStart + $selectionLength + 2)
        }
        else {
            [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $line.Length, '(' + $line + ')')
            [Microsoft.PowerShell.PSConsoleReadLine]::EndOfLine()
        }
    }

    Set-PSReadlineOption -CommandValidationHandler {
        param([CommandAst]$CommandAst)

        switch ($CommandAst.GetCommandName()) {
            'git' {
                $gitCmd = $CommandAst.CommandElements[1].Extent
                switch ($gitCmd.Text) {
                    'cmt' {
                        [Microsoft.PowerShell.PSConsoleReadLine]::Replace(
                            $gitCmd.StartOffset, $gitCmd.EndOffset - $gitCmd.StartOffset, 'commit')
                    }
                }
            }
        }
    }
    # Each time you press Alt+', this key handler will change the token
    # under or before the cursor.  It will cycle through single quotes, double quotes, or
    # no quotes each time it is invoked.
    Set-PSReadlineKeyHandler -Key "Alt+2" `
        -BriefDescription ToggleQuoteArgument `
        -LongDescription "Toggle quotes on the argument under the cursor" `
        -ScriptBlock {
        param($key, $arg)

        $ast = $null
        $tokens = $null
        $errors = $null
        $cursor = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)

        $tokenToChange = $null
        foreach ($token in $tokens) {
            $extent = $token.Extent
            if ($extent.StartOffset -le $cursor -and $extent.EndOffset -ge $cursor) {
                $tokenToChange = $token

                # If the cursor is at the end (it's really 1 past the end) of the previous token,
                # we only want to change the previous token if there is no token under the cursor
                if ($extent.EndOffset -eq $cursor -and $foreach.MoveNext()) {
                    $nextToken = $foreach.Current
                    if ($nextToken.Extent.StartOffset -eq $cursor) {
                        $tokenToChange = $nextToken
                    }
                }
                break
            }
        }

        if ($tokenToChange -ne $null) {
            $extent = $tokenToChange.Extent
            $tokenText = $extent.Text
            if ($tokenText[0] -eq '"' -and $tokenText[-1] -eq '"') {
                # Switch to no quotes
                $replacement = $tokenText.Substring(1, $tokenText.Length - 2)
            }
            elseif ($tokenText[0] -eq "'" -and $tokenText[-1] -eq "'") {
                # Switch to double quotes
                $replacement = '"' + $tokenText.Substring(1, $tokenText.Length - 2) + '"'
            }
            else {
                # Add single quotes
                $replacement = "'" + $tokenText + "'"
            }

            [Microsoft.PowerShell.PSConsoleReadLine]::Replace(
                $extent.StartOffset,
                $tokenText.Length,
                $replacement)
        }
    }
	
	# adapted version of https://github.com/PowerShell/PSReadLine/issues/1593
	$setPSReadLineKeyHandlerSplat = @{
		Chord = 'ctrl+v'
		BriefDescription = 'SmartPaste'
		Description = (
			'If pasting a string containing \ or / surround with quotes and escape. ' +
			'Otherwise paste normally.')
		ScriptBlock = {
			param([Nullable[ConsoleKeyInfo]] $key, [object] $arg) end {

				$clipText = Get-Clipboard

				# Use Regex.IsMatch to avoid changing global `$matches` variable.
				if ([regex]::IsMatch($clipText, '^(?<quote>''|").*\k<quote>$')) {
					[PSConsoleReadLine]::Paste($key, $arg)
					return
				}

				if ( !$clipText.Contains(' ') -or (!$clipText.Contains('\') -and !$clipText.Contains('/'))) {
					[PSConsoleReadLine]::Paste($key, $arg)
					return
				}

				[PSConsoleReadLine]::Insert("'")

				if ($clipText.Contains("'")) {
					[PSConsoleReadLine]::Insert(($clipText -replace "([\u2018\u2019\u201a\u201b'])", '$1$1'))
				} else {
					[PSConsoleReadLine]::Paste($key, $arg)
				}

				[PSConsoleReadLine]::Insert("'")
			}
		}
	}

	Set-PSReadLineKeyHandler @setPSReadLineKeyHandlerSplat
    Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadlineOption -HistorySearchCursorMovesToEnd
    
}