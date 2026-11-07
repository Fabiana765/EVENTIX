# EVENTIX — Relaciones y cardinalidades de la base de datos

## 1. Descripción general

La base de datos de EVENTIX permite gestionar el registro de usuarios, la organización de eventos, sus funciones, la disponibilidad de sectores y asientos, la compra de entradas, los pagos y el control de ingreso.

El modelo está compuesto por **17 tablas**. Cada usuario tiene un único rol: **CLIENTE** o **ADMINISTRADOR**.

## 2. Claves y cardinalidades

### Tipos de claves

| Abreviatura | Nombre | Función |
|---|---|---|
| PK | Clave primaria | Identifica de manera única cada registro. |
| FK | Clave foránea | Relaciona un registro con otro de una tabla referenciada. |
| UK | Clave única | Impide que se repitan los valores de un campo o combinación de campos. |
| PK compuesta | Clave primaria compuesta | Identifica un registro mediante la combinación de dos o más campos. |

### Tipos de cardinalidades

| Cardinalidad | Significado |
|---|---|
| 1:N | Un registro puede relacionarse con varios registros de otra tabla. |
| 1:1 | Un registro puede relacionarse, como máximo, con un registro de otra tabla. |
| N:M | Varios registros de una tabla pueden relacionarse con varios de otra. Se implementa mediante una tabla intermedia. |
| 0..N | Puede no haber registros relacionados o puede haber varios. |
| 0..1 | Puede no haber un registro relacionado o puede haber solamente uno. |
| 1..N | Debe existir al menos un registro relacionado y puede haber varios. |

Las etiquetas **1:N** y **1:1** del diagrama representan la cardinalidad máxima. Los círculos de la notación indican participación opcional.

## 3. Tablas del sistema

| N.º | Tabla | Propósito |
|---|---|---|
| 1 | ROL | Define los roles CLIENTE y ADMINISTRADOR. |
| 2 | USUARIO | Almacena las cuentas registradas, sus datos y su rol. |
| 3 | CATEGORIA | Clasifica los eventos, por ejemplo, conciertos, deportes o teatro. |
| 4 | EVENTO | Almacena la información general del evento y su organizador. |
| 5 | RECINTO | Registra los lugares donde se realizan las funciones. |
| 6 | SECTOR | Define las áreas de un recinto, como VIP o General. |
| 7 | ASIENTO | Registra los asientos físicos de un sector. |
| 8 | FUNCION | Define la fecha, horario y recinto de una presentación de un evento. |
| 9 | FUNCION_SECTOR | Configura los sectores disponibles, precios y cupos de una función. |
| 10 | COMPRA | Registra la compra de entradas realizada por un usuario para una función. |
| 11 | DETALLE_COMPRA | Registra cada entrada solicitada dentro de una compra y su precio. |
| 12 | ASIGNACION_ASIENTO | Controla la reserva u ocupación de un asiento para una función. |
| 13 | METODO_PAGO | Define los métodos disponibles: QR y TARJETA. |
| 14 | PAGO | Registra los intentos de pago, su importe, referencia y estado. |
| 15 | ENTRADA | Almacena las entradas emitidas y sus códigos únicos. |
| 16 | ACCESO | Registra el ingreso exitoso de una persona mediante su entrada. |
| 17 | AUDITORIA | Registra operaciones relevantes realizadas en el sistema. |

## 4. Registro de usuarios y roles

Las personas que se registran en la plataforma se almacenan en la tabla **USUARIO**.

Cada usuario tiene un único rol mediante el campo obligatorio `id_rol`, que referencia a `ROL.id_rol`.

| Rol | Funciones |
|---|---|
| CLIENTE | Consultar eventos, comprar entradas y revisar sus compras y entradas. |
| ADMINISTRADOR | Administrar usuarios, eventos, funciones, sectores y pagos; validar entradas. |

### Proceso de registro

1. La persona introduce su nombre, correo y contraseña.
2. El sistema comprueba que el correo no esté registrado.
3. La contraseña se transforma en un hash antes de almacenarse.
4. Se crea el registro en USUARIO.
5. El servidor asigna automáticamente el rol CLIENTE.

El formulario público no permite elegir el rol ADMINISTRADOR. La cuenta inicial de administración se crea durante la configuración del sistema.

Los permisos se verifican en el servidor antes de ejecutar cada operación protegida.

## 5. Relaciones entre tablas

En las relaciones siguientes, la tabla de la izquierda es el punto de partida para interpretar la cardinalidad.

| N.º | Relación | Cardinalidad | Clave foránea | Descripción |
|---|---|---|---|---|
| 1 | ROL → USUARIO | 1:N | USUARIO.id_rol | Un rol puede asignarse a muchos usuarios. Cada usuario tiene exactamente un rol. |
| 2 | USUARIO → EVENTO | 1:N | EVENTO.id_organizador | Un administrador puede organizar varios eventos. Cada evento tiene un único organizador. |
| 3 | CATEGORIA → EVENTO | 1:N | EVENTO.id_categoria | Una categoría puede clasificar varios eventos. Cada evento pertenece a una categoría. |
| 4 | EVENTO → FUNCION | 1:N | FUNCION.id_evento | Un evento puede tener varias funciones. Cada función pertenece a un evento. |
| 5 | RECINTO → FUNCION | 1:N | FUNCION.id_recinto | Un recinto puede albergar varias funciones. Cada función se realiza en un recinto. |
| 6 | RECINTO → SECTOR | 1:N | SECTOR.id_recinto | Un recinto puede contener varios sectores. Cada sector pertenece a un recinto. |
| 7 | SECTOR → ASIENTO | 1:N | ASIENTO.id_sector | Un sector puede contener varios asientos. Cada asiento pertenece a un sector. |
| 8 | FUNCION → FUNCION_SECTOR | 1:N | FUNCION_SECTOR.id_funcion | Una función puede habilitar varios sectores. Cada configuración corresponde a una función. |
| 9 | SECTOR → FUNCION_SECTOR | 1:N | FUNCION_SECTOR.id_sector | Un sector puede utilizarse en varias funciones, con precios y cupos propios para cada una. |
| 10 | USUARIO → COMPRA | 1:N | COMPRA.id_comprador | Un cliente puede realizar varias compras. Cada compra pertenece a un usuario. |
| 11 | FUNCION → COMPRA | 1:N | COMPRA.id_funcion | Una función puede recibir muchas compras. Cada compra corresponde a una sola función. |
| 12 | COMPRA → DETALLE_COMPRA | 1:N | DETALLE_COMPRA.id_compra | Una compra contiene uno o varios detalles. Cada detalle pertenece a una compra y representa una entrada individual. |
| 13 | FUNCION_SECTOR → DETALLE_COMPRA | 1:N | DETALLE_COMPRA.id_funcion_sector | Un sector habilitado para una función puede aparecer en muchos detalles. Cada detalle selecciona una configuración de sector. |
| 14 | ASIENTO → DETALLE_COMPRA | 1:N | DETALLE_COMPRA.id_asiento | Un asiento puede aparecer en varios detalles a lo largo del tiempo. Cada detalle tiene un asiento o ninguno si la entrada es general. |
| 15 | FUNCION → ASIGNACION_ASIENTO | 1:N | ASIGNACION_ASIENTO.id_funcion | Una función puede tener muchas asignaciones de asientos. Cada asignación pertenece a una función. |
| 16 | ASIENTO → ASIGNACION_ASIENTO | 1:N | ASIGNACION_ASIENTO.id_asiento | Un asiento puede asignarse en distintas funciones. Cada asignación corresponde a un asiento. |
| 17 | DETALLE_COMPRA → ASIGNACION_ASIENTO | 1:1 | ASIGNACION_ASIENTO.id_detalle | Un detalle puede tener como máximo una asignación activa. Cada asignación pertenece a un detalle. |
| 18 | COMPRA → PAGO | 1:N | PAGO.id_compra | Una compra puede registrar varios intentos de pago. Cada intento pertenece a una compra. |
| 19 | METODO_PAGO → PAGO | 1:N | PAGO.id_metodo_pago | Un método puede utilizarse en muchos pagos. Cada pago utiliza un solo método. |
| 20 | DETALLE_COMPRA → ENTRADA | 1:1 | ENTRADA.id_detalle | Un detalle puede generar como máximo una entrada. Cada entrada corresponde a un detalle. |
| 21 | ENTRADA → ACCESO | 1:1 | ACCESO.id_entrada | Una entrada permite registrar como máximo un ingreso exitoso. Cada acceso corresponde a una entrada. |
| 22 | USUARIO → ACCESO | 1:N | ACCESO.id_validador | Un administrador puede validar muchas entradas. Cada acceso registra al usuario que realizó la validación. |
| 23 | USUARIO → AUDITORIA | 1:N | AUDITORIA.id_actor | Un usuario puede generar muchos registros de auditoría. El actor puede quedar vacío en operaciones automáticas del sistema. |

## 6. Participación obligatoria y opcional

### Relaciones 1:N

En las relaciones 1:N del modelo, un registro de la tabla principal puede tener **cero o muchos registros relacionados (0..N)**, excepto en COMPRA → DETALLE_COMPRA.

Por ejemplo:

- Un usuario recién registrado puede no tener compras.
- Una categoría puede no tener eventos.
- Un evento puede crearse antes de configurar sus funciones.
- Un sector general puede no tener asientos numerados.
- Una compra pendiente puede no tener todavía intentos de pago.

En **COMPRA → DETALLE_COMPRA**, una compra válida debe contener **uno o varios detalles (1..N)**. La creación de la compra y sus detalles debe completarse como una sola transacción.

Cada registro dependiente referencia exactamente un registro principal, salvo estas excepciones:

| Campo | Participación | Motivo |
|---|---|---|
| DETALLE_COMPRA.id_asiento | Opcional | Las entradas generales no utilizan asiento numerado. |
| AUDITORIA.id_actor | Opcional | Una operación automática puede no tener un usuario asociado. |

### Relaciones 1:1

| Relación | Participación real | Explicación |
|---|---|---|
| DETALLE_COMPRA → ASIGNACION_ASIENTO | 1 → 0..1 | Puede no existir asignación si la entrada es general o si se liberó la reserva. |
| DETALLE_COMPRA → ENTRADA | 1 → 0..1 | La entrada todavía puede no haberse emitido por falta de pago aprobado. |
| ENTRADA → ACCESO | 1 → 0..1 | La entrada puede no haberse utilizado. |

En sentido inverso, cada asignación corresponde a un detalle, cada entrada corresponde a un detalle y cada acceso corresponde a una entrada.

## 7. Tablas intermedias

### FUNCION_SECTOR

Relaciona FUNCION con SECTOR.

Una función puede habilitar varios sectores y un sector puede utilizarse en distintas funciones. Esta relación conceptual N:M se resuelve mediante FUNCION_SECTOR.

Además de las claves foráneas, almacena:

- Modalidad: GENERAL o NUMERADO.
- Precio.
- Cupo.
- Cantidad retenida por reservas vigentes.

La combinación `id_funcion + id_sector` debe ser única.

### ASIGNACION_ASIENTO

Relaciona FUNCION con ASIENTO y vincula la asignación con DETALLE_COMPRA.

Una función puede tener varios asientos asignados y un mismo asiento puede utilizarse en distintas funciones.

Su clave primaria está compuesta por:

`id_funcion + id_asiento`

Esto impide asignar dos veces el mismo asiento para una misma función.

Ejemplo:

| id_funcion | id_asiento | id_detalle |
|---|---|---|
| 5 | 10 | 80 |
| 6 | 10 | 95 |

El asiento 10 puede asignarse a las funciones 5 y 6. No puede existir otra asignación con la combinación `id_funcion = 5` e `id_asiento = 10`.

Cuando una reserva vence o se cancela, se libera su asignación. El detalle de compra permanece como historial.

Las entradas generales no utilizan esta tabla; su disponibilidad se controla mediante el cupo de FUNCION_SECTOR.

## 8. Reglas de integridad y negocio

### Usuarios

- El correo debe ser obligatorio y único.
- La contraseña se almacena como hash en `password_hash`.
- Cada usuario debe tener exactamente un rol.
- El registro público asigna automáticamente CLIENTE.
- Los usuarios referenciados por `EVENTO.id_organizador` y `ACCESO.id_validador` deben ser ADMINISTRADORES.

### Funciones, sectores y asientos

- Un sector habilitado debe pertenecer al recinto donde se realiza la función.
- No debe repetirse la combinación `id_funcion + id_sector` en FUNCION_SECTOR.
- Un asiento debe pertenecer al sector seleccionado en el detalle de compra.
- La función del detalle debe coincidir con la función de la compra.
- La función y el asiento de ASIGNACION_ASIENTO deben coincidir con los del detalle asociado.
- La clave primaria compuesta de ASIGNACION_ASIENTO impide asignaciones duplicadas en la misma función.
- Las reservas y liberaciones de cupo deben ejecutarse mediante transacciones para evitar sobreventas.
- La liberación de una reserva vencida o cancelada debe efectuarse una sola vez.

### Compras

- Cada compra corresponde a un usuario y a una función.
- Cada detalle representa una entrada individual.
- El precio unitario conserva el importe aplicado al momento de la compra.
- El total de la compra debe coincidir con la suma de sus detalles.
- La clave de idempotencia evita crear compras duplicadas al repetir una misma solicitud.

### Pagos

- Una compra puede tener varios intentos de pago.
- Solo puede existir un pago aprobado por compra.
- El método utilizado se registra mediante METODO_PAGO.
- El monto aprobado debe corresponder al total de la compra.
- La referencia identifica la operación de pago.
- No se almacenan números completos de tarjeta ni códigos CVV.
- En el alcance académico inicial, los pagos por QR y tarjeta se simulan; no se procesan cobros bancarios reales.

### Entradas y accesos

- Solo se emiten entradas cuando el pago de la compra está aprobado.
- `ENTRADA.id_detalle` debe ser único.
- Cada entrada tiene un código único y no predecible.
- `ACCESO.id_entrada` debe ser único para impedir un segundo ingreso exitoso.
- La validación debe comprobar el estado de la entrada y el horario de acceso de su función.
- Los intentos de ingreso rechazados pueden registrarse en AUDITORIA; ACCESO conserva los ingresos exitosos.

Estas reglas deben implementarse mediante restricciones, transacciones y validaciones del servidor. Una clave foránea por sí sola no comprueba el rol de un usuario ni todas las condiciones del negocio.

## 9. Ejemplo del funcionamiento completo

Un cliente compra dos entradas numeradas para una función de Babel:

1. El cliente se registra y sus datos se almacenan en USUARIO con el rol CLIENTE.
2. Selecciona el EVENTO y una FUNCION.
3. Elige un sector habilitado en FUNCION_SECTOR.
4. Selecciona dos registros de ASIENTO.
5. El sistema crea una COMPRA y dos registros de DETALLE_COMPRA.
6. Se generan dos registros de ASIGNACION_ASIENTO para reservar los lugares.
7. El cliente selecciona QR o TARJETA y se registra un intento en PAGO.
8. Cuando se aprueba el pago, se emiten dos registros en ENTRADA.
9. Al ingresar al evento, un administrador valida cada entrada.
10. Se registra un ACCESO por cada entrada utilizada.

Si el pago no se completa dentro del plazo de reserva, la compra vence y se liberan los asientos y el cupo retenido.

## 10. Alcance del modelo actualizado

El modelo conserva la estructura original de EVENTIX con estos ajustes:

- USUARIO incluye la clave foránea obligatoria `id_rol`.
- Solo existen los roles CLIENTE y ADMINISTRADOR.
- Se elimina USUARIO_ROL porque cada usuario tiene un único rol.
- Se elimina ASIGNACION_ACCESO porque la validación corresponde al administrador.
- Se conserva ASIGNACION_ASIENTO para controlar la ocupación por función.
- Se incorpora METODO_PAGO para distinguir QR y TARJETA.
