
import 'package:flutter/material.dart';
import '../bookingCar.dart';
class CarModel {
final int id;
final String tagNumber;
final double pricePerDay;
final double pricePerWeek;
final double pricePerMonth;
final double pricePerYear;
final int manu_year;
final String carColor;
final String city;
final String gazType;
final String transmission;
final int seatNumber;
final String modelName;
final String manufacturerName;
final String institutionName;
final int availability; // Ajoutez ce champ

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
required this.availability,
required this.manu_year,
required this.pricePerMonth,
required this.pricePerWeek,
required this.pricePerYear,
});
factory CarModel.fromJson(Map<String, dynamic> json) {
return CarModel(
id: json['id'] as int, // Explicitly cast to int
tagNumber: json['tagNumber'] as String, // Explicitly cast to String
pricePerDay: (json['price_per_day'] as num?)?.toDouble() ?? 0.0, // Handle null and cast to double
carColor: json['car_color'] as String,
city: json['city'] as String,
gazType: json['gaz_type'] as String,
transmission: json['transmission'] as String,
seatNumber: json['seat_number'] as int,
modelName: json['model']['name_en'] as String,
manufacturerName: json['model']['manufacture']['name_en'] as String,
institutionName: json['institution']['name'] as String,
availability: json['availability'] as int,
manu_year: int.tryParse(json['manu_year'].toString()) ?? 0, // Convert string to int
pricePerMonth: (json['price_per_month'] as num?)?.toDouble() ?? 0.0, // Handle null and cast to double
pricePerWeek: (json['price_per_week'] as num?)?.toDouble() ?? 0.0, // Handle null and cast to double
pricePerYear: (json['price_per_year'] as num?)?.toDouble() ?? 0.0, // Handle null and cast to double
);
}

// Méthode pour convertir l'objet en Map<String, dynamic>
Map<String, dynamic> toJson() {
return {
'id': id,
'price_per_year':pricePerYear,
'price_per_week':pricePerWeek,
'price_per_month':pricePerMonth,
'manu_year':manu_year.toString(),
'tagNumber': tagNumber,
'price_per_day': pricePerDay,
'car_color': carColor,
'city': city,
'gaz_type': gazType,
'transmission': transmission,
'seat_number': seatNumber,
'model': {
'name_en': modelName,
'manufacture': {
'name_en': manufacturerName,
},
},
'institution': {
'name': institutionName,
},
'availability': availability,
};
}
}

class CarDetailsPage extends StatelessWidget {
final CarModel car;
final int numberOfDays;
final String date_debut;
final String date_fin;

CarDetailsPage({required this.car, required this. numberOfDays, required this.date_debut, required this.date_fin});

late String prix_total =  (numberOfDays*car.pricePerDay).toString();

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
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => BookingDetailScreen(date_debut :date_debut , date_fin: date_fin,prix_total:prix_total,id:car.id),
),
);
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