# =============================================
# GUÍA DE CONFIGURACIÓN ESPECÍFICA PARA TU SISTEMA
# Instancia: 127.0.0.1,1433 (SQL Server con Autenticación SQL)
# =============================================

## ? CONFIGURACIÓN DE TU SISTEMA

Tu SQL Server está configurado con:
- **Servidor:** 127.0.0.1,1433 (localhost puerto 1433)
- **Autenticación:** SQL Server Authentication
- **Usuario:** sa
- **Contraseña:** Semicrol_10

## PASO 1: VERIFICAR QUE SQL SERVER ESTÁ EN EJECUCIÓN

### Opción A: Usando Services (Recomendado)
1. Presiona `Win + R` y escribe: `services.msc`
2. Busca el servicio: **SQL Server (MSSQLSERVER)** o similar
3. Verifica que el Estado sea: **Running** (En ejecución)
4. Si no está corriendo: Clic derecho ? **Start** (Iniciar)

### Opción B: Usando PowerShell
```powershell
# Ver servicios de SQL Server
Get-Service | Where-Object { $_.DisplayName -like "*SQL Server*" }

# Iniciar SQL Server si no está corriendo
Start-Service "MSSQLSERVER"
```

### Opción C: Verificar conectividad al puerto
```powershell
# Probar que el puerto 1433 está abierto
Test-NetConnection -ComputerName 127.0.0.1 -Port 1433
```

## PASO 2: CONECTARSE EN SQL SERVER MANAGEMENT STUDIO 22

1. Abre **SQL Server Management Studio 22**
2. En la ventana de conexión configura:
   - **Server type:** Database Engine
   - **Server name:** `127.0.0.1,1433` o simplemente `127.0.0.1`
   - **Authentication:** SQL Server Authentication
   - **Login:** `sa`
   - **Password:** `Semicrol_10`
   - ?? Marca: **Trust server certificate** (si aparece la opción)
3. Clic en **Connect**

## PASO 3: CREAR LA BASE DE DATOS

1. Una vez conectado en SSMS, abre el archivo: **`Scripts/CreateDatabase.sql`**
2. Presiona **F5** o clic en **Execute**
3. Verifica en la ventana de mensajes que no haya errores
4. Deberías ver el mensaje: "Base de datos ACEXAPI creada exitosamente"
5. Actualiza el explorador de objetos (F5) y verás la base de datos **ACEXAPI**

## PASO 4: VERIFICAR LA INSTALACIÓN

1. En SSMS, abre el archivo: **`Scripts/VerifyDatabase.sql`**
2. Ejecuta el script (F5)
3. Verifica que:
   - La base de datos ACEXAPI existe
   - Las 13 tablas fueron creadas
   - Los datos iniciales (3 departamentos y 3 cursos) están presentes

## PASO 5: CONFIGURACIÓN YA ACTUALIZADA

? Tu archivo `appsettings.json` ya está configurado con:
```json
"ConnectionStrings": {
  "DefaultConnection": "Server=127.0.0.1,1433;Database=ACEXAPI;User Id=sa;Password=Semicrol_10;MultipleActiveResultSets=true;TrustServerCertificate=True;Encrypt=False"
}
```

### ?? IMPORTANTE - Seguridad en Producción
Para producción, considera:
1. Crear un usuario específico para la aplicación (no usar 'sa')
2. Mover la contraseña a **User Secrets** o **Azure Key Vault**
3. Usar permisos mínimos necesarios

### Configurar User Secrets (Opcional para Desarrollo):
```powershell
# En la carpeta del proyecto
dotnet user-secrets init
dotnet user-secrets set "ConnectionStrings:DefaultConnection" "Server=127.0.0.1,1433;Database=ACEXAPI;User Id=sa;Password=Semicrol_10;MultipleActiveResultSets=true;TrustServerCertificate=True;Encrypt=False"
```

Luego en appsettings.json puedes dejar:
```json
"ConnectionStrings": {
  "DefaultConnection": ""
}
```

## PASO 6: EJECUTAR TU APLICACIÓN

1. En Visual Studio, presiona **F5** para ejecutar
2. La aplicación debería:
   - Conectarse a SQL Server usando las credenciales configuradas
   - Detectar que la base de datos ya existe
   - Iniciar correctamente en modo Development
3. Accede a: `https://localhost:{puerto}` (Swagger debería abrirse automáticamente)

## ESTRUCTURA DE LA BASE DE DATOS CREADA

### Tablas Principales (8):
1. **Departamentos** - Departamentos educativos (3 registros iniciales)
2. **Cursos** - Niveles académicos (3 registros iniciales)
3. **Grupos** - Grupos de estudiantes
4. **Profesores** - Datos de profesores
5. **Localizaciones** - Lugares de actividades
6. **EmpTransportes** - Empresas de transporte
7. **Actividades** - Actividades extraescolares
8. **Usuarios** - Usuarios del sistema

### Tablas de Relación (3):
9. **GrupoPartics** - Grupos en actividades
10. **ProfParticipantes** - Profesores participantes
11. **ProfResponsables** - Profesores responsables

### Tablas de Soporte (2):
12. **Fotos** - Imágenes de actividades
13. **Contratos** - Contratos y presupuestos

## SOLUCIÓN DE PROBLEMAS

### "Login failed for user 'sa'"
- Verifica que la contraseña es correcta: `Semicrol_10`
- Asegúrate de que SQL Server permite autenticación mixta (Windows + SQL Server)
- Para verificar/cambiar: SSMS ? Clic derecho en servidor ? Properties ? Security ? SQL Server and Windows Authentication mode

### "A network-related or instance-specific error"
- Verifica que el servicio SQL Server está corriendo
- Verifica que el puerto 1433 está abierto: `Test-NetConnection -ComputerName 127.0.0.1 -Port 1433`
- Verifica que SQL Server Browser está corriendo (si es necesario)
- Comprueba el Firewall de Windows

### "Cannot open database 'ACEXAPI'"
- Asegúrate de haber ejecutado el script CreateDatabase.sql
- Verifica en SSMS que la base de datos existe: Databases ? ACEXAPI

### "Certificate chain was issued by an authority that is not trusted"
- Ya configurado en el connection string: `TrustServerCertificate=True;Encrypt=False`

### La aplicación no puede conectarse
1. Prueba la conexión primero en SSMS con las mismas credenciales
2. Verifica el connection string en appsettings.json
3. Revisa los logs de la aplicación en Visual Studio (Output window)

## COMANDOS ÚTILES

### Verificar servicios de SQL Server:
```powershell
Get-Service | Where-Object { $_.DisplayName -like "*SQL Server*" }
```

### Probar conexión desde PowerShell:
```powershell
# Instalar módulo si no lo tienes
# Install-Module -Name SqlServer

# Probar conexión
$connectionString = "Server=127.0.0.1,1433;Database=master;User Id=sa;Password=Semicrol_10;TrustServerCertificate=True;Encrypt=False"
try {
    $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
    $connection.Open()
    Write-Host "? Conexión exitosa!" -ForegroundColor Green
    $connection.Close()
} catch {
    Write-Host "? Error: $_" -ForegroundColor Red
}
```

### Ver bases de datos desde línea de comandos:
```powershell
sqlcmd -S 127.0.0.1,1433 -U sa -P Semicrol_10 -Q "SELECT name FROM sys.databases"
```

### Habilitar autenticación mixta (si es necesario):
```sql
-- Ejecuta esto en SSMS si tienes problemas de login
USE master;
GO
EXEC xp_instance_regwrite 
    N'HKEY_LOCAL_MACHINE', 
    N'Software\Microsoft\MSSQLServer\MSSQLServer',
    N'LoginMode', 
    REG_DWORD, 
    2; -- 2 = Mixed Mode (Windows + SQL Server Authentication)
GO
-- Después reinicia el servicio SQL Server
```

## CREAR USUARIO ESPECÍFICO PARA LA APLICACIÓN (RECOMENDADO)

En lugar de usar 'sa', crea un usuario específico:

```sql
-- Ejecuta en SSMS conectado como 'sa'
USE master;
GO

-- Crear login
CREATE LOGIN acexapi_user WITH PASSWORD = 'Tu_Contraseña_Segura_123!';
GO

-- Usar la base de datos
USE ACEXAPI;
GO

-- Crear usuario en la base de datos
CREATE USER acexapi_user FOR LOGIN acexapi_user;
GO

-- Dar permisos necesarios
ALTER ROLE db_datareader ADD MEMBER acexapi_user;
ALTER ROLE db_datawriter ADD MEMBER acexapi_user;
ALTER ROLE db_ddladmin ADD MEMBER acexapi_user; -- Solo si necesitas crear/modificar tablas
GO

PRINT 'Usuario acexapi_user creado correctamente';
```

Luego actualiza tu connection string:
```json
"DefaultConnection": "Server=127.0.0.1,1433;Database=ACEXAPI;User Id=acexapi_user;Password=Tu_Contraseña_Segura_123!;MultipleActiveResultSets=true;TrustServerCertificate=True;Encrypt=False"
```

## PRÓXIMOS PASOS DESPUÉS DE LA CONFIGURACIÓN

1. ? Crear usuarios en la tabla Usuarios
2. ? Registrar profesores
3. ? Crear grupos para los cursos existentes
4. ? Comenzar a registrar actividades
5. ? Probar los endpoints desde Swagger

## ACCESO A SWAGGER

Una vez que la aplicación esté corriendo:
- URL: `https://localhost:{puerto}/` (se abre automáticamente)
- Probar endpoints sin autenticación primero
- Para endpoints protegidos: Usa el botón "Authorize" y proporciona un token JWT válido

---
**¡Listo!** Con SQL Server corriendo y el script CreateDatabase.sql ejecutado, tu aplicación ACEXAPI debería funcionar perfectamente. ??
