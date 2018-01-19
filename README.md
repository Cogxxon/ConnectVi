# ConnectVi 
### Description
ConnectVI is a wrapper function for `VMWare.PowercCLI` it downloads and caches function to temp folder and loads it into the current PS Instance very basic script but useful saves some typing

#### PowerShell
+ `Find-Module`
+ `Save-Module`
+ `Import-mode`
#### VMWare.PowerCLI
+ `Connect-ViServer`
#### Powershell Custom Embbeded
+ write-segline - *which wraps  `Write-Host` cmdlet

#### Usages
`ConnectVi -Server 'vCenter.contoso.org.au'`

`ConnectVi -Server 'vCenter.contoso.org.au' -path 'your custome cached path'`