# Proxmox Server pve-01

AMD EPYC™ 3251 SoC Processor, 8 Core/16 Thread, 55W  

* Mainboard: Supermicro M11SDV-8C+-LN4F  
<https://www.supermicro.com/en/products/motherboard/M11SDV-8C+-LN4F>  
<https://www.supermicro.com/support/resources/?CFID=e97aac97-835c-4f35-a5c0-9fcae9d734d5&CFTOKEN=0>   

* Einbaublende: MCP-260-00084-0N
* Supports up to 512GB Registered ECC DDR4 2666MHz SDRAM in 4 DIMMs  
  * Micron MEM-DR432L-CL01-ER29  
  * Samsung MEM-DR432L-SL01-ER29  
  * Samsung MEM-DR412L-SL01-LR29  
* M2 SSD: Toshiba KXG50PNV1T02 (1TB) oder KXG50PNV2T04 (2TB)

BMC MAC Address: 00:25:90:bb:71:11
Motherboard Serial Number: WM196S600159  

Alternatives Mini-ITX Board:  
<https://www.asrockrack.com/general/productdetail.asp?Model=EPYC3251D4I-2T#Specifications>  

* 2 x 10GB Ethernet  

## Redfish

SFT-OOB-LIC: C5BF-C310-BA48-0281-BD4F-88AC
https://www.thomas-krenn.com/de/wiki/Redfish
https://www.youtube.com/SupermicroSoftware

Zum Test die Chrome Extension verwenden: Talent API Tester oder Postman Rest Client
oder die Desktop-App ARC

Authorization : Basic QURNSU46MTlJTCEhZmlkRHI0IzYx
Get https://192.168.178.15/redfish/v1/Systems/1

https://ftp.supermicro.org.cn/en/solutions/management-software/redfish
https://www.supermicro.com/support/bios/firmware.aspx

siehe auch .\HomeLab\hardware\server-01\IPMI\redfishexample.ps1