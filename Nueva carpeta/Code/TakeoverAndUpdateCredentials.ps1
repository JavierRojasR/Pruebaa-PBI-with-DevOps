## PowerShell Modules

Install-Module -Name MicrosoftPowerBIMgmt.Profile -Verbose -Scope CurrentUser -Force
Install-Module -Name MicrosoftPowerBIMgmt.Workspaces -Verbose -Scope CurrentUser -Force

## Variables

$datasetname="ClimaValencia"
$workspacename=""

$client_id=''
$tenant_id=''
$clientsec = "" | ConvertTo-SecureString -AsPlainText -Force

## PowerBI Connection

$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $client_id, $clientsec 
Connect-PowerBIServiceAccount -ServicePrincipal -Credential $credential -TenantId $tenant_id

## Getworksapce

$workspace =Get-PowerBIWorkspace -Name $workspacename

# GetDataSets
$DatasetResponse=Invoke-PowerBIRestMethod -Url "groups/$($workspace.id)/datasets" -Method Get | ConvertFrom-Json


# Get DataSet
$datasets = $DatasetResponse.value

     foreach($dataset in $datasets){
                if($dataset.name -eq $datasetname){
                $datasetid= $dataset.id;
                break;
                }

            }

## Take Over DataSet

Invoke-PowerBIRestMethod -Url "groups/$($workspace.id)/datasets/$($datasetid)/Default.TakeOver" -Method Post

## update data source credentials

$BounGateway=Invoke-PowerBIRestMethod -Url "groups/$($workspace.id)/datasets/$($datasetid)/Default.GetBoundGatewayDataSources" -Method GET | ConvertFrom-Json


$UpdateUserCredential = @{
            credentialType ="Basic"
            basicCredentials = @{            
            username= ''
            password= ''
            }
} | ConvertTo-Json



Invoke-PowerBIRestMethod -Url "gateways/$($BounGateway.value.gatewayId)/datasources/$($BounGateway.value.id)" -Method PATCH -Body $UpdateUserCredential | ConvertFrom-Json

