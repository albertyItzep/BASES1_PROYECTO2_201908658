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

