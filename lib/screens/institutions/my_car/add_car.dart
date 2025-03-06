import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/config.dart';
import 'car_liste.dart';

class AddInstitutionCarScreen extends StatefulWidget {
  final bool isEdit;
  final Map<String, dynamic>? tempCar;

  const AddInstitutionCarScreen({Key? key, this.isEdit = false, this.tempCar})
      : super(key: key);

  @override
  _AddInstitutionCarScreenState createState() => _AddInstitutionCarScreenState();
}

Future<String?> getAuthToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('auth_token');
}

class _AddInstitutionCarScreenState extends State<AddInstitutionCarScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedCountry;
  String? selectedCity;
  int? selectedCountryId;
  late Future<List<Map<String, dynamic>>> fetchedCountries;
  final Map<String, dynamic> _formData = {
    'manufacturer': '',
    'model': '',
    'tagNumber1': '',
    'tagNumber2': '',
    'manuYear': '',
    'pricePerDay': '',
    'pricePerWeek': '',
    'pricePerMonth': '',
    'pricePerYear': '',
    'gasType': '',
    'freeCancellation': false,
    'babySeat': false,
    'transmission': '',
    'seatNumber': '',
    'country': '',
    'city': 'Ariana',
    'color': '',
    'availability': 1,
    'reason': '',
  };

  static const colorOptions = [
    { 'value': 'Red', 'label': 'Red', 'color': '#ff0000' },
    { 'value': 'Blue', 'label': 'Blue', 'color': '#0000ff' },
    { 'value': 'Black', 'label': 'Black', 'color': '#000000' },
    { 'value': 'White', 'label': 'White', 'color': '#ffffff' },
    { 'value': 'Silver', 'label': 'Silver', 'color': '#c0c0c0' },
    { 'value': 'Green', 'label': 'Green', 'color': '#008000' },
    { 'value': 'Yellow', 'label': 'Yellow', 'color': '#ffff00' },
    { 'value': 'Orange', 'label': 'Orange', 'color': '#ffa500' },
    { 'value': 'Pink', 'label': 'Pink', 'color': '#ffc0cb' },
    { 'value': 'Purple', 'label': 'Purple', 'color': '#800080' },
    { 'value': 'Brown', 'label': 'Brown', 'color': '#a52a2a' },
    { 'value': 'Gray', 'label': 'Gray', 'color': '#808080' },
    { 'value': 'Beige', 'label': 'Beige', 'color': '#f5f5dc' },
    { 'value': 'Gold', 'label': 'Gold', 'color': '#ffd700' },
    { 'value': 'Bronze', 'label': 'Bronze', 'color': '#cd7f32' },
    { 'value': 'Turquoise', 'label': 'Turquoise', 'color': '#40e0d0' },
    { 'value': 'Champagne', 'label': 'Champagne', 'color': '#f7e7ce' },
    { 'value': 'Navy', 'label': 'Navy', 'color': '#000080' },
    { 'value': 'Teal', 'label': 'Teal', 'color': '#008080' },
    { 'value': 'Burgundy', 'label': 'Burgundy', 'color': '#800020' },
    { 'value': 'Lavender', 'label': 'Lavender', 'color': '#e6e6fa' },
    { 'value': 'Ivory', 'label': 'Ivory', 'color': '#fffff0' },
    { 'value': 'Pearl', 'label': 'Pearl', 'color': '#f0e5de' },
    { 'value': 'Mint', 'label': 'Mint', 'color': '#98ff98' },
    { 'value': 'Copper', 'label': 'Copper', 'color': '#b87333' },
    { 'value': 'Mahogany', 'label': 'Mahogany', 'color': '#c04000' },
    { 'value': 'Platinum', 'label': 'Platinum', 'color': '#e5e4e2' },
    { 'value': 'MatteBlack', 'label': 'Matte Black', 'color': '#212121' },
    { 'value': 'MatteWhite', 'label': 'Matte White', 'color': '#f2f2f2' },
    { 'value': 'MatteGray', 'label': 'Matte Gray', 'color': '#bdbdbd' },
    { 'value': 'Carbon', 'label': 'Carbon', 'color': '#3a3a3a' },
  ];

  // Extraire les labels de colorOptions et les convertir en majuscules
  final colors = colorOptions.map((option) {
    final label = option['label'] ?? ''; // Valeur par défaut si null
    return label;
  }).toList();
  List<dynamic> manufactures = [];
  List<dynamic> models = [];
  List<String> countries = ['Tunisia', 'Jordan'];
  List<String> cities = [];
  bool isLoading = false;

  @override
  void initState() {
    fetchedCountries = fetchCountries();
    super.initState();
    fetchManufactures();
    if (widget.isEdit && widget.tempCar != null) {
      setFields(widget.tempCar!);
    }
  }

  Future<void> fetchManufactures() async {
    try {
      final response = await http.get(Uri.parse('${Config.BASE_URL}/car-manufactures'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('data')) {
          setState(() {
            manufactures = responseData['data'];
          });
        } else {
          throw Exception('Invalid API response format');
        }
      } else {
        throw Exception('Failed to load manufactures');
      }
    } catch (e) {
      print('Error fetching manufactures: $e');
    }
  }

  Future<void> fetchModels(String manufacturerId) async {
    try {
      final response = await http.get(Uri.parse('${Config.BASE_URL}/car-models/$manufacturerId'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('data')) {
          setState(() {
            models = responseData['data'];
          });
        } else {
          throw Exception('Invalid API response format');
        }
      } else {
        throw Exception('Failed to load models');
      }
    } catch (e) {
      print('Error fetching models: $e');
    }
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

  void setFields(Map<String, dynamic> car) {
    final splitArray = car['tagNumber']?.split('-') ?? ['', '']; // Vérification de nullité
    setState(() {
      // _formData['manufacturer'] = car['model']?['manufacture']?? '';
      // _formData['model'] = car['model']?['id'] ?? '';
      _formData['tagNumber1'] = splitArray[0];
      _formData['tagNumber2'] = splitArray[1];
      _formData['manuYear'] = car['manu_year'] ?? '';
      _formData['pricePerDay'] = car['price_per_day']?.toString() ?? '';
      _formData['pricePerWeek'] = car['price_per_week']?.toString() ?? '';
      _formData['pricePerMonth'] = car['price_per_month']?.toString() ?? '';
      _formData['pricePerYear'] = car['price_per_year']?.toString() ?? '';
      _formData['gasType'] = car['gaz_type'] ?? '';
      _formData['freeCancellation'] = car['free_cancellation'] ?? false;
      _formData['babySeat'] = car['baby_seat'] ?? false;
      _formData['transmission'] = car['transmission'] ?? '';
      _formData['seatNumber'] = car['seat_number']?.toString() ?? '';
      _formData['country'] = car['country'] ?? '';
      _formData['city'] = car['city'] ?? 'Ariana';
      _formData['color'] = car['car_color'] ?? '';
      _formData['availability'] = car['availability'] ?? 1;
      _formData['reason'] = car['reason'] ?? '';
    });
  }

  Future<void> _submitForm() async {
    final token = await getAuthToken();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final payload = {
        'car_model_id': _formData['model'],
        'manufacturer_id': _formData['manufacturer'],
        'tag_number': '${_formData['tagNumber1']}-${_formData['tagNumber2']}',
        'manu_year': _formData['manuYear'],
        'price_per_day': double.parse(_formData['pricePerDay']),
        'price_per_week': double.parse(_formData['pricePerWeek']),
        'price_per_month': double.parse(_formData['pricePerMonth']),
        'price_per_year': double.parse(_formData['pricePerYear']),
        'gaz_type': _formData['gasType'],
        'free_cancellation': _formData['freeCancellation'],
        'transmission': _formData['transmission'],
        'seat_number': int.parse(_formData['seatNumber']),
        'car_color': _formData['color'],
        'country': selectedCountry,
        'city': selectedCity,
        'availability': _formData['availability'],
        'description_availability': _formData['availability'] == 0 ? _formData['reason'] : '',
      };

      // print('iddddddd :${widget.tempCar!['id']}');

      final response = widget.isEdit
          ? await http.post(
        Uri.parse('${Config.BASE_URL}/update-institution-cars/${widget.tempCar!['id']}'),
        body: json.encode(payload),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      )
          : await http.post(
        Uri.parse('${Config.BASE_URL}/add-cars'),
        body: json.encode(payload),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print(payload);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.isEdit ? 'Car updated successfully!' : 'Car added successfully!')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyBookingScreen(),
          ),
        );
      } else {
        final errorResponse = json.decode(response.body);
        throw Exception(errorResponse['error'] ?? 'Failed to submit form');
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Car' : 'Add Car'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Manufacturer Dropdown
              DropdownButtonFormField(
                value: _formData['manufacturer'].isEmpty ? null : _formData['manufacturer'],
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text('Select Manufacturer'),
                  ),
                  ...manufactures.map((manufacture) {
                    return DropdownMenuItem(
                      value: manufacture['id'].toString(),
                      child: Text(manufacture['name_en']),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    _formData['manufacturer'] = value ?? '';
                    _formData['model'] = '';
                  });
                  fetchModels(value.toString());
                },
                decoration: const InputDecoration(
                  labelText: 'Manufacturer',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Model Dropdown
              DropdownButtonFormField(
                value: _formData['model'].isEmpty ? null : _formData['model'],
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text('Select Model'),
                  ),
                  ...models.map((model) {
                    return DropdownMenuItem(
                      value: model['id'].toString(),
                      child: Text(model['name_en']),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    _formData['model'] = value ?? '';
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Model',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Tag Number
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _formData['tagNumber1'],
                      decoration: const InputDecoration(
                        labelText: 'Tag Number Part 1',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _formData['tagNumber1'] = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      initialValue: _formData['tagNumber2'],
                      decoration: const InputDecoration(
                        labelText: 'Tag Number Part 2',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _formData['tagNumber2'] = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Manufacture Year
              TextFormField(
                initialValue: _formData['manuYear'],
                decoration: const InputDecoration(
                  labelText: 'Manufacture Year',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _formData['manuYear'] = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Price Per Day
              TextFormField(
                initialValue: _formData['pricePerDay'],
                decoration: const InputDecoration(
                  labelText: 'Price Per Day',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _formData['pricePerDay'] = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Price Per Week
              TextFormField(
                initialValue: _formData['pricePerWeek'],
                decoration: const InputDecoration(
                  labelText: 'Price Per Week',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _formData['pricePerWeek'] = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Price Per Month
              TextFormField(
                initialValue: _formData['pricePerMonth'],
                decoration: const InputDecoration(
                  labelText: 'Price Per Month',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _formData['pricePerMonth'] = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Price Per Year
              TextFormField(
                initialValue: _formData['pricePerYear'],
                decoration: const InputDecoration(
                  labelText: 'Price Per Year',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _formData['pricePerYear'] = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Gas Type
              DropdownButtonFormField(
                value: _formData['gasType'].isEmpty ? null : _formData['gasType'],
                items: ['petrol', 'diesel', 'electric', 'hybrid'].map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _formData['gasType'] = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Gas Type',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Free Cancellation
              DropdownButtonFormField(
                value: _formData['freeCancellation'],
                items: [true, false].map((value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value ? 'Yes' : 'No'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _formData['freeCancellation'] = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Free Cancellation',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Baby Seat
              DropdownButtonFormField(
                value: _formData['babySeat'],
                items: [true, false].map((value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value ? 'Yes' : 'No'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _formData['babySeat'] = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Baby Seat',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Transmission
              DropdownButtonFormField(
                value: _formData['transmission'].isEmpty ? null : _formData['transmission'],
                items: ['automatic', 'manual'].map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _formData['transmission'] = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Transmission',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Seat Number
              TextFormField(
                initialValue: _formData['seatNumber'],
                decoration: const InputDecoration(
                  labelText: 'Seat Number',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _formData['seatNumber'] = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              Column(
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

                        return DropdownButtonFormField<int>(
                          value: selectedCountryId, // ✅ Utilise l'ID du pays comme valeur sélectionnée
                          items: countries.map((country) {
                            return DropdownMenuItem<int>(
                              value: country["id"], // ✅ Utilisation de l'ID du pays
                              child: Text(country["name"]), // ✅ Affichage du nom du pays
                            );
                          }).toList(),
                          onChanged: (value) async {
                            setState(() {
                              selectedCountryId = value; // ✅ Stocke l'ID du pays sélectionné
                              selectedCountry = countries.firstWhere((country) => country["id"] == value)["name"]; // ✅ Stocke le nom du pays
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

                  ]
              ),
              const SizedBox(height: 16),

              // City Dropdown
              // DropdownButtonFormField(
              //   value: _formData['city'],
              //   items: [
              //     DropdownMenuItem(
              //       value: null,
              //       child: Text('Select City'),
              //     ),
              //     ...cities.map((city) {
              //       return DropdownMenuItem(
              //         value: city,
              //         child: Text(city),
              //       );
              //     }).toList(),
              //   ],
              //   onChanged: (value) {
              //     setState(() {
              //       _formData['city'] = value ?? '';
              //     });
              //   },
              //   decoration: const InputDecoration(
              //     labelText: 'City',
              //     border: OutlineInputBorder(),
              //   ),
              // ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _formData['color']?.isEmpty ?? true ? null : _formData['color'], // Vérification null-safe
                items: colors.map((String color) {
                  // Trouver l'objet color correspondant dans colorOptions
                  final colorOption = colorOptions.firstWhere(
                        (option) => option['label'] == color,
                    orElse: () => { 'label': 'UNKNOWN', 'color': '#000000' }, // Ajout de 'label'
                  );

                  // Vérifier que colorOption['color'] n'est pas null
                  final colorHex = (colorOption['color'] ?? '#000000') as String;
                  final colorValue = colorHex.replaceAll('#', '0xFF');

                  return DropdownMenuItem<String>(
                    value: color,
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: Color(int.parse(colorValue)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Text(color),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _formData['color'] = value ?? ''; // Assurez-vous que la valeur n'est pas null
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Color',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a color';
                  }
                  return null;
                },
              ),
              //Color
              // TextFormField(
              //   initialValue: _formData['color'],
              //   decoration: const InputDecoration(
              //     labelText: 'Color',
              //     border: OutlineInputBorder(),
              //   ),
              //   onChanged: (value) {
              //     setState(() {
              //       _formData['color'] = value;
              //     });
              //   },
              // ),


              const SizedBox(height: 16),

              // Availability
              DropdownButtonFormField(
                value: _formData['availability'],
                items: [
                  DropdownMenuItem(value: 1, child: Text('Available')),
                  DropdownMenuItem(value: 0, child: Text('Not Available')),
                ],
                onChanged: (value) {
                  setState(() {
                    _formData['availability'] = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Availability',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Reason (only shown if availability is 0)
              if (_formData['availability'] == 0)
                TextFormField(
                  initialValue: _formData['reason'],
                  decoration: const InputDecoration(
                    labelText: 'Reason',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _formData['reason'] = value;
                    });
                  },
                ),
              const SizedBox(height: 16),

              // Submit Button
              ElevatedButton(
                onPressed: isLoading ? null : _submitForm,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : Text(widget.isEdit ? 'Update' : 'Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}