-- Database: db_eventix

-- DROP DATABASE IF EXISTS db_eventix;

CREATE DATABASE db_eventix
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'Spanish_Latin America.1252'
    LC_CTYPE = 'Spanish_Latin America.1252'
    LOCALE_PROVIDER = 'libc'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;


CREATE TABLE rol (
    id_rol INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL UNIQUE,
    descripcion VARCHAR(200),

    CONSTRAINT chk_rol_nombre
        CHECK (nombre IN ('CLIENTE', 'ADMINISTRADOR'))
);


CREATE TABLE usuario (
    id_usuario INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_rol INTEGER NOT NULL,
    nombre VARCHAR(120) NOT NULL,
    correo VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    telefono VARCHAR(20),
    estado VARCHAR(20) NOT NULL DEFAULT 'ACTIVO',
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_usuario_rol
        FOREIGN KEY (id_rol) REFERENCES rol(id_rol),

    CONSTRAINT chk_usuario_estado
        CHECK (estado IN ('ACTIVO', 'INACTIVO'))
);

CREATE TABLE categoria (
    id_categoria INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL UNIQUE,
    descripcion VARCHAR(250)
);

CREATE TABLE recinto (
    id_recinto INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    direccion VARCHAR(250) NOT NULL,
    ciudad VARCHAR(80) NOT NULL
);

CREATE TABLE evento (
    id_evento INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_organizador INTEGER NOT NULL,
    id_categoria INTEGER NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_evento_organizador
        FOREIGN KEY (id_organizador) REFERENCES usuario(id_usuario),

    CONSTRAINT fk_evento_categoria
        FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria)
);


CREATE TABLE sector (
    id_sector INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_recinto INTEGER NOT NULL,
    nombre VARCHAR(80) NOT NULL,
    capacidad INTEGER NOT NULL,

    CONSTRAINT fk_sector_recinto
        FOREIGN KEY (id_recinto) REFERENCES recinto(id_recinto),

    CONSTRAINT uq_sector_recinto_nombre
        UNIQUE (id_recinto, nombre),

    CONSTRAINT chk_sector_capacidad
        CHECK (capacidad > 0)
);


CREATE TABLE asiento (
    id_asiento INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_sector INTEGER NOT NULL,
    fila VARCHAR(10) NOT NULL,
    numero VARCHAR(10) NOT NULL,

    CONSTRAINT fk_asiento_sector
        FOREIGN KEY (id_sector) REFERENCES sector(id_sector),

    CONSTRAINT uq_asiento_sector_fila_numero
        UNIQUE (id_sector, fila, numero)
);


CREATE TABLE funcion (
    id_funcion INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_evento INTEGER NOT NULL,
    id_recinto INTEGER NOT NULL,
    fecha_inicio TIMESTAMP NOT NULL,
    fecha_fin TIMESTAMP NOT NULL,
    apertura_acceso TIMESTAMP NOT NULL,
    cierre_acceso TIMESTAMP NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'PROGRAMADA',

    CONSTRAINT fk_funcion_evento
        FOREIGN KEY (id_evento) REFERENCES evento(id_evento),

    CONSTRAINT fk_funcion_recinto
        FOREIGN KEY (id_recinto) REFERENCES recinto(id_recinto),

    CONSTRAINT chk_funcion_fechas
        CHECK (fecha_fin > fecha_inicio),

    CONSTRAINT chk_funcion_acceso
        CHECK (
            apertura_acceso <= fecha_inicio
            AND cierre_acceso > apertura_acceso
            AND cierre_acceso <= fecha_fin
        ),

    CONSTRAINT chk_funcion_estado
        CHECK (
            estado IN (
                'PROGRAMADA',
                'EN_CURSO',
                'FINALIZADA',
                'CANCELADA'
            )
        )
);


CREATE TABLE funcion_sector (
    id_funcion_sector INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_funcion INTEGER NOT NULL,
    id_sector INTEGER NOT NULL,
    modalidad VARCHAR(20) NOT NULL,
    precio NUMERIC(10,2) NOT NULL,
    cupo INTEGER NOT NULL,
    cantidad_retenida INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT fk_funcion_sector_funcion
        FOREIGN KEY (id_funcion) REFERENCES funcion(id_funcion),

    CONSTRAINT fk_funcion_sector_sector
        FOREIGN KEY (id_sector) REFERENCES sector(id_sector),

    CONSTRAINT uq_funcion_sector
        UNIQUE (id_funcion, id_sector),

    CONSTRAINT chk_funcion_sector_modalidad
        CHECK (modalidad IN ('GENERAL', 'NUMERADO')),

    CONSTRAINT chk_funcion_sector_precio
        CHECK (precio >= 0),

    CONSTRAINT chk_funcion_sector_cupo
        CHECK (cupo > 0),

    CONSTRAINT chk_funcion_sector_retenida
        CHECK (
            cantidad_retenida >= 0
            AND cantidad_retenida <= cupo
        )
);


CREATE TABLE compra (
    id_compra INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_comprador INTEGER NOT NULL,
    id_funcion INTEGER NOT NULL,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_vencimiento TIMESTAMP NOT NULL,
    total NUMERIC(10,2) NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE',
    clave_idempotencia VARCHAR(100) NOT NULL UNIQUE,

    CONSTRAINT fk_compra_comprador
        FOREIGN KEY (id_comprador) REFERENCES usuario(id_usuario),

    CONSTRAINT fk_compra_funcion
        FOREIGN KEY (id_funcion) REFERENCES funcion(id_funcion),

    CONSTRAINT chk_compra_total
        CHECK (total >= 0),

    CONSTRAINT chk_compra_vencimiento
        CHECK (fecha_vencimiento > fecha_creacion),

    CONSTRAINT chk_compra_estado
        CHECK (
            estado IN (
                'PENDIENTE',
                'PAGADA',
                'VENCIDA',
                'CANCELADA'
            )
        )
);


CREATE TABLE detalle_compra (
    id_detalle INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_compra INTEGER NOT NULL,
    id_funcion_sector INTEGER NOT NULL,
    id_asiento INTEGER,
    precio_unitario NUMERIC(10,2) NOT NULL,

    CONSTRAINT fk_detalle_compra
        FOREIGN KEY (id_compra) REFERENCES compra(id_compra),

    CONSTRAINT fk_detalle_funcion_sector
        FOREIGN KEY (id_funcion_sector)
        REFERENCES funcion_sector(id_funcion_sector),

    CONSTRAINT fk_detalle_asiento
        FOREIGN KEY (id_asiento) REFERENCES asiento(id_asiento),

    CONSTRAINT chk_detalle_precio
        CHECK (precio_unitario >= 0)
);


CREATE TABLE asignacion_asiento (
    id_funcion INTEGER NOT NULL,
    id_asiento INTEGER NOT NULL,
    id_detalle INTEGER NOT NULL UNIQUE,

    CONSTRAINT pk_asignacion_asiento
        PRIMARY KEY (id_funcion, id_asiento),

    CONSTRAINT fk_asignacion_funcion
        FOREIGN KEY (id_funcion) REFERENCES funcion(id_funcion),

    CONSTRAINT fk_asignacion_asiento
        FOREIGN KEY (id_asiento) REFERENCES asiento(id_asiento),

    CONSTRAINT fk_asignacion_detalle
        FOREIGN KEY (id_detalle) REFERENCES detalle_compra(id_detalle)
);


CREATE TABLE metodo_pago (
    id_metodo_pago INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL UNIQUE,
    descripcion VARCHAR(200),
    activo BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT chk_metodo_pago_nombre
        CHECK (nombre IN ('QR', 'TARJETA'))
);


CREATE TABLE pago (
    id_pago INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_compra INTEGER NOT NULL,
    id_metodo_pago INTEGER NOT NULL,
    referencia VARCHAR(100) NOT NULL UNIQUE,
    monto NUMERIC(10,2) NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE',
    fecha_pago TIMESTAMP,

    CONSTRAINT fk_pago_compra
        FOREIGN KEY (id_compra) REFERENCES compra(id_compra),

    CONSTRAINT fk_pago_metodo
        FOREIGN KEY (id_metodo_pago)
        REFERENCES metodo_pago(id_metodo_pago),

    CONSTRAINT chk_pago_monto
        CHECK (monto > 0),

    CONSTRAINT chk_pago_estado
        CHECK (estado IN ('PENDIENTE', 'APROBADO', 'RECHAZADO')),

    CONSTRAINT chk_pago_aprobado_fecha
        CHECK (estado <> 'APROBADO' OR fecha_pago IS NOT NULL)
);

CREATE TABLE entrada (
    id_entrada INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_detalle INTEGER NOT NULL UNIQUE,
    codigo VARCHAR(100) NOT NULL UNIQUE,
    estado VARCHAR(20) NOT NULL DEFAULT 'VIGENTE',
    fecha_emision TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_entrada_detalle
        FOREIGN KEY (id_detalle) REFERENCES detalle_compra(id_detalle),

    CONSTRAINT chk_entrada_estado
        CHECK (estado IN ('VIGENTE', 'UTILIZADA', 'ANULADA'))
);


CREATE TABLE acceso (
    id_acceso INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_entrada INTEGER NOT NULL UNIQUE,
    id_validador INTEGER NOT NULL,
    fecha_ingreso TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_acceso_entrada
        FOREIGN KEY (id_entrada) REFERENCES entrada(id_entrada),

    CONSTRAINT fk_acceso_validador
        FOREIGN KEY (id_validador) REFERENCES usuario(id_usuario)
);


CREATE TABLE auditoria (
    id_auditoria INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_actor INTEGER,
    operacion VARCHAR(50) NOT NULL,
    entidad VARCHAR(80) NOT NULL,
    referencia_registro VARCHAR(100) NOT NULL,
    fecha TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    detalle TEXT,

    CONSTRAINT fk_auditoria_actor
        FOREIGN KEY (id_actor) REFERENCES usuario(id_usuario)
);


-- 1. ROL: 2 registros según el alcance del proyecto

INSERT INTO rol (nombre, descripcion)
VALUES
('ADMINISTRADOR', 'Gestiona eventos, usuarios y validacion de entradas'),
('CLIENTE', 'Consulta eventos y compra entradas');


-- 2. USUARIO: 10 registros
-- Usuarios 1 y 2: administradores.
-- Usuarios 3 al 10: clientes.

INSERT INTO usuario
(id_rol, nombre, correo, password_hash, telefono, estado, fecha_registro)
VALUES
(1, 'Laura Rojas', 'laura@example.com',
 'lrojas@gmail.com', '70000001', 'ACTIVO', '2026-09-01 09:00'),
(1, 'Diego Vargas', 'diego@example.com',
 'dvargas@gmail.com', '70000002', 'ACTIVO', '2026-09-01 09:10'),
(2, 'Ana Lopez', 'ana@example.com',
 'alopez@gmail.com', '70000003', 'ACTIVO', '2026-09-02 10:00'),
(2, 'Luis Perez', 'luis@example.com',
 'lperez@gmail.com', '70000004', 'ACTIVO', '2026-09-02 10:10'),
(2, 'Maria Flores', 'maria@example.com',
 'mflores@gmail.com', '70000005', 'ACTIVO', '2026-09-03 11:00'),
(2, 'Carlos Mendoza', 'carlos@example.com',
 'cmendoza@gmail.com', '70000006', 'ACTIVO', '2026-09-03 11:10'),
(2, 'Sofia Castro', 'sofia@example.com',
 'scastro@gmail.com', '70000007', 'ACTIVO', '2026-09-04 12:00'),
(2, 'Jorge Salazar', 'jorge@example.com',
 'jsalazar@gmail.com', '70000008', 'ACTIVO', '2026-09-04 12:10'),
(2, 'Valeria Torres', 'valeria@example.com',
 'vtorres@gmail.com', '70000009', 'ACTIVO', '2026-09-05 13:00'),
(2, 'Pedro Molina', 'pedro@example.com',
 'pmolina@gmail.com', '70000010', 'ACTIVO', '2026-09-05 13:10');


-- 3. CATEGORIA: 10 registros

INSERT INTO categoria (nombre, descripcion)
VALUES
('Cumbia', 'Conciertos de cumbia y musica tropical'),
('Pop romantico', 'Conciertos de pop y baladas romanticas'),
('Rock y heavy metal', 'Conciertos de rock y heavy metal'),
('Regional mexicano', 'Conciertos de banda y musica regional mexicana'),
('Regueton y urbano', 'Conciertos de regueton y musica urbana'),
('Folklore boliviano', 'Conciertos de musica folklorica boliviana'),
('Electronica', 'Presentaciones de DJ y musica electronica'),
('Salsa', 'Conciertos de salsa'),
('Bachata', 'Conciertos de bachata'),
('Jazz y blues', 'Conciertos de jazz y blues');

-- 4. RECINTO: 10 registros


INSERT INTO recinto (nombre, direccion, ciudad)
VALUES
('Recinto por confirmar - Ke Personajes','Pendiente de confirmacion','La Paz'),
('Teatro al Aire Libre','Direccion pendiente de completar''La Paz'),
('Estadio Ramon Tahuichi Aguilera','Direccion pendiente de completar','Santa Cruz'),
('Sonilum Arena','Av. Internacional / Av. Cristo Redentor, 9no Anillo, Zona Norte','Santa Cruz'),
('Palacio de los Deportes','Direccion pendiente de completar', 'Oruro'),
('Sonilum Plaza','Direccion pendiente de completar', 'Santa Cruz'),
('Campo Ferial Chuquiago Marka','Direccion pendiente de completar', 'La Paz'),
('Alice Park','Av. Melchor Urquidi, entre Av. America y Calle Buenos Aires, Zona Noreste','Cochabamba'),
('Super Multiteatro de Oruro','Calle Sucre entre Presidente Montes y Washington, Zona Central','Oruro'),
('Teatro Escena 21','Av. Ballivian, Calle 21 de Calacoto, Edificio Plaza 21 Mall, Zona Sur','La Paz');


-- 5. EVENTO: 10 registros ficticios

INSERT INTO evento
(id_organizador, id_categoria, nombre, descripcion, fecha_creacion)
VALUES
(1, 1, 'Ke Personajes', 'Concierto de cumbia de Ke Personajes.', '2026-01-05 09:00:00'),
(2, 2, 'Sin Bandera', 'Concierto de pop romantico del duo Sin Bandera.', '2026-01-05 09:10:00'),
(1, 3, 'Rata Blanca', 'Concierto de rock y heavy metal de Rata Blanca.', '2026-01-05 09:20:00'),
(2, 4, 'Grupo Firme', 'Concierto de musica regional mexicana de Grupo Firme.', '2026-01-05 09:30:00'),
(1, 5, 'Arcángel', 'Concierto de regueton y musica urbana de Arcangel.', '2026-01-05 09:40:00'),
(2, 6, 'Los Kjarkas (55 Años)', 'Concierto de folklore boliviano por los 55 años de Los Kjarkas.', '2026-01-05 09:50:00'),
(1, 7, 'Alok', 'Presentacion de musica electronica del DJ Alok.', '2026-01-05 10:00:00'),
(2, 2, 'Ricardo Montaner', 'Concierto de pop romantico y baladas de Ricardo Montaner.', '2026-01-05 10:10:00'),
(1, 6, 'Chila Jatun', 'Concierto de folklore boliviano del grupo Chila Jatun.', '2026-01-05 10:20:00'),
(2, 7, 'Steve Aoki', 'Presentacion de musica electronica del DJ Steve Aoki.', '2026-01-05 10:30:00');

-- 6. SECTOR: 10 registros

INSERT INTO sector (id_recinto, nombre, capacidad)
VALUES

(1, 'General', 500),
(2, 'Primera Fila', 100),
(2, 'Super VIP', 200),
(2, 'General', 500),
(2, 'Butaca', 200),
(3, 'General', 1000),
(4, 'Super VIP', 300),
(4, 'Butaca', 200),
(5, 'Butaca', 200),
(6, 'General', 1000);

-- 7. ASIENTO: 10 registros


INSERT INTO asiento (id_sector, fila, numero)
VALUES
-- Sector 8: Butaca de Sonilum Arena
(8, 'A', '1'),
(8, 'A', '2'),
(8, 'A', '3'),
(8, 'A', '4'),
(8, 'A', '5'),

-- Sector 9: Butaca del Palacio de los Deportes
(9, 'A', '1'),
(9, 'A', '2'),
(9, 'A', '3'),
(9, 'A', '4'),
(9, 'A', '5');

-- 8. FUNCION: 10 registros

INSERT INTO funcion
(id_evento, id_recinto, fecha_inicio, fecha_fin,
 apertura_acceso, cierre_acceso, estado)
VALUES
-- 1. Ke Personajes
(1, 1,'2026-02-12 20:00', '2026-02-12 23:00','2026-02-12 18:00', '2026-02-12 21:00','FINALIZADA'),

-- 2. Sin Bandera
(2, 2,'2026-03-15 20:00', '2026-03-15 23:00','2026-03-15 18:00', '2026-03-15 21:00','FINALIZADA'),

-- 3. Rata Blanca
(3, 2,'2026-03-13 20:00', '2026-03-13 23:00','2026-03-13 18:00', '2026-03-13 21:00','FINALIZADA'),

-- 4. Grupo Firme
(4, 3,'2026-04-11 20:00', '2026-04-11 23:00','2026-04-11 18:00', '2026-04-11 21:00','FINALIZADA'),

-- 5. Arcangel
(5, 4,'2026-09-10 20:00', '2026-09-10 23:00','2026-09-10 18:00', '2026-09-10 21:00','FINALIZADA'),

-- 6. Los Kjarkas
(6, 2,'2026-09-18 20:00', '2026-09-18 23:00','2026-09-18 18:00', '2026-09-18 21:00','FINALIZADA'),

-- 7. Alok
(7, 4,'2026-09-23 20:00', '2026-09-23 23:00','2026-09-23 18:00', '2026-09-23 21:00','FINALIZADA'),

-- 8. Ricardo Montaner
(8, 2,'2026-11-08 20:00', '2026-11-08 23:00','2026-11-08 18:00', '2026-11-08 21:00','FINALIZADA'),

-- 9. Chila Jatun
(9, 5,'2026-11-13 20:00', '2026-11-13 23:00','2026-11-13 18:00', '2026-11-13 21:00','PROGRAMADA'),

-- 10. Steve Aoki
(10, 6,'2026-11-28 20:00', '2026-11-28 23:00','2026-11-28 18:00', '2026-11-28 21:00','PROGRAMADA');

-- 9. FUNCION_SECTOR: 10 registros

INSERT INTO funcion_sector
(id_funcion, id_sector, modalidad, precio, cupo, cantidad_retenida)
VALUES
(1, 1, 'GENERAL', 150.00, 500, 0),
(2, 2, 'GENERAL', 350.00, 100, 0),
(3, 3, 'GENERAL', 250.00, 200, 0),
(4, 6, 'GENERAL', 200.00, 1000, 0),
(5, 8, 'NUMERADO', 300.00, 5, 0),
(6, 4, 'GENERAL', 100.00, 500, 0),
(7, 8, 'NUMERADO', 280.00, 5, 0),
(8, 2, 'GENERAL', 400.00, 100, 0),
(9, 9, 'NUMERADO', 120.00, 5, 0),
(10, 10, 'GENERAL', 250.00, 1000, 0);


-- 10. COMPRA: 10 registros
-- Reservas originales de diez minutos, ya pagadas.

INSERT INTO compra
(id_comprador, id_funcion, fecha_creacion, fecha_vencimiento,
 total, estado, clave_idempotencia)
VALUES
(3, 1, '2026-09-20 10:00', '2026-09-20 10:10',
 150.00, 'PAGADA', 'COMPRA-PRUEBA-001'),

(4, 2, '2026-09-20 11:00', '2026-09-20 11:10',
 80.00, 'PAGADA', 'COMPRA-PRUEBA-002'),

(5, 3, '2026-09-21 10:00', '2026-09-21 10:10',
 60.00, 'PAGADA', 'COMPRA-PRUEBA-003'),

(6, 4, '2026-09-21 11:00', '2026-09-21 11:10',
 70.00, 'PAGADA', 'COMPRA-PRUEBA-004'),

(7, 5, '2026-09-22 10:00', '2026-09-22 10:10',
 90.00, 'PAGADA', 'COMPRA-PRUEBA-005'),

(8, 6, '2026-09-22 11:00', '2026-09-22 11:10',
 50.00, 'PAGADA', 'COMPRA-PRUEBA-006'),

(9, 7, '2026-09-23 10:00', '2026-09-23 10:10',
 40.00, 'PAGADA', 'COMPRA-PRUEBA-007'),

(10, 8, '2026-09-23 11:00', '2026-09-23 11:10',
 35.00, 'PAGADA', 'COMPRA-PRUEBA-008'),

(3, 9, '2026-09-24 10:00', '2026-09-24 10:10',
 55.00, 'PAGADA', 'COMPRA-PRUEBA-009'),

(4, 10, '2026-09-24 11:00', '2026-09-24 11:10',
 120.00, 'PAGADA', 'COMPRA-PRUEBA-010');


-- 11. DETALLE_COMPRA: 10 registros
-- Cada asiento pertenece al sector de la función elegida.

INSERT INTO detalle_compra
(id_compra, id_funcion_sector, id_asiento, precio_unitario)
VALUES
(1, 1, 1, 150.00),
(2, 2, 2, 80.00),
(3, 3, 3, 60.00),
(4, 4, 4, 70.00),
(5, 5, 5, 90.00),
(6, 6, 6, 50.00),
(7, 7, 7, 40.00),
(8, 8, 8, 35.00),
(9, 9, 9, 55.00),
(10, 10, 10, 120.00);


-- 12. ASIGNACION_ASIENTO: 10 registros

INSERT INTO asignacion_asiento
(id_funcion, id_asiento, id_detalle)
VALUES
(1, 1, 1),
(2, 2, 2),
(3, 3, 3),
(4, 4, 4),
(5, 5, 5),
(6, 6, 6),
(7, 7, 7),
(8, 8, 8),
(9, 9, 9),
(10, 10, 10);

-- 13. METODO_PAGO: 2 registros según el alcance

INSERT INTO metodo_pago (nombre, descripcion, activo)
VALUES
('QR', 'Pago simulado mediante codigo QR', TRUE),
('TARJETA', 'Pago simulado mediante tarjeta', TRUE);

-- 14. PAGO: 10 registros

INSERT INTO pago
(id_compra, id_metodo_pago, referencia, monto, estado, fecha_pago)
VALUES
(1, 1, 'SIM-QR-001', 150.00, 'APROBADO', '2026-09-20 10:05'),
(2, 2, 'SIM-TAR-002', 80.00, 'APROBADO', '2026-09-20 11:05'),
(3, 1, 'SIM-QR-003', 60.00, 'APROBADO', '2026-09-21 10:05'),
(4, 2, 'SIM-TAR-004', 70.00, 'APROBADO', '2026-09-21 11:05'),
(5, 1, 'SIM-QR-005', 90.00, 'APROBADO', '2026-09-22 10:05'),
(6, 2, 'SIM-TAR-006', 50.00, 'APROBADO', '2026-09-22 11:05'),
(7, 1, 'SIM-QR-007', 40.00, 'APROBADO', '2026-09-23 10:05'),
(8, 2, 'SIM-TAR-008', 35.00, 'APROBADO', '2026-09-23 11:05'),
(9, 1, 'SIM-QR-009', 55.00, 'APROBADO', '2026-09-24 10:05'),
(10, 2, 'SIM-TAR-010', 120.00, 'APROBADO', '2026-09-24 11:05');

-- 15. ENTRADA: 10 registros

INSERT INTO entrada
(id_detalle, codigo, estado, fecha_emision)
VALUES
(1, 'ENT-PRUEBA-001', 'UTILIZADA', '2026-09-20 10:06'),
(2, 'ENT-PRUEBA-002', 'UTILIZADA', '2026-09-20 11:06'),
(3, 'ENT-PRUEBA-003', 'UTILIZADA', '2026-09-21 10:06'),
(4, 'ENT-PRUEBA-004', 'UTILIZADA', '2026-09-21 11:06'),
(5, 'ENT-PRUEBA-005', 'UTILIZADA', '2026-09-22 10:06'),
(6, 'ENT-PRUEBA-006', 'UTILIZADA', '2026-09-22 11:06'),
(7, 'ENT-PRUEBA-007', 'UTILIZADA', '2026-09-23 10:06'),
(8, 'ENT-PRUEBA-008', 'UTILIZADA', '2026-09-23 11:06'),
(9, 'ENT-PRUEBA-009', 'UTILIZADA', '2026-09-24 10:06'),
(10, 'ENT-PRUEBA-010', 'UTILIZADA', '2026-09-24 11:06');


-- 16. ACCESO: 10 registros

INSERT INTO acceso
(id_entrada, id_validador, fecha_ingreso)
VALUES
(1, 1, '2026-10-01 18:30'),
(2, 2, '2026-10-02 18:30'),
(3, 1, '2026-10-03 18:30'),
(4, 2, '2026-10-04 18:30'),
(5, 1, '2026-10-05 18:30'),
(6, 2, '2026-10-06 18:30'),
(7, 1, '2026-10-07 18:30'),
(8, 2, '2026-10-08 18:30'),
(9, 1, '2026-10-09 18:30'),
(10, 2, '2026-10-10 18:30');

-- 17. AUDITORIA: 10 registros

INSERT INTO auditoria
(id_actor, operacion, entidad, referencia_registro, fecha, detalle)
VALUES
(1, 'VALIDAR_ENTRADA', 'acceso', '1', '2026-10-01 18:30',
 'Ingreso autorizado con entrada 1 para la funcion 1'),

(2, 'VALIDAR_ENTRADA', 'acceso', '2', '2026-10-02 18:30',
 'Ingreso autorizado con entrada 2 para la funcion 2'),

(1, 'VALIDAR_ENTRADA', 'acceso', '3', '2026-10-03 18:30',
 'Ingreso autorizado con entrada 3 para la funcion 3'),

(2, 'VALIDAR_ENTRADA', 'acceso', '4', '2026-10-04 18:30',
 'Ingreso autorizado con entrada 4 para la funcion 4'),

(1, 'VALIDAR_ENTRADA', 'acceso', '5', '2026-10-05 18:30',
 'Ingreso autorizado con entrada 5 para la funcion 5'),

(2, 'VALIDAR_ENTRADA', 'acceso', '6', '2026-10-06 18:30',
 'Ingreso autorizado con entrada 6 para la funcion 6'),

(1, 'VALIDAR_ENTRADA', 'acceso', '7', '2026-10-07 18:30',
 'Ingreso autorizado con entrada 7 para la funcion 7'),

(2, 'VALIDAR_ENTRADA', 'acceso', '8', '2026-10-08 18:30',
 'Ingreso autorizado con entrada 8 para la funcion 8'),

(1, 'VALIDAR_ENTRADA', 'acceso', '9', '2026-10-09 18:30',
 'Ingreso autorizado con entrada 9 para la funcion 9'),

(2, 'VALIDAR_ENTRADA', 'acceso', '10', '2026-10-10 18:30',
 'Ingreso autorizado con entrada 10 para la funcion 10');


