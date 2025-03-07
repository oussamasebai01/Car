import 'package:car/models/Booking.dart';
import 'package:car/utils/config.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BookingListScreen extends StatefulWidget {
  @override
  _BookingListScreenState createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  late Future<List<Booking>> futureBookings;
  final Map<int, bool> _expandedCards = {}; // Track which cards are expanded

  @override
  void initState() {
    super.initState();
    futureBookings = fetchTenantBookings();
  }

  // Function to fetch tenant bookings from the API
  Future<List<Booking>> fetchTenantBookings() async {
    // Retrieve the authentication token from shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token'); // Replace 'auth_token' with your key

    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.get(
      Uri.parse('${Config.BASE_URL}/institution-tenant'),
      headers: {
        'Authorization': 'Bearer $token', // Include the token in the headers
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Booking> bookings = body.map((dynamic item) => Booking.fromJson(item)).toList();
      return bookings;
    } else {
      throw Exception('Failed to load tenant bookings: ${response.statusCode}');
    }
  }

  // Function to handle finish booking action
  Future<void> finishBooking(int bookingId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.post(
      Uri.parse('${Config.BASE_URL}/finish-tenant/$bookingId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    print(Uri.parse('${Config.BASE_URL}/finish-tenant/$bookingId'));
    print(token);
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) { // Check for status code 200
      // Refresh the list after finishing the booking
      setState(() {
        futureBookings = fetchTenantBookings(); // Refresh the list
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking finished successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to finish booking: ${response.statusCode}')),
      );
    }
  }

  // Function to handle cancel booking action
  Future<void> cancelBooking(int bookingId) async {
    // Show a dialog to get the cancellation description
    String? description = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String inputValue = ''; // Variable to store the user's input
        return AlertDialog(
          title: Text('Cancel Booking'),
          content: TextField(
            onChanged: (value) {
              inputValue = value; // Update the input value as the user types
            },
            decoration: InputDecoration(
              hintText: 'Enter cancellation reason',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog without saving
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, inputValue); // Close the dialog and return the input value
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );

    // If the user cancels the dialog or doesn't provide a description, do nothing
    if (description == null || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cancellation reason is required')),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User is not authenticated')),
      );
      return;
    }

    // Send the cancellation request with the description
    final response = await http.post(
      Uri.parse('${Config.BASE_URL}/cancel-tenant/$bookingId'),
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

    if (response.statusCode == 200) { // Check for status code 200
      // Refresh the list after canceling the booking
      setState(() {
        futureBookings = fetchTenantBookings(); // Refresh the list
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking canceled successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to cancel booking: ${response.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tenant Bookings', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green, // Green theme for the app bar
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // Custom back button
          onPressed: () {
            // Navigate to /dashboardinstitution
            Navigator.pushReplacementNamed(context, '/dashboardinstitution');
          },
        ),
      ),
      body: FutureBuilder<List<Booking>>(
        future: futureBookings,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.green));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No tenant bookings found.', style: TextStyle(color: Colors.grey)));
          } else {
            List<Booking> bookings = snapshot.data!;
            return ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                Booking booking = bookings[index];
                bool isExpanded = _expandedCards[booking.id] ?? false;

                return Card(
                  margin: EdgeInsets.all(8.0),
                  elevation: 4, // Add shadow for a modern look
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                  child: ExpansionTile(
                    title: Text(
                      '${booking.firstName} ${booking.middleName ?? ''} ${booking.lastName}',
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
                        _expandedCards[booking.id] = expanded;
                      });
                    },
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow(Icons.email, 'Email: ${booking.email}'),
                            _buildDetailRow(Icons.phone, 'Phone: ${booking.phoneNumber}'),
                            if (booking.whatsappNumber != null)
                              _buildDetailRow(Icons.phone_android, 'WhatsApp: ${booking.whatsappNumber}'),
                            _buildDetailRow(Icons.location_on, 'Address: ${booking.street}, ${booking.buildingNumber}'),
                            if (booking.nearestLocation != null)
                              _buildDetailRow(Icons.location_on, 'Nearest Location: ${booking.nearestLocation}'),
                            SizedBox(height: 10),
                            Text('Driver License:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                            SizedBox(height: 5),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8), // Rounded corners for the image
                              child: Image.network(
                                booking.driverLicense,
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
                            if (booking.idPicture != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('ID Picture:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                                  SizedBox(height: 5),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8), // Rounded corners for the image
                                    child: Image.network(
                                      booking.idPicture!,
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
                                ],
                              ),
                            SizedBox(height: 10),
                            _buildDetailRow(Icons.payment, 'Payment Method: ${booking.paymentMethod}'),
                            _buildDetailRow(Icons.attach_money, 'Total Price: \$${booking.totalPrice.toStringAsFixed(2)}'),
                            _buildDetailRow(Icons.calendar_today, 'Rent Date: ${booking.rentDate.toLocal()}'),
                            _buildDetailRow(Icons.calendar_today, 'Return Date: ${booking.returnDate.toLocal()}'),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () => finishBooking(booking.id),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green, // Green color for finish
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8), // Rounded corners for the button
                                    ),
                                  ),
                                  child: Text('Finish Booking', style: TextStyle(color: Colors.white)),
                                ),
                                SizedBox(width: 10), // Add spacing between buttons
                                ElevatedButton(
                                  onPressed: () => cancelBooking(booking.id),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red, // Red color for cancel
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8), // Rounded corners for the button
                                    ),
                                  ),
                                  child: Text('Cancel Booking', style: TextStyle(color: Colors.white)),
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