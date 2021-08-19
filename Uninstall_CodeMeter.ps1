<# Script that uninstalls CodeMeter software from Windows 10 OS
   Lite V2 and Lite V3 systems. #>

# Check if this is a valid target system. Since this is targeted
# at OS images SW-20284-001 (V2) and SW-20285-001 (V3) we test
# for appropriate OEM information.
$oemModel = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" -Name "Model")."Model"

$litev2 = "RP Lite V2"
$litev3 = "RP Lite V3"

if ($oemModel -eq $litev2) {
    Write-Host "Found RP Lite V2 - continue ..."
} elseif ($oemModel -eq $litev3) {
    Write-Host "Found RP Lite V3 - continue ..."
} else {
    Write-Host "System is not a RP Lite V2 or RP Lite V3 - Not supported"
    exit -1
}


# Check if 'CodeMeter Runtime Kit Reduced v6.20a' is installed (sanity check)
Write-Host "Verifying CodeMeter is installed ..."
$cmDispName = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{4DEB156B-92BA-416B-8BE9-8C9525A05799}" -Name "DisplayName")."DisplayName"
$cmPublisher = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{4DEB156B-92BA-416B-8BE9-8C9525A05799}" -Name "Publisher")."Publisher"

$displayName = "CodeMeter Runtime Kit Reduced v6.20a"
$publisher = "WIBU-SYSTEMS AG"

if (($cmDispName -eq $displayName) -and ($cmPublisher -eq $publisher)) {
    Write-Host "Found CodeMeter Runtime Kit Reduced v6.20a installation in registry"
} else {
    Write-Host "Did not find CodeMeter Runtime Kit Reduced v6.20a installation in registry - Was it already removed?"
    
    # Update HDDPatchesInstalled.txt based on the assumption that it _was_ already removed. This
    # could lead to double-entries in HDDPatchesInstalled.txt in corner cases.
    ECHO "007 CodeMeter_Remove" | Out-File "C:\HDDPatchesInstalled.txt" -Encoding ASCII -Append
    exit -1
}
Write-Host "... found ..."


# Remove 'CodeMeter Runtime Kit Reduced v6.20a'
# Note: Other versions would likely have a different GUID
Write-Host "Uninstalling CodeMeter ..."
$cmRmCmd = 'MsiExec.exe'
$cmRmArgs = '/x "{4DEB156B-92BA-416B-8BE9-8C9525A05799}" /passive /norestart /log cm-uninstall.log'
try {
    Start-Process $cmRmCmd -ArgumentList $cmRmArgs -Wait
} catch {
    Write-Host "Failed to uninstall CodeMeter. Check CMD output and potentially log file: cm-uninstall.log"
}
Write-Host "... done."


# Update HDDPatchesInstalled.txt
ECHO "007 CodeMeter_Remove" | Out-File "C:\HDDPatchesInstalled.txt" -Encoding ASCII -Append