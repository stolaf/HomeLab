break

#https://msdn.microsoft.com/en-us/library/aa371730(v=vs.85).aspx
$NodeSetting = Get-WmiObject -Class 'MicrosoftNLB_NodeSetting' -Namespace 'root\MicrosoftNLB'
$NodeSetting.ClusterModeOnStart = $true
$NodeSetting.GetPropertyValue('ClusterModeOnStart')
$NodeSetting.ClusterModeOnStart = $true
(Get-WmiObject -Class 'MicrosoftNLB_NodeSetting' -Namespace 'root\MicrosoftNLB').InvokeMethod('ClusterModeOnStart',$true)