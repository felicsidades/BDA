SELECT * FROM practica1bda_tablaunica.tablaunica;

-- SESION 1
/*1. A partir del conjunto de dependencias funcionales (L), completar los requisitos del sistema en lenguaje natural. ¿Puede servir un local a clientes de fuera de su zona? ¿Son
los descuentos acumulables, es decir, puedo aplicar dos descuentos distintos al mismo pedido? Indica que dependencias funcionales o la ausencia de estas te permiten
responder a las preguntas anteriores. */
-- RESPUESTA
-- No hay ninguna relacion en que K sea el implicante luego no hay restricciones
-- Una oferta tiene un solo descuento O -> D
-- A un pedido con un producto y una medida le corresponde una unica oferta D no pertenece al cierre (I)+ luego puedes tener dos descuento

/*2. Determinar el nivel de normalización de la relación TablaUnica, calculando todas las claves existentes. Mediante sentencias SQL se definirán en MySql TODAS las claves
encontradas para esta tabla. */
-- RESPUESTA
-- CLAVES: CLAVE(IPM),CLAVE(LFPM),CLAVE(EFPM),CLAVE(UFPM),CLAVE(NFPM)
-- ESTA EN 1FN Dado que E X->Y / X es un subconjunto de la clave L F -> I E B H,
-- SOLO SE PUEDE CREAR UNA CLAVE PRINCIPAL
ALTER TABLE tablaunica ADD PRIMARY KEY (pedidoID,producto,medida);
-- ALTER TABLE tablaunica ADD PRIMARY KEY (localID,fecha_hora,producto,medida);
-- ALTER TABLE tablaunica ADD PRIMARY KEY  (clienteID,fecha_hora,producto,medida);
-- ALTER TABLE tablaunica ADD PRIMARY KEY  (usuario,fecha_hora,producto,medida);
-- ALTER TABLE tablaunica ADD PRIMARY KEY  (nombre_local,fecha_hora,producto,medida);
CREATE INDEX key_segunda ON tablaunica (localID,fecha_hora,producto,medida);
CREATE INDEX key_tercera ON tablaunica (clienteID,fecha_hora,producto,medida);
CREATE INDEX key_cuarta ON tablaunica (usuario,fecha_hora,producto,medida);
CREATE INDEX key_quinta ON tablaunica (nombre_local,fecha_hora,producto,medida);

/*3. Resolver en SQL las siguientes consultas: */
/*a. Obtener el número de clientes que han realizado pedidos entregados en Local.*/
SELECT clienteID
from tablaunica
where clienteID in(SELECT clienteID
					FROM practica1bda_tablaunica.tablaunica
					WHERE entrega = 'Local'
					GROUP BY clienteID)
GROUP BY clienteID;
/*Obtener para cada pedido registrado el día 12 de febrero de 2023 que no incluya ningún tipo de oferta, el nombre del local, el nombre y medida del producto y
su tipo. Ordenar el resultado por nombre del producto y nombre del local. */
select producto, tipo, medida
from tablaunica
where fecha_hora like '%2023-02-12%'
and nombre_oferta is null
order by producto,nombre_local;
/*c. Obtener por cada nombre de local la suma total cobrada para los pedidos que incluyan pizzas. */
select nombre_local,sum(total)
from tablaunica
group by nombre_local;

/*4. Insertar mediante SQL, si es posible, (manteniendo las claves primarias creadas) los siguientes datos, explicando los problemas y anomalías encontradas en caso de poder
insertarlos. Para las inserciones en tablaunica se dejarán a nulo los valores que no figuren en el apartado, mientras que para las inserciones en la base de datos normalizada
se obtendrán, de ser posible, mediante consultas a la propia base de datos. Hacer uso de transacciones con acción ROLLBACK para comprobar resultados sin modificar el
contenido de las bases de datos. */
-- TABLAUNICA
/*a. Los datos de un nuevo local de la cadena de pizzerías con identificador 4, nombre La Cuarta, y situada en la calle Venus y zona 3
No se puede insertar debido a que la clave principal es nula*/
insert into tablaunica(localID,nombre_local,calle_local,zona_local)
value(4,'La Cuarta','Venus',3);
/* b. Los datos de un nuevo pedido (identificador 344) del cliente zampa con identificador 25, al local "La Primera" (identificador 1) de una Pizza Cuatro quesos el 28 de
febrero de 2023 a las 21:00 por un importe total de 18€ y entrega a domicilio. */
-- No se puede insertar, una parte de la clave principal no tiene valor
insert into tablaunica(pedidoID,usuario,clienteID,nombre_local,localID,producto,fecha_hora,total,entrega)
value(344,'zampa',25,'La Primera',1,'Pizza Cuatro quesos','2023-02-28 21:00:00',18,'Domicilio');
/*c. Los datos de un nuevo pedido (identificador 501) a domicilio del cliente new23 (identificador 35) de la calle Marte y zona 2, a la pizzería “La Primera” de 2 Pizza
Vegana de tamaño mediano acogiéndose a la oferta de 2x1 a domicilio, con valor subtotal y total de 13€.*/
insert into tablaunica(pedidoID,usuario,clienteID,calle_local,zona_local,nombre_local,cantidad,producto,medida,nombre_oferta,subtotal,total)
value(501,'new23',35,'Marte',2,'La Primera',2,'Pizza Vegana','Mediana','2x1 domicilio',13,13);
/* Los datos de un nuevo pedido (identificador 223) de recogida en local del cliente maria1 (identificador 3), a la pizzería “La Primera” de la calle Luna (zona 3), de 1
Pizza Carbonara familiar por un precio de 18€ (sin descuentos) con fecha de “14/02/2023 21:45:00”. */
-- El formato de la fecha_hora es erróneo
insert into tablaunica(pedidoID,entrega,usuario,clienteID,nombre_local,calle_local,zona_local,cantidad,producto,medida,fecha_hora)
value(223,'Local','maria1',3,'La Primera','Luna',3,1,'Pizza Carbonara','Familiar','14/02/2023 21:45:00');

/*5. Realizar los siguientes cambios en los datos mediante SQL explicando los problemas y anomalías encontradas: */
/*a. Cambiar la zona de la calle Sol a valor 4.*/
-- Error safe mode 
-- No se han producido anomalias
update tablaunica
set zona_cliente=4
where calle_cliente ='Sol';
/*b. Debido a un error, se debe cancelar el pedido 170, eliminando los datos de dicho pedido.*/
-- ANOMALIA: Se han perdido los datos del usuario marta23
delete from tablaunica
where pedidoID=170;


