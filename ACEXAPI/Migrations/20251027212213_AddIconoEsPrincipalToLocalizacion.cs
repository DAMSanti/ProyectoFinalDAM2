using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ACEXAPI.Migrations
{
    /// <inheritdoc />
    public partial class AddIconoEsPrincipalToLocalizacion : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Solo agregar las columnas nuevas a la tabla Localizaciones existente
            migrationBuilder.AddColumn<bool>(
                name: "EsPrincipal",
                table: "Localizaciones",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<string>(
                name: "Icono",
                table: "Localizaciones",
                type: "nvarchar(50)",
                maxLength: 50,
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "EsPrincipal",
                table: "Localizaciones");

            migrationBuilder.DropColumn(
                name: "Icono",
                table: "Localizaciones");
        }
    }
}
