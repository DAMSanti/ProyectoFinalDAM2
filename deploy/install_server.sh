#!/bin/bash
# Script de instalación para Ubuntu 22.04 en DigitalOcean
# Instala SQL Server 2019, .NET 8.0 y configura el servidor

set -e

echo "======================================"
echo "  Instalación de ACEXAPI Server"
echo "======================================"
echo ""

# Actualizar sistema
echo "📦 Actualizando sistema..."
sudo apt-get update
sudo apt-get upgrade -y

# Instalar dependencias
echo "📦 Instalando dependencias..."
sudo apt-get install -y curl wget apt-transport-https software-properties-common

# ============================================
# INSTALAR SQL SERVER 2019 PARA UBUNTU
# ============================================
echo ""
echo "🗄️  Instalando SQL Server 2019..."

# Importar las claves públicas del repositorio GPG
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -

# Registrar el repositorio de SQL Server
sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/22.04/mssql-server-2019.list)"

# Instalar SQL Server
sudo apt-get update
sudo apt-get install -y mssql-server

# Configurar SQL Server
echo ""
echo "⚙️  Configurando SQL Server..."
echo "Por favor, selecciona la edición (2 = Developer - gratis)"
echo "Y establece la contraseña SA (mínimo 8 caracteres, mayúsculas, minúsculas, números y símbolos)"
sudo /opt/mssql/bin/mssql-conf setup

# Verificar que SQL Server está corriendo
systemctl status mssql-server --no-pager

# Instalar herramientas de línea de comandos de SQL Server
echo ""
echo "🔧 Instalando herramientas SQL Server..."
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
curl https://packages.microsoft.com/config/ubuntu/22.04/prod.list | sudo tee /etc/apt/sources.list.d/msprod.list
sudo apt-get update
sudo apt-get install -y mssql-tools18 unixodbc-dev

# Agregar herramientas al PATH
echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bashrc
source ~/.bashrc

# ============================================
# INSTALAR .NET 8.0
# ============================================
echo ""
echo "📦 Instalando .NET 8.0..."

# Agregar repositorio de Microsoft
wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb

# Instalar .NET 8 SDK y Runtime
sudo apt-get update
sudo apt-get install -y dotnet-sdk-8.0 aspnetcore-runtime-8.0

# Verificar instalación
dotnet --version

# ============================================
# CONFIGURAR FIREWALL
# ============================================
echo ""
echo "🔥 Configurando firewall..."

# Habilitar firewall
sudo ufw --force enable

# Permitir SSH
sudo ufw allow 22/tcp

# Permitir HTTP y HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Permitir puerto de la API (5000)
sudo ufw allow 5000/tcp

# Permitir SQL Server (solo si necesitas acceso externo a la BD)
# sudo ufw allow 1433/tcp

sudo ufw status

# ============================================
# INSTALAR NGINX (Reverse Proxy)
# ============================================
echo ""
echo "🌐 Instalando Nginx..."
sudo apt-get install -y nginx

# Crear directorio para la aplicación
echo ""
echo "📁 Creando directorios..."
sudo mkdir -p /var/www/acexapi
sudo chown -R $USER:$USER /var/www/acexapi

# ============================================
# CONFIGURAR SYSTEMD SERVICE
# ============================================
echo ""
echo "⚙️  Configurando servicio systemd..."

sudo tee /etc/systemd/system/acexapi.service > /dev/null <<EOF
[Unit]
Description=ACEX API .NET Application
After=network.target

[Service]
WorkingDirectory=/var/www/acexapi
ExecStart=/usr/bin/dotnet /var/www/acexapi/ACEXAPI.dll
Restart=always
RestartSec=10
KillSignal=SIGINT
SyslogIdentifier=acexapi
User=$USER
Environment=ASPNETCORE_ENVIRONMENT=Production
Environment=DOTNET_PRINT_TELEMETRY_MESSAGE=false

[Install]
WantedBy=multi-user.target
EOF

# ============================================
# CONFIGURAR NGINX REVERSE PROXY
# ============================================
echo ""
echo "⚙️  Configurando Nginx..."

sudo tee /etc/nginx/sites-available/acexapi > /dev/null <<'EOF'
server {
    listen 80;
    server_name _;
    
    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection keep-alive;
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# Habilitar sitio
sudo ln -sf /etc/nginx/sites-available/acexapi /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Verificar configuración de Nginx
sudo nginx -t

# Reiniciar Nginx
sudo systemctl restart nginx
sudo systemctl enable nginx

# ============================================
# FINALIZAR
# ============================================
echo ""
echo "✅ ¡Instalación completada!"
echo ""
echo "Siguiente paso:"
echo "1. Sube tu aplicación a /var/www/acexapi"
echo "2. Restaura la base de datos"
echo "3. Ejecuta: sudo systemctl start acexapi"
echo ""
echo "Información útil:"
echo "- SQL Server: /opt/mssql/bin/mssql-conf"
echo "- Logs SQL: sudo journalctl -u mssql-server"
echo "- Logs API: sudo journalctl -u acexapi"
echo "- Reiniciar API: sudo systemctl restart acexapi"
echo ""
