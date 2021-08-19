Stop-Service -name Spooler -force
Set-Service -name spooler -startupType disabled

Add-Content -Path C:\HDDPatchesInstalled.txt -Value '002_Print_Spooler_Disable'