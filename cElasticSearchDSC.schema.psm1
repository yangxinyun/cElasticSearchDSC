Configuration cElasticSearchDSC
{
    param(
        [Parameter(Mandatory = $True)]
        [ValidateSet('Present', 'Absent')] 
        [string] $Ensure,

        [Parameter(Mandatory = $True)] 
        [System.IO.FileInfo] $JRESourcePath,

        [Parameter(Mandatory = $True)] 
        [System.IO.FileInfo] $ElasticSourcePath,

        [ValidateNotNullOrEmpty()] 
        [System.IO.FileInfo] $JREDestinationPath = "$Env:ProgramFiles\Java\jre8",

        [ValidateNotNullOrEmpty()] 
        [System.IO.FileInfo] $ElasticDestinationPath = "$Env:ProgramFiles\ElasticSearch",

        [ValidateNotNullOrEmpty()]
        [System.IO.FileInfo] $ElasticDataPath = "D:\data\elastic-data",

        [ValidateNotNullOrEmpty()]
        [System.IO.FileInfo] $ElasticLogPath = "D:\data\elastic-logs"
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration

    if ($Ensure -eq 'Absent')
    {
        Script UnstallElasticSearch
        {
            GetScript  = 
            {
                $instances = Get-Service "elasticsearch-service*" 
                $vals = @{ 
                    Installed = [boolean]$instances; 
                }
                return $vals
            }

            TestScript = 
            {
                $instances = Get-Service "elasticsearch-service*" 
                if ($instances)
                {
                    Write-Verbose "elasticsearch-service is already running as a service"
                }
                else
                {
                    Write-Verbose "elasticsearch-service is not running as a service"
                }
                return ![boolean]$instances
            }

            SetScript  = 
            {
                $batPath = Join-Path $Using:elasticDestinationPath "bin/elasticsearch-service.bat"

                if (!(Test-Path $batPath))
                {
                    throw "Cannot find elasticsearch-service-x64.exe at $batPath."
                }

                $env:JAVA_HOME = $using:JREDestinationPath
                if (!$env:JAVA_HOME)
                {
                    throw "Cannot find java.exe from env var JAVA_HOME path. elasticsearch-service.bat cannot remove elasticsearch service."
                }

                $process = Start-Process -FilePath $batPath -ArgumentList "remove" -PassThru -WindowStyle Hidden -Wait
                Start-Sleep -Seconds 10
                if ($process.ExitCode -ne 0)
                {
                    Write-Error "ElasticSearch Service Removal completed with errors (exit code $($process.ExitCode))"
                }
                else
                {
                    Write-Verbose "ElasticSearch Service completed successfully (exit code $($process.ExitCode))"
                }
                
            }
        }
    }

    Archive JRE
    {
        Ensure      = $Ensure
        Destination = $JREDestinationPath
        Path        = $JRESourcePath
    }

    Environment JavaHomeEnv
    {
        Ensure    = $Ensure
        Name      = "JAVA_HOME"
        Value     = $JREDestinationPath
        DependsOn = "[Archive]JRE"
    }

    Archive ElasticSearch
    {
        Ensure      = $Ensure
        Destination = $ElasticDestinationPath
        Path        = $ElasticSourcePath
    }

    #Please keep the contents attribute format as it. otherwise the config file cannot be parsed by ES.
    File ElasticConfigFile
    {
        Ensure          = $Ensure
        Type            = "File"
        DestinationPath = Join-Path "$ElasticDestinationPath" "config\elasticsearch.yml"
        Contents        = 
        "path.data: $ElasticDataPath
path.logs: $ElasticLogPath
node.name: $($Node.NodeName)
network.host: _site_
"
        DependsOn       = "[Archive]ElasticSearch"
        Force           = $true
    }

    File ElasticDataDirectory 
    {
        Ensure          = $Ensure
        Type            = "Directory"
        DestinationPath = $ElasticDataPath
        Force           = $true
    }

    File ElasticLogDirectory 
    {
        Ensure          = $Ensure
        Type            = "Directory"
        DestinationPath = $ElasticLogPath
        Force           = $true
    }

    if ($Ensure -eq 'Present')
    {
        Script InstallElasticSearch
        {
            DependsOn  = "[File]ElasticConfigFile", "[File]ElasticDataDirectory", "[File]ElasticLogDirectory", "[Environment]JavaHomeEnv"

            GetScript  = 
            {
                $instances = Get-Service "elasticsearch-service*" 
                $vals = @{ 
                    Installed = [boolean]$instances; 
                }
                return $vals
            }

            TestScript = 
            {
                $instances = Get-Service "elasticsearch-service*" 
                if ($instances)
                {
                    Write-Verbose "elasticsearch-service is already running as a service"
                }
                else
                {
                    Write-Verbose "elasticsearch-service is not running as a service"
                }
                return [boolean]$instances
            }

            SetScript  = 
            {
                $batPath = Join-Path $Using:elasticDestinationPath "bin/elasticsearch-service.bat"

                if ($using:Ensure -eq 'Present')
                {
                    $process = Start-Process -FilePath $batPath -ArgumentList "install" -PassThru -WindowStyle Hidden -Wait
                    if ($process.ExitCode -ne 0)
                    {
                        Write-Error "ElasticSearch Service installation completed with errors (exit code $($process.ExitCode))"
                    }
                    else
                    {
                        Write-Verbose "ElasticSearch Service installation completed successfully (exit code $($process.ExitCode))"
                    }
                    $start = Start-Process -FilePath $batPath -ArgumentList "start" -PassThru -WindowStyle Hidden -Wait
                    if ($start.ExitCode -ne 0)
                    {
                        Write-Error "ElasticSearch Service started with errors (exit code $($start.ExitCode))"
                    }
                    else
                    {
                        Write-Verbose "ElasticSearch Service started successfully (exit code $($start.ExitCode))"
                    }
                }
            }
        }
    } 
}