@{
    RootModule           = 'cElasticSearchDSC.schema.psm1'

    DscResourcesToExport = @('cElasticSearchDSC')
    # Version number of this module.
    ModuleVersion        = '0.0.1'

    # ID used to uniquely identify this module
    GUID                 = '02ccabde-f626-4bea-a4b7-363554f3f282'

    # Author of this module
    Author               = 'Yang Xinyun'

    # Company or vendor of this module
    CompanyName          = 'Yang Xinyun'

    # Copyright statement for this module
    Copyright            = '(c) 2021 Yang Xinyun. All rights reserved.'

    # Description of the functionality provided by this module
    Description          = 'Powershell DSC Resource to install JDK and ElasticSearch on Windows Server.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion    = '5.1'

    PrivateData          = @{

        PSData = @{
    
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags                     = @('DSC', 'ElasticSearch', 'Elastic', 'DSCResource', 'DesiredStateConfiguration')
    
            # A URL to the license for this module.
            # LicenseUri = ''
    
            # A URL to the main website for this project.
            ProjectUri               = 'https://github.com/yangxinyun/cElasticSearchDSC'
    
            # A URL to an icon representing this module.
            IconUri                  = 'https://cdn.iconscout.com/icon/free/png-512/elasticsearch-226094.png'
    
            # ReleaseNotes of this module
            # ReleaseNotes = ''
    
            # Prerelease string of this module
            # Prerelease = ''
    
            # Flag to indicate whether the module requires explicit user acceptance for install/update/save
            RequireLicenseAcceptance = $false
    
            # External dependent modules of this module
            # ExternalModuleDependencies = @()
    
        } # End of PSData hashtable
    
    }

}