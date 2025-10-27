# Configuración de Entornos - ACEXAPI

Este proyecto tiene configuraciones separadas para **Casa** y **Trabajo**.

## 🏠 Entorno CASA (Por defecto)

**Configuración:** `appsettings.json`

### Ejecutar desde CASA:
```powershell
cd ACEXAPI
dotnet run
```

O usar el script:
```powershell
.\start-api.ps1
```

**Conexión BD:**
- Servidor: Docker local
- Base de datos: ACEXAPI
- Usuario: sa
- Password: (configurado en appsettings.json)

---

## 💼 Entorno TRABAJO

**Configuración:** `appsettings.Trabajo.json`

### Ejecutar desde TRABAJO:
```powershell
cd ACEXAPI
.\start-api-trabajo.ps1
```

**Conexión BD:**
- Servidor: 127.0.0.1,1433 (Docker)
- Base de datos: ACEXAPI
- Usuario: sa
- Password: Semicrol_10

---

## 📝 Notas Importantes

1. **Antes de iniciar la API**, asegúrate de que:
   - SQL Server esté corriendo (Docker o local)
   - La base de datos ACEXAPI exista o se creará automáticamente
   - El puerto 5000 esté disponible

2. **Para cambiar entre entornos**:
   - En CASA: Ejecuta normalmente con `dotnet run`
   - En TRABAJO: Ejecuta con `.\start-api-trabajo.ps1`

3. **Verificar conexión a SQL Server**:
   ```powershell
   # En PowerShell
   Test-NetConnection 127.0.0.1 -Port 1433
   ```

4. **Si hay problemas con Docker SQL Server**:
   ```powershell
   # Ver contenedores corriendo
   docker ps
   
   # Iniciar SQL Server (si existe el contenedor)
   docker start nombre_contenedor
   ```

---

## 🔧 Troubleshooting

### Error: "The server was not found or was not accessible"
- Verifica que Docker Desktop esté corriendo
- Verifica que el contenedor de SQL Server esté iniciado
- Verifica el puerto 1433 con `netstat -an | findstr 1433`

### Error: "Login failed for user 'sa'"
- Verifica la contraseña en `appsettings.Trabajo.json`
- Verifica que la contraseña del contenedor Docker coincida

### La API no inicia
- Verifica que no haya otra aplicación usando el puerto 5000
- Ejecuta `netstat -ano | findstr 5000` para ver qué proceso lo está usando
