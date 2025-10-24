# 🐳 GUÍA RÁPIDA: Docker en G: + SQL Server

## 📋 TU SITUACIÓN
- ✅ Tienes solo **800 MB libres en C:**
- ✅ Tienes espacio en **G:**
- ✅ Quieres instalar Docker + SQL Server

---

## 🚀 PASOS SIMPLIFICADOS

### PASO 1: Preparar el sistema (PowerShell como Administrador)

```powershell
# Ejecutar el script de instalación
.\instalar-docker.ps1
```

Este script:
- ✅ Habilita WSL 2 (necesario para Docker)
- ✅ Crea carpetas en G:\
- ✅ Te guía para descargar Docker Desktop
- ✅ Instala Docker en G:\Docker

**⚠️ Necesitarás reiniciar el PC después de este paso**

---

### PASO 2: Descargar Docker Desktop

1. **Descarga desde:** https://www.docker.com/products/docker-desktop/
2. **Guarda en:** `G:\Downloads\Docker Desktop Installer.exe`
3. **Tamaño:** ~500 MB

---

### PASO 3: Ejecutar el script de instalación de nuevo

Después de descargar Docker Desktop y reiniciar el PC:

```powershell
# Ejecutar como Administrador
.\instalar-docker.ps1
```

El script instalará Docker Desktop automáticamente.

---

### PASO 4: Iniciar Docker Desktop

1. Abre Docker Desktop desde el menú de inicio
2. Acepta los términos de servicio
3. **Espera 2-3 minutos** a que inicie completamente
4. Verás un ícono de Docker en la bandeja del sistema (abajo a la derecha)

---

### PASO 5: Mover datos de Docker a G: (Opcional pero recomendado)

```powershell
# Ejecutar como Administrador
.\mover-docker-datos.ps1
```

Este script mueve todos los datos de Docker de C: a G:\DockerData

**Espacio liberado en C:** ~2-3 GB

---

### PASO 6: Instalar SQL Server en Docker

```powershell
.\instalar-sqlserver-docker.ps1
```

Este script:
- ✅ Descarga SQL Server 2022 (~1.5 GB)
- ✅ Crea el contenedor 'sqlserver'
- ✅ Guarda los datos en G:\SqlServerData
- ✅ Configura puerto 1433
- ✅ Reinicio automático

---

### PASO 7: Crear la base de datos ACEXAPI

```powershell
cd ACEXAPI
dotnet ef database update
```

O usar el script SQL:
```powershell
sqlcmd -S "127.0.0.1,1433" -U sa -P "Semicrol_10" -i "ACEXAPI\Scripts\CreateDatabase.sql"
```

---

### PASO 8: ¡Ejecutar tu aplicación!

```powershell
cd ACEXAPI
dotnet run
```

---

## 📊 RESUMEN DE ESPACIO

| Ubicación | Contenido | Tamaño |
|-----------|-----------|--------|
| **C:\Program Files\Docker** | Binarios de Docker | ~500 MB |
| **G:\Docker** | Instalación | ~1 GB |
| **G:\DockerData** | Datos de WSL 2 + Docker | ~2-3 GB |
| **G:\SqlServerData** | Base de datos SQL Server | Variable |
| **Total en C:** | | **~1 GB** |
| **Total en G:** | | **~5-10 GB** |

---

## 🔧 COMANDOS ÚTILES

### Docker
```powershell
# Ver contenedores corriendo
docker ps

# Ver todas las imágenes
docker images

# Ver espacio usado
docker system df

# Limpiar espacio
docker system prune -a
```

### SQL Server
```powershell
# Iniciar
docker start sqlserver

# Detener
docker stop sqlserver

# Ver logs
docker logs sqlserver

# Conectar
sqlcmd -S "127.0.0.1,1433" -U sa -P "Semicrol_10"
```

---

## 📋 INFORMACIÓN DE CONEXIÓN

Una vez todo instalado:

```
Servidor: 127.0.0.1,1433
Usuario: sa
Contraseña: Semicrol_10
Base de datos: ACEXAPI
```

**Connection String (ya configurado en tu appsettings.json):**
```
Server=127.0.0.1,1433;Database=ACEXAPI;User Id=sa;Password=Semicrol_10;MultipleActiveResultSets=true;TrustServerCertificate=True;Encrypt=False
```

---

## 🐛 SOLUCIÓN RÁPIDA DE PROBLEMAS

### "WSL 2 installation is incomplete"
```powershell
wsl --update
wsl --shutdown
```
Luego reinicia el PC.

### "Docker no inicia"
1. Verifica que la virtualización esté habilitada en BIOS
2. Reinicia Docker Desktop
3. Revisa los logs en Docker Desktop (⚙️ Settings > Troubleshoot > View logs)

### "SQL Server no conecta"
```powershell
# Verificar que está corriendo
docker ps

# Ver logs
docker logs sqlserver

# Reiniciar
docker restart sqlserver
```

### "Puerto 1433 ocupado"
```powershell
# Ver qué lo usa
netstat -ano | findstr :1433

# Matar proceso (reemplaza XXXX con el PID)
taskkill /PID XXXX /F
```

---

## 📚 ARCHIVOS CREADOS

- ✅ **instalar-docker.ps1** - Instala Docker en G:
- ✅ **mover-docker-datos.ps1** - Mueve datos a G:
- ✅ **instalar-sqlserver-docker.ps1** - Instala SQL Server
- ✅ **INSTALACION_DOCKER_OTRA_UNIDAD.md** - Guía detallada
- ✅ **Este archivo** - Guía rápida

---

## ✅ CHECKLIST

- [ ] WSL 2 habilitado
- [ ] PC reiniciado
- [ ] Docker Desktop descargado
- [ ] Docker instalado en G:\Docker
- [ ] Docker Desktop iniciado
- [ ] Datos movidos a G: (opcional)
- [ ] SQL Server instalado
- [ ] Base de datos ACEXAPI creada
- [ ] Aplicación corriendo

---

## 🎯 RESUMEN DE COMANDOS (ORDEN)

```powershell
# 1. Instalar Docker (como Administrador)
.\instalar-docker.ps1

# 2. Reiniciar PC (si lo pide el script)
Restart-Computer

# 3. Iniciar Docker Desktop manualmente desde el menú

# 4. Mover datos a G: (opcional)
.\mover-docker-datos.ps1

# 5. Instalar SQL Server
.\instalar-sqlserver-docker.ps1

# 6. Crear base de datos
cd ACEXAPI
dotnet ef database update

# 7. Ejecutar aplicación
dotnet run
```

---

**¿Dudas?** Revisa **INSTALACION_DOCKER_OTRA_UNIDAD.md** para la guía completa detallada.

¡Ahora sí, a programar! 🚀
