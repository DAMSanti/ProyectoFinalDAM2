using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ACEXAPI.Migrations
{
    /// <inheritdoc />
    public partial class SyncModelWithDatabase : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Already dropped in previous migration
            // migrationBuilder.DropForeignKey(
            //     name: "FK_Actividades_Departamentos_DepartamentoId",
            //     table: "Actividades");

            // Already dropped in previous migration
            // migrationBuilder.DropIndex(
            //     name: "IX_Usuarios_Email",
            //     table: "Usuarios");

            // Already dropped in previous migration
            // migrationBuilder.DropColumn(
            //     name: "Email",
            //     table: "Usuarios");

            // These columns don't exist in Alojamientos (never were created or already dropped)
            // migrationBuilder.DropColumn(
            //     name: "Latitud",
            //     table: "Alojamientos");

            // migrationBuilder.DropColumn(
            //     name: "Longitud",
            //     table: "Alojamientos");

            // migrationBuilder.DropColumn(
            //     name: "NumeroHabitaciones",
            //     table: "Alojamientos");

            // migrationBuilder.DropColumn(
            //     name: "PrecioPorNoche",
            //     table: "Alojamientos");

            // migrationBuilder.DropColumn(
            //     name: "Servicios",
            //     table: "Alojamientos");

            // migrationBuilder.DropColumn(
            //     name: "TipoAlojamiento",
            //     table: "Alojamientos");

            // Already dropped in previous migration
            // migrationBuilder.DropColumn(
            //     name: "Aprobada",
            //     table: "Actividades");

            // Already renamed in previous migration
            // migrationBuilder.RenameColumn(
            //     name: "NombreCompleto",
            //     table: "Usuarios",
            //     newName: "NombreUsuario");

            // Already added in previous migration
            // migrationBuilder.AddColumn<Guid>(
            //     name: "ProfesorUuid",
            //     table: "Usuarios",
            //     type: "uniqueidentifier",
            //     nullable: true);

            // Already added in previous migration
            // migrationBuilder.AddColumn<string>(
            //     name: "Estado",
            //     table: "Actividades",
            //     type: "nvarchar(20)",
            //     maxLength: 20,
            //     nullable: false,
            //     defaultValue: "");

            // Already added in previous migration
            // migrationBuilder.AddColumn<Guid>(
            //     name: "ResponsableId",
            //     table: "Actividades",
            //     type: "uniqueidentifier",
            //     nullable: true);

            // Already added in previous migration
            // migrationBuilder.AddColumn<string>(
            //     name: "Tipo",
            //     table: "Actividades",
            //     type: "nvarchar(20)",
            //     maxLength: 20,
            //     nullable: false,
            //     defaultValue: "");

            // Already added in previous migration (precio_alojamiento may or may not exist)
            // migrationBuilder.AddColumn<decimal>(
            //     name: "precio_alojamiento",
            //     table: "Actividades",
            //     type: "decimal(18,2)",
            //     precision: 18,
            //     scale: 2,
            //     nullable: true);

            // GastosPersonalizados table - check if it exists
            migrationBuilder.Sql(@"
                IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'GastosPersonalizados')
                BEGIN
                    CREATE TABLE GastosPersonalizados (
                        Id INT IDENTITY(1,1) NOT NULL,
                        ActividadId INT NOT NULL,
                        Concepto NVARCHAR(200) NOT NULL,
                        Cantidad DECIMAL(18,2) NOT NULL,
                        FechaCreacion DATETIME2 NOT NULL,
                        CONSTRAINT PK_GastosPersonalizados PRIMARY KEY (Id),
                        CONSTRAINT FK_GastosPersonalizados_Actividades_ActividadId 
                            FOREIGN KEY (ActividadId) REFERENCES Actividades(Id) ON DELETE CASCADE
                    )
                    CREATE INDEX IX_GastosPersonalizados_ActividadId ON GastosPersonalizados(ActividadId)
                END
            ");

            // Create indexes if they don't exist
            migrationBuilder.Sql(@"
                IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Usuarios_NombreUsuario')
                BEGIN
                    CREATE UNIQUE INDEX IX_Usuarios_NombreUsuario ON Usuarios(NombreUsuario)
                END
            ");

            migrationBuilder.Sql(@"
                IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Usuarios_ProfesorUuid')
                BEGIN
                    CREATE INDEX IX_Usuarios_ProfesorUuid ON Usuarios(ProfesorUuid)
                END
            ");

            migrationBuilder.Sql(@"
                IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Actividades_ResponsableId')
                BEGIN
                    CREATE INDEX IX_Actividades_ResponsableId ON Actividades(ResponsableId)
                END
            ");

            // REMOVE DepartamentoId from Actividades completely
            migrationBuilder.Sql(@"
                IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Actividades_DepartamentoId')
                BEGIN
                    DROP INDEX IX_Actividades_DepartamentoId ON Actividades
                END
            ");

            migrationBuilder.Sql(@"
                IF EXISTS (SELECT * FROM sys.columns 
                           WHERE object_id = OBJECT_ID('Actividades') 
                           AND name = 'DepartamentoId')
                BEGIN
                    ALTER TABLE Actividades DROP COLUMN DepartamentoId
                END
            ");

            // Add foreign keys if they don't exist
            migrationBuilder.Sql(@"
                IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Actividades_Profesores_ResponsableId')
                BEGIN
                    ALTER TABLE Actividades
                    ADD CONSTRAINT FK_Actividades_Profesores_ResponsableId
                    FOREIGN KEY (ResponsableId) REFERENCES Profesores(Uuid)
                END
            ");

            migrationBuilder.Sql(@"
                IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Usuarios_Profesores_ProfesorUuid')
                BEGIN
                    ALTER TABLE Usuarios
                    ADD CONSTRAINT FK_Usuarios_Profesores_ProfesorUuid
                    FOREIGN KEY (ProfesorUuid) REFERENCES Profesores(Uuid)
                END
            ");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Actividades_Departamentos_DepartamentoId",
                table: "Actividades");

            migrationBuilder.DropForeignKey(
                name: "FK_Actividades_Profesores_ResponsableId",
                table: "Actividades");

            migrationBuilder.DropForeignKey(
                name: "FK_Usuarios_Profesores_ProfesorUuid",
                table: "Usuarios");

            migrationBuilder.DropTable(
                name: "GastosPersonalizados");

            migrationBuilder.DropIndex(
                name: "IX_Usuarios_NombreUsuario",
                table: "Usuarios");

            migrationBuilder.DropIndex(
                name: "IX_Usuarios_ProfesorUuid",
                table: "Usuarios");

            migrationBuilder.DropIndex(
                name: "IX_Actividades_ResponsableId",
                table: "Actividades");

            migrationBuilder.DropColumn(
                name: "ProfesorUuid",
                table: "Usuarios");

            migrationBuilder.DropColumn(
                name: "Estado",
                table: "Actividades");

            migrationBuilder.DropColumn(
                name: "ResponsableId",
                table: "Actividades");

            migrationBuilder.DropColumn(
                name: "Tipo",
                table: "Actividades");

            migrationBuilder.DropColumn(
                name: "precio_alojamiento",
                table: "Actividades");

            migrationBuilder.RenameColumn(
                name: "NombreUsuario",
                table: "Usuarios",
                newName: "NombreCompleto");

            migrationBuilder.AddColumn<string>(
                name: "Email",
                table: "Usuarios",
                type: "nvarchar(256)",
                maxLength: 256,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<decimal>(
                name: "Latitud",
                table: "Alojamientos",
                type: "decimal(10,7)",
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "Longitud",
                table: "Alojamientos",
                type: "decimal(10,7)",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "NumeroHabitaciones",
                table: "Alojamientos",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "PrecioPorNoche",
                table: "Alojamientos",
                type: "decimal(10,2)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Servicios",
                table: "Alojamientos",
                type: "nvarchar(1000)",
                maxLength: 1000,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "TipoAlojamiento",
                table: "Alojamientos",
                type: "nvarchar(50)",
                maxLength: 50,
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "Aprobada",
                table: "Actividades",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.CreateIndex(
                name: "IX_Usuarios_Email",
                table: "Usuarios",
                column: "Email",
                unique: true);

            migrationBuilder.AddForeignKey(
                name: "FK_Actividades_Departamentos_DepartamentoId",
                table: "Actividades",
                column: "DepartamentoId",
                principalTable: "Departamentos",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);
        }
    }
}
