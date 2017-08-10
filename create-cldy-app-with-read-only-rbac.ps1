<#
A Powershell script that creates a Application principal and assigns it a RBAC role for access to read-only 
resources in Azure.
#>

Function GET-Temppassword() {
	Param(
	[int]$length=18
	)

	$sourcedata="ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890abcdefghijklmnopqrstuvwxyz".ToCharArray()
	
	For($loop=1; $loop -le $length; $loop++) {
		$TempPassword+=($sourcedata | GET-RANDOM)
	}
	return $TempPassword
}


$appPassword = GET-Temppassword(32)
$sp = New-AzureRmADServicePrincipal -DisplayName "CloudabilityIntegrationReadOnlyApplication" -Password $appPassword
#Sleep here for a few seconds to allow the service principal to propogate
Echo "Waiting 30 seconds for service principal to propogate"
Sleep 30

$app = Get-AzureRmADApplication -ApplicationId $sp.ApplicationId.Guid
$appId = $app.ApplicationId
$appObjectId = $app.ObjectId.Guid

<#
For more information on Reader role, see: https://docs.microsoft.com/en-us/azure/active-directory/role-based-access-built-in-roles#reader
#>
$roleName = "Reader"
foreach ($sub in $subs) {
	$subId = $sub.SubscriptionId
	Set-AzureRmContext -SubscriptionName $sub.SubscriptionName
	New-AzureRMRoleAssignment -RoleDefinitionName $roleName  -ServicePrincipalName $sp.ApplicationId -Scope "/subscriptions/$subId"
}

$tenantId = $subs[0].TenantId
Echo "Add the appId and password in the Cloduability Application Portal"
Echo "tentantId: $tenantId, appId: $appId, password: $appPassword"
