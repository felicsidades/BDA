-- Asignatura Bases de Datos Avanzadas - curso 2022-23
-- ETS Ingeniería Sistemas Informáticos - UPM

-- -----------------------------------------------------
-- Practica 2 - Script de creación de claves principales
-- -----------------------------------------------------

USE practica2bda22_23;

ALTER TABLE clientes ADD PRIMARY KEY (ClienteID);
ALTER TABLE categoriaproducto ADD PRIMARY KEY (CategoriaID);
ALTER TABLE subcategoriaproducto ADD PRIMARY KEY (SubCategoriaID);
ALTER TABLE productos ADD PRIMARY KEY (ProductoID);
ALTER TABLE detallepedidos ADD PRIMARY KEY (PedidoID, detalle_pedidoID);
ALTER TABLE pedidos ADD PRIMARY KEY (PedidoID);
ALTER TABLE territorioventas ADD PRIMARY KEY (TerritorioID);
