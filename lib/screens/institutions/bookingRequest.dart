import 'package:car/models/Client.dart';
import 'package:car/utils/config.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BookingRequestScreen extends StatefulWidget {
  @override
  _BookingRequestScreenState createState() => _BookingRequestScreenState();
}

class _BookingRequestScreenState extends State<BookingRequestScreen> {
  late Future<List<Client>> futureClients;
  final Map<int, bool> _expandedCards = {}; // Track which cards are expanded

  @override
  void initState() {
    super.initState();
    futureClients = fetchPendingClients();
  }

  // Function to fetch pending clients from the API
  Future<List<Client>> fetchPendingClients() async {
    // Retrieve the authentication token from shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token'); // Replace 'auth_token' with your key

    if (token == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }

    final response = await http.get(
      Uri.parse('${Config.BASE_URL}/get_pending_client'),
      headers: {
        'Authorization': 'Bearer $token', // Include the token in the headers
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Client> clients = body.map((dynamic item) => Client.fromJson(item)).toList();
      return clients;
    } else {
      throw Exception('فشل في تحميل العملاء المعلقين: ${response.statusCode}');
    }
  }

  // Function to handle approve action
  Future<void> approveClient(int clientId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }

    final response = await http.post(
      Uri.parse('${Config.BASE_URL}/approve-client/$clientId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    print(response.statusCode);
    if (response.statusCode == 201) {
      // Refresh the list after approval
      setState(() {
        futureClients = fetchPendingClients(); // Refresh the list
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تمت الموافقة على العميل بنجاح')),
      );
    } else {
      throw Exception('فشل في الموافقة على العميل: ${response.statusCode}');
    }
  }

  // Function to handle reject action
  Future<void> rejectClient(int clientId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('المستخدم غير مسجل الدخول')),
      );
      return;
    }

    // Show a dialog to get the rejection description
    String? description = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String inputValue = ''; // Variable to store the user's input
        return AlertDialog(
          title: Text('رفض العميل'),
          content: TextField(
            onChanged: (value) {
              inputValue = value; // Update the input value as the user types
            },
            decoration: InputDecoration(
              hintText: 'أدخل سبب الرفض',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog without saving
              },
              child: Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, inputValue); // Close the dialog and return the input value
              },
              child: Text('إرسال'),
            ),
          ],
        );
      },
    );

    // If the user cancels the dialog, do nothing
    if (description == null || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('سبب الرفض مطلوب')),
      );
      return;
    }

    try {
      // Send the rejection request with the description
      final response = await http.post(
        Uri.parse('${Config.BASE_URL}/rejected-client/$clientId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json', // Add this header for JSON data
        },
        body: jsonEncode({
          'description': description, // Include the description in the request body
        }),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 201) {
        // Refresh the list after rejection
        setState(() {
          futureClients = fetchPendingClients(); // Refresh the list
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم رفض العميل بنجاح')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في رفض العميل: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('طلبات الحجز', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green, // Green theme for the app bar
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // Custom back button
          onPressed: () {
            // Navigate to /dashboardinstitution
            Navigator.pushReplacementNamed(context, '/dashboardinstitution');
          },
        ),
      ),
      body: FutureBuilder<List<Client>>(
        future: futureClients,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.green));
          } else if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error}', style: TextStyle(color: Colors.red)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('لا توجد عملاء معلقين.', style: TextStyle(color: Colors.grey)));
          } else {
            List<Client> clients = snapshot.data!;
            return ListView.builder(
              itemCount: clients.length,
              itemBuilder: (context, index) {
                Client client = clients[index];
                bool isExpanded = _expandedCards[client.id] ?? false;

                return Card(
                  margin: EdgeInsets.all(8.0),
                  elevation: 4, // Add shadow for a modern look
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                  child: ExpansionTile(
                    title: Text(
                      '${client.firstName} ${client.middleName} ${client.lastName}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green, // Green text for the title
                      ),
                    ),
                    leading: Icon(Icons.person, color: Colors.green), // Add an icon
                    initiallyExpanded: isExpanded,
                    onExpansionChanged: (expanded) {
                      setState(() {
                        _expandedCards[client.id] = expanded;
                      });
                    },
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow(Icons.phone, 'الهاتف: ${client.phoneNumber}'),
                            _buildDetailRow(Icons.phone_android, 'واتساب: ${client.whatsappNumber}'),
                            _buildDetailRow(Icons.location_on, 'العنوان: ${client.street}, ${client.buildingNumber}, ${client.nearestLocation}'),
                            SizedBox(height: 10),
                            Text('رخصة القيادة:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                            SizedBox(height: 5),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8), // Rounded corners for the image
                              child: Image.network(
                                client.driverLicense,
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
                            _buildDetailRow(Icons.payment, 'طريقة الدفع: ${client.paymentMethod}'),
                            _buildDetailRow(Icons.attach_money, 'السعر الإجمالي: \$${client.totalPrice.toStringAsFixed(2)}'),
                            _buildDetailRow(Icons.calendar_today, 'تاريخ الإيجار: ${client.rentDate.toLocal()}'),
                            _buildDetailRow(Icons.calendar_today, 'تاريخ الإرجاع: ${client.returnDate.toLocal()}'),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () => approveClient(client.id),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green, // Green color for approve
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8), // Rounded corners for the button
                                    ),
                                  ),
                                  child: Text('موافقة', style: TextStyle(color: Colors.white)),
                                ),
                                SizedBox(width: 10), // Add spacing between buttons
                                ElevatedButton(
                                  onPressed: () => rejectClient(client.id),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red, // Red color for reject
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8), // Rounded corners for the button
                                    ),
                                  ),
                                  child: Text('رفض', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
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