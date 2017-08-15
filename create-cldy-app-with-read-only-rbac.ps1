<#
Prerequisite: Azure RM v 4.2.0
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



$app = Get-AzureRmADServicePrincipal -SearchString 'CloudabilityIntegrationReadOnlyApplication'
$appPassword = $null
if($app -eq $null){	
	$appPassword = GET-Temppassword(32)
	$sp = New-AzureRmADServicePrincipal -DisplayName "CloudabilityIntegrationReadOnlyApplication" -Password $appPassword
	#Sleep here for a few seconds to allow the service principal to propogate
	Echo "Waiting 30 seconds for service principal to propogate"
	Sleep 30
	$app = Get-AzureRmADApplication -ApplicationId $sp.ApplicationId.Guid
}else{
	$appPassword = "NA"
	Echo "$app exists"
}

$appId = $app.ApplicationId

<#
For more information on Reader role, see: https://docs.microsoft.com/en-us/azure/active-directory/role-based-access-built-in-roles#reader
#>
$subs = Get-AzureRmSubscription
$roleName = "Reader"
foreach ($sub in $subs) {
	$subId = $sub.Id
	Set-AzureRmContext -SubscriptionName $sub.Name
	$roles = Get-AzureRMRoleAssignment -RoleDefinitionName $roleName  -ServicePrincipalName $appId -Scope "/subscriptions/$subId"
	if($roles -eq $null){
		Echo "Creating a new role assignment $roleName for subscription: $subId"
		New-AzureRMRoleAssignment -RoleDefinitionName $roleName  -ServicePrincipalName $appId -Scope "/subscriptions/$subId"
	}else{
		Echo "$roles exists for subscription $subId"
	}
}

$tenantId = $subs[0].TenantId
Echo "Add the appId and password in the Cloduability Application Portal"
Echo "tentantId: $tenantId, appId: $appId, password: $appPassword"
