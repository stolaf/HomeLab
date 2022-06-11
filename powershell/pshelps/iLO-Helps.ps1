break

#ab PS 5 IPMI/BMC  https://4sysops.com/archives/restart-multiple-computers-with-the-powershell-pcsvdevice-module/
# Examples of BMCs are the Integrated Dell Remote Access (iDRAC) or HP Integrated Lights Out (iLO) cards.
# HP iLO not work
Get-Command -Module PcsvDevice
$iLOCredential = Get-Credential -UserName 'ILOINSTALL' -Message 'Input ILOINSTALL Credential'
Get-PcsvDevice -TargetAddress FSDEBSNE0423r -Credential $iLOCredential -ManagementProtocol IPMI 

<# WebServer Installation

    Use an existing web server, or install a new web server for the purpose of delivering the ISO files
    Create a folder to hold the ISO images
    Add ISO file(s)
    Enable directory browsing in Web Services. You can do this with the IIS manager if its a Windows web server. If you created a custom folder for the files, enable directory browsing on that folder.
    You must add a MIME type for the ISO extension. In Server 2008 IIS, you can do this from the HTTP Headers selection in IIS Manager.
    1: .ISO application/octet-stream
    2: .IMG application/octet-stream
    Login to the ILO target server, and open the remote console
    At the top of the window, click on Virtual Drives, and then select URL DVD ROM
    Input the HTTP path to the image file, including the file name. Click connect and it will mount the drive. Path will resemble "http://hostname or IP/folder/filename.ISO"

#>

#region HPiLOCmdlets
https://fsdebsne0152r/html/IRC.application
. 'C:\Program Files (x86)\IRC\IRC.exe' -addr 'FSDEBSNE0152r' -name 'zzview' -password '...'
Import-Module HPiLOCmdlets   # HPBIOSCmdlets, HPOACmdlets
 
Get-HPiLOModuleVersion
Get-Command -Module HPiLOCmdlets #-Name Get*

#Reset
Reset-HPiLORIB -Server $ServerName -Credential $Credential -DisableCertificateAuthentication
#over SSH
cd /map1
reset

if (!$Credential) {$Credential = Get-Credential -UserName 'zzview' -Message 'Input zzview Credential'}
$ServerName = 'FSDEBSNE0162r'  #,'FSDEBSNE0161r'
  
Get-HPiLOFirmwareVersion -Server $ServerName  -Credential $Credential -DisableCertificateAuthentication
$HPiLOFirmwareInfo = Get-HPiLOFirmwareInfo -Server $ServerName  -Credential $Credential -DisableCertificateAuthentication
$HPiLOFirmwareInfo.FirmwareInfo
  
$HPiLOEventlog = Get-HPiLOEventlog -Server $ServerName  -Credential $Credential -DisableCertificateAuthentication
$HPiLOEventlog.EVENT
  
$HPiLOServerInfo = Get-HPiLOServerInfo -Server $ServerName  -Credential $Credential -DisableCertificateAuthentication
$HPiLOServerInfo.FirmwareInfo
  
Get-HPiLOStorageController -Server $ServerName -Credential $Credential -DisableCertificateAuthentication 
Get-HPiLOHostPower -Server $ServerName  -Credential $Credential -DisableCertificateAuthentication 
Find-HPiLO 192.168.9.216-249

Get-HPiLOOneTimeBootOrder -Server $ServerName -Credential $Credential -DisableCertificateAuthentication
$ImageUrl = 'http://localhost/iso/WinPE_PS5.iso'
Mount-HPiLOVirtualMedia -Server $ServerName -Credential $Credential -DisableCertificateAuthentication -Device CDROM -ImageURL $ImageUrl
Set-HPiLOVMStatus  -Server $ServerName -Credential $Credential -DisableCertificateAuthentication -Device CDROM -VMBootOption CONNECT
Set-HPiLOOneTimeBootOrder -Server $ServerName -Credential $Credential -DisableCertificateAuthentication -Device CDROM
Set-HPiLOHostPower -Server $ServerName -Credential $Credential -DisableCertificateAuthentication -HostPower Off
Set-HPiLOHostPower -Server $ServerName -Credential $Credential -DisableCertificateAuthentication -HostPower On

$ImageUrl = 'http://localhost/iso/IMG/Install-HyperVHost.img'
Mount-HPiLOVirtualMedia -Server $ServerName -Credential $Credential -DisableCertificateAuthentication -Device FLOPPY -ImageURL $ImageUrl -Force
Set-HPiLOVMStatus  -Server $ServerName -Credential $Credential -DisableCertificateAuthentication -Device FLOPPY -VMBootOption CONNECT

Dismount-HPiLOVirtualMedia -Server $ServerName -Credential $Credential -DisableCertificateAuthentication -Device CDROM

#\\fsdebsgv4911\iopi_sources$\Install\HP\iLO\windows-LOsamplescripts4.80.0
$RipScriptFileName = "$env:TEMP\ribscript.xml"
@" 
<RIBCL VERSION="2.0">
    <LOGIN USER_LOGIN="zzview" PASSWORD="...">
        <RIB_INFO MODE="write">
            <SET_VM_STATUS DEVICE="CDROM">
                <VM_BOOT_OPTION VALUE="CONNECT"/>
            </SET_VM_STATUS>
        </RIB_INFO>
    </LOGIN>
</RIBCL>"@ | Out-File -FilePath $RipScriptFileName -Encoding ascii -Force
. 'C:\Program Files (x86)\Hewlett-Packard\HP Lights-Out Configuration Utility\HPQLOCFG.exe' -s $ServerName -f $RipScriptFileName

@"
<RIBCL VERSION="2.0">
 <LOGIN USER_LOGIN="zzview" PASSWORD="...">
   <RIB_INFO MODE="write">
    <INSERT_VIRTUAL_MEDIA DEVICE="CDROM" IMAGE_URL="http://192.168.8.2/iso/WinPE_PS5.iso"/>
    <SET_VM_STATUS DEVICE="CDROM">
      <VM_BOOT_OPTION VALUE="BOOT_ONCE"/>
      <VM_WRITE_PROTECT VALUE="YES" />
      <VM_BOOT_OPTION VALUE="CONNECT"/>
    </SET_VM_STATUS>
   </RIB_INFO>
 </LOGIN>
</RIBCL>
"@ | Out-File -FilePath $RipScriptFileName -Encoding ascii -Force
. 'C:\Program Files (x86)\Hewlett-Packard\HP Lights-Out Configuration Utility\HPQLOCFG.exe' -s $ServerName -f $RipScriptFileName

$plink = plink -ssh Administrator@$ILOIP -pw $PSWD -auto_store_key_in_cache 'set /map1/oemhp_vm1/cddr1 oemhp_image=http://IPADDRESS/ISO.iso'
$plink = plink -ssh Administrator@$ILOIP -pw $PSWD -auto_store_key_in_cache 'set /map1/oemhp_vm1/cddr1 oemhp_boot=connect'
$plink = plink -ssh Administrator@$ILOIP -pw $PSWD -auto_store_key_in_cache 'set /map1/oemhp_vm1/cddr1 oemhp_boot=once'

#endregion HPiLOCmdlets

#region HPBIOSCmdlets
Import-Module HPBIOSCmdlets
Get-Command -Module HPBIOSCmdlets -Name Get*
  
if (!$Credential) {$Credential = Get-Credential -UserName 'zzview' -Message 'Input zzview Credential'}
  
$ServerName = 'FSDEBSNE0162r'
$IP = (Resolve-DnsName -Name $ServerName).IPAddress
$conn = Connect-HPBIOS -IP $IP -Credential $Credential
Get-HPBIOSPowerProfile -Connection $conn 
$conn | Disconnect-HPBIOS
#endregion HPBIOSCmdlets


Import-Module HPOACmdlets
  