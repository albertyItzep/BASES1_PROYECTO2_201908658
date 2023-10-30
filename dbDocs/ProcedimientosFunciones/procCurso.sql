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

