$Source = @"
	[DllImport("BluetoothAPIs.dll", SetLastError = true, CallingConvention = CallingConvention.StdCall)]
	[return: MarshalAs(UnmanagedType.U4)]
	static extern UInt32 BluetoothRemoveDevice(IntPtr pAddress);
	public static UInt32 Unpair(UInt64 BTAddress) {
		GCHandle pinnedAddr = GCHandle.Alloc(BTAddress, GCHandleType.Pinned);
		IntPtr pAddress     = pinnedAddr.AddrOfPinnedObject();
		UInt32 result       = BluetoothRemoveDevice(pAddress);
		pinnedAddr.Free();
		return result;
	}
"@
Function Get-BTDevice {
    Get-PnpDevice -class Bluetooth | Where-Object { $_.HardwareID -match 'DEV_' } |
    Select-Object Status, Class, FriendlyName, HardwareID,
				# Extract device address from HardwareID
				@{N = 'Address'; E = { [uInt64]('0x{0}' -f $_.HardwareID[0].Substring(12)) } }
}

################## Execution Begins Here ################

$BTR = Add-Type -MemberDefinition $Source -Name "BTRemover"  -Namespace "BStuff" -PassThru
$BTDevices = @(Get-BTDevice) # Force array if null or single item

Do {
    If ($BTDevices.Count) {
        "`n******** Bluetooth Devices ********`n" | Write-Host
        For ($i = 0; $i -lt $BTDevices.Count; $i++) {
			('{0,5} - {1} ({2}/{3}/{4})' -f ($i + 1), $BTDevices[$i].FriendlyName, $BTDevices[$i].Status, $BTDevices[$i].Class, $BTDevices[$i].Address) | Write-Host
        }
        $selected = Read-Host "`nSelect a device to remove (0 to Exit)"
        If ([int]$selected -in 1..$BTDevices.Count) {
            'Removing device: {0}' -f $BTDevices[$Selected - 1].FriendlyName | Write-Host
            $Result = $BTR::Unpair($BTDevices[$Selected - 1].Address)
            If (!$Result) {
                "Device removed successfully." | Write-Host
            }
            Else {
				("Sorry, an error occured. Return was: {0}" -f $Result) | Write-Host
            }
        }
    }
    Else {
        "`n********* No devices found ********" | Write-Host
    }
} While (($BTDevices = @(Get-BTDevice)) -and [int]$selected)
Write-Host "`n`nPress any key to exit...";
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');

