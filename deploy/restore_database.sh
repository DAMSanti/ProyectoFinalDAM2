#!/bin/bash
# Script para restaurar la base de datos ACEXAPI en el servidor

set -e

echo "======================================"
echo "  Restauración de Base de Datos"
echo "======================================"
echo ""

# Verificar que se pasó la contraseña SA
if [ -z "$1" ]; then
    echo "❌ Error: Debes proporcionar la contraseña SA"
    echo "Uso: ./restore_database.sh <SA_PASSWORD>"
    exit 1
fi

SA_PASSWORD="$1"

# Crear la base de datos
echo "📦 Creando base de datos ACEXAPI..."
/opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P "$SA_PASSWORD" -C -Q "
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'ACEXAPI')
BEGIN
    CREATE DATABASE ACEXAPI;
END
GO
"

echo "✅ Base de datos creada"
echo ""

# Restaurar el script SQL
if [ -f "/tmp/acexapi_database.sql" ]; then
    echo "📥 Restaurando estructura y datos..."
    /opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P "$SA_PASSWORD" -d ACEXAPI -C -i /tmp/acexapi_database.sql
    echo "✅ Base de datos restaurada correctamente"
else
    echo "⚠️  Archivo /tmp/acexapi_database.sql no encontrado"
    echo "Deberás restaurar la base de datos manualmente"
fi

echo ""
echo "📊 Verificando tablas..."
/opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P "$SA_PASSWORD" -d ACEXAPI -C -Q "
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' ORDER BY TABLE_NAME;
"

echo ""
echo "✅ ¡Restauración completada!"
