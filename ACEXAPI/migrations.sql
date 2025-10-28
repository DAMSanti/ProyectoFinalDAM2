IF OBJECT_ID(N'[__EFMigrationsHistory]') IS NULL
BEGIN
    CREATE TABLE [__EFMigrationsHistory] (
        [MigrationId] nvarchar(150) NOT NULL,
        [ProductVersion] nvarchar(32) NOT NULL,
        CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY ([MigrationId])
    );
END;
GO

BEGIN TRANSACTION;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251027212213_AddIconoEsPrincipalToLocalizacion'
)
BEGIN
    ALTER TABLE [Localizaciones] ADD [EsPrincipal] bit NOT NULL DEFAULT CAST(0 AS bit);
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251027212213_AddIconoEsPrincipalToLocalizacion'
)
BEGIN
    ALTER TABLE [Localizaciones] ADD [Icono] nvarchar(50) NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251027212213_AddIconoEsPrincipalToLocalizacion'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20251027212213_AddIconoEsPrincipalToLocalizacion', N'8.0.0');
END;
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251028072438_AddActividadLocalizacionesTable'
)
BEGIN
    ALTER TABLE [Actividades] ADD [AlojamientoId] int NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251028072438_AddActividadLocalizacionesTable'
)
BEGIN
    ALTER TABLE [Actividades] ADD [alojamiento_req] int NOT NULL DEFAULT 0;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251028072438_AddActividadLocalizacionesTable'
)
BEGIN
    ALTER TABLE [Actividades] ADD [precio_transporte] decimal(18,2) NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251028072438_AddActividadLocalizacionesTable'
)
BEGIN
    ALTER TABLE [Actividades] ADD [transporte_req] int NOT NULL DEFAULT 0;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251028072438_AddActividadLocalizacionesTable'
)
BEGIN
    CREATE TABLE [Alojamientos] (
        [Id] int NOT NULL IDENTITY,
        [Nombre] nvarchar(200) NOT NULL,
        [Direccion] nvarchar(300) NULL,
        [Ciudad] nvarchar(100) NULL,
        [CodigoPostal] nvarchar(20) NULL,
        [Provincia] nvarchar(100) NULL,
        [Telefono] nvarchar(20) NULL,
        [Email] nvarchar(200) NULL,
        [Web] nvarchar(max) NULL,
        [TipoAlojamiento] nvarchar(50) NULL,
        [NumeroHabitaciones] int NULL,
        [CapacidadTotal] int NULL,
        [PrecioPorNoche] decimal(10,2) NULL,
        [Servicios] nvarchar(1000) NULL,
        [Observaciones] nvarchar(1000) NULL,
        [Activo] bit NOT NULL,
        [FechaCreacion] datetime2 NOT NULL,
        [Latitud] decimal(10,7) NULL,
        [Longitud] decimal(10,7) NULL,
        CONSTRAINT [PK_Alojamientos] PRIMARY KEY ([Id])
    );
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251028072438_AddActividadLocalizacionesTable'
)
BEGIN
    CREATE INDEX [IX_Actividades_AlojamientoId] ON [Actividades] ([AlojamientoId]);
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251028072438_AddActividadLocalizacionesTable'
)
BEGIN
    ALTER TABLE [Actividades] ADD CONSTRAINT [FK_Actividades_Alojamientos_AlojamientoId] FOREIGN KEY ([AlojamientoId]) REFERENCES [Alojamientos] ([Id]) ON DELETE SET NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251028072438_AddActividadLocalizacionesTable'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20251028072438_AddActividadLocalizacionesTable', N'8.0.0');
END;
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251028072449_AddMissingColumnsAndTables'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20251028072449_AddMissingColumnsAndTables', N'8.0.0');
END;
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251028072838_CreateActividadLocalizacionesTable'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20251028072838_CreateActividadLocalizacionesTable', N'8.0.0');
END;
GO

COMMIT;
GO

