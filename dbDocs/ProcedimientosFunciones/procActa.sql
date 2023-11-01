-- OBTENEMOS EL TOTAL DE ASIGNACIONES QUE SE HICIERON
-- CONTAMOS TODAS LAS NTOTAS INGRESADAS

DELIMITER $$
CREATE PROCEDURE generarActa(curso integer, cicloI varchar(2),seccionI varchar(1))
BEGIN
    DECLARE valCiclo BOOLEAN;
    DECLARE idHab, contador,totalNotas,idAsig integer;

    SET valCiclo = validarCiclo(cicloI);
    
    IF valCiclo THEN
        SELECT idHabilitado INTO idHab FROM CURSO_HABILITADO WHERE codigoCurso = curso AND seccion = seccionI AND cicloEstudiantil = cicloI AND yearH = CAST(YEAR(NOW()) AS SIGNED);
        SELECT cantidadAsignados INTO contador FROM CONTROL_ASIGNACION WHERE idHabilitado = idHab;
        SELECT COUNT(*) INTO idAsig FROM ASIGNACION AS a LEFT JOIN NOTA AS n ON a.idAsignacion = n.idAsignacion WHERE a.idHabilitado = idHab;

        IF idAsig = contador THEN
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