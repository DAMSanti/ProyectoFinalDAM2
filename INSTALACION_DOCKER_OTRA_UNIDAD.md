# 🐳 INSTALACIÓN DE DOCKER DESKTOP EN OTRA UNIDAD

## 🚨 PROBLEMA: Poco espacio en C: (solo 800 MB libres)

Docker Desktop por defecto se instala en C: y necesita **al menos 4-5 GB** libres.

### ✅ SOLUCIÓN: Instalar Docker en otra unidad (G:)

---

## 📋 REQUISITOS

- ✅ Windows 10/11 (64-bit)
- ✅ Espacio en otra unidad: **~5-10 GB** (G: en tu caso)
- ✅ WSL 2 habilitado
- ✅ Virtualización habilitada en BIOS

---

## 🚀 PASOS DE INSTALACIÓN

### PASO 1: Habilitar WSL 2 (Windows Subsystem for Linux)

WSL 2 es necesario para Docker Desktop.

#### A. Abrir PowerShell como Administrador

```powershell
# Habilitar WSL
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

# Habilitar la característica de Máquina Virtual
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```

#### B. Reiniciar el PC

```powershell
Restart-Computer
```

#### C. Después del reinicio, establecer WSL 2 como predeterminado

```powershell
# Ejecutar como Administrador
wsl --set-default-version 2
```

#### D. Instalar el kernel de actualización de WSL 2

1. Descargar desde: https://aka.ms/wsl2kernel
2. Ejecutar el instalador
3. Seguir el asistente

---

### PASO 2: Liberar espacio en C: (Opcional pero recomendado)

Antes de instalar Docker, libera algo de espacio:

```powershell
# Limpiar archivos temporales
cleanmgr

# O ejecutar Disk Cleanup desde Windows
```

**Recomendación:** Deja al menos **2-3 GB libres en C:** para la instalación inicial.

---

### PASO 3: Descargar Docker Desktop

1. Ve a: **https://www.docker.com/products/docker-desktop/**
2. Clic en **"Download for Windows"**
3. Descarga el instalador: `Docker Desktop Installer.exe` (~500 MB)
4. **⚠️ IMPORTANTE:** Guarda el instalador en **G:\** (no en Descargas que está en C:)

---

### PASO 4: Instalar Docker Desktop en G:

#### A. Ejecutar el instalador desde línea de comandos

**⚠️ NO hagas doble clic en el instalador**, usa este comando en PowerShell (como Administrador):

```powershell
# Navegar a donde descargaste el instalador
cd "G:\Downloads"  # O donde lo hayas guardado

# Instalar Docker en G:\Docker
Start-Process "Docker Desktop Installer.exe" -ArgumentList "install --installation-dir=G:\Docker" -Wait
```

#### B. Durante la instalación:
- ✅ Marca **"Use WSL 2 instead of Hyper-V"** (recomendado)
- ✅ Deja marcado "Add shortcut to desktop"
- Espera a que termine (5-10 minutos)

---

### PASO 5: Mover datos de Docker a G:

Después de instalar, Docker seguirá guardando datos en C:. Hay que moverlos:

#### A. Cerrar Docker Desktop si está abierto

```powershell
# Detener Docker Desktop
Stop-Process -Name "Docker Desktop" -Force -ErrorAction SilentlyContinue
```

#### B. Mover los datos de WSL 2 (donde Docker guarda las imágenes)

```powershell
# Exportar la distribución de Docker a G:
wsl --export docker-desktop "G:\DockerData\docker-desktop.tar"
wsl --export docker-desktop-data "G:\DockerData\docker-desktop-data.tar"

# Desregistrar las distribuciones originales
wsl --unregister docker-desktop
wsl --unregister docker-desktop-data

# Importar las distribuciones en G:
wsl --import docker-desktop "G:\DockerData\docker-desktop" "G:\DockerData\docker-desktop.tar" --version 2
wsl --import docker-desktop-data "G:\DockerData\docker-desktop-data" "G:\DockerData\docker-desktop-data.tar" --version 2

# Eliminar los archivos .tar (ya no son necesarios)
Remove-Item "G:\DockerData\docker-desktop.tar"
Remove-Item "G:\DockerData\docker-desktop-data.tar"
```

---

### PASO 6: Configurar Docker Desktop

#### A. Abrir Docker Desktop

Busca "Docker Desktop" en el menú de inicio y ábrelo.

#### B. Ir a Settings (⚙️ arriba a la derecha)

#### C. Configurar ubicación de datos

1. Ve a **Settings** > **Resources** > **Advanced**
2. Cambia la ubicación del disco virtual si es posible

#### D. Configurar límites de recursos (Opcional)

- **CPUs:** 2-4 (según tu PC)
- **Memory:** 2-4 GB
- **Swap:** 1 GB
- **Disk image size:** Lo que necesites (empezar con 20 GB)

---

### PASO 7: Verificar instalación

```powershell
# Verificar versión de Docker
docker --version

# Debe mostrar algo como: Docker version 24.x.x

# Verificar que WSL 2 está configurado
wsl --list --verbose

# Debe mostrar docker-desktop y docker-desktop-data en estado "Running"
```

---

### PASO 8: Instalar SQL Server en Docker

Ahora sí, ejecuta el comando para SQL Server:

```powershell
# Descargar imagen de SQL Server 2022
docker pull mcr.microsoft.com/mssql/server:2022-latest

# Ejecutar SQL Server en contenedor
docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=Semicrol_10" -e "MSSQL_PID=Express" -p 1433:1433 --name sqlserver --restart always -v "G:/SqlServerData:/var/opt/mssql" -d mcr.microsoft.com/mssql/server:2022-latest
```

**Nota:** El parámetro `-v "G:/SqlServerData:/var/opt/mssql"` guarda los datos de SQL Server en **G:\SqlServerData**

---

### PASO 9: Verificar SQL Server

```powershell
# Ver contenedores corriendo
docker ps

# Debe mostrar 'sqlserver' con status 'Up'

# Ver logs de SQL Server
docker logs sqlserver

# Probar conexión
sqlcmd -S "127.0.0.1,1433" -U sa -P "Semicrol_10" -Q "SELECT @@VERSION"
```

---

## 📊 ESPACIO UTILIZADO

### Después de la instalación completa:

- **C:\Program Files\Docker** → ~500 MB (mínimo necesario)
- **G:\Docker** → ~1 GB (instalación)
- **G:\DockerData** → ~2-3 GB (WSL 2 + Docker)
- **G:\SqlServerData** → Variable (datos de SQL Server)

**Total en C:** ~500 MB - 1 GB  
**Total en G:** ~3-5 GB + datos

---

## 🔧 COMANDOS ÚTILES

### Gestión de Docker

```powershell
# Ver espacio usado por Docker
docker system df

# Limpiar recursos no usados
docker system prune -a

# Ver imágenes descargadas
docker images

# Ver contenedores
docker ps -a

# Detener Docker Desktop
Stop-Process -Name "Docker Desktop" -Force
```

### Gestión de SQL Server en Docker

```powershell
# Iniciar contenedor
docker start sqlserver

# Detener contenedor
docker stop sqlserver

# Ver logs
docker logs sqlserver

# Entrar al contenedor
docker exec -it sqlserver /bin/bash

# Backup de base de datos
docker exec sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "Semicrol_10" -Q "BACKUP DATABASE [ACEXAPI] TO DISK='/var/opt/mssql/backup/ACEXAPI.bak'"

# Copiar backup a Windows
docker cp sqlserver:/var/opt/mssql/backup/ACEXAPI.bak G:\Backups\
```

---

## ⚠️ ALTERNATIVA: Instalación mínima en C:

Si Docker no te deja instalar en G: o tienes problemas, intenta esto:

### 1. Liberar espacio en C:

```powershell
# Desinstalar aplicaciones no usadas
# Limpiar archivos temporales
cleanmgr

# Mover archivos grandes a G:
# Vaciar papelera de reciclaje
```

### 2. Instalar Docker normalmente en C:

```powershell
# Ejecutar instalador normal
Start-Process "Docker Desktop Installer.exe" -ArgumentList "install" -Wait
```

### 3. Inmediatamente después, mover datos a G: (Paso 5 de arriba)

---

## 🐛 SOLUCIÓN DE PROBLEMAS

### Error: "WSL 2 installation is incomplete"

```powershell
# Actualizar WSL
wsl --update

# Reiniciar WSL
wsl --shutdown
```

### Error: "Docker Desktop requires Windows 10 Pro/Enterprise/Education"

Si tienes Windows 10 Home:
1. Actualiza a Windows 10 versión 2004 o superior
2. Docker Desktop ahora funciona con WSL 2 en Home

### Error: "This application requires virtualization"

1. Reinicia el PC
2. Entra en BIOS (F2/F10/DEL al iniciar)
3. Busca "Virtualization Technology" o "Intel VT-x" / "AMD-V"
4. Habilítalo
5. Guarda y sal

### Docker usa mucho espacio en C:

```powershell
# Ver qué ocupa espacio
docker system df -v

# Limpiar imágenes no usadas
docker image prune -a

# Limpiar todo (⚠️ cuidado: borra contenedores detenidos)
docker system prune -a --volumes
```

---

## 🎯 RESUMEN EJECUTIVO

### Lo que vas a hacer:

1. ✅ Habilitar WSL 2 en Windows
2. ✅ Descargar Docker Desktop en G:\
3. ✅ Instalar Docker apuntando a G:\Docker
4. ✅ Mover datos de WSL 2 a G:\DockerData
5. ✅ Ejecutar SQL Server en Docker
6. ✅ Datos de SQL Server en G:\SqlServerData

### Resultado final:

- **C:** Solo ~500 MB - 1 GB ocupados
- **G:** Todo lo demás (3-5 GB + datos)
- **SQL Server:** Corriendo en Docker, datos persistentes

---

## 📝 SCRIPT AUTOMATIZADO (OPCIONAL)

Puedes copiar este script para automatizar parte del proceso:

```powershell
# Script para instalar Docker en G: y configurar SQL Server
# ⚠️ Ejecutar como Administrador

Write-Host "🐳 Instalando Docker en G:" -ForegroundColor Cyan

# Crear carpetas
New-Item -ItemType Directory -Force -Path "G:\Docker"
New-Item -ItemType Directory -Force -Path "G:\DockerData"
New-Item -ItemType Directory -Force -Path "G:\SqlServerData"

# Verificar WSL 2
Write-Host "Verificando WSL 2..." -ForegroundColor Yellow
wsl --list --verbose

# Instalar Docker Desktop
# (Primero debes descargar el instalador en G:\Downloads)
if (Test-Path "G:\Downloads\Docker Desktop Installer.exe") {
    Write-Host "Instalando Docker Desktop en G:\Docker..." -ForegroundColor Yellow
    Start-Process "G:\Downloads\Docker Desktop Installer.exe" -ArgumentList "install --installation-dir=G:\Docker" -Wait
    Write-Host "✅ Docker Desktop instalado" -ForegroundColor Green
} else {
    Write-Host "❌ No se encuentra el instalador de Docker en G:\Downloads" -ForegroundColor Red
    Write-Host "Descárgalo desde: https://www.docker.com/products/docker-desktop/" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Siguiente paso: Abrir Docker Desktop y esperar a que inicie" -ForegroundColor Cyan
Write-Host "Luego ejecutar: docker run -e ACCEPT_EULA=Y -e SA_PASSWORD=Semicrol_10 -p 1433:1433 --name sqlserver -v G:/SqlServerData:/var/opt/mssql -d mcr.microsoft.com/mssql/server:2022-latest" -ForegroundColor Yellow
```

---

## 🆘 ¿NECESITAS AYUDA?

Si tienes problemas en algún paso, dime en cuál te quedaste y te ayudo específicamente.

**¡Ahora sí estás listo para instalar Docker en G: y ahorrar espacio en C:!** 🚀
