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
          IF cupoMax > 0 THEN
            INSERT INTO CURSO_HABILITADO(codigoCurso,cicloEstudiantil,siifDocente,cupoMaximo,seccion,yearH,fechaHora) VALUES (curso,ciclo,docente,cupoMax,seccionI,CAST(YEAR(NOW()) AS SIGNED),NOW());
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

