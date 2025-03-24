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
    _loadBookings();
  }

  // Function to load tenant bookings
  void _loadBookings() {
    futureBookings = fetchTenantBookings();
  }

  // Function to fetch tenant bookings from the API
  Future<List<Booking>> fetchTenantBookings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }

    final response = await http.get(
      Uri.parse('${Config.BASE_URL}/institution-tenant'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Booking> bookings = body.map((dynamic item) => Booking.fromJson(item)).toList();
      return bookings;
    } else {
      throw Exception('فشل في تحميل حجوزات المستأجرين: ${response.statusCode}');
    }
  }

  // Function to handle finish booking action
  Future<void> finishBooking(int bookingId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('المستخدم غير مسجل الدخول');
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

    if (response.statusCode == 200) {
      setState(() {
        _loadBookings(); // Refresh the list
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم إنهاء الحجز بنجاح')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في إنهاء الحجز: ${response.statusCode}')),
      );
    }
  }

  // Function to handle cancel booking action
  Future<void> cancelBooking(int bookingId) async {
    String? description = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String inputValue = '';
        return AlertDialog(
          title: Text('إلغاء الحجز'),
          content: TextField(
            onChanged: (value) {
              inputValue = value;
            },
            decoration: InputDecoration(
              hintText: 'أدخل سبب الإلغاء',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, inputValue);
              },
              child: Text('إرسال'),
            ),
          ],
        );
      },
    );

    if (description == null || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('سبب الإلغاء مطلوب')),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('المستخدم غير مسجل الدخول')),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('${Config.BASE_URL}/cancel-tenant/$bookingId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'description': description,
      }),
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      setState(() {
        _loadBookings(); // Refresh the list
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم إلغاء الحجز بنجاح')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في إلغاء الحجز: ${response.statusCode}')),
      );
    }
  }

  // Function to handle list refresh
  Future<void> _refreshList() async {
    setState(() {
      _expandedCards.clear(); // Reset expanded state of cards
      _loadBookings(); // Reload the bookings
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('قائمة الحجوزات', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
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
            return Center(child: Text('خطأ: ${snapshot.error}', style: TextStyle(color: Colors.red)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('لا توجد حجوزات للمستأجرين.', style: TextStyle(color: Colors.grey)));
          } else {
            List<Booking> bookings = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _refreshList, // Call the refresh method for the list
              child: ListView.builder(
                physics: AlwaysScrollableScrollPhysics(), // Ensure scroll is always enabled
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  Booking booking = bookings[index];
                  bool isExpanded = _expandedCards[booking.id] ?? false;

                  return Card(
                    margin: EdgeInsets.all(8.0),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ExpansionTile(
                      title: Text(
                        '${booking.firstName} ${booking.middleName ?? ''} ${booking.lastName}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      leading: Icon(Icons.person, color: Colors.green),
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
                              _buildDetailRow(Icons.phone, 'الهاتف: ${booking.phoneNumber}'),
                              if (booking.whatsappNumber != null)
                                _buildDetailRow(Icons.phone_android, 'واتساب: ${booking.whatsappNumber}'),
                              _buildDetailRow(Icons.location_on, 'العنوان: ${booking.street}, ${booking.buildingNumber}'),
                              if (booking.nearestLocation != null)
                                _buildDetailRow(Icons.location_on, 'أقرب موقع: ${booking.nearestLocation}'),
                              SizedBox(height: 10),
                              Text('رخصة القيادة:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                              SizedBox(height: 5),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
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
                              _buildDetailRow(Icons.payment, 'طريقة الدفع: ${booking.paymentMethod}'),
                              _buildDetailRow(Icons.attach_money, 'السعر الإجمالي: \$${booking.totalPrice.toStringAsFixed(2)}'),
                              _buildDetailRow(Icons.calendar_today, 'تاريخ الإيجار: ${booking.rentDate.toLocal()}'),
                              _buildDetailRow(Icons.calendar_today, 'تاريخ الإرجاع: ${booking.returnDate.toLocal()}'),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () => finishBooking(booking.id),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text('إنهاء الحجز', style: TextStyle(color: Colors.white)),
                                  ),
                                  SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () => cancelBooking(booking.id),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text('إلغاء الحجز', style: TextStyle(color: Colors.white)),
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