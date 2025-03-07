import 'package:car/models/Rejected.dart';
import 'package:car/utils/config.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RejectedScreen extends StatefulWidget {
  @override
  _RejectedScreenState createState() => _RejectedScreenState();
}

class _RejectedScreenState extends State<RejectedScreen> {
  late Future<List<Rejected>> futureRejectedClients;
  final Map<int, bool> _expandedCards = {};

  @override
  void initState() {
    super.initState();
    futureRejectedClients = fetchRejectedClients();
  }

  // Function to fetch rejected clients from the API
  Future<List<Rejected>> fetchRejectedClients() async {
    // Retrieve the authentication token from shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token'); // Replace 'auth_token' with your key

    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.get(
      Uri.parse('${Config.BASE_URL}/institution-rejected'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Rejected> rejectedClients = body.map((dynamic item) => Rejected.fromJson(item)).toList();
      return rejectedClients;
    } else {
      throw Exception('Failed to load rejected clients: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rejected Booking Requests', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green, // Green theme for the app bar
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // Custom back button
          onPressed: () {
            // Navigate to /DashboardInstitution
            Navigator.pushReplacementNamed(context, '/dashboardinstitution');
          },
        ),
      ),
      body: FutureBuilder<List<Rejected>>(
        future: futureRejectedClients,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.green));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No rejected clients found.', style: TextStyle(color: Colors.grey)));
          } else {
            List<Rejected> rejectedClients = snapshot.data!;
            return ListView.builder(
              itemCount: rejectedClients.length,
              itemBuilder: (context, index) {
                Rejected rejected = rejectedClients[index];
                bool isExpanded = _expandedCards[rejected.id] ?? false;

                return Card(
                  margin: EdgeInsets.all(8.0),
                  elevation: 4, // Add shadow for a modern look
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                  child: ExpansionTile(
                    title: Text(
                      '${rejected.firstName} ${rejected.middleName} ${rejected.lastName}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Green text for the title
                      ),
                    ),
                    leading: Icon(Icons.person, color: Colors.green), // Add an icon
                    initiallyExpanded: isExpanded,
                    onExpansionChanged: (expanded) {
                      setState(() {
                        _expandedCards[rejected.id] = expanded;
                      });
                    },
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow(Icons.email, 'Email: ${rejected.email}'),
                            _buildDetailRow(Icons.phone, 'Phone: ${rejected.phoneNumber}'),
                            _buildDetailRow(Icons.phone_android, 'WhatsApp: ${rejected.whatsappNumber}'),
                            _buildDetailRow(Icons.location_on, 'Address: ${rejected.street}, ${rejected.buildingNumber}, ${rejected.nearestLocation}'),
                            SizedBox(height: 10),
                            Text('Driver License:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                            SizedBox(height: 5),
                            if (rejected.driverLicense != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8), // Rounded corners for the image
                                child: Image.network(
                                  rejected.driverLicense,
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
                            Text('ID Picture:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                            SizedBox(height: 5),
                            if (rejected.idPicture != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8), // Rounded corners for the image
                                child: Image.network(
                                  rejected.idPicture,
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
                            _buildDetailRow(Icons.payment, 'Payment Method: ${rejected.paymentMethod}'),
                            _buildDetailRow(Icons.attach_money, 'Total Price: \$${rejected.totalPrice.toStringAsFixed(2)}'),
                            _buildDetailRow(Icons.calendar_today, 'Rent Date: ${rejected.rentDate}'),
                            _buildDetailRow(Icons.calendar_today, 'Return Date: ${rejected.returnDate}'),
                            _buildDetailRow(Icons.description, 'Rejection Reason: ${rejected.description}'), // Added description
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

