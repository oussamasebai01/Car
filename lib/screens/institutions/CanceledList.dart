import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:car/models/Canceled.dart';
import 'package:car/utils/config.dart';

class CanceledListScreen extends StatefulWidget {
  @override
  _CanceledListScreenState createState() => _CanceledListScreenState();
}

class _CanceledListScreenState extends State<CanceledListScreen> {
  late Future<List<Canceled>> futureCanceledClients;
  final Map<int, bool> _expandedCards = {};

  @override
  void initState() {
    super.initState();
    _loadCanceledClients();
  }

  // Function to load canceled clients
  void _loadCanceledClients() {
    futureCanceledClients = fetchCanceledClients();
  }

  // Function to fetch canceled clients from the API
  Future<List<Canceled>> fetchCanceledClients() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }

    final response = await http.get(
      Uri.parse('${Config.BASE_URL}/canceled-by-institution'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = jsonDecode(response.body);
      List<dynamic> data = responseBody['data'];
      List<Canceled> canceledClients = data.map((dynamic item) => Canceled.fromJson(item)).toList();
      return canceledClients;
    } else {
      throw Exception('فشل في تحميل الحجوزات الملغاة: ${response.statusCode}');
    }
  }

  // Function to handle list refresh
  Future<void> _refreshList() async {
    setState(() {
      _expandedCards.clear(); // Reset expanded state of cards
      _loadCanceledClients(); // Reload the canceled clients
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الحجوزات الملغاة', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/dashboardinstitution');
          },
        ),
      ),
      body: FutureBuilder<List<Canceled>>(
        future: futureCanceledClients,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.green));
          } else if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error}', style: TextStyle(color: Colors.red)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('لا توجد حجوزات ملغاة.', style: TextStyle(color: Colors.grey)));
          } else {
            List<Canceled> canceledClients = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _refreshList, // Call the refresh method for the list
              child: ListView.builder(
                physics: AlwaysScrollableScrollPhysics(), // Ensure scroll is always enabled
                itemCount: canceledClients.length,
                itemBuilder: (context, index) {
                  Canceled canceled = canceledClients[index];
                  bool isExpanded = _expandedCards[canceled.id] ?? false;

                  return Card(
                    margin: EdgeInsets.all(8.0),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ExpansionTile(
                      title: Text(
                        '${canceled.firstName} ${canceled.middleName} ${canceled.lastName}',
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
                          _expandedCards[canceled.id] = expanded;
                        });
                      },
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow(Icons.phone, 'الهاتف: ${canceled.phoneNumber}'),
                              _buildDetailRow(Icons.phone_android, 'واتساب: ${canceled.whatsappNumber}'),
                              _buildDetailRow(Icons.location_on, 'العنوان: ${canceled.street}, ${canceled.buildingNumber}, ${canceled.nearestLocation}'),
                              SizedBox(height: 10),
                              Text('رخصة القيادة:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                              SizedBox(height: 5),
                              if (canceled.driverLicense != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    canceled.driverLicense,
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
                              _buildDetailRow(Icons.payment, 'طريقة الدفع: ${canceled.paymentMethod}'),
                              _buildDetailRow(Icons.attach_money, 'السعر الإجمالي: \$${canceled.totalPrice.toStringAsFixed(2)}'),
                              _buildDetailRow(Icons.calendar_today, 'تاريخ الإيجار: ${canceled.rentDate}'),
                              _buildDetailRow(Icons.calendar_today, 'تاريخ الإرجاع: ${canceled.returnDate}'),
                              _buildDetailRow(Icons.description, 'الوصف: ${canceled.description}'),
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