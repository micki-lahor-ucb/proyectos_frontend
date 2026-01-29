# CD Frontend - Continuous Delivery Pipeline

## 📋 Descripción

Pipeline de Continuous Delivery para el frontend (Vue 3 + Vite) con despliegue a múltiples ambientes, symlinks atómicos, approvals y rollback automático.

## 🏗️ Arquitectura de Deployment

### Estructura en el Servidor

```
/var/www/frontend/
├── releases/
│   ├── 20260128_143022_a3b4c5d/    # Release 1
│   │   ├── index.html
│   │   ├── assets/
│   │   └── release-info.json
│   ├── 20260128_145033_f6e7a8b/    # Release 2
│   └── 20260128_150044_c9d0e1f/    # Release 3 (actual)
├── current -> releases/20260128_150044_c9d0e1f  # Symlink atómico
└── shared/
    └── .env  # Configuración por ambiente
```

### Flujo de Deployment

1. **Build único** - Se construye una sola vez el artefacto
2. **Staging** - Deploy automático en merge a `main`
3. **Approval** - Pausa para aprobación humana antes de producción
4. **Production** - Deploy con tag `v*` o workflow_dispatch
5. **Health Check** - Verificación POST-deploy
6. **Rollback** - Automático si falla el health check

## 🔐 Secrets Requeridos

### Staging Frontend

En GitHub → Settings → Environments → `staging-frontend`:

```
STAGING_FRONTEND_HOST=localhost  # o IP del servidor
STAGING_FRONTEND_USER=deploy
STAGING_FRONTEND_SSH_KEY=<private-key-content>
STAGING_FRONTEND_PORT=2223  # opcional, default 2223
STAGING_FRONTEND_URL=http://localhost:8081  # para health check
```

### Production Frontend

En GitHub → Settings → Environments → `production-frontend`:

```
PROD_FRONTEND_HOST=localhost
PROD_FRONTEND_USER=deploy
PROD_FRONTEND_SSH_KEY=<private-key-content>
PROD_FRONTEND_PORT=2224  # opcional, default 2224
PROD_FRONTEND_URL=http://localhost:8082
```

**Configurar Protection Rules:**
- ✅ Required reviewers (1-2 personas)
- ✅ Wait timer (opcional, ej: 5 min)

## 🚀 Cómo Desplegar

### Deploy a Staging (Automático)

```bash
git checkout main
git pull origin main
# Cualquier push a main despliega a staging automáticamente
git push origin main
```

### Deploy a Production (Con Aprobación)

```bash
# Crear release tag
git tag -a v1.0.0 -m "release: production deployment with CD pipeline"
git push origin v1.0.0

# O deployment manual
gh workflow run cd-staging-prod.yml
```

El pipeline se pausará esperando aprobación antes de desplegar a producción.

## 🔄 Rollback

### Rollback Automático

Si el health check falla, el rollback se ejecuta automáticamente.

### Rollback Manual

```bash
# Conectarse al servidor
ssh deploy@staging_host -p 2223

# Ver releases disponibles
ls -lt /var/www/frontend/releases/

# Rollback manual
PREV_RELEASE=20260128_143022_a3b4c5d
ln -sfn /var/www/frontend/releases/$PREV_RELEASE /var/www/frontend/current

# Verificar
readlink -f /var/www/frontend/current
curl http://localhost:8081
```

## 📊 Observabilidad

### Release Info Endpoint

El archivo `release-info.json` está disponible en cada deployment:

```bash
curl http://localhost:8081/release-info.json
```

Respuesta:
```json
{
  "releaseId": "20260128_150044_c9d0e1f",
  "commit": "c9d0e1f8a9b0c1d2e3f4a5b6c7d8e9f0",
  "branch": "main",
  "buildDate": "2026-01-28T15:00:44Z",
  "version": "v1.0.0"
}
```

### Verificar Symlink Actual

```bash
# En staging
ssh deploy@staging_host -p 2223 "readlink -f /var/www/frontend/current"

# En production
ssh deploy@production_host -p 2224 "readlink -f /var/www/frontend/current"
```

### Logs del Pipeline

Ver en GitHub Actions:
- **Staging**: Logs completos del deploy
- **Production**: Logs con información de aprobador
- **Rollback**: Logs de recovery automático

## 🧪 Testing Local Pre-Deploy

Ejecutar antes de hacer merge/tag:

```bash
# En proyectos_frontend/
npm ci
npm run lint:check
npm run test
npm run build

# Verificar build
ls -la dist/
```

## 📝 Checklist de Deployment

### Pre-Deploy
- [ ] Tests pasando localmente (`npm test`)
- [ ] Linter sin errores (`npm run lint:check`)
- [ ] Build exitoso (`npm run build`)
- [ ] PR revisado y aprobado
- [ ] Branch actualizado con main

### Post-Deploy Staging
- [ ] Pipeline verde en GitHub Actions
- [ ] Health check OK (200)
- [ ] Symlink apuntando a nueva release
- [ ] `release-info.json` accesible
- [ ] Funcionalidad crítica testeada manualmente

### Post-Deploy Production
- [ ] Approval registrado con nombre del aprobador
- [ ] Pipeline verde
- [ ] Health check OK
- [ ] Symlink correcto
- [ ] Release tag creado y pusheado
- [ ] Release notes documentadas
- [ ] Equipo notificado

## 🛡️ Reglas de Deployment Profesional

1. ✅ **Build una sola vez** - El mismo artefacto se despliega a staging y producción
2. ✅ **Promoción por artefacto** - No recompilar por ambiente
3. ✅ **Despliegue atómico** - Switch instantáneo vía symlink
4. ✅ **Rollback inmediato** - Sin reinstalar dependencias
5. ✅ **Accountability** - Aprobador registrado en logs
6. ✅ **Health checks** - Gates automáticos post-deploy
7. ✅ **Zero-downtime** - Symlink cambio es instantáneo

## 🎯 Evidencias para Evaluación

Para la entrega del TP2, necesitas capturar:

### 1. Pipeline Run Staging
- Screenshot del pipeline ejecutándose
- Link directo: `https://github.com/<user>/proyectos_frontend/actions`

### 2. Pipeline Run Production
- Screenshot mostrando la pausa esperando aprobación
- Screenshot post-aprobación con nombre del aprobador
- Pipeline verde completo

### 3. Symlink Current
```bash
# Captura de estos comandos
ssh deploy@staging -p 2223 "ls -la /var/www/frontend/ && readlink -f /var/www/frontend/current"
ssh deploy@production -p 2224 "ls -la /var/www/frontend/ && readlink -f /var/www/frontend/current"
```

### 4. Health Check
```bash
# Staging
curl -v http://localhost:8081
curl http://localhost:8081/release-info.json

# Production
curl -v http://localhost:8082
curl http://localhost:8082/release-info.json
```

### 5. Rollback (Simulación)
```bash
# Introducir error intencional
git checkout -b feature/break-frontend
echo "ERROR_INTENCIONAL" > src/App.vue
git add . && git commit -m "ci: break frontend intentionally"
git push origin feature/break-frontend

# Merge a main (fallará en staging)
# Verificar rollback automático

# Capturar logs y estado del symlink post-rollback
```

### 6. Release Notes
```bash
git tag -a v1.0.0 -m "release: Frontend CD with atomic deploy and health gates
- Implemented CD pipeline for staging and production
- Atomic deployments via symlink
- Health checks and automatic rollback
- Approval gates for production
- Release traceability with release-info.json"

git push origin v1.0.0
```

## 📚 Comandos Útiles

```bash
# Ver releases en servidor
ssh deploy@host -p PORT "ls -lht /var/www/frontend/releases/ | head -10"

# Ver symlink actual
ssh deploy@host -p PORT "readlink /var/www/frontend/current"

# Cleanup releases antiguas (mantener últimas 5)
ssh deploy@host -p PORT "cd /var/www/frontend/releases && ls -t | tail -n +6 | xargs rm -rf"

# Ver logs nginx (si aplica)
ssh deploy@host -p PORT "tail -f /var/log/nginx/frontend-access.log"
```

## 🔍 Troubleshooting

### Pipeline falla en SSH
- Verificar que los secrets estén configurados correctamente
- Verificar que el puerto SSH sea el correcto
- Probar conexión manual: `ssh -p PORT user@host`

### Health check falla
- Verificar que el servidor web esté corriendo
- Verificar URL en los secrets
- Verificar que el symlink apunte al directorio correcto

### Rollback no funciona
- Verificar que existan releases previas: `ls /var/www/frontend/releases/`
- Verificar permisos del usuario deploy

### Build falla
- Ejecutar `npm ci` en vez de `npm install`
- Limpiar cache: `rm -rf node_modules dist && npm ci`
- Verificar versión de Node: `node --version` (debe ser 20+)

## 🎓 Mensaje para Maestrantes

> "Un release sin verificación es un riesgo.  
> Un deploy sin symlink atómico es incertidumbre.  
> Un pipeline sin approvals en producción es inmadurez.  
> Un equipo que no puede recuperarse rápido no gobierna el sistema, el sistema lo gobierna a él."

---

**Versión:** 1.0.0  
**Última actualización:** Enero 2026
