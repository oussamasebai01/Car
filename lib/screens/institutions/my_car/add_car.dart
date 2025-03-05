import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

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

  List<dynamic> manufactures = [];
  List<dynamic> models = [];
  List<String> countries = ['Tunisia', 'Jordan'];
  List<String> cities = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchManufactures();
    if (widget.isEdit && widget.tempCar != null) {
      setFields(widget.tempCar!);
    }
  }

  Future<void> fetchManufactures() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/car-manufactures'));
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
      final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/car-models/$manufacturerId'));
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

  void setFields(Map<String, dynamic> car) {
    final splitArray = car['tagNumber'].split('-');
    setState(() {
      _formData['manufacturer'] = car['model']['manufacture']['id'];
      _formData['model'] = car['model']['id'];
      _formData['tagNumber1'] = splitArray[0];
      _formData['tagNumber2'] = splitArray[1];
      _formData['manuYear'] = car['manu_year'];
      _formData['pricePerDay'] = car['price_per_day'];
      _formData['pricePerWeek'] = car['price_per_week'];
      _formData['pricePerMonth'] = car['price_per_month'];
      _formData['pricePerYear'] = car['price_per_year'];
      _formData['gasType'] = car['gaz_type'];
      _formData['freeCancellation'] = car['free_cancellation'];
      _formData['babySeat'] = car['baby_seat'];
      _formData['transmission'] = car['transmission'];
      _formData['seatNumber'] = car['seat_number'];
      _formData['country'] = car['country'];
      _formData['city'] = car['city'];
      _formData['color'] = car['color'];
      _formData['availability'] = car['availability'];
      _formData['reason'] = car['reason'];
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
        'country': _formData['country'],
        'city': "Ariana",
        'availability': _formData['availability'],
        'description_availability': _formData['availability'] == 0 ? _formData['reason'] : '',
      };

      final response = widget.isEdit
          ? await http.put(
        Uri.parse('http://10.0.2.2:8000/api/update-institution-cars/${widget.tempCar!['id']}'),
        body: json.encode(payload),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      )
          : await http.post(
        Uri.parse('http://10.0.2.2:8000/api/add-cars'),
        body: json.encode(payload),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.isEdit ? 'Car updated successfully!' : 'Car added successfully!')),
        );
        Navigator.pop(context, true); // Return to previous screen with refresh
      } else {
        final errorResponse = json.decode(response.body);
        throw Exception(errorResponse['error'] ?? 'Failed to submit form');
      }
    } catch (e) {
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

              // Country Dropdown
              DropdownButtonFormField(
                value: _formData['country'].isEmpty ? null : _formData['country'],
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text('Select Country'),
                  ),
                  ...countries.map((country) {
                    return DropdownMenuItem(
                      value: country,
                      child: Text(country),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    _formData['country'] = value ?? '';
                    _formData['city'] = '';
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Country',
                  border: OutlineInputBorder(),
                ),
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

              // Color
              TextFormField(
                initialValue: _formData['color'],
                decoration: const InputDecoration(
                  labelText: 'Color',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _formData['color'] = value;
                  });
                },
              ),
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