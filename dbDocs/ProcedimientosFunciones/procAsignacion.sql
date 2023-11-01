USE proyecto2;

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
  SELECT COUNT(carnetEstudiante) INTO contador FROM ASIGNACION AS asi JOIN CURSO_HABILITADO AS ch  ON ch.codigoCurso = curso AND asi.carnetEstudiante = carnet AND ch.yearH = CAST(YEAR(NOW()) AS SIGNED);
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
  DECLARE cursoC, estudiante INTEGER
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

-- OBTENEMOS EL TOTAL DE ASIGNACIONES QUE SE HICIERON
-- CONTAMOS TODAS LAS NTOTAS INGRESADAS

DELIMITER $$
CREATE PROCEDURE generarActa(curso integer, cicloI varchar(2),seccionI varchar(1))
BEGIN
    DECLARE valCiclo BOOLEAN;
    DECLARE idHab, contador,totalNotas,idAsig integer;

    SET valCiclo = validarCiclo(cicloI);
    
    IF valCiclo THEN
        SELECT idHabilitado INTO idHab FROM CURSO_HABILITADO WHERE codigoCurso = curso AND seccion = seccionI AND cicloEstudiantil = cicloI;
        SELECT cantidadAsignados INTO contador FROM CONTROL_ASIGNACION WHERE idHabilitado = idHab;
        SELECT COUNT(*) INTO totalNotas FROM NOTA AS nt JOIN ASIGNACION AS asi ON asi.cicloEstudiantil = cicloI AND asi.idHabilitado = idHab;

        IF totalNotas = contador THEN
            INSERT INTO ACTA(codigoCurso, ciclo, seccion, fechaHora) VALUES (curso,cicloI,seccionI, NOW());
            SELECT "ACTA GENERADA CON EXITO" AS Resultado;
        ELSE 
            SELECT "NO SE HAN INGRESADO TODAS LAS NOTAS" AS Resultado;
        END IF;
    ELSE
        SELECT "FORMATO DE CICLO ESTUDIANTIL INCORRECTO" AS Resultado;
    END IF;
END $$
DELIMITER ;