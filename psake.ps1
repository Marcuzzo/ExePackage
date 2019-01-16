Task default -Depends Deploy

Properties {
    
    $ProjectRoot = $ENV:APPVEYOR_BUILD_FOLDER
    
    if( ( -not $ProjectRoot ) ) 
    {
        [ValidateNotNullOrEmpty()]$ProjectRoot = $Psake.build_script_dir 
    }

    $ProjectName = $ENV:APPVEYOR_PROJECT_NAME
    if(-not $ProjectName) { 
        [ValidateNotNullOrEmpty()]$ProjectName = (Get-ChildItem -Include *.psd1 -Recurse)[0].BaseName
    }

    $Timestamp = Get-date -uformat "%Y%m%d-%H%M%S"
    $PSVersion = $PSVersionTable.PSVersion.Major
    $TestFile = "TestResults_PS$PSVersion`_$TimeStamp.xml"
    $lines = '----------------------------------------------------------------------'
    $Verbose = @{}
    $CommitMsg =  "$env:APPVEYOR_REPO_COMMIT_MESSAGE $env:APPVEYOR_REPO_COMMIT_MESSAGE_EXTENDED"
    if($CommitMsg -match "!verbose")
    {
        $Verbose = @{Verbose = $True}
    }
}






Task Deploy {
       
    if ($env:APPVEYOR_REPO_BRANCH -ne 'master') 
    {
        Write-Warning -Message "Skipping version increment and publish for branch $env:APPVEYOR_REPO_BRANCH"
    }
    elseif ($env:APPVEYOR_PULL_REQUEST_NUMBER -gt 0)
    {
        Write-Warning -Message "Skipping version increment and publish for pull request #$env:APPVEYOR_PULL_REQUEST_NUMBER"
    }
    else
    {
        Try 
        {            
            $PM = @{
                Path        = '.\ExePackageResource'
                NuGetApiKey = $env:NuGetApiKey
                ErrorAction = 'Stop'
            }
            Publish-Module @PM
            Write-Host "ExePackage Resource published to the PowerShell Gallery." -ForegroundColor Cyan
        }
        Catch 
        {
            
            Write-Warning "Publishing to the PowerShell Gallery failed."
            throw $_
        }
    }
}

