# Script rápido para actualizar solo el código de la API
Write-Host "======================================"
Write-Host "  ACEXAPI - Actualizacion Rapida"
Write-Host "======================================"
Write-Host ""

$dropletIP = "64.226.85.100"
$sshKey = "$env:USERPROFILE\.ssh\digitalocean_key"

Write-Host "Verificando conexion..." -ForegroundColor Yellow
$test = ssh -i $sshKey -o ConnectTimeout=5 root@$dropletIP "echo OK" 2>&1
if ($test -notlike "*OK*") {
    Write-Host "No se pudo conectar. Intentando sin clave SSH..." -ForegroundColor Red
    Write-Host ""
    $test2 = ssh -o ConnectTimeout=5 root@$dropletIP "echo OK" 2>&1
    if ($test2 -notlike "*OK*") {
        Write-Host "No se pudo conectar al servidor" -ForegroundColor Red
        exit 1
    }
    $sshKey = ""
}
Write-Host "Conexion OK" -ForegroundColor Green

Write-Host ""
Write-Host "Compilando API..." -ForegroundColor Cyan
Set-Location $PSScriptRoot\..\ACEXAPI
dotnet publish -c Release -o .\publish

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error al compilar" -ForegroundColor Red
    exit 1
}

Write-Host "Empaquetando..." -ForegroundColor Cyan
Compress-Archive -Path .\publish\* -DestinationPath .\acexapi-deploy.zip -Force

Write-Host "Subiendo archivos..." -ForegroundColor Cyan
if ($sshKey) {
    scp -i $sshKey .\acexapi-deploy.zip root@${dropletIP}:/tmp/
} else {
    scp .\acexapi-deploy.zip root@${dropletIP}:/tmp/
}

Write-Host ""
Write-Host "Desplegando en servidor..." -ForegroundColor Cyan

$deployCommands = @"
cd /var/www/acexapi
unzip -o /tmp/acexapi-deploy.zip
systemctl restart acexapi
systemctl status acexapi --no-pager -l
"@

if ($sshKey) {
    ssh -i $sshKey root@$dropletIP $deployCommands
} else {
    ssh root@$dropletIP $deployCommands
}

Write-Host ""
Write-Host "Actualizacion completada!" -ForegroundColor Green
Write-Host ""
Write-Host "API: http://$dropletIP/api" -ForegroundColor Cyan
Write-Host "Swagger: http://$dropletIP/swagger" -ForegroundColor Cyan
Write-Host ""

Remove-Item .\acexapi-deploy.zip -Force -ErrorAction SilentlyContinue
Set-Location $PSScriptRoot
