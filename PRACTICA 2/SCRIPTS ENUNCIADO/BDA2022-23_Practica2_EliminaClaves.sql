-- Asignatura Bases de Datos Avanzadas - curso 2022-23
-- ETS Ingeniería Sistemas Informáticos - UPM

-- -----------------------------------------------------
-- Practica 2 - Script de eliminación de claves foraneas y primarias
-- -----------------------------------------------------

-- Eliminar las claves foraneas
ALTER TABLE clientes DROP FOREIGN KEY fk_cliente_territorio;
DROP INDEX fk_cliente_territorio ON clientes;
ALTER TABLE subcategoriaproducto DROP CONSTRAINT fk_subcateg_categ;
DROP INDEX fk_subcateg_categ ON subcategoriaproducto;
ALTER TABLE productos DROP CONSTRAINT fk_producto_subcateg;
DROP INDEX fk_producto_subcateg ON productos;            
ALTER TABLE pedidos DROP CONSTRAINT fk_pedido_cliente; 
DROP INDEX fk_pedido_cliente ON pedidos;           
ALTER TABLE pedidos DROP CONSTRAINT fk_pedidos_territorio;   
DROP INDEX fk_pedidos_territorio ON pedidos;         
ALTER TABLE detallepedidos DROP CONSTRAINT fk_detalle_producto;
ALTER TABLE detallepedidos DROP CONSTRAINT fk_detalle_pedido;
DROP INDEX fk_detalle_producto ON detallepedidos;
-- DROP INDEX fk_detalle_pedido ON pedidos;

-- Eliminar las claves primarias
ALTER TABLE clientes DROP PRIMARY KEY;
ALTER TABLE categoriaproducto DROP PRIMARY KEY;
ALTER TABLE subcategoriaproducto DROP PRIMARY KEY;
ALTER TABLE productos DROP PRIMARY KEY;
ALTER TABLE detallepedidos DROP PRIMARY KEY;
ALTER TABLE pedidos DROP PRIMARY KEY;
ALTER TABLE territorioventas DROP PRIMARY KEY;