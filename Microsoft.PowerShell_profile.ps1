Set-Alias msb ${env:ProgramFiles(x86)}\MSBuild\14.0\Bin\MSBuild.exe
Set-Alias msbuild ${env:ProgramFiles(x86)}\MSBuild\14.0\Bin\MSBuild.exe
Set-Alias msbuild12 ${env:ProgramFiles(x86)}\MSBuild\12.0\Bin\MSBuild.exe
Set-Alias msbuild4 $env:WinDir\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe
Set-Alias msbuild35 $env:WinDir\Microsoft.NET\Framework\v3.5\MSBuild.exe
Set-Alias msbuild2 $env:WinDir\Microsoft.NET\Framework\v2.0.50727\MSBuild.exe
Set-Alias iise "${env:ProgramFiles(x86)}\IIS Express\iisexpress.exe"
Set-Alias devsetup "${env:ProgramFiles(x86)}\Microsoft Visual Studio 12.0\Common7\IDE\devenv.com"
Set-Alias dev12 "${env:ProgramFiles(x86)}\Microsoft Visual Studio 12.0\Common7\IDE\devenv.com"
Set-Alias windbg "${env:ProgramFiles(x86)}\Windows Kits\8.1\Debuggers\x86\windbg.exe"
Set-Alias touch Set-File
Set-Alias blog New-BlogEntry

function msbr
{
    msb -v:m -p:Configuration=Release $args
}

function msbm
{
    msb -v:m -m -nr:false $args
}

function msbmr
{
    msb -v:m -m -nr:false -p:Configuration=Release $args
}


# Import-Module 'C:\Program Files (x86)\Microsoft SDKs\Windows Azure\PowerShell\Azure\Azure.psd1'


$identity  = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
$administrator = $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)

# posh-git settings
Import-Module posh-git

$GitPromptSettings.BeforeText = '['
$GitPromptSettings.AfterText = '] '
$GitPromptSettings.WorkingForegroundColor = [ConsoleColor]::Gray
# $GitPromptSettings.UntrackedForegroundColor = [ConsoleColor]::Gray
$GitPromptSettings.EnableWindowTitle = ''

function prompt
{
    $realLASTEXITCODE = $LASTEXITCODE

    # Reset color, which can be messed up by Enable-GitColors
    $Host.UI.RawUI.ForegroundColor = $GitPromptSettings.DefaultForegroundColor

    $terminator = if ($administrator) { '!' } else { '$' }
    $Host.UI.RawUI.WindowTitle = $pwd.ProviderPath + $terminator + ' for ' + $env:UserName + '@' + $env:ComputerName

    Write-Host($pwd.ProviderPath)
    Write-VcsStatus

    $global:LASTEXITCODE = $realLASTEXITCODE
    return $terminator + ' '
}

function Add-Path {
    param([Parameter(Mandatory=$true)][string]$path)

    $env:Path+= ";" +  $path

    Write-Output $env:Path

    $write = Read-Host 'Set PATH permanently ? (yes|no)'
    if ($write -eq "yes")
    {
        [Environment]::SetEnvironmentVariable("Path", $env:Path, [System.EnvironmentVariableTarget]::User)
        Write-Output 'PATH updated'
    }
}

function Set-File {
    param([Parameter(Mandatory=$true)][string]$path)

    $folder = Split-Path $path -Parent

    if ($folder) {
        New-Item -ItemType Directory -Force -Path $folder | Out-Null
    }

    Out-File -Encoding ascii -FilePath $path
}

function New-BlogEntry {
    param([Parameter(Mandatory=$true, ValueFromRemainingArguments=$true)][string]$name)

    $repo = 'E:\src\RobMensching.com'
    $postsFolder = Join-Path $repo 'Web\static\documents\blog\posts'
    $contentFolder = Join-Path $repo 'Web\static\files\blog\content\posts'
    $date = Get-Date -format 'yyyy-MM-dd'
    $entryFile = $date + ' ' + $name + '.html.md'

    code $repo (Join-Path $postsFolder $entryFile)

    Invoke-Item $contentFolder

    $url = 'https://www.flickr.com/search/?license=4%2C5%2C9%2C10&advanced=1&text=' + $name
    Start-Process "$url"
}


# Required VS2012 environment variable
#$env:VisualStudioVersion="12.0"

Set-Location E:\src
#Clear-Host
