break


http://en.community.dell.com/techcenter/extras/m/white_papers/20444043 

$Nodes = "FSDEBSNE0423.mgmt.fsadm.vwfs-ad","FSDEBSNE0424.mgmt.fsadm.vwfs-ad"
Test-Cluster -Node $Nodes -Include "Storage Spaces Direct","Netzwerk???","Hyper-V-Konfiguration","Inventar","Systemkonfiguration"
