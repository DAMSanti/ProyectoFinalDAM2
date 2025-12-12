#!/bin/bash
# Script de despliegue para Digital Ocean
# Ejecutar en el servidor de Digital Ocean

set -e

echo "=== Desplegando proyecto_santi en Digital Ocean ==="

# Variables (modificar según tu configuración)
APP_NAME="proyecto-santi-web"
PORT=8080

# Detener contenedor existente si existe
echo "Deteniendo contenedor existente..."
docker stop $APP_NAME 2>/dev/null || true
docker rm $APP_NAME 2>/dev/null || true

# Construir imagen
echo "Construyendo imagen Docker..."
docker build -t $APP_NAME .

# Ejecutar contenedor
echo "Iniciando contenedor..."
docker run -d \
    --name $APP_NAME \
    -p $PORT:80 \
    --restart unless-stopped \
    $APP_NAME

echo ""
echo "=== Despliegue completado ==="
echo "La aplicación está disponible en: http://$(curl -s ifconfig.me):$PORT"
echo ""
echo "Para ver los logs: docker logs -f $APP_NAME"
echo "Para detener: docker stop $APP_NAME"
