#!/bin/bash
# Script para desplegar la API ACEXAPI en el servidor

set -e

echo "======================================"
echo "  Deploy de ACEXAPI"
echo "======================================"
echo ""

# Verificar argumentos
if [ -z "$1" ]; then
    echo "❌ Error: Debes proporcionar la IP del servidor"
    echo "Uso: ./deploy_api.sh <SERVER_IP> [SA_PASSWORD]"
    exit 1
fi

SERVER_IP="$1"
SA_PASSWORD="${2:-YourStrongPassword123!}"

echo "🎯 Servidor: $SERVER_IP"
echo ""

# Compilar la aplicación
echo "🔨 Compilando aplicación..."
cd ../ACEXAPI
dotnet publish -c Release -o ./publish

# Crear tarball
echo "📦 Empaquetando..."
cd publish
tar -czf ../acexapi-deploy.tar.gz *
cd ..

echo "✅ Aplicación empaquetada"
echo ""

# Subir al servidor
echo "📤 Subiendo al servidor..."
scp -i ~/.ssh/digitalocean_key acexapi-deploy.tar.gz root@$SERVER_IP:/tmp/

# Subir backup de base de datos si existe
if [ -f "../DB/ACEXAPI_backup.bak" ]; then
    echo "📤 Subiendo backup de base de datos..."
    scp -i ~/.ssh/digitalocean_key ../DB/ACEXAPI_backup.bak root@$SERVER_IP:/tmp/
fi

# Conectar al servidor y desplegar
echo ""
echo "🚀 Desplegando en el servidor..."

ssh -i ~/.ssh/digitalocean_key root@$SERVER_IP << 'ENDSSH'
# Detener servicio si está corriendo
sudo systemctl stop acexapi || true

# Limpiar directorio
sudo rm -rf /var/www/acexapi/*

# Extraer aplicación
cd /var/www/acexapi
sudo tar -xzf /tmp/acexapi-deploy.tar.gz

# Dar permisos
sudo chown -R www-data:www-data /var/www/acexapi
sudo chmod -R 755 /var/www/acexapi

# Habilitar e iniciar servicio
sudo systemctl enable acexapi
sudo systemctl start acexapi

# Verificar estado
sleep 2
sudo systemctl status acexapi --no-pager

echo ""
echo "✅ Deploy completado"
ENDSSH

echo ""
echo "🌐 Tu API debería estar disponible en:"
echo "   http://$SERVER_IP"
echo ""
echo "📊 Para ver logs:"
echo "   ssh -i ~/.ssh/digitalocean_key root@$SERVER_IP"
echo "   sudo journalctl -u acexapi -f"
echo ""
