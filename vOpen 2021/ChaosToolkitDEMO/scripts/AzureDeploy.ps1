if (!(Get-AzContext)) {
    Connect-AzAccount
}

$context = Get-AzContext
if ($context) {
    $templateFile = Join-Path -Path $PSScriptRoot -ChildPath ".."  -AdditionalChildPath "template", "azuredeploy.json"
    $templateParametersFile = Join-Path -Path $PSScriptRoot -ChildPath ".."  -AdditionalChildPath "template", "azuredeploy.parameters.json"
    Write-Host -ForegroundColor Yellow "Iniciando deployment..."
    $deployment = New-AzDeployment -Name "ChaosToolkitDEMO" -TemplateFile $templateFile -TemplateParameterFile $templateParametersFile -Location "eastus" -Verbose

    if ($deployment.Outputs){
        Write-Host -ForegroundColor Yellow "Website A:"
        Invoke-WebRequest -Uri ("https://{0}" -f $deployment.Outputs["regionAAppServiceUrl"].Value)
        Write-Host -ForegroundColor Yellow "Website B:"
        Invoke-WebRequest -Uri ("https://{0}" -f $deployment.Outputs["regionBAppServiceUrl"].Value)
    } else {
        Write-Warning -Message "No hay salida :("
    }

    $deployment | Format-List

    Write-Host -ForegroundColor Yellow "Creando el Azure AD Service Principal.."
    $newSp = New-AzADServicePrincipal -Scope "/subscriptions/$($context.Subscription.Id)" -Role "Contributor" -DisplayName "chaosaadsp" -ErrorVariable newSpError
    if (!$newSpError) {
        $newSpSecret = ConvertFrom-SecureString -SecureString $newSp.Secret -AsPlainText
        Write-Host = "Service principal - client ID: $($newSp.ApplicationId)"
        Write-Host = "Service principal - client secret: $($newSpSecret)"
    }
    else {
        Write-Error "Error al crear el service principal :("
    }
}
else {
    Write-Error -Message "No conectado a Azure :("
}