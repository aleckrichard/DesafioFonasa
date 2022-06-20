-- Adminer 4.8.1 MySQL 8.0.29 dump

SET NAMES utf8;
SET time_zone = '+00:00';
SET foreign_key_checks = 0;
SET sql_mode = 'NO_AUTO_VALUE_ON_ZERO';

DELIMITER ;;

DROP PROCEDURE IF EXISTS `atenderPacientes`;;
CREATE PROCEDURE `atenderPacientes`(IN `id` int, IN `run` int)
BEGIN
DECLARE idConsulta INT;

   SET idConsulta = (SELECT idTipoConsulta FROM consultas WHERE runEspecialista = run);

CASE
WHEN idConsulta = 1 THEN 
SELECT numeroHistoriaClinicaPaciente, runPaciente, nombrePaciente, prioridad, nombreEspecialista, runEspecialista, tipoPaciente FROM pacientes AS p
INNER JOIN consultas AS c ON p.idHospital = c.idHospital
WHERE tipoPaciente = 'niño' AND prioridad <= 4
AND c.idHospital = id
AND runEspecialista = run
AND p.estado = 'En Espera'
ORDER BY prioridad DESC;

WHEN idConsulta = 3 THEN 
SELECT numeroHistoriaClinicaPaciente, runPaciente, nombrePaciente, prioridad, nombreEspecialista, runEspecialista, tipoPaciente FROM pacientes AS p
INNER JOIN consultas AS c ON p.idHospital = c.idHospital
WHERE tipoPaciente NOT IN ('niño')
AND c.idHospital = id AND runEspecialista = run
AND p.estado = 'En Espera'
ORDER BY prioridad DESC;
WHEN idConsulta = 2 THEN
SELECT numeroHistoriaClinicaPaciente, runPaciente, nombrePaciente, prioridad, nombreEspecialista, runEspecialista, tipoPaciente FROM pacientes AS p
INNER JOIN consultas AS c ON p.idHospital = c.idHospital
WHERE prioridad > 4
AND c.idHospital = id
AND runEspecialista = run
AND p.estado = 'En Espera'
ORDER BY prioridad DESC;
END CASE;
END;;

DROP PROCEDURE IF EXISTS `listarPacientes`;;
CREATE PROCEDURE `listarPacientes`(IN id INT)
BEGIN

CASE
-- LISTAR TODOS LOS PACIENTES ORDENADOS POR numeroHistoriaClinicaPaciente 
WHEN id = 1 THEN 
SELECT numeroHistoriaClinicaPaciente,
        nombrePaciente, 
        fechaNacimientoPaciente, 
        TIMESTAMPDIFF(YEAR, fechaNacimientoPaciente, CURDATE()) AS edadPaciente,
        prioridad,
        IF(tipoPaciente= 'anciano', ((TIMESTAMPDIFF(YEAR, fechaNacimientoPaciente, CURDATE()) * prioridad)/100 +5.3), ((TIMESTAMPDIFF(YEAR, fechaNacimientoPaciente, CURDATE()) * prioridad) /100) ) AS riesgo,
        h.nombreHospital
        FROM pacientes AS p
        INNER JOIN hospitales AS h ON p.idHospital = h.idHospital
        ORDER BY numeroHistoriaClinicaPaciente DESC;

WHEN id = 2 THEN 
-- LISTAR TODOS LOS PACIENTES ORDENADOS POR nivel de riesgo
SELECT numeroHistoriaClinicaPaciente,
        nombrePaciente, 
        fechaNacimientoPaciente, 
        TIMESTAMPDIFF(YEAR, fechaNacimientoPaciente, CURDATE()) AS edadPaciente,
        prioridad,
        IF(tipoPaciente= 'anciano', ((TIMESTAMPDIFF(YEAR, fechaNacimientoPaciente, CURDATE()) * prioridad)/100 +5.3), ((TIMESTAMPDIFF(YEAR, fechaNacimientoPaciente, CURDATE()) * prioridad) /100) ) AS riesgo,
        h.nombreHospital
        FROM pacientes AS p
        INNER JOIN hospitales AS h ON p.idHospital = h.idHospital
        ORDER BY riesgo DESC;
WHEN id= 3 THEN
-- LISTAR TODOS LOS PACIENTES FUMADORES
SELECT numeroHistoriaClinicaPaciente,
        nombrePaciente,
        'SI' AS pacienteFumadador,
        fechaNacimientoPaciente, 
        TIMESTAMPDIFF(YEAR, fechaNacimientoPaciente, CURDATE()) AS edadPaciente,
        prioridad,
        IF(tipoPaciente= 'anciano', ((TIMESTAMPDIFF(YEAR, fechaNacimientoPaciente, CURDATE()) * prioridad)/100 +5.3), ((TIMESTAMPDIFF(YEAR, fechaNacimientoPaciente, CURDATE()) * prioridad) /100) ) AS riesgo,
        h.nombreHospital
        FROM pacientes AS p
        INNER JOIN hospitales AS h ON p.idHospital = h.idHospital
        WHERE pacienteFumador = 1
        ORDER BY riesgo DESC;
END CASE;
END;;

DELIMITER ;

DROP TABLE IF EXISTS `atencionespacientes`;
CREATE TABLE `atencionespacientes` (
  `idAtencion` int NOT NULL AUTO_INCREMENT,
  `numeroHistoriaClinicaPaciente` int NOT NULL,
  `idConsulta` int NOT NULL,
  `idHospital` int NOT NULL,
  `fechaAtencion` datetime NOT NULL,
  `estadoAtencion` varchar(20) NOT NULL,
  PRIMARY KEY (`idAtencion`),
  KEY `numeroHistoriaClinicaPaciente` (`numeroHistoriaClinicaPaciente`),
  KEY `idConsulta` (`idConsulta`),
  KEY `idHospital` (`idHospital`),
  CONSTRAINT `atencionespacientes_ibfk_1` FOREIGN KEY (`numeroHistoriaClinicaPaciente`) REFERENCES `pacientes` (`numeroHistoriaClinicaPaciente`),
  CONSTRAINT `atencionespacientes_ibfk_2` FOREIGN KEY (`idConsulta`) REFERENCES `consultas` (`idConsulta`),
  CONSTRAINT `atencionespacientes_ibfk_3` FOREIGN KEY (`idHospital`) REFERENCES `hospitales` (`idHospital`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


DROP TABLE IF EXISTS `consultas`;
CREATE TABLE `consultas` (
  `idConsulta` int NOT NULL AUTO_INCREMENT,
  `idHospital` int NOT NULL,
  `runEspecialista` varchar(10) NOT NULL,
  `nombreEspecialista` varchar(200) NOT NULL,
  `idTipoConsulta` int NOT NULL,
  `estado` varchar(20) NOT NULL,
  PRIMARY KEY (`idConsulta`),
  UNIQUE KEY `idEspecialista` (`nombreEspecialista`),
  UNIQUE KEY `runEspecialista` (`runEspecialista`),
  KEY `idHospital` (`idHospital`),
  KEY `idTipoConsulta` (`idTipoConsulta`),
  CONSTRAINT `consultas_ibfk_4` FOREIGN KEY (`idHospital`) REFERENCES `hospitales` (`idHospital`),
  CONSTRAINT `consultas_ibfk_6` FOREIGN KEY (`idTipoConsulta`) REFERENCES `tipoconsulta` (`idTipoConsulta`),
  CONSTRAINT `consultas_ibfk_7` FOREIGN KEY (`idTipoConsulta`) REFERENCES `tipoconsulta` (`idTipoConsulta`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

INSERT INTO `consultas` (`idConsulta`, `idHospital`, `runEspecialista`, `nombreEspecialista`, `idTipoConsulta`, `estado`) VALUES
(2,	12,	'11223344',	'Dr Strange',	1,	'En Espera'),
(3,	12,	'1123123',	'Dra Gonzalez',	2,	'En Espera'),
(13,	12,	'15121212',	'Dra. Ortega',	1,	'En Espera'),
(14,	12,	'22112211',	'Dr Henandez',	3,	'En Espera'),
(15,	4,	'99887766',	'Dr Francisco Esteban González Pérez',	3,	'En Espera');

DROP TABLE IF EXISTS `especialistas`;
CREATE TABLE `especialistas` (
  `idEspecialista` int NOT NULL AUTO_INCREMENT,
  `runEspecialista` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8_general_ci NOT NULL,
  `nombreEspecialista` varchar(200) NOT NULL,
  PRIMARY KEY (`idEspecialista`),
  UNIQUE KEY `runEspecialista` (`runEspecialista`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

INSERT INTO `especialistas` (`idEspecialista`, `runEspecialista`, `nombreEspecialista`) VALUES
(1,	'',	'Marcelo Andrés Vera Sandoval');

DROP TABLE IF EXISTS `hospitales`;
CREATE TABLE `hospitales` (
  `idHospital` int NOT NULL AUTO_INCREMENT,
  `nombreHospital` varchar(500) NOT NULL,
  PRIMARY KEY (`idHospital`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

INSERT INTO `hospitales` (`idHospital`, `nombreHospital`) VALUES
(1,	'Hospital Metropolitano de Santiago'),
(4,	'Hospital Barros Luco Trudeau'),
(12,	'Hospital Metropolitano Occidente Félix Bulnes Cerda');

DROP TABLE IF EXISTS `pacientes`;
CREATE TABLE `pacientes` (
  `numeroHistoriaClinicaPaciente` int NOT NULL AUTO_INCREMENT,
  `nombrePaciente` varchar(200) NOT NULL,
  `runPaciente` varchar(15) NOT NULL,
  `fechaNacimientoPaciente` date NOT NULL,
  `idHospital` int NOT NULL,
  `relacionPesoEstatura` int DEFAULT NULL,
  `pacienteFumador` tinyint DEFAULT NULL,
  `anniosFumador` varchar(2) DEFAULT NULL,
  `pacienteDieta` tinytext,
  `prioridad` float NOT NULL,
  `tipoPaciente` varchar(7) CHARACTER SET utf8mb3 COLLATE utf8_general_ci NOT NULL,
  `estado` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8_general_ci NOT NULL,
  PRIMARY KEY (`numeroHistoriaClinicaPaciente`),
  UNIQUE KEY `runPaciente` (`runPaciente`),
  KEY `idHospital` (`idHospital`),
  CONSTRAINT `pacientes_ibfk_1` FOREIGN KEY (`idHospital`) REFERENCES `hospitales` (`idHospital`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

INSERT INTO `pacientes` (`numeroHistoriaClinicaPaciente`, `nombrePaciente`, `runPaciente`, `fechaNacimientoPaciente`, `idHospital`, `relacionPesoEstatura`, `pacienteFumador`, `anniosFumador`, `pacienteDieta`, `prioridad`, `tipoPaciente`, `estado`) VALUES
(8,	'Alex Alvarado',	'55665566',	'1990-01-05',	12,	NULL,	0,	'',	NULL,	2,	'joven',	'En Espera'),
(9,	'Iris vargas',	'67676767k',	'1971-08-22',	12,	NULL,	NULL,	NULL,	'0',	4.66667,	'anciano',	'atendido'),
(10,	'Camila Lopez',	'22334455',	'2018-01-01',	12,	3,	NULL,	NULL,	NULL,	6,	'niño',	'En Espera'),
(11,	'Alejandra Mendez',	'98989898k',	'1990-12-05',	12,	NULL,	0,	'',	NULL,	2,	'joven',	'En Espera'),
(12,	'Cesar Díaz',	'11223344',	'2008-06-04',	12,	4,	NULL,	NULL,	NULL,	5,	'niño',	'En Espera'),
(13,	'Miguel Alvarado',	'12312312',	'1987-01-10',	12,	NULL,	1,	'14',	NULL,	5.5,	'joven',	'atendido'),
(14,	'Andrea Jara',	'F12883934',	'2018-06-18',	12,	4,	NULL,	NULL,	NULL,	7,	'niño',	'En Espera'),
(15,	'Usuario Test',	'11112222',	'1998-01-06',	1,	NULL,	1,	'2',	NULL,	2.5,	'joven',	'En Espera'),
(16,	'Bastián',	'123123123',	'2016-06-19',	4,	3,	NULL,	NULL,	NULL,	6,	'niño',	'En Espera'),
(17,	'Javier Nuñez',	'63773737',	'2016-05-06',	12,	1,	NULL,	NULL,	NULL,	3,	'niño',	'En Espera'),
(18,	'Susana Arias',	'21212121',	'2020-01-01',	12,	1,	NULL,	NULL,	NULL,	4,	'niño',	'En Espera'),
(19,	'Juan Vera',	'81212121',	'1945-12-13',	4,	NULL,	NULL,	NULL,	'1',	7.8,	'anciano',	'En Espera'),
(20,	'Sonia Almonacid Sanhueza',	'6546535',	'1935-10-10',	4,	NULL,	NULL,	NULL,	'0',	5.86667,	'anciano',	'En Espera');

DROP TABLE IF EXISTS `programaanciano`;
CREATE TABLE `programaanciano` (
  `idProgramaAnciano` int NOT NULL AUTO_INCREMENT,
  `tieneDieta` bit(1) NOT NULL,
  `numeroHistoriaClinicaPaciente` int NOT NULL,
  PRIMARY KEY (`idProgramaAnciano`),
  KEY `numeroHistoriaClinicaPaciente` (`numeroHistoriaClinicaPaciente`),
  CONSTRAINT `programaanciano_ibfk_1` FOREIGN KEY (`numeroHistoriaClinicaPaciente`) REFERENCES `pacientes` (`numeroHistoriaClinicaPaciente`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


DROP TABLE IF EXISTS `programajoven`;
CREATE TABLE `programajoven` (
  `idPrograma` int NOT NULL AUTO_INCREMENT,
  `fumador` bit(1) NOT NULL,
  `numeroHistoriaClinicaPaciente` int NOT NULL,
  PRIMARY KEY (`idPrograma`),
  KEY `numeroHistoriaClinicaPaciente` (`numeroHistoriaClinicaPaciente`),
  CONSTRAINT `programajoven_ibfk_1` FOREIGN KEY (`numeroHistoriaClinicaPaciente`) REFERENCES `pacientes` (`numeroHistoriaClinicaPaciente`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


DROP TABLE IF EXISTS `programaninno`;
CREATE TABLE `programaninno` (
  `idProgramaNinno` int NOT NULL AUTO_INCREMENT,
  `relacionPesoEstatura` int NOT NULL,
  `numeroHistoriaClinicaPaciente` int NOT NULL,
  PRIMARY KEY (`idProgramaNinno`),
  KEY `numeroHistoriaClinicaPaciente` (`numeroHistoriaClinicaPaciente`),
  CONSTRAINT `programaninno_ibfk_1` FOREIGN KEY (`numeroHistoriaClinicaPaciente`) REFERENCES `pacientes` (`numeroHistoriaClinicaPaciente`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


DROP TABLE IF EXISTS `tipoconsulta`;
CREATE TABLE `tipoconsulta` (
  `idTipoConsulta` int NOT NULL AUTO_INCREMENT,
  `nombreTipoConsulta` varchar(50) NOT NULL,
  PRIMARY KEY (`idTipoConsulta`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

INSERT INTO `tipoconsulta` (`idTipoConsulta`, `nombreTipoConsulta`) VALUES
(1,	'Pediatría'),
(2,	'Urgencia'),
(3,	'CGI Consulta General Integral');

-- 2022-06-20 22:01:03
