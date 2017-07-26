<#
Powershell scripts that create Azure Storage Table SAS tokens and saves them to a local csv file.
The script will iterate through each subscriptions and each storage account within a susbscription and create tokens with "read, list" permissions.
Tokens are defaulted to expire 3 months after the day this script was executed. This can be changed by adjusting the "expiryTime" variable.
#>

$now = Get-Date
$expiryTime = $now.AddMonths(3)
$subs = Get-AzureRmSubscription
$sasTokens = @()
foreach ($sub in $subs) {
	Set-AzureRmContext -SubscriptionName $sub.SubscriptionName
	$stgacts = Get-AzureRmStorageAccount
	foreach($act in $stgacts){
		$token = New-AzureStorageAccountSASToken -Service Table -ResourceType Service,Container,Object -Permission "rl" -Context $act.Context -ExpiryTime $expiryTime
		$ep = $ep = $act.Context.TableEndPoint
		$subId = $sub.SubscriptionId
		$rgName = $act.ResourceGroupName
		$stgId = $act.Id
		$sasTokenEntry = "$subId, $rgName, $expiryTime, $stgId, $ep$token"

		$sasTokens = $sasTokens + $sasTokenEntry
	}
}

$edate = Get-Date $expiryTime.ToString() -format "yyyy_mm_dd"

$filename = "cloudability-SAStokens-$edate.csv"
$sasTokens | Out-File -FilePath $filename
