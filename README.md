# public-azure-samples
Powershell (and other languages) snippets for Azure
## create-storage-table-sas-tokens.ps1

   This script will create Azure Storage Table REST API SAS tokens that can then be used to fetch raw Azure utilization metrics. 
   
## create-cldy-app-with-rbac.ps1
   The script performs the following actions
   1. Create an AD Service Principal
   2. For every subscription:
      2.1 Create a role with a set of read-only permissions, with the subscription as the scope
      2.2 Assign the role to the service principal created in Step 1
   3. Output the application id and secret for the service principal. Please send generated application id and secret to Cloudability in a secure manner.

