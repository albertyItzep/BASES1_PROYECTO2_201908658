
-- proceso para realizar el ingreso de notas
-- validar el ciclo
-- redondear los numeros
-- si es aprobado o no el curso
-- sumar al estudiante los creditos de haber ganado

DELIMITER $$
CREATE PROCEDURE ingresarNota(curso integer, cicloI varchar(2), seccionI varchar(1), carnet bigint,nota DEC)
BEGIN
    DECLARE contador,idHab,tmp1,idAsig,credOtor INTEGER;
    DECLARE valCarnet, valCiclo, cursoGanado BOOLEAN;
    SET valCarnet = verificarEstudiante(carnet);
    SET valCiclo = validarCiclo(cicloI);    
    SET contador = CAST(ROUND(nota) AS SIGNED);
    IF valCiclo THEN
        IF valCarnet THEN
            IF contador > 0 THEN
                IF contador > 61 THEN
                    SET cursoGanado = TRUE;
                    SET cursoGanado = FALSE;
                    -- OBTENEMOS EL ID DE LA ASIGNACION
                    SET idAsig = obtenerAsignacion(curso, cicloI,seccionI,carnet);
                    -- INSERTAMOS LA NOTA
                    IF idAsig IS NULL THEN
                        SELECT "ESTUDIANTE NO ASIGNADO A ESTE CURSO" AS Resultado;     
                    ELSE 
                        INSERT INTO NOTA(cicloEstudiantil, nota, aprobado, idAsignacion, fechaHora) VALUES (cicloI, contador,cursoGanado,idAsig,NOW());
                        SELECT creditosOtorgados INTO credOtor FROM CURSO WHERE codigoCurso = curso;
                        UPDATE ESTUDIANTE SET creditos = creditos + credOtor WHERE carnetEstudiante = carnet; 
                        SELECT "NOTA INSERTADA CORRECTAMENTE" AS Resultado;     
                    END IF;
                ELSE
                    SET cursoGanado = FALSE;
                    -- OBTENEMOS EL ID DE LA ASIGNACION
                    SET idAsig = obtenerAsignacion(curso, cicloI,seccionI,carnet);
                    -- INSERTAMOS LA NOTA
                    IF idAsig IS NULL THEN
                        SELECT "ESTUDIANTE NO ASIGNADO A ESTE CURSO" AS Resultado;     
                    ELSE 
                        INSERT INTO NOTA(cicloEstudiantil, nota, aprobado, idAsignacion, fechaHora) VALUES (cicloI, contador,cursoGanado,idAsig,NOW());
                        SELECT "NOTA INSERTADA CORRECTAMENTE" AS Resultado;     
                    END IF;
                END IF;
            ELSE
                SELECT "VALORES PARA NOTA INCORRECTOS" AS Resultado;     
            END IF;
        ELSE
            SELECT "ESTUDIANTE INEXISTENTE" AS Resultado;
        END IF;
    ELSE
        SELECT "FORMATO CICLO INCORRECTO" AS Resultado;
    END IF;
END $$
DELIMITER ;