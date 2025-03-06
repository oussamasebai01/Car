import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/config.dart';

class DashboardInstitution extends StatelessWidget {
  // List of card data (title, icon, and route)
  final List<Map<String, dynamic>> cards = [
    {'title': 'My Cars', 'icon': FontAwesomeIcons.car, 'route': '/car_liste'},
    {'title': 'Booking List', 'icon': FontAwesomeIcons.list, 'route': '/booking_list'},
    {'title': 'Booking Requests', 'icon': FontAwesomeIcons.solidEnvelope, 'route': '/bookingrequest'},
    {'title': 'Rejected List', 'icon': FontAwesomeIcons.timesCircle, 'route': '/rejected_list'},
    {'title': 'Cancelled List', 'icon': FontAwesomeIcons.ban, 'route': '/cancelled_list'},
    {'title': 'Finished Bookings', 'icon': FontAwesomeIcons.checkCircle, 'route': '/finished_bookings'},
  ];

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> Logout() async {
    final token = await getAuthToken();
    print(token);
    if (token != null) {
      final response = await http.post(
        Uri.parse('${Config.BASE_URL}/logout'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      // Handle the response
    } else {
      // Handle the case where there is no token
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Institution Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              Logout();
              Navigator.pushReplacementNamed(context, '/singin');
            },
            icon: Icon(FontAwesomeIcons.signOutAlt),
            tooltip: 'Logout',
          ),
        ],
        centerTitle: true,
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey[100]!],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 1.2,
            ),
            itemCount: cards.length,
            itemBuilder: (context, index) {
              return _buildCard(
                context,
                cards[index]['title'],
                cards[index]['icon'],
                cards[index]['route'], // Pass the specific route
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 60,
        color: Colors.green,
        child: Center(
          child: Text(
            '© 2025 Go Sayara ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // Function to build a card
  Widget _buildCard(BuildContext context, String title, IconData icon, String route) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(color: Colors.green.withOpacity(0.3), width: 1.5),
        ),
        child: InkWell(
          onTap: () {
            // Navigate to the specific route
            Navigator.pushReplacementNamed(context, route).then((_) {
              print('$title clicked');
            }).catchError((error) {
              print('Navigation error: $error');
            });
          },
          borderRadius: BorderRadius.circular(12.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.grey[50]!],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 50, color: Colors.green),
                SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}