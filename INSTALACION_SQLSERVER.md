# 🗄️ INSTALACIÓN DE SQL SERVER - Guía Completa

## 📋 Opciones Disponibles

| Opción | Tamaño Descarga | Tamaño Instalado | Complejidad | Recomendado |
|--------|----------------|------------------|-------------|-------------|
| **SQL Server Express** | 1.5-2 GB | ~6 GB | ⭐ Fácil | ✅ **SÍ** |
| **Docker + SQL Server** | 2 GB total | ~4 GB | ⭐⭐ Media | Para avanzados |
| **SQL Server Developer** | 2-3 GB | ~8 GB | ⭐⭐ Media | Si tienes espacio |

---

## ✅ OPCIÓN 1: SQL SERVER EXPRESS (RECOMENDADO)

### ¿Por qué SQL Server Express?
- ✅ **Gratis** y completo para desarrollo
- ✅ **No necesita Docker**
- ✅ **Fácil de instalar**
- ✅ Incluye herramientas de gestión
- ✅ Perfecto para tu proyecto

### Paso 1: Descargar SQL Server Express

1. Ve a: **https://www.microsoft.com/es-es/sql-server/sql-server-downloads**

2. Busca la sección **"SQL Server 2022 Express"**

3. Clic en **"Descarga gratuita"**

### Paso 2: Instalación

#### A. Ejecutar el instalador
1. Abre el archivo descargado (`SQL2022-SSEI-Expr.exe`)
2. Selecciona **"Básica"** (Basic)
3. Acepta los términos de licencia
4. Elige la ubicación de instalación (requiere ~6 GB)
5. Clic en **"Instalar"**

#### B. Esperar la instalación
- Tardará 10-20 minutos dependiendo de tu conexión y PC

#### C. Configuración Post-Instalación

Una vez instalado, necesitas **habilitar autenticación SQL Server**:

**Opción A: Con PowerShell (Más Rápido)**

```powershell
# Abrir PowerShell como Administrador y ejecutar:

# 1. Detener el servicio
Stop-Service -Name 'MSSQL$SQLEXPRESS'

# 2. Cambiar a modo de autenticación mixta
# (Ejecuta estos comandos uno por uno)
$instance = "MSSQLSERVER" # O "SQLEXPRESS" si instalaste Express
$key = "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL16.$instance\MSSQLServer"
Set-ItemProperty -Path $key -Name "LoginMode" -Value 2

# 3. Iniciar el servicio
Start-Service -Name 'MSSQL$SQLEXPRESS'
```

**Opción B: Con SSMS (SQL Server Management Studio)**

Si instalaste SSMS, sigue estos pasos:

1. Abre **SQL Server Configuration Manager**
2. Ve a **SQL Server Network Configuration** > **Protocols for SQLEXPRESS**
3. Habilita **TCP/IP**
4. Reinicia el servicio SQL Server

### Paso 3: Crear usuario 'sa' con contraseña

Abre PowerShell y ejecuta:

```powershell
# Conectar con autenticación Windows
sqlcmd -S localhost\SQLEXPRESS -E -Q "ALTER LOGIN sa ENABLE; ALTER LOGIN sa WITH PASSWORD = 'Semicrol_10';"
```

### Paso 4: Verificar Instalación

```powershell
# Probar conexión con el usuario 'sa'
sqlcmd -S "localhost\SQLEXPRESS" -U sa -P "Semicrol_10" -Q "SELECT @@VERSION"
```

✅ Si muestra la versión de SQL Server, **¡está listo!**

### Paso 5: Actualizar Connection String en tu proyecto

Edita `ACEXAPI/appsettings.json`:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost\\SQLEXPRESS;Database=ACEXAPI;User Id=sa;Password=Semicrol_10;MultipleActiveResultSets=true;TrustServerCertificate=True;Encrypt=False"
  }
}
```

⚠️ **Nota:** Usa `\\SQLEXPRESS` (doble barra invertida) en JSON.

---

## 🐳 OPCIÓN 2: DOCKER + SQL SERVER

### ¿Cuándo usar Docker?
- Si ya conoces Docker
- Si quieres aislar SQL Server en un contenedor
- Si quieres fácil backup/restore de contenedores

### Paso 1: Instalar Docker Desktop

1. **Descargar Docker Desktop:**
   - Ve a: **https://www.docker.com/products/docker-desktop/**
   - Descarga para Windows (~500 MB)

2. **Requisitos:**
   - Windows 10/11 Pro, Enterprise o Education (64-bit)
   - WSL 2 habilitado
   - Virtualización habilitada en BIOS

3. **Instalación:**
   - Ejecuta el instalador
   - Sigue el asistente
   - Reinicia el PC si se solicita
   - Abre Docker Desktop y espera a que inicie

### Paso 2: Verificar Docker

```powershell
# Verificar que Docker está instalado
docker --version

# Debe mostrar: Docker version 24.x.x o similar
```

### Paso 3: Descargar y Ejecutar SQL Server

```powershell
# Descargar imagen de SQL Server 2022 (~1.5 GB)
docker pull mcr.microsoft.com/mssql/server:2022-latest

# Ejecutar contenedor
docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=Semicrol_10" -e "MSSQL_PID=Express" -p 1433:1433 --name sqlserver --restart always -d mcr.microsoft.com/mssql/server:2022-latest
```

### Paso 4: Verificar que está corriendo

```powershell
# Ver contenedores corriendo
docker ps

# Debe aparecer 'sqlserver' con status 'Up'
```

### Paso 5: Conectar a SQL Server en Docker

```powershell
# Probar conexión
sqlcmd -S "127.0.0.1,1433" -U sa -P "Semicrol_10" -Q "SELECT @@VERSION"
```

### Comandos útiles de Docker

```powershell
# Iniciar contenedor (si está detenido)
docker start sqlserver

# Detener contenedor
docker stop sqlserver

# Ver logs
docker logs sqlserver

# Eliminar contenedor (¡cuidado! perderás los datos)
docker rm -f sqlserver

# Entrar al contenedor (shell)
docker exec -it sqlserver /bin/bash
```

### Connection String para Docker

Usa la misma que ya tienes en `appsettings.json`:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=127.0.0.1,1433;Database=ACEXAPI;User Id=sa;Password=Semicrol_10;MultipleActiveResultSets=true;TrustServerCertificate=True;Encrypt=False"
  }
}
```

---

## 🛠️ OPCIÓN 3: SQL SERVER DEVELOPER EDITION

Similar a SQL Server Express pero con más características.

### Descargar

1. Ve a: **https://www.microsoft.com/es-es/sql-server/sql-server-downloads**
2. Selecciona **"Developer Edition"** (Gratis)
3. Descarga el instalador (~2-3 GB)

### Instalación

Igual que SQL Server Express, pero incluye todas las características empresariales.

---

## 📊 COMPARACIÓN RÁPIDA

### SQL Server Express
**✅ Ventajas:**
- Fácil de instalar
- No requiere Docker
- Instalación nativa en Windows
- Incluye herramientas

**❌ Desventajas:**
- Ocupa más espacio (~6 GB)
- Menos portable

### Docker + SQL Server
**✅ Ventajas:**
- Más ligero (~4 GB)
- Fácil de eliminar/reinstalar
- Portable entre sistemas
- Aislado del sistema

**❌ Desventajas:**
- Requiere instalar Docker primero
- Curva de aprendizaje
- Requiere virtualización

---

## 🎯 MI RECOMENDACIÓN PARA TI

### Si eres principiante o no conoces Docker:
👉 **SQL Server Express** (Opción 1)

### Si ya usas Docker o quieres aprenderlo:
👉 **Docker + SQL Server** (Opción 2)

### Si tienes espacio y quieres todas las características:
👉 **SQL Server Developer** (Opción 3)

---

## 🚀 INSTALACIÓN RÁPIDA RECOMENDADA

### Para principiantes (SQL Server Express):

1. **Descargar:**
   https://www.microsoft.com/es-es/sql-server/sql-server-downloads
   
2. **Instalar:**
   - Ejecutar instalador
   - Seleccionar "Básica"
   - Esperar 15-20 minutos
   
3. **Configurar:**
   ```powershell
   # Habilitar usuario 'sa'
   sqlcmd -S localhost\SQLEXPRESS -E -Q "ALTER LOGIN sa ENABLE; ALTER LOGIN sa WITH PASSWORD = 'Semicrol_10';"
   ```
   
4. **Actualizar appsettings.json:**
   ```json
   "Server=localhost\\SQLEXPRESS;Database=ACEXAPI;..."
   ```

5. **Crear base de datos:**
   ```powershell
   cd ACEXAPI
   dotnet ef database update
   ```

✅ **¡Listo para usar!**

---

## 🔍 VERIFICACIÓN FINAL

Después de instalar, verifica con:

```powershell
# Ver servicios SQL Server
Get-Service | Where-Object {$_.DisplayName -like "*SQL*"}

# Probar conexión
sqlcmd -S "TU_SERVIDOR" -U sa -P "Semicrol_10" -Q "SELECT @@VERSION"

# Listar bases de datos
sqlcmd -S "TU_SERVIDOR" -U sa -P "Semicrol_10" -Q "SELECT name FROM sys.databases"
```

Reemplaza `TU_SERVIDOR` con:
- `localhost\SQLEXPRESS` (SQL Server Express)
- `127.0.0.1,1433` (Docker)

---

## 🆘 SOLUCIÓN DE PROBLEMAS

### Error: "Login failed for user 'sa'"
```powershell
# Habilitar usuario sa y cambiar contraseña
sqlcmd -S localhost\SQLEXPRESS -E -Q "ALTER LOGIN sa ENABLE; ALTER LOGIN sa WITH PASSWORD = 'Semicrol_10';"
```

### Error: "Cannot connect to server"
```powershell
# Verificar que el servicio está corriendo
Get-Service | Where-Object {$_.DisplayName -like "*SQL*"}

# Iniciar servicio si está detenido
Start-Service 'MSSQL$SQLEXPRESS'
```

### Error: "TCP/IP is not enabled"
1. Abre **SQL Server Configuration Manager**
2. Ve a **SQL Server Network Configuration** > **Protocols for SQLEXPRESS**
3. Clic derecho en **TCP/IP** > **Enable**
4. Reinicia el servicio SQL Server

---

## 📚 RECURSOS ADICIONALES

- **SQL Server Express:** https://www.microsoft.com/es-es/sql-server/sql-server-downloads
- **Docker Desktop:** https://www.docker.com/products/docker-desktop/
- **SSMS (SQL Server Management Studio):** https://aka.ms/ssmsfullsetup
- **Azure Data Studio (Alternativa moderna):** https://aka.ms/azuredatastudio

---

**¿Necesitas ayuda adicional?** Pregúntame cualquier duda sobre la instalación. 🙋‍♂️
