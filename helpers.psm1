#helper functions
function lcurl {
    [CmdletBinding()]
    Param
    (
        [parameter(mandatory = $false, position = 1, ValueFromRemainingArguments = $true)]$Remaining
    )


    $arguments = [regex]::Split($Remaining, ' (?=(?:[^"]|"[^"]*")*$)' )

    & 'C:\Windows\SysWOW64\curl.exe' $arguments


}

function Start-Conda{
	& 'C:\Users\Dirk\Anaconda3\shell\condabin\conda-hook.ps1' ; conda activate 'C:\Users\Dirk\Anaconda3'
}
function ConvertTo-Hashtable{
    param
    (
        [Parameter(Mandatory,ValueFromPipeline)]
        $object,

        [Switch]
        $ExcludeEmpty
    )

    process
    {
        $object.PSObject.Properties | 
        # sort property names
        Sort-Object -Property Name |
        # exclude empty properties if requested
        Where-Object { $ExcludeEmpty.IsPresent -eq $false -or $_.Value -ne $null } |
        ForEach-Object { 
            $hashtable = [Ordered]@{}} { 
            $hashtable[$_.Name] = $_.Value 
            } { 
            $hashtable 
            } 
    }
}
function weather ($Location = "53.4345597,-6.3795018") {
    (Invoke-WebRequest "http://wttr.in/$location" -UserAgent curl).content -split "`n"
}

function Get-LogonAttempts{
    Get-WinEvent -FilterHashtable @{LogName='security';Id=4625,4624;StartTime=(Get-Date).AddDays(-1)} | 
    Group {if ($_.Id -eq 4624){'Success'}else{'Failure'}},{$_.TimeCreated.ToString('ddd')},{$_.TimeCreated.ToString('HH:00')} |
    sort Name
}

function rout {
 'Joshuita@home' | Set-Clipboard
}

function Get-GalleryUpdates{
    Find-Module | 
        where {$_.PublishedDate.Date -eq [datetime]::today -or $_.UpdatedDate -eq [datetime]::today} | 
        select Name, ProjectUri, Author, Description | ogv
}

function cdd { 
    $path = menu ((dir -Directory).Name)
    if ($path){
        cd $path
    }
}

function Pivot-Object
{
    param
    (
        [Parameter(Mandatory,ValueFromPipeline)]
        $object,
 
        [string]
        $PropertyName = "Property",
 
        [string]
        $ValueName = "Value"
    )
 
    process
    {
    $object | 
        Get-Member -MemberType *Property | 
        Select-Object -ExpandProperty Name |
        Sort-Object |
        ForEach-Object { [PSCustomObject]@{ 
            $PropertyName = $_
            $ValueName = $object.$_} 
        }
    }
}

function cds{
    Set-Location ([System.Enum]::GetNames([System.Environment+SpecialFolder]) | fzf | ForEach-Object{[System.Environment]::GetFolderPath($_)})
}


function weather ($Location="/~dublin+ireland"){
    (Invoke-WebRequest "http://wttr.in/$location" -UserAgent curl).content -split "`n"
}




function Out-Excel{  
  param  
  (  
    $Path = "$env:TEMP\$(Get-Random).csv"  
  )  
 
  $Input | Export-Csv -Path $Path -Encoding UTF8 -NoTypeInformation -UseCulture  
  Invoke-Item -Path $Path  
}


function Install-Nuget($package,$Destination=$PWD){
    Install-Package -Name $package -ProviderName NuGet -Source 'https://www.nuget.org/api/v2' -Destination $Destination
}

function Find-Nuget($pattern){
    Find-Package -ProviderName NuGet $pattern -Source 'https://www.nuget.org/api/v2'
}

function PickFile 
([string]$Path = $PWD)
{
    $results = Get-ChildItem $Path | Out-GridView -PassThru

    if ($results.Count -eq 1 -and $results.PSIsContainer)
    {
        PickFile $results.FullName
    }
    else
    {
        Write-Output -InputObject $results
    }
}
Set-Alias -Name pick -Value PickFile

#needs diff2html-cli npm package (needs node for windows)
function Show-Changes{
    diff2html -s line -f html -d word -i command -o preview -- -M HEAD~1
}



function Get-AutoStart{
    Get-CimInstance -ClassName Win32_StartupCommand | Select-Object -Property Name, Location, User, Command, Description | ogv
}

function Get-WeekEnding($date=(get-date)){
	for($i=0; $i -le 6; $i++){        
	    if($date.AddDays($i).DayOfWeek -eq 'Sunday')
	    {
	        $date.AddDays($i).ToString('WE dd-MMM-yyyy') | clip
	        break
	    }
	}
}


function standby{
    psshutdown -d -t 0
}

<#
Function prompt {
  $(if (test-path variable:/PSDebugContext) { '[DBG]: ' } else { '' }) + 
    "#$([Math]::abs($MyInvocation.HistoryID)) PS$($PSVersionTable.PSVersion.Major) " + $(Get-Location) + 
    $(if ($nestedpromptlevel -ge 1) { '>>' }) + '> '
}
#>


function cap{
    ipmo C:\Scripts\ps1\misc\PSImaging\PSImaging.dll
    $txt = (Export-ImageText -Path C:\scripts\pic.png) -replace ' ','' -replace "\'\|","T" -replace "'" 
    $txt | clip
    $txt

}

function excel($path) {& (Resolve-Path 'c:\Program Files*\Microsoft Office\*\Office*\Excel.exe').Path "$path"}
function Lock-PC{
	 $shell = New-Object -com "Wscript.Shell"
	 $shell.Run("%windir%\System32\rundll32.exe user32.dll,LockWorkStation")
}

function npp($file) {
  if($file){
    & (Resolve-Path 'c:\Program Files*\Notepad++\notepad++.exe').Path "$file"
  } else {
    & (Resolve-Path 'c:\Program Files*\Notepad++\notepad++.exe').Path "$input"
  }
}
#function npp {& 'C:\Program Files (x86)\Notepad++\notepad++.exe' $args}	

filter Get-FileSize {
	"{0:N2} {1}" -f $(
	if ($_ -lt 1kb) { $_, 'Bytes' }
	elseif ($_ -lt 1mb) { ($_/1kb), 'KB' }
	elseif ($_ -lt 1gb) { ($_/1mb), 'MB' }
	elseif ($_ -lt 1tb) { ($_/1gb), 'GB' }
	elseif ($_ -lt 1pb) { ($_/1tb), 'TB' }
	else { ($_/1pb), 'PB' }
	)
}
#search with everything commandline 
function search {
    $arguments=$args -split ' '
	$flags="-folder","-open","-path","-object", "-raw"
	foreach ($item in $flags){
		if($arguments -contains $item){
			$arguments=$arguments -ne $item
			$flag=$item.SubString(1)
			break
		}
    }
	$result=& "C:\Program Files (x86)\es\es.exe" $arguments
    if($result.Count -gt 1){
       #$result=$result | Out-GridView -PassThru
    }
    switch ($flag){
        "raw" { $result }
		"path" { $result | clip }
		"open" { & "$result" }
		"folder" {  & "explorer.exe" /select,"$result" }
		"object" { $result | Get-ItemProperty -ErrorAction SilentlyContinue }
		default { $result | Get-ItemProperty -ErrorAction SilentlyContinue | select Name,DirectoryName,@{Name="Size";Expression={$_.Length | Get-FileSize }},LastWriteTime}
    }
}


#CTRL+ALT+DELETE to unblock
function Block-Keyboard {
	$signature = @"
	  [DllImport("user32.dll")]
	  public static extern bool BlockInput(bool fBlockIt);
"@
	$block = Add-Type -MemberDefinition $signature -Name DisableInput -Namespace DisableInput -PassThru
	$block::BlockInput($true)
}
#get quoted list
function s+ { "'$($args -join "','")'"  }
function ql{$args}
function qs{"$args"}
#ql = build string array without using quotation marks
#qs = build string of words without using quotation marks
#s+ = build comma-separated list of quoted strings

function dots($filename){. $pwd\$filename.ps1}#usage . dots filename
set-alias gh get-help
#. C:\Scripts\ps1\dev\Dev.Get-MSDNInfo.ps1
function pro {ise "$([Environment]::GetFolderPath('MyDocuments'))\WindowsPowerShell\profile.ps1"}
function notepad{$args | % { notepad.exe (resolve-path $_)}}
function psscript {cd c:\scripts\ps1}
<#
Update-TypeData  -force -TypeName System.IO.FileInfo -MemberName Length -MemberType ScriptProperty -Value { 
    $this.length | Get-FileSize
 } 
 
 Update-TypeData -force -TypeName System.IO.FileInfo -DefaultDisplayPropertySet Mode,LastWriteTime,Length,Name

 Update-TypeData  -force -TypeName System.IO.DirectoryInfo -MemberName foo -MemberType ScriptProperty -Value { 
    $objFSO = New-Object -com  Scripting.FileSystemObject
	$folder=$objFSO.GetFolder($this.FullName)
	if ($folder.SubFolders.Count -eq 0){
		$s = $folder.Size 
        "{0:N2} {1}" -f $(
			if ($s -lt 1kb) { $s, 'B' }
			elseif ($s -lt 1mb) { ($s/1kb), 'KB' }
			elseif ($s -lt 1gb) { ($s/1mb), 'MB' }
		)
	}
	else{
		$s = ($folder.SubFolders | Measure-Object Size -Sum).Sum
        "{0:N2} {1}" -f $(
			if ($s -lt 1kb) { $s, 'B' }
			elseif ($s -lt 1mb) { ($s/1kb), 'KB' }
			elseif ($s -lt 1gb) { ($s/1mb), 'MB' }
		)
	}
 } 
 Update-TypeData -force -TypeName System.IO.DirectoryInfo -DefaultDisplayPropertySet Mode,LastWriteTime,Length,Name
 
 #>
 

function Get-RegexHelp{
	Import-Csv "C:\Scripts\ps1\string\regexHelptxt.csv" | ogv
	#ii "http://regexrenamer.sourceforge.net/help/regex_quickref.html"
}

function Format-XML {
    Param   ( 
                [parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName="Path",Mandatory=$true )][Alias('FullName')]
                $Path,
                [parameter(ValueFromPipeLine= $true,ParameterSetName="Pipe",Mandatory=$true, position=0)][Alias('Text')]
                $InputObject   
    )
  
    begin   {#to cope with multiple items being piped we will assemble blocks of XML or Lumps of text in the process block and output them in the end block
                [xml[]]$xmlblocks = @() 
                [String[]]$text   = @()     
    }
    process {
                #Catch file names; if text is not a file name assume it is going to be XML   
                if    (($InputObject -is [string]) -and ($null -eq $Path) -and (Test-Path -Path $InputObject -ErrorAction SilentlyContinue)) {
                        $Path        =   $InputObject
                        $InputObject =   $null
                } 
                #Read XML File(s) specified via $path
                if     ($Path) { Resolve-Path -Path $Path -ErrorAction silentlycontinue | ForEach-Object { $xmlblocks += [xml](Get-Content -Path $_) } }
                #If input was a file object read XML from it                 
                elseif ($InputObject -is [System.IO.FileInfo]){
                        $doc = New-Object -TypeName System.Xml.XmlDataDocument
                        $doc.Load($InputObject)
                        $xmlblocks += $doc
                }
                #if input was already XML don't turn it back into text
                elseif ($InputObject -is [XML])               {$xmlblocks += $InputObject}
                #If input was text and not a path build up one big blok of text to convert at the end. 
                else                                          {$text      += $InputObject}
    }
    end     { 
                #If the process block assembled something in $Text, convert it to XML 
                if ($text) {$xmlblocks += [xml]$text }   

                #And now output the XML blocks - we need a couple of objects
                $sw     = New-Object -TypeName System.IO.StringWriter
                $writer = New-Object -TypeName System.Xml.XmlTextWriter -ArgumentList $sw -Property @{"Formatting" = [System.Xml.Formatting]::Indented } 
                foreach ($doc in $xmlblocks) {
                         $doc.WriteContentTo($writer) 
                         $sw.ToString() 
                }
    }
}        




function Search-ReplaceText{
	param(
	[Parameter(ValueFromPipeline=$true)]$files=(dir "$(Join-Path $env:HOMEDRIVE $env:HOMEPATH)\Dropbox\Scripts\ps1\get-stats" -rec -include ("*.ps1","*.psm1")),
	[Parameter(Position=1)]$searchString,
	[Parameter(Position=2)]$replaceString,
	[Parameter(Position=3)][switch]$replace,
    [Parameter(Position=4)][switch]$updatePW)
	
	begin{
		filter ColorPattern( [string]$Pattern, [ConsoleColor]$Color, [switch]$SimpleMatch ) {
			  if( $SimpleMatch ) { $Pattern = [regex]::Escape( $Pattern ) }

			  $split = $_ -split $Pattern
			  $found = [regex]::Matches( $_, $Pattern, 'IgnoreCase' )
			  for( $i = 0; $i -lt $split.Count; ++$i ) {
			    Write-Host $split[$i] -NoNewline
			    Write-Host $found[$i] -NoNewline -ForegroundColor $Color
			  }

			  Write-Host
		}
        if ($updatePW){
            $files = (dir "C:\Repository\get-stats" -rec -include ("*.ps1","*.psm1"))
        }

		$searchString=[regex]::Escape($searchString)
		$overallCount=0
	}
	process{
		$files | Select-String -Pattern $searchString | select Path,Line,LineNumber | group Path | foreach {
			$count=0
			$_.group | Add-Member -MemberType NoteProperty -Name "NewLine" -Value "" 
			$_.group | foreach {
				if ($replace){$_.Path="  " + (Split-Path -Leaf -Path $_.Path)}
				$_.Line=$_.Line.Trim()
				$_.NewLine=$_.Line -replace "$searchString","$replaceString"
				if (!$count){
					$_.Path=$_.Path.Trim()
				}
				$count++
			}
			$overallCount+=$count
			If ($host.Name -eq "ConsoleHost" -and $replace){ $_.Group | Out-String | ColorPattern "$replaceString" -Color Green -SimpleMatch }
			elseif ($host.Name -eq "ConsoleHost" -and -not $replace){ $_.Group | fl }
			else { $_.Group }
				
		}
		
		if ($replace){
			$files | Select-String -List "$searchString" | select Path | %{
				(Get-Content $_.Path) -replace "$searchString","$replaceString" | Set-Content $_.Path
			}
		}
		
	}
	end{
		if ($replace -and $overallCount -gt 0){
			Write-Host "`n`nReplaced $($overAllCount+1) occurences of $([regex]::UnEscape($searchString))"	-BackgroundColor Red -ForegroundColor White
		}
	}
}
Set-Alias -Name SAR -Value Search-ReplaceText
#cmd /c dir posh-* /s /b | dir #search for files fast

function Use-Location($Path, $Body) {  
    Push-Location $Path 
    try { &$Body }  
    finally { Pop-Location }  
} 

#jump back within current directory based on wildcard 
#c:\Users\dirk\Desktop> back u
#c:\users>
function back ($p) {            
    Push-Location            
    $parts = $pwd.Path.Split('\')            
    $count = $parts.Count            
    for($idx=0; $idx -lt $count; $idx+=1) {            
        if($parts[$idx] -match $p) {            
            Set-Location ($parts[0..$idx] -join '\')            
            break            
        }            
    }                
}

Add-Type -TypeDefinition '
using System;
using System.Runtime.InteropServices;
 
namespace Utilities {
   public static class Display
   {
      [DllImport("user32.dll", CharSet = CharSet.Auto)]
      private static extern IntPtr SendMessage(
         IntPtr hWnd,
         UInt32 Msg,
         IntPtr wParam,
         IntPtr lParam
      );
 
      public static void PowerOff ()
      {
         SendMessage(
            (IntPtr)0xffff, // HWND_BROADCAST
            0x0112,         // WM_SYSCOMMAND
            (IntPtr)0xf170, // SC_MONITORPOWER
            (IntPtr)0x0002  // POWER_OFF
         );
      }
   }
}
'
function DisplayOff{
   [Utilities.Display]::PowerOff()
}

Export-ModuleMember -Function * -Alias *