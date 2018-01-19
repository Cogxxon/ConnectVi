<#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    AUTHER------: Garvey Snow
    VERSION-----: 1.2
    DESCRIPTION-: Connect-VIServer wrapper, download and cache vmware.powercli module and connect the a vcenter server
    DEPENDANCIES: Write-Segline.ps1 - EMBEDDED in bottom of script
    ------------:                     Can be sourced from github: https://github.com/Cogxxon/Write-Segline
	BUILD ENV   : Powershell Version 5.0.10586.117
    LICENCE-----: GNU GENERAL PUBLIC LICENSE
    KB: o-» https://ss64.com/ps/syntax-datatypes.html
        o-» https://ss64.com/nt/syntax-variables.html
        o-» https://technet.microsoft.com/en-us/library/jj554301.aspx
	UPDATE: 15/11/2017 @ 16:11
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#>
Function ConnectVI()
{

    param( 
            [string[]][parameter(Mandatory=$true)]$server, 
            [string[]]$path 
         )

    
    #////////////////////////////////////
    #//( SET YOUR SSO CREDENTIALS )//////
    #////////////////////////////////////
    $creds_adm = Get-Credential -UserName 'domain\username' -Message 'Please enter your SSO Credentials for your vCenter Server' -Verbose


    #/////////////////////////////////////////////////////
    #///| CACHE PATH FOR VMWARE.POWERCLI               |//
    #///| - If path is not specified it will use local |//
    #///|   temp path for logged on user               |//
    #/////////////////////////////////////////////////////
    if( $path -eq $null -or $path.Length -eq 0 ) 
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
            # If folder already exists use existing folder
            $cache_module_path = $env:APPDATA + "\VMWARE-POWERCLI-MODULE-CACHE" 
        }
    }
    else
    { 
        # IF SET FROM SWITCH -PATH
        $cache_module_path  = $path    
    }
    
    
    #////////////////////////////////////////////////#
    #/// Check if module has been download         //#
    #/// - If path is not specified will use local //#
    #///   temp path for logged on user            //#
    #////////////////////////////////////////////////#
    Write-Segline -action -firstline 'Searching Modules for:: ' -secondline 'VMware.PowerCLI' -numlines 2 -color yellow   
    if($vmware_module = Find-Module -Name VMware.PowerCLI -Verbose)
    {
        
        # search Module
        Write-Segline -response -firstline 'Module Found' -secondline 'VMware.PowerCLI' -numlines 2 -color green
    
        # Output findings
        $vmware_module | FT -AutoSize

        # Install Module/Used cached
        if(!(Get-Module -Name Vmware.PowerCLI -Verbose))
        {
            Write-Segline -action -firstline 'Intalling VMware.PowerCLI for' -secondline 'SCOPE: Current User' -numlines 2 -color yellow
            Install-Module -Name VMware.PowerCLI –Scope CurrentUser -Verbose

            # Save Mudule and cache to local folder    
            Write-Segline -action -firstline 'Saving module for offline use - Cache Folder : ' -secondline $cache_module_path  -numlines 2
            Save-Module -Name VMware.PowerCLI -Path $cache_module_path -Verbose

            # import the module command line
            Write-Segline -action -firstline 'Importing Module CMDLETS for ' -secondline 'Vmware.PowerCLI' -numlines 2 -color yellow
            Import-Module VMware.PowerCLI -Verbose

            #////////////////////////////////////////////////////////#
            #//// VMware Customer Experience Improvement Program ////#
            #////////////////////////////////////////////////////////#
            Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $false

        }
        else
        {
            # import the module command line
            Write-Segline -action -firstline 'Importing Module CMDLETS for ' -secondline 'Vmware.PowerCLI' -numlines 2 -color yellow
            Import-Module VMware.PowerCLI -Verbose
        }
        #---------------------------------------------
        # Connect to vCenter Server
        #---------------------------------------------
        Write-Segline -action -firstline 'Connecting to vCenter Server' -secondline $server -numlines 2 -color yellow
        if($vc_connect_obj = Connect-VIServer -Server $server -Credential $creds_adm -Verbose -ErrorVariable $vc_connect_error_obj | FT -AutoSize)
        {
            Write-Segline -response -firstline 'Sucessfully Connected to ' -secondline $server -numlines 2 -color green
            $vc_connect_obj | FT -AutoSize
        }
        else
        {
            Write-Segline -error -firstline 'Error Connecting to ' -secondline $server -numlines 2 -color red
            $vc_connect_error_obj
        }
    }       
    else
    {
        Write-Segline -error -firstline 'Counld not find module' -secondline 'VMware.PowerCLI Suspending script' -numlines 2 -color red 
    }
}

<#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#>

<#//////////////////////////( EMBBEDED Write-Segline FUNCTION )///////////( v0.1b )////////////////////////////////#>
function Write-Segline
{
    # Set Parems
    param(
           [int][parameter(Mandatory=$true)][Alias('nl')]$numlines,
          #---------
           [string[]][parameter(Mandatory=$false)][Alias('c')]$color,
          #---------
           [string[]][parameter(Mandatory=$true)][Alias('fl')]$firstline,
          #---------
           [string[]][parameter(Mandatory=$false)][Alias('sl')]$secondline,
          #---------
           [string[]][parameter(Mandatory=$false)][Alias('tl')]$thirdline,
          #---------
           [string[]][parameter(Mandatory=$false)][Alias('fhl')]$fourthline,
          #---------
           [string[]][parameter(Mandatory=$false)][Alias('ffhl')]$fifthline,
          #---------
           [switch][parameter(Mandatory=$false)][Alias('a')]$Action,
          #---------
           [switch][parameter(Mandatory=$false)][Alias('r')]$response,
          #---------
           [switch][parameter(Mandatory=$false)][Alias('e')]$error,
          #---------
           [switch][parameter(Mandatory=$false)][Alias('n')]$Notification,
          #---------
           [switch][parameter(Mandatory=$false)][Alias('ri')]$requestinput,
          #---------
           [switch][parameter(Mandatory=$false)][Alias('nnl')]$nonewline
           )

    # set default color
    if($color.length -lt 1 ){ $color = "Gray" }

    # one line write
    if($numlines -eq 1)
    {
        # Line write supporting single value
        if($Notification)
        {
            write-host -ForegroundColor DarkCyan '---<(  ' -nonewline; 
            write-host -ForegroundColor DarkRed 'Notification' -nonewline; 
            write-host -ForegroundColor DarkCyan '--------<(  ' -NoNewline; 
            write-host -ForegroundColor $color $firstline -NoNewline;
            if($nonewline){ write-host -ForegroundColor DarkCyan ' ) ' -NoNewLine; } 
            else { write-host -ForegroundColor DarkCyan ' ) ' }
        }
        if($requestinput)
        {
            write-host -ForegroundColor DarkCyan '---<(  ' -nonewline; 
            write-host -ForegroundColor DarkGreen 'Request User Input' -nonewline; 
            write-host -ForegroundColor DarkCyan '---<(  ' -NoNewline; 
            write-host -ForegroundColor $color $firstline -NoNewline; 
            if($nonewline){ write-host -ForegroundColor DarkCyan ' ) ' -NoNewLine; } 
            else { write-host -ForegroundColor DarkCyan ' ) ' }
        }
        if($error){
            write-host -ForegroundColor DarkCyan '---<(  ' -nonewline; 
            write-host -ForegroundColor red 'Error Exception' -nonewline; 
            write-host -ForegroundColor DarkCyan '------<(  ' -NoNewline; 
            write-host -ForegroundColor $color $firstline -NoNewline; 
            if($nonewline){ write-host -ForegroundColor DarkCyan ' ) ' -NoNewLine; } 
            else { write-host -ForegroundColor DarkCyan ' ) ' }       
        }
        if($Action){
            write-host -ForegroundColor DarkCyan '---<(  ' -nonewline; 
            write-host -ForegroundColor Blue 'Action' -nonewline; 
            write-host -ForegroundColor DarkCyan '---------<(  ' -NoNewline; 
            write-host -ForegroundColor $color $firstline -NoNewline; 
            if($nonewline){ write-host -ForegroundColor DarkCyan ' ) ' -NoNewLine; } 
            else { write-host -ForegroundColor DarkCyan ' ) ' }       
        }
        if($response){
            write-host -ForegroundColor DarkCyan '---<(  ' -nonewline; 
            write-host -ForegroundColor yellow 'response' -nonewline; 
            write-host -ForegroundColor DarkCyan '---<(  ' -NoNewline; 
            write-host -ForegroundColor $color $firstline -NoNewline; 
            if($nonewline){ write-host -ForegroundColor DarkCyan ' ) ' -NoNewLine; } 
            else { write-host -ForegroundColor DarkCyan ' ) ' }       
        }
    }
   # two line write
   if($numlines -eq 2)
   {
        # Line write supporting single value
        if($Notification)
        {
            write-host -ForegroundColor DarkCyan '---<(  ' -nonewline; 
            write-host -ForegroundColor DarkRed 'Notification' -nonewline; 
            write-host -ForegroundColor DarkCyan '---<(  ' -NoNewline; 
            write-host -ForegroundColor $color $firstline -NoNewline; 
            write-host -ForegroundColor DarkCyan ' ) ' -nonewline; 
            write-host -ForegroundColor DarkCyan '---<(  ' -NoNewline; 
            write-host -ForegroundColor Magenta $secondline -NoNewline; 
            if($nonewline){ write-host -ForegroundColor DarkCyan ' ) ' -NoNewLine; } 
            else { write-host -ForegroundColor DarkCyan ' ) ' }
        }
        if($requestinput)
        {
            write-host -ForegroundColor DarkCyan '---<(  ' -nonewline; 
            write-host -ForegroundColor DarkGreen 'Request User Input' -nonewline;
            write-host -ForegroundColor DarkCyan '--< ' -NoNewline; 
            write-host -ForegroundColor $color $firstline -NoNewline; 
            write-host -ForegroundColor DarkCyan ' ) ' -nonewline; 
            write-host -ForegroundColor DarkCyan '---<(  ' -NoNewline; 
            write-host -ForegroundColor Magenta $secondline -NoNewline; 
            if($nonewline){ write-host -ForegroundColor DarkCyan ' ) ' -NoNewLine; } 
            else { write-host -ForegroundColor DarkCyan ' ) ' }
        }
        if($error)
        {
            write-host -ForegroundColor DarkCyan '---<(  ' -nonewline; 
            write-host -ForegroundColor Red 'Error Exception' -nonewline; 
            write-host -ForegroundColor DarkCyan '--< ' -NoNewline; 
            write-host -ForegroundColor $color $firstline -NoNewline; 
            write-host -ForegroundColor DarkCyan ' ) ' -nonewline; 
            write-host -ForegroundColor DarkCyan '---<(  ' -NoNewline; 
            write-host -ForegroundColor Magenta $secondline -NoNewline; 
            if($nonewline){ write-host -ForegroundColor DarkCyan ' ) ' -NoNewLine; } 
            else { write-host -ForegroundColor DarkCyan ' ) ' }
        }
        if($Action)
        {
            write-host -ForegroundColor DarkCyan '---<(  ' -nonewline; 
            write-host -ForegroundColor Blue 'Action' -nonewline; 
            write-host -ForegroundColor DarkCyan '--< ' -NoNewline; 
            write-host -ForegroundColor $color $firstline -NoNewline; 
            write-host -ForegroundColor DarkCyan ' ) ' -nonewline; 
            write-host -ForegroundColor DarkCyan '---<(  ' -NoNewline; 
            write-host -ForegroundColor Magenta $secondline -NoNewline; 
            if($nonewline){ write-host -ForegroundColor DarkCyan ' ) ' -NoNewLine; } 
            else { write-host -ForegroundColor DarkCyan ' ) ' }
        }
        if($response)
        {
            write-host -ForegroundColor DarkCyan '---<(  ' -nonewline; 
            write-host -ForegroundColor DarkGreen 'response' -nonewline; 
            write-host -ForegroundColor DarkCyan '---<(  ' -NoNewline; 
            write-host -ForegroundColor $color $firstline -NoNewline; 
            write-host -ForegroundColor DarkCyan ' ) ' -nonewline; 
            write-host -ForegroundColor DarkCyan '---<(  ' -NoNewline; 
            write-host -ForegroundColor Magenta $secondline -NoNewline; 
            if($nonewline) {write-host -ForegroundColor DarkCyan ' ) ' -NoNewLine;}
            else {write-host -ForegroundColor DarkCyan ' ) '}
        }
   }
    # Three line write
    if($numlines -eq 3)
    {
    
        if($Notification)
        {
          
              write-host -ForegroundColor DarkCyan '---<(  ' -nonewline; 
              write-host -ForegroundColor DarkRed 'Notification' -nonewline;
              write-host -ForegroundColor DarkCyan '---<(  ' -NoNewline;
                write-host -ForegroundColor $color $firstline -NoNewline;
              write-host -ForegroundColor DarkCyan ' ) ' -NoNewline;
              write-host -ForegroundColor DarkCyan ' ---<(  ' -NoNewline;
                write-host -ForegroundColor Magenta $secondline -NoNewline;
              write-host -ForegroundColor DarkCyan ' ) ' -NoNewline;
              write-host -ForegroundColor DarkCyan ' ---<(  ' -NoNewline;
                write-host -ForegroundColor Green $thirdline -NoNewline;
              if($nonewline){write-host -ForegroundColor DarkCyan ' ) ' -NoNewLine;}
              else{write-host -ForegroundColor DarkCyan ' ) ' }
    
        }
        if($Action)
        {
          
              write-host -ForegroundColor DarkCyan '---<(  ' -nonewline; 
              write-host -ForegroundColor Blue 'Action ' -nonewline;
              write-host -ForegroundColor DarkCyan '---<(  ' -NoNewline;
                write-host -ForegroundColor $color $firstline -NoNewline;
              write-host -ForegroundColor DarkCyan ' ) ' -NoNewline;
              write-host -ForegroundColor DarkCyan ' ---<(  ' -NoNewline;
                write-host -ForegroundColor Magenta $secondline -NoNewline;
              write-host -ForegroundColor DarkCyan ' ) ' -NoNewline;
              write-host -ForegroundColor DarkCyan ' ---<(  ' -NoNewline;
                write-host -ForegroundColor Green $thirdline -NoNewline;
              if($nonewline){
                 write-host -ForegroundColor DarkCyan ' ) ' -NoNewLine;
              }else{
                 write-host -ForegroundColor DarkCyan ' ) ' 
              }
    
        }

    }#End Function

    # Three line write
    if($numlines -eq 4)
    {
        <#-------
        Notification
        ---------#>
        if($Notification)
        {
          
              write-host -ForegroundColor DarkCyan '---<(  ' -nonewline; 
              write-host -ForegroundColor DarkRed 'Notification' -nonewline;
              write-host -ForegroundColor DarkCyan '---<(  ' -NoNewline;
                write-host -ForegroundColor $color $firstline -NoNewline;
              write-host -ForegroundColor DarkCyan ' ) ' -NoNewline;
              write-host -ForegroundColor DarkCyan ' ---<(  ' -NoNewline;
                write-host -ForegroundColor Magenta $secondline -NoNewline;
              write-host -ForegroundColor DarkCyan ' ) ' -NoNewline;
              write-host -ForegroundColor DarkCyan ' ---<(  ' -NoNewline;
                write-host -ForegroundColor Green $thirdline -NoNewline;
              write-host -ForegroundColor DarkCyan ' ) ' -NoNewline;
              write-host -ForegroundColor DarkCyan ' ---<(  ' -NoNewline;
                write-host -ForegroundColor Green $fourthline -NoNewline;
              if($nonewline){
                 write-host -ForegroundColor DarkCyan ' ) ' -NoNewLine;
              }else{
                 write-host -ForegroundColor DarkCyan ' ) ' 
              }
    
        }
        <#-------
        Action
        ---------#>
        if($Action)
        {
          
              write-host -ForegroundColor DarkCyan '---<(  ' -nonewline; 
              write-host -ForegroundColor yellow 'Action' -nonewline;
              write-host -ForegroundColor DarkCyan '---<(  ' -NoNewline;
                write-host -ForegroundColor $color $firstline -NoNewline;
              write-host -ForegroundColor DarkCyan ' ) ' -NoNewline;
              write-host -ForegroundColor DarkCyan ' ---<(  ' -NoNewline;
                write-host -ForegroundColor Magenta $secondline -NoNewline;
              write-host -ForegroundColor DarkCyan ' ) ' -NoNewline;
              write-host -ForegroundColor DarkCyan ' ---<(  ' -NoNewline;
                write-host -ForegroundColor Green $thirdline -NoNewline;
              write-host -ForegroundColor DarkCyan ' ) ' -NoNewline;
              write-host -ForegroundColor DarkCyan ' ---<(  ' -NoNewline;
                write-host -ForegroundColor Green $fourthline -NoNewline;
              if($nonewline){
                 write-host -ForegroundColor DarkCyan ' ) ' -NoNewLine;
              }else{
                 write-host -ForegroundColor DarkCyan ' ) ' 
              }
    
        }

    }#End Function
    if($numlines -eq 5)
    {
        <#-------
        Notification
        ---------#>
        if($Notification)
        {
          
              write-host -ForegroundColor DarkCyan '---<(  ' -nonewline; 
              write-host -ForegroundColor DarkRed 'Notification' -nonewline;
              write-host -ForegroundColor DarkCyan '---<(  ' -NoNewline;
                write-host -ForegroundColor $color $firstline -NoNewline;
              write-host -ForegroundColor DarkCyan ' ) ' -NoNewline;
              write-host -ForegroundColor DarkCyan ' ---<(  ' -NoNewline;
                write-host -ForegroundColor Magenta $secondline -NoNewline;
              write-host -ForegroundColor DarkCyan ' ) ' -NoNewline;
              write-host -ForegroundColor DarkCyan ' ---<(  ' -NoNewline;
                write-host -ForegroundColor Green $thirdline -NoNewline;
              write-host -ForegroundColor DarkCyan ' ) ' -NoNewline;
              write-host -ForegroundColor DarkCyan ' ---<(  ' -NoNewline;
                write-host -ForegroundColor Green $fourthline -NoNewline;
              write-host -ForegroundColor DarkCyan ' ) ' -NoNewline;
              write-host -ForegroundColor DarkCyan ' ---<(  ' -NoNewline;
                write-host -ForegroundColor Green $fifthline -NoNewline;
              if($nonewline){
                 write-host -ForegroundColor DarkCyan ' ) ' -NoNewLine;
              }else{
                 write-host -ForegroundColor DarkCyan ' ) ' 
              }
    
        }
        <#-------
        Action
        ---------#>
        if($Action)
        {
          
              write-host -ForegroundColor DarkCyan '---<(  ' -nonewline; 
              write-host -ForegroundColor Blue 'Action' -nonewline;
              write-host -ForegroundColor DarkCyan '---<(  ' -NoNewline;
                write-host -ForegroundColor $color $firstline -NoNewline;
              write-host -ForegroundColor DarkCyan ' ) ' -NoNewline;
              write-host -ForegroundColor DarkCyan ' ---<(  ' -NoNewline;
                write-host -ForegroundColor Magenta $secondline -NoNewline;
              write-host -ForegroundColor DarkCyan ' ) ' -NoNewline;
              write-host -ForegroundColor DarkCyan ' ---<(  ' -NoNewline;
                write-host -ForegroundColor Green $thirdline -NoNewline;
              write-host -ForegroundColor DarkCyan ' ) ' -NoNewline;
              write-host -ForegroundColor DarkCyan ' ---<(  ' -NoNewline;
                write-host -ForegroundColor Green $forthline -NoNewline;
              write-host -ForegroundColor DarkCyan ' ) ' -NoNewline;
              write-host -ForegroundColor DarkCyan ' ---<(  ' -NoNewline;
                write-host -ForegroundColor Green $fifthline -NoNewline;
              if($nonewline){
                 write-host -ForegroundColor DarkCyan ' ) ' -NoNewLine;
              }else{
                 write-host -ForegroundColor DarkCyan ' ) ' 
              }
    
        }

    }#End Function

   }
