USE proyecto2;

DELIMITER $$
CREATE PROCEDURE agregarHorario(idHabilitadoI INTEGER, dia integer, horario varchar(11))
BEGIN
  DECLARE contador,idHorarioI INTEGER;
  DECLARE valHabilitado BOOLEAN; 
  DECLARE regHorario varchar(50);
  SET regHorario = '^[0-9][0-9]?:[0-9][0-9]-[0-9][0-9]?:[0-9][0-9]$';
  SET idHorarioI = verificarExisteHorario(dia, horario);
  SET valHabilitado = validarHabilitado(idHabilitadoI); 
  SELECT COUNT(*) INTO contador FROM HORARIO_ASIGNADO WHERE idHabilitado = idHabilitadoI AND idHorarioCurso = idHorarioI;
  
  If valHabilitado THEN
    if contador > 0 THEN
      SELECT "HORARIO YA SE ENCUENTRA ASIGNADO" AS RESULTADO;
    ELSE
      IF dia<8 AND dia>0 THEN
        IF horario REGEXP regHorario THEN
          INSERT INTO HORARIO_ASIGNADO(idHorarioCurso,idHabilitado,fechaHora) VALUES (idHorarioI,idHabilitadoI,NOW());
          SELECT "HORARIO ASIGNADO CORRECTAMENTE" AS Resultado;
        ELSE 
          SELECT "FORMATO HORARIO INCORRECTO" AS Resultado;
        END IF;
      ELSE
        SELECT "PARAMETRO DIA INCORRECTO" AS Resultado;
      END IF;
    END IF;
  ELSE
    SELECT "CURSO NO HABILITADO" AS Resultado;
  END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION verificarExisteHorario(diaI integer, horarioI varchar(11))
RETURNS INTEGER DETERMINISTIC
BEGIN
  DECLARE contador, id INTEGER;
  SELECT COUNT(*) INTO contador FROM HORARIO_CURSO WHERE dia = diaI AND horario = horarioI;
  IF contador > 0 THEN 
    select idHorarioCurso INTO id from HORARIO_CURSO WHERE dia = diaI AND horario = horarioI;
    RETURN id;
  ELSE
    INSERT INTO HORARIO_CURSO(dia, horario,fechaHora) VALUES (dia, horario,NOW());
    RETURN LAST_INSERT_ID();
  END IF;
END $$
DELIMITER ;
