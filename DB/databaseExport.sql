-- MySQL dump 10.13  Distrib 8.0.36, for Win64 (x86_64)
--
-- Host: localhost    Database: proyecto
-- ------------------------------------------------------
-- Server version	8.4.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `actividades`
--

DROP TABLE IF EXISTS `actividades`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `actividades` (
  `id` int NOT NULL AUTO_INCREMENT,
  `titulo` text CHARACTER SET utf8mb3 COLLATE utf8mb3_spanish_ci NOT NULL,
  `tipo` enum('extraescolar','complementaria') CHARACTER SET utf8mb3 COLLATE utf8mb3_spanish_ci NOT NULL,
  `descripcion` text CHARACTER SET utf8mb3 COLLATE utf8mb3_spanish_ci,
  `fini` date NOT NULL,
  `ffin` date NOT NULL,
  `hini` time NOT NULL,
  `hfin` time NOT NULL,
  `prevista_ini` tinyint NOT NULL,
  `transporte_req` tinyint NOT NULL,
  `coment_transporte` text CHARACTER SET utf8mb3 COLLATE utf8mb3_spanish_ci,
  `alojamiento_req` tinyint NOT NULL,
  `coment_alojamiento` text CHARACTER SET utf8mb3 COLLATE utf8mb3_spanish_ci,
  `comentarios` text CHARACTER SET utf8mb3 COLLATE utf8mb3_spanish_ci,
  `estado` enum('SOLICITADA','DENEGADA','APROBADA','REALIZADA','REALIZANDOSE','CANCELADA') CHARACTER SET utf8mb3 COLLATE utf8mb3_spanish_ci NOT NULL,
  `coment_estado` text CHARACTER SET utf8mb3 COLLATE utf8mb3_spanish_ci,
  `incidencias` text CHARACTER SET utf8mb3 COLLATE utf8mb3_spanish_ci,
  `url_folleto` text CHARACTER SET utf8mb3 COLLATE utf8mb3_spanish_ci,
  `solicitante_id` char(36) CHARACTER SET utf8mb3 COLLATE utf8mb3_spanish_ci NOT NULL,
  `importe_por_alumno` decimal(5,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_actividades_profesores2_idx` (`solicitante_id`),
  CONSTRAINT `fk_actividades_profesores2` FOREIGN KEY (`solicitante_id`) REFERENCES `profesores` (`uuid`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `actividades`
--

LOCK TABLES `actividades` WRITE;
/*!40000 ALTER TABLE `actividades` DISABLE KEYS */;
INSERT INTO `actividades` VALUES (11,'Taller de reciclaje y sostenibilidad','complementaria','Sensibilización sobre la importancia del reciclaje y cuidado ambiental.','2024-10-15','2024-10-15','10:00:00','12:00:00',1,0,NULL,0,NULL,'Dirigido a alumnos de 1º ESO.','CANCELADA','El ponente no pudo asistir',NULL,NULL,'b837e307-bec1-11ef-a232-b00cd1e6ac21',0.00),(12,'Concurso de matemáticas recreativas','complementaria','Competición interna para resolver retos matemáticos divertidos.','2024-11-01','2024-11-01','10:00:00','12:30:00',1,0,NULL,0,NULL,'Fomenta habilidades de razonamiento lógico.','REALIZADA',NULL,NULL,NULL,'b83c3175-bec1-11ef-a232-b00cd1e6ac21',0.00),(13,'Jornada de lectura colectiva','complementaria','Lectura compartida y análisis de obras literarias en grupo.','2024-11-05','2024-11-05','11:00:00','13:00:00',1,0,NULL,0,NULL,'Enfocado a fomentar el interés por la literatura.','REALIZADA',NULL,NULL,NULL,'b83e61d8-bec1-11ef-a232-b00cd1e6ac21',0.00),(14,'Charla sobre salud mental en adolescentes','complementaria','Ponencia sobre la importancia del bienestar emocional.','2025-01-22','2025-01-22','10:00:00','11:30:00',1,0,NULL,0,NULL,'Actividad transversal para todos los cursos.','APROBADA',NULL,NULL,NULL,'b83e8264-bec1-11ef-a232-b00cd1e6ac21',0.00),(15,'Taller de escritura creativa','complementaria','Explorar técnicas de narrativa y redacción creativa.','2024-11-25','2024-11-25','09:30:00','11:30:00',1,0,NULL,0,NULL,'Fomentar habilidades de expresión escrita.','REALIZADA',NULL,NULL,NULL,'b83c120e-bec1-11ef-a232-b00cd1e6ac21',0.00),(16,'Torneo interno de ajedrez','complementaria','Competencia de ajedrez entre estudiantes.','2025-01-23','2025-01-23','10:00:00','12:30:00',1,0,NULL,0,NULL,'Promueve el pensamiento estratégico.','APROBADA',NULL,NULL,NULL,'b83c387c-bec1-11ef-a232-b00cd1e6ac21',0.00),(17,'Simulacro de emergencias','complementaria','Práctica de evacuación y manejo de emergencias.','2025-01-28','2025-01-28','09:00:00','10:30:00',1,0,NULL,0,NULL,'Actividad organizada por el equipo de seguridad del centro.','APROBADA',NULL,NULL,NULL,'b83e7855-bec1-11ef-a232-b00cd1e6ac21',0.00),(18,'Taller de astronomía básica','complementaria','Observación y comprensión de fenómenos astronómicos.','2025-02-03','2025-02-03','10:00:00','12:00:00',1,0,NULL,0,NULL,'Actividad relacionada con Ciencias Naturales.','APROBADA',NULL,NULL,NULL,'b83e8692-bec1-11ef-a232-b00cd1e6ac21',0.00),(19,'Jornada de experimentos científicos','complementaria','Realización de experimentos prácticos en el laboratorio.','2024-12-15','2024-12-15','09:30:00','12:00:00',1,0,NULL,0,NULL,'Fomenta la curiosidad por la ciencia.','REALIZADA',NULL,NULL,NULL,'b83c1e43-bec1-11ef-a232-b00cd1e6ac21',0.00),(20,'Competición interna de debate','complementaria','Debates estructurados sobre temas de actualidad.','2025-02-10','2025-02-10','10:00:00','12:00:00',1,0,NULL,0,NULL,'Desarrolla habilidades de comunicación y argumentación.','APROBADA',NULL,NULL,NULL,'b83c3fdc-bec1-11ef-a232-b00cd1e6ac21',0.00),(21,'Taller de Emprendimiento en Tecnologías','complementaria','Exploración de ideas para desarrollar proyectos tecnológicos innovadores en el ámbito del emprendimiento.','2024-11-10','2024-11-10','09:00:00','12:30:00',1,0,NULL,0,NULL,'Dirigido a estudiantes de ASIR y DAW para fomentar la iniciativa empresarial.Los alumnos participaron activamente.','REALIZADA','',NULL,NULL,'ae1908f3-bebf-11ef-a232-b00cd1e6ac21',0.00),(22,'Hackathon Interno de Desarrollo','complementaria','Resolución de problemas reales mediante el desarrollo de software en equipo.','2024-12-01','2024-12-01','09:00:00','17:00:00',1,0,NULL,0,NULL,'Competencia interna dirigida a alumnos de FP Superior.','REALIZADA','Los alumnos mostraron gran creatividad y trabajo en equipo.',NULL,NULL,'ae194248-bebf-11ef-a232-b00cd1e6ac21',0.00),(23,'Visita al Parque de la Naturaleza de Cabárceno','extraescolar','Actividad educativa para conocer la biodiversidad y los ecosistemas.','2024-10-20','2024-10-20','09:00:00','16:30:00',1,1,'Se usó un autobús contratado.',0,NULL,'Dirigido a estudiantes de ESO y FP.','REALIZADA','Se completó sin incidencias.',NULL,'https://parquedecabarceno.com','29e89408-bec2-11ef-a232-b00cd1e6ac21',8.50),(24,'Jornada cultural en Santander','extraescolar','Recorrido por lugares históricos y culturales emblemáticos de Santander.','2025-02-05','2025-02-05','09:30:00','15:30:00',1,1,NULL,0,NULL,'Actividad enfocada en la historia y el arte.','REALIZADA','El grupo mostró mucho interés.',NULL,NULL,'29e3f28e-bec2-11ef-a232-b00cd1e6ac21',4.00),(27,'Ruta en bicicleta por la Viesca','extraescolar','Recorrido en bicicleta por la Viesca para promover la actividad física.','2024-11-15','2024-11-15','16:00:00','18:30:00',1,0,NULL,0,NULL,'Dirigido a alumnos interesados en deportes y actividades al aire libre.','REALIZADA','Buena acogida por parte de los estudiantes.',NULL,NULL,'29e8b18e-bec2-11ef-a232-b00cd1e6ac21',0.00);
/*!40000 ALTER TABLE `actividades` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contratos`
--

DROP TABLE IF EXISTS `contratos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `contratos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `actividad_id` int NOT NULL,
  `emp_transporte_id` int NOT NULL,
  `contratada` tinyint NOT NULL,
  `importe` decimal(6,2) NOT NULL,
  `url_presupuesto` text CHARACTER SET utf8mb3 COLLATE utf8mb3_spanish_ci,
  `url_factura` text CHARACTER SET utf8mb3 COLLATE utf8mb3_spanish_ci,
  PRIMARY KEY (`id`),
  KEY `fk_actividades_has_emp_transporte_emp_transporte1_idx` (`emp_transporte_id`),
  KEY `fk_actividades_has_emp_transporte_actividades1_idx` (`actividad_id`),
  CONSTRAINT `fk_actividades_has_emp_transporte_actividades1` FOREIGN KEY (`actividad_id`) REFERENCES `actividades` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_actividades_has_emp_transporte_emp_transporte1` FOREIGN KEY (`emp_transporte_id`) REFERENCES `emp_transporte` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contratos`
--

LOCK TABLES `contratos` WRITE;
/*!40000 ALTER TABLE `contratos` DISABLE KEYS */;
INSERT INTO `contratos` VALUES (1,23,1,0,650.00,NULL,NULL),(2,23,2,1,620.00,NULL,NULL),(3,24,2,1,852.00,NULL,NULL);
/*!40000 ALTER TABLE `contratos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cursos`
--

DROP TABLE IF EXISTS `cursos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cursos` (
  `id_curso` int NOT NULL AUTO_INCREMENT,
  `cod_curso` char(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_spanish_ci NOT NULL,
  `titulo` text CHARACTER SET utf8mb3 COLLATE utf8mb3_spanish_ci NOT NULL,
  `etapa` enum('ESO','BACH','FPGS','FPGM','FPB','FPCE') CHARACTER SET utf8mb3 COLLATE utf8mb3_spanish_ci NOT NULL,
  `nivel` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_spanish_ci NOT NULL,
  `activo` tinyint NOT NULL,
  PRIMARY KEY (`id_curso`),
  UNIQUE KEY `cod_curso_UNIQUE` (`cod_curso`)
) ENGINE=InnoDB AUTO_INCREMENT=53 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cursos`
--

LOCK TABLES `cursos` WRITE;
/*!40000 ALTER TABLE `cursos` DISABLE KEYS */;
INSERT INTO `cursos` VALUES (1,'ESO1','1º de Educación Secundaria Obligatoria','ESO','1',1),(2,'ESO2','2º de Educación Secundaria Obligatoria','ESO','2',1),(3,'ESO3','3º de Educación Secundaria Obligatoria','ESO','3',1),(4,'ESO4','4º de Educación Secundaria Obligatoria','ESO','4',1),(5,'BACH1','1º de Bachillerato','BACH','1',1),(6,'BACH2','2º de Bachillerato','BACH','2',1),(7,'FPBIC1','1º FP Básica de Informática y Comunicaciones','FPB','1',0),(8,'FPBFM1','1º FP Básica de Fabricación Mecánica','FPB','1',1),(9,'FPBIC2','2º FP Básica de Informática y Comunicaciones','FPB','2',0),(10,'FPBFM2','2º FP Básica de Fabricación Mecánica','FPB','2',1),(11,'SMR1','1º FP Grado Medio de Sistemas Microinformáticos y Redes','FPGM','1',1),(12,'SMR2','2º FP Grado Medio de Sistemas Microinformáticos y Redes','FPGM','2',1),(13,'MEC1','1º FP Grado Medio de Mecanizado','FPGM','1',1),(14,'MEC2','2º FP Grado Medio de Mecanizado','FPGM','2',1),(15,'GAD1','1º FP Grado Medio de Gestión Administrativa','FPGM','1',1),(16,'GAD2','2º FP Grado Medio de Gestión Administrativa','FPGM','2',1),(17,'DAM1','1º FP Grado Superior de Desarrollo de Aplicaciones Multiplataforma','FPGS','1',1),(18,'DAM2','2º FP Grado Superior de Desarrollo de Aplicaciones Multiplataforma','FPGS','2',1),(19,'PPFM1','1º FP Grado Superior de Programación de la Producción en Fabricación Mecánica','FPGS','1',1),(20,'PPFM2','2º FP Grado Superior de Programación de la Producción en Fabricación Mecánica','FPGS','2',1),(21,'AYF1','1º FP Grado Superior de Administración y Finanzas','FPGS','1',1),(22,'AYF2','2º FP Grado Superior de Administración y Finanzas','FPGS','2',1),(23,'DPFM1','1º FP Grado Superior de Diseño en Fabricación Mecánica','FPGS','1',1),(24,'DPFM2','2º FP Grado Superior de Diseño en Fabricación Mecánica','FPGS','2',1),(25,'DAW1','1º FP Grado Superior de Desarrollo de Aplicaciones Web','FPGS','1',1),(26,'DAW2','2º FP Grado Superior de Desarrollo de Aplicaciones Web','FPGS','2',1),(27,'ASIR1','1º FP Grado Superior de Administración de Sistemas Informáticos en Red','FPGS','1',1),(28,'ASIR2','2º FP Grado Superior de Administración de Sistemas Informáticos en Red','FPGS','2',1);
/*!40000 ALTER TABLE `cursos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `departamentos`
--

DROP TABLE IF EXISTS `departamentos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `departamentos` (
  `id_depar` int NOT NULL AUTO_INCREMENT,
  `codigo` char(3) CHARACTER SET utf8mb3 COLLATE utf8mb3_spanish_ci NOT NULL,
  `nombre` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_spanish_ci NOT NULL,
  PRIMARY KEY (`id_depar`),
  UNIQUE KEY `id_depar_UNIQUE` (`id_depar`),
  UNIQUE KEY `codigo_UNIQUE` (`codigo`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `departamentos`
--

LOCK TABLES `departamentos` WRITE;
/*!40000 ALTER TABLE `departamentos` DISABLE KEYS */;
INSERT INTO `departamentos` VALUES (1,'INF','Informática'),(2,'ADM','Administración y Gestión'),(3,'FAB','Fabricación Mecánica'),(4,'MAT','Matemáticas'),(5,'LEN','Lengua y Literatura'),(6,'SOC','Ciencias Sociales'),(7,'FYQ','Física y Química'),(8,'EFI','Educación Física'),(9,'BIO','Biología y Geología'),(10,'ING','Inglés');
/*!40000 ALTER TABLE `departamentos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `emp_transporte`
--

DROP TABLE IF EXISTS `emp_transporte`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `emp_transporte` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(60) CHARACTER SET utf8mb3 COLLATE utf8mb3_spanish_ci NOT NULL,
  `cif` char(9) CHARACTER SET utf8mb3 COLLATE utf8mb3_spanish_ci NOT NULL,
  `direccion` text CHARACTER SET utf8mb3 COLLATE utf8mb3_spanish_ci,
  `cp` char(5) CHARACTER SET utf8mb3 COLLATE utf8mb3_spanish_ci DEFAULT NULL,
  `localidad` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_spanish_ci DEFAULT NULL,
  `contacto` text CHARACTER SET utf8mb3 COLLATE utf8mb3_spanish_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `cif_UNIQUE` (`cif`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `emp_transporte`
--

LOCK TABLES `emp_transporte` WRITE;
/*!40000 ALTER TABLE `emp_transporte` DISABLE KEYS */;
INSERT INTO `emp_transporte` VALUES (1,'GOCOTOUR','A12345678','Poligono de Navas, 38','39500','Cabezón de la Sal (Cantabria)','tlf: 942718760, 666400500   mail: info@gocotour.com'),(2,'ALTRANS','B23456789','Av. Cantabria, 8','39301','Campuzano (Cantabria)','tlf: 675675675 (Roberto)  mail: info@altrans.com');
/*!40000 ALTER TABLE `emp_transporte` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fotos`
--

DROP TABLE IF EXISTS `fotos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fotos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `url_foto` text CHARACTER SET utf8mb3 COLLATE utf8mb3_spanish_ci NOT NULL,
  `descripcion` text CHARACTER SET utf8mb3 COLLATE utf8mb3_spanish_ci NOT NULL,
  `actividad_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_fotos_actividades1_idx` (`actividad_id`),
  CONSTRAINT `fk_fotos_actividades1` FOREIGN KEY (`actividad_id`) REFERENCES `actividades` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fotos`
--

LOCK TABLES `fotos` WRITE;
/*!40000 ALTER TABLE `fotos` DISABLE KEYS */;
/*!40000 ALTER TABLE `fotos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `grupos`
--

DROP TABLE IF EXISTS `grupos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `grupos` (
  `id_grupo` int NOT NULL AUTO_INCREMENT,
  `curso_id` int NOT NULL,
  `cod_grupo` char(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_spanish_ci NOT NULL,
  `num_alumnos` int NOT NULL,
  `activo` tinyint NOT NULL,
  `tutor_id` char(36) CHARACTER SET utf8mb3 COLLATE utf8mb3_spanish_ci NOT NULL,
  PRIMARY KEY (`id_grupo`),
  UNIQUE KEY `cod_curso_UNIQUE` (`cod_grupo`),
  KEY `fk_grupos_cursos1_idx` (`curso_id`),
  KEY `fk_grupos_profesores1_idx` (`tutor_id`),
  CONSTRAINT `fk_grupos_cursos1` FOREIGN KEY (`curso_id`) REFERENCES `cursos` (`id_curso`) ON UPDATE CASCADE,
  CONSTRAINT `fk_grupos_profesores1` FOREIGN KEY (`tutor_id`) REFERENCES `profesores` (`uuid`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `grupos`
--

LOCK TABLES `grupos` WRITE;
/*!40000 ALTER TABLE `grupos` DISABLE KEYS */;
INSERT INTO `grupos` VALUES (1,17,'DAM1',23,1,'ae194f4d-bebf-11ef-a232-b00cd1e6ac21'),(2,18,'DAM2',20,1,'ae195e7a-bebf-11ef-a232-b00cd1e6ac21'),(3,8,'FPBFM1',15,1,'1c8a4e9a-bec0-11ef-a232-b00cd1e6ac21'),(4,10,'FPBFM2',8,1,'1c8b192d-bec0-11ef-a232-b00cd1e6ac21'),(5,13,'MEC1',22,1,'1c8b1dea-bec0-11ef-a232-b00cd1e6ac21'),(6,14,'MEC2',19,1,'1c8b218f-bec0-11ef-a232-b00cd1e6ac21'),(7,19,'PPFM1',18,1,'1c8b247a-bec0-11ef-a232-b00cd1e6ac21'),(8,20,'PPFM2',17,1,'1c8b2a22-bec0-11ef-a232-b00cd1e6ac21'),(9,11,'SMR1',20,1,'ae1946ac-bebf-11ef-a232-b00cd1e6ac21'),(10,12,'SMR2',18,1,'ae194b72-bebf-11ef-a232-b00cd1e6ac21'),(11,7,'FPBIC1',15,0,'ae1908f3-bebf-11ef-a232-b00cd1e6ac21'),(12,9,'FPBIC2',9,0,'ae194248-bebf-11ef-a232-b00cd1e6ac21'),(13,21,'AYF1',25,1,'7b79f5e4-bec0-11ef-a232-b00cd1e6ac21'),(14,22,'AYF2',23,1,'7b79fa2a-bec0-11ef-a232-b00cd1e6ac21'),(15,4,'ESO4A',20,1,'b83e8264-bec1-11ef-a232-b00cd1e6ac21'),(16,4,'ESO4B',18,1,'b83e8692-bec1-11ef-a232-b00cd1e6ac21'),(17,4,'ESO4C',19,1,'b83e8a07-bec1-11ef-a232-b00cd1e6ac21'),(18,1,'ESO1A',21,1,'b837e307-bec1-11ef-a232-b00cd1e6ac21'),(19,1,'ESO1B',19,1,'b83c120e-bec1-11ef-a232-b00cd1e6ac21'),(20,1,'ESO1C',18,1,'b83c1e43-bec1-11ef-a232-b00cd1e6ac21'),(21,2,'ESO2A',20,1,'b83c3175-bec1-11ef-a232-b00cd1e6ac21'),(22,2,'ESO2B',21,1,'b83c387c-bec1-11ef-a232-b00cd1e6ac21'),(23,2,'ESO2C',21,1,'b83c3fdc-bec1-11ef-a232-b00cd1e6ac21'),(24,3,'ESO3A',19,1,'b83e61d8-bec1-11ef-a232-b00cd1e6ac21'),(25,3,'ESO3B',20,1,'b83e7855-bec1-11ef-a232-b00cd1e6ac21'),(26,3,'ESO3C',20,1,'b83e7e7e-bec1-11ef-a232-b00cd1e6ac21'),(27,5,'BACH1CT',22,1,'b837e307-bec1-11ef-a232-b00cd1e6ac21'),(28,5,'BACH1HS',16,1,'b83c120e-bec1-11ef-a232-b00cd1e6ac21'),(29,6,'BACH2CT',21,1,'b83c1e43-bec1-11ef-a232-b00cd1e6ac21'),(30,6,'BACH2HS',16,1,'b83c3175-bec1-11ef-a232-b00cd1e6ac21'),(31,15,'GAD1',25,1,'7b79f5e4-bec0-11ef-a232-b00cd1e6ac21'),(32,16,'GAD2',20,1,'7b79fa2a-bec0-11ef-a232-b00cd1e6ac21'),(33,27,'ASIR1A',23,1,'ae1962bb-bebf-11ef-a232-b00cd1e6ac21'),(34,28,'ASIR2A',20,1,'ae196681-bebf-11ef-a232-b00cd1e6ac21'),(35,25,'DAW1A',22,1,'ae1969a6-bebf-11ef-a232-b00cd1e6ac21'),(36,26,'DAW2A',19,1,'ae196bf5-bebf-11ef-a232-b00cd1e6ac21');
/*!40000 ALTER TABLE `grupos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `grupos_participantes`
--

DROP TABLE IF EXISTS `grupos_participantes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `grupos_participantes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `actividades_id` int NOT NULL,
  `grupo_id` int NOT NULL,
  `num_participantes` int NOT NULL DEFAULT '0',
  `comentario` text CHARACTER SET utf8mb3 COLLATE utf8mb3_spanish_ci,
  PRIMARY KEY (`id`),
  KEY `fk_actividades_has_grupos_grupos1_idx` (`grupo_id`),
  KEY `fk_actividades_has_grupos_actividades1_idx` (`actividades_id`),
  CONSTRAINT `fk_actividades_has_grupos_actividades1` FOREIGN KEY (`actividades_id`) REFERENCES `actividades` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_actividades_has_grupos_grupos1` FOREIGN KEY (`grupo_id`) REFERENCES `grupos` (`id_grupo`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=79 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `grupos_participantes`
--

LOCK TABLES `grupos_participantes` WRITE;
/*!40000 ALTER TABLE `grupos_participantes` DISABLE KEYS */;
INSERT INTO `grupos_participantes` VALUES (16,21,11,15,NULL),(18,22,12,9,NULL),(20,14,15,20,NULL),(23,23,15,20,NULL),(24,18,16,18,NULL),(27,23,16,18,NULL),(29,23,17,19,NULL),(30,27,18,21,NULL),(32,15,19,19,NULL),(33,27,19,19,NULL),(36,19,20,18,NULL),(37,27,20,18,NULL),(40,12,20,18,NULL),(41,12,21,20,NULL),(44,24,21,20,NULL),(45,16,22,21,NULL),(47,20,23,21,NULL),(49,13,24,19,NULL),(51,17,25,20,NULL),(53,27,27,22,NULL),(56,27,28,16,NULL),(57,15,28,16,NULL),(59,19,29,21,NULL),(60,27,29,21,NULL),(63,12,29,21,NULL),(64,12,30,16,NULL),(67,24,30,16,NULL);
/*!40000 ALTER TABLE `grupos_participantes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `localizaciones`
--

DROP TABLE IF EXISTS `localizaciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `localizaciones` (
  `id` int NOT NULL AUTO_INCREMENT,
  `id_Actividad` int NOT NULL,
  `latitud` int NOT NULL,
  `longitud` int NOT NULL,
  `comentario` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idActividad_idx` (`id_Actividad`),
  CONSTRAINT `idActividad` FOREIGN KEY (`id_Actividad`) REFERENCES `actividades` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `localizaciones`
--

LOCK TABLES `localizaciones` WRITE;
/*!40000 ALTER TABLE `localizaciones` DISABLE KEYS */;
/*!40000 ALTER TABLE `localizaciones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prof_participantes`
--

DROP TABLE IF EXISTS `prof_participantes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `prof_participantes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `actividad_id` int NOT NULL,
  `profesor_id` char(36) CHARACTER SET utf8mb3 COLLATE utf8mb3_spanish_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_actividades_has_profesores_profesores1_idx` (`profesor_id`),
  KEY `fk_actividades_has_profesores_actividades1_idx` (`actividad_id`),
  CONSTRAINT `fk_actividades_has_profesores_actividades1` FOREIGN KEY (`actividad_id`) REFERENCES `actividades` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_actividades_has_profesores_profesores1` FOREIGN KEY (`profesor_id`) REFERENCES `profesores` (`uuid`)
) ENGINE=InnoDB AUTO_INCREMENT=85 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prof_participantes`
--

LOCK TABLES `prof_participantes` WRITE;
/*!40000 ALTER TABLE `prof_participantes` DISABLE KEYS */;
INSERT INTO `prof_participantes` VALUES (1,24,'29e3f28e-bec2-11ef-a232-b00cd1e6ac21'),(2,23,'29e89408-bec2-11ef-a232-b00cd1e6ac21'),(3,27,'29e8b18e-bec2-11ef-a232-b00cd1e6ac21'),(7,15,'b83c120e-bec1-11ef-a232-b00cd1e6ac21'),(9,12,'b83c3175-bec1-11ef-a232-b00cd1e6ac21'),(10,16,'b83c387c-bec1-11ef-a232-b00cd1e6ac21'),(12,13,'b83e61d8-bec1-11ef-a232-b00cd1e6ac21'),(14,14,'b83e8264-bec1-11ef-a232-b00cd1e6ac21'),(16,23,'b83e8264-bec1-11ef-a232-b00cd1e6ac21'),(17,23,'b83e8692-bec1-11ef-a232-b00cd1e6ac21'),(18,23,'b83e8a07-bec1-11ef-a232-b00cd1e6ac21'),(29,17,'b83e7855-bec1-11ef-a232-b00cd1e6ac21'),(30,18,'b83e8692-bec1-11ef-a232-b00cd1e6ac21'),(31,19,'b83c1e43-bec1-11ef-a232-b00cd1e6ac21'),(32,20,'b83c3fdc-bec1-11ef-a232-b00cd1e6ac21'),(33,21,'ae1908f3-bebf-11ef-a232-b00cd1e6ac21'),(34,22,'ae194248-bebf-11ef-a232-b00cd1e6ac21'),(41,24,'b83c3175-bec1-11ef-a232-b00cd1e6ac21'),(42,27,'b837e307-bec1-11ef-a232-b00cd1e6ac21'),(43,27,'b83c120e-bec1-11ef-a232-b00cd1e6ac21'),(44,27,'b83c1e43-bec1-11ef-a232-b00cd1e6ac21'),(49,12,'b83c1e43-bec1-11ef-a232-b00cd1e6ac21'),(54,12,'b83c387c-bec1-11ef-a232-b00cd1e6ac21'),(55,13,'b83c387c-bec1-11ef-a232-b00cd1e6ac21'),(56,14,'b83c387c-bec1-11ef-a232-b00cd1e6ac21'),(58,12,'b8403dd3-bec1-11ef-a232-b00cd1e6ac21'),(59,13,'b8403dd3-bec1-11ef-a232-b00cd1e6ac21'),(60,14,'b8403dd3-bec1-11ef-a232-b00cd1e6ac21'),(62,12,'29e89408-bec2-11ef-a232-b00cd1e6ac21'),(63,13,'29e89408-bec2-11ef-a232-b00cd1e6ac21'),(64,14,'29e89408-bec2-11ef-a232-b00cd1e6ac21'),(66,12,'b83e8692-bec1-11ef-a232-b00cd1e6ac21'),(67,13,'b83e8692-bec1-11ef-a232-b00cd1e6ac21'),(68,14,'b83e8692-bec1-11ef-a232-b00cd1e6ac21'),(70,12,'b83e8264-bec1-11ef-a232-b00cd1e6ac21'),(71,13,'b83e8264-bec1-11ef-a232-b00cd1e6ac21'),(72,14,'b83e8264-bec1-11ef-a232-b00cd1e6ac21'),(74,12,'7b79fd9f-bec0-11ef-a232-b00cd1e6ac21'),(75,13,'7b79fd9f-bec0-11ef-a232-b00cd1e6ac21'),(76,14,'7b79fd9f-bec0-11ef-a232-b00cd1e6ac21'),(78,12,'ae1908f3-bebf-11ef-a232-b00cd1e6ac21'),(79,13,'ae1908f3-bebf-11ef-a232-b00cd1e6ac21'),(80,14,'ae1908f3-bebf-11ef-a232-b00cd1e6ac21'),(82,12,'ae1946ac-bebf-11ef-a232-b00cd1e6ac21'),(83,13,'ae1946ac-bebf-11ef-a232-b00cd1e6ac21'),(84,14,'ae1946ac-bebf-11ef-a232-b00cd1e6ac21');
/*!40000 ALTER TABLE `prof_participantes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prof_responsables`
--

DROP TABLE IF EXISTS `prof_responsables`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `prof_responsables` (
  `id` int NOT NULL AUTO_INCREMENT,
  `actividad_id` int NOT NULL,
  `profesor_id` char(36) CHARACTER SET utf8mb3 COLLATE utf8mb3_spanish_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_actividades_has_profesores_profesores1_idx` (`profesor_id`),
  KEY `fk_actividades_has_profesores_actividades1_idx` (`actividad_id`),
  CONSTRAINT `fk_actividades_has_profesores_actividades10` FOREIGN KEY (`actividad_id`) REFERENCES `actividades` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_actividades_has_profesores_profesores10` FOREIGN KEY (`profesor_id`) REFERENCES `profesores` (`uuid`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prof_responsables`
--

LOCK TABLES `prof_responsables` WRITE;
/*!40000 ALTER TABLE `prof_responsables` DISABLE KEYS */;
INSERT INTO `prof_responsables` VALUES (1,24,'29e3f28e-bec2-11ef-a232-b00cd1e6ac21'),(2,23,'29e89408-bec2-11ef-a232-b00cd1e6ac21'),(3,27,'29e8b18e-bec2-11ef-a232-b00cd1e6ac21'),(4,21,'ae1908f3-bebf-11ef-a232-b00cd1e6ac21'),(5,22,'ae194248-bebf-11ef-a232-b00cd1e6ac21'),(7,15,'b83c120e-bec1-11ef-a232-b00cd1e6ac21'),(8,19,'b83c1e43-bec1-11ef-a232-b00cd1e6ac21'),(9,12,'b83c3175-bec1-11ef-a232-b00cd1e6ac21'),(10,16,'b83c387c-bec1-11ef-a232-b00cd1e6ac21'),(11,20,'b83c3fdc-bec1-11ef-a232-b00cd1e6ac21'),(12,13,'b83e61d8-bec1-11ef-a232-b00cd1e6ac21'),(13,17,'b83e7855-bec1-11ef-a232-b00cd1e6ac21'),(14,14,'b83e8264-bec1-11ef-a232-b00cd1e6ac21'),(15,18,'b83e8692-bec1-11ef-a232-b00cd1e6ac21'),(16,23,'b83e8264-bec1-11ef-a232-b00cd1e6ac21'),(17,23,'b83e8692-bec1-11ef-a232-b00cd1e6ac21'),(18,23,'b83e8a07-bec1-11ef-a232-b00cd1e6ac21'),(19,24,'b83c3175-bec1-11ef-a232-b00cd1e6ac21'),(20,27,'b837e307-bec1-11ef-a232-b00cd1e6ac21'),(21,27,'b83c120e-bec1-11ef-a232-b00cd1e6ac21'),(22,27,'b83c1e43-bec1-11ef-a232-b00cd1e6ac21'),(24,12,'b83c3175-bec1-11ef-a232-b00cd1e6ac21'),(25,13,'b83e61d8-bec1-11ef-a232-b00cd1e6ac21'),(26,14,'b83e8264-bec1-11ef-a232-b00cd1e6ac21'),(27,15,'b83c120e-bec1-11ef-a232-b00cd1e6ac21'),(28,16,'b83c387c-bec1-11ef-a232-b00cd1e6ac21'),(29,17,'b83e7855-bec1-11ef-a232-b00cd1e6ac21'),(30,18,'b83e8692-bec1-11ef-a232-b00cd1e6ac21'),(31,19,'b83c1e43-bec1-11ef-a232-b00cd1e6ac21'),(32,20,'b83c3fdc-bec1-11ef-a232-b00cd1e6ac21'),(33,21,'ae1908f3-bebf-11ef-a232-b00cd1e6ac21'),(34,22,'ae194248-bebf-11ef-a232-b00cd1e6ac21'),(38,23,'b83e8264-bec1-11ef-a232-b00cd1e6ac21'),(39,23,'b83e8692-bec1-11ef-a232-b00cd1e6ac21'),(40,23,'b83e8a07-bec1-11ef-a232-b00cd1e6ac21'),(41,24,'b83c3175-bec1-11ef-a232-b00cd1e6ac21'),(42,27,'b837e307-bec1-11ef-a232-b00cd1e6ac21'),(43,27,'b83c120e-bec1-11ef-a232-b00cd1e6ac21'),(44,27,'b83c1e43-bec1-11ef-a232-b00cd1e6ac21'),(49,12,'b83c1e43-bec1-11ef-a232-b00cd1e6ac21');
/*!40000 ALTER TABLE `prof_responsables` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `profesores`
--

DROP TABLE IF EXISTS `profesores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `profesores` (
  `uuid` char(36) CHARACTER SET utf8mb3 COLLATE utf8mb3_spanish_ci NOT NULL,
  `dni` char(9) CHARACTER SET utf8mb3 COLLATE utf8mb3_spanish_ci NOT NULL,
  `nombre` varchar(25) CHARACTER SET utf8mb3 COLLATE utf8mb3_spanish_ci NOT NULL,
  `apellidos` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_spanish_ci NOT NULL,
  `correo` text CHARACTER SET utf8mb3 COLLATE utf8mb3_spanish_ci NOT NULL,
  `password` char(64) COLLATE utf8mb3_spanish_ci NOT NULL,
  `rol` enum('ADM','ED','PROF') CHARACTER SET utf8mb3 COLLATE utf8mb3_spanish_ci NOT NULL DEFAULT 'PROF',
  `activo` tinyint NOT NULL DEFAULT '1',
  `url_foto` text CHARACTER SET utf8mb3 COLLATE utf8mb3_spanish_ci,
  `es_jefe_dep` tinyint DEFAULT '0',
  `depart_id` int NOT NULL,
  PRIMARY KEY (`uuid`),
  UNIQUE KEY `dni_UNIQUE` (`dni`),
  UNIQUE KEY `correo_UNIQUE` (`correo`(50)),
  KEY `FK_departamento_profesor_idx` (`depart_id`),
  CONSTRAINT `FK_departamento_profesor` FOREIGN KEY (`depart_id`) REFERENCES `departamentos` (`id_depar`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `profesores`
--

LOCK TABLES `profesores` WRITE;
/*!40000 ALTER TABLE `profesores` DISABLE KEYS */;
INSERT INTO `profesores` VALUES ('1c8a4e9a-bec0-11ef-a232-b00cd1e6ac21','56384920H','Alicia','Fernández del Río','alicia.fernandez@educantabria.es','$2y$10$wTxRvp7w2TVwzGCl3tu4WusvfcTIRGcx6SdskUOuikG6J96WSaj7K','PROF',1,NULL,1,3),('1c8b192d-bec0-11ef-a232-b00cd1e6ac21','48276139J','Laura','Ruiz Altamira','laura.ruiz@educantabria.es','81dc9bdb52d04dc20036dbd8313ed055','ADM',1,NULL,0,3),('1c8b1dea-bec0-11ef-a232-b00cd1e6ac21','76392841L','Andrés','Santos Cabrera','andres.santos@educantabria.es','81dc9bdb52d04dc20036dbd8313ed055','PROF',1,NULL,0,3),('1c8b218f-bec0-11ef-a232-b00cd1e6ac21','89317654K','Gustavo','López Ocaña','gustavo.lopez@educantabria.es','81dc9bdb52d04dc20036dbd8313ed055','PROF',1,NULL,0,3),('1c8b247a-bec0-11ef-a232-b00cd1e6ac21','73982146T','Javier','Martín Torquemada','javier.martin@educantabria.es','81dc9bdb52d04dc20036dbd8313ed055','PROF',1,NULL,0,3),('1c8b2a22-bec0-11ef-a232-b00cd1e6ac21','59218347P','Marta','Revuelta Requena','marta.revuelta@educantabria.es','81dc9bdb52d04dc20036dbd8313ed055','PROF',1,NULL,0,3),('29e3f28e-bec2-11ef-a232-b00cd1e6ac21','12345678C','Alejandro','Fernández Ruiz','alejandro.fernandez.ruiz@educantabria.es','81dc9bdb52d04dc20036dbd8313ed055','PROF',1,NULL,1,6),('29e4a813-bec2-11ef-a232-b00cd1e6ac21','23456789D','Ana','López García','ana.lopez.garcia@educantabria.es','81dc9bdb52d04dc20036dbd8313ed055','PROF',1,NULL,0,6),('29e4abde-bec2-11ef-a232-b00cd1e6ac21','34567890E','Jorge','Santos del Campo','jorge.santos@educantabria.es','81dc9bdb52d04dc20036dbd8313ed055','PROF',1,NULL,0,6),('29e6951c-bec2-11ef-a232-b00cd1e6ac21','45678901F','Lucía','Gómez López','lucia.gomez@educantabria.es','81dc9bdb52d04dc20036dbd8313ed055','PROF',1,NULL,1,7),('29e6abd3-bec2-11ef-a232-b00cd1e6ac21','56789012G','Pedro','Martínez Quintana','pedro.martinez@educantabria.es','81dc9bdb52d04dc20036dbd8313ed055','PROF',1,NULL,0,7),('29e6af23-bec2-11ef-a232-b00cd1e6ac21','67890123H','Yenifer','Hernández Salazar','yenifer.hernandez@educantabria.es','81dc9bdb52d04dc20036dbd8313ed055','PROF',1,NULL,0,7),('29e89408-bec2-11ef-a232-b00cd1e6ac21','78901234I','Raquel','Herrera Santiañez','raquel.herrera@educantabria.es','81dc9bdb52d04dc20036dbd8313ed055','PROF',1,NULL,1,9),('29e8ac24-bec2-11ef-a232-b00cd1e6ac21','89012345J','Henar','Rodríguez del Río','henar.rodriguez@educantabria.es','81dc9bdb52d04dc20036dbd8313ed055','PROF',1,NULL,0,9),('29e8b18e-bec2-11ef-a232-b00cd1e6ac21','90123456K','Beatriz','Jiménez López','beatriz.jimenez.bio@educantabria.es','81dc9bdb52d04dc20036dbd8313ed055','PROF',1,NULL,0,8),('7b7932e6-bec0-11ef-a232-b00cd1e6ac21','74829365M','Diego','Rodríguez de la Fuente','diego.rodriguez@educantabria.es','81dc9bdb52d04dc20036dbd8313ed055','PROF',1,NULL,1,2),('7b79efaa-bec0-11ef-a232-b00cd1e6ac21','84291537K','Sofía','Fernández Esquivel','sofia.fernandez@educantabria.es','81dc9bdb52d04dc20036dbd8313ed055','ED',1,NULL,0,2),('7b79f5e4-bec0-11ef-a232-b00cd1e6ac21','83946172T','Hugo','López Valverde','hugo.lopez@educantabria.es','81dc9bdb52d04dc20036dbd8313ed055','PROF',1,NULL,0,2),('7b79fa2a-bec0-11ef-a232-b00cd1e6ac21','73628495P','Rogelio','Díaz Ceballos','rogelio.diaz@educantabria.es','81dc9bdb52d04dc20036dbd8313ed055','PROF',1,NULL,0,2),('7b79fd9f-bec0-11ef-a232-b00cd1e6ac21','91284763R','Raúl','Martínez del Castillo','raul.martinez@educantabria.es','81dc9bdb52d04dc20036dbd8313ed055','PROF',1,NULL,0,2),('7b7a014c-bec0-11ef-a232-b00cd1e6ac21','64738291L','Rebeca','Jiménez de Alba','rebeca.jimenez@educantabria.es','81dc9bdb52d04dc20036dbd8313ed055','PROF',1,NULL,0,2),('ae1908f3-bebf-11ef-a232-b00cd1e6ac21','91483756L','Juan Diego','Gómez del Campo','juandiego.gomez@educantabria.es','81dc9bdb52d04dc20036dbd8313ed055','PROF',1,NULL,1,1),('ae194248-bebf-11ef-a232-b00cd1e6ac21','68294357M','Ana','Martínez de la Vega','ana.martinez@educantabria.es','81dc9bdb52d04dc20036dbd8313ed055','PROF',1,NULL,0,1),('ae1946ac-bebf-11ef-a232-b00cd1e6ac21','72849562Z','Luis','de Diego Torrijos','luis.dediego@educantabria.es','81dc9bdb52d04dc20036dbd8313ed055','PROF',1,NULL,0,1),('ae194b72-bebf-11ef-a232-b00cd1e6ac21','83920458K','Mónica','Herrero Bermejo','monica.herrero@educantabria.es','81dc9bdb52d04dc20036dbd8313ed055','PROF',1,NULL,0,1),('ae194f4d-bebf-11ef-a232-b00cd1e6ac21','91746385B','José Luis','López Valdeón','joseluis.lopez@educantabria.es','81dc9bdb52d04dc20036dbd8313ed055','PROF',1,NULL,0,1),('ae195e7a-bebf-11ef-a232-b00cd1e6ac21','12837465V','Verónica','Díaz Figueroa','veronica.diaz@educantabria.es','81dc9bdb52d04dc20036dbd8313ed055','PROF',1,NULL,0,1),('ae1962bb-bebf-11ef-a232-b00cd1e6ac21','45673921C','Miguel','Rodríguez Cepeda','miguel.rodriguez@educantabria.es','81dc9bdb52d04dc20036dbd8313ed055','PROF',1,NULL,0,1),('ae196681-bebf-11ef-a232-b00cd1e6ac21','67948302T','Elena','Pérez del Valle','elena.perez@educantabria.es','81dc9bdb52d04dc20036dbd8313ed055','PROF',1,NULL,0,1),('ae1969a6-bebf-11ef-a232-b00cd1e6ac21','54829137J','Pablo','García Quintanilla','pablo.garcia@educantabria.es','81dc9bdb52d04dc20036dbd8313ed055','PROF',1,NULL,0,1),('ae196bf5-bebf-11ef-a232-b00cd1e6ac21','93718564R','Ignacio','Jiménez de la Torre','ignacio.jimenez@educantabria.es','81dc9bdb52d04dc20036dbd8313ed055','ED',1,NULL,0,1),('b837e307-bec1-11ef-a232-b00cd1e6ac21','23456789A','Lara','Velasco Gómez','lara.velasco@educantabria.es','81dc9bdb52d04dc20036dbd8313ed055','PROF',1,NULL,1,4),('b83c120e-bec1-11ef-a232-b00cd1e6ac21','34567890B','Luis','Martínez de la Fuente','luis.martinez@educantabria.es','81dc9bdb52d04dc20036dbd8313ed055','ADM',1,NULL,0,4),('b83c1e43-bec1-11ef-a232-b00cd1e6ac21','45678901C','Carmen','Díaz Pérez','carmen.diaz.math@educantabria.es','81dc9bdb52d04dc20036dbd8313ed055','PROF',1,NULL,0,4),('b83c3175-bec1-11ef-a232-b00cd1e6ac21','56789012D','Jimena','Rodríguez López','jimena.rodriguez@educantabria.es','81dc9bdb52d04dc20036dbd8313ed055','PROF',1,NULL,0,4),('b83c387c-bec1-11ef-a232-b00cd1e6ac21','67890123E','Laura','Gómez Ceballos','laura.gomez@educantabria.es','81dc9bdb52d04dc20036dbd8313ed055','PROF',1,NULL,0,4),('b83c3fdc-bec1-11ef-a232-b00cd1e6ac21','78901234F','Pedro','Santos Fernández','pedro.santos@educantabria.es','81dc9bdb52d04dc20036dbd8313ed055','PROF',1,NULL,0,4),('b83e61d8-bec1-11ef-a232-b00cd1e6ac21','89012345G','Raquel','Vitienes Gil','raquel.vitienes@educantabria.es','81dc9bdb52d04dc20036dbd8313ed055','PROF',1,NULL,1,5),('b83e7855-bec1-11ef-a232-b00cd1e6ac21','90123456H','Isabel','Hernández Quintana','isabel.hernandez.@educantabria.es','81dc9bdb52d04dc20036dbd8313ed055','ED',1,NULL,0,5),('b83e7e7e-bec1-11ef-a232-b00cd1e6ac21','01234567I','Miguel','Retegui del Valle','miguel.retegui@educantabria.es','81dc9bdb52d04dc20036dbd8313ed055','ED',1,NULL,0,5),('b83e8264-bec1-11ef-a232-b00cd1e6ac21','12345678J','Elena','García López','elena.garcia@educantabria.es','81dc9bdb52d04dc20036dbd8313ed055','PROF',1,NULL,0,5),('b83e8692-bec1-11ef-a232-b00cd1e6ac21','23456789K','Carlos','Jiménez Salazar','carlos.jimenez@educantabria.es','81dc9bdb52d04dc20036dbd8313ed055','PROF',1,NULL,0,5),('b83e8a07-bec1-11ef-a232-b00cd1e6ac21','34567890L','María','Torres Moreno','maria.torres@educantabria.es','81dc9bdb52d04dc20036dbd8313ed055','PROF',1,NULL,0,5),('b8400b2f-bec1-11ef-a232-b00cd1e6ac21','45678901M','Sergio','Martín López','sergio.martin.english@educantabria.es','81dc9bdb52d04dc20036dbd8313ed055','PROF',1,NULL,1,10),('b840247b-bec1-11ef-a232-b00cd1e6ac21','56789012N','Beatriz','Ortiz Serrano','beatriz.ortiz.serrano@educantabria.es','81dc9bdb52d04dc20036dbd8313ed055','ADM',1,NULL,0,10),('b8402acd-bec1-11ef-a232-b00cd1e6ac21','67890123O','Fernando','Gómez Quintana','fernando.gomez@educantabria.es','81dc9bdb52d04dc20036dbd8313ed055','PROF',1,NULL,0,10),('b84031b5-bec1-11ef-a232-b00cd1e6ac21','78901234P','Lucía','Zubizarreta Santos','lucia.zubizarreta@educantabria.es','81dc9bdb52d04dc20036dbd8313ed055','PROF',1,NULL,0,10),('b8403a72-bec1-11ef-a232-b00cd1e6ac21','89012345Q','David','Ruiz Gil','david.ruiz.gil@educantabria.es','81dc9bdb52d04dc20036dbd8313ed055','PROF',1,NULL,0,10),('b8403dd3-bec1-11ef-a232-b00cd1e6ac21','90123456R','Lorenzo','Santos del Campo','lorenzo.santos@educantabria.es','81dc9bdb52d04dc20036dbd8313ed055','PROF',1,NULL,0,10);
/*!40000 ALTER TABLE `profesores` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'proyecto'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-01-23 19:15:21
