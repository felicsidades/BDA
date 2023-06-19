-- Asignatura Bases de Datos Avanzadas - curso 2022-23
-- ETS Ingeniería Sistemas Informáticos - UPM

-- -----------------------------------------------------
-- Practica 2 - Script de creación de claves foraneas
-- -----------------------------------------------------
ALTER TABLE clientes ADD CONSTRAINT fk_cliente_territorio
			FOREIGN KEY (TerritorioID) REFERENCES territorioventas (TerritorioID);
ALTER TABLE subcategoriaproducto ADD CONSTRAINT fk_subcateg_categ
			FOREIGN KEY (CategoriaID) REFERENCES categoriaproducto (CategoriaID);
ALTER TABLE productos ADD CONSTRAINT fk_producto_subcateg 
			FOREIGN KEY (SubcategoriaID) REFERENCES subcategoriaproducto (SubCategoriaID);            
ALTER TABLE pedidos ADD CONSTRAINT fk_pedido_cliente
			FOREIGN KEY (ClienteID) REFERENCES clientes (ClienteID);            
ALTER TABLE pedidos ADD CONSTRAINT fk_pedidos_territorio 
			FOREIGN KEY (TerritorioID) REFERENCES territorioventas (TerritorioID);            
ALTER TABLE detallepedidos ADD CONSTRAINT fk_detalle_producto 
			FOREIGN KEY (ProductoID) REFERENCES productos (ProductoID);
ALTER TABLE detallepedidos ADD CONSTRAINT fk_detalle_pedido  
			FOREIGN KEY (PedidoID) REFERENCES pedidos (PedidoID);
