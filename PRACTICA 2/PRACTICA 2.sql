/* Crear una consulta SQL que permita obtener el nombre de los productos que figuren en algún
detalle de pedido con más de 5 unidades vendidas (atributo cantidad) sin que figuren valores
duplicados en el resultado. Definir diferentes variantes de la consulta de forma que se aprecien*/
-- 1
select nombre_producto
from productos 
where productoID in(select productoID
					from detallepedidos
					where cantidad > 5
					group by ProductoID);
-- 16389.29
-- Clave primaria: 16657.80
-- Clave secundaria: 228.05
-- 2
select nombre_producto
from productos p inner join detallepedidos d
on p.ProductoID=d.ProductoID
where cantidad>5 
group by nombre_producto;
-- 2050256.24
-- Clave primaria: 46805.72
-- Clave secundaria: 228.05
-- Clave secundaria: 228.05
ALTER TABLE detallepedidos DROP CONSTRAINT fk_detalle_producto;
ALTER TABLE detallepedidos ADD CONSTRAINT fk_detalle_producto 
			FOREIGN KEY (ProductoID) REFERENCES productos (ProductoID);
            
-- Un indice sobre cantidad hay 121317 detalle pedidos y solo 10225 mayores que 5 es un buen candidato
CREATE INDEX idx_cantidad ON detallepedidos(cantidad);    
DROP INDEX idx_cantidad ON detallepedidos;
select count(*)
from detallepedidos
where cantidad > 5;
select count(*)
from detallepedidos;
-- El indice reduce el coste total
/*b. Crear una consulta SQL que permita obtener el nombre de los productos de categoría Componente,
subcategoría que contenga con la palabra Cuadro, y color Blue, que se hayan vendido en más
pedidos a lo largo del tiempo que todos los productos de las subcategorías Dirección o Horquilla. */
select nombre_producto
from productos pr inner join subcategoriaproducto s on pr.subcategoriaID=s.subCategoriaID
inner join categoriaproducto c on c.categoriaID=s.categoriaID
inner join detallepedidos d on d.ProductoID=pr.ProductoID
inner join pedidos pe on pe.PedidoID=d.PedidoID
where nombre_categoria = 'Componente'
and nombre_subcategoria like '%Cuadro%'
and color='Blue'
group by nombre_producto
having count(*)>(select count(*)
				from productos pr inner join subcategoriaproducto s on pr.subcategoriaID=s.subCategoriaID
				inner join categoriaproducto c on c.categoriaID=s.categoriaID
				inner join detallepedidos d on d.ProductoID=pr.ProductoID
				inner join pedidos pe on pe.PedidoID=d.PedidoID
                where nombre_categoria='Dirección')
                or
                (select count(*)
				from productos pr inner join subcategoriaproducto s on pr.subcategoriaID=s.subCategoriaID
				inner join categoriaproducto c on c.categoriaID=s.categoriaID
				inner join detallepedidos d on d.ProductoID=pr.ProductoID
				inner join pedidos pe on pe.PedidoID=d.PedidoID
                where nombre_categoria='Horquilla');

/*INDICE DEL ENUNCIADO*/
create unique index categoria_nombrecategoria on categoriaproducto (nombre_categoria); 
DROP index categoria_nombrecategoria on categoriaproducto; 
-- El coste sin indice: 289.67
-- El coste con indice:437.05
-- El indice aumenta el coste
-- RESPUESTA
/* Segun la explicación de explain cuando no usamos un índice el optimizador filtra por la clausula where, lo que al menos en tres ocasiones reduce las filas en mas de un 50%,
 no obstante al utilizar el indice siempre devuelve el 100% de las filas*/
explain select nombre_producto
from productos pr inner join subcategoriaproducto s on pr.subcategoriaID=s.subCategoriaID
inner join categoriaproducto c ignore index (categoria_nombrecategoria) on c.categoriaID=s.categoriaID
inner join detallepedidos d on d.ProductoID=pr.ProductoID
inner join pedidos pe on pe.PedidoID=d.PedidoID
where nombre_categoria = 'Componente'
and nombre_subcategoria like '%Cuadro%'
and color='Blue'
group by nombre_producto
having count(*)>(select count(*)
				from productos pr inner join subcategoriaproducto s on pr.subcategoriaID=s.subCategoriaID
				inner join categoriaproducto c on c.categoriaID=s.categoriaID
				inner join detallepedidos d on d.ProductoID=pr.ProductoID
				inner join pedidos pe on pe.PedidoID=d.PedidoID
                where nombre_categoria='Dirección')
                or
                (select count(*)
				from productos pr inner join subcategoriaproducto s on pr.subcategoriaID=s.subCategoriaID
				inner join categoriaproducto c on c.categoriaID=s.categoriaID
				inner join detallepedidos d on d.ProductoID=pr.ProductoID
				inner join pedidos pe on pe.PedidoID=d.PedidoID
                where nombre_categoria='Horquilla');
                
/*4. Dada la siguiente consulta SQL: */
select c.primer_nombre, c.apellidos
from pedidos p inner join clientes c on p.clienteID = c.clienteID
 inner join detallepedidos d ON p.PedidoID = d.PedidoID
where year(c.fecha_nacimiento) between 1980 and 1986 and genero = "F" and
 c.ingresos_anuales >= (
 select MAX(ingresos_anuales) AS `90th_percentile`
 from (
	 select ingresos_anuales, PERCENT_RANK() OVER (ORDER BY ingresos_anuales)
	 AS percentile_rank
	 from clientes
	 where year(fecha_nacimiento) between 1970 and 1980 and genero = "F"
	 ) AS ranked_sales
 where percentile_rank <= 0.9
 )
group by c.clienteID
having sum((precio_unitario - descuento_unitario) * cantidad) >= (
	 select avg(total)
	 from (
		 select sum( (precio_unitario - descuento_unitario) * cantidad) as total
		 from pedidos p inner join detallepedidos d ON p.PedidoID = d.PedidoID
		 where year(fecha_venta) = 2021
		 group by clienteID
		 ) as totales2021
);

-- RESPUESTA
/*Busca aquellos`por encima del percentil 90 que se hayan gastado mas dinero que la media de lo gastado en el año 2021*/
-- ELIMINAR INDICES
DROP index categoria_nombrecategoria on categoriaproducto; 
-- RESPUESTA
-- Original "query_cost": "2812.62"
-- fecha nacimiento no mejora la consulta
CREATE INDEX idx_fecha_nacimiento_anio ON clientes(fecha_nacimiento);
CREATE INDEX idx_fecha_venta ON pedidos(fecha_venta);

/*5. Estudio de índices en actualizaciones. */
/*a. Eliminar los índices creados en el apartado anterior manteniendo claves primarias y foráneas. */
DROP index categoria_nombrecategoria on categoriaproducto; 
drop INDEX idx_fecha_nacimiento_anio ON clientes;
drop INDEX idx_fecha_venta ON pedidos;
/*b. Para aquellos pedidos realizados a lo largo del año 2023, incrementar el descuento unitario en un
1% para los productos vendidos con categoría Bicicleta y que ya tuvieran descuento, es decir, sea
distinto de 0. Actualizar la tabla detallepedidos para que contemple dicho incremento tomando
nota de su tiempo, plan y coste de ejecución. Deshacer el cambio con ‘rollback’.*/
start transaction;
update detallepedidos d
inner join productos pr on pr.productoID=d.productoID
inner join pedidos pe on pe.pedidoID=d.pedidoID
inner join subcategoriaproducto s on s.subCategoriaID=pr.subCategoriaID
inner join categoriaproducto c on c.categoriaID=s.categoriaID
set descuento_unitario=descuento_unitario-1
where fecha_venta like'2023%' 
and descuento_unitario <> 0;
rollback;
/*c. Suponiendo la existencia de otros procesos actuando sobre la misma base de datos que requieren
para optimizar cierto tipo de consultas de un índice en la tabla detalleproductos sobre los atributos
producotid, precio_unitario y descuento_unitario, crear dicho índice mediante la siguiente
sentencia sql: */
start transaction;
create index idx_detalleproductoprecio on detallepedidos (ProductoID, precio_unitario,descuento_unitario); 
rollback;


/*6. Desnormalización. */	

ALTER TABLE detallepedidos DROP FOREIGN KEY idx_detalleproductoprecio;
ALTER TABLE detallepedidos DROP INDEX idx_detalleproductoprecio;
/*b. Crear una consulta que devuelva, para cada pedido el nombre del cliente, su país, la fecha del
pedido, el total del pedido calculado como la suma de los detalles de cada pedido (precio_unitario
– descuento_unitario) * cantidad. Tomar nota del coste y plan de ejecución. */
select primer_nombre,segundo_nombre,pe.pedidoID,sum((precio_unitario-descuento_unitario)*cantidad) as sumatotal
from pedidos pe 
inner join detallepedidos d on d.pedidoID=pe.pedidoID
inner join clientes c on pe.clienteID=c.clienteID
group by pedidoID;
-- "query_cost": "21048.88"
/*c. Aplicar la técnica o técnicas de desnormalización que se consideren más adecuadas para acelerar
la consulta anterior, creando los scripts sql necesarios para modificar el esquema de la base de
datos. */
start transaction;
ALTER TABLE pedidos ADD sumatotal float DEFAULT 0;
UPDATE pedidos p 
INNER JOIN (
  SELECT pedidoID, SUM((precio_unitario - descuento_unitario) * cantidad) AS total
  FROM detallepedidos
  GROUP BY pedidoID
) d ON d.pedidoID = p.pedidoID
SET p.sumatotal = d.total;
rollback;

-- TRIGGERS
DELIMITER $$
CREATE TRIGGER actualizarsuma
AFTER INSERT
ON detallepedidos
FOR EACH ROW
BEGIN
    UPDATE pedidos p 
    INNER JOIN (
      SELECT pedidoID, SUM((precio_unitario - descuento_unitario) * cantidad) AS total
      FROM detallepedidos
      GROUP BY pedidoID
    ) d ON d.pedidoID = p.pedidoID
    SET p.sumatotal = d.total;
END $$
DELIMITER ;





