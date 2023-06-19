-- Asignatura Bases de Datos Avanzadas - curso 2022-23
-- ETS Ingeniería Sistemas Informáticos - UPM

-- -----------------------------------------------------
-- Practica 2 -Consulta del apartado 4
-- -----------------------------------------------------

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
             where year(fecha_nacimiento) between 1970  and 1980 and genero = "F"
           ) AS ranked_sales
     where percentile_rank <= 0.9
    )
group by c.clienteID, c.primer_nombre, c.apellidos
having sum((precio_unitario - descuento_unitario) * cantidad) >= (
       select avg(total) 
       from (
             select sum( (precio_unitario - descuento_unitario) * cantidad) as total
             from pedidos p inner join detallepedidos d ON p.PedidoID = d.PedidoID
             where year(fecha_venta) = 2021
             group by clienteID
) as totales2021
);


