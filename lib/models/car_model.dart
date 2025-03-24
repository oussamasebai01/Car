
import 'package:flutter/material.dart';
import '../bookingCar.dart';
import '../carCardItem.dart';
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
final int availability;

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

  CarDetailsPage(
      {required this.car, required this.numberOfDays, required this.date_debut, required this.date_fin});

  late String prix_total = (numberOfDays * car.pricePerDay).toString();
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
    final imageUrl = createCarImage(car, "03", car.carColor);
    return Scaffold(
      appBar: AppBar(
        title: Text(car.modelName), // استخدام car.modelName كعنوان
        backgroundColor: Colors.green, // لون خلفية الشريط الأخضر
        elevation: 0, // إزالة الظل
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الصورة الافتراضية
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
                      height: 150, // Limite l'image à 40% de la carte
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
            SizedBox(height: 16),

            // السعر الإجمالي والسعر اليومي
            Row(
              children: [
                Text(
                  '\$${car.pricePerDay * numberOfDays}', // السعر الإجمالي
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Spacer(), // دفع النص الثاني إلى أقصى اليمين
                Text(
                  '\$${car.pricePerDay}/يوم', // السعر اليومي
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 16),

            // المعلومات الأساسية
            Text(
              'الشركة المصنعة: ${car.manufacturerName}',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            SizedBox(height: 8),
            Text(
              'المدينة: ${car.city}',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            SizedBox(height: 8),
            Text(
              'المؤسسة: ${car.institutionName}',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            SizedBox(height: 16),

            // المواصفات الفنية
            Text(
              'المواصفات',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('المقاعد', style: TextStyle(color: Colors.grey)),
                      Row(
                        children: [
                          Icon(
                            Icons.people_alt,
                            size: 24,
                            color: Colors.green,
                          ),
                          Text('  ${car.seatNumber}', style: TextStyle(
                              fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('نوع الوقود', style: TextStyle(color: Colors.grey)),
                      Row(
                        children: [
                          Icon(
                            Icons.local_gas_station,
                            size: 24,
                            color: Colors.green,
                          ),
                          Text(" " + car.gazType, style: TextStyle(
                              fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('اللون', style: TextStyle(color: Colors.grey)),
                      Row(
                        children: [
                          Icon(
                            Icons.color_lens,
                            size: 24,
                            color: Colors.green,
                          ),
                          Text("  " + car.carColor, style: TextStyle(
                              fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // ناقل الحركة
            Row(
              children: [
                Icon(
                  Icons.tune,
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

            Row(
              children: [
                Icon(
                  Icons.tag,
                  size: 24,
                  color: Colors.green,
                ),
                Text(
                  '  : ${car.tagNumber}',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ],
            ),
            // الرقم التعريفي

            SizedBox(height: 16),

            // زر "احجز الآن"
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          BookingDetailScreen(
                              date_debut: date_debut,
                              date_fin: date_fin,
                              prix_total: prix_total,
                              id: car.id,
                              car: car,),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.green, // لون الزر الأخضر
                ),
                child: Text(
                  "احجز الآن",
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