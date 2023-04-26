# pwsh modifyTriggers.ps1 -WorkspaceName <synapse-workspace> -action <disable/enable>

[CmdletBinding()]
param(
    [parameter(mandatory)] [string] $WorkspaceName,
    [parameter(mandatory)] [string] $action
)

#Import needed modules
Import-Module Az.Synapse

$triggers = Get-AzSynapseTrigger -WorkspaceName $WorkspaceName

if ($action -eq 'disable') {
    Write-Host "Disabling triggers for workspace: $($WorkspaceName)"
    $triggers | ForEach-Object { Stop-AzSynapseTrigger -WorkspaceName $WorkspaceName -Name $_.name -Force }
}
elseif ($action -eq 'enable') {
    Write-Host "Enabling triggers for workspace: $($WorkspaceName)"
    $triggers | ForEach-Object { Start-AzSynapseTrigger -WorkspaceName $WorkspaceName -Name $_.name -Force }
}
else {
    Write-Host "Doing nothing, i don't know action: $($action)"
}
