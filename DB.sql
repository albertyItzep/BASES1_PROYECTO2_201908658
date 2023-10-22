CREATE SCHEMA proyecto2;
USE proyecto2;

CREATE TABLE IF NOT EXISTS CARRERA(
    idCarrera INTEGER AUTO_INCREMENT,
    nombreCarrera VARCHAR(50) NOT NULL,
    fechaHora datetime NOT NULL
    PRIMARY KEY(idCarrera)
);

CREATE TABLE IF NOT EXISTS  DOCENTE(
    siifDocente INTEGER,
    nombre	varchar(100) not null,
    apellido varchar(100) not null,
    fechaNacimiento DATE,
    correo varchar(50) not null,
    telefono varchar(10) not null,
    direccion varchar(100) not null,
    dpiDocente BIGINT not null,
    fechaHora datetime NOT NULL,
    PRIMARY KEY(siifDocente)
);

CREATE TABLE IF NOT EXISTS CURSO(
    codigoCurso INTEGER,
    nombre VARCHAR(100) NOT NULL,
    creditosNecesarios INTEGER NOT NULL,
    creditosOtorgados INTEGER NOT NULL,
    obligatorio boolean NOT NULL DEFAULT 0,
    idCarrera INTEGER NOT NULL,
    fechaHora datetime NOT NULL,
    PRIMARY KEY(codigoCurso),
    FOREIGN KEY(idCarrera) REFERENCES CARRERA(idCarrera)
);

CREATE TABLE IF NOT EXISTS ESTUDIANTE(
    carnetEstudiante BIGINT,
    nombre	varchar(100) not null,
    apellido varchar(100) not null,
    fechaNacimiento DATE,
    correo varchar(50) not null,
    telefono varchar(10) not null,
    direccion varchar(100) not null,
    dpiEstudiante BIGINT not null,
    creditos INTEGER NOT NULL,
    idCarrera INTEGER NOT NULL,
    fechaHora datetime NOT NULL,
    PRIMARY KEY(carnetEstudiante),
    FOREIGN KEY(idCarrera) REFERENCES CARRERA(idCarrera)
);

CREATE TABLE IF NOT EXISTS CURSO_HABILITADO(
    idHabilitado INTEGER AUTO_INCREMENT,
    codigoCurso INTEGER NOT NULL,
    cicloEstudiantil VARCHAR(2) NOT NULL,
    siifDocente INTEGER NOT NULL,
    cupoMaximo INTEGER NOT NULL,
    seccion VARCHAR(1) NOT NULL,
    fechaHora datetime NOT NULL,
    PRIMARY KEY(idHabilitado),
    FOREIGN KEY(codigoCurso) REFERENCES CURSO(codigoCurso),
    FOREIGN KEY(siifDocente) REFERENCES DOCENTE(siifDocente),
);

CREATE TABLE IF NOT EXISTS HORARIO_CURSO(
    idHorario INTEGER AUTO_INCREMENT,
    idHabilitado INTEGER NOT NULL,
    dia INTEGER NOT NULL,
    horario VARCHAR(10) NOT NULL,
    PRIMARY KEY(idHorario),
    FOREIGN KEY(idHabilitado) REFERENCES CURSO_HABILITADO(idHabilitado)
);

CREATE TABLE IF NOT EXISTS ASIGNACION(
    idAsignacion INTEGER AUTO_INCREMENT,
    idHabilitado INTEGER NOT NULL,
    cicloEstudiantil VARCHAR(2) NOT NULL,
    carnetEstudiante INTEGER NOT NULL,
    fechaHora datetime NOT NULL,
    PRIMARY KEY(idAsignacion),
    FOREIGN KEY(idHabilitado) REFERENCES CURSO_HABILITADO(idHabilitado),
    FOREIGN KEY(carnetEstudiante) REFERENCES ESTUDIANTE(carnetEstudiante)
);

CREATE TABLE IF NOT EXISTS DESASIGNACION(
    idDesasignacion INTEGER AUTO_INCREMENT,
    cicloEstudiantil VARCHAR(2) NOT NULL,
    idHabilitado INTEGER NOT NULL,
    carnetEstudiante INTEGER NOT NULL,
    fechaHora datetime NOT NULL,
    PRIMARY KEY(idDesasignacion),
    FOREIGN KEY(idHabilitado) REFERENCES CURSO_HABILITADO(idHabilitado),
    FOREIGN KEY(carnetEstudiante) REFERENCES ESTUDIANTE(carnetEstudiante)
);

CREATE TABLE IF NOT EXISTS NOTA(
    idNota INTEGER AUTO_INCREMENT,
    cicloEstudiantil VARCHAR(2) NOT NULL,
    nota INTEGER NOT NULL,
    aprobado boolean NOT NULL,
    idAsignacion INTEGER NOT NULL,
    fechaHora datetime NOT NULL,
    PRIMARY KEY(idNota),
    FOREIGN KEY(idAsignacion) REFERENCES ASIGNACION(idAsignacion)
);

CREATE TABLE IF NOT EXISTS HISTORIAL(
    idHistorico INTEGER AUTO_INCREMENT,
    fechaHora datetime NOT NULL,
    descripcion varchar(100) NOT NULL,
    tipi VARCHAR(10) NOT NULL,
    PRIMARY KEY(idHistorico)
);

-- Procedimientos almacenados

--Procedimiento para crear carreras valida si una carrera existe, si no la crea
DELIMITER $$
CREATE PROCEDURE crearCarrera(nombre varchar(50))
BEGIN
	declare contador INT;
    DECLARE soloLetras VARCHAR(18);
    SET soloLetras = '^[a-zA-Zaáéíóú ]+$';
    SELECT COUNT(*) INTO contador FROM CARRERA WHERE nombreCarrera = nombre;
    IF contador > 0 THEN
		SELECT 0 AS Resultado;
	ELSE
		IF nombre REGEXP soloLetras THEN
			INSERT INTO CARRERA(nombreCarrera, fechaHora) VALUES (nombre, NOW());
			SELECT 1 AS Resultado;
		ELSE
			SELECT 0 AS Resultado;
		END IF;
	END IF;
END;
$$

DELIMITER ;

--PROCEDIMIENTO PARA CREAR UN ESTUDIANTE
DELIMITER $$
CREATE PROCEDURE crearEstudiante(carnet bigint,nombres varchar(100), apellidos VARCHAR(100),fechaNac date, correo varchar(50), telefono integer, direccion varchar(100), dpi bigint, idCarrera integer)
BEGIN
	declare contador INT;
    DECLARE soloLetras VARCHAR(18);
    DECLARE correoCorrecto VARCHAR(50);
    SET soloLetras = '^[a-zA-Zaáéíóú ]+$';
    SET correoCorrecto = '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$';
    IF nombres regexp soloLetras THEN
		IF apellidos REGEXP soloLetras THEN
			IF correo REGEXP correoCorrecto THEN
				INSERT INTO ESTUDIANTE(carnetEstudiante, nombre, apellido,fechaNacimiento, correo, telefono, direccion, dpiEstudiante, creditos, idCarrera, fechaHora) VALUES (carnet, nombres, apellidos, fechaNac, correo, telefono, direccion, dpi, 0,idCarrera, now());
                SELECT 1 AS Resultado;
			ELSE 
				SELECT 0 AS Resultado;
			END IF;
        ELSE
        SELECT 0 AS Resultado;
        END IF;
    ELSE 
		SELECT 0 AS Resultado;
    END IF;
END;
$$

DELIMITER ;

--PROCEDIMIENTO PARA CREAR UN DOCENTE
DELIMITER $$
CREATE PROCEDURE crearDocente(nombres varchar(100), apellidos VARCHAR(100),fechaNac date, correo varchar(50), telefono integer, direccion varchar(100), dpi bigint, siifDocente INTEGER)
BEGIN
	declare contador INT;
    DECLARE soloLetras VARCHAR(18);
    DECLARE correoCorrecto VARCHAR(50);
    SET soloLetras = '^[a-zA-Zaáéíóú ]+$';
    SET correoCorrecto = '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$';
    IF nombres regexp soloLetras THEN
		IF apellidos REGEXP soloLetras THEN
			IF correo REGEXP correoCorrecto THEN
				INSERT INTO DOCENTE(siifDocente , nombre, apellido,fechaNacimiento, correo, telefono, direccion, dpiDocente, fechaHora) VALUES (siifDocente, nombres, apellidos, fechaNac, correo, telefono, direccion, dpi, now());
                SELECT 1 AS Resultado;
			ELSE 
				SELECT 0 AS Resultado;
			END IF;
        ELSE
        SELECT 0 AS Resultado;
        END IF;
    ELSE 
		SELECT 0 AS Resultado;
    END IF;
END;
$$

DELIMITER ;

--PROCEDIMIENTO ALMACENADO PARA CREAR CURSO
DELIMITER $$

CREATE PROCEDURE crearCurso(codigoCurso INTEGER, nombre VARCHAR(100), creditosNecesarios INTEGER, creditosOtorgados INTEGER, obligatorio BOOLEAN, idCarrera INTEGER)
BEGIN 

    IF creditosNecesarios >= 0 THEN 
        IF creditosOtorgados >= 0 THEN
            INSERT INTO CURSO(codigoCurso, nombre, creditosNecesarios, creditosOtorgados, obligatorio, idCarrera, fechaHora) 
            VALUES (codigoCurso, nombre, creditosNecesarios, creditosOtorgados, obligatorio, idCarrera, NOW());
            SELECT 1 AS Resultado;
        ELSE
            SELECT 0 AS Resultado;
        END IF;
    ELSE 
        SELECT 0 AS Resultado;
    END IF;

END;
$$

DELIMITER ;