db.listing.find()
/*Mostrar el id, nombre, descripción y número de camas de todos los alojamientos 
con más de 2 baños. */
db.listing.find({},{_id:1,name:1,description:1,beds:1})
/*Mostrar el nombre, descripción y precio de todos los alojamientos con un precio entre 500 y 1000 ordenados por precio ascendente.*/
db.listing.find({price:{$gt:500,$lt:1000}},{name:1,description:1,price:1}).sort({price:1})
/*Mostrar los 10 últimos alojamientos que han recibido una reseña*/
db.listing.find({number_of_reviews:{$gt:0}},{last_scraped:1}).sort({last_scraped:1}).limit(10)
/*Mostrar todos los alojamientos de tipo 'Earth house' o 'Treehouse'*/
db.listing.aggregate({{room_type:'Earth house'},$or:{room_type:'Treehouse'}},{})
/*Mostrar todos los alojamientos que entre sus comodidades (amenities) tengan Wifi 
y permitan mascotas */
db.listing.find({ amenities: { $all: ["Wifi","Pets allowed"] } })
/*Mostrar la calle, precio y el número de habitaciones de todos los alojamientos de 
España */
db.listing.find({"address.country":{$in:["Spain"]}},{address:1,price:1,bedrooms:1})
/*Mostrar todos los alojamientos que hayan recibido al menos una reseña del usuario 
20775242 durante el año 201 */
db.listing.find({"address.country":{$in:["Spain"]}},{address:1,price:1,bedrooms:1})
/*Mostrar todos los alojamientos que en su descripción contengan la palabra 
“luminous” (tener en cuenta que puede estar en mayúscula o minúscula) */
db.listing.find({ name: { $regex: 'luminous', $options: 'i' } })
/*Mostrar todos los alojamientos en los que el tipo de cama no sea ni 'Pull‐out Sofa' ni 
'Futon'*/
db.listing.find({bed_type:{$nin:['Pull-out Sofa','Futon']}},{})
/*Mostrar todos los alojamientos en los que el número de huéspedes que pueden 
alojarse sea par */
db.listing.find({ accommodates: { $mod: [2, 0] } }, {})
/*Mostrar todos los alojamientos que estén a una distancia máxima de 200m de la 
Sagrada familia (coordenadas 2.1743558, 41.4036299). */
db.getCollection('listing').createIndex({ "address.location.coordinates" : "2dsphere" })
db.listing.aggregate([
  {
    $geoNear: {
      near: { type: "Point", coordinates: [2.1743558, 41.4036299] },
      distanceField: "distancia",
      maxDistance: 200,
      spherical: true
    }
  },
  {
    $match: {
      distancia: { $lte: 200}
    }
  }
])
