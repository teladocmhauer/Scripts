#These changes are to address security issues found on the Lite v4 Jira ticket DOS-253 

## Lite v4 Microsoft Windows Server Registry Key Configuration Missing (ADV190013) (2 entries)

# Set variables to indicate value and which key to set
$RegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management'
$Name         = 'FeatureSettingsOverride'
$Value        = '72'
# Create the key if it does not exist
If (-NOT (Test-Path $RegistryPath)) {
  New-Item -Path $RegistryPath -Force | Out-Null
}  
# Now set the value
New-ItemProperty -Path $RegistryPath -Name $Name -Value $Value -PropertyType DWORD -Force 

# Set variables to indicate value and key to set
$RegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management'
$Name         = 'FeatureSettingsOverrideMask'
$Value        = '3'
# Create the key if it does not exist
If (-NOT (Test-Path $RegistryPath)) {
  New-Item -Path $RegistryPath -Force | Out-Null
}  
# Now set the value
New-ItemProperty -Path $RegistryPath -Name $Name -Value $Value -PropertyType DWORD -Force 

## Windows Explorer Autoplay Not Disabled for Default User

# Set variables to indicate value and key to set
$RegistryPath = 'HKU:\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer'
$Name         = 'NoDriveTypeAutoRun'
$Value        = '0x91'

# Create the key if it does not exist
If (-NOT (Test-Path $RegistryPath)) {
  New-Item -Path $RegistryPath -Force | Out-Null
}  
# Now set the value
New-ItemProperty -Path $RegistryPath -Name $Name -Value ([byte[]]$Value) -PropertyType Binary -Force 

## Allowed Null Session (4 entries)

# Set variables to indicate value and key to set
$RegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters'
$Name         = 'RestrictNullSessAccess'
$Value        = '1'

# Create the key if it does not exist
If (-NOT (Test-Path $RegistryPath)) {
  New-Item -Path $RegistryPath -Force | Out-Null
}  
# Now set the value
New-ItemProperty -Path $RegistryPath -Name $Name -Value $Value -PropertyType DWORD -Force 

# Set variables to indicate value and key to set
$RegistryPath = 'HKLM:\System\CurrentControlSet\Control\Lsa'
$Name         = 'RestrictAnonymous'
$Value        = '1' # Null sessions can not be used to enumerate shares

# Create the key if it does not exist
If (-NOT (Test-Path $RegistryPath)) {
  New-Item -Path $RegistryPath -Force | Out-Null
}  
# Now set the value
New-ItemProperty -Path $RegistryPath -Name $Name -Value $Value -PropertyType DWORD -Force 

# Set variables to indicate value and key to set
$RegistryPath = 'HKLM:\System\CurrentControlSet\Control\Lsa'
$Name         = 'RestrictAnonymousSAM'
$Value        = '1' # Default setting. Null sessions can not enumerate user names

# Create the key if it does not exist
If (-NOT (Test-Path $RegistryPath)) {
  New-Item -Path $RegistryPath -Force | Out-Null
}  
# Now set the value
New-ItemProperty -Path $RegistryPath -Name $Name -Value $Value -PropertyType DWORD -Force 

# Set variables to indicate value and key to set
$RegistryPath = 'HKLM:\System\CurrentControlSet\Control\Lsa'
$Name         = 'EveryoneIncludesAnonymous'
$Value        = '0' # Default setting. Null sessions have no special rights

# Create the key if it does not exist
If (-NOT (Test-Path $RegistryPath)) {
  New-Item -Path $RegistryPath -Force | Out-Null
}  
# Now set the value
New-ItemProperty -Path $RegistryPath -Name $Name -Value $Value -PropertyType DWORD -Force 

## Microsoft Windows Explorer AutoPlay Not Disabled

# Set variables to indicate value and key to set
$RegistryPath = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer'
$Name         = 'NoDriveTypeAutoRun'
$Value        = '255'

# Create the key if it does not exist
If (-NOT (Test-Path $RegistryPath)) {
  New-Item -Path $RegistryPath -Force | Out-Null
}  
# Now set the value
New-ItemProperty -Path $RegistryPath -Name $Name -Value $Value -PropertyType DWORD -Force 

## Cached Logon Credential Enabled

# Set variables to indicate value and key to set
$RegistryPath = 'HKLM:\Software\Microsoft\Windows Nt\CurrentVersion\Winlogon'
$Name         = 'CachedLogonsCount'
$Value        = '0' #Default is 10

# Create the key if it does not exist
If (-NOT (Test-Path $RegistryPath)) {
  New-Item -Path $RegistryPath -Force | Out-Null
}  
# Now set the value
New-ItemProperty -Path $RegistryPath -Name $Name -Value $Value -PropertyType String -Force 

## Disable USB storage devices for all non admin users. Kaseya places a lite v4 golden GPO backup folder at c:\temp. Restore_Local_Group_Policy.vbs utilizes this backup.
Set-Location C:\temp
Unblock-File Restore_Local_Group_Policy.vbs
.\Restore_Local_Group_Policy.vbs

## Built-in Guest Account Not Renamed at Windows Target System
Rename-LocalUser -Name "Guest" -NewName "GuestDisabled"