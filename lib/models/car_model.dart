import 'package:car/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
class CarModel {
  final int id;
  final String tagNumber;
  final double pricePerDay;
  final String carColor;
  final String city;
  final String gazType;
  final String transmission;
  final int seatNumber;
  final String modelName;
  final String manufacturerName;
  final String institutionName;

  CarModel({
    required this.id,
    required this.tagNumber,
    required this.pricePerDay,
    required this.carColor,
    required this.city,
    required this.gazType,
    required this.transmission,
    required this.seatNumber,
    required this.modelName,
    required this.manufacturerName,
    required this.institutionName,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      id: json['id'],
      tagNumber: json['tagNumber'],
      pricePerDay: json['price_per_day'].toDouble(),
      carColor: json['car_color'],
      city: json['city'],
      gazType: json['gaz_type'],
      transmission: json['transmission'],
      seatNumber: json['seat_number'],
      modelName: json['model']['name_en'],
      manufacturerName: json['model']['manufacture']['name_en'],
      institutionName: json['institution']['name'],
    );
  }
}

class CarDetailsPage extends StatelessWidget {
  final CarModel car;
  final int numberOfDays;

  CarDetailsPage({required this.car, required this. numberOfDays});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(car.modelName), // Utiliser car.modelName comme titre
        backgroundColor: Colors.green, // AppBar noire pour un style moderne
        elevation: 0, // Supprimer l'ombre
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image par défaut
            ClipRRect(
              borderRadius: BorderRadius.circular(12), // Bordure arrondie
              child: Image.asset(
                "assets/bmw_x5.png", // Image par défaut
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200, // Hauteur de l'image
              ),
            ),
            SizedBox(height: 16),

            // Prix total et prix par jour
            Row(
              children: [
                Text(
                  '\$${car.pricePerDay * numberOfDays}', // Prix total
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Spacer(), // Pousse le deuxième texte à l'extrême droite
                Text(
                  '\$${car.pricePerDay}/day', // Prix par jour
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Informations de base
            Text(
              'Fabricant : ${car.manufacturerName}',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            SizedBox(height: 8),
            Text(
              'Ville : ${car.city}',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            SizedBox(height: 8),
            Text(
              'Institution : ${car.institutionName}',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            SizedBox(height: 16),

            // Spécifications techniques
            Text(
              'Spécifications',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sièges', style: TextStyle(color: Colors.grey)),
                      Row(
                        children: [
                          Icon(
                            Icons.people_alt ,
                            size: 24,
                            color: Colors.green,
                          ),
                          Text('  ${car.seatNumber}', style: TextStyle(fontSize: 16)),
                        ],
                      ),

                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Carburant', style: TextStyle(color: Colors.grey)),
                      Row(
                        children: [
                          Icon(
                            Icons.local_gas_station ,
                            size: 24,
                            color: Colors.green,
                          ),
                          Text(" "+car.gazType, style: TextStyle(fontSize: 16)),
                        ],
                      ),

                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Couleur', style: TextStyle(color: Colors.grey)),
                      Row(
                        children: [
                          Icon(
                            Icons.color_lens ,
                            size: 24,
                            color: Colors.green,
                          ),
                          Text("  "+car.carColor, style: TextStyle(fontSize: 16)),
                        ],
                      ),

                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Transmission
            Row(
              children: [
                Icon(
                  Icons.tune ,
                  size: 24,
                  color: Colors.green,
                ),
                Text(
                  '    ${car.transmission}',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ],
            ),

            SizedBox(height: 16),

            Row(children: [
              Icon(
                Icons.tag ,
                size: 24,
                color: Colors.green,
              ),
              Text(
                '  : ${car.tagNumber}',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ],),
            // Tag

            SizedBox(height: 16),

            // Bouton "Book Now"
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Action pour réserver la voiture
                  // Navigator.popUntil(context, (route) => route.isFirst);
                  // Navigator.pushReplacementNamed(context, '/DashboardClient');
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.green, // Bouton noir
                ),
                child: Text(
                  "Book Now",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}