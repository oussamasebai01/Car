import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../models/car_model.dart';
import 'add_car.dart';

class CarDetailsPageI extends StatelessWidget {
  final CarModel car;

  CarDetailsPageI({required this.car});

  // دالة لإنشاء رابط صورة السيارة
  String createCarImage(CarModel car, String angle, String color) {
    final url = Uri.https("cdn.imagin.studio", "/getimage");

    final manuYear = car.manu_year;
    final modelName = car.modelName; // اسم الموديل
    final manufacturerName = car.manufacturerName; // اسم الصانع

    final params = {
      "customer": "img", // مفتاح API
      "zoomType": "relative", // نوع التكبير
      "paintdescription": color, // لون السيارة
      "modelFamily": modelName.split(" ")[0], // أول كلمة من اسم الموديل
      "make": manufacturerName, // الصانع
      "modelYear": "$manuYear", // سنة التصنيع
      "angle": angle, // زاوية الصورة
      "width": "800", // عرض الصورة
    };

    return url.replace(queryParameters: params).toString();
  }

  @override
  Widget build(BuildContext context) {
    // إنشاء رابط الصورة
    final imageUrl = createCarImage(car, "03", car.carColor);

    return Scaffold(
      appBar: AppBar(
        title: Text(car.modelName!), // استخدام اسم الموديل كعنوان
        backgroundColor: Colors.green, // لون خلفية AppBar
        elevation: 0, // إزالة الظل
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة السيارة الديناميكية
            ClipRRect(
              borderRadius: BorderRadius.circular(12), // حواف مدورة
              child: FutureBuilder(
                future: precacheImage(NetworkImage(imageUrl), context),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    // إذا تم تحميل الصورة، عرضها
                    return Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 200, // ارتفاع الصورة
                    );
                  } else {
                    // أثناء التحميل، عرض مؤشر تقدم
                    return Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 16),

            // السعر اليومي
            Row(
              children: [
                Spacer(), // دفع النص إلى اليمين
                Text(
                  '\$${car.pricePerDay}/يوم', // السعر اليومي
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 16),

            // المعلومات الأساسية
            Text(
              'الصانع: ${car.manufacturerName}',
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
                          Text('  ${car.seatNumber}',
                              style: TextStyle(fontSize: 16)),
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
                          Text(" " + car.gazType!,
                              style: TextStyle(fontSize: 16)),
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
                          Text("  " + car.carColor!,
                              style: TextStyle(fontSize: 16)),
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

            // رقم اللوحة
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

            SizedBox(height: 16),

            // زر "تحديث المعلومات"
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddInstitutionCarScreen(isEdit: true, tempCar: car.toJson()),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.green, // لون الزر
                ),
                child: Text(
                  "تحديث المعلومات",
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