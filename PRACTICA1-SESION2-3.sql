-- SESION 2
-- VOY A HACERLO TODO EN LA MISMA SESION NI DE PUTA COÑA CREO A MANO LAS TABLAS
/*
L = { 
	U -> E,
	E -> U,
	U -> C ,
	C -> Z,
	L -> N,
	L -> J,
	J -> K,
 	N->L, 
 	P -> A ,
	P M -> R,
 	O -> D,
 	L F -> I E B H,
 	E F -> L , 
	I -> L F ,
 	I P M-> G O S 
} 
-- Separados en el implicante
L1 = { 
	U -> E,
	E -> U,
	U -> C ,
	C -> Z,
	L -> N,
	L -> J,
	J -> K,
 	N -> L, 
 	P -> A ,
	P M -> R,
 	O -> D,
 	L F -> I,
	L F -> E,
	L F -> B,
	L F -> H,
 	E F -> L , 
	I -> L F ,
 	I P M-> G,
	I P M-> O,
	I P M-> S
}
-- Atributos extraños: NO HAY
L2 = { 
	U -> E,
	E -> U,
	U -> C ,
	C -> Z,
	L -> N,
	L -> J,
	J -> K,
 	N -> L, 
 	P -> A ,
	P M -> R,
 	O -> D,
 	L F -> I,
	L F -> E,
	L F -> B,
	L F -> H,
 	E F -> L , 
	I -> L F ,
 	I P M-> G,
	I P M-> O,
	I P M-> S
} 
-- Redundantes: NO HAY
RMNR= { 
	U -> E,
	E -> U,
	U -> C ,
	C -> Z,
	L -> N,
	L -> J,
	J -> K,
 	N -> L, 
 	P -> A ,
	P M -> R,
 	O -> D,
 	L F -> I,
	L F -> E,
	L F -> B,
	L F -> H,
 	E F -> L , 
	I -> L F ,
 	I P M-> G,
	I P M-> O,
	I P M-> S
} 
*/
-- AGRUPAR POR IMPLICANTE Y CREAR TABLAS EN TRANSACCION
/* SEGUN EL DIAGRAMA UN DETALLE PEDIDO TIENE UN PRODUCTO Y EL DETALLEPEDIDO CALCULA LA CANTIDAD EN LUGAR DE SER UNA RELACION CON MAXIMAS N:M Y CALCULARSE EN UNA CONSULTA*/
BEGIN;
/* TABLA1:{U,E,C}
	U -> E,
	E -> U,
	U -> C*/
CREATE TABLE clientes AS
SELECT  usuario, clienteID ,calle_cliente 
FROM tablaunica
group by clienteID,usuario,calle_cliente;

/* TABLA 2:
	C -> Z,*/
-- Problema con esta tabla, maria no tiene un domicilio o calle y genera un null hay que modificar la sentencia para que ignore nulos y luego poder asignar clave
CREATE TABLE domicilioclientes AS
SELECT  calle_cliente, zona_cliente
FROM tablaunica
group by calle_cliente, zona_cliente;

/* TABLA 3:
	L -> N,
	L -> J,
 	N -> L,*/
-- La insercion del pedido sin localID genera anomalias
CREATE TABLE locales AS
SELECT  localID, nombre_local, calle_local 
FROM tablaunica
group by localID, nombre_local, calle_local ;

/* TABLA 3:
	J -> K,*/
CREATE TABLE ubicacionlocal AS
SELECT  calle_local , zona_local 
FROM tablaunica
group by calle_local , zona_local;

/* TABLA 4:
 	P -> A ,*/
CREATE TABLE producto AS
SELECT  producto , tipo
FROM tablaunica
group by producto, tipo;

/* TABLA 5:
	P M -> R,*/
CREATE TABLE detalleproducto AS
SELECT  producto , medida , precio
FROM tablaunica
group by producto , medida , precio;

/* TABLA 6:
	O -> D,*/
CREATE TABLE ofertas AS
SELECT  nombre_oferta , descuento
FROM tablaunica
group by nombre_oferta , descuento;

/* TABLA 7:  
	L F -> I,
	L F -> E,
	L F -> B,
	L F -> H,
 	E F -> L , 
	I -> L F ,*/
CREATE TABLE pedidos AS
SELECT  localID,fecha_hora,pedidoID,clienteID, total,entrega
FROM tablaunica
group by localID,fecha_hora,pedidoID,clienteID, total,entrega;

/* TABLA 8:
	I P M-> G,
	I P M-> O,
	I P M-> S*/
CREATE TABLE detallepedidos AS
SELECT  pedidoID,producto,medida,nombre_oferta, cantidad, subtotal
FROM tablaunica
group by pedidoID,producto,medida,nombre_oferta, cantidad, subtotal;

COMMIT; 
ROLLBACK;
-- CLAVES PRIMARIAS
BEGIN;
ALTER TABLE clientes ADD PRIMARY KEY (clienteID);
ALTER TABLE domicilioclientes ADD PRIMARY KEY (calle_cliente);
ALTER TABLE locales ADD PRIMARY KEY (localID);
ALTER TABLE ubicacionlocal ADD PRIMARY KEY (calle_local);
ALTER TABLE producto ADD PRIMARY KEY (producto);
ALTER TABLE detalleproducto ADD PRIMARY KEY (producto , medida);
ALTER TABLE ofertas ADD PRIMARY KEY (nombre_oferta);
ALTER TABLE pedidos ADD PRIMARY KEY (pedidoID);
ALTER TABLE detallepedidos ADD PRIMARY KEY (pedidoID,producto,medida);
COMMIT;
-- TIENES QUE CREAR INDICES ANTES DE CREAR CLAVES FORANEAS
-- INDICES CLAVES FORANEAS
CREATE INDEX idx_calle_cliente ON clientes (calle_cliente);
CREATE INDEX idx_calle_local ON locales (calle_local);

CREATE INDEX idx_producto ON producto (producto);
CREATE INDEX idx_clientes ON clientes(clienteID);
CREATE INDEX idx_clienteID ON locales (calle_local);
CREATE INDEX idx_calle_local ON locales (calle_local);
CREATE INDEX idx_calle_local ON locales (calle_local);
-- CLAVES FORANEAS
-- UN CLIENTE TIENE UN DOMICILIO
ALTER TABLE domicilioclientes ADD CONSTRAINT fk_calle_clientes FOREIGN KEY (calle_cliente) REFERENCES clientes(calle_cliente);
-- UN LOCAL TIENE UNA UBICACION
ALTER TABLE ubicacionlocal ADD CONSTRAINT fk_calle_local FOREIGN KEY (calle_local) REFERENCES locales(calle_local);
-- UN PRODUCTO TIENE SUS DETALLES
ALTER TABLE detalleproducto ADD CONSTRAINT fk_producto FOREIGN KEY (producto) REFERENCES producto(producto);
-- UN PEDIDO TIENE SUS DETALLES
ALTER TABLE detallepedidos ADD CONSTRAINT fk_pedidoID FOREIGN KEY (clienteID) REFERENCES clientes(clienteID);
-- PEDIDO ES UNA TABLA RELACION ENTRE CLIENTE Y LOCAL
ALTER TABLE pedidos ADD CONSTRAINT fk_localID FOREIGN KEY (localID) REFERENCES locales(localID);
ALTER TABLE pedidos ADD CONSTRAINT fk_clientes FOREIGN KEY (clienteID) REFERENCES clientes(clienteID);
-- UN DETALLE DE PEDIDO TIENE UNA UNICA OFERTA
ALTER TABLE detallepedidos ADD CONSTRAINT fk_oferta FOREIGN KEY (nombre_oferta) REFERENCES ofertas(nombre_oferta);
-- UN DETALLEPEDIDO ES LA RELACION ENTRE PRODUCTO Y PEDIDO 
ALTER TABLE detallepedidos ADD CONSTRAINT fk_producto FOREIGN KEY (producto) REFERENCES clientes(producto);
ALTER TABLE detallepedidos ADD CONSTRAINT fk_pedido FOREIGN KEY (pedidoID) REFERENCES pedidos(pedidoID);
