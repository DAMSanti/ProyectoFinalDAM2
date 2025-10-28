-- Script para insertar alojamientos de ejemplo
-- Fecha: 2025-10-28

-- Verificar si ya existen alojamientos
SELECT COUNT(*) as TotalAlojamientos FROM Alojamientos;

-- Insertar alojamientos de ejemplo
SET IDENTITY_INSERT Alojamientos ON;

INSERT INTO Alojamientos (
    Id, Nombre, Direccion, Ciudad, CodigoPostal, Provincia, 
    Telefono, Email, Web, TipoAlojamiento, 
    NumeroHabitaciones, CapacidadTotal, PrecioPorNoche, 
    Servicios, Observaciones, Activo, FechaCreacion,
    Latitud, Longitud
) VALUES 
(1, 'Hotel Plaza Mayor', 'Calle Mayor 15', 'Madrid', '28013', 'Madrid',
 '915551234', 'info@hotelplazamayor.com', 'www.hotelplazamayor.com', 'Hotel',
 50, 100, 75.00,
 'WiFi, Desayuno incluido, Parking, Aire acondicionado',
 'Hotel céntrico ideal para grupos escolares. Dispone de salones para actividades.',
 1, GETDATE(), 40.4168, -3.7038),

(2, 'Albergue Juvenil La Montaña', 'Avenida de los Picos 23', 'León', '24001', 'León',
 '987223344', 'reservas@alberguelamontana.es', 'www.alberguelamontana.es', 'Albergue',
 30, 120, 35.00,
 'WiFi, Pensión completa, Actividades al aire libre, Comedor',
 'Albergue juvenil con instalaciones deportivas y zonas verdes. Perfecto para grupos grandes.',
 1, GETDATE(), 42.5987, -5.5671),

(3, 'Hostal Buen Camino', 'Plaza del Peregrino 8', 'Santiago de Compostela', '15704', 'A Coruña',
 '981567890', 'contacto@hostalbuencamino.com', 'www.hostalbuencamino.com', 'Hostal',
 20, 60, 45.00,
 'WiFi, Media pensión, Zona común, Cocina compartida',
 'Hostal acogedor en pleno casco histórico. Habitaciones múltiples disponibles.',
 1, GETDATE(), 42.8805, -8.5456),

(4, 'Residencia Universitaria Cervantes', 'Campus Universitario s/n', 'Salamanca', '37008', 'Salamanca',
 '923445566', 'info@residenciacervantes.es', 'www.residenciacervantes.es', 'Residencia',
 40, 150, 40.00,
 'WiFi, Pensión completa, Biblioteca, Salas de estudio, Gimnasio',
 'Residencia universitaria que acepta grupos durante vacaciones. Excelentes instalaciones.',
 1, GETDATE(), 40.9651, -5.6640),

(5, 'Hotel Costa Blanca', 'Paseo Marítimo 45', 'Alicante', '03001', 'Alicante',
 '965778899', 'reservas@hotelcostablanca.com', 'www.hotelcostablanca.com', 'Hotel',
 60, 150, 85.00,
 'WiFi, Pensión completa, Piscina, Playa cercana, Aire acondicionado',
 'Hotel con vistas al mar. Ideal para actividades acuáticas y excursiones culturales.',
 1, GETDATE(), 38.3452, -0.4810),

(6, 'Camping El Bosque', 'Carretera Nacional km 45', 'Segovia', '40001', 'Segovia',
 '921334455', 'info@campingelbosque.es', 'www.campingelbosque.es', 'Camping',
 0, 200, 25.00,
 'WiFi, Bungalows, Zona de acampada, Barbacoas, Actividades naturaleza',
 'Camping familiar con bungalows. Perfecto para actividades de naturaleza y aventura.',
 1, GETDATE(), 40.9429, -4.1088),

(7, 'Hotel Las Palmeras', 'Avenida del Sol 78', 'Sevilla', '41013', 'Sevilla',
 '954667788', 'info@hotellaspalmeras.com', 'www.hotellaspalmeras.com', 'Hotel',
 45, 110, 70.00,
 'WiFi, Media pensión, Piscina, Parking, Aire acondicionado',
 'Hotel moderno cerca del centro histórico. Facilita visitas guiadas.',
 1, GETDATE(), 37.3886, -5.9823),

(8, 'Albergue Rural El Refugio', 'Camino del Monte 12', 'Granada', '18001', 'Granada',
 '958889900', 'contacto@albergueelrefugio.es', 'www.albergueelrefugio.es', 'Albergue',
 25, 100, 38.00,
 'WiFi, Pensión completa, Senderismo, Observación astronómica',
 'Albergue rural con actividades de montaña. Entorno natural privilegiado.',
 1, GETDATE(), 37.1773, -3.5986),

(9, 'Hotel Vista Mar', 'Paseo de la Concha 23', 'San Sebastián', '20001', 'Guipúzcoa',
 '943112233', 'reservas@hotelvistamar.com', 'www.hotelvistamar.com', 'Hotel',
 55, 130, 95.00,
 'WiFi, Pensión completa, Gimnasio, SPA, Vistas al mar',
 'Hotel de lujo frente a la playa de la Concha. Servicios premium para grupos.',
 1, GETDATE(), 43.3183, -1.9812),

(10, 'Hostal El Estudiante', 'Calle Universidad 34', 'Valencia', '46003', 'Valencia',
 '963445566', 'info@hostalelesestudiante.com', 'www.hostalelesestudiante.com', 'Hostal',
 28, 80, 50.00,
 'WiFi, Desayuno incluido, Cocina compartida, Zona común',
 'Hostal económico cerca de universidades y museos. Trato familiar.',
 1, GETDATE(), 39.4699, -0.3763);

SET IDENTITY_INSERT Alojamientos OFF;

-- Verificar los alojamientos insertados
SELECT Id, Nombre, Ciudad, PrecioPorNoche, Activo, TipoAlojamiento
FROM Alojamientos
ORDER BY Id;

-- Estadísticas
SELECT 
    TipoAlojamiento,
    COUNT(*) as Cantidad,
    AVG(PrecioPorNoche) as PrecioMedio,
    MIN(PrecioPorNoche) as PrecioMinimo,
    MAX(PrecioPorNoche) as PrecioMaximo
FROM Alojamientos
WHERE Activo = 1
GROUP BY TipoAlojamiento
ORDER BY Cantidad DESC;
