# Crear Tabla GastosPersonalizados en Producción

## Problema
La tabla `GastosPersonalizados` no existe en la base de datos de producción (DigitalOcean), causando errores 500 al intentar cargar gastos.

## Solución

### Opción 1: Usando Azure Data Studio o SQL Server Management Studio (SSMS)

1. Conectar al servidor:
   - Server: `64.226.85.100,1433`
   - User: `SA`
   - Password: `Semicrol_10!`
   - Database: `ACEXAPI`

2. Ejecutar el script: `create_gastos_personalizados.sql`

### Opción 2: Desde PowerShell/Terminal

```powershell
sqlcmd -S "64.226.85.100,1433" -U SA -P "Semicrol_10!" -d ACEXAPI -i "create_gastos_personalizados.sql"
```

### Opción 3: Usando Entity Framework Migrations

Si tienes acceso al servidor, puedes crear una migración:

```bash
cd ACEXAPI
dotnet ef migrations add AddGastosPersonalizados
dotnet ef database update --connection "Server=64.226.85.100,1433;Initial Catalog=ACEXAPI;User ID=SA;Password=Semicrol_10!;..."
```

## Verificación

Después de crear la tabla, verifica que existe:

```sql
SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'GastosPersonalizados';
```

## Estado Actual

✅ **Frontend**: Maneja el error gracefully, inicializa lista vacía si la tabla no existe
✅ **Backend**: Controller tiene manejo de errores mejorado para logs detallados
❌ **Base de Datos**: Tabla pendiente de crear en producción

## Nota

El frontend seguirá funcionando sin la tabla, pero no podrá:
- Cargar gastos personalizados existentes
- Crear nuevos gastos personalizados
- Mostrar el total de "Gastos Varios" en el presupuesto
