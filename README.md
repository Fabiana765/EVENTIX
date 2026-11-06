EVENTIX 🎟️
Sistema de gestión de eventos, venta de entradas y control de acceso
Asignatura: Base de Datos II
Estado: Propuesta académica, pendiente de implementación.
Integrantes: Por completar.
Docente y universidad: Por completar.
1. Descripción
EVENTIX es una propuesta de aplicación web para organizar eventos, reservar y vender entradas y validar el ingreso de asistentes. Permitirá consultar eventos, seleccionar cupos o asientos, registrar pagos simulados y obtener entradas con códigos QR.

El proyecto se centrará en una base de datos relacional que garantice integridad, controle operaciones simultáneas y facilite reportes. La interfaz permitirá demostrar estas operaciones.
2. Problema a resolver
La gestión de entradas mediante hojas de cálculo y registros separados puede provocar ventas duplicadas, errores de disponibilidad y dificultades para verificar asistentes. Cuando varias personas intentan comprar el último cupo o el mismo asiento, una validación insuficiente puede generar sobreventas.

También se necesita impedir el uso repetido de una entrada y contar con información centralizada sobre ventas, ingresos y asistencia.

Pregunta del proyecto: ¿Cómo gestionar la venta de entradas y el acceso a eventos mediante una base de datos relacional que evite sobreventas, preserve la consistencia de las operaciones y facilite la generación de reportes?
3. Objetivo general
Desarrollar un sistema web de gestión de eventos, venta de entradas y control de acceso, sustentado en una base de datos relacional, que centralice la información, controle la disponibilidad de cupos y asientos, garantice la integridad de las transacciones y facilite el seguimiento de ventas y asistencia.
4. Objetivos específicos
1. Analizar los requisitos de compradores, organizadores y personal de acceso.
2. Diseñar un modelo entidad-relación y un esquema normalizado hasta tercera forma normal.
3. Implementar restricciones, funciones, procedimientos y transacciones para reservas y compras.
4. Aplicar control de concurrencia para evitar sobreventas y asientos duplicados.
5. Establecer permisos por rol y auditoría de operaciones críticas.
6. Emitir entradas con identificadores únicos representados como códigos QR.
7. Generar reportes mediante vistas y consultas avanzadas.
8. Comprobar integridad, concurrencia y rendimiento mediante pruebas documentadas.
5. Justificación
El proyecto permite aplicar contenidos de Base de Datos II a un problema con reglas verificables: una compra debe confirmarse completa o revertirse, un asiento no puede venderse dos veces para la misma función y una entrada no puede permitir varios ingresos.

Su desarrollo integra normalización, transacciones, restricciones, triggers, vistas, índices, seguridad y recuperación de datos, con una aplicación demostrable en conciertos, conferencias y actividades universitarias.
6. Alcance
Primera versión
- Usuarios y permisos por rol.
- Eventos, recintos, sectores y funciones con fecha y horario.
- Entradas generales por sector y entradas numeradas por asiento.
- Reservas temporales y cancelación de reservas pendientes.
- Compras de varias entradas para una misma función.
- Pagos simulados en bolivianos (BOB).
- Emisión de entradas y validación por QR o código.
- Reportes y auditoría.
Fuera del alcance
- Cobros reales, integración bancaria y facturación fiscal.
- Reventa y transferencia de entradas.
- Aplicación móvil nativa y validación sin conexión.
- Reembolsos automáticos y cancelación de funciones con ventas confirmadas.
7. Usuarios del sistema
Rol	Permisos
Administrador	Gestionar usuarios y roles, supervisar el sistema y consultar auditoría.
Organizador	Gestionar sus eventos, configurar funciones, asignar personal de acceso y consultar sus reportes.
Comprador	Consultar eventos, reservar, comprar y acceder a sus propias entradas.
Personal de acceso	Validar entradas de las funciones a las que esté asignado.


Los permisos se comprobarán en el servidor en cada operación.
8. Requisitos funcionales
Código	Requisito
RF01	Registrar usuarios e iniciar y cerrar sesión.
RF02	Asignar roles y verificar permisos.
RF03	Crear eventos con nombre, descripción, categoría y organizador.
RF04	Configurar funciones con recinto, fecha, horario y estado.
RF05	Configurar sectores, precios, cupos y asientos antes de publicar.
RF06	Buscar eventos publicados por nombre, categoría, lugar y fecha.
RF07	Consultar disponibilidad por función y sector.
RF08	Crear reservas temporales de entradas disponibles.
RF09	Cancelar o vencer reservas y liberar recursos.
RF10	Registrar intentos de pago simulado aprobados o rechazados.
RF11	Confirmar compras y emitir entradas de manera transaccional.
RF12	Generar un código único y su representación QR por entrada.
RF13	Consultar compras y entradas propias.
RF14	Validar entradas y registrar un único ingreso exitoso.
RF15	Rechazar entradas inexistentes, utilizadas o de otra función.
RF16	Generar reportes de ventas, disponibilidad y asistencia.
RF17	Auditar operaciones críticas e intentos de acceso rechazados.


9. Requisitos no funcionales
- Integridad: claves primarias, foráneas, restricciones de unicidad y validación de valores.
- Atomicidad: una operación fallida no dejará compras o entradas parcialmente confirmadas.
- Concurrencia: dos solicitudes simultáneas no podrán consumir el mismo asiento o último cupo.
- Seguridad: contraseñas con hash seguro, consultas parametrizadas y credenciales fuera del repositorio.
- Privacidad: acceso a compras y reportes limitado según propietario y rol.
- Usabilidad: interfaz adaptable a computadoras y teléfonos.
- Rendimiento: evaluar consultas frecuentes con al menos 10.000 entradas ficticias y documentar equipo, tiempos y planes de ejecución. Meta inicial: menos de dos segundos por consulta frecuente en el entorno de prueba.
- Recuperación: documentar y comprobar una restauración desde un respaldo.
- Mantenibilidad: separar interfaz, lógica de negocio y acceso a datos; versionar scripts SQL.
Las metas de rendimiento deberán comprobarse; no representan resultados obtenidos.
10. Reglas de negocio
1. Cada evento pertenece a un organizador y puede tener varias funciones.
2. La disponibilidad se controla por función; un asiento puede venderse para funciones diferentes.
3. Los sectores pueden ser generales o numerados. Los numerados requieren asiento.
4. Las reservas activas y ventas confirmadas no podrán superar el cupo habilitado.
5. Cada asiento tendrá como máximo una asignación activa por función.
6. Una compra pertenecerá a un comprador y contendrá entradas de una sola función.
7. Las reservas durarán inicialmente 10 minutos, calculados con la hora del servidor.
8. Una reserva vencida no podrá confirmarse, aunque aún no haya sido liberada por la tarea programada.
9. El detalle conservará el precio de compra; los cambios posteriores de precio no modificarán ventas anteriores.
10. Los importes se almacenarán como decimales exactos.
11. Solo un pago simulado aprobado podrá confirmar una compra vigente.
12. Repetir una confirmación no deberá duplicar pagos aprobados ni entradas.
13. Cada entrada tendrá un código único no predecible y permitirá un solo ingreso exitoso.
14. El acceso exigirá función correcta, horario habilitado y validador autorizado.
15. Los registros con historial de ventas se conservarán; no se eliminarán físicamente.
16. No se reducirá el cupo ni se modificará la distribución de asientos después de iniciar las ventas.
11. Modelo de datos propuesto
Tabla	Propósito y atributos principales
usuarios	id, nombre, correo único, hash de contraseña, estado.
roles	id y nombre único.
usuario_roles	Asociación única entre usuario y rol.
categorias	Clasificación de eventos.
eventos	id, organizador_id, categoria_id, nombre, descripción.
recintos	id, nombre, dirección, ciudad.
sectores	id, recinto_id, nombre, capacidad física.
asientos	id, sector_id, fila, número; ubicación única dentro del sector.
funciones	id, evento_id, recinto_id, inicio, fin, horario de acceso, estado.
funcion_sectores	id, funcion_id, sector_id, modalidad, precio, cupo, cantidad retenida; función-sector único.
compras	id, comprador_id, funcion_id, estado, creación, vencimiento, total, clave de idempotencia única.
detalle_compra	id, compra_id, funcion_sector_id, asiento_id opcional, precio_unitario; una fila por entrada.
asignaciones_asiento	funcion_id, asiento_id, detalle_id; función-asiento único para reservas y ventas activas.
pagos	id, compra_id, referencia única, monto, estado, fecha; varios intentos, máximo uno aprobado por compra.
entradas	id, detalle_id único, código único, estado, fecha de emisión.
asignaciones_acceso	Asociación única entre validador y función.
accesos	id, entrada_id único, validador_id, fecha; solo ingresos exitosos.
auditoria	id, actor_id, operación, entidad, referencia, fecha y cambios relevantes.


Relaciones y validaciones
- Un organizador registra varios eventos; cada evento tiene varias funciones.
- Un recinto contiene sectores y un sector puede contener asientos.
- Una función habilita sectores mediante funcion_sectores.
- Una compra contiene varios detalles y varios intentos de pago.
- Cada detalle confirmado genera una entrada y cada entrada admite un único acceso exitoso.
- El sector debe pertenecer al recinto de la función; el asiento debe pertenecer al sector seleccionado.
- Todos los detalles deben corresponder a la función de la compra.
Se elaborará el diagrama entidad-relación y el diccionario de datos antes de implementar. Si se almacenan datos derivados, como total o cantidad retenida, deberán mantenerse dentro de las transacciones y verificarse con consultas de conciliación.
12. Aplicación de Base de Datos II
Contenido	Aplicación
Normalización	Separar entidades y reducir redundancias.
Restricciones	Impedir códigos duplicados, referencias inválidas e importes incorrectos.
Procedimientos o funciones	Reservar, confirmar, cancelar, liberar reservas y validar acceso.
Transacciones	Confirmar pago simulado, compra y entradas como unidad.
Control de concurrencia	Proteger cupos y asignaciones de asientos mediante bloqueos y unicidad.
Triggers	Auditar cambios críticos y validar transiciones cuando corresponda.
Vistas	Consultar ventas, disponibilidad y asistencia.
Índices	Agilizar búsquedas por fecha, función, comprador y código.
Consultas avanzadas	Agrupaciones, subconsultas, CTE y funciones de ventana.
Seguridad	Roles de aplicación y privilegios limitados de conexión.
Respaldo	Generación y restauración comprobada de copias.


El vencimiento de reservas requerirá una tarea programada u operación explícita: un trigger no se ejecuta por el simple paso del tiempo.
13. Operaciones críticas
Reservar
Iniciar una transacción, comprobar que la función admite ventas y bloquear los sectores afectados en un orden consistente. Verificar cupos y asientos, registrar compra pendiente y detalles, crear asignaciones y actualizar la cantidad retenida. Confirmar todos los cambios o revertirlos ante un error.
Confirmar compra
Bloquear la compra y comprobar propietario, estado y vencimiento. Si ya está confirmada, devolver el resultado existente. En caso contrario, registrar el pago simulado aprobado, confirmar la compra y emitir sus entradas en una sola transacción.
Cancelar o vencer
Bloquear la compra pendiente y sus recursos, cambiar su estado, liberar asignaciones de asientos y disminuir la cantidad retenida. Repetir la operación no deberá liberar cupos dos veces.
Validar ingreso
Comprobar código, función, horario y permisos. Bloquear la entrada, verificar que no esté utilizada, registrar el acceso y actualizar su estado en una sola transacción.
14. Estados
Entidad	Estados
Función	BORRADOR, PUBLICADA, CERRADA, FINALIZADA, CANCELADA.
Compra	PENDIENTE, CONFIRMADA, CANCELADA, VENCIDA.
Pago simulado	APROBADO, RECHAZADO.
Entrada	EMITIDA, UTILIZADA.


Una compra pendiente puede confirmarse, cancelarse o vencer. Una confirmada no vuelve a pendiente. Un pago rechazado permite reintentar mientras la reserva siga vigente. Una función cerrada no vende, pero puede admitir accesos durante el horario habilitado. Solo se cancelarán funciones sin ventas confirmadas, liberando sus reservas pendientes.
15. Reportes
- Entradas vendidas e ingresos simulados por evento y función.
- Cupos libres, reservas vigentes y ventas por sector.
- Porcentaje de ocupación de venta.
- Asistencia efectiva y entradas sin utilizar.
- Ventas por día y categoría.
- Ranking de eventos por entradas vendidas.
- Reservas vencidas y canceladas.
- Historial de compras por usuario.
- Auditoría y accesos rechazados.
Los ingresos se calcularán a partir de pagos aprobados de compras confirmadas, evitando multiplicar importes al unir varios detalles. Ocupación de venta y asistencia serán métricas diferentes.
16. Arquitectura y tecnologías propuestas
Se propone una arquitectura de tres capas: interfaz web, lógica de negocio y persistencia relacional.
Componente	Propuesta
Base de datos	PostgreSQL.
Backend	Python con Django.
Interfaz	Plantillas de Django, HTML, CSS y JavaScript.
Versionamiento	Git y GitHub.
Entradas	QR validado contra el servidor.
Pagos	Simulación interna sin dinero real.


Las versiones y dependencias exactas se definirán al implementar el proyecto.
17. Estructura prevista del repositorio
Ruta	Contenido
README.md	Especificación del proyecto.
docs/	Diagramas, requisitos, diccionario de datos y evidencias.
database/schema/	Tablas y restricciones.
database/functions/	Procedimientos y funciones.
database/triggers/	Auditoría y validaciones.
database/views/	Vistas y reportes.
database/seeds/	Datos ficticios de prueba.
src/	Aplicación web.
tests/	Pruebas de integridad, funcionalidad y concurrencia.


Esta estructura es propuesta y no implica que las carpetas ya existan.
18. Criterios de aceptación
Prueba	Resultado esperado
Dos usuarios reservan el mismo asiento simultáneamente.	Solo uno obtiene la reserva.
Dos solicitudes compiten por el último cupo.	Solo una reserva se acepta.
Falla la emisión de una entrada durante la confirmación.	Toda la confirmación se revierte.
Se repite una confirmación.	No se duplican pagos ni entradas.
Se intenta confirmar una reserva vencida.	La operación se rechaza.
Se ejecuta dos veces la liberación de una reserva.	El cupo se libera una sola vez.
Dos validadores escanean una entrada simultáneamente.	Solo se registra un ingreso exitoso.
Se presenta una entrada de otra función.	Se rechaza el acceso.
Se consulta una compra o evento sin autorización.	Se deniega la operación.
Se generan reportes con datos conocidos.	Los totales coinciden con los resultados esperados.
Se restaura un respaldo.	Se recuperan estructura y datos y se verifican mediante consultas.


19. Plan de desarrollo
1. Requisitos y casos de uso.
2. Modelo entidad-relación, normalización y diccionario de datos.
3. Esquema SQL y datos ficticios.
4. Operaciones transaccionales, auditoría y reportes.
5. Interfaz web e integración.
6. Pruebas de integridad, permisos, concurrencia y rendimiento.
7. Documentación, respaldo y demostración final.
20. Entregables
- README del proyecto.
- Diagramas y diccionario de datos.
- Scripts SQL versionados y datos ficticios.
- Código de la aplicación web.
- Pruebas y evidencias.
- Manual de instalación y uso.
- Respaldo y evidencia de restauración.
21. Instalación y ejecución
Pendiente de implementación. Este README describe una propuesta y no afirma que exista una aplicación ejecutable.

Cuando se implemente, se documentarán versiones, dependencias, variables de entorno, creación de la base de datos, carga de datos ficticios y comandos para iniciar la aplicación y ejecutar pruebas. No se publicarán credenciales en el repositorio.
22. Resultado esperado
Un prototipo funcional que gestione la publicación de funciones, la compra de entradas y el ingreso de asistentes, demostrando mediante pruebas que no se producen sobreventas, entradas duplicadas ni múltiples ingresos con el mismo código.
23. Autoría y licencia
Integrantes y enlace del repositorio: Por completar.
Licencia: Por definir por los autores antes de autorizar su reutilización.
