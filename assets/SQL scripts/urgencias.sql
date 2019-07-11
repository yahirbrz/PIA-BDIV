-- phpMyAdmin SQL Dump
-- version 4.9.0.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 11, 2019 at 04:15 AM
-- Server version: 10.3.16-MariaDB
-- PHP Version: 7.3.6

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `urgencias`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_CRUD_HABITACIONES` (`OPC` INT, `HAB` INT, `STAT` CHAR(1), `DES` VARCHAR(200), OUT `RES` BIT)  BEGIN
DECLARE varHAB INT;
CASE OPC
	WHEN 1 THEN
		SELECT COALESCE(MAX(NUMHABITACION),0) INTO varHAB FROM HABITACIONES;
		SET varHAB = varHAB + 1;
		INSERT INTO HABITACIONES VALUES(varHAB,STAT,DES);
		IF EXISTS(SELECT * FROM HABITACIONES WHERE NUMHABITACION = varHAB) THEN
			SELECT CONCAT("Se registró la habitación: ",NUMHABITACION) AS MSG, 1 AS RES FROM HABITACIONES
            WHERE NUMHABITACION = varHAB;
			SET RES = 1;
        ELSE
			SELECT "No se pudó registrar!" AS MSG, 0 AS RES;
			SET RES = 0;
		END IF;
	WHEN 2 THEN
		SELECT NUMHABITACION, CASE STATUS WHEN 'D' THEN 'Disponible' WHEN 'O' THEN 'Ocupada' WHEN 'S' THEN 'Sucia' END AS STATUS, DESCRIPCION FROM HABITACIONES
		WHERE (HAB IS NULL OR NUMHABITACION = HAB) AND (STAT IS NULL OR STATUS = STAT) AND (DES IS NULL OR DESCRIPCION = DES);
		SET RES = 1;
	WHEN 3 THEN
		UPDATE HABITACIONES SET STATUS = STAT, DESCRIPCION = DES WHERE NUMHABITACION = HAB;
		IF EXISTS(SELECT * FROM HABITACIONES WHERE NUMHABITACION = HAB AND STATUS = STAT AND DESCRIPCION = DES) THEN
			SELECT "Se actualizó correctamente!" AS MSG, 1 AS RES;
			SET RES = 1;
		ELSE
			SELECT "No se pudó actualizar!" AS MSG, 0 AS RES;
			SET RES = 0;
		END IF;
	WHEN 4 THEN
		DELETE FROM HABITACIONES WHERE NUMHABITACION = HAB;
        IF NOT EXISTS(SELECT * FROM HABITACIONES WHERE NUMHABITACION = HAB) THEN
			SELECT "Se eliminó correctamente!" AS MSG, 1 AS RES;
			SET RES = 1;
		ELSE
			SELECT "No se pudó eliminar la habitación!" AS MSG, 0 AS RES;
			SET RES = 0;
		END IF;
	ELSE
		SELECT "OPCIÓN NO VALIDA!" AS MSG, 3 AS RES;
		SET RES = 3;
END CASE;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_CRUD_MEDICOS` (`OPC` INT, `CED` VARCHAR(20), `NOM` VARCHAR(200), `APE` VARCHAR(200), `DIR` VARCHAR(300), `TEL` VARCHAR(10), OUT `RES` BIT)  BEGIN
CASE OPC
	WHEN 1 THEN
		INSERT INTO MEDICOS VALUES(CED,NOM,APE,DIR,TEL);
		IF EXISTS(SELECT * FROM MEDICOS WHERE CEDULA = CED) THEN
			SELECT CONCAT("Se registró a ",SUBSTRING_INDEX(NOMBRE, ' ', 1)," ",SUBSTRING_INDEX(APELLIDOS, ' ', 1)," con la cedula no: ",CED) AS MSG, 1 AS RES FROM MEDICOS
            WHERE CEDULA = CED;
			SET RES = 1;
        ELSE
			SELECT "No se pudó registrar!" AS MSG, 0 AS RES;
			SET RES = 0;
		END IF;
	WHEN 2 THEN
		SELECT CEDULA, NOMBRE, APELLIDOS, DIRECCION, TEL FROM MEDICOS
		WHERE (CEDULA IS NULL OR CEDULA = CED) AND (NOM IS NULL OR NOMBRES LIKE CONCAT('%',NOM,'%')) AND
        (APE IS NULL OR APELLIDOS LIKE CONCAT('%',APE,'%')) AND (DIR IS NULL OR DIRECCION LIKE CONCAT('%',DIR,'%')) AND (TEL IS NULL OR TELEFONO LIKE CONCAT('%',TEL,'%'));
		SET RES = 1;
	WHEN 3 THEN
		UPDATE MEDICO SET DIRECCION = DIR, TELEFONO= TEL WHERE CEDULA = CED;
		IF EXISTS(SELECT * FROM MEDICOS WHERE CEDULA = CED AND DIRECCION = DIR AND TELEFONO = TEL) THEN
			SELECT "Se actualizó correctamente!" AS MSG, 1 AS RES;
			SET RES = 1;
		ELSE
			SELECT "No se pudó actualizar!" AS MSG, 0 AS RES;
			SET RES = 0;
		END IF;
	WHEN 4 THEN
		DELETE FROM MEDICOS WHERE CEDULA = CED;
        IF NOT EXISTS(SELECT * FROM MEDICOS WHERE CEDULA = CED) THEN
			SELECT "Se eliminó correctamente!" AS MSG, 1 AS RES;
			SET RES = 1;
		ELSE
			SELECT "No se pudó eliminar el registr correctamente!" AS MSG, 0 AS RES;
			SET RES = 0;
		END IF;
	ELSE
		SELECT "OPCIÓN NO VALIDA!" AS MSG, 3 AS RES;
		SET RES = 3;
END CASE;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_CRUD_PACIENTES` (`OPC` INT, `EXPED` VARCHAR(20), `NOM` VARCHAR(200), `APE` VARCHAR(200), `DIR` VARCHAR(300), `STAT` TINYINT, `FEC_NAC` DATE, `FEC_ING` DATE, `TEL` VARCHAR(10), `HAB` INT, `DIAG` INT, `MED` VARCHAR(20), OUT `RES` BIT)  BEGIN
CASE OPC
	WHEN 1 THEN
		INSERT INTO PACIENTES VALUES(EXPED,NOM,APE,DIR,STAT,FEC_NAC,FEC_ING,TEL,HAB,DIAG,MED,1);
		UPDATE HABITACIONES SET STATUS = 'O' WHERE NUMHABITACION = HAB;
		IF EXISTS(SELECT * FROM PACIENTES WHERE EXPEDIENTE = EXPED) THEN
			SELECT CONCAT("Se ingresó a ",SUBSTRING_INDEX(NOMBRE, ' ', 1)," ",SUBSTRING_INDEX(APELLIDOS, ' ', 1)," con el expediente no: ",EXPED, " en la habitación: ", NUMHABITACION) AS MSG, 1 AS RES FROM PACIENTES
            WHERE EXPEDIENTE = EXPED;
			SET RES = 1;
        ELSE
			SELECT "No se pudó registrar!" AS MSG, 0 AS RES;
			SET RES = 0;
		END IF;
	WHEN 2 THEN
		SELECT P.EXPEDIENTE, P.NOMBRE, P.APELLIDOS, COALESCE(D.DESCRIPCION,'') AS DESCRIPCION, P.FECHAINGRESO, CASE P.STATUS WHEN 1 THEN 'Sin Riesgo' WHEN 2 THEN 'Bajo Riesgo' WHEN 3 THEN 'Mediano Riesgo'
		WHEN 4 THEN 'Alto Riesgo' END AS ESTADO, NUMHABITACION FROM PACIENTES P LEFT JOIN DIAGNOSTICO D ON D.claveDiagnostico = P.claveDiagnostico
		WHERE (EXPED IS NULL OR EXPEDIENTE = EXPED) AND (NOM IS NULL OR NOMBRES LIKE CONCAT('%',NOM,'%')) AND (APE IS NULL OR APELLIDOS LIKE CONCAT('%',APE,'%')) AND
		(DIR IS NULL OR DIRECCION LIKE CONCAT('%',DIR,'%')) AND (STATUS IS NULL OR STATUS = STAT) AND (FEC_NAC IS NULL OR FECHANACIMIENTO = FEC_NAC) AND
		(FEC_ING IS NULL OR FECHAINGRESO = FEC_ING) AND (TEL IS NULL OR TELEFONO LIKE CONCAT('%',TEL,'%')) AND (HAB IS NULL OR NUMHABITACION = HAB) AND
		(DIAG IS NULL OR CLAVEDIAGNOSTICO = DIAG) AND (MED IS NULL OR MEDICO = MED);
		SET RES = 1;
	WHEN 3 THEN
		UPDATE PACIENTES SET DIAGNOSTICO = DIAG, STATUS = STAT, MEDICO = MED WHERE EXPEDIENTE = EXPED;
		IF EXISTS(SELECT * FROM PACIENTES WHERE EXPEDIENTE = EXPED AND DIAGNOSTICO = DIAG AND STATUS = STAT AND MEDICO = MED) THEN
			SELECT "Se actualizó correctamente!" AS MSG, 1 AS RES;
			SET RES = 1;
		ELSE
			SELECT "No se pudó actualizar!" AS MSG, 0 AS RES;
			SET RES = 0;
		END IF;
	WHEN 4 THEN
		UPDATE HABITACIONES SET STATUS = 'S' WHERE NUMHABITACION = (SELECT NUMHABITACION FROM PACIENTES WHERE EXPEDIENTE = EXPED);
		UPDATE PACIENTES SET ACTIVO = 0 WHERE EXPEDIENTE = EXPED;
        IF NOT EXISTS(SELECT * FROM PACIENTES WHERE EXPEDIENTE = EXPED AND ACTIVO = 1) THEN
			SELECT "Se realizó el alta correctamente!" AS MSG, 1 AS RES;
			SET RES = 1;
		ELSE
			SELECT "No se pudó realizar el alta correctamente!" AS MSG, 0 AS RES;
			SET RES = 0;
		END IF;
	ELSE
		SELECT "OPCIÓN NO VALIDA!" AS MSG, 3 AS RES;
		SET RES = 3;
END CASE;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_CRUD_USUARIOS` (`OPC` INT, `USERNAME` VARCHAR(30), `PASS` VARCHAR(32), `CREATE_DATE` DATE, `TIP` CHAR(1), OUT `RES` BIT)  BEGIN
CASE OPC
	WHEN 1 THEN
		INSERT INTO USUARIOS VALUES(USERNAME,MD5(PASS),CREATE_DATE,TIP);
		IF EXISTS(SELECT * FROM USUARIOS WHERE USUARIO = USERNAME) THEN
			SELECT CONCAT("Se el usuario: ",USUARIO) AS MSG, 1 AS RES FROM USUARIOS
            WHERE USUARIO = USERNAME;
			SET RES = 1;
        ELSE
			SELECT "No se pudó registrar!" AS MSG, 0 AS RES;
			SET RES = 0;
		END IF;
	WHEN 2 THEN
		SELECT USUARIO, CREACION, TIPO FROM USUARIO
		WHERE (USERNAME IS NULL OR USUARIO = USERNAME) AND (CREATE_DATE IS NULL OR CREACION = CREATE_DATE) AND (TIP IS NULL OR TIPO = TIP) AND (PASSWORD IS NULL OR PASSWORD = PASS);
		SET RES = 1;
	WHEN 3 THEN
		UPDATE USUARIOS SET PASSWORD = MD5(PASS), TIPO = TIP WHERE USUARIO = USERNAME AND PASSWORD = MD5(PASS);
		IF EXISTS(SELECT * FROM USUARIOS WHERE USUARIO = USERNAME AND TIPO = TIP AND PASSWORD = MD5(PASS)) THEN
			SELECT "Se actualizó correctamente!" AS MSG, 1 AS RES;
			SET RES = 1;
		ELSE
			SELECT "No se pudó actualizar!" AS MSG, 0 AS RES;
			SET RES = 0;
		END IF;
	WHEN 4 THEN
		DELETE FROM USUARIOS WHERE USUARIO = USERNAME;
        IF NOT EXISTS(SELECT * FROM USUARIOS WHERE USUARIO = USERNAME) THEN
			SELECT "Se eliminó correctamente!" AS MSG, 1 AS RES;
			SET RES = 1;
		ELSE
			SELECT "No se pudó eliminar el usuario!" AS MSG, 0 AS RES;
			SET RES = 0;
		END IF;
	ELSE
		SELECT "OPCIÓN NO VALIDA!" AS MSG, 3 AS RES;
		SET RES = 3;
END CASE;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `alergias`
--

CREATE TABLE `alergias` (
  `claveAlergia` int(11) NOT NULL,
  `tipo` varchar(50) NOT NULL,
  `descripcion` varchar(300) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `alergiaspaciente`
--

CREATE TABLE `alergiaspaciente` (
  `expediente` varchar(20) NOT NULL,
  `claveAlergia` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `diagnostico`
--

CREATE TABLE `diagnostico` (
  `claveDiagnostico` int(11) NOT NULL,
  `descripcion` varchar(300) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `diagnostico`
--

INSERT INTO `diagnostico` (`claveDiagnostico`, `descripcion`) VALUES
(1, 'prueba');

-- --------------------------------------------------------

--
-- Table structure for table `habitaciones`
--

CREATE TABLE `habitaciones` (
  `numHabitacion` int(11) NOT NULL,
  `status` char(1) NOT NULL,
  `descripcion` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `habitaciones`
--

INSERT INTO `habitaciones` (`numHabitacion`, `status`, `descripcion`) VALUES
(1, 'O', 'PRUEBA'),
(2, 'D', 'PRUEBA ACTUALIZACION');

-- --------------------------------------------------------

--
-- Table structure for table `medicos`
--

CREATE TABLE `medicos` (
  `cedula` varchar(20) NOT NULL,
  `nombre` varchar(200) NOT NULL,
  `apellidos` varchar(200) NOT NULL,
  `direccion` varchar(300) NOT NULL,
  `telefono` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `medicos`
--

INSERT INTO `medicos` (`cedula`, `nombre`, `apellidos`, `direccion`, `telefono`) VALUES
('1', 'Dr', 'Tachistosa', 'prueba', '2342465345');

-- --------------------------------------------------------

--
-- Table structure for table `pacientes`
--

CREATE TABLE `pacientes` (
  `expediente` varchar(20) NOT NULL,
  `nombre` varchar(200) NOT NULL,
  `apellidos` varchar(200) NOT NULL,
  `direccion` varchar(300) DEFAULT NULL,
  `status` tinyint(4) DEFAULT NULL,
  `fechaNacimiento` date NOT NULL,
  `fechaIngreso` date NOT NULL DEFAULT current_timestamp(),
  `telefono` varchar(10) DEFAULT NULL,
  `numHabitacion` int(11) NOT NULL,
  `claveDiagnostico` int(11) DEFAULT NULL,
  `medico` varchar(20) DEFAULT NULL,
  `activo` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `usuarios`
--

CREATE TABLE `usuarios` (
  `usuario` varchar(30) NOT NULL,
  `password` varchar(32) NOT NULL,
  `creacion` date NOT NULL DEFAULT current_timestamp(),
  `tipo` char(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `alergias`
--
ALTER TABLE `alergias`
  ADD PRIMARY KEY (`claveAlergia`);

--
-- Indexes for table `alergiaspaciente`
--
ALTER TABLE `alergiaspaciente`
  ADD PRIMARY KEY (`expediente`,`claveAlergia`),
  ADD KEY `FK_CVEALERGIA` (`claveAlergia`);

--
-- Indexes for table `diagnostico`
--
ALTER TABLE `diagnostico`
  ADD PRIMARY KEY (`claveDiagnostico`);

--
-- Indexes for table `habitaciones`
--
ALTER TABLE `habitaciones`
  ADD PRIMARY KEY (`numHabitacion`);

--
-- Indexes for table `medicos`
--
ALTER TABLE `medicos`
  ADD PRIMARY KEY (`cedula`);

--
-- Indexes for table `pacientes`
--
ALTER TABLE `pacientes`
  ADD PRIMARY KEY (`expediente`),
  ADD KEY `FK_MED` (`medico`),
  ADD KEY `FK_DIAG` (`claveDiagnostico`);

--
-- Indexes for table `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`usuario`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `alergias`
--
ALTER TABLE `alergias`
  MODIFY `claveAlergia` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `diagnostico`
--
ALTER TABLE `diagnostico`
  MODIFY `claveDiagnostico` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `alergiaspaciente`
--
ALTER TABLE `alergiaspaciente`
  ADD CONSTRAINT `FK_CVEALERGIA` FOREIGN KEY (`claveAlergia`) REFERENCES `alergias` (`claveAlergia`),
  ADD CONSTRAINT `FK_EXP` FOREIGN KEY (`expediente`) REFERENCES `pacientes` (`expediente`);

--
-- Constraints for table `pacientes`
--
ALTER TABLE `pacientes`
  ADD CONSTRAINT `FK_DIAG` FOREIGN KEY (`claveDiagnostico`) REFERENCES `diagnostico` (`claveDiagnostico`),
  ADD CONSTRAINT `FK_MED` FOREIGN KEY (`medico`) REFERENCES `medicos` (`cedula`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
