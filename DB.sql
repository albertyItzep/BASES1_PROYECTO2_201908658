CREATE SCHEMA IF NOT EXISTS proyecto2;
USE proyecto2;

CREATE TABLE IF NOT EXISTS CARRERA(
    idCarrera INTEGER AUTO_INCREMENT,
    nombreCarrera VARCHAR(50) NOT NULL,
    fechaHora datetime NOT NULL,
    PRIMARY KEY(idCarrera)
);

DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS agregarAreaComun()
BEGIN
    INSERT INTO CARRERA(idCarrera,nombreCarrera, fechaHora) VALUES(0,"Area Comun",NOW());
	update CARRERA set idCarrera = 0 where nombreCarrera = "Area Comun" and idCarrera = 1;
	ALTER TABLE CARRERA AUTO_INCREMENT =1;

END $$
DELIMITER ;

CALL agregarAreaComun();

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
    idCarrera INTEGER NOT NULL,
    obligatorio boolean NOT NULL DEFAULT 0,
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
    FOREIGN KEY(siifDocente) REFERENCES DOCENTE(siifDocente)
);

 CREATE TABLE IF NOT EXISTS HORARIO_CURSO(
    idHorarioCurso INTEGER AUTO_INCREMENT,
    dia INTEGER NOT NULL,
    horario VARCHAR(10) NOT NULL,
    fechaHora datetime NOT NULL,
    PRIMARY KEY(idHorarioCurso),
);

CREATE TABLE IF NOT EXISTS HORARIO_ASIGNADO(
    idHorarioAsignado INTEGER AUTO_INCREMENT,
    idHorarioCurso INTEGER NOT NULL,
    idHabilitado INTEGER NOT NULL,
    fechaHora datetime,
    PRIMARY KEY(idHorarioAsignado),
    FOREIGN KEY(idHorarioCurso) REFERENCES HORARIO_CURSO(idHorarioCurso),
    FOREIGN KEY(idHabilitado)  REFERENCES CURSO_HABILITADO(idHabilitado) 
);



CREATE TABLE IF NOT EXISTS ASIGNACION(
    idAsignacion INTEGER AUTO_INCREMENT,
    idHabilitado INTEGER NOT NULL,
    cicloEstudiantil VARCHAR(2) NOT NULL,
    carnetEstudiante BIGINT NOT NULL,
    fechaHora datetime NOT NULL,
    PRIMARY KEY(idAsignacion),
    FOREIGN KEY(idHabilitado) REFERENCES CURSO_HABILITADO(idHabilitado),
    FOREIGN KEY(carnetEstudiante) REFERENCES ESTUDIANTE(carnetEstudiante)
);

CREATE TABLE IF NOT EXISTS DESASIGNACION(
    idDesasignacion INTEGER AUTO_INCREMENT,
    cicloEstudiantil VARCHAR(2) NOT NULL,
    idHabilitado INTEGER NOT NULL,
    carnetEstudiante BIGINT NOT NULL,
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


-- procedimientos

-- CREAR CARRERA
use proyecto2;


DELIMITER $$
CREATE PROCEDURE crearCarrera(nombre varchar(50))
BEGIN
	declare contador INT;
  DECLARE soloLetras VARCHAR(18);
  SET soloLetras = '^[a-zA-Zaáéíóú ]+$';
  SELECT COUNT(*) INTO contador FROM CARRERA WHERE nombreCarrera = nombre;
	-- insertamos la carrera
  IF contador > 0 THEN
		SELECT "Carrera Existente" AS Resultado;
	ELSE
		IF nombre REGEXP soloLetras THEN
			INSERT INTO CARRERA(nombreCarrera, fechaHora) VALUES (nombre, NOW());
			SELECT "Carrera Creada Con Exito" AS Resultado;
		ELSE
			SELECT "Nombre de la carrera Incorrecta" AS Resultado;
		END IF;
	END IF;
END;
$$

DELIMITER ;


USE proyecto2;

-- PROCEDIMIENTO ALMACENADO PARA CREAR CURSO
DELIMITER $$

CREATE PROCEDURE crearCurso(codigoCurso INTEGER, nombre VARCHAR(100), creditosNecesarios INTEGER, creditosOtorgados INTEGER, idCarrera INTEGER,obligatorio BOOLEAN)
BEGIN 

    IF creditosNecesarios >= 0 THEN 
        IF creditosOtorgados >= 0 THEN
            INSERT INTO CURSO(codigoCurso, nombre, creditosNecesarios, creditosOtorgados,  idCarrera, obligatorio,fechaHora) 
            VALUES (codigoCurso, nombre, creditosNecesarios, creditosOtorgados,  idCarrera, obligatorio,NOW());
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

-- funcion para verificar si un curso existe
DELIMITER $$
CREATE FUNCTION verificarExisteCurso(codigoCursoI integer)
RETURNS BOOLEAN DETERMINISTIC
BEGIN
	DECLARE contador INTEGER;
    SELECT COUNT(*) INTO contador FROM CURSO WHERE codigoCurso = codigoCursoI;
    IF contador > 0 THEN
		RETURN TRUE;
	ELSE
		RETURN FALSE;
	END IF;
END $$
DELIMITER ;


USE proyecto2;

-- PROCEDIMIENTO PARA CREAR UN DOCENTE
DELIMITER $$
CREATE PROCEDURE registrarDocente(nombres varchar(100), apellidos VARCHAR(100),fechaNac varchar(10), correo varchar(50), telefono integer, direccion varchar(100), dpi bigint, siifDocente INTEGER)
BEGIN
	declare contador INT;
    DECLARE correoCorrecto VARCHAR(50);
    DECLARE fechaCorrecta DATE;
    SET correoCorrecto = '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$';
    SET fechaCorrecta = valFormatoFecha(fechaNac);
	IF correo REGEXP correoCorrecto THEN
		INSERT INTO DOCENTE(siifDocente , nombre, apellido,fechaNacimiento, correo, telefono, direccion, dpiDocente, fechaHora) VALUES (siifDocente, nombres, apellidos, fechaCorrecta, correo, telefono, direccion, dpi, now());
            SELECT 1 AS Resultado;
	ELSE 
			SELECT "FORMATO DE CORREO INCORRECTO" AS Resultado;
	END IF;
END;
$$

DELIMITER ;


-- funcion para validar que existe un docente
DELIMITER $$
CREATE FUNCTION validarExisteDocente(docente integer)
RETURNS BOOLEAN DETERMINISTIC
BEGIN
	DECLARE contador INTEGER;
    SELECT COUNT(*) INTO contador FROM DOCENTE WHERE siifDocente = docente;
    IF contador > 0 THEN
		RETURN TRUE;
	ELSE 
		RETURN FALSE;
	END IF;
END $$
DELIMITER ;


DELIMITER $$
CREATE FUNCTION valFormatoFecha(fecha varchar(10))
RETURNS DATE DETERMINISTIC
BEGIN
	DECLARE fechaReordenada DATE;

  IF fecha REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$' AND STR_TO_DATE(fecha, '%d-%m-%Y') IS NOT NULL THEN
    SET fechaReordenada = STR_TO_DATE(fecha, '%d-%m-%Y');
  ELSE
    SET fechaReordenada = STR_TO_DATE(fecha, '%d-%m-%Y');
  END IF;

    RETURN fechaReordenada;

END $$
DELIMITER ;


USE proyecto2;

-- PROCEDIMIENTO PARA CREAR UN ESTUDIANTE
DELIMITER $$
CREATE PROCEDURE registrarEstudiante(carnet bigint,nombres varchar(100), apellidos VARCHAR(100),fechaNac varchar(10), correo varchar(50), telefono integer, direccion varchar(100), dpi bigint, idCarrera integer)
BEGIN
	declare contador INT;
    DECLARE soloLetras VARCHAR(18);
    DECLARE correoCorrecto VARCHAR(50);
    DECLARE fechaCorrecta DATE;
    SET fechaCorrecta = valFormatoFecha(fechaNac);
    SET correoCorrecto = '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$';
	IF correo REGEXP correoCorrecto THEN
    	INSERT INTO ESTUDIANTE(carnetEstudiante, nombre, apellido,fechaNacimiento, correo, telefono, direccion, dpiEstudiante, creditos, idCarrera, fechaHora) VALUES (carnet, nombres, apellidos, fechaCorrecta, correo, telefono, direccion, dpi, 0,idCarrera, now());
        SELECT 1 AS Resultado;
	ELSE 
	    SELECT 0 AS Resultado;
	END IF;  
END;
$$

DELIMITER ;


DELIMITER $$
CREATE FUNCTION verificarEstudiante(carnet bigint)
returns boolean DETERMINISTIC
BEGIN
    DECLARE contador INTEGER;
    SELECT COUNT(*) INTO contador FROM ESTUDIANTE WHERE carnetEstudiante = carnet;
    IF contador > 0 THEN
        RETURN TRUE;
    ELSE 
        RETURN FALSE;
    END IF;
END $$
DELIMITER ;

USE proyecto2;

-- procedure para realizar la habilitacion de un curso dentro de la base de datos
DELIMITER $$
CREATE PROCEDURE habilitarCurso(curso integer, ciclo varchar(2), docente integer, cupoMax integer, seccionI varchar(1))
BEGIN
  -- validaciones
  DECLARE valCurso, valCiclo, valDocente BOOLEAN;
  DECLARE valSeccion INTEGER;
  SET valCurso = verificarExisteCurso(curso);
  SET valCiclo = validarCiclo(ciclo);
  SET valDocente = validarExisteDocente(docente);
  SELECT COUNT(*) INTO valSeccion FROM CURSO_HABILITADO WHERE codigoCurso = curso AND seccion = seccionI; 
  
  IF valSeccion = 0 THEN
    IF valCurso THEN
      IF valCiclo THEN
        IF valDocente THEN
          INSERT INTO CURSO_HABILITADO(codigoCurso,cicloEstudiantil,siifDocente,cupoMaximo,seccion,fechaHora) VALUES (curso,ciclo,docente,cupoMaximo,seccionI,NOW());
          SELECT "CURSO HABILITADO EXITOSAMENTE" AS Resultado;
        ELSE
          SELECT "DOCENTE INEXISTENTE" AS Resultado;
        END IF;
      ELSE
        SELECT "FORMATO DE CICLO INCORRECTO" AS Resultado;
      END IF;
    ELSE
     SELECT "NO EXISTE CURSO CON EL CODIGO INGRESADO" AS Resultado;
    END IF;
  ELSE
     SELECT "Curso Habilitado anteriormente" AS Resultado;
  END IF;
END;
$$

DELIMITER ;

-- FUNCION PARA VALIDAR LA SECCION DE UN CURSO
DELIMITER $$
CREATE FUNCTION validarSeccion(curso integer, seccionI varchar(1))
RETURNS BOOLEAN DETERMINISTIC
BEGIN
	DECLARE contador INTEGER;
    SELECT COUNT(*) INTO contador FROM SECCION WHERE idHabilitado = curso AND seccion = seccionI;
    IF NOT(contador = 0) THEN
		RETURN TRUE;
    ELSE
		RETURN FALSE;
    END IF;
END $$
DELIMITER ;

-- funcion para validar que el ciclo que este ingresando sea correcto
DELIMITER $$
CREATE FUNCTION validarCiclo(ciclo VARCHAR(2))
RETURNS BOOLEAN DETERMINISTIC
BEGIN
	IF ciclo IN ("1S", "2S", "VJ", "VD") THEN
		RETURN TRUE;
	ELSE
		RETURN FALSE;
	END IF;
END $$
DELIMITER ;

-- Funcion para validar que existe el curso en la tabla habilitados
DELIMITER $$
CREATE FUNCTION validarHabilitado(id integer)
RETURNS BOOLEAN DETERMINISTIC
BEGIN
	DECLARE contador integer;
    SELECT COUNT(*) INTO contador FROM CURSO_HABILITADO WHERE idHabilitado = id;
    IF contador > 0 THEN
		RETURN TRUE;
    ELSE
		RETURN FALSE;
    END IF;
END $$
DELIMITER ;


USE proyecto2;

DELIMITER $$
CREATE PROCEDURE agregarHorario(idHabilitadoI INTEGER, dia integer, horario varchar(11))
BEGIN
  DECLARE contador,idHorarioI INTEGER;
  DECLARE valHabilitado BOOLEAN; 
  DECLARE regHorario varchar(50);
  SET regHorario = '^[0-9][0-9]?:[0-9][0-9]-[0-9][0-9]?:[0-9][0-9]$';
  SET idHorarioI = verificarExisteHorario(dia, horario);
  SET valHabilitado = validarHabilitado(idHabilitadoI); 
  SELECT COUNT(*) INTO contador FROM HORARIO_ASIGNADO WHERE idHabilitado = idHabilitadoI AND idHorarioCurso = idHorarioI;
  
  If valHabilitado THEN
    if contador > 0 THEN
      SELECT "HORARIO YA SE ENCUENTRA ASIGNADO" AS RESULTADO;
    ELSE
      IF dia<8 AND dia>0 THEN
        IF horario REGEXP regHorario THEN
          INSERT INTO HORARIO_ASIGNADO(idHorarioCurso,idHabilitado,fechaHora) VALUES (idHorarioI,idHabilitadoI,NOW());
          SELECT "HORARIO ASIGNADO CORRECTAMENTE" AS Resultado;
        ELSE 
          SELECT "FORMATO HORARIO INCORRECTO" AS Resultado;
        END IF;
      ELSE
        SELECT "PARAMETRO DIA INCORRECTO" AS Resultado;
      END IF;
    END IF;
  ELSE
    SELECT "CURSO NO HABILITADO" AS Resultado;
  END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION verificarExisteHorario(diaI integer, horarioI varchar(11))
RETURNS INTEGER DETERMINISTIC
BEGIN
  DECLARE contador, id INTEGER;
  SELECT COUNT(*) INTO contador FROM HORARIO_CURSO WHERE dia = diaI AND horario = horarioI;
  IF contador > 0 THEN 
    select idHorarioCurso INTO id from HORARIO_CURSO WHERE dia = diaI AND horario = horarioI;
    RETURN id;
  ELSE
    INSERT INTO HORARIO_CURSO(dia, horario,fechaHora) VALUES (dia, horario,NOW());
    RETURN LAST_INSERT_ID();
  END IF;
END $$
DELIMITER ;

USE proyecto2;

DELIMITER $$
CREATE PROCEDURE asignarCurso(curso integer, cicloI varchar(2), seccionI varchar(1), carnet bigint)
BEGIN
	DECLARE valCurso BOOL;
    DECLARE valEstudiante BOOL;
    DECLARE valCiclo BOOL;
    DECLARE contador ,idHab INTEGER;
    SET valCurso = verificarExisteCurso(curso);
    SET valEstudiante = verificarEstudiante(carnet);
    SET valCiclo = validarCiclo(cicloI);
    
    IF valCurso THEN
		IF valEstudiante THEN
			IF valCiclo THEN
				SELECT COUNT(*) INTO contador FROM CURSO_HABILITADO WHERE codigoCurso = curso AND seccion = seccionI AND ciclo = cicloI;
                IF contador > 0 THEN 
					SELECT idHabilitado INTO idHab FROM CURSO_HABILITADO WHERE codigoCurso = curso AND seccion = seccionI AND ciclo = cicloI;
					INSERT INTO ASIGNACION(idHabilitado,cicloEstudiantil, carnetEstudiante,fechaHora) VALUES(idHab,cicloI,carnet,NOW());
                ELSE
					SELECT "CURSO NO SE ENCUENTRA HABILITADO" AS Resultado;
                END IF;
            ELSE
				SELECT "FORMATO CICLO INCORRECTO" AS Resultado;
            END IF;
        ELSE
			SELECT "ESTUDIANTE INEXISTENTE" AS Resultado;
        END IF;
    ELSE
		SELECT "CURSO INEXISTENTE" AS Resultado;
    END IF;
END;
$$
DELIMITER ;

-- Consultas
-- consulta pensum
DELIMITER $$
CREATE PROCEDURE consultarPensum(carrera integer)
BEGIN
    SELECT codigoCurso,nombre,creditosNecesarios,obligatorio FROM CURSO WHERE idCarrera = carrera;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE consultarEstudiante(carnet BIGINT)
BEGIN
SELECT carnetEstudiante,CONCAT(nombre," ",apellido),fechaNacimiento,correo, telefono,direccion,dpiEstudiante,creditos,idCarrera FROM ESTUDIANTE WHERE carnetEstudiante = carnet;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE consultarDocente(codigo BIGINT)
BEGIN
    select siifDocente, CONCAT(nombre," ",apellido), fechaNacimiento,correo,telefono,direccion,dpiDocente from DOCENTE WHERE siifDocente = codigo;
END $$
DELIMITER ;

-- DATOS INGRESADOS EN LA BASE

-- REGISTRO DE CARRERAS
CALL crearCarrera('Ingenieria Civil');       -- 1  VALIDAR QUE LES QUEDE ESTE ID EN LA CARRERA CORRESPONDIENTE
CALL crearCarrera('Ingenieria Industrial');  -- 2  VALIDAR QUE LES QUEDE ESTE ID EN LA CARRERA CORRESPONDIENTE
CALL crearCarrera('Ingenieria Sistemas');    -- 3  VALIDAR QUE LES QUEDE ESTE ID EN LA CARRERA CORRESPONDIENTE
CALL crearCarrera('Ingenieria Electronica'); -- 4  VALIDAR QUE LES QUEDE ESTE ID EN LA CARRERA CORRESPONDIENTE
CALL crearCarrera('Ingenieria Mecanica');    -- 5  VALIDAR QUE LES QUEDE ESTE ID EN LA CARRERA CORRESPONDIENTE
CALL crearCarrera('Ingenieria Mecatronica'); -- 6  VALIDAR QUE LES QUEDE ESTE ID EN LA CARRERA CORRESPONDIENTE
CALL crearCarrera('Ingenieria Quimica');     -- 7  VALIDAR QUE LES QUEDE ESTE ID EN LA CARRERA CORRESPONDIENTE
CALL crearCarrera('Ingenieria Ambiental');   -- 8  VALIDAR QUE LES QUEDE ESTE ID EN LA CARRERA CORRESPONDIENTE
CALL crearCarrera('Ingenieria Materiales');  -- 9  VALIDAR QUE LES QUEDE ESTE ID EN LA CARRERA CORRESPONDIENTE
CALL crearCarrera('Ingenieria Textil');      -- 10 VALIDAR QUE LES QUEDE ESTE ID EN LA CARRERA CORRESPONDIENTE

-- REGISTRO DE DOCENTES
CALL registrarDocente('Docente1','Apellido1','30-10-1999','aadf@ingenieria.usac.edu.gt',12345678,'direccion',12345678910,1);
CALL registrarDocente('Docente2','Apellido2','20-11-1999','docente2@ingenieria.usac.edu.gt',12345678,'direcciondocente2',12345678911,2);
CALL registrarDocente('Docente3','Apellido3','20-12-1980','docente3@ingenieria.usac.edu.gt',12345678,'direcciondocente3',12345678912,3);
CALL registrarDocente('Docente4','Apellido4','20-11-1981','docente4@ingenieria.usac.edu.gt',12345678,'direcciondocente4',12345678913,4);
CALL registrarDocente('Docente5','Apellido5','20-09-1982','docente5@ingenieria.usac.edu.gt',12345678,'direcciondocente5',12345678914,5);

-- REGISTRO DE ESTUDIANTES
-- SISTEMAS
CALL registrarEstudiante(202000001,'Estudiante de','Sistemas Uno','30-10-1999','sistemasuno@gmail.com',12345678,'direccion estudiantes sistemas 1',337859510101,3);
CALL registrarEstudiante(202000002,'Estudiante de','Sistemas Dos','3-5-2000','sistemasdos@gmail.com',12345678,'direccion estudiantes sistemas 2',32781580101,3);
CALL registrarEstudiante(202000003,'Estudiante de','Sistemas Tres','3-5-2002','sistemastres@gmail.com',12345678,'direccion estudiantes sistemas 3',32791580101,3);
-- CIVIL
CALL registrarEstudiante(202100001,'Estudiante de','Civil Uno','3-5-1990','civiluno@gmail.com',12345678,'direccion de estudiante civil 1',3182781580101,1);
CALL registrarEstudiante(202100002,'Estudiante de','Civil Dos','03-08-1998','civildos@gmail.com',12345678,'direccion de estudiante civil 2',3181781580101,1);
-- INDUSTRIAL
CALL registrarEstudiante(202200001,'Estudiante de','Industrial Uno','30-10-1999','industrialuno@gmail.com',12345678,'direccion de estudiante industrial 1',3878168901,2);
CALL registrarEstudiante(202200002,'Estudiante de','Industrial Dos','20-10-1994','industrialdos@gmail.com',89765432,'direccion de estudiante industrial 2',29781580101,2);
-- ELECTRONICA
CALL registrarEstudiante(202300001, 'Estudiante de','Electronica Uno','20-10-2005','electronicauno@gmail.com',89765432,'direccion de estudiante electronica 1',29761580101,4);
CALL registrarEstudiante(202300002, 'Estudiante de','Electronica Dos', '01-01-2008','electronicados@gmail.com',12345678,'direccion de estudiante electronica 2',387916890101,4);
-- ESTUDIANTES RANDOM
CALL registrarEstudiante(201710160, 'ESTUDIANTE','SISTEMAS RANDOM','20-08-1994','estudiasist@gmail.com',89765432,'direccionestudisist random',29791580101,3);
CALL registrarEstudiante(201710161, 'ESTUDIANTE','CIVIL RANDOM','20-08-1995','estudiacivl@gmail.com',89765432,'direccionestudicivl random',30791580101,1);


-- AREA COMUN
CALL crearCurso(0006,'Idioma Tecnico 1',0,7,0,false); 
CALL crearCurso(0007,'Idioma Tecnico 2',0,7,0,false);
CALL crearCurso(101,'MB 1',0,7,0,true); 
CALL crearCurso(103,'MB 2',0,7,0,true); 
CALL crearCurso(017,'SOCIAL HUMANISTICA 1',0,4,0,true); 
CALL crearCurso(019,'SOCIAL HUMANISTICA 2',0,4,0,true); 
CALL crearCurso(348,'QUIMICA GENERAL',0,3,0,true); 
CALL crearCurso(349,'QUIMICA GENERAL LABORATORIO',0,1,0,true);
-- INGENIERIA EN SISTEMAS
CALL crearCurso(777,'Compiladores 1',80,4,3,true); 
CALL crearCurso(770,'INTR. A la Programacion y computacion 1',0,4,3,true); 
CALL crearCurso(960,'MATE COMPUTO 1',33,5,3,true); 
CALL crearCurso(795,'lOGICA DE SISTEMAS',33,2,3,true);
CALL crearCurso(796,'LENGUAJES FORMALES Y DE PROGRAMACIÓN',0,3,3,TRUE);
-- INGENIERIA INDUSTRIAL
CALL crearCurso(123,'Curso Industrial 1',0,4,2,true); 
CALL crearCurso(124,'Curso Industrial 2',0,4,2,true);
CALL crearCurso(125,'Curso Industrial enseñar a pensar',10,2,2,false);
CALL crearCurso(126,'Curso Industrial ENSEÑAR A DIBUJAR',2,4,2,true);
CALL crearCurso(127,'Curso Industrial 3',8,4,2,true);
-- INGENIERIA CIVIL
CALL crearCurso(321,'Curso Civil 1',0,4,1,true);
CALL crearCurso(322,'Curso Civil 2',4,4,1,true);
CALL crearCurso(323,'Curso Civil 3',8,4,1,true);
CALL crearCurso(324,'Curso Civil 4',12,4,1,true);
CALL crearCurso(325,'Curso Civil 5',16,4,1,false);
CALL crearCurso(0250,'Mecanica de Fluidos',0,5,1,true);
-- INGENIERIA ELECTRONICA
CALL crearCurso(421,'Curso Electronica 1',0,4,4,true);
CALL crearCurso(422,'Curso Electronica 2',4,4,4,true);
CALL crearCurso(423,'Curso Electronica 3',8,4,4,false);
CALL crearCurso(424,'Curso Electronica 4',12,4,4,true);
CALL crearCurso(425,'Curso Electronica 5',16,4,4,true);