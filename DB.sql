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
    yearH INTEGER NOT NULL,
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
    PRIMARY KEY(idHorarioCurso)
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

CREATE TABLE IF NOT EXISTS CONTROL_ASIGNACION (
    idControlAsignados INTEGER AUTO_INCREMENT,
    idHabilitado INTEGER NOT NULL,
    cantidadAsignados INTEGER NOT NULL,
    PRIMARY KEY(idControlAsignados),
    FOREIGN KEY(idHabilitado) REFERENCES CURSO_HABILITADO(idHabilitado)
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

CREATE TABLE IF NOT EXISTS ACTA(
  idActa INTEGER AUTO_INCREMENT,
  codigoCurso INTEGER NOT NULL,
  ciclo VARCHAR(2) NOT NULL,
  seccion varchar(1) NOT NULL,
  fechaHora DATETIME NOT NULL,
  PRIMARY KEY(idActa)
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
          IF cupoMax > 0 THEN
            INSERT INTO CURSO_HABILITADO(codigoCurso,cicloEstudiantil,siifDocente,cupoMaximo,seccion,yearH,fechaHora) VALUES (curso,ciclo,docente,cupoMax,seccionI,CAST(YEAR(NOW()) AS SIGNED));
            SELECT "CURSO HABILITADO EXITOSAMENTE" AS Resultado;
          ELSE
            SELECT "CUPO MAXIMO INCORRECTO" AS Resultado;
          END IF;
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

DELIMITER $$ 
CREATE FUNCTION validarHabilitadoSeccion(curso integer, seccionI varchar(1))
RETURNS BOOLEAN DETERMINISTIC
BEGIN
  DECLARE contador integer;
  SELECT COUNT(*) INTO contador FROM CURSO_HABILITADO WHERE codigoCurso = curso AND seccion = seccionI;
  IF contador > 0 THEN
    RETURN TRUE;
  ELSE 
    RETURN FALSE;
  END IF;
END $$
DELIMITER ;

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

DELIMITER $$
CREATE PROCEDURE asignarCurso(curso integer, cicloI varchar(2), seccionI varchar(1), carnet bigint)
BEGIN
	DECLARE valCurso BOOLEAN;
    DECLARE valEstudiante,valCarrera,valCup BOOLEAN;
    DECLARE valCiclo,asignado,creditosNecesarios BOOLEAN;
    DECLARE contador ,idHab INTEGER;
    -- verificar el curso
    SET valCurso = verificarExisteCurso(curso);
    -- verificar el estudiante
    SET valEstudiante = verificarEstudiante(carnet);
    -- verificar el ciclo
    SET valCiclo = validarCiclo(cicloI);


    SET asignado =  validarAsignaciones(carnet, curso);
    SET creditosNecesarios = validarCreditos(carnet, curso);
    SET valCarrera = validarCarrera(carnet, curso);
    SET valCup = validarCupos(idHab);
    -- OTRAS VALIDACIONES
    -- no se encuentre asignado al curso
    -- creditos necesarios
    -- pertenezca a su carrera o area comun
    -- seccion elegida existe
    -- tenga aun cupo

    IF valCurso THEN
      IF valEstudiante THEN
        IF valCiclo THEN
            SELECT COUNT(*) INTO contador FROM CURSO_HABILITADO WHERE codigoCurso = curso AND seccion = seccionI AND cicloEstudiantil = cicloI;
            SELECT idHabilitado INTO idHab FROM CURSO_HABILITADO WHERE codigoCurso = curso AND seccion = seccionI AND cicloEstudiantil = cicloI;
            IF contador > 0 THEN
              -- VALIDAMOS SI EL ESTUDIANTE YA ESTA ASIGNADO
              IF NOT(asignado) THEN
                -- VALIDAMOS QUE TENGA LOS CREDITOS NECESARIOS
                IF creditosNecesarios THEN
                  IF valCarrera THEN
                    IF valCup THEN
                       INSERT INTO ASIGNACION(idHabilitado,cicloEstudiantil, carnetEstudiante,fechaHora) VALUES(idHab,cicloI,carnet,NOW());                
                    ELSE 
                      SELECT "NO SE PUEDE ASIGNAR: NO HAY CUPOS LIBRES" AS Resultado;
                    END IF;
                  ELSE
                    SELECT "NO SE PUEDE ASIGNAR: NO PERTENECE A SU PENSUM" AS Resultado;
                  END IF;
                ELSE
                  SELECT "NO SE PUEDE ASIGNAR: CREDITOS INSUFICIENTES" AS Resultado;
                END IF;
              ELSE
                SELECT "NO SE PUEDE ASIGNAR: CURSO ASIGNADO" AS Resultado;
              END IF;
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

DELIMITER $$
CREATE FUNCTION validarAsignaciones(carnet integer, curso integer)
RETURNS BOOLEAN DETERMINISTIC
BEGIN
  DECLARE contador INTEGER;
  SELECT COUNT(carnetEstudiante) INTO contador FROM ASIGNACION AS asi JOIN CURSO_HABILITADO AS ch  ON ch.codigoCurso = curso AND asi.carnetEstudiante = carnet AND asi.yearH = CAST(YEAR(NOW()) AS SIGNED);
  IF contador > 0 THEN
    RETURN TRUE;
  ELSE 
    RETURN FALSE;
  END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION validarCreditos(carnet integer, curso integer)
RETURNS BOOLEAN DETERMINISTIC
BEGIN
  DECLARE cursoC,creditosEstudiante INTEGER;
  SELECT creditosNecesarios INTO cursoC FROM CURSO WHERE codigoCurso = curso;
  SELECT creditos INTO creditosEstudiante FROM ESTUDIANTE WHERE carnetEstudiante = carnet;
  
  IF creditosEstudiante >= cursoC THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION validarCarrera(carnet integer, curso integer)
RETURNS BOOLEAN DETERMINISTIC
BEGIN
  DECLARE cursoC, estudiante INTEGER;
  SELECT idCarrera INTO cursoC FROM CURSO WHERE codigoCurso = curso;
  SELECT idCarrera INTO estudiante FROM ESTUDIANTE WHERE carnetEstudiante = carnet;

  IF cursoC = 0 THEN
    RETURN TRUE;
  ELSE
    IF cursoC = estudiante THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END IF; 
END $$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION validarCupos(idCursoH INT)
RETURNS BOOLEAN DETERMINISTIC
BEGIN
  DECLARE contador, habilitado INT;
  SELECT cantidadAsignados INTO contador FROM CONTROL_ASIGNACION WHERE idHabilitado = idCursoH;
  SELECT cupoMaximo INTO habilitado FROM CURSO_HABILITADO WHERE idHabilitado = idCursoH;

  IF contador < habilitado OR contador IS NULL THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END $$
DELIMITER ;

DELIMITER $$ 
CREATE TRIGGER insertControlAsignacion
BEFORE INSERT ON ASIGNACION
FOR EACH ROW
BEGIN
  DECLARE curso_id INTEGER;
  SET curso_id = NEW.idHabilitado;

  IF EXISTS(SELECT 1 FROM CONTROL_ASIGNACION WHERE idHabilitado = curso_id) THEN
    UPDATE CONTROL_ASIGNACION SET cantidadAsignados = cantidadAsignados +1 WHERE idHabilitado = curso_id;
  ELSE 
    INSERT INTO CONTROL_ASIGNACION(idHabilitado,cantidadAsignados) VALUES (curso_id, 1);
  END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION obtenerAsignacion(curso integer, cicloI varchar(2),seccionI varchar(1), carnet bigint)
RETURNS INTEGER DETERMINISTIC
BEGIN 
  DECLARE idVal,idHab INTEGER;
  SELECT idHabilitado INTO idHab FROM CURSO_HABILITADO WHERE codigoCurso = curso AND seccion = seccionI AND cicloEstudiantil = cicloI AND yearH = CAST(YEAR(NOW()) AS SIGNED);
  SELECT idAsignacion INTO idVal FROM ASIGNACION WHERE idHabilitado = idHab AND carnetEstudiante = carnet;
  RETURN idVal;
END $$
DELIMITER 

DROP PROCEDURE desasignarCurso;
DELIMITER $$
CREATE PROCEDURE desasignarCurso(curso integer, cicloI varchar(2), seccionI varchar(1),carnet bigint)
BEGIN
    -- VALIDACIONES
    -- QUE EL CURSO SE ENCUENTRE ASIGNADO
    -- VALIDAR EL CICLO
    -- VALIDAR QUE EXISTA EL CARNET
    DECLARE contador,idHab,tmp1 INTEGER;
    DECLARE valCarnet, valCiclo BOOLEAN;
    SET valCarnet = verificarEstudiante(carnet);
    SET valCiclo = validarCiclo(cicloI);


    IF valCarnet THEN
        IF valCiclo THEN
            SELECT idHabilitado INTO idHab FROM CURSO_HABILITADO WHERE codigoCurso = curso AND seccion = seccionI AND cicloEstudiantil = cicloI;
            SELECT COUNT(*) INTO contador FROM ASIGNACION WHERE cicloEstudiantil = cicloI AND carnetEstudiante = carnet AND idHabilitado = idHab;
            IF contador > 0 THEN
                -- DESASIGNAMOS AL ESTUDIANTE
                DELETE FROM ASIGNACION WHERE cicloEstudiantil = cicloI AND carnetEstudiante = carnet AND idHabilitado = idHab;
                UPDATE CONTROL_ASIGNACION SET cantidadAsignados = cantidadAsignados -1 WHERE idHabilitado = idHab;
                SELECT "CURSO DESASIGNADO CON EXITO" AS Resultado;
            ELSE
                SELECT "NO SE PUEDE DESASIGNAR: CURSO NO ASIGNADO" AS Resultado;    
            END IF;
        ELSE
            SELECT "FORMATO CICLO INCORRECTO" AS Resultado;
        END IF;
    ELSE 
        SELECT "ESTUDIANTE INEXISTENTE" AS Resultado;
    END IF;
END $$
DELIMITER ;


-- pensum
DELIMITER $$
CREATE PROCEDURE consultarPensum(carrera integer)
BEGIN
    SELECT codigoCurso,nombre,creditosNecesarios,obligatorio FROM CURSO WHERE idCarrera = carrera;
END $$
DELIMITER ;

-- Estudiante

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

DELIMITER $$
CREATE PROCEDURE consultarAsignados(codigo integer, ciclo varchar(2),year integer,seccion varchar(1))
BEGIN
END $$
DELIMITER ;


