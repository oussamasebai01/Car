import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../utils/config.dart';

class MyBookingScreen extends StatefulWidget {
  const MyBookingScreen({Key? key}) : super(key: key);

  @override
  State<MyBookingScreen> createState() => _MyBookingScreenState();
}

Future<String?> getAuthToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('auth_token');
}

Future<List<Map<String, dynamic>>> fetchCars() async {
  final token = await getAuthToken();
  print(token);
  final response = await http.get(
    Uri.parse('${Config.BASE_URL}/cars-inst'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((car) {
      return {
        'car': 'assets/bmw_x5.png',
        'name': car['model']['name_en'],
        'tagNumber': car['tagNumber'],
        'address': '${car['city']}, ${car['country']}',
        'tripStart': 'Sat, 7 June, 5.30pm',
        'tripEnd': 'Mon, 9 June, 6.30pm',
        'paid': car['price_per_day']?.toString() ?? '0',
      };
    }).toList();
  } else {
    throw Exception('Failed to load data');
  }
}

class _MyBookingScreenState extends State<MyBookingScreen> {
  Future<List<Map<String, dynamic>>>? futureCars;
  List<Map<String, dynamic>> filteredBookings = [];
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
          booking['tagNumber'].toLowerCase().contains(query.toLowerCase()))
              .toList();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          title: const Text('My Booking'),
          centerTitle: true,
          backgroundColor: Colors.green,
          elevation: 0,
        ),
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
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: filterBookings,
            ),
          ),
          // Liste des réservations
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
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
          // Action à effectuer lors du clic sur le bouton flottant
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

  Widget filledBooking(List<Map<String, dynamic>> bookingList) {
    return SingleChildScrollView(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: bookingList.length,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          height: 15.h,
                          child: Image.asset(bookingList[index]['car']),
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          height: 8.h,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AutoSizeText(
                                bookingList[index]['name'],
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                                maxLines: 1,
                              ),
                              AutoSizeText(
                                'Tag Number ${bookingList[index]['tagNumber']}',
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.blue,
                          size: 20,
                        ),
                        const SizedBox(width: 5),
                        SizedBox(
                          width: 60.w,
                          child: Text(
                            bookingList[index]['address'],
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Trip start',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                bookingList[index]['tripStart'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Trip end',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                bookingList[index]['tripEnd'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Paid',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '\$${bookingList[index]['paid']}',
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
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
              Positioned(
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 25),
                  child: GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.blue,
                          duration: const Duration(seconds: 1),
                          content: Text(
                            "${bookingList[index]['name']} removed",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                      setState(() {
                        bookingList.removeAt(index);
                      });
                    },
                    child: const Icon(
                      Icons.cancel_outlined,
                      color: Colors.grey,
                      size: 23,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget emptyBooking() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 4.5.h,
            child: Image.asset('assets/images/no_booking.png'),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 80.w,
            child: const AutoSizeText(
              'No bookings yet',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}