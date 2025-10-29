# Script para exportar la base de datos ACEXAPI a SQL script

Write-Host "======================================"
Write-Host "  Exportación de Base de Datos ACEXAPI"
Write-Host "======================================"
Write-Host ""

$outputFile = "G:\ProyectoFinalCSharp\ProyectoFinalDAM2\deploy\acexapi_database.sql"
$server = ".\SQLEXPRESS"
$database = "ACEXAPI"

Write-Host "📦 Exportando base de datos..." -ForegroundColor Cyan

# Obtener todas las tablas
$tables = sqlcmd -S $server -d $database -E -h -1 -Q "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' ORDER BY TABLE_NAME;" -W

# Iniciar archivo SQL
@"
-- ====================================
-- ACEXAPI Database Export
-- Fecha: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
-- ====================================

USE ACEXAPI;
GO

-- Deshabilitar constraints temporalmente
EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL';
GO

"@ | Out-File -FilePath $outputFile -Encoding UTF8

Write-Host "📋 Tablas a exportar:" -ForegroundColor Yellow
foreach ($table in $tables) {
    $table = $table.Trim()
    if ($table -and $table -ne "" -and $table -ne "TABLE_NAME") {
        Write-Host "   - $table"
    }
}

Write-Host ""
Write-Host "⏳ Generando scripts..." -ForegroundColor Cyan

# Usar bcp para exportar datos
$tables | ForEach-Object {
    $table = $_.Trim()
    if ($table -and $table -ne "" -and $table -ne "TABLE_NAME") {
        Write-Host "   Exportando: $table" -ForegroundColor Gray
        
        # Obtener CREATE TABLE
        $createScript = sqlcmd -S $server -d $database -E -h -1 -Q "
        DECLARE @table NVARCHAR(MAX) = '$table';
        SELECT 
            'IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''' + @table + ''') AND type in (N''U''))' + CHAR(13) + CHAR(10) +
            'CREATE TABLE [' + @table + '] (' + CHAR(13) + CHAR(10) +
            STUFF((
                SELECT ',' + CHAR(13) + CHAR(10) + 
                    '    [' + c.COLUMN_NAME + '] ' + 
                    c.DATA_TYPE + 
                    CASE 
                        WHEN c.DATA_TYPE IN ('varchar', 'nvarchar', 'char', 'nchar') THEN 
                            '(' + CASE WHEN c.CHARACTER_MAXIMUM_LENGTH = -1 THEN 'MAX' ELSE CAST(c.CHARACTER_MAXIMUM_LENGTH AS VARCHAR) END + ')'
                        WHEN c.DATA_TYPE IN ('decimal', 'numeric') THEN 
                            '(' + CAST(c.NUMERIC_PRECISION AS VARCHAR) + ',' + CAST(c.NUMERIC_SCALE AS VARCHAR) + ')'
                        ELSE ''
                    END +
                    CASE WHEN c.IS_NULLABLE = 'NO' THEN ' NOT NULL' ELSE ' NULL' END
                FROM INFORMATION_SCHEMA.COLUMNS c
                WHERE c.TABLE_NAME = @table
                ORDER BY c.ORDINAL_POSITION
                FOR XML PATH('')
            ), 1, 1, '') + CHAR(13) + CHAR(10) + ');' + CHAR(13) + CHAR(10) + 'GO'
        " -W
        
        $createScript | Out-File -FilePath $outputFile -Append -Encoding UTF8
        
        # Exportar datos
        $rowCount = sqlcmd -S $server -d $database -E -h -1 -Q "SELECT COUNT(*) FROM [$table]" -W
        $rowCount = [int]($rowCount.Trim())
        
        if ($rowCount -gt 0) {
            Write-Host "      └─ $rowCount filas" -ForegroundColor DarkGray
            
            "`n-- Datos para $table" | Out-File -FilePath $outputFile -Append -Encoding UTF8
            "SET IDENTITY_INSERT [$table] ON;" | Out-File -FilePath $outputFile -Append -Encoding UTF8
            
            $data = sqlcmd -S $server -d $database -E -Q "SELECT * FROM [$table]" -s "," -W -h -1
            
            # Aquí podrías generar INSERTs, pero es complejo con sqlcmd
            # Por ahora dejamos comentario
            "-- Insertar datos manualmente o usar bcp" | Out-File -FilePath $outputFile -Append -Encoding UTF8
            "SET IDENTITY_INSERT [$table] OFF;" | Out-File -FilePath $outputFile -Append -Encoding UTF8
            "GO`n" | Out-File -FilePath $outputFile -Append -Encoding UTF8
        }
    }
}

# Rehabilitar constraints
@"

-- Rehabilitar constraints
EXEC sp_MSforeachtable 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL';
GO

"@ | Out-File -FilePath $outputFile -Append -Encoding UTF8

Write-Host ""
Write-Host "✅ Exportación completada!" -ForegroundColor Green
Write-Host "📄 Archivo: $outputFile" -ForegroundColor Cyan
Write-Host ""
Write-Host "⚠️  NOTA: Este script contiene solo la estructura." -ForegroundColor Yellow
Write-Host "Para exportar datos, usa el backup .bak creado anteriormente" -ForegroundColor Yellow
