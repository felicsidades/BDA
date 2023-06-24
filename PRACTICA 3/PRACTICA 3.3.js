db.listing.find()
//Ejercicio 1
/*A. Implementar una función map Reduce que devuelva la suma de las casas que tiene cada 
propietario */
db.listing.aggregate([
  { $group: { _id: "$_id", count: { $sum: 1 } } }
]);
/*B. Implementar la misma búsqueda con aggregate pipeline*/


db.listing.mapReduce(
// Emitimos para cada clave host el valor 1
  function() {emit(this.host,1 );},
// Agrupamos las claves y sumamos sus valores
  function(key, values) {return Array.sum(values);},
  {
    out: "cuentacasas"
  }
);
/*VER RESULTADOS*/
db.cuentacasas.find()



//Ejercicio 2 
/*Buscar casas que tengan más de 5 revisiones utilizando diferentes técnicas: */
/*C. Función pipeline aggregate */

db.listing.mapReduce(
    
  function() {
      if(this.reviews && this.reviews.length>5)
      {emit(this._id,this.reviews);}},
  function(key, values) {return Array.sum(values);},
  {
    out: "cuentarevisiones"
  }
);

/*D. Operador $expr */
db.listing.find({ $expr: { $gt: [{ $size: "$reviews" }, 5] } })

/*E. Operador $where */
// ESTA ULTIMA NO MUESTRA RESULTADO
db.listing.find({$where: function() {
    return this.reviews && this.reviews.length >5;
  }
});


// VER RESULTADOS
db.cuentarevisiones.find()


db.listing.find()
//Ejercicio 3
/*F. Mostrar el número medio de camas que hay en cada market (campo address.market) de los 
Estados Unidos (US). Ignorar aquellos alojamientos cuyo market sea vacio */
db.listing.aggregate([
  {$match: {'address.country_code': "US"}},
  {$group: {_id: "$address.market", avgBeds: {$avg: "$beds"}}}
])
/*G. Mostrar el precio medio de un alojamiento por pais y market. Ignorar aquellos alojamientos 
cuyo market sea vacio y mostrar los resultados ordenados por pais y market de manera 
alfabética */
db.listing.aggregate([
  {$group: {_id: ["$address.market","$address.country"], avgprice: {$avg: "$price"}}}
])
/*H. Mostrar el precio medio por país de alquilar un alojamiento que permita mascotas (debe 
contener el amenity "Pets allowed"). Mostrar los resultados ordenados del país más caro al 
más barato*/
db.listing.aggregate([
    {$match: {amenities: 'Pets allowed'}},
    {$group: {_id: "$address.country", avgprice: {$avg: "$price"}}},
    { $sort: { avgprice: -1 } }
])