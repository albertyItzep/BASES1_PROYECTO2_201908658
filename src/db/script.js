const script = `
CREATE SCHEMA IF NOT EXISTS proyecto2;

CREATE TABLE IF NOT EXISTS proyecto2.CARRERA(
    idCarrera INTEGER auto_increment,
    nombreCarrera VARCHAR(50) NOT NULL,
    fechaHora datetime NOT NULL,
    PRIMARY KEY(idCarrera)
);

CREATE TABLE IF NOT EXISTS  proyecto2.DOCENTE(
    siifDocente INTEGER,
    nombre	varchar(100) not null,
    apellido varchar(100) not null,
    fechaNacimiento DATE,
    correo varchar(50) not null,
    telefono varchar(10) not null,
    direccion varchar(100) not null,
    dpiDocente BIGINT not null,
    fechaHora datetime NOT NULL,
    PRIMARY KEY(siifDocente)
);

CREATE TABLE IF NOT EXISTS proyecto2.CURSO(
    codigoCurso INTEGER,
    nombre VARCHAR(100) NOT NULL,
    creditosNecesarios INTEGER NOT NULL,
    creditosOtorgados INTEGER NOT NULL,
    obligatorio boolean NOT NULL DEFAULT 0,
    idCarrera INTEGER NOT NULL,
    fechaHora datetime NOT NULL,
    PRIMARY KEY(codigoCurso),
    FOREIGN KEY(idCarrera) REFERENCES CARRERA(idCarrera)
);

CREATE TABLE IF NOT EXISTS proyecto2.ESTUDIANTE(
    carnetEstudiante BIGINT,
    nombre	varchar(100) not null,
    apellido varchar(100) not null,
    fechaNacimiento DATE,
    correo varchar(50) not null,
    telefono varchar(10) not null,
    direccion varchar(100) not null,
    dpiEstudiante BIGINT not null,
    creditos INTEGER NOT NULL,
    idCarrera INTEGER NOT NULL,
    fechaHora datetime NOT NULL,
    PRIMARY KEY(carnetEstudiante),
    FOREIGN KEY(idCarrera) REFERENCES CARRERA(idCarrera)
);

CREATE TABLE IF NOT EXISTS proyecto2.CURSO_HABILITADO(
    idHabilitado INTEGER AUTO_INCREMENT,
    codigoCurso INTEGER NOT NULL,
    cicloEstudiantil VARCHAR(2) NOT NULL,
    siifDocente INTEGER NOT NULL,
    cupoMaximo INTEGER NOT NULL,
    seccion VARCHAR(1) NOT NULL,
    fechaHora datetime NOT NULL,
    PRIMARY KEY(idHabilitado),
    FOREIGN KEY(codigoCurso) REFERENCES CURSO(codigoCurso),
    FOREIGN KEY(siifDocente) REFERENCES DOCENTE(siifDocente)
);

CREATE TABLE IF NOT EXISTS proyecto2.HORARIO_CURSO(
    idHorario INTEGER AUTO_INCREMENT,
    idHabilitado INTEGER NOT NULL,
    dia INTEGER NOT NULL,
    horario VARCHAR(10) NOT NULL,
    PRIMARY KEY(idHorario),
    FOREIGN KEY(idHabilitado) REFERENCES CURSO_HABILITADO(idHabilitado)
);

CREATE TABLE IF NOT EXISTS proyecto2.ASIGNACION(
    idAsignacion INTEGER AUTO_INCREMENT,
    idHabilitado INTEGER NOT NULL,
    cicloEstudiantil VARCHAR(2) NOT NULL,
    carnetEstudiante BIGINT NOT NULL,
    fechaHora datetime NOT NULL,
    PRIMARY KEY(idAsignacion),
    FOREIGN KEY(idHabilitado) REFERENCES CURSO_HABILITADO(idHabilitado),
    FOREIGN KEY(carnetEstudiante) REFERENCES ESTUDIANTE(carnetEstudiante)
);

CREATE TABLE IF NOT EXISTS proyecto2.DESASIGNACION(
    idDesasignacion INTEGER AUTO_INCREMENT,
    cicloEstudiantil VARCHAR(2) NOT NULL,
    idHabilitado INTEGER NOT NULL,
    carnetEstudiante BIGINT NOT NULL,
    fechaHora datetime NOT NULL,
    PRIMARY KEY(idDesasignacion),
    FOREIGN KEY(idHabilitado) REFERENCES CURSO_HABILITADO(idHabilitado),
    FOREIGN KEY(carnetEstudiante) REFERENCES ESTUDIANTE(carnetEstudiante)
);

CREATE TABLE IF NOT EXISTS proyecto2.NOTA(
    idNota INTEGER AUTO_INCREMENT,
    cicloEstudiantil VARCHAR(2) NOT NULL,
    nota INTEGER NOT NULL,
    aprobado boolean NOT NULL,
    idAsignacion INTEGER NOT NULL,
    fechaHora datetime NOT NULL,
    PRIMARY KEY(idNota),
    FOREIGN KEY(idAsignacion) REFERENCES ASIGNACION(idAsignacion)
);

CREATE TABLE IF NOT EXISTS proyecto2.HISTORIAL(
    idHistorico INTEGER AUTO_INCREMENT,
    fechaHora datetime NOT NULL,
    descripcion varchar(100) NOT NULL,
    tipi VARCHAR(10) NOT NULL,
    PRIMARY KEY(idHistorico)
);

`

module.exports = script

