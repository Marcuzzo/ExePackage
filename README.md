# Executable install DSC Resource

[![Build status](https://ci.appveyor.com/api/projects/status/ai7cs9ud2lb4axvc?svg=true)](https://ci.appveyor.com/project/Marcuzzo/exepackageresource)

This is a quick and dirty way for me to install executable setup's

PackageManagement (OneGet) CmdLets are used to detect the applications.

```powershell
 Get-Package -Name $Name -RequiredVersion $version -ProviderName programs -ErrorAction SilentlyContinue
```

## Example usage

Install using PowershellGet

> Install-Module -Name ExePackage



```powershell

Configuration ExePackageSetup
{

    param (
        [Parameter()]
        [string] $RepositoryPath
    )

    Import-DSCResource -ModuleName ExePackage

    Node localhost
    {

        ExePackage Git
        {
            Ensure = 'Present'
            Path = "$RepositoryPath\git\Git-2.20.1-64-bit.exe"
            Arguments = "/SP- /VERYSILENT /SUPPRESSMSGBOXES  /NORESTART /LOADINF='$RepositoryPath\git\setup.inf'"
            Name = 'Git version 2.20.1'
            Version = '2.20.1'

        }
    }

}

[string] $Root = [System.IO.Path]::GetPathRoot($PSScriptRoot)
ExePackageSetup -RepositoryPath "$Root\sources" -LogDirectory $env:TEMP
Start-DscConfiguration -Wait -Force -Path .\ExePackageSetup -Verbose
```
