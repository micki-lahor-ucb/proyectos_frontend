#!/bin/bash

# Script para configurar el servidor de deployment del frontend
# Uso: ./setup-frontend-server.sh [staging|production]

set -e

ENVIRONMENT=${1:-staging}
APP_NAME="frontend"
BASE_DIR="/var/www/${APP_NAME}"
RELEASES_DIR="${BASE_DIR}/releases"
SHARED_DIR="${BASE_DIR}/shared"
CURRENT_LINK="${BASE_DIR}/current"

echo "🚀 Configurando servidor de ${APP_NAME} para ambiente: ${ENVIRONMENT}"
echo "================================================"

# Verificar que se ejecuta como usuario correcto
if [ "$USER" = "root" ]; then
    echo "⚠️  No ejecutar como root. Usar usuario 'deploy' o similar."
    exit 1
fi

# Crear estructura de directorios
echo "📁 Creando estructura de directorios..."
mkdir -p "${RELEASES_DIR}"
mkdir -p "${SHARED_DIR}"

echo "✅ Directorios creados:"
echo "   - ${RELEASES_DIR}"
echo "   - ${SHARED_DIR}"

# Configurar permisos
echo "🔐 Configurando permisos..."
chmod 755 "${BASE_DIR}"
chmod 755 "${RELEASES_DIR}"
chmod 755 "${SHARED_DIR}"

# Crear archivo .env de ejemplo
ENV_FILE="${SHARED_DIR}/.env.${ENVIRONMENT}"
if [ ! -f "${ENV_FILE}" ]; then
    echo "📝 Creando archivo de entorno: ${ENV_FILE}"
    cat > "${ENV_FILE}" <<EOF
# Environment: ${ENVIRONMENT}
# Frontend Configuration

VITE_API_URL=http://localhost:3000/api
VITE_APP_ENV=${ENVIRONMENT}
VITE_APP_NAME="Project Management Frontend"

# Add your environment-specific variables here
EOF
    chmod 600 "${ENV_FILE}"
    echo "✅ Archivo .env creado. Editar con las variables correctas."
else
    echo "⚠️  Archivo .env ya existe: ${ENV_FILE}"
fi

# Crear release inicial de prueba (opcional)
INITIAL_RELEASE="initial_$(date +%Y%m%d_%H%M%S)"
INITIAL_DIR="${RELEASES_DIR}/${INITIAL_RELEASE}"

if [ ! -L "${CURRENT_LINK}" ]; then
    echo "🎯 Creando release inicial de prueba..."
    mkdir -p "${INITIAL_DIR}"
    
    # Crear index.html de prueba
    cat > "${INITIAL_DIR}/index.html" <<'EOF'
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Frontend - Deployment Test</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }
        .container {
            text-align: center;
            background: rgba(255, 255, 255, 0.1);
            padding: 40px;
            border-radius: 20px;
            backdrop-filter: blur(10px);
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
        }
        h1 { margin: 0; font-size: 2.5em; }
        .status { 
            background: #10b981; 
            padding: 10px 20px; 
            border-radius: 25px; 
            display: inline-block;
            margin-top: 20px;
            font-weight: bold;
        }
        .info {
            margin-top: 30px;
            font-size: 0.9em;
            opacity: 0.9;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Frontend Ready</h1>
        <div class="status">✅ Server Configured</div>
        <div class="info">
            <p><strong>Environment:</strong> ENVIRONMENT_PLACEHOLDER</p>
            <p><strong>Release:</strong> RELEASE_PLACEHOLDER</p>
            <p>Waiting for first deployment...</p>
        </div>
    </div>
</body>
</html>
EOF

    # Reemplazar placeholders
    sed -i "s/ENVIRONMENT_PLACEHOLDER/${ENVIRONMENT}/g" "${INITIAL_DIR}/index.html"
    sed -i "s/RELEASE_PLACEHOLDER/${INITIAL_RELEASE}/g" "${INITIAL_DIR}/index.html"
    
    # Crear release-info.json inicial
    cat > "${INITIAL_DIR}/release-info.json" <<EOF
{
  "releaseId": "${INITIAL_RELEASE}",
  "environment": "${ENVIRONMENT}",
  "status": "initial",
  "message": "Server configured - waiting for first deployment"
}
EOF
    
    # Crear symlink
    ln -sfn "${INITIAL_DIR}" "${CURRENT_LINK}"
    echo "✅ Release inicial creado y activado"
    echo "   Symlink: ${CURRENT_LINK} -> ${INITIAL_DIR}"
fi

# Verificar symlink
if [ -L "${CURRENT_LINK}" ]; then
    CURRENT_TARGET=$(readlink -f "${CURRENT_LINK}")
    echo "✅ Symlink actual apunta a: ${CURRENT_TARGET}"
fi

# Mostrar estructura creada
echo ""
echo "📋 Estructura final:"
tree -L 3 "${BASE_DIR}" 2>/dev/null || ls -la "${BASE_DIR}"

echo ""
echo "================================================"
echo "✅ Servidor configurado exitosamente"
echo ""
echo "📌 Próximos pasos:"
echo "   1. Configurar servidor web (nginx/apache) para servir desde: ${CURRENT_LINK}"
echo "   2. Configurar secrets en GitHub (STAGING_FRONTEND_* o PROD_FRONTEND_*)"
echo "   3. Ejecutar pipeline de deployment"
echo ""
echo "🔍 Verificar deployment:"
echo "   readlink -f ${CURRENT_LINK}"
echo "   ls -la ${RELEASES_DIR}"
echo ""
echo "🌐 Ejemplo configuración nginx:"
echo "   server {"
echo "     listen 80;"
echo "     root ${CURRENT_LINK};"
echo "     index index.html;"
echo "     location / {"
echo "       try_files \$uri \$uri/ /index.html;"
echo "     }"
echo "   }"
echo ""
echo "================================================"
