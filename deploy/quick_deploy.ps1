# Script rápido para desplegar ACEXAPI en DigitalOcean
# Ejecutar desde: G:\ProyectoFinalCSharp\ProyectoFinalDAM2\deploy

Write-Host "======================================"
Write-Host "  ACEXAPI - Deploy Rápido"
Write-Host "======================================"
Write-Host ""

# Solicitar IP del Droplet
$dropletIP = Read-Host "Ingresa la IP de tu Droplet"

if ([string]::IsNullOrWhiteSpace($dropletIP)) {
    Write-Host "❌ Error: Debes ingresar una IP válida" -ForegroundColor Red
    exit 1
}

$sshKey = "$env:USERPROFILE\.ssh\digitalocean_key"

Write-Host ""
Write-Host "🎯 Droplet IP: $dropletIP" -ForegroundColor Cyan
Write-Host "🔑 SSH Key: $sshKey" -ForegroundColor Cyan
Write-Host ""

# Verificar conexión
Write-Host "🔌 Verificando conexión al servidor..." -ForegroundColor Yellow
$testConnection = ssh -i $sshKey -o ConnectTimeout=5 -o StrictHostKeyChecking=no root@$dropletIP "echo 'OK'" 2>&1

if ($testConnection -notlike "*OK*") {
    Write-Host "❌ No se pudo conectar al servidor" -ForegroundColor Red
    Write-Host "Verifica que:" -ForegroundColor Yellow
    Write-Host "  1. La IP sea correcta" -ForegroundColor Yellow
    Write-Host "  2. El Droplet esté encendido" -ForegroundColor Yellow
    Write-Host "  3. La SSH key sea correcta" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Conexión exitosa" -ForegroundColor Green
Write-Host ""

# Paso 1: Subir script de instalación
Write-Host "📤 1/5 - Subiendo script de instalación..." -ForegroundColor Cyan
scp -i $sshKey .\install_server.sh root@${dropletIP}:/tmp/
Write-Host "✅ Script subido" -ForegroundColor Green
Write-Host ""

# Paso 2: Ejecutar instalación
Write-Host "⚙️  2/5 - Instalando software en el servidor..." -ForegroundColor Cyan
Write-Host "Esto tomará varios minutos..." -ForegroundColor Yellow
ssh -i $sshKey root@$dropletIP "chmod +x /tmp/install_server.sh && /tmp/install_server.sh"

# Paso 3: Compilar y empaquetar API
Write-Host ""
Write-Host "🔨 3/5 - Compilando API..." -ForegroundColor Cyan
Set-Location ..\ACEXAPI
dotnet publish -c Release -o .\publish | Out-Null

Write-Host "📦 Empaquetando..." -ForegroundColor Cyan
Set-Location publish
Compress-Archive -Path * -DestinationPath ..\acexapi-deploy.zip -Force
Set-Location ..
Write-Host "✅ API compilada" -ForegroundColor Green
Write-Host ""

# Paso 4: Subir archivos
Write-Host "📤 4/5 - Subiendo archivos al servidor..." -ForegroundColor Cyan
scp -i $sshKey .\acexapi-deploy.zip root@${dropletIP}:/tmp/
scp -i $sshKey ..\DB\ACEXAPI_backup.bak root@${dropletIP}:/tmp/ 2>$null
Write-Host "✅ Archivos subidos" -ForegroundColor Green
Write-Host ""

# Paso 5: Solicitar password SA
$saPassword = Read-Host "Ingresa la contraseña SA que configuraste (mínimo 8 caracteres)" -AsSecureString
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($saPassword)
$saPasswordPlain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

# Actualizar appsettings.Production.json
Write-Host ""
Write-Host "⚙️  5/5 - Configurando y desplegando..." -ForegroundColor Cyan

$appsettings = Get-Content ..\ACEXAPI\appsettings.Production.json | ConvertFrom-Json
$appsettings.ConnectionStrings.DefaultConnection = "Server=localhost;Initial Catalog=ACEXAPI;User ID=SA;Password=$saPasswordPlain;MultipleActiveResultSets=True;Encrypt=True;TrustServerCertificate=True;Connection Timeout=30;"
$appsettings.Cors.AllowedOrigins += "http://$dropletIP"
$appsettings | ConvertTo-Json -Depth 10 | Set-Content ..\ACEXAPI\publish\appsettings.Production.json

# Desplegar en servidor
$deployCommands = @"
mkdir -p /var/www/acexapi
cd /var/www/acexapi
apt-get install -y unzip
unzip -o /tmp/acexapi-deploy.zip
/opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P '$saPasswordPlain' -C -Q 'RESTORE DATABASE ACEXAPI FROM DISK = '\''/tmp/ACEXAPI_backup.bak'\'' WITH MOVE '\''ACEXAPI'\'' TO '\''/var/opt/mssql/data/ACEXAPI.mdf'\'', MOVE '\''ACEXAPI_log'\'' TO '\''/var/opt/mssql/data/ACEXAPI_log.ldf'\'', REPLACE'
systemctl daemon-reload
systemctl enable acexapi
systemctl restart acexapi
systemctl restart nginx
sleep 3
systemctl status acexapi --no-pager
"@

ssh -i $sshKey root@$dropletIP $deployCommands

Write-Host ""
Write-Host "✅ ¡Deploy completado!" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 Tu API está disponible en:" -ForegroundColor Cyan
Write-Host "   http://$dropletIP" -ForegroundColor White
Write-Host "   http://$dropletIP/swagger" -ForegroundColor White
Write-Host ""
Write-Host "📱 Actualiza tu app Flutter:" -ForegroundColor Yellow
Write-Host "   baseUrl: `"http://$dropletIP`"" -ForegroundColor White
Write-Host ""
Write-Host "🔍 Ver logs:" -ForegroundColor Yellow
Write-Host "   ssh -i $sshKey root@$dropletIP" -ForegroundColor White
Write-Host "   sudo journalctl -u acexapi -f" -ForegroundColor White
Write-Host ""

# Limpiar
Remove-Item .\acexapi-deploy.zip -Force
Remove-Item .\publish -Recurse -Force

Set-Location ..\deploy
