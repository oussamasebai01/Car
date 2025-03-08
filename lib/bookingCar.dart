import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:car/utils/config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/constant.dart';
import 'package:intl/intl.dart';

import 'dashboard_client.dart';

class BookingDetailScreen extends StatefulWidget {
  final String date_debut;
  final String date_fin;
  final String prix_total;
  final int id;
  const BookingDetailScreen({Key? key, required this.date_debut, required this.date_fin, required this.prix_total , required this.id}) : super(key: key);

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  bool withDriver = true;
  String? pickText;
  String? returnText;
  Object? pickTimeResult;
  Object? returnTimeResult;

  // Variables pour les nouveaux champs
  String? _paymentMethod;
  XFile? _licenseImage;
  XFile? _idImage;
  List<Map<String, dynamic>> cities = []; // Stocker les villes avec leurs IDs

  final List<String> _paymentMethods = ['cash', 'cliq'];
  String? selectedCountry;
  int? selectedCityId; // Stocker l'ID de la ville sélectionnée
  String? selectedCityName; // Stocker le nom de la ville sélectionnée
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _buildingNumberController = TextEditingController();
  final TextEditingController _nearestLocationController = TextEditingController();
  late Future<List<Map<String, dynamic>>> fetchedCountries;

  Future<List<Map<String, dynamic>>> fetchCountries() async {
    try {
      final response = await http.get(Uri.parse("${Config.BASE_URL}/countries"));
      print("response :$response");
      if (response.statusCode == 200) {
        List<dynamic> countriesFromServer = json.decode(response.body);
        print("Countries from server: $countriesFromServer");
        return countriesFromServer.map((country) {
          return {
            "id": country["id"],
            "name": country["name_en"]
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

  Future<List<Map<String, dynamic>>> fetchCities(int countryId) async {
    try {
      final response = await http.get(Uri.parse("${Config.BASE_URL}/countries/$countryId/cities"));
      if (response.statusCode == 200) {
        List<dynamic> citiesFromServer = json.decode(response.body);
        return citiesFromServer.map((city) {
          return {
            "id": city["id"], // ID de la ville
            "name": city["name_en"] // Nom de la ville
          };
        }).toList();
      } else {
        print("Erreur serveur: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Erreur lors de la récupération des villes: $e");
      return [];
    }
  }

  Future<void> _pickImage(bool isLicense) async {
    try {
      final ImagePicker _picker = ImagePicker();
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          if (isLicense) {
            _licenseImage = image;
          } else {
            _idImage = image;
          }
        });
      }
    } catch (e) {
      print("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to open camera: $e")),
      );
    }
  }


  Future<void> _submitForm() async {
    final url = Uri.parse('${Config.BASE_URL}/add_client/${widget.id}');
    final request = http.MultipartRequest('POST', url);

    // Ajouter les champs texte
    request.fields['national_id'] = _idController.text;
    request.fields['first_name'] = _firstNameController.text;
    request.fields['middle_name'] = _fatherNameController.text;
    request.fields['last_name'] = _lastNameController.text;
    request.fields['email'] = _emailController.text;
    request.fields['phone_number'] = _phoneController.text;
    request.fields['whatsapp_number'] = _whatsappController.text;
    request.fields['city_id'] = selectedCityId.toString();
    request.fields['country_id'] = selectedCountry ?? '';
    request.fields['street'] = _streetController.text;
    request.fields['building_number'] = _buildingNumberController.text;
    request.fields['nearest_location'] = _nearestLocationController.text;
    request.fields['payment_method'] = _paymentMethod ?? '';
    request.fields['total_price'] = widget.prix_total;
    request.fields['rent_date'] = widget.date_debut;
    request.fields['return_date'] = widget.date_fin;

    // Ajouter les fichiers
    if (_licenseImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'driver_license', // Nom du champ attendu par le backend
        _licenseImage!.path,
      ));
    }

    if (_idImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'id_picture', // Nom du champ attendu par le backend
        _idImage!.path,
      ));
    }
   print("files :$request.files.id_picture");
   print("files :$request.files.driver_license");
    print("fields : $request.fields");

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Client added successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add client: ${await response.stream.bytesToString()}')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
      bottomSheet: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        color: Colors.white,
        child: ElevatedButton(
          onPressed:() {
            _submitForm() ; // Appeler _submitForm ici
        Navigator.push(
        context,
        MaterialPageRoute(
        builder: (context) => CarSearchPage(),
        ),
        );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            minimumSize: Size(double.infinity, 50),
          ),
          child: Text(
            'Continue',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
      appBar: AppBar(
        title: Text('Booking Information', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset("assets/bmw_x5.png", fit: BoxFit.cover, width: double.infinity),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('With Driver', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  CupertinoSwitch(
                    value: withDriver,
                    activeColor: primaryColor,
                    onChanged: (value) {
                      setState(() {
                        withDriver = value;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchCountries(),
                builder: (context, snapshot) {
                  print("Snapshot data: ${snapshot.data}");
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text("Erreur de chargement des pays");
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text("Aucun pays disponible");
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
                        selectedCityId = null;
                        selectedCityName = null;
                        cities = [];
                      });

                      List<Map<String, dynamic>> fetchedCities = await fetchCities(value!);
                      setState(() {
                        cities = fetchedCities;
                      });
                    },
                    decoration: InputDecoration(labelText: "اختر البلد", border: OutlineInputBorder()),
                  );
                },
              ),
              SizedBox(height: 10),
              if (cities.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: selectedCityName,
                  items: cities.map((Map<String, dynamic> city) {
                    return DropdownMenuItem<String>(
                      value: city["name"],
                      child: Text(city["name"]),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCityName = value;
                      selectedCityId = cities.firstWhere((city) => city["name"] == value)["id"];
                    });
                  },
                  decoration: InputDecoration(labelText: "موقع الاستلام", border: OutlineInputBorder()),
                ),
              SizedBox(height: 10),
              _buildTextField('رقم الهوية أو جواز السفر', _idController),
              SizedBox(height: 10),
              _buildTextField('الاسم الأول', _firstNameController),
              SizedBox(height: 10),
              _buildTextField('اسم الأب', _fatherNameController),
              SizedBox(height: 10),
              _buildTextField('الاسم الأخير', _lastNameController),
              SizedBox(height: 10),
              _buildTextField('البريد الإلكتروني', _emailController),
              SizedBox(height: 10),
              _buildTextField('رقم الهاتف', _phoneController),
              SizedBox(height: 10),
              _buildTextField('رقم واتساب', _whatsappController),
              SizedBox(height: 10),
              _buildTextField('الشارع', _streetController),
              SizedBox(height: 10),
              _buildTextField('رقم المبنى', _buildingNumberController),
              SizedBox(height: 10),
              _buildTextField('أقرب موقع', _nearestLocationController),
              SizedBox(height: 10),
              _buildImagePicker('رخصة القيادة', _licenseImage, true),
              SizedBox(height: 10),
              _buildImagePicker('صورة الهوية أو جواز السفر', _idImage, false),
              SizedBox(height: 10),
              _buildDropdown('طريقة الدفع', _paymentMethod, _paymentMethods, (value) {
                setState(() {
                  _paymentMethod = value;
                });
              }),
              SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildImagePicker(String label, XFile? image, bool isLicense) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        GestureDetector(
          onTap: () => _pickImage(isLicense),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  image != null ? 'Image selected' : 'Tap to take a photo',
                  style: TextStyle(color: Colors.grey),
                ),
                Icon(Icons.camera_alt, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }
}