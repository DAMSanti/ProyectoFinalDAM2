# 🚀 Guía de Despliegue ACEXAPI en DigitalOcean

Esta guía te ayudará a desplegar tu API .NET y base de datos SQL Server en un Droplet de DigitalOcean.

## 📋 Requisitos Previos

- Droplet de DigitalOcean creado (Ubuntu 22.04)
- SSH Key configurada
- IP del Droplet

## 🎯 Paso 1: Conectar al Servidor

Una vez creado el Droplet, anota la **IP pública** (ejemplo: `164.92.123.456`)

Conéctate por SSH:

```bash
ssh -i C:\Users\rathm\.ssh\digitalocean_key root@TU_IP_AQUI
```

## 🔧 Paso 2: Instalar Software Necesario

### Opción A: Script Automático (Recomendado)

Desde tu PC Windows, sube y ejecuta el script de instalación:

```powershell
# Subir script al servidor
scp -i C:\Users\rathm\.ssh\digitalocean_key G:\ProyectoFinalCSharp\ProyectoFinalDAM2\deploy\install_server.sh root@TU_IP:/tmp/

# Conectar y ejecutar
ssh -i C:\Users\rathm\.ssh\digitalocean_key root@TU_IP
chmod +x /tmp/install_server.sh
sudo /tmp/install_server.sh
```

Durante la instalación te pedirá:
1. **Edición de SQL Server**: Elige `2` (Developer Edition - gratis)
2. **Contraseña SA**: Crea una contraseña segura (ejemplo: `Semicrol_10!`)

### Opción B: Manual

Conectado al servidor, ejecuta:

```bash
# Actualizar sistema
sudo apt-get update && sudo apt-get upgrade -y

# Instalar SQL Server 2019
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/22.04/mssql-server-2019.list)"
sudo apt-get update
sudo apt-get install -y mssql-server
sudo /opt/mssql/bin/mssql-conf setup

# Instalar .NET 8.0
wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get update
sudo apt-get install -y dotnet-sdk-8.0 aspnetcore-runtime-8.0

# Instalar Nginx
sudo apt-get install -y nginx
```

## 🗄️ Paso 3: Restaurar Base de Datos

### Desde tu PC Windows:

```powershell
# La base de datos ya fue respaldada en:
# G:\ProyectoFinalCSharp\ProyectoFinalDAM2\DB\ACEXAPI_backup.bak

# Subir al servidor
scp -i C:\Users\rathm\.ssh\digitalocean_key G:\ProyectoFinalCSharp\ProyectoFinalDAM2\DB\ACEXAPI_backup.bak root@TU_IP:/tmp/
```

### En el servidor:

```bash
# Conectar
ssh -i C:\Users\rathm\.ssh\digitalocean_key root@TU_IP

# Restaurar base de datos
/opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P 'TU_PASSWORD_SA' -C -Q "
RESTORE DATABASE ACEXAPI 
FROM DISK = '/tmp/ACEXAPI_backup.bak' 
WITH MOVE 'ACEXAPI' TO '/var/opt/mssql/data/ACEXAPI.mdf',
MOVE 'ACEXAPI_log' TO '/var/opt/mssql/data/ACEXAPI_log.ldf',
REPLACE
GO
"

# Verificar
/opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P 'TU_PASSWORD_SA' -C -Q "SELECT name FROM sys.databases"
```

## 📦 Paso 4: Desplegar la API

### Preparar en tu PC:

1. **Editar configuración de producción:**

Abre: `G:\ProyectoFinalCSharp\ProyectoFinalDAM2\ACEXAPI\appsettings.Production.json`

Actualiza:
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Initial Catalog=ACEXAPI;User ID=SA;Password=TU_PASSWORD_SA;..."
  },
  "Cors": {
    "AllowedOrigins": [
      "http://TU_IP_DROPLET",
      "https://tu-dominio.com"
    ]
  }
}
```

2. **Compilar y publicar:**

```powershell
cd G:\ProyectoFinalCSharp\ProyectoFinalDAM2\ACEXAPI
dotnet publish -c Release -o ./publish
```

3. **Empaquetar:**

```powershell
cd publish
Compress-Archive -Path * -DestinationPath ..\acexapi-deploy.zip
cd ..
```

4. **Subir al servidor:**

```powershell
scp -i C:\Users\rathm\.ssh\digitalocean_key acexapi-deploy.zip root@TU_IP:/tmp/
```

### Desplegar en el servidor:

```bash
# Conectar
ssh -i C:\Users\rathm\.ssh\digitalocean_key root@TU_IP

# Crear directorio
sudo mkdir -p /var/www/acexapi
cd /var/www/acexapi

# Descomprimir
sudo apt-get install -y unzip
sudo unzip /tmp/acexapi-deploy.zip -d /var/www/acexapi

# Permisos
sudo chown -R www-data:www-data /var/www/acexapi
sudo chmod -R 755 /var/www/acexapi
```

## ⚙️ Paso 5: Configurar Servicio Systemd

```bash
sudo nano /etc/systemd/system/acexapi.service
```

Pega este contenido:

```ini
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
User=www-data
Environment=ASPNETCORE_ENVIRONMENT=Production
Environment=DOTNET_PRINT_TELEMETRY_MESSAGE=false

[Install]
WantedBy=multi-user.target
```

Guardar (Ctrl+X, Y, Enter)

```bash
# Recargar systemd
sudo systemctl daemon-reload

# Habilitar e iniciar servicio
sudo systemctl enable acexapi
sudo systemctl start acexapi

# Verificar estado
sudo systemctl status acexapi
```

## 🌐 Paso 6: Configurar Nginx

```bash
sudo nano /etc/nginx/sites-available/acexapi
```

Pega:

```nginx
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
```

```bash
# Habilitar sitio
sudo ln -s /etc/nginx/sites-available/acexapi /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default

# Test y reinicio
sudo nginx -t
sudo systemctl restart nginx
```

## 🔥 Paso 7: Configurar Firewall

```bash
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw --force enable
sudo ufw status
```

## ✅ Paso 8: Verificar

Abre en tu navegador:

```
http://TU_IP_DROPLET/swagger
```

Deberías ver la documentación Swagger de tu API.

## 🔍 Comandos Útiles

### Ver logs de la API:
```bash
sudo journalctl -u acexapi -f
```

### Ver logs de SQL Server:
```bash
sudo journalctl -u mssql-server -f
```

### Reiniciar API:
```bash
sudo systemctl restart acexapi
```

### Reiniciar Nginx:
```bash
sudo systemctl restart nginx
```

### Ver estado de servicios:
```bash
sudo systemctl status acexapi
sudo systemctl status nginx
sudo systemctl status mssql-server
```

### Conectar a SQL Server:
```bash
/opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P 'TU_PASSWORD' -C
```

## 🆘 Solución de Problemas

### La API no inicia:

```bash
# Ver logs detallados
sudo journalctl -u acexapi -n 100 --no-pager

# Verificar que el puerto 5000 no esté ocupado
sudo netstat -tulpn | grep 5000

# Probar manualmente
cd /var/www/acexapi
dotnet ACEXAPI.dll
```

### Error de conexión a base de datos:

```bash
# Verificar que SQL Server esté corriendo
sudo systemctl status mssql-server

# Probar conexión
/opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P 'TU_PASSWORD' -C -Q "SELECT @@VERSION"
```

### Nginx muestra error 502:

```bash
# Ver logs de Nginx
sudo tail -f /var/log/nginx/error.log

# Verificar que la API esté corriendo
curl http://localhost:5000
```

## 🎉 ¡Listo!

Tu API está desplegada en:
- **API**: http://TU_IP_DROPLET
- **Swagger**: http://TU_IP_DROPLET/swagger

Para actualizar tu app Flutter, cambia la URL de la API en:
`lib/config/api_config.dart` → `baseUrl: 'http://TU_IP_DROPLET'`

---

## 📚 Referencias

- [SQL Server en Linux](https://learn.microsoft.com/en-us/sql/linux/sql-server-linux-overview)
- [ASP.NET Core en Linux](https://learn.microsoft.com/en-us/aspnet/core/host-and-deploy/linux-nginx)
- [DigitalOcean Docs](https://docs.digitalocean.com/)
