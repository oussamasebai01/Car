import 'dart:convert';
import 'package:car/map.dart';
import 'package:car/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'models/car_model.dart';
import 'carCardItem.dart';

class CarSearchPage extends StatefulWidget {
  @override
  _CarSearchPageState createState() => _CarSearchPageState();
}

class _CarSearchPageState extends State<CarSearchPage> {
  String? selectedCountry;
  String? selectedCity;
  final TextEditingController _pickupDateController = TextEditingController();
  final TextEditingController _returnDateController = TextEditingController();
  List<String> cities = [];
  List<CarModel> cars = [];
  int numberOfDays = 0;
  String? selectedSortOption; // For sorting by price

  late Future<List<Map<String, dynamic>>> fetchedCountries;
  late Future<List<String>> futureCities;

  Future<DateTime?> showDateTimePicker() async {
    return await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    ).then((selectedDate) async {
      if (selectedDate != null) {
        final TimeOfDay? selectedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (selectedTime != null) {
          return DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
        }
      }
      return null;
    });
  }

  Future<List<String>> fetchCitiesWithCars() async {
    final url = Uri.parse('${Config.BASE_URL}/getCitiesHaveCars');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.cast<String>(); // Convert to list of String
      } else {
        throw Exception('خطأ في تحميل المدن');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchCountries() async {
    try {
      final response = await http.get(Uri.parse('${Config.BASE_URL}/countries'));

      if (response.statusCode == 200) {
        List<dynamic> countriesFromServer = json.decode(response.body);

        return countriesFromServer.map((country) {
          return {
            "id": country["id"], // ✅ استرجاع الـ ID
            "name": country["name_en"] // ✅ اسم البلد بالعربية
          };
        }).toList();
      } else {
        print("خطأ في الخادم: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("حدث خطأ أثناء جلب البلدان: $e");
      return [];
    }
  }

  Future<void> searchCars() async {
    if (selectedCity == null || _pickupDateController.text.isEmpty || _returnDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("الرجاء تحديد مدينة وتواريخ صالحة.")),
      );
      return;
    }

    final url = Uri.parse('${Config.BASE_URL}/get-available-institution-cars-by-city');
    final body = jsonEncode({
      "city": selectedCity,
      "rent_date": _pickupDateController.text,
      "return_date": _returnDateController.text,
    });

    try {
      print("جاري المحاولة...");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print(responseData);
        setState(() {
          cars = (responseData['data'] as List)
              .map((carJson) => CarModel.fromJson(carJson)) // استخدام طريقة fromJson المحدثة
              .toList();
          sortCars(); // ترتيب السيارات بعد جلبها
          print(cars);
        });
      } else {
        throw Exception('فشل في تحميل السيارات: ${response.statusCode}');
      }
    } catch (e) {
      print("خطأ: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("لا توجد سيارات متاحة في هذه المنطقة حاليًا.")),
      );
    }
  }

  Future<List<String>> fetchCities(int countryId) async {
    try {
      final response = await http.get(Uri.parse("${Config.BASE_URL}/countries/$countryId/cities"));

      if (response.statusCode == 200) {
        List<dynamic> citiesFromServer = json.decode(response.body);
        return citiesFromServer.map((city) => city["name_en"].toString()).toList();
      } else {
        print("خطأ في الخادم: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("حدث خطأ أثناء جلب المدن: $e");
      return [];
    }
  }

  void calculateDaysDifference() {
    if (_pickupDateController.text.isNotEmpty && _returnDateController.text.isNotEmpty) {
      DateTime pickupDate = DateTime.parse(_pickupDateController.text);
      DateTime returnDate = DateTime.parse(_returnDateController.text);

      setState(() {
        numberOfDays = returnDate.difference(pickupDate).inDays;
      });
    }
  }

  void sortCars() {
    if (selectedSortOption == 'السعر: من الأقل إلى الأعلى') {
      cars.sort((a, b) => a.pricePerDay.compareTo(b.pricePerDay));
    } else if (selectedSortOption == 'السعر: من الأعلى إلى الأقل') {
      cars.sort((a, b) => b.pricePerDay.compareTo(a.pricePerDay));
    }
  }

  @override
  void initState() {
    fetchedCountries = fetchCountries();
    futureCities = fetchCitiesWithCars();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("البحث عن سيارة"),
        actions: [
          IconButton(
            icon: Icon(Icons.login),
            onPressed: () {
              Navigator.pushReplacementNamed(context, "/singin");
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // المحتوى الرئيسي مع SingleChildScrollView
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          FutureBuilder<List<Map<String, dynamic>>>(
                            future: fetchCountries(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text("خطأ في تحميل البلدان");
                              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return Text("لا توجد بلدان متاحة");
                              }

                              List<Map<String, dynamic>> countries = snapshot.data!;

                              return DropdownButtonFormField<int>(
                                value: selectedCountry != null ? int.tryParse(selectedCountry!) : null,
                                items: countries.map((country) {
                                  return DropdownMenuItem<int>(
                                    value: country["id"],
                                    child: Text(country["name"]),
                                  );
                                }).toList(),
                                onChanged: (value) async {
                                  setState(() {
                                    selectedCountry = value.toString();
                                    selectedCity = null;
                                    cities = [];
                                  });

                                  List<String> fetchedCities = await fetchCities(value!);
                                  setState(() {
                                    cities = fetchedCities;
                                  });
                                },
                                decoration: InputDecoration(labelText: "اختر البلد"),
                              );
                            },
                          ),

                          if (cities.isNotEmpty)
                            DropdownButtonFormField<String>(
                              value: selectedCity,
                              items: cities.map((String city) {
                                return DropdownMenuItem<String>(
                                  value: city,
                                  child: Text(city),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedCity = value;
                                });
                              },
                              decoration: InputDecoration(labelText: "موقع الاستلام"),
                            ),

                          TextField(
                            controller: _pickupDateController,
                            decoration: InputDecoration(labelText: "تاريخ الاستلام"),
                            readOnly: true,
                            onTap: () async {
                              DateTime? pickedDateTime = await showDateTimePicker();
                              if (pickedDateTime != null) {
                                setState(() {
                                  _pickupDateController.text = "${pickedDateTime.toLocal()}".split('.')[0];
                                  calculateDaysDifference();
                                });
                              }
                            },
                          ),
                          TextField(
                            controller: _returnDateController,
                            decoration: InputDecoration(labelText: "تاريخ التسليم"),
                            readOnly: true,
                            onTap: () async {
                              DateTime? pickedDateTime = await showDateTimePicker();
                              if (pickedDateTime != null) {
                                setState(() {
                                  _returnDateController.text = "${pickedDateTime.toLocal()}".split('.')[0];
                                  calculateDaysDifference();
                                });
                              }
                            },
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: searchCars,
                            child: Text("بحث"),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Dropdown للترتيب حسب السعر
                  DropdownButton<String>(
                    value: selectedSortOption,
                    hint: Text("ترتيب حسب السعر"),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedSortOption = newValue;
                        sortCars(); // ترتيب السيارات عند اختيار الخيار
                      });
                    },
                    items: <String>['السعر: من الأقل إلى الأعلى', 'السعر: من الأعلى إلى الأقل']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: cars.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CarDetailsPage(car: cars[index], date_debut: _pickupDateController.text, date_fin: _returnDateController.text, numberOfDays: numberOfDays),
                            ),
                          );
                        },
                        child: CarCardItem(car: cars[index]),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FloatingActionButton.extended(
          onPressed: () {
            futureCities.then((cities) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MapScreen(cityNames: cities),
                ),
              );
            });
          },
          label: Text("الخريطة" ,style: TextStyle(color: Colors.white),),
          icon: Icon(Icons.map,color: Colors.white,),
          backgroundColor: Color.fromRGBO(0, 150, 55, 1.0),
        ),
      ),
    );
  }
}