import 'package:car/models/Finished.dart';
import 'package:car/utils/config.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FinishedScreen extends StatefulWidget {
  @override
  _FinishedScreenState createState() => _FinishedScreenState();
}

class _FinishedScreenState extends State<FinishedScreen> {
  late Future<List<Finished>> futureFinishedClients;
  final Map<int, bool> _expandedCards = {};

  @override
  void initState() {
    super.initState();
    futureFinishedClients = fetchFinishedClients();
  }

  // Function to fetch finished clients from the API
  Future<List<Finished>> fetchFinishedClients() async {
    // Retrieve the authentication token from shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token'); // Replace 'auth_token' with your key

    if (token == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }

    final response = await http.get(
      Uri.parse('${Config.BASE_URL}/finished-by-institution'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Parse the response as a JSON object
      Map<String, dynamic> responseBody = jsonDecode(response.body);

      // Extract the list of bookings from the 'data' field
      List<dynamic> data = responseBody['data'];

      // Map the list of JSON objects to a list of Finished objects
      List<Finished> finishedClients = data.map((dynamic item) => Finished.fromJson(item)).toList();
      return finishedClients;
    } else {
      throw Exception('فشل في تحميل الحجوزات المنتهية: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الحجوزات المنتهية', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green, // Green theme for the app bar
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // Custom back button
          onPressed: () {
            // Navigate to /DashboardInstitution
            Navigator.pushReplacementNamed(context, '/dashboardinstitution');
          },
        ),
      ),
      body: FutureBuilder<List<Finished>>(
        future: futureFinishedClients,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.green));
          } else if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error}', style: TextStyle(color: Colors.red)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('لا توجد حجوزات منتهية.', style: TextStyle(color: Colors.grey)));
          } else {
            List<Finished> finishedClients = snapshot.data!;
            return ListView.builder(
              itemCount: finishedClients.length,
              itemBuilder: (context, index) {
                Finished finished = finishedClients[index];
                bool isExpanded = _expandedCards[finished.id] ?? false;

                return Card(
                  margin: EdgeInsets.all(8.0),
                  elevation: 4, // Add shadow for a modern look
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                  child: ExpansionTile(
                    title: Text(
                      '${finished.firstName} ${finished.middleName} ${finished.lastName}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Black text for the title
                      ),
                    ),
                    leading: Icon(Icons.person, color: Colors.green), // Add an icon
                    initiallyExpanded: isExpanded,
                    onExpansionChanged: (expanded) {
                      setState(() {
                        _expandedCards[finished.id] = expanded;
                      });
                    },
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow(Icons.phone, 'الهاتف: ${finished.phoneNumber}'),
                            _buildDetailRow(Icons.phone_android, 'واتساب: ${finished.whatsappNumber}'),
                            _buildDetailRow(Icons.location_on, 'العنوان: ${finished.street}, ${finished.buildingNumber}, ${finished.nearestLocation}'),
                            SizedBox(height: 10),
                            Text('رخصة القيادة:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                            SizedBox(height: 5),
                            if (finished.driverLicense != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8), // Rounded corners for the image
                                child: Image.network(
                                  finished.driverLicense,
                                  width: double.infinity,
                                  height: 150,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(child: CircularProgressIndicator(color: Colors.green));
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(child: Icon(Icons.error, color: Colors.red));
                                  },
                                ),
                              ),
                            SizedBox(height: 10),
                            _buildDetailRow(Icons.payment, 'طريقة الدفع: ${finished.paymentMethod}'),
                            _buildDetailRow(Icons.attach_money, 'السعر الإجمالي: \$${finished.totalPrice.toStringAsFixed(2)}'),
                            _buildDetailRow(Icons.calendar_today, 'تاريخ الإيجار: ${finished.rentDate}'),
                            _buildDetailRow(Icons.calendar_today, 'تاريخ الإرجاع: ${finished.returnDate}'),
                            _buildDetailRow(Icons.description, 'الوصف: ${finished.description}'), // Added description
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  // Helper function to build a detail row with an icon
  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 20),
          SizedBox(width: 8),
          Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[800])),
        ],
      ),
    );
  }
}