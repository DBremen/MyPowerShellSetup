<#
.SYNOPSIS
Installs applications via chocolatey, powershell modules via powershellget, and other applications via direct download.
.DESCRIPTION
Installs applications via chocolatey, powershell modules via powershellget, and other applications via direct download.
Will also install some configurations I like to have for particular apps.
.EXAMPLE
.\Install-Extras.ps1
.NOTES
Author: Zachary Loeber

The order of operations is:
1. We first update some basic components (PowershellGet/PackageManager) and force a powershell session restart if required.
2. Chocolatey will install and the script will restart if choco.exe is not found
4. We then download any github releases software if possible (most recent release)
5. Download any manual defined links
6. Start the exe/msi installs one at a time (waiting for completion before moving on)
7. Set some configuration prefs for a handful of apps
9. Chocolatey installs and updates tend to clutter the desktop with shortcuts so we attempt to move any desktop shortcuts to a folder called 'shortcuts' on the desktop to declutter things.
10. Create a custom powershell profile

Apps will not redownload or be executed if they are already found in the downloads folder.

.LINK
https://github.com/zloeber/WindowsSetupScripts
#>

# ***** BEGIN CUSTOMIZATION *****
# PowerShell Modules to install
# (Get-InstalledModule | select -expand name | where {$_ -notmatch 'AzureRM\..*'} | foreach {"'$_'"}) -join ",`n`t" | clip
#//start-ModulesToBeInstalled
$ModulesToBeInstalled = @(
    'ChocolateyGet',
    'DirColors',
    'Emojis',
    'GetSQL',
    'ImportExcel',
    'ISEModuleBrowserAddon',
    'MsftGraph',
    'PackageManagement',
    'parse-curl',
    'PowerShellGet',
    'ps-menu',
    'PSColor',
    'PSFzf',
    'PSProse',
    'PSSharedGoods',
    'PSWriteColor',
    'PSWriteHTML',
    'ShowUI',
    'TabExpansionPlusPlus',
    'UMN-Google',
    'WPFBot3000',
    'z',
    'Gridify',
    'Pester'
)
#//end-ModulesToBeInstalled
# Chocolatey packages to install
#get-package
#Register-PackageSource -Name Chocolatey -ProviderName Chocolatey -Location http://chocolatey.org/api/v2/
#Find-Package graphviz | Install-Package -ForceBootstrap
# (choco list --localonly --id-only | select -skiplast 1 | where {$_ -notmatch 'KB\d+' -and $_ -notmatch 'chocolatey v.*' -and $_ -notmatch '\w+[\.-]install.*'} | foreach {"'$_'"}) -join ",`n`t" | clip
#//start-chocoToBeInstalled
$ModulesToBeInstalled = @(
    'autohotkey',
    'chocolatey',
    'chocolatey-core.extension',
    'Cmder',
    'fd',
    'fluent-terminal',
    'fzf',
    'nodejs',
    'openssh',
    'PowerShell',
    'scite4autohotkey',
    'vcredist2010'
)
#//end-chocoToBeInstalled
# Chocolatey places a bunch of crap on the desktop after installing or updating software. This flag allows
#  you to clean that up (Note: this will move *.lnk files from the Public user profile desktop and your own
#  desktop to a new directory called 'shortcuts' on your desktop. This may or may not be what you want..)
$ClearDesktopShortcuts = $True

# Add a folder to place your nefarious executables in so you can infect yourself (or run hacker tools like I do)
$BypassDefenderPaths = @('C:\_ByPassDefender')

# Downloads of non-chocolatey installed apps will go here (within system root)
$UtilDownloadPath = join-path $env:systemdrive 'Utilities\Downloads'

# some manual installs: vscode-insiders, typora, and skypeonline powershell module (as examples)
$ManualDownloadInstall = @{
    'node'                      = 'updateNodeURL'
    'vscodeinsiders.exe'        = 'https://go.microsoft.com/fwlink/?Linkid=852155'
    # 'vscode.exe' = 'https://go.microsoft.com/fwlink/?linkid=852157'
    'typora-setup-x64.exe'      = 'https://typora.io/windows/typora-setup-x64.exe'
    'skypeonlinepowershell.exe' = 'https://download.microsoft.com/download/2/0/5/2050B39B-4DA5-48E0-B768-583533B42C3B/SkypeOnlinePowershell.exe'
    'keybase_setup_386.exe'     = 'https://prerelease.keybase.io/keybase_setup_386.exe'
}

# Releases based github packages to download and install. I include Keeweb,Dokany (used for Keybase explorer integration), and pandoc
$GithubReleasesPackages = @{
    'keeweb/keeweb'    = "keeweb*win.x64.exe"
    'dokan-dev/dokany' = "DokanSetup.exe"
    'jgm/pandoc'       = "pandoc-*-windows.msi"
}


# Use the $MyPowerShellProfile to create a new powershell profile if one doesn't already exist
$CreatePowershellProfile = $False
$MyPowerShellProfile = @'
## Detect if we are running powershell without a console.
$_ISCONSOLE = $TRUE
try {
    [System.Console]::Clear()
}
catch {
    $_ISCONSOLE = $FALSE
}

# Everything in this block is only relevant in a console. This keeps nonconsole based powershell sessions clean.
if ($_ISCONSOLE) {
    ##  Check SHIFT state ASAP at startup so we can use that to control verbosity :)
    try {
	Add-Type -Assembly PresentationCore, WindowsBase
        if ([System.Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::LeftShift) -or [System.Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::RightShift)) {
            $VerbosePreference = "Continue"
        }
    }
    catch {
        # Maybe this is a non-windows host?
    }

    ## Set the profile directory variable for possible use later
    Set-Variable ProfileDir (Split-Path $MyInvocation.MyCommand.Path -Parent) -Scope Global -Option AllScope, Constant -ErrorAction SilentlyContinue

    # Start OhMyPsh only if we are in a console
    if ($Host.Name -eq 'ConsoleHost') {
        if (Get-Module OhMyPsh -ListAvailable) {
            Import-Module OhMyPsh
        }
    }
}

# Relax the code signing restriction so we can actually get work done
Import-module Microsoft.PowerShell.Security
Set-ExecutionPolicy RemoteSigned Process
'@
# ***** END CUSTOMIZATION *****
Function ReRunScriptElevated {
    if ( -not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator') ) {
        Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $PSCommandArgs" -WorkingDirectory $pwd -Verb RunAs
        Exit
    }
}

Function ReRunScript {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $PSCommandArgs" -WorkingDirectory $pwd -Verb RunAs
    Exit
}

Function Get-SpecialPaths {
    $SpecialFolders = @{ }

    $names = [Environment+SpecialFolder]::GetNames([Environment+SpecialFolder])

    foreach ($name in $names) {
        $SpecialFolders[$name] = [Environment]::GetFolderPath($name)
    }

    $SpecialFolders
}

Function Get-EnvironmentVariableNames {
    param (
        [string]$Scope
    )

    ([Environment]::GetEnvironmentVariables($Scope).GetEnumerator()).Name
}

Function Get-EnvironmentVariable {
    param (
        [string]$Name,
        [string]$Scope
    )

    [Environment]::GetEnvironmentVariable($Name, $Scope)
}
Function Update-SessionEnvironment {
    <#
    Ripped directly from the chocolatey project, used here just for initial setup
    #>
    $refreshEnv = $false
    $invocation = $MyInvocation
    if ($invocation.InvocationName -eq 'refreshenv') {
        $refreshEnv = $true
    }

    if ($refreshEnv) {
        Write-Output "Refreshing environment variables from the registry for powershell.exe. Please wait..."
    }
    else {
        Write-Verbose "Refreshing environment variables from the registry."
    }

    $userName = $env:USERNAME
    $architecture = $env:PROCESSOR_ARCHITECTURE
    $psModulePath = $env:PSModulePath

    #ordering is important here, $user comes after so we can override $machine
    'Process', 'Machine', 'User' |
    % {
        $scope = $_
        Get-EnvironmentVariableNames -Scope $scope |
        % {
            Set-Item "Env:$($_)" -Value (Get-EnvironmentVariable -Scope $scope -Name $_)
        }
    }

    #Path gets special treatment b/c it munges the two together
    $paths = 'Machine', 'User' |
    % {
        (Get-EnvironmentVariable -Name 'PATH' -Scope $_) -split ';'
    } | Select-Object -Unique
    $Env:PATH = $paths -join ';'

    # PSModulePath is almost always updated by process, so we want to preserve it.
    $env:PSModulePath = $psModulePath

    # reset user and architecture
    if ($userName) { $env:USERNAME = $userName; }
    if ($architecture) { $env:PROCESSOR_ARCHITECTURE = $architecture; }

    if ($refreshEnv) {
        Write-Output "Finished"
    }
}

Function Add-EnvPath {
    # Adds a path to the $ENV:Path list for a user or system if it does not already exist (in both the system and user Path variables)
    param (
        [string]$Location,
        [string]$NewPath
    )

    $AllPaths = $Env:Path -split ';'
    if ($AllPaths -notcontains $NewPath) {
        Write-Output "Adding Utilties bin directory path to the environmental path list: $UtilBinPath"

        $NewPaths = (@(([Environment]::GetEnvironmentVariables($Location).GetEnumerator() | Where { $_.Name -eq 'Path' }).Value -split ';') + $UtilBinPath | Select-Object -Unique) -join ';'

        [Environment]::SetEnvironmentVariable("PATH", $NewPaths, $Location)
    }
}

function Start-Proc {
    param([string]$Exe = $(Throw "An executable must be specified"),
        [string]$Arguments,
        [switch]$Hidden,
        [switch]$waitforexit)

    $startinfo = New-Object System.Diagnostics.ProcessStartInfo
    $startinfo.FileName = $Exe
    $startinfo.Arguments = $Arguments
    if ($Hidden) {
        $startinfo.WindowStyle = 'Hidden'
        $startinfo.CreateNoWindow = $True
    }
    $process = [System.Diagnostics.Process]::Start($startinfo)
    if ($waitforexit) { $process.WaitForExit() }
}


function Get-ChocoPackages {
    if (get-command clist -ErrorAction:SilentlyContinue) {
        clist -lo -r -all | Foreach {
            $Name, $Version = $_ -split '\|'
            New-Object -TypeName psobject -Property @{
                'Name'    = $Name
                'Version' = $Version
            }
        }
    }
}

# Add a path for windows defender to bypass
function Add-DefenderBypassPath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string[]]$Path
    )
    begin {
        $Paths = @()
    }
    process {
        $Paths += $Path
    }
    end {
        $Paths | Foreach-Object {
            if (-not [string]::isnullorempty($_)) {
                Add-MpPreference -ExclusionPath $_ -Force
            }
        }
    }
}

# Rerun elevated if required
ReRunScriptElevated

# Need this to download via Invoke-WebRequest
[Net.ServicePointManager]::SecurityProtocol = [System.Security.Authentication.SslProtocols] "tls, tls11, tls12"

# Trust the psgallery for installs
Write-Host -ForegroundColor 'Yellow' 'Setting PSGallery as a trusted installation source...'
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

# Install/Update PowershellGet and PackageManager if needed
try {
    Import-Module PowerShellGet
}
catch {
    throw 'Unable to load PowerShellGet!'
}

# Need to set Nuget as a provider before installing modules via PowerShellGet
$null = Install-PackageProvider NuGet -Force

# Store a few things for later use
$SpecialPaths = Get-SpecialPaths
$packages = Get-Package

if (@($packages | Where-Object { $_.Name -eq 'PackageManagement' }).Count -eq 0) {
    Write-Host -ForegroundColor cyan "PackageManager is installed but not being maintained via the PowerShell gallery (so it will never get updated). Forcing the install of this module through the gallery to rectify this now."
    Install-Module PackageManagement -Force
    Install-Module PowerShellGet -Force

    Write-Host -ForegroundColor:Red "PowerShellGet and PackageManagement have been installed from the gallery. You need to close and rerun this script for them to work properly!"

    # Rerun this script if we got this far as upgrading packagemanagament seems to require it after an update
    ReRunScript
}
else {
    $InstalledModules = (Get-InstalledModule).name
    $ModulesToBeInstalled = $ModulesToBeInstalled | Where-Object { $InstalledModules -notcontains $_ }
    if ($ModulesToBeInstalled.Count -gt 0) {
        Write-Host -ForegroundColor:cyan "Installing modules that are not already installed via powershellget. Modules to be installed = $($ModulesToBeInstalled.Count)"
        Install-Module -Name $ModulesToBeInstalled -AllowClobber -AcceptLicense -ErrorAction:SilentlyContinue
    }
    else {
        Write-Output "No modules were found that needed to be installed."
    }
}

if ($null -eq (get-command choco.exe -ErrorAction SilentlyContinue)) {
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    ReRunScript
}
# Install any chocolatey packages now
Write-Output "Installing software via chocolatey"

# We run upgrade which will install the software if it doesn't exist or upgrade it if it does.
if ($ChocoInstalls.Count -gt 0) {
    # Install a ton of other crap I use or like, update $ChocoInsalls to suit your needs of course
    $ChocoInstalls | Foreach-Object {
        try {
            choco upgrade -y $_ --cacheLocation "$($env:userprofile)\AppData\Local\Temp\chocolatey"
        }
        catch {
            Write-Warning "Unable to install software package with Chocolatey: $($_)"
        }
    }
}
else {
    Write-Output 'There were no packages to install!'
}

<#
    Manually installed packages (not in chocolatey or packagemanager)
#>
If (-not (Test-Path $UtilDownloadPath)) {
    mkdir $UtilDownloadPath -Force
}
If (-not (Test-Path $UtilBinPath)) {
    mkdir $UtilBinPath -Force
}

Push-Location $UtilDownloadPath
# Store all the file we download for later processing
$FilesDownloaded = @()


# Github releases based software.
Foreach ($software in $GithubReleasesPackages.keys) {
    $releases = "https://api.github.com/repos/$software/releases"
    Write-Output "Determining latest release for repo $Software"
    $tag = (Invoke-WebRequest $releases -UseBasicParsing | ConvertFrom-Json)[0]
    $tag.assets | ForEach-Object {
        if ($_.name -like $GithubReleasesPackages[$software]) {
            if ( -not (Test-Path $_.name)) {
                try {
                    Write-Output "Downloading $($_.name)..."
                    Invoke-WebRequest $_.'browser_download_url' -OutFile $_.Name
                    $FilesDownloaded += $_.Name
                }
                catch { }
            }
            else {
                Write-Warning "File is already downloaded, skipping: $($_.Name)"
            }
        }
    }
}

# Manually downloaded software
Foreach ($software in $ManualDownloadInstall.keys) {
    Write-Output "Downloading $software"
    if ( -not (Test-Path $software) ) {
        try {
            Invoke-WebRequest $ManualDownloadInstall[$software] -OutFile $software -UseBasicParsing
            $FilesDownloaded += $software
        }
        catch { }
    }
    else {
        Write-Warning "File is already downloaded, skipping: $software"
    }
}

# Extracting self-contained binaries (zip files) to our bin folder
Write-Output 'Extracting self-contained binaries (zip files) to our bin folder'
Get-ChildItem -Path $UtilDownloadPath -File -Filter '*.zip' | Where { $FilesDownloaded -contains $_.Name } | ForEach-Object {
    Expand-Archive -Path $_.FullName -DestinationPath $UtilBinPath -Force
}

Add-EnvPath -Location 'User' -NewPath $UtilBinPath
Update-SessionEnvironment

# Kick off exe installs
Get-ChildItem -Path $UtilDownloadPath -File -Filter '*.exe' | Where { $FilesDownloaded -contains $_.Name } | ForEach-Object {
    Start-Proc -Exe $_.FullName -waitforexit
}

# Kick off msi installs
Get-ChildItem -Path $UtilDownloadPath -File -Filter '*.msi' | Where { $FilesDownloaded -contains $_.Name } | ForEach-Object {
    Start-Proc -Exe $_.FullName -waitforexit
}

<#
    Configuration
#>

# keyprinha ini setup. If you don't use this launchy alternative then don't run this.
$keypirinhaconfigdata = @'
[app]
launch_at_startup = yes
hotkey_run = Alt+Space
escape_always_closes = yes
'@

if ($null -ne (Get-Command 'keypirinha.exe' -ErrorAction:SilentlyContinue)) {
    Write-Output 'Found keypirinha, attempting to configure...'
    if ($null -eq (Get-Process -Name 'keypirinha-x64' -ErrorAction:SilentlyContinue)) {
        Write-Output '   Need to start KeyPirinha at least once to get the app directories created'
        . 'keypirinha.exe'
    }

    $keypirinhaconfig = join-path $SpecialPaths['ApplicationData'] 'Keypirinha\User\Keypirinha.ini'
    if (-not (Test-Path $keypirinhaconfig)) {
        Write-Output '   No custom user keypirinha config found, creating one that binds Alt+Space to launch the app..'
        $keypirinhaconfigdata | Out-File -FilePath $keypirinhaconfig -Encoding:utf8 -Force
        Stop-Process -Name 'keypirinha-x64' -ErrorAction:SilentlyContinue
        . 'keypirinha.exe'
    }
    else {
        Write-Warning "KeyPirinha user config file already found and NOT overwritten: $keypirinhaconfig"
    }
}


# Setup Defender bypass directory
if ($BypassDefenderPaths.Count -gt 0) {
    Write-Output 'Adding defender paths to bypass...'
    $ByPassDefenderPaths | Add-DefenderBypassPath
}

if ($ClearDesktopShortcuts) {
    $Desktop = $SpecialPaths['DesktopDirectory']
    $DesktopShortcuts = Join-Path $Desktop 'Shortcuts'
    if (-not (Test-Path $DesktopShortcuts)) {
        Write-Host -ForegroundColor:Cyan "Creating a new shortcuts folder on your desktop and moving all .lnk files to it: $DesktopShortcuts"
        $null = mkdir $DesktopShortcuts
    }

    Write-Output "Moving .lnk files from $($SpecialPaths['CommonDesktopDirectory']) to the Shortcuts folder"
    Get-ChildItem -Path  $SpecialPaths['CommonDesktopDirectory'] -Filter '*.lnk' | ForEach-Object {
        Move-Item -Path $_.FullName -Destination $DesktopShortcuts -ErrorAction:SilentlyContinue
    }

    Write-Output "Moving .lnk files from $Desktop to the Shortcuts folder"
    Get-ChildItem -Path $Desktop -Filter '*.lnk' | ForEach-Object {
        Move-Item -Path $_.FullName -Destination $DesktopShortcuts -ErrorAction:SilentlyContinue
    }
}

if ($CreatePowershellProfile) {
    if (-not (Test-Path $PROFILE)) {
        $ControlledFolderAccess = (Get-MpPreference).EnableControlledFolderAccess
        Set-MpPreference -EnableControlledFolderAccess 0
        Write-Output 'Creating user powershell profile...'
        $MyPowerShellProfile | Out-File -FilePath $PROFILE -Encoding:utf8 -Force
        Set-MpPreference -EnableControlledFolderAccess $ControlledFolderAccess
    }
    else {
        Write-Warning "Powershell profile already exists!"
    }
}

Pop-Location


