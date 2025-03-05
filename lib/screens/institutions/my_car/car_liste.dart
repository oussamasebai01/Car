import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:car/models/car_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'add_car.dart';
import 'car_details.dart';

class MyBookingScreen extends StatefulWidget {
  const MyBookingScreen({Key? key}) : super(key: key);

  @override
  State<MyBookingScreen> createState() => _MyBookingScreenState();
}

Future<String?> getAuthToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('auth_token');
}

Future<List<CarModel>> fetchCars() async {
  final token = await getAuthToken();
  print(token);
  final response = await http.get(
    Uri.parse('http://10.0.2.2:8000/api/cars-inst'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((car) {
      return CarModel(
        id: car['id'],
        tagNumber: car['tagNumber'],
        pricePerDay: car['price_per_day']?.toDouble() ?? 0.0,
        carColor: car['car_color'],
        city: car['city'],
        gazType: car['gaz_type'],
        transmission: car['transmission'],
        seatNumber: car['seat_number'],
        modelName: car['model']['name_en'],
        manufacturerName: car['model']['manufacture']['name_en'],
        institutionName: car['institution']['name'],
        availability: car['availability'],
        manu_year: int.tryParse(car['manu_year']?.toString() ?? '0000') ?? 0000,
        pricePerMonth: car['price_per_month']?.toDouble() ?? 0.0,
        pricePerWeek: car['price_per_week']?.toDouble() ?? 0.0,
        pricePerYear: car['price_per_year']?.toDouble() ?? 0.0,
      );
    }).toList();
  } else {
    throw Exception('Failed to load data');
  }
}

class _MyBookingScreenState extends State<MyBookingScreen> {
  Future<List<CarModel>>? futureCars;
  List<CarModel> filteredBookings = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureCars = fetchCars().then((bookings) {
      setState(() {
        filteredBookings = bookings;
      });
      return bookings;
    });
  }

  void filterBookings(String query) {
    setState(() {
      if (query.isEmpty) {
        futureCars!.then((bookings) {
          filteredBookings = bookings;
        });
      } else {
        futureCars!.then((bookings) {
          filteredBookings = bookings
              .where((booking) =>
              booking.tagNumber.toLowerCase().contains(query.toLowerCase()))
              .toList();
        });
      }
    });
  }

  // Fonction pour supprimer une réservation via l'API
  Future<void> deleteBooking(int index) async {
    final car = filteredBookings[index];
    final token = await getAuthToken();

    // Boîte de dialogue de confirmation
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${car.modelName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Envoyer une requête DELETE à l'API
        final response = await http.delete(
          Uri.parse('http://10.0.2.2:8000/api/delete-institution-cars/${car.id}'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          // Supprimer l'élément de la liste locale
          setState(() {
            filteredBookings.removeAt(index);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${car.modelName} deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // Gérer les erreurs de l'API
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete ${car.modelName}: ${response.body}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        // Gérer les erreurs de connexion
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Booking', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.green,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search cars...',
                prefixIcon: const Icon(Icons.search, color: Colors.blueGrey),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: filterBookings,
            ),
          ),
          // Liste des réservations
          Expanded(
            child: FutureBuilder<List<CarModel>>(
              future: futureCars,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return emptyBooking();
                } else {
                  return filledBooking(filteredBookings);
                }
              },
            ),
          ),
        ],
      ),
      // Bouton flottant
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddInstitutionCarScreen(isEdit:false , tempCar :null),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Floating Action Button clicked!'),
            ),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: Container(
        height: 60,
        color: Colors.green,
        child: const Center(
          child: Text(
            '© 2025 Go Sayara',
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

  Widget filledBooking(List<CarModel> bookingList) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: bookingList.length,
      itemBuilder: (context, index) {
        final car = bookingList[index];
        final borderColor = car.availability == 1 ? Colors.green : Colors.red;
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: borderColor, width: 2),
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CarDetailsPageI(car: car),
                ),
              );
            },
            borderRadius: BorderRadius.circular(15),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          "assets/bmw_x5.png",
                          fit: BoxFit.cover,
                          width: 100,
                          height: 70,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              car.modelName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tag Number: ${car.tagNumber}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteBooking(index),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        car.city,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Color',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              car.carColor,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Manufacturer',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              car.manufacturerName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price/Day',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              '\$${car.pricePerDay}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget emptyBooking() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/no_booking.png',
            height: 100,
          ),
          const SizedBox(height: 16),
          const Text(
            'No bookings yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}