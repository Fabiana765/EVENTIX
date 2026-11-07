# EVENTIX — Sistema de Gestión de Eventos y Venta de Entradas

## Descripción

EVENTIX es una plataforma web para gestionar eventos y vender entradas de forma organizada. Permite a los clientes registrarse con su correo electrónico, consultar eventos, seleccionar una función, elegir un sector o asiento y adquirir sus entradas.

El administrador puede gestionar eventos, funciones, recintos, sectores, asientos y usuarios, consultar las compras y los pagos, y validar las entradas al momento del ingreso.

El sistema controla la disponibilidad para evitar la sobreventa y la asignación duplicada de asientos. Además, registra las operaciones importantes para facilitar su seguimiento.

El proyecto se desarrolla como parte de la materia Base de Datos II.

## Problema a Resolver

La venta de entradas mediante registros manuales o herramientas separadas puede generar duplicidad de asientos, errores en el control de cupos, dificultades para verificar pagos y demoras al validar el ingreso del público.

También dificulta que los clientes consulten la disponibilidad y accedan a sus entradas desde un mismo lugar.

EVENTIX busca centralizar estos procesos mediante una aplicación web y una base de datos relacional que mantenga la información organizada y consistente.

## Objetivo General

Desarrollar una plataforma web para gestionar eventos, funciones y venta de entradas, mediante una base de datos relacional que permita controlar la disponibilidad, registrar compras y pagos, y validar el ingreso de los asistentes.

## Objetivos Específicos

- Gestionar el registro y la autenticación de usuarios mediante correo electrónico y contraseña.
- Establecer permisos diferenciados para los roles CLIENTE y ADMINISTRADOR.
- Gestionar eventos y clasificarlos por categorías.
- Administrar funciones, fechas, horarios y recintos.
- Configurar sectores, precios, cupos y asientos disponibles por función.
- Registrar compras y reservas, evitando la sobreventa y la asignación duplicada de asientos.
- Registrar intentos de pago mediante QR o tarjeta en un entorno simulado.
- Emitir entradas con códigos únicos después de aprobarse el pago.
- Validar las entradas y registrar un único ingreso por cada una.
- Registrar operaciones relevantes mediante una auditoría.
- Aplicar restricciones de integridad, transacciones, funciones y triggers en PostgreSQL.

## Tecnologías

| Área | Tecnología | Uso |
|---|---|---|
| Frontend | HTML, CSS y JavaScript | Estructura, diseño e interacción de las páginas. |
| Backend | PHP | Implementación de la lógica del servidor. |
| Framework del backend | Laravel | Organización de la aplicación, rutas, validaciones y acceso a datos. |
| Base de datos | PostgreSQL | Almacenamiento y gestión de la información relacional. |


## Roles del Sistema

Cada usuario tiene un único rol.

### Cliente

- Registrarse e iniciar sesión.
- Consultar eventos y funciones disponibles.
- Seleccionar sectores y asientos.
- Realizar compras de entradas.
- Elegir un método de pago.
- Consultar sus compras y entradas.

### Administrador

- Administrar usuarios.
- Gestionar categorías y eventos.
- Configurar recintos, sectores y asientos.
- Crear funciones y establecer sus horarios.
- Definir precios y cupos por sector.
- Consultar compras y pagos.
- Validar entradas y registrar el ingreso.
- Consultar los registros de auditoría.

El registro público asigna automáticamente el rol CLIENTE. La cuenta inicial de ADMINISTRADOR se crea durante la configuración del sistema.

## Funcionalidades Principales

### Registro e inicio de sesión

Las cuentas se almacenan en la tabla USUARIO. El correo es único y las contraseñas se almacenan como hash.

### Gestión de eventos y funciones

Cada evento pertenece a una categoría y puede tener varias funciones. Cada función establece una fecha, un horario y un recinto.

### Disponibilidad de sectores y asientos

Los sectores disponibles se configuran por función, con su modalidad, precio y cupo.

Para sectores numerados, el sistema controla la asignación de asientos. Para sectores generales, controla la cantidad de entradas disponibles.

### Compras y reservas

Una compra corresponde a un cliente y a una función. Puede incluir varias entradas, representadas individualmente en DETALLE_COMPRA.

Las reservas tienen un plazo de vencimiento. Si no se completa el pago, se liberan los asientos y el cupo retenido.

### Pagos

Se registran los intentos de pago mediante QR o tarjeta, indicando su referencia, monto y estado.

Una compra puede tener varios intentos, pero solo uno aprobado.

### Emisión de entradas

Después de aprobarse el pago, se generan las entradas con códigos únicos para su consulta y validación.

### Control de acceso

El administrador verifica la entrada y registra el ingreso. El sistema impide registrar un segundo ingreso exitoso con la misma entrada.

### Auditoría

Se registran operaciones relevantes para facilitar el seguimiento de las acciones realizadas en la plataforma.

## Base de Datos

El modelo está compuesto por 17 tablas:

1. ROL
2. USUARIO
3. CATEGORIA
4. EVENTO
5. RECINTO
6. SECTOR
7. ASIENTO
8. FUNCION
9. FUNCION_SECTOR
10. COMPRA
11. DETALLE_COMPRA
12. ASIGNACION_ASIENTO
13. METODO_PAGO
14. PAGO
15. ENTRADA
16. ACCESO
17. AUDITORIA

Se utilizarán claves primarias, claves foráneas, restricciones de unicidad y validaciones para mantener la integridad de los datos.

Las operaciones de reserva, pago y emisión de entradas utilizarán transacciones para evitar registros incompletos y conflictos entre compras simultáneas.

## Reglas de Negocio

- Cada usuario tiene un único rol: CLIENTE o ADMINISTRADOR.
- El correo electrónico no puede repetirse.
- Cada evento tiene un administrador responsable.
- Una compra corresponde a una sola función.
- Cada detalle de compra representa una entrada.
- El mismo asiento no puede asignarse dos veces para la misma función.
- Las entradas generales no requieren un asiento numerado.
- Las reservas vencidas o canceladas liberan su disponibilidad.
- Una compra admite como máximo un pago aprobado.
- Las entradas se emiten después de aprobarse el pago.
- Cada entrada permite registrar un único ingreso exitoso.
- Los permisos se verifican en el servidor.

