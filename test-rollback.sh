#!/bin/bash

# Script para probar rollback del frontend
# Uso: ./test-rollback.sh [staging|production]

set -e

ENVIRONMENT=${1:-staging}

case $ENVIRONMENT in
    staging)
        SSH_PORT=2223
        URL="http://localhost:8081"
        ;;
    production)
        SSH_PORT=2224
        URL="http://localhost:8082"
        ;;
    *)
        echo "❌ Ambiente inválido. Usar: staging o production"
        exit 1
        ;;
esac

SSH_USER="deploy"
SSH_HOST="localhost"
REMOTE_PATH="/var/www/frontend"

echo "🔄 Simulación de Rollback - Frontend ${ENVIRONMENT^^}"
echo "================================================"
echo ""

# Función para ejecutar comando SSH
run_ssh() {
    ssh -p ${SSH_PORT} ${SSH_USER}@${SSH_HOST} "$1"
}

# Mostrar releases disponibles
echo "📦 Releases disponibles:"
run_ssh "ls -lht ${REMOTE_PATH}/releases/ | head -10"
echo ""

# Mostrar release actual
echo "🎯 Release actual:"
CURRENT=$(run_ssh "readlink -f ${REMOTE_PATH}/current")
echo "   ${CURRENT}"
echo ""

# Obtener release anterior
echo "🔍 Buscando release anterior..."
PREVIOUS=$(run_ssh "ls -1dt ${REMOTE_PATH}/releases/*/ | sed -n '2p' | tr -d '/'")

if [ -z "$PREVIOUS" ]; then
    echo "❌ No hay release anterior disponible para rollback"
    exit 1
fi

echo "   Release anterior: ${PREVIOUS}"
echo ""

# Confirmar rollback
read -p "¿Deseas hacer rollback a la versión anterior? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Rollback cancelado"
    exit 0
fi

# Ejecutar rollback
echo ""
echo "🔄 Ejecutando rollback..."
ROLLBACK_CMD="ln -sfn ${PREVIOUS} ${REMOTE_PATH}/current && readlink -f ${REMOTE_PATH}/current"
NEW_CURRENT=$(run_ssh "$ROLLBACK_CMD")

echo "✅ Rollback completado"
echo "   Nuevo current: ${NEW_CURRENT}"
echo ""

# Verificar health check
echo "🏥 Verificando health check..."
sleep 2

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" ${URL}/health || echo "000")

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ Health check OK (HTTP ${HTTP_CODE})"
else
    echo "❌ Health check FAILED (HTTP ${HTTP_CODE})"
fi

# Verificar release-info
echo ""
echo "📊 Información de release actual:"
curl -s ${URL}/release-info.json 2>/dev/null | python3 -m json.tool || echo "Release info no disponible"

echo ""
echo "================================================"
echo "✅ Proceso de rollback completado"
echo ""
echo "🔍 Comandos útiles:"
echo "   Ver releases:  ssh -p ${SSH_PORT} ${SSH_USER}@${SSH_HOST} 'ls -lht ${REMOTE_PATH}/releases/'"
echo "   Ver current:   ssh -p ${SSH_PORT} ${SSH_USER}@${SSH_HOST} 'readlink -f ${REMOTE_PATH}/current'"
echo "   Test web:      curl ${URL}"
echo ""
