<#
    AUTHER------: Garvey Snow
    VERSION-----: 1.1
    DESCRIPTION-: Connect-VIServer wrapper, download and cache vmware.powercli module and connect the a vcenter server
    DEPENDANCIES: write-segline.ps1 - Provided in folder and import to script
	BUILD ENV   : Powershell Version 5.0.10586.117
    LICENCE-----: GNU GENERAL PUBLIC LICENSE
    KB: o->https://ss64.com/ps/syntax-datatypes.html
    KB: 0->https://ss64.com/nt/syntax-variables.html
	UPDATE: 15/11/2017 @ 16:11
#>
function connectVI()
{

    param( [string[]]$server, [string[]]$path )

    
    ################################################
    #### CACHE PATH FOR VMWARE.POWERCLI            #
    #### - If path is not specified will use local #
    ####   temp path for logged on user            #
    ################################################
    if($path -eq $null -or $path.Length -eq 0) 
    { 
        $cache_module_path = $env:APPDATA + "\VMWARE-POWERCLI-MODULE-CACHE" 

        ## CREATE DIRECTORY IF IT DOES NOT EXISTS
        if(!(Test-Path -Path $cache_module_path))
        {
            Write-Warning -Message 'CACHE FOLDER DOES NOT EXIST - MOVING TO CREATE'
            New-Item -ItemType Directory -Path $env:APPDATA -Name "VMWARE-POWERCLI-MODULE-CACHE" -Value $null

            #SET VAR
            $cache_module_path = $env:APPDATA + "\VMWARE-POWERCLI-MODULE-CACHE" 
        }
        else
        {
            $cache_module_path = $env:APPDATA + "\VMWARE-POWERCLI-MODULE-CACHE" 
        }
    }
    else
    { 
        # IF SET FROM SWITCH -PATH
        $cache_module_path  = $path    
    }
    
    
    ################################################
    #### Check if module has been download         #
    #### - If path is not specified will use local #
    ####   temp path for logged on user            #
    ################################################    
    if($vmware_module = Find-Module -Name VMware.PowerCLI -Verbose)
    {
        
        $creds_adm = Get-Credential -UserName 'calvarycare\' -Message 'Please enter your account information.' -Verbose

        # search Module
        WRITE-SEGLINE -action -firstline 'Searching Modules for:: ' -secondline 'VMware.PowerCLI' -numlines 2 -color yellow
        WRITE-SEGLINE -response -firstline 'Module Found' -secondline 'VMware.PowerCLI' -numlines 2 -color green
    
        # Output findings
        $vmware_module | FT -AutoSize

        # Install Module/Used cached
        if(!(Get-Module -Name Vmware.PowerCLI -Verbose))
        {
            WRITE-SEGLINE -action -firstline 'Intalling VMware.PowerCLI for' -secondline 'SCOPE: Current User' -numlines 2 -color yellow
            Install-Module -Name VMware.PowerCLI –Scope CurrentUser -Verbose

            # Save Mudule and cache to local folder    
            WRITE-SEGLINE -action -firstline 'Saving module for offline use - Cache Folder : ' -secondline $cache_module_path  -numlines 2
            Save-Module -Name VMware.PowerCLI -Path $cache_module_path -Verbose

            # import the module command line
            WRITE-SEGLINE -action -firstline 'Importing Module CMDLETS for ' -secondline 'Vmware.PowerCLI' -numlines 2 -color yellow
            Import-Module VMware.PowerCLI -Verbose

        }
        else
        {
            # import the module command line
            WRITE-SEGLINE -action -firstline 'Importing Module CMDLETS for ' -secondline 'Vmware.PowerCLI' -numlines 2 -color yellow
            Import-Module VMware.PowerCLI -Verbose
        }
        #---------------------------------------------
        # Connect to vCenter Server
        #---------------------------------------------
        WRITE-SEGLINE -action -firstline 'Connecting to vCenter Server' -secondline $server -numlines 2 -color yellow
        if($vc_connect_obj = Connect-VIServer -Server $server -Credential $creds_adm -Verbose -ErrorVariable $vc_connect_error_obj | FT -AutoSize)
        {
            WRITE-SEGLINE -response -firstline 'Sucessfully Connected to ' -secondline $server -numlines 2 -color green
            $vc_connect_obj | FT -AutoSize
        }
        else
        {
            WRITE-SEGLINE -error -firstline 'Error Connecting to ' -secondline $server -numlines 2 -color red
            $vc_connect_error_obj
        }
    }       
    else
    {
        WRITE-SEGLINE -error -firstline 'Counld not find module' -secondline 'VMware.PowerCLI Suspending script' -numlines 2 -color red 
    }
}