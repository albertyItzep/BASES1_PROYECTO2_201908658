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
