<#
A Powershell script that creates a Application principal and assigns it a RBAC role for access to read-only 
resources in Azure.
#>

Function GET-Temppassword() {
	Param(
	[int]$length=18
	)

	$sourcedata="ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890abcdefghijklmnopqrstuvwxyz".ToCharArray()

	For($loop=1; $loop –le $length; $loop++) {
		$TempPassword+=($sourcedata | GET-RANDOM)
	}
	return $TempPassword
}


$appPassword = GET-Temppassword(32)
$sp = New-AzureRmADServicePrincipal -DisplayName "CloudabilityIntegrationApplication" -Password $appPassword
#Sleep here for a few seconds to allow the service principal to propogate
Sleep 30

$app = Get-AzureRmADApplication -ApplicationId $sp.ApplicationId.Guid
$appId = $app.ApplicationId
$appObjectId = $app.ObjectId.Guid


<#
Create a read-only role in each of the subscriptions and 
assign it to the Cloudability application/principal created earlier
#>

$subs = Get-AzureRmSubscription
foreach ($sub in $subs) {
	$subId = $sub.SubscriptionId
	Set-AzureRmContext -SubscriptionName $sub.SubscriptionName
	$role = Get-AzureRmRoleDefinition "Cloudability Metrics Reader Role"
	if (!$role) {
		#Role doesn't exist, create it by using a existing Azure role as a template
		$role = Get-AzureRmRoleDefinition "Virtual Machine Contributor"
		$role.Id = $null
		$role.Name = "Cloudability Metrics Reader Role"
		$role.Description = "Allows for read access to Azure storage, compute, Insight, RateCard and Usage resources."
		$role.Actions.Clear()
		$role.Actions.Add("Microsoft.Compute/*/read")
		$role.Actions.Add("Microsoft.Storage/storageAccounts/listKeys/action")
		$role.Actions.Add("Microsoft.Insights/diagnosticSettings/*/read")
		$role.Actions.Add("Microsoft.Commerce/RateCard/read")
		$role.Actions.Add("Microsoft.Commerce/UsageAggregates/read")
		$role.AssignableScopes.Clear()
		$role.AssignableScopes.Add("/subscriptions/$subId")
		New-AzureRmRoleDefinition -Role $role
	}
	$role = Get-AzureRmRoleDefinition "Cloudability Metrics Reader Role"
	New-AzureRMRoleAssignment -RoleDefinitionName $role.Name  -ServicePrincipalName $sp.ApplicationId -Scope "/subscriptions/$subId"
}

Echo "Add the appId and password in the Cloduability Application Portal"
Echo "appId: $appId, password: $appPassword"