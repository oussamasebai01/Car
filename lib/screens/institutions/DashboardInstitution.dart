import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DashboardInstitution extends StatelessWidget {
  // List of card data (title and icon)
  final List<Map<String, dynamic>> cards = [
    {'title': 'My Cars', 'icon': FontAwesomeIcons.car},
    {'title': 'Booking List', 'icon': FontAwesomeIcons.list},
    {'title': 'Booking Requests', 'icon': FontAwesomeIcons.solidEnvelope},
    {'title': 'Rejected List', 'icon': FontAwesomeIcons.timesCircle},
    {'title': 'Cancelled List', 'icon': FontAwesomeIcons.ban},
    {'title': 'Finished Bookings', 'icon': FontAwesomeIcons.checkCircle},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Institution Dashboard'),
        actions: [IconButton(onPressed: () {
          // Navigate to Forgot Password Screen
          Navigator.pushNamed(context, '/dashboardinstitution');
        },
          icon: Icon(FontAwesomeIcons.signOutAlt), // Logout icon
          tooltip: 'Logout',
        )],
        centerTitle: true,
        backgroundColor: Colors.green, // Keep app bar green
        elevation: 0, // Remove shadow
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey[100]!], // Subtle gradient
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 cards per row
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 1.2, // Adjust card aspect ratio
            ),
            itemCount: cards.length,
            itemBuilder: (context, index) {
              return _buildCard(cards[index]['title'], cards[index]['icon']);
            },
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 60,
        color: Colors.green, // Green footer
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
  Widget _buildCard(String title, IconData icon) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Card(
        elevation: 5, // Default shadow
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(color: Colors.green.withOpacity(0.3), width: 1.5), // Lighter border
        ),
        child: InkWell(
          onTap: () {
            // Handle card click
            print('$title clicked');
          },
          borderRadius: BorderRadius.circular(12.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.grey[50]!], // Subtle card gradient
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 50, color: Colors.green), // Green icon
                SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800], // Darker text for better readability
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