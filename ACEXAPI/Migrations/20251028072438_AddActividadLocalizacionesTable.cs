using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ACEXAPI.Migrations
{
    /// <inheritdoc />
    public partial class AddActividadLocalizacionesTable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "AlojamientoId",
                table: "Actividades",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "alojamiento_req",
                table: "Actividades",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<decimal>(
                name: "precio_transporte",
                table: "Actividades",
                type: "decimal(18,2)",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "transporte_req",
                table: "Actividades",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateTable(
                name: "Alojamientos",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Nombre = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    Direccion = table.Column<string>(type: "nvarchar(300)", maxLength: 300, nullable: true),
                    Ciudad = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    CodigoPostal = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: true),
                    Provincia = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    Telefono = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: true),
                    Email = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: true),
                    Web = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    TipoAlojamiento = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true),
                    NumeroHabitaciones = table.Column<int>(type: "int", nullable: true),
                    CapacidadTotal = table.Column<int>(type: "int", nullable: true),
                    PrecioPorNoche = table.Column<decimal>(type: "decimal(10,2)", nullable: true),
                    Servicios = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: true),
                    Observaciones = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: true),
                    Activo = table.Column<bool>(type: "bit", nullable: false),
                    FechaCreacion = table.Column<DateTime>(type: "datetime2", nullable: false),
                    Latitud = table.Column<decimal>(type: "decimal(10,7)", nullable: true),
                    Longitud = table.Column<decimal>(type: "decimal(10,7)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Alojamientos", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Actividades_AlojamientoId",
                table: "Actividades",
                column: "AlojamientoId");

            migrationBuilder.AddForeignKey(
                name: "FK_Actividades_Alojamientos_AlojamientoId",
                table: "Actividades",
                column: "AlojamientoId",
                principalTable: "Alojamientos",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Actividades_Alojamientos_AlojamientoId",
                table: "Actividades");

            migrationBuilder.DropTable(
                name: "Alojamientos");

            migrationBuilder.DropIndex(
                name: "IX_Actividades_AlojamientoId",
                table: "Actividades");

            migrationBuilder.DropColumn(
                name: "AlojamientoId",
                table: "Actividades");

            migrationBuilder.DropColumn(
                name: "alojamiento_req",
                table: "Actividades");

            migrationBuilder.DropColumn(
                name: "precio_transporte",
                table: "Actividades");

            migrationBuilder.DropColumn(
                name: "transporte_req",
                table: "Actividades");
        }
    }
}
