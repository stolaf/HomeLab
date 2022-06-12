Start-Process 'C:\Users\olaf\Nextcloud\Github\HomeLab\hardware\server-01\IPMI\Redfish_Ref_Guide_2.0.pdf'

$Headers = @{Authorization = "Basic QURNSU46MTlJTCEhZmlkRHI0IzYx"}
Invoke-WebRequest -Uri "https://192.168.178.15/redfish/v1/Managers/1" -Method Get -Headers $Headers -SkipCertificateCheck
$WebRequest = Invoke-WebRequest -Uri "https://192.168.178.15/redfish/v1/Systems/1" -Method Get -Headers $Headers -SkipCertificateCheck
$WebRequest.Content | ConvertFrom-Json 
($WebRequest.Content | ConvertFrom-Json).ProcessorSummary
($WebRequest.Content | ConvertFrom-Json).MemorySummary
($WebRequest.Content | ConvertFrom-Json).PowerState
Invoke-RestMethod -Method Get -Uri "https://192.168.178.15/redfish/v1/Systems/1" -SkipCertificateCheck -Headers $Headers

$WebRequest = Invoke-WebRequest -Uri "https://192.168.178.15/redfish/v1/Chassis/1" -Method Get -Headers $Headers -SkipCertificateCheck
$WebRequest.Content | ConvertFrom-Json 
Invoke-RestMethod -Method Get -Uri "https://192.168.178.15/redfish/v1/Chassis/1" -SkipCertificateCheck -Headers $Headers

$WebRequest = Invoke-WebRequest -Uri "https://192.168.178.15/redfish/v1/Chassis/1/Thermal" -Method Get -Headers $Headers -SkipCertificateCheck
($WebRequest.Content | ConvertFrom-Json).Temperatures

$WebRequest = Invoke-WebRequest -Uri "https://192.168.178.15/redfish/v1/Chassis/1/Power" -Method Get -Headers $Headers -SkipCertificateCheck
($WebRequest.Content | ConvertFrom-Json).Voltages

$WebRequest = Invoke-WebRequest -Uri "https://192.168.178.15/redfish/v1/SessionService/" -Method Get -Headers $Headers -SkipCertificateCheck
($WebRequest.Content | ConvertFrom-Json) 

$WebRequest = Invoke-WebRequest -Uri "https://192.168.178.15/redfish/v1/Managers/1/FanMode" -Method Get -Headers $Headers -SkipCertificateCheck
($WebRequest.Content | ConvertFrom-Json)    #.'Mode@Redfish.AllowableValues'

$WebRequest = Invoke-WebRequest -Uri "https://192.168.178.15/redfish/v1/Chassis/1/Thermal" -Method Get -Headers $Headers -SkipCertificateCheck
($WebRequest.Content | ConvertFrom-Json).Temperatures
($WebRequest.Content | ConvertFrom-Json).Fans | ? {$_.Status.State -notmatch 'Absent'}

$WebRequest = Invoke-WebRequest -Uri "https://192.168.178.15/redfish/v1/Systems/1/Processors/1" -Method Get -Headers $Headers -SkipCertificateCheck
($WebRequest.Content | ConvertFrom-Json) 

$WebRequest = Invoke-WebRequest -Uri "https://192.168.178.15/redfish/v1/Systems/1/EthernetInterfaces" -Method Get -Headers $Headers -SkipCertificateCheck
($WebRequest.Content | ConvertFrom-Json)

$WebRequest = Invoke-WebRequest -Uri "https://192.168.178.15/redfish/v1/Systems/1/EthernetInterfaces/4" -Method Get -Headers $Headers -SkipCertificateCheck
($WebRequest.Content | ConvertFrom-Json)

$WebRequest = Invoke-WebRequest -Uri "https://192.168.178.15/redfish/v1/Systems/1/LogServices/Log1/Entries" -Method Get -Headers $Headers -SkipCertificateCheck
($WebRequest.Content | ConvertFrom-Json).Members | ft -AutoSize

$WebRequest = Invoke-WebRequest -Uri "https://192.168.178.15/redfish/v1/Managers/1/VM1/CfgCD" -Method Get -Headers $Headers -SkipCertificateCheck
($WebRequest.Content | ConvertFrom-Json)  #.Actions

$WebRequest = Invoke-WebRequest -Uri "https://192.168.178.15/redfish/v1/Managers/1/VM1/CfgCD/Actions/IsoConfig.Mount" -Method Get -Headers $Headers -SkipCertificateCheck
($WebRequest.Content | ConvertFrom-Json)

$WebRequest = Invoke-WebRequest -Uri "https://192.168.178.15/redfish/v1/AccountService/Roles" -Method Get -Headers $Headers -SkipCertificateCheck
($WebRequest.Content | ConvertFrom-Json).Members

$WebRequest = Invoke-WebRequest -Uri "https://192.168.178.15/redfish/v1/AccountService/Roles/Administrator" -Method Get -Headers $Headers -SkipCertificateCheck
($WebRequest.Content | ConvertFrom-Json)

$WebRequest = Invoke-WebRequest -Uri "https://192.168.178.15/redfish/v1/AccountService/Accounts/2" -Method Get -Headers $Headers -SkipCertificateCheck
($WebRequest.Content | ConvertFrom-Json)

$WebRequest = Invoke-WebRequest -Uri "https://192.168.178.15/redfish/v1/Systems/1/Processors/1" -Method Get -Headers $Headers -SkipCertificateCheck
($WebRequest.Content | ConvertFrom-Json)

#Not licensed to perform this request. The following licenses DCMS  were needed
Invoke-WebRequest -Uri "https://192.168.178.15/redfish/v1/Managers/1/IKVM" -Method Get -Headers $Headers -SkipCertificateCheck

# There are insufficient privileges for the account or credentials associated with the current session to perform the requested operation.
#Note: Redfish BIOS configuration supported on following platforms X11DPU, X11DPU_PLUS, X11DDW, X11DPT-B, X11DPT-B PLUS, X11DPI, X11DDW
$WebRequest = Invoke-WebRequest -Uri "https://192.168.178.15/redfish/v1/Systems/1/Bios" -Method Get -Headers $Headers -SkipCertificateCheck
($WebRequest.Content | ConvertFrom-Json) 


Invoke-WebRequest -Uri "https://192.168.178.15/redfish/v1/Managers/1/IKVM" -Method Get -Headers $Headers -SkipCertificateCheck