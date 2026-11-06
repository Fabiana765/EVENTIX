## Cardinalidades

| Relación | Cardinalidad | Significado |
|---|---|---|
| Usuario → Evento | 1 a 0..N | Un usuario puede organizar varios eventos. Cada evento tiene un organizador. |
| Evento → Función | 1 a 0..N | Un evento puede tener varias funciones con fechas y horarios diferentes. |
| Recinto → Sector | 1 a 0..N | Un recinto puede contener varios sectores. |
| Sector → Asiento | 1 a 0..N | Un sector puede contener asientos numerados o no tenerlos. |
| Usuario → Compra | 1 a 0..N | Un usuario puede realizar varias compras. Cada compra pertenece a un usuario. |
| Compra → Detalle de compra | 1 a 1..N | Cada compra contiene uno o varios detalles. |
| Compra → Pago | 1 a 0..N | Una compra puede registrar varios intentos de pago. |
| Detalle de compra → Entrada | 1 a 0..1 | Cada detalle puede generar una entrada cuando se confirma la compra. |
| Entrada → Acceso | 1 a 0..1 | Una entrada puede no utilizarse o registrar un único ingreso exitoso. |

