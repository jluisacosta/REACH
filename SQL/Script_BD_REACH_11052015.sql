-- phpMyAdmin SQL Dump
-- version 4.0.10.7
-- http://www.phpmyadmin.net
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 30-03-2015 a las 20:00:43
-- Versión del servidor: 5.1.68-community-log
-- Versión de PHP: 5.3.29

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Base de datos: `alejand_reach`
--
DROP DATABASE IF EXISTS `alejand_reach`;
CREATE DATABASE `alejand_reach` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE `alejand_reach`;

DELIMITER $$
--
-- Procedimientos
--
DROP PROCEDURE IF EXISTS `insertaConcentrado`$$
CREATE PROCEDURE `insertaConcentrado`(IN `id` VARCHAR(3), IN `fecha_act` DATE, IN `cp` DECIMAL(10,2), IN `masa` DECIMAL(10,2), IN `area` DECIMAL(10,2))
BEGIN
	DECLARE sumf01 DECIMAL(10,2) DEFAULT 0;
	DECLARE sumf03 DECIMAL(10,2) DEFAULT 0;
	DECLARE sumf04 DECIMAL(10,2) DEFAULT 0;
	DECLARE gasv DECIMAL(10,2) DEFAULT 0;
	DECLARE kcal_kgv DECIMAL(10,2) DEFAULT 0;
	DECLARE kg_kgv DECIMAL(10,2) DEFAULT 0;
	DECLARE kj_kcalv DECIMAL(10,2) DEFAULT 0;
	DECLARE effv DECIMAL(10,2) DEFAULT 0;

	DECLARE prom_irrad DECIMAL(10,2) DEFAULT 0;
	DECLARE prom_delta DECIMAL(10,2) DEFAULT 0;
	DECLARE deltat DECIMAL(10,2) DEFAULT 0;
	DECLARE tempmin DECIMAL(10,2) DEFAULT 0;
	DECLARE tempmax DECIMAL(10,2) DEFAULT 0;
	DECLARE tiempo_total DECIMAL(10,2) DEFAULT 0;
	DECLARE energia_capt DECIMAL(10,2) DEFAULT 0;
	DECLARE energia_disp DECIMAL(10,2) DEFAULT 0;
	DECLARE eficiencia DECIMAL(10,2) DEFAULT 0;
	DECLARE costokj DECIMAL(10,5) DEFAULT 0;
	DECLARE ganancia DECIMAL(10,5) DEFAULT 0;

	# Irradiacion solar y Tiempo total
	SET sumf01 = (SELECT SUM(Formula1) FROM formulas WHERE Id_Empresa = id AND Fecha = fecha_act);
	SET tiempo_total = (SELECT SUM(Formula2) FROM formulas WHERE Id_Empresa = id AND Fecha = fecha_act);
	SET prom_irrad = sumf01/tiempo_total;

	# Promedio Delta_T
	SET sumf03 = (SELECT SUM(Formula3) FROM formulas WHERE Id_Empresa = id AND Fecha = fecha_act);
	SET sumf04 = (SELECT SUM(Formula4) FROM formulas WHERE Id_Empresa = id AND Fecha = fecha_act);
	SET prom_delta = (sumf03/tiempo_total) - (sumf04/tiempo_total);

	# Temperatura minima, maxima y Delta T
	SET tempmin = (SELECT MIN(Formula5) FROM formulas WHERE Id_Empresa = id AND Fecha = fecha_act AND Formula5>0);
	SET tempmax = (SELECT MAX(Formula5) FROM formulas WHERE Id_Empresa = id AND Fecha = fecha_act);
	SET deltat = tempmax - tempmin;

	#Energia captada, Energia disponible y Eficiencia
	SET energia_capt = (cp*masa*deltat)/1000;
	SET energia_disp = (sumf01*60*area)/1000;
	SET eficiencia = energia_capt/energia_disp;

	# costo/kj y Ganancia

	SET gasv = (SELECT GAS FROM constantes WHERE Id_Empresa = id);
	SET kcal_kgv = (SELECT KCAL_KG FROM constantes WHERE Id_Empresa = id);
	SET kg_kgv = (SELECT KG_KG FROM constantes WHERE Id_Empresa = id);
	SET kj_kcalv = (SELECT KJ_KCAL FROM constantes WHERE Id_Empresa = id);
	SET effv = (SELECT EFF FROM constantes WHERE Id_Empresa = id);

	SET costokj = gasv/(kcal_kgv*kg_kgv*kj_kcalv*effv);
	SET ganancia = costokj*energia_capt;

	INSERT INTO concentrado (Id_Empresa,Fecha,Irradiacion_Solar,Promedio_Delta_T,Delta_T,Ener_Captada,Ener_Disponible,
							 Eficiencia,Masa,Temp_Max,Temp_Min,Ganancia,Tiempo_Total,Costo_KJ) 
	VALUES (id,fecha_act,prom_irrad,prom_delta,deltat,energia_capt,energia_disp,eficiencia,masa,tempmax,tempmin,ganancia,tiempo_total,costokj);

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `bitacora`
--

DROP TABLE IF EXISTS `bitacora`;
CREATE TABLE IF NOT EXISTS `bitacora` (
  `Id_Empresa` varchar(3) NOT NULL,
  `Id_Usuario` int(11) NOT NULL,
  `Id_Ventana` varchar(3) NOT NULL,
  `Descripcion_Consulta` varchar(100) NOT NULL,
  `Fecha` date NOT NULL,
  `Hora` time NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `concentrado`
--

DROP TABLE IF EXISTS `concentrado`;
CREATE TABLE IF NOT EXISTS `concentrado` (
  `Id_Empresa` varchar(3) NOT NULL,
  `Fecha` date NOT NULL,
  `Irradiacion_Solar` decimal(10,2) DEFAULT NULL,
  `Promedio_Delta_T` decimal(10,2) DEFAULT NULL,
  `Delta_T` decimal(10,2) DEFAULT NULL,
  `Ener_Captada` decimal(10,2) DEFAULT NULL,
  `Ener_Disponible` decimal(10,2) DEFAULT NULL,
  `Eficiencia` decimal(10,2) DEFAULT NULL,
  `Masa` decimal(10,2) DEFAULT NULL,
  `Temp_Max` decimal(10,2) DEFAULT NULL,
  `Temp_Min` decimal(10,2) DEFAULT NULL,
  `Ganancia` decimal(10,5) DEFAULT NULL,
  `Tiempo_Total` decimal(10,2) DEFAULT NULL,
  `Costo_KJ` decimal(10,5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `configuracion`
--

DROP TABLE IF EXISTS `configuracion`;
CREATE TABLE IF NOT EXISTS `configuracion` (
  `Id_Empresa` varchar(3) NOT NULL,
  `Id_Usuario` int(11) NOT NULL,
  `Descripcion` longtext NOT NULL,
  `Privilegio1` int(11) NOT NULL,
  `Privilegio2` int(11) DEFAULT NULL,
  `Privilegio3` int(11) DEFAULT NULL,
  `Privilegio4` int(11) DEFAULT NULL,
  `Privilegio5` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `constantes`
--

DROP TABLE IF EXISTS `constantes`;
CREATE TABLE IF NOT EXISTS `constantes` (
  `Id_Empresa` varchar(3) NOT NULL,
  `INICIO` decimal(10,2) NOT NULL,
  `FIN` decimal(10,2) NOT NULL,
  `CP` decimal(10,2) NOT NULL,
  `MASA` decimal(10,2) NOT NULL,
  `AREA` decimal(10,2) NOT NULL,
  `GAS` decimal(10,2) NOT NULL,
  `KCAL_KG` decimal(10,2) NOT NULL,
  `KG_KG` decimal(10,2) NOT NULL,
  `KJ_KCAL` decimal(10,2) NOT NULL,
  `EFF` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `datos_paneles`
--

DROP TABLE IF EXISTS `datos_paneles`;
CREATE TABLE IF NOT EXISTS `datos_paneles` (
  `Id_Dato` int(11) AUTO_INCREMENT NOT NULL,
  `Id_Empresa` varchar(3) NOT NULL,
  `Fecha` date NOT NULL,
  `Hora` time NOT NULL,
  `Irradiacion` decimal(10,2) NOT NULL,
  `Temp_Tanque` decimal(10,2) NOT NULL,
  `Temp1` decimal(10,2) NOT NULL,
  `Temp2` decimal(10,2) NOT NULL,
  `Pos_Solar` decimal(10,2) NOT NULL,
  `Inclinacion` decimal(10,2) NOT NULL,
  `Flujo` decimal(10,2) NOT NULL,
  `Bomba` decimal(10,2) NOT NULL,
  `Temp_Ambiente` decimal(10,2) NOT NULL,
  `Lluvia` decimal(10,2) NOT NULL,
  `Viento` decimal(10,2) NOT NULL,
  `Id_Viento` varchar(3) DEFAULT NULL,
  CONSTRAINT `pk_datos_paneles` PRIMARY KEY (`Id_Dato`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Disparadores `datos_paneles`
--
DROP TRIGGER IF EXISTS `insercionFormulas`;
DELIMITER //
CREATE TRIGGER `insercionFormulas` AFTER INSERT ON `datos_paneles`
 FOR EACH ROW BEGIN
	DECLARE energia_capt DECIMAL(10,2) DEFAULT 0;
	DECLARE energia_disp DECIMAL(10,2) DEFAULT 0;
	DECLARE eficiencia DECIMAL(10,2) DEFAULT 0;
	DECLARE deltat DECIMAL(10,2) DEFAULT 0;
	DECLARE dif_in_out DECIMAL(10,2) DEFAULT 0;
	DECLARE f01 DECIMAL(10,2) DEFAULT 0;
	DECLARE f02 DECIMAL(10,2) DEFAULT 0;
	DECLARE f03 DECIMAL(10,2) DEFAULT 0;
	DECLARE f04 DECIMAL(10,2) DEFAULT 0;
	DECLARE f05 DECIMAL(10,2) DEFAULT 0;

	DECLARE iniciov DECIMAL(10,2) DEFAULT 0;
	DECLARE finv DECIMAL(10,2) DEFAULT 0;
	DECLARE cpv DECIMAL(10,2) DEFAULT 0;
	DECLARE masav DECIMAL(10,2) DEFAULT 0;
	DECLARE areav DECIMAL(10,2) DEFAULT 0;

	# Constantes
	SET iniciov = (SELECT INICIO FROM constantes WHERE Id_Empresa = NEW.Id_Empresa);
	SET finv = (SELECT FIN FROM constantes WHERE Id_Empresa = NEW.Id_Empresa);
	SET cpv = (SELECT CP FROM constantes WHERE Id_Empresa = NEW.Id_Empresa);
	SET masav = (SELECT MASA FROM constantes WHERE Id_Empresa = NEW.Id_Empresa);
	SET areav = (SELECT AREA FROM constantes WHERE Id_Empresa = NEW.Id_Empresa);

	# Formulas
	IF NEW.Inclinacion > (iniciov+1) AND NEW.Pos_Solar < finv
	AND NEW.Pos_Solar > iniciov THEN
		SET f01 = NEW.Irradiacion;
		SET f02 = 1;
		SET f03 = NEW.Temp1;
		SET f04 = NEW.Temp2;
		SET f05 = NEW.Temp_Tanque;
	END IF;

	# Delt_T
	SET deltat = (SELECT MIN(Formula5) FROM formulas
	WHERE Id_Empresa = NEW.Id_Empresa AND Fecha = NEW.Fecha AND Formula5 > 0);

	IF deltat IS NOT NULL THEN
		IF f05 < deltat THEN
			SET deltat = f05;
		END IF;
	ELSE SET deltat = 0;
	END IF;

	SET deltat = f05 - deltat;

	# Energia_disp

	SET energia_disp = (SELECT formulas.Energia_Disp FROM formulas WHERE Id_Empresa = NEW.Id_Empresa
	AND Hora = (SELECT MAX(Hora) FROM formulas WHERE Id_Empresa = NEW.Id_Empresa AND Fecha = NEW.Fecha) LIMIT 1);

	IF energia_disp IS NULL THEN
		SET energia_disp = 0;
	END IF;

	SET energia_disp = ((f01 * areav * 60)/1000) + energia_disp;

	# Energia_capt y Eficiencia
	IF f02 > 0 THEN
		SET energia_capt = (cpv * masav * deltat)/1000;
		SET eficiencia = (energia_capt/energia_disp)*100;
	END IF;

	# Dif_in_out
	SET dif_in_out = f03 - f04;

	# INSTRUCCION DE INSERCION
	INSERT INTO formulas (Id_Empresa,Energia_Capt,Energia_Disp,Eficiencia,Delta_T,
						  Dif_In_Out,Formula1,Formula2,Formula3,Formula4,Formula5,Fecha,Hora)
	VALUES (NEW.Id_Empresa,energia_capt,energia_disp,eficiencia,deltat,dif_in_out,f01,f02,f03,f04,f05,NEW.Fecha,NEW.Hora);

	IF NEW.Hora >= '22:00:00' AND NEW.Hora < '22:01:00' THEN
		CALL insertaConcentrado(NEW.Id_Empresa,NEW.Fecha,cpv,masav,areav);
	END IF;
END
//
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `datos_personales`
--

DROP TABLE IF EXISTS `datos_personales`;
CREATE TABLE IF NOT EXISTS `datos_personales` (
  `Id_Persona` int(11) AUTO_INCREMENT NOT NULL,
  `Id_Empresa` varchar(3) NOT NULL,
  `Nombre` varchar(30) NOT NULL,
  `ApellidoP` varchar(20) NOT NULL,
  `ApellitoM` varchar(20) NOT NULL,
  `Correo` varchar(30) NOT NULL,
  `Telefono1` varchar(25) NOT NULL,
  `Telefono2` varchar(25) DEFAULT NULL,
  `Direccion` varchar(200) NOT NULL,
  CONSTRAINT `pk_datos_personales` PRIMARY KEY (`Id_Persona`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `dir_viento`
--

DROP TABLE IF EXISTS `dir_viento`;
CREATE TABLE IF NOT EXISTS `dir_viento` (
  `Id_Viento` varchar(3) NOT NULL,
  `Descripcion` varchar(200) NOT NULL,
  `Valor` decimal(10,2) NOT NULL,
  CONSTRAINT `pk_dir_viento` PRIMARY KEY (`Id_Viento`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `empresas`
--

DROP TABLE IF EXISTS `empresas`;
CREATE TABLE IF NOT EXISTS `empresas` (
  `Id_Empresa` varchar(3) NOT NULL,
  `Descripcion_Empresa` varchar(200) NOT NULL,
  `Nombre_Cliente` varchar(100) NOT NULL,
  `RFC` varchar(15) DEFAULT NULL,
  `Direccion` varchar(200) DEFAULT NULL,
  `Colonia` varchar(50) DEFAULT NULL,
  `Cp` varchar(6) DEFAULT NULL,
  `Ciudad` varchar(50) DEFAULT NULL,
  `Pais` varchar(20) DEFAULT NULL,
  `Razon_Social` varchar(100) DEFAULT NULL,
  CONSTRAINT `pk_empresas` PRIMARY KEY (`Id_Empresa`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `formulas`
--

DROP TABLE IF EXISTS `formulas`;
CREATE TABLE IF NOT EXISTS `formulas` (
  `Id_Dato` int(11) AUTO_INCREMENT NOT NULL,
  `Id_Empresa` varchar(3) NOT NULL,
  `Energia_Capt` decimal(10,2) NOT NULL,
  `Energia_Disp` decimal(10,2) NOT NULL,
  `Eficiencia` decimal(10,2) NOT NULL,
  `Delta_T` decimal(10,2) NOT NULL,
  `Dif_In_Out` decimal(10,2) NOT NULL,
  `Formula1` decimal(10,2) NOT NULL,
  `Formula2` decimal(10,2) NOT NULL,
  `Formula3` decimal(10,2) NOT NULL,
  `Formula4` decimal(10,2) NOT NULL,
  `Formula5` decimal(10,2) NOT NULL,
  `Fecha` date NOT NULL,
  `Hora` time NOT NULL,
  CONSTRAINT `pk_formulas` PRIMARY KEY (`Id_Dato`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `privilegios`
--

DROP TABLE IF EXISTS `privilegios`;
CREATE TABLE IF NOT EXISTS `privilegios` (
  `Id_Privilegio` int(11) AUTO_INCREMENT NOT NULL,
  `Descripcion` varchar(100) NOT NULL,
  `Tipo` varchar(2) NOT NULL,
  CONSTRAINT `pk_privilegios` PRIMARY KEY (`Id_Privilegio`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
CREATE TABLE IF NOT EXISTS `usuarios` (
  `Id_Usuario` int(11) AUTO_INCREMENT NOT NULL,
  `Id_Persona` int(11) NOT NULL,
  `Id_Privilegio` int(11) NOT NULL,
  `Id_Empresa` varchar(3) NOT NULL,
  `Nombre_Usuario` varchar(50) NOT NULL,
  `Contrasena` int(15) NOT NULL,
  CONSTRAINT `pk_usuarios` PRIMARY KEY (`Id_Usuario`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `bitacora`
--

ALTER TABLE `bitacora` ADD CONSTRAINT `fk_id_empresa_bitacora`
FOREIGN KEY (`Id_Empresa`) REFERENCES `empresas` (`Id_Empresa`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `bitacora` ADD CONSTRAINT `fk_id_usuario_bitacora`
FOREIGN KEY (`Id_Usuario`) REFERENCES `usuarios` (`Id_Usuario`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `concentrado`
--

ALTER TABLE `concentrado` ADD CONSTRAINT `fk_id_empresa_concentrado`
FOREIGN KEY (`Id_Empresa`) REFERENCES `empresas` (`Id_Empresa`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `configuracion`
--

ALTER TABLE `configuracion` ADD CONSTRAINT `fk_id_empresa_configuracion`
FOREIGN KEY (`Id_Empresa`) REFERENCES `empresas` (`Id_Empresa`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `configuracion` ADD CONSTRAINT `fk_id_usuario_configuracion`
FOREIGN KEY (`Id_Usuario`) REFERENCES `usuarios` (`Id_Usuario`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `constantes`
--

ALTER TABLE `constantes` ADD CONSTRAINT `fk_id_empresa_constantes`
FOREIGN KEY (`Id_Empresa`) REFERENCES `empresas` (`Id_Empresa`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `datos_paneles`
--

ALTER TABLE `datos_paneles` ADD CONSTRAINT `fk_id_empresa_datos_paneles`
FOREIGN KEY (`Id_Empresa`) REFERENCES `empresas` (`Id_Empresa`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `datos_paneles` ADD CONSTRAINT `fk_id_viento_datos_paneles`
FOREIGN KEY (`Id_Viento`) REFERENCES `dir_viento` (`Id_Viento`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `datos_personales`
--

ALTER TABLE `datos_personales` ADD CONSTRAINT `fk_id_empresa_datos_personales`
FOREIGN KEY (`Id_Empresa`) REFERENCES `empresas` (`Id_Empresa`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `formulas`
--

ALTER TABLE `formulas` ADD CONSTRAINT `fk_id_empresa_formulas`
FOREIGN KEY (`Id_Empresa`) REFERENCES `empresas` (`Id_Empresa`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `usuarios`
--

ALTER TABLE `usuarios` ADD CONSTRAINT `fk_id_empresa_usuarios`
FOREIGN KEY (`Id_Empresa`) REFERENCES `empresas` (`Id_Empresa`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `usuarios` ADD CONSTRAINT `fk_id_persona_usuarios`
FOREIGN KEY (`Id_Persona`) REFERENCES `datos_personales` (`Id_Persona`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `usuarios` ADD CONSTRAINT `fk_id_privilegio_usuarios`
FOREIGN KEY (`Id_Privilegio`) REFERENCES `privilegios` (`Id_Privilegio`) ON DELETE CASCADE ON UPDATE CASCADE;


/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
