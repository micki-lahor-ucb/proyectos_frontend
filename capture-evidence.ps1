# Script para capturar evidencias del CD Frontend
# Uso: .\capture-evidence.ps1 -Environment staging|production

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("staging", "production", "both")]
    [string]$Environment = "both"
)

$ErrorActionPreference = "Continue"

# Configuración
$stagingPort = 2223
$stagingUrl = "http://localhost:8081"
$productionPort = 2224
$productionUrl = "http://localhost:8082"
$sshUser = "deploy"
$sshHost = "localhost"

# Crear directorio para evidencias
$evidenceDir = ".\evidence_frontend_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
New-Item -ItemType Directory -Path $evidenceDir -Force | Out-Null

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "🎯 Capturando Evidencias de CD Frontend" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📁 Directorio de evidencias: $evidenceDir" -ForegroundColor Green
Write-Host ""

function Capture-Evidence {
    param(
        [string]$EnvName,
        [int]$Port,
        [string]$Url
    )
    
    Write-Host "================================================" -ForegroundColor Yellow
    Write-Host "📊 Capturando evidencias de: $EnvName" -ForegroundColor Yellow
    Write-Host "================================================" -ForegroundColor Yellow
    Write-Host ""
    
    $envDir = Join-Path $evidenceDir $EnvName
    New-Item -ItemType Directory -Path $envDir -Force | Out-Null
    
    # 1. Estado del symlink
    Write-Host "🔗 1. Capturando estado del symlink..." -ForegroundColor Cyan
    $symlinkOutput = Join-Path $envDir "01_symlink_status.txt"
    
    ssh -p $Port ${sshUser}@${sshHost} @"
echo '=== Symlink Current ==='
readlink -f /var/www/frontend/current
echo ''
echo '=== Lista de Releases ==='
ls -lht /var/www/frontend/releases/ | head -10
echo ''
echo '=== Detalle del directorio current ==='
ls -la /var/www/frontend/current | head -20
"@ | Out-File -FilePath $symlinkOutput -Encoding UTF8
    
    Write-Host "   ✅ Guardado en: $symlinkOutput" -ForegroundColor Green
    
    # 2. Health check
    Write-Host "🏥 2. Capturando health check..." -ForegroundColor Cyan
    $healthOutput = Join-Path $envDir "02_health_check.txt"
    
    try {
        $healthResponse = Invoke-WebRequest -Uri "$Url/health" -Method Get -TimeoutSec 10 -UseBasicParsing
        @"
=== Health Check - $EnvName ===
URL: $Url/health
Status Code: $($healthResponse.StatusCode)
Status Description: $($healthResponse.StatusDescription)
Response:
$($healthResponse.Content)

Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
"@ | Out-File -FilePath $healthOutput -Encoding UTF8
        Write-Host "   ✅ Health check OK (HTTP $($healthResponse.StatusCode))" -ForegroundColor Green
    } catch {
        @"
=== Health Check - $EnvName ===
URL: $Url/health
Status: FAILED
Error: $($_.Exception.Message)

Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
"@ | Out-File -FilePath $healthOutput -Encoding UTF8
        Write-Host "   ❌ Health check FAILED" -ForegroundColor Red
    }
    
    # 3. Release info
    Write-Host "📋 3. Capturando release info..." -ForegroundColor Cyan
    $releaseOutput = Join-Path $envDir "03_release_info.json"
    
    try {
        $releaseInfo = Invoke-RestMethod -Uri "$Url/release-info.json" -Method Get -TimeoutSec 10
        $releaseInfo | ConvertTo-Json -Depth 5 | Out-File -FilePath $releaseOutput -Encoding UTF8
        Write-Host "   ✅ Release ID: $($releaseInfo.releaseId)" -ForegroundColor Green
        Write-Host "   ✅ Commit: $($releaseInfo.commit)" -ForegroundColor Green
        Write-Host "   ✅ Version: $($releaseInfo.version)" -ForegroundColor Green
    } catch {
        @"
{
  "error": "Release info not available",
  "message": "$($_.Exception.Message)",
  "timestamp": "$(Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ')"
}
"@ | Out-File -FilePath $releaseOutput -Encoding UTF8
        Write-Host "   ⚠️  Release info no disponible" -ForegroundColor Yellow
    }
    
    # 4. Frontend page capture
    Write-Host "🌐 4. Capturando página principal..." -ForegroundColor Cyan
    $pageOutput = Join-Path $envDir "04_frontend_page.html"
    
    try {
        $pageResponse = Invoke-WebRequest -Uri $Url -Method Get -TimeoutSec 10 -UseBasicParsing
        @"
<!-- Frontend Page Capture - $EnvName -->
<!-- URL: $Url -->
<!-- Status: $($pageResponse.StatusCode) -->
<!-- Captured: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -->

$($pageResponse.Content)
"@ | Out-File -FilePath $pageOutput -Encoding UTF8
        Write-Host "   ✅ Página capturada (HTTP $($pageResponse.StatusCode))" -ForegroundColor Green
    } catch {
        Write-Host "   ⚠️  No se pudo capturar la página" -ForegroundColor Yellow
    }
    
    # 5. Server configuration
    Write-Host "⚙️  5. Capturando configuración del servidor..." -ForegroundColor Cyan
    $configOutput = Join-Path $envDir "05_server_config.txt"
    
    ssh -p $Port ${sshUser}@${sshHost} @"
echo '=== Espacio en disco ==='
df -h /var/www/frontend
echo ''
echo '=== Número de releases ==='
ls -1 /var/www/frontend/releases/ | wc -l
echo ''
echo '=== Permisos ==='
ls -ld /var/www/frontend/current
echo ''
echo '=== Contenido del release actual ==='
du -sh /var/www/frontend/current
find /var/www/frontend/current -type f | wc -l
echo 'archivos en total'
"@ | Out-File -FilePath $configOutput -Encoding UTF8
    
    Write-Host "   ✅ Guardado en: $configOutput" -ForegroundColor Green
    Write-Host ""
}

# Capturar evidencias según el ambiente seleccionado
if ($Environment -eq "staging" -or $Environment -eq "both") {
    Capture-Evidence -EnvName "staging" -Port $stagingPort -Url $stagingUrl
}

if ($Environment -eq "production" -or $Environment -eq "both") {
    Capture-Evidence -EnvName "production" -Port $productionPort -Url $productionUrl
}

# Capturar logs de GitHub Actions (requiere gh CLI)
Write-Host "================================================" -ForegroundColor Yellow
Write-Host "📜 Capturando logs de GitHub Actions..." -ForegroundColor Yellow
Write-Host "================================================" -ForegroundColor Yellow

if (Get-Command gh -ErrorAction SilentlyContinue) {
    try {
        $actionsOutput = Join-Path $evidenceDir "06_github_actions.txt"
        
        Write-Host "🔍 Obteniendo últimas ejecuciones del workflow..." -ForegroundColor Cyan
        gh run list --workflow="cd-staging-prod.yml" --limit 5 | Out-File -FilePath $actionsOutput -Encoding UTF8
        
        Write-Host "   ✅ Logs guardados en: $actionsOutput" -ForegroundColor Green
        Write-Host ""
        Write-Host "💡 Para ver detalles de una ejecución:" -ForegroundColor Cyan
        Write-Host "   gh run view <run-id>" -ForegroundColor White
        Write-Host ""
    } catch {
        Write-Host "   ⚠️  No se pudo capturar logs de GitHub Actions" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ⚠️  GitHub CLI (gh) no está instalado" -ForegroundColor Yellow
    Write-Host "   💡 Instalar con: winget install GitHub.cli" -ForegroundColor Cyan
}

# Crear README con instrucciones
Write-Host "📝 Creando README de evidencias..." -ForegroundColor Cyan
$readmeOutput = Join-Path $evidenceDir "README.md"

@"
# Evidencias de Continuous Delivery - Frontend

Capturado el: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

## 📁 Estructura de Archivos

``````
evidence_frontend_*/
├── staging/
│   ├── 01_symlink_status.txt       # Estado del symlink y releases
│   ├── 02_health_check.txt         # Verificación de health endpoint
│   ├── 03_release_info.json        # Metadata del release actual
│   ├── 04_frontend_page.html       # Captura de la página principal
│   └── 05_server_config.txt        # Configuración del servidor
├── production/
│   ├── 01_symlink_status.txt
│   ├── 02_health_check.txt
│   ├── 03_release_info.json
│   ├── 04_frontend_page.html
│   └── 05_server_config.txt
├── 06_github_actions.txt           # Logs de GitHub Actions
└── README.md                        # Este archivo
``````

## ✅ Checklist de Evidencias para TP2

### 1. Pipeline Run Staging
- [ ] Screenshot del workflow ejecutándose
- [ ] URL: https://github.com/micki-lahor-ucb/proyectos_frontend/actions
- [ ] Ver archivo: staging/01_symlink_status.txt

### 2. Pipeline Run Production
- [ ] Screenshot de la pausa esperando aprobación
- [ ] Screenshot post-aprobación con nombre del aprobador
- [ ] Pipeline verde completo
- [ ] Ver archivo: production/01_symlink_status.txt

### 3. Symlink Current
- [ ] Captura mostrando symlink apuntando a release correcto
- [ ] Ver archivos: */01_symlink_status.txt

### 4. Health Checks
- [ ] Staging: HTTP 200 OK
- [ ] Production: HTTP 200 OK
- [ ] Ver archivos: */02_health_check.txt

### 5. Release Info
- [ ] Metadata del release visible
- [ ] Ver archivos: */03_release_info.json

### 6. Rollback (si aplica)
- [ ] Captura del rollback ejecutándose
- [ ] Symlink apuntando a versión anterior
- [ ] Health check OK post-rollback

## 🔍 Comandos para Verificación Manual

### Ver Symlink Actual
``````bash
# Staging
ssh -p 2223 deploy@localhost "readlink -f /var/www/frontend/current"

# Production
ssh -p 2224 deploy@localhost "readlink -f /var/www/frontend/current"
``````

### Health Checks
``````bash
# Staging
curl -v http://localhost:8081/health
curl http://localhost:8081/release-info.json

# Production
curl -v http://localhost:8082/health
curl http://localhost:8082/release-info.json
``````

### Ver Releases Disponibles
``````bash
# Staging
ssh -p 2223 deploy@localhost "ls -lht /var/www/frontend/releases/"

# Production
ssh -p 2224 deploy@localhost "ls -lht /var/www/frontend/releases/"
``````

## 📊 Información de Despliegue

Ver [CD-DEPLOYMENT-GUIDE.md](../CD-DEPLOYMENT-GUIDE.md) para documentación completa.

## 🎓 Notas para Evaluación

Estas evidencias demuestran:
- ✅ Build único de artefacto
- ✅ Despliegue atómico vía symlink
- ✅ Health checks como gates
- ✅ Approvals en producción
- ✅ Rollback preparado
- ✅ Observabilidad con release info

---
*Generado automáticamente por capture-evidence.ps1*
"@ | Out-File -FilePath $readmeOutput -Encoding UTF8

Write-Host "   ✅ README creado: $readmeOutput" -ForegroundColor Green

# Resumen final
Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host "✅ Captura de Evidencias Completada" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""
Write-Host "📁 Directorio: $evidenceDir" -ForegroundColor White
Write-Host ""
Write-Host "📋 Archivos capturados:" -ForegroundColor Cyan
Get-ChildItem -Path $evidenceDir -Recurse -File | ForEach-Object {
    $relativePath = $_.FullName.Replace($evidenceDir, ".")
    Write-Host "   - $relativePath" -ForegroundColor Gray
}
Write-Host ""
Write-Host "💡 Próximos pasos:" -ForegroundColor Cyan
Write-Host "   1. Revisar los archivos en el directorio de evidencias" -ForegroundColor White
Write-Host "   2. Capturar screenshots del pipeline en GitHub Actions" -ForegroundColor White
Write-Host "   3. Documentar el proceso de approval en producción" -ForegroundColor White
Write-Host "   4. Compilar todas las evidencias para la entrega del TP2" -ForegroundColor White
Write-Host ""
