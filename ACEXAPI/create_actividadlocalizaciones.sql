-- Create ActividadLocalizaciones table if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ActividadLocalizaciones]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[ActividadLocalizaciones](
        [Id] [int] IDENTITY(1,1) NOT NULL,
        [ActividadId] [int] NOT NULL,
        [LocalizacionId] [int] NOT NULL,
        [EsPrincipal] [bit] NOT NULL DEFAULT 0,
        [Orden] [int] NOT NULL DEFAULT 0,
        [FechaAsignacion] [datetime2](7) NOT NULL DEFAULT GETUTCDATE(),
     CONSTRAINT [PK_ActividadLocalizaciones] PRIMARY KEY CLUSTERED ([Id] ASC)
    )

    CREATE UNIQUE INDEX [IX_ActividadLocalizaciones_ActividadId_LocalizacionId] 
    ON [dbo].[ActividadLocalizaciones]([ActividadId], [LocalizacionId])

    ALTER TABLE [dbo].[ActividadLocalizaciones] WITH CHECK 
    ADD CONSTRAINT [FK_ActividadLocalizaciones_Actividades_ActividadId] 
    FOREIGN KEY([ActividadId]) REFERENCES [dbo].[Actividades] ([Id]) ON DELETE CASCADE

    ALTER TABLE [dbo].[ActividadLocalizaciones] WITH CHECK 
    ADD CONSTRAINT [FK_ActividadLocalizaciones_Localizaciones_LocalizacionId] 
    FOREIGN KEY([LocalizacionId]) REFERENCES [dbo].[Localizaciones] ([Id]) ON DELETE CASCADE

    PRINT 'Tabla ActividadLocalizaciones creada exitosamente'
END
ELSE
BEGIN
    PRINT 'La tabla ActividadLocalizaciones ya existe'
END
GO
