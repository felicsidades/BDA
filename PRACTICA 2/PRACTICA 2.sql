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
CREATE INDEX idx_fecha_venta ON clientes(fecha_venta);


