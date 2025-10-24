# Poblar Base de Datos ACEXAPI con Datos de Ejemplo

## 📋 Descripción

Este directorio contiene scripts SQL para poblar la base de datos ACEXAPI con datos de ejemplo.

## 🎯 Scripts disponibles

### 1. `PoblarBaseDatos.sql` - Script completo de población

Inserta datos de ejemplo en todas las tablas:

- **Departamentos** (6): Informática, Matemáticas, Lengua, Ciencias, Educación Física, Idiomas
- **Cursos** (8): 1º-4º ESO, 1º-2º ASIR, 1º-2º DAW
- **Grupos** (8): Grupos A/B de ESO y grupos de FP
- **Profesores** (6): Profesores de diferentes departamentos
- **Localizaciones** (5): Museo, Parque Cabárceno, Playa, Centro Cultural, Polideportivo
- **Empresas de Transporte** (3)
- **Actividades** (10):
  - 5 futuras aprobadas (aparecen en Home)
  - 3 pasadas realizadas
  - 2 pendientes de aprobación
- **Grupos Participantes**: Relación grupos-actividades
- **Profesores Responsables y Participantes**
- **Contratos de Transporte**

### 2. `InsertTestActivities.sql` - Script anterior de actividades

Script antiguo con 6 actividades de ejemplo (mantiene compatibilidad).

### 3. `databaseExport.sql` - Exportación MySQL

Exportación de una base de datos MySQL anterior (estructura diferente, datos de referencia).

## 🚀 Ejecución rápida

### PowerShell (RECOMENDADO)

Desde la raíz del proyecto ejecuta:

```powershell
.\poblar-base-datos.ps1
```

### SQL Command Line

```powershell
sqlcmd -S localhost\SQLEXPRESS -U sa -P Semicrol_10 -i "DB\PoblarBaseDatos.sql"
```

### SQL Server Management Studio

1. Abrir SSMS
2. Conectar a `localhost\SQLEXPRESS`
3. Abrir `DB\PoblarBaseDatos.sql`
4. Ejecutar (F5)

## ✅ Verificación

Después de ejecutar verás un resumen con el total de registros insertados en cada tabla.

## 📝 Notas importantes

- El script usa `IF NOT EXISTS` para evitar duplicados
- Las fechas de actividades futuras son relativas (GETDATE() + días)
- Puedes re-ejecutar sin borrar datos existentes
- Para limpiar y volver a empezar, descomenta las líneas DELETE al inicio del script

## 🔧 Troubleshooting

### SQL Server no responde
```powershell
Get-Service MSSQL*
Start-Service MSSQL$SQLEXPRESS
```

### Base de datos no existe
```powershell
cd ACEXAPI
dotnet ef database update
```

## 📚 Más información

Ver el archivo raíz `GUIA_INSTALACION.md` para instrucciones completas de configuración.
