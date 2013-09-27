Set-Alias msb $env:WinDir\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe
Set-Alias msbuild $env:WinDir\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe
Set-Alias msbuild35 $env:WinDir\Microsoft.NET\Framework\v3.5\MSBuild.exe
Set-Alias msbuild2 $env:WinDir\Microsoft.NET\Framework\v2.0.50727\MSBuild.exe

$identity  = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
$administrator = $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)

# posh-git settings
Import-Module posh-git

$GitPromptSettings.BeforeText = '['
$GitPromptSettings.AfterText = '] '
$GitPromptSettings.WorkingForegroundColor = [ConsoleColor]::Gray
$GitPromptSettings.UntrackedForegroundColor = [ConsoleColor]::Gray
$GitPromptSettings.EnableWindowTitle = ''
Enable-GitColors

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

Set-Location E:\src
Clear-Host
