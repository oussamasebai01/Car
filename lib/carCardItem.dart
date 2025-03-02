import 'package:flutter/material.dart';
import 'models/car_model.dart';

class CarCardItem extends StatelessWidget {
  final CarModel car;

  const CarCardItem({required this.car});

  @override
  Widget build(BuildContext context) {
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
            child: Image.asset(
              "assets/bmw_x5.png", // Image par défaut
              fit: BoxFit.cover,
              width: double.infinity,
              height: 90, // Hauteur de l'image
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
                  car.modelName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  car.manufacturerName,
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
                      "\$${car.pricePerDay}/day",
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
                          "${car.seatNumber} seats",
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