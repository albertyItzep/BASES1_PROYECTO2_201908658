
-- pensum
DELIMITER $$
CREATE PROCEDURE consultarPensum(carrera integer)
BEGIN
    SELECT codigoCurso,nombre,creditosNecesarios,obligatorio FROM CURSO WHERE idCarrera = carrera;
END $$
DELIMITER ;

-- Estudiante

DELIMITER $$
CREATE PROCEDURE consultarEstudiante(carnet BIGINT)
BEGIN
SELECT carnetEstudiante,CONCAT(nombre," ",apellido),fechaNacimiento,correo, telefono,direccion,dpiEstudiante,creditos,idCarrera FROM ESTUDIANTE WHERE carnetEstudiante = carnet;
END $$
DELIMITER ;