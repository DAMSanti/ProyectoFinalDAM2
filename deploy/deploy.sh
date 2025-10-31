#!/bin/bash

# Script de deployment para ACEXAPI en DigitalOcean
# Este script debe ejecutarse en el servidor (droplet)

set -e  # Salir si hay algún error

echo "=== Iniciando deployment de ACEXAPI ==="

# Variables de configuración
APP_NAME="acexapi"
APP_DIR="/var/www/acexapi"
REPO_URL="https://github.com/DAMSanti/ProyectoFinalDAM2.git"
BRANCH="main"
SERVICE_NAME="acexapi.service"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}1. Deteniendo servicio...${NC}"
sudo systemctl stop $SERVICE_NAME || echo "Servicio no estaba corriendo"

echo -e "${YELLOW}2. Actualizando código desde GitHub...${NC}"
if [ -d "$APP_DIR" ]; then
    cd $APP_DIR
    sudo git fetch origin
    sudo git reset --hard origin/$BRANCH
    sudo git pull origin $BRANCH
else
    echo -e "${RED}Error: Directorio $APP_DIR no existe${NC}"
    exit 1
fi

echo -e "${YELLOW}3. Restaurando dependencias...${NC}"
cd $APP_DIR/ACEXAPI
sudo dotnet restore

echo -e "${YELLOW}4. Compilando aplicación...${NC}"
sudo dotnet build --configuration Release

echo -e "${YELLOW}5. Publicando aplicación...${NC}"
sudo dotnet publish --configuration Release --output /var/www/acexapi/publish

echo -e "${YELLOW}6. Configurando permisos...${NC}"
sudo chown -R www-data:www-data $APP_DIR
sudo chmod -R 755 $APP_DIR

echo -e "${YELLOW}7. Iniciando servicio...${NC}"
sudo systemctl start $SERVICE_NAME
sudo systemctl status $SERVICE_NAME --no-pager

echo -e "${YELLOW}8. Verificando estado del servicio...${NC}"
sleep 3
if sudo systemctl is-active --quiet $SERVICE_NAME; then
    echo -e "${GREEN}✓ Deployment completado exitosamente!${NC}"
    echo -e "${GREEN}✓ El servicio está corriendo${NC}"
else
    echo -e "${RED}✗ Error: El servicio no está corriendo${NC}"
    echo -e "${YELLOW}Mostrando logs:${NC}"
    sudo journalctl -u $SERVICE_NAME -n 50 --no-pager
    exit 1
fi

echo -e "${YELLOW}9. Logs recientes:${NC}"
sudo journalctl -u $SERVICE_NAME -n 20 --no-pager

echo -e "${GREEN}=== Deployment finalizado ===${NC}"
