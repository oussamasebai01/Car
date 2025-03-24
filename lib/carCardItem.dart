import 'package:flutter/material.dart';
import 'models/car_model.dart';

class CarCardItem extends StatefulWidget {
  final CarModel car;

   CarCardItem({Key? key, required this.car}) : super(key: key)
   {}
  @override
  _CarCardItemState createState() => _CarCardItemState();
}
class _CarCardItemState extends State<CarCardItem> {
  // Fonction pour générer l'URL de l'image
  String createCarImage(CarModel car, String angle, String color) {
    // Base API URL for generating car images
    final url = Uri.https("cdn.imagin.studio", "/getimage");

    // Destructure the necessary properties from the car object
    final manuYear = car.manu_year;
    final modelName = car.modelName; // Get the model name in English
    final manufacturerName = car.manufacturerName; // Get the manufacturer name

    // Append query parameters for the API request
    final params = {
      "customer": "img", // API key
      "zoomType": "relative", // Zoom type
      "paintdescription": color, // Example color
      "modelFamily": modelName.split(" ")[0], // First word of the model name
      "make": manufacturerName, // Car make
      "modelYear": "$manuYear", // Manufacturing year
      "angle": angle, // Car angle
      "width": "800",
    };

    // Return the constructed URL as a string
    return url.replace(queryParameters: params).toString();
  }


@override
  Widget build(BuildContext context) {
  // Générer l'URL de l'image
  final imageUrl = createCarImage(widget.car, "03", widget.car.carColor);
    return Card(
      elevation: 4, // Ombre pour un effet visuel
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Bordure arrondie
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image par défaut
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: FutureBuilder(
              future: precacheImage(NetworkImage(imageUrl), context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  // Si l'image est chargée, l'afficher
                  return Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 90, // Limite l'image à 40% de la carte
                  );
                } else {
                  // Pendant le chargement, afficher un indicateur de progression
                  return Container(
                    height: 90,
                    color: Colors.grey[300],
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
              },
            ),
          ),
          // Contenu de la carte
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nom du modèle et fabricant
                Text(
                  widget.car.modelName!,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  widget.car.manufacturerName!,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 16),
                // Prix par jour
                Row(
                  children: [
                    Icon(Icons.attach_money, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "\$${widget.car.pricePerDay}/day",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Informations supplémentaires (sièges et carburant)
                Row(
                  children: [
                    // Nombre de sièges
                    Row(
                      children: [
                        Icon(Icons.people, color: Colors.grey[600], size: 20),
                        SizedBox(width: 8),
                        Text(
                          "${widget.car.seatNumber} seats",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
