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