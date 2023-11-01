
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

DELIMITER $$
CREATE PROCEDURE consultarDocente(codigo BIGINT)
BEGIN
    select siifDocente, CONCAT(nombre," ",apellido), fechaNacimiento,correo,telefono,direccion,dpiDocente from DOCENTE WHERE siifDocente = codigo;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE consultarAsignados(codigo integer, cicloI varchar(2),yearI integer,seccioni varchar(1))
BEGIN
    DECLARE idHab INTEGER;
    SELECT idHabilitado INTO idHab FROM CURSO_HABILITADO WHERE codigoCurso = codigo AND seccion = seccionI AND cicloEstudiantil = cicloI AND yearH = yearI;
    SELECT e.carnetEstudiante, CONCAT(e.nombre," ",e.apellido) as NOMBRE, e.creditos FROM ESTUDIANTE AS e JOIN ASIGNACION as a ON a.idHabilitado = idHab AND e.carnetEstudiante = a.carnetEstudiante;
END $$
DELIMITER ;

DELIMITER ;
CREATE PROCEDURE consultarAprobacion(curso integer,cicloI varchar(2),yearI integer,seccioni varchar(1))
BEGIN
    DECLARE idHab INTEGER;
    SELECT idHabilitado INTO idHab FROM CURSO_HABILITADO WHERE codigoCurso = curso AND seccion = seccionI AND cicloEstudiantil = cicloI AND yearH = yearI;

    SELECT h.codigoCurso, a.carnetEstudiante,CONCAT(e.nombre," ",e.apellido), n.aprobado FROM CURSO_HABILITADO AS h JOIN ASIGNACION AS a ON a.idHabilitado = idHab JOIN ESTUDIANTE AS e ON a.carnetEstudiante = e.carnetEstudiante JOIN NOTA AS n ON a.idAsignacion = n.idAsignacion;
END $$
DELIMITER ;