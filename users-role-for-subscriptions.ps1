<#
This script identifies the current user's roles for the provided subscriptions.

The $selectedSubIds array defined in line 21 MUST be populated with String IDs before this script is run.  For example:
$selectedSubIds = ("5fccde18-ddac-4c33-9025-95b40cde3335","84ed165f-9cae-43bd-bf0e-ebec2b6f2781")
#>

$now = Get-Date
$formattedCurrentDate = $now.ToString("yyyy_MM_dd_hh_mm_ss")
$userRolesFileName = "user-roles-list-$formattedCurrentDate.txt"
New-Item -itemType File -Name $userRolesFileName

$sessionContext = Get-AzureRmContext
$sessionUser = $sessionContext.Account.Id

"Starting AzureRM session context" | Out-File -Append $userRolesFileName
$sessionContext | Out-File -Append $userRolesFileName

Start-Transcript -Path $userRolesFileName -Append -NoClobber

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

    Write-Output "`r`n"
    Get-AzureRmRoleAssignment -Scope /subscriptions/$subscription -SignInName $sessionUser
}

Stop-Transcript
