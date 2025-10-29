# Script simplificado de deploy para ACEXAPI
Write-Host "======================================"
Write-Host "  ACEXAPI - Deploy Simplificado"
Write-Host "======================================"
Write-Host ""

$dropletIP = Read-Host "Ingresa la IP de tu Droplet"
$sshKey = "$env:USERPROFILE\.ssh\digitalocean_key"

Write-Host ""
Write-Host "🔌 Verificando conexión..." -ForegroundColor Yellow
$test = ssh -i $sshKey -o ConnectTimeout=5 root@$dropletIP "echo OK" 2>&1
if ($test -notlike "*OK*") {
    Write-Host "❌ No se pudo conectar" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Conexión OK" -ForegroundColor Green

Write-Host ""
Write-Host "📤 Subiendo script de instalación..." -ForegroundColor Cyan
scp -i $sshKey .\install_server.sh root@${dropletIP}:/tmp/

Write-Host ""
Write-Host "⚙️  Instalando software (esto toma varios minutos)..." -ForegroundColor Cyan
Write-Host "IMPORTANTE: Cuando te pregunte:" -ForegroundColor Yellow
Write-Host "  1. Edición SQL Server → Escribe: 2" -ForegroundColor Yellow
Write-Host "  2. Contraseña SA → Crea una segura (ej: Semicrol_10!)" -ForegroundColor Yellow
Write-Host ""
ssh -i $sshKey root@$dropletIP "chmod +x /tmp/install_server.sh && bash /tmp/install_server.sh"

Write-Host ""
$saPassword = Read-Host "Ingresa la contraseña SA que acabas de configurar" -AsSecureString
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($saPassword)
$saPass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

Write-Host ""
Write-Host "🔨 Compilando API..." -ForegroundColor Cyan
Set-Location ..\ACEXAPI
dotnet publish -c Release -o .\publish | Out-Null

Write-Host "📦 Empaquetando..." -ForegroundColor Cyan
Compress-Archive -Path .\publish\* -DestinationPath .\acexapi-deploy.zip -Force

Write-Host "📤 Subiendo archivos..." -ForegroundColor Cyan
scp -i $sshKey .\acexapi-deploy.zip root@${dropletIP}:/tmp/
scp -i $sshKey ..\DB\ACEXAPI_backup.bak root@${dropletIP}:/tmp/

Write-Host ""
Write-Host "⚙️  Desplegando en servidor..." -ForegroundColor Cyan

# Crear script de restauración SQL en el servidor
$sqlScript = "/opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P `"$saPass`" -C -Q `"RESTORE DATABASE ACEXAPI FROM DISK = '/tmp/ACEXAPI_backup.bak' WITH MOVE 'ACEXAPI' TO '/var/opt/mssql/data/ACEXAPI.mdf', MOVE 'ACEXAPI_log' TO '/var/opt/mssql/data/ACEXAPI_log.ldf', REPLACE`""

ssh -i $sshKey root@$dropletIP "mkdir -p /var/www/acexapi && cd /var/www/acexapi && apt-get install -y unzip && unzip -o /tmp/acexapi-deploy.zip"
ssh -i $sshKey root@$dropletIP $sqlScript
ssh -i $sshKey root@$dropletIP "systemctl daemon-reload && systemctl enable acexapi && systemctl restart acexapi && systemctl restart nginx"

Write-Host ""
Write-Host "✅ ¡Deploy completado!" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 Tu API: http://$dropletIP/swagger" -ForegroundColor Cyan
Write-Host ""

Remove-Item .\acexapi-deploy.zip -Force
Set-Location ..\deploy
