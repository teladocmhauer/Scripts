<# Script configures Distributed MIL server startup options
   to use Run at logon option instead of service. #>

# Pre-configure the firewall settings for DistributedMIL server,
# Matrox Imaging Library (64-bit) to avoid the Windows Defender dialog
# that would otherwise be shown.
Write-Host "Preconfiguring Distributed MIL server firewall options ..."
netsh advfirewall firewall add rule name='DistributedMIL 64-bit server block public TCP' enable=yes profile=Public dir=in action=Block protocol=TCP localip='any' localport='any' remoteip='any' remoteport='any' edge=no program='C:\program files\matrox imaging\tools\milnetworkserver.exe'
netsh advfirewall firewall add rule name='DistributedMIL 64-bit server block public UDP' enable=yes profile=Public dir=in action=Block protocol=UDP localip='any' localport='any' remoteip='any' remoteport='any' edge=no program='C:\program files\matrox imaging\tools\milnetworkserver.exe'
netsh advfirewall firewall add rule name='DistributedMIL 64-bit server block private TCP' enable=yes profile=Private dir=in action=Block protocol=TCP localip='any' localport='any' remoteip='any' remoteport='any' edge=no program='C:\program files\matrox imaging\tools\milnetworkserver.exe'
netsh advfirewall firewall add rule name='DistributedMIL 64-bit server block private UDP' enable=yes profile=Private dir=in action=Block protocol=UDP localip='any' localport='any' remoteip='any' remoteport='any' edge=no program='C:\program files\matrox imaging\tools\milnetworkserver.exe'
Write-Host "... done"

# Reconfigure Distributed MIL server settings.
# Note: Although the 64-bit version of 'milconfig' should be the default we
# use the full path to make sure the correct version is used.
# Options:
#   dmilserverprocess 0: Run as a system service
#   dmilserverprocess 1: Manually launched
#   dmilserverprocess 2: Run at every logon with user credentials
#
Write-Host "Reconfiguring Distributed MIL server startup options ..."
$distMilCfgCmd = '"C:\Program Files\Matrox Imaging\tools\milconfig.exe" `-dmilserverprocess 2'
try {
    Invoke-Expression "& $distMilCfgCmd"
} catch {
    Write-Host "Failed to change Distributed MIL server config. Check CMD output."
}
Write-Host "... done."

# Update HDDPatchesInstalled.txt
ECHO "006 dMIL_Use_User_Login" | Out-File "C:\HDDPatchesInstalled.txt" -Encoding ASCII -Append
