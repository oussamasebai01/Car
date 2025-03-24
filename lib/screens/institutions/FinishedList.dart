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
    _loadFinishedClients();
  }

  // Function to load finished clients
  void _loadFinishedClients() {
    futureFinishedClients = fetchFinishedClients();
  }

  // Function to fetch finished clients from the API
  Future<List<Finished>> fetchFinishedClients() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

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
      Map<String, dynamic> responseBody = jsonDecode(response.body);
      List<dynamic> data = responseBody['data'];
      List<Finished> finishedClients = data.map((dynamic item) => Finished.fromJson(item)).toList();
      return finishedClients;
    } else {
      throw Exception('فشل في تحميل الحجوزات المنتهية: ${response.statusCode}');
    }
  }

  // Function to handle list refresh
  Future<void> _refreshList() async {
    setState(() {
      _expandedCards.clear(); // Reset expanded state of cards
      _loadFinishedClients(); // Reload the finished clients
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الحجوزات المنتهية', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
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
            return RefreshIndicator(
              onRefresh: _refreshList, // Call the refresh method for the list
              child: ListView.builder(
                physics: AlwaysScrollableScrollPhysics(), // Ensure scroll is always enabled
                itemCount: finishedClients.length,
                itemBuilder: (context, index) {
                  Finished finished = finishedClients[index];
                  bool isExpanded = _expandedCards[finished.id] ?? false;

                  return Card(
                    margin: EdgeInsets.all(8.0),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ExpansionTile(
                      title: Text(
                        '${finished.firstName} ${finished.middleName} ${finished.lastName}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      leading: Icon(Icons.person, color: Colors.green),
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
                                  borderRadius: BorderRadius.circular(8),
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
                              _buildDetailRow(Icons.description, 'الوصف: ${finished.description}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
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