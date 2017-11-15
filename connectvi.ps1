<#
    AUTHER------: Garvey Snow
    VERSION-----: 1.0
    DESCRIPTION-: Connect-VIServer wrapper, download and cache vmware.powercli module and connect the a vcenter server
    DEPENDANCIES: write-segline.ps1 - Provided in folder and import to script
	BUILD ENV   : Powershell Version 5.0.10586.117
    LICENCE-----: GNU GENERAL PUBLIC LICENSE
    KB: o->https://ss64.com/ps/syntax-datatypes.html
	UPDATE: 15/11/2017 @ 16:11
#>
function connectVI()
{

    param([string[]]$server)

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
            WRITE-SEGLINE -action -firstline 'Saving module for offline use - Cache Folder : ' -secondline $global:config.module_cache -numlines 2
            Save-Module -Name VMware.PowerCLI -Path $global:config.module_cache -Verbose

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
        # if vCenter Server are linked to a Master 
        #---------------------------------------------
        if($linked -eq $true)
        {
                #---------------------------------------------
                # Connect to vCenter Servesr with linked mode Enabled
                #---------------------------------------------
                foreach($vc_server in $Global:config.vcenter_Servers)
                {
                    WRITE-SEGLINE -action -firstline 'Connecting to vCenter Server' -secondline $vc_server -numlines 2 -color yellow
                    Connect-VIServer -AllLinked:$true -Server $vc_server -Credential $creds_adm | FT -AutoSize
                    WRITE-SEGLINE -response -firstline 'Sucessfully Connected to ' -secondline $vc_server -numlines 3 -color green -thirdline 'LINKED MODE: YES'
                }        
        }
        else
        {       if($hvc_server -eq $null)
                { <#
                    --o-| switch between config file and switch imput
                  #> 
                    WRITE-SEGLINE -action -firstline 'Connecting to vCenter Server' -secondline $Global:config.vcenter_Servers[0] -numlines 2 -color yellow
                    if($vc_connect_obj = Connect-VIServer -Server $Global:config.vcenter_Servers[0] -Credential $creds_adm -Verbose -ErrorVariable $vc_connect_error_obj | FT -AutoSize)
                    {
                        WRITE-SEGLINE -response -firstline 'Sucessfully Connected to ' -secondline $Global:vCenter_Servers[0] -numlines 2 -color green
                        $vc_connect_obj | FT -AutoSize
                    }
                    else
                    {
                        WRITE-SEGLINE -error -firstline 'Error Connecting to ' -secondline $Global:config.vcenter_Servers[0] -numlines 2 -color red
                        $vc_connect_error_obj
                    }
                }
                else
                {
                    WRITE-SEGLINE -action -firstline 'Connecting to vCenter | HOST' -secondline $Global:config.vcenter_Servers[0] -numlines 2 -color yellow
                    if($vc_connect_obj = Connect-VIServer -Server $hvc_server -Credential $creds_adm -Verbose -ErrorVariable $vc_connect_error_obj | FT -AutoSize)
                    {
                        WRITE-SEGLINE -response -firstline 'Sucessfully Connected to ' -secondline $hvc_server -numlines 2 -color green
                        $vc_connect_obj | FT -AutoSize
                    }
                    else
                    {
                        WRITE-SEGLINE -error -firstline 'Error Connecting to ' -secondline $hvc_server -numlines 2 -color red
                        $vc_connect_error_obj
                    }                    
                }
        }

    }
    else
    {
        WRITE-SEGLINE -error -firstline 'Counld not find module' -secondline 'VMware.PowerCLI Suspending script' -numlines 2 -color red 
    

    }
}