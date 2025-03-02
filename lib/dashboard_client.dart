import 'dart:convert';
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

  late Future<List<Map<String, dynamic>>> fetchedCountries;
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
  Future<List<Map<String, dynamic>>> fetchCountries() async {
    try {
      final response = await http.get(
          Uri.parse('${Config.BASE_URL}/countries'));

      if (response.statusCode == 200) {
        List<dynamic> countriesFromServer = json.decode(response.body);

        return countriesFromServer.map((country) {
          return {
            "id": country["id"], // ✅ On récupère l'ID
            "name": country["name_en"] // ✅ Nom du pays en arabe
          };
        }).toList();
      } else {
        print("Erreur serveur: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Erreur lors de la récupération des pays: $e");
      return [];
    }
  }
////////////////////////////////////////////////////////////////////////////////////////////
  Future<void> searchCars() async {
    if (selectedCity == null || _pickupDateController.text.isEmpty || _returnDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veuillez sélectionner une ville et des dates valides.")),
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
              .map((carJson) => CarModel.fromJson(carJson))
              .toList();
          print(cars);
        });
      } else {
        throw Exception('Failed to load cars: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la recherche de voitures: $e")),
      );
    }
  }
  /////////////////////////////////////////////////////////////////////////////////////////////////////
  Future<List<String>> fetchCities(int countryId) async {
    try {
      final response = await http.get(
          Uri.parse("${Config.BASE_URL}/countries/$countryId/cities"));

      if (response.statusCode == 200) {
        List<dynamic> citiesFromServer = json.decode(response.body);
        return citiesFromServer.map((city) => city["name_en"].toString())
            .toList();
      } else {
        print("Erreur serveur: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Erreur lors de la récupération des villes: $e");
      return [];
    }
  }

  void calculateDaysDifference() {
    if (_pickupDateController.text.isNotEmpty &&
        _returnDateController.text.isNotEmpty) {
      DateTime pickupDate = DateTime.parse(_pickupDateController.text);
      DateTime returnDate = DateTime.parse(_returnDateController.text);

      setState(() {
        numberOfDays = returnDate
            .difference(pickupDate)
            .inDays;
      });
    }
  }



  @override
  void initState() {
    fetchedCountries = fetchCountries();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Rechercher une voiture"),
        actions: [
          IconButton(
            icon: Icon(Icons.login),
            onPressed: () {
              Navigator.pushReplacementNamed(context, "/singin");
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                            return Text("Erreur de chargement des pays");
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Text("Aucun pays disponible");
                          }

                          List<Map<String, dynamic>> countries = snapshot.data!;

                          return DropdownButtonFormField<int>( // ✅ Maintenant, on stocke un `int` (l'ID du pays)
                            value: selectedCountry != null ? int.tryParse(selectedCountry!) : null,
                            items: countries.map((country) {
                              return DropdownMenuItem<int>(
                                value: country["id"], // ✅ Utilisation de l'ID réel du pays
                                child: Text(country["name"]), // ✅ Affichage du nom du pays
                              );
                            }).toList(),
                            onChanged: (value) async {
                              setState(() {
                                selectedCountry = value.toString(); // ✅ Stocker l'ID du pays sélectionné sous forme de String
                                selectedCity = null;
                                cities = [];
                              });

                              // ✅ Charger les villes du pays sélectionné
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
                        onPressed: searchCars,////////////////////////////////////////
                        child: Text("بحث "),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      )
                    ],
                  ),
                ),
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
                          builder: (context) => CarDetailsPage(car: cars[index], numberOfDays: numberOfDays),
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
    );
  }
}
