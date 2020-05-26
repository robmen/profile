Set-Alias msb "E:\apps\Visual Studio\2017\Enterprise\MSBuild\15.0\Bin\MSBuild.exe"
Set-Alias msb16 "E:\apps\Visual Studio\2019\MSBuild\Current\Bin\MSBuild.exe"
Set-Alias msbuild "E:\apps\Visual Studio\2017\Enterprise\MSBuild\15.0\Bin\MSBuild.exe"
Set-Alias msbuild15 "E:\apps\Visual Studio\2017\Enterprise\MSBuild\15.0\Bin\MSBuild.exe"
Set-Alias msbuild16 "E:\apps\Visual Studio\2019\MSBuild\Current\Bin\MSBuild.exe"
Set-Alias msbuild14 ${env:ProgramFiles(x86)}\MSBuild\14.0\Bin\MSBuild.exe
Set-Alias msbuild12 ${env:ProgramFiles(x86)}\MSBuild\12.0\Bin\MSBuild.exe
Set-Alias msbuild4 $env:WinDir\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe
Set-Alias msbuild35 $env:WinDir\Microsoft.NET\Framework\v3.5\MSBuild.exe
Set-Alias msbuild2 $env:WinDir\Microsoft.NET\Framework\v2.0.50727\MSBuild.exe
Set-Alias iise "${env:ProgramFiles(x86)}\IIS Express\iisexpress.exe"
Set-Alias devenv "E:\apps\Visual Studio\2017\Enterprise\Common7\IDE\devenv.exe"
Set-Alias devsetup "${env:ProgramFiles(x86)}\Microsoft Visual Studio 14.0\Common7\IDE\devenv.com"
Set-Alias dev12 "${env:ProgramFiles(x86)}\Microsoft Visual Studio 12.0\Common7\IDE\devenv.com"
Set-Alias windbg "${env:ProgramFiles(x86)}\Windows Kits\8.1\Debuggers\x86\windbg.exe"
Set-Alias sn "${env:ProgramFiles(x86)}\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.6.1 Tools\sn.exe"
Set-Alias vs 'E:\apps\Visual Studio\2017\Enterprise\Common7\IDE\devenv.exe'
Set-Alias touch Set-File
Set-Alias blog New-BlogEntry

function msbr {
    param([Parameter(ValueFromRemainingArguments=$true)][string]$arguments)

    msb -v:m -p:Configuration=Release $arguments
}

function msbm {
    param([Parameter(ValueFromRemainingArguments=$true)][string]$arguments)

    msb -v:m -m -nr:false $arguments
}

function msbmd {
    param([Parameter(ValueFromRemainingArguments=$true)][string]$arguments)

    msb -v:m -m -nr:false -p:Configuration=Debug $arguments
}

function msbmr {
    param([Parameter(ValueFromRemainingArguments=$true)][string]$arguments)

    msb -v:m -m -nr:false -p:Configuration=Release $arguments
}

function which($name)
{
    Get-Command $name | Select-Object -ExpandProperty Definition
}

. E:\zin\_rg.ps1

# Import-Module 'C:\Program Files (x86)\Microsoft SDKs\Windows Azure\PowerShell\Azure\Azure.psd1'


$identity  = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
$administrator = $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)

# posh-git settings
Import-Module posh-git

$GitPromptSettings.AnsiConsole = 0
#$GitPromptSettings.DefaultColor.ForegroundColor = [ConsoleColor]::Gray
$GitPromptSettings.WorkingColor.ForegroundColor = "Gray"
$GitPromptSettings.PathStatusSeparator = ''
$GitPromptSettings.AfterStatus.Text = '] '

function prompt
{
    $realLASTEXITCODE = $LASTEXITCODE

    $terminator = if ($administrator) { '!' } else { '$' }
    $Host.UI.RawUI.WindowTitle = $pwd.ProviderPath + $terminator + ' for ' + $env:UserName + '@' + $env:ComputerName

    $prompt = ""
    $prompt += Write-Prompt "$($pwd.ProviderPath)`n" -ForegroundColor DarkGray
    $prompt += Write-VcsStatus
    $prompt += Write-Prompt $terminator -ForegroundColor DarkGray

    $global:LASTEXITCODE = $realLASTEXITCODE
    #$prompt
    if ($prompt) { "$prompt " } else { " " }
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

function Import-DevEnv {
  & "${env:COMSPEC}" /s /c "`"E:\apps\Visual Studio\2017\Enterprise\Common7\Tools\VsDevCmd.bat`" -no_logo && set" | foreach-object {
    $name, $value = $_ -split '=', 2
    Set-Content env:\"$name" $value
  }
}

function Import-DevEnv15 {
  & "${env:COMSPEC}" /s /c "`"E:\apps\Visual Studio\2017\Enterprise\Common7\Tools\VsDevCmd.bat`" -no_logo && set" | foreach-object {
    $name, $value = $_ -split '=', 2
    Set-Content env:\"$name" $value
  }
}

function Import-DevEnv16 {
  & "${env:COMSPEC}" /s /c "`"E:\apps\Visual Studio\2019\Common7\Tools\VsDevCmd.bat`" -no_logo && set" | foreach-object {
    $name, $value = $_ -split '=', 2
    Set-Content env:\"$name" $value
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

    Push-Location $repo

    code $repo (Join-Path $postsFolder $entryFile)

    Invoke-Item $contentFolder

    $url = 'https://www.flickr.com/search/?license=4%2C5%2C9%2C10&advanced=1&text=' + $name
    Start-Process "$url"
}

function Measure-Command2 ([ScriptBlock]$Expression, [int]$Samples = 1, [Switch]$Silent, [Switch]$Long) {
<#
.SYNOPSIS
  Runs the given script block and returns the execution duration.
  Discovered on StackOverflow. http://stackoverflow.com/questions/3513650/timing-a-commands-execution-in-powershell

.EXAMPLE
  Measure-Command2 { ping -n 1 google.com }
#>
  $timings = @()
  do {
    $sw = New-Object Diagnostics.Stopwatch
    if ($Silent) {
      $sw.Start()
      $null = & $Expression
      $sw.Stop()
      Write-Host "." -NoNewLine
    }
    else {
      $sw.Start()
      & $Expression
      $sw.Stop()
    }
    $timings += $sw.Elapsed

    $Samples--
  }
  while ($Samples -gt 0)

  Write-Host

  $stats = $timings | Measure-Object -Average -Minimum -Maximum -Property Ticks

  # Print the full timespan if the $Long switch was given.
  if ($Long) {
    Write-Host "Avg: $((New-Object System.TimeSpan $stats.Average).ToString())"
    Write-Host "Min: $((New-Object System.TimeSpan $stats.Minimum).ToString())"
    Write-Host "Max: $((New-Object System.TimeSpan $stats.Maximum).ToString())"
  }
  else {
    # Otherwise just print the milliseconds which is easier to read.
    Write-Host "Avg: $((New-Object System.TimeSpan $stats.Average).TotalMilliseconds)ms"
    Write-Host "Min: $((New-Object System.TimeSpan $stats.Minimum).TotalMilliseconds)ms"
    Write-Host "Max: $((New-Object System.TimeSpan $stats.Maximum).TotalMilliseconds)ms"
  }
}

Set-Alias time Measure-Command2
Set-Alias timethis Measure-Command2

# Required VS2012 environment variable
#$env:VisualStudioVersion="12.0"

Set-Location E:\src
#Clear-Host
