enum Ensure
{
    Absent
    Present
}


[DscResource()]
class ExePackage
{

    [DscProperty(Key)]
    [string] $Path


    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    [DscProperty(Mandatory)]
    [string] $Name

    
    [DscProperty(Mandatory)]
    [string] $version

    [DscProperty(
        Mandatory = $false
    )]
    [string] $Arguments = [string]::Empty

    #region helpers
    [bool] TestInstalled([string] $Name, [string] $Version)
    {
        $Package = Get-Package -Name $Name -RequiredVersion $version -ProviderName programs -ErrorAction SilentlyContinue   
        return ( $null -ne $Package )        
    }
    
    [void] RemovePackage([string] $Name, [string] $Version)
    {
        $Package = Get-Package -Name $Name -RequiredVersion $version -ProviderName programs -ErrorAction SilentlyContinue   
        $Package | Uninstall-Package -Force
    }

    #endregion 


    [void] Set()
    {
        $isPresent = $this.TestInstalled($this.Name, $this.version)
        if ( $this.Ensure -eq [Ensure]::Present )
        {            
            if ( -not $isPresent )            
            {
                $Args = @{
                    FilePath = $this.Path
                    ArgumentList = $this.Arguments
                }                                          
                Start-Process @Args -Wait
            }        
        }
        else
        {
            if ( $isPresent )
            {
                $this.RemovePackage($this.Name, $this.version)
            }
        }
    }
    
    [bool] Test()
    {   
        $Present = $this.TestInstalled($this.Name, $this.version)
        
        if ( $this.Ensure -eq [Ensure]::Present )
        {
            return $Present
        }
        else
        {
            return -not $Present
        }
                
    }

    [ExePackage] Get()
    {
        $isPresent = $this.TestInstalled($this.Name, $this.version)        
        if ( $isPresent )
        {
            $this.Ensure = [Ensure]::Present
        }
        else
        {
            $this.Ensure = [Ensure]::Absent
        }
        return $this
    }

}