/*Ejercicio 1 */
/*Insertar los dos documentos JSON en el catálogo listing. Analizar las diferencias en los dos 
documentos y los riesgos para las aplicaciones que usen esta base de datos.  */
db.listing.findOne()
/*UNO*/
db.listing.insertOne(
  {
    _id:"99999999",
    listing_url:"https://github.com/felicsidades/BDA.git",
    name:"my-house",
    summary:"my fucking house",
    space:"none"
  }
)
/*VARIOS*/
db.movies.insertMany([
  {
    _id:"55555555",
    listing_url:"https://github.com/felicsidades/BDA.git",
    name:"another one",
    summary:"some other fucking house",
    space:"some"
  },
  {
    _id:"44444444",
    listing_url:"https://github.com/felicsidades/BDA.git",
    name:"soldado de cristo porque te ocultas",
    summary:"el demonio de babilonia se oculta tras la tunica del justo",
    space:"some"
  }
])
db.listing.find({_id:"99999999"})
/*Ejercicio 2 */
/*
a. nombre no puede ser nulo y es un string 
b. edad es in integer entre 0 y 120 
c. especialidad puede ser o general o pediatria o neurología. 
d. Se añade un campo (no obligatorio) nif que tiene que tener un formado de 8 dígitos 
seguidos de letra en mayúsculas, sin separadores ni espacios
*/
/*BORRAR EN CASO NECESARIO*/
db.pacientes.drop()
/**/
db.createCollection("pacientes", {
   validator: {
      $jsonSchema: {
         bsonType: "object",
         title: "Pacientes Object Validation",
         required: [ "nombre", "edad", "especialidad", "diagnostico" ],
         properties: {
            nombre: {
               bsonType: "string",
               description: "'name' must be a string and is required"
            },
            edad: {
               bsonType: "int",
               minimum: 0,
               maximum: 120,
               description: "edad es in integer entre 0 y 120 "
            },
            especialidad: {
               "enum": ["general","pediatria","neurología"],
               description: "especialidad puede ser o general o pediatria o neurología. "
            },
            nif: {
               "bsonType": "string",
                pattern: "^[0-9]{8}$",
                description: "Se añade un campo (no obligatorio) nif que tiene que tener un formado de 8 dígitos seguidos de letra en mayúsculas, sin separadores ni espacios"
            }
         }
      }
   }
} )
/*TESTEANDO*/
db.pacientes.insertOne(
  {
    nombre:"felix",
    edad:23,
    especialidad:"general",
    diagnostico:"Jodidamente diabético",
  }
)
db.pacientes.insertOne(
  {
    nombre:"novalidoedad",
    edad:140,
    especialidad:"general",
    diagnostico:"Jodidamente diabético",
  }
)
db.pacientes.insertOne(
  {
    nombre:"novalidespecialidad",
    edad:23,
    especialidad:"endocrinologia",
    diagnostico:"Jodidamente diabético",
  }
)
db.pacientes.insertOne(
  {
    nombre:"novalidenif",
    edad:23,
    especialidad:"endocrinologia",
    nif:99999999999999999999999999999
  }
)
/*BUSCA*/
db.pacientes.find()


/*jercicio 3 */
/*Crear una colección de series temporales para poder almacenar datos de calidad de aire de una 
pagina web de sensores ambientales públicos. */
/*BORRAR*/
db.estaciones.drop()
/*----------*/

db.createCollection(
    "estaciones",
    {
       timeseries: {
          timeField: "timeglobal",
          metaField: "data",
          granularity: "hours"
       },
       expireAfterSeconds: 86400
    }
)
/*Para que nos acepte las inserciones el tiempo tiene que ser un atributo directo de la clase y tener un formato
, como ambos pollutants tienen la misma fecha se saca fuera con nombre timeglobal y hacemos que el campo timestamp sea igual
a este */
db.estaciones.insertMany([
  {
    "id": "BEI001",
    "cityName": "Beijing",
    "stationName": "Dongcheng",
    "localName": "\u4e1c\u57ce\u4e1c\u56db",
    "latitude": 39.929,
    "longitude": 116.417,
    "timeglobal": ("2023-06-21T07:00:00Z"),
    "pollutants": [
      {
        "pol": "PM2.5",
        "unit": "mg\/m3",
        "timestamp": ("2023-06-21T07:00:00Z"),
        "value": 18.7,
        "averaging": "1 hour"
      },
      {
        "pol": "Ozone",
        "unit": "ppb",
        "timestamp": ("2023-06-21T07:00:00Z"),
        "value": 12.1,
        "averaging": "1 hour"
      }
    ]
  },
  {
    "id": "BEI002",
    "cityName": "Beijing",
    "stationName": "WestPark",
    "localName": "\u897f\u57ce\u5b98\u56ed",
    "latitude": 39.929,
    "longitude": 116.417,
    "timeglobal": ("2023-06-21T07:00:00Z"),
    "pollutants": [
      {
        "pol": "PM10",
        "unit": "mg\/m3",
        "timestamp": ("2023-06-21T07:00:00Z"),
        "value": 18.7,
        "averaging": "1 hour"
      },
      {
        "pol": "Humidity",
        "unit": "%",
        "timestamp": ("2023-06-21T07:00:00Z"),
        "value": 88.8,
        "averaging": "1 hour"
      }
    ]
  }
]);



/*COMPRUEBA*/
db.estaciones.find({})