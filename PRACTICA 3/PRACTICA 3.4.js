/*A. Buscar las personas que tengan más de 50 años*/
MATCH (p:Person)
WHERE (2023 - p.born) > 50
RETURN p

/*B. Haz una consulta que muestre a todas las personas menores de 50 años que hayan actuado
en al menos una película.*/
MATCH (p:Person)-[r:ACTED_IN]->(m)
WHERE (2023 - p.born) < 50
RETURN p, r, m

/*C. Haz una consulta que muestre todas las relaciones que unen a una persona con otra persona
sin importar la etiqueta que tengan.*/
match (p:Person)-[r]-(n:Person)
return p

/*D. Buscar las personas que han dirigido por lo menos 3 películas*/
MATCH (p:Person)-[r:DIRECTED]->(m:Movie)
WITH p,count(r) as directedMovies
WHERE directedMovies >= 3
RETURN p,directedMovies

/*E. Haz una consulta que muestre todas las películas que han sido dirigidas por dos o más
personas.*/
MATCH (m:Movie)-[r:DIRECTED]->(p:Person)
WITH m, count(p) as directors
WHERE directors > 1
RETURN m, directors

/*F. Haz una consulta que inserte un nodo con etiqueta Person en el grafo (da igual si los valores
de los atributos son inventados, no tienes por qué poner tus datos personales si no quieres).*/
CREATE (:Person {name:"Felix"})

/*G. Haz una consulta que cree una review (Etiqueta REVIEW) de una película de la base de datos
a tu elección (usa el nodo Person creado en la pregunta anterior).*/
MATCH (a:Person {name: 'Felix'}), (m:Movie {title: 'V for Vendetta'})
CREATE (a)-[:REVIEWED]->(m)

/*H. Define que el texto de la review tiene que ser único en la base de datos y no debe de
permitir la creación de repetidos.*/
CREATE CONSTRAINT FOR ()-[r:REVIEWED]-()
REQUIRE (r.summary) IS UNIQUE

/*I. Eliminare la restricción que has creado anteriormente*/
//ESTO TIENES QUE BUSCARLOPOR NOMBRE PORQUE SI NO NO TE DEJA BORRARLO
drop constraint constraint_fcfa27d9

/*J. Trasformar el modelo en grafo en un modelo tabular que devuelva una table con nombre,
legación y nombre de la película ordenado por nombre de actor.*/
//EL NOMBRE DE LA RELACION TIENE QUE OBTENERSE CON TYPE(R) NO CON T.TYPE POR NINGUNA RAZON APARENTE
MATCH (p:Person)-[r:%]->(m:Movie)
RETURN p.name AS nombre, type(r) AS relacion, m.title as titulo
