<#
.SYNOPSIS
    Get-ADHealthCheck.ps1 - Auditoría automatizada de Active Directory y GPOs.
.DESCRIPTION
    Verifica que los servicios críticos de AD estén corriendo y exporta el estado
    de la directiva de complejidad de contraseñas.
#>

Import-Module ActiveDirectory

$ReportPath = "C:\AD_HealthReport_$(Get-Date -Format 'yyyyMMdd').json"
$HealthStatus = [ordered]@{
    Timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    DomainName = (Get-ADDomain).NetBIOSName
    Services   = @{}
}

# 1. Verificar servicios críticos de identidad de Windows Server
$CriticalServices = @("NTDS", "Kdc", "LanmanWorkstation", "Netlogon")
foreach ($Service in $CriticalServices) {
    $Status = (Get-Service -Name $Service -ErrorAction SilentlyContinue).Status
    $HealthStatus.Services[$Service] = if ($Status) { $Status.ToString() } else { "NotInstalled" }
}

# 2. Auditar políticas de complejidad de contraseñas (GPO - Principio de Mínimo Privilegio)
$PasswordPolicy = Get-ADDefaultDomainPasswordPolicy
$HealthStatus["GPO_Password_Complexity"] = $PasswordPolicy.ComplexityEnabled
$HealthStatus["GPO_Min_Password_Length"] = $PasswordPolicy.MinPasswordLength

# 3. Exportar resultados en JSON legible para consumo externo o logs centralizados
$HealthStatus | ConvertTo-Json -Depth 4 | Out-File -FilePath $ReportPath -Encoding utf8

Write-Host "✅ Diagnóstico de Active Directory completado con éxito." -ForegroundColor Green
Write-Host "📊 Reporte generado en: $ReportPath" -ForegroundColor Cyan