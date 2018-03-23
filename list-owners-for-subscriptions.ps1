<#
A script to identify all owners for each provided subscription.

The $selectedSubIds array defined in line 20 MUST be populated with String IDs before this script is run.  For example:
$selectedSubIds = ("5fccde18-ddac-4c33-9025-95b40cde3335","84ed165f-9cae-43bd-bf0e-ebec2b6f2781")
#>

$now = Get-Date
$formattedCurrentDate = $now.ToString("yyyy_MM_dd_hh_mm_ss")
$ownersFileName = "subscription-owners-list-$formattedCurrentDate.txt"
New-Item -itemType File -Name $ownersFileName

$sessionContext = Get-AzureRmContext

"Starting AzureRM session context" | Out-File -Append $ownersFileName
$sessionContext | Out-File -Append $ownersFileName

Start-Transcript -Path $ownersFileName -Append -NoClobber

$selectedSubIds = @()
Write-Output "Selected subscriptions to query: $selectedSubIds"

foreach ($subscription in $selectedSubIds) {

    Write-Output "`r`n"
    Try {
        Set-AzureRmContext -SubscriptionId $subscription -ErrorAction Stop
    } Catch {
        Write-Warning "Could not set the context to subscription $subscription"
        Continue
    }

    Write-Output "`r`nOwners for subscription $subscription"
    Get-AzureRmRoleAssignment -Scope /subscriptions/$subscription -RoleDefinitionName Owner
}

Stop-Transcript
