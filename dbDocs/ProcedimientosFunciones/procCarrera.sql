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


