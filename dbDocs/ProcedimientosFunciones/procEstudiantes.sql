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