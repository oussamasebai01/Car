import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:car/utils/config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/constant.dart';

class BookingDetailScreen extends StatefulWidget {

  final String date_debut;
  final String date_fin;
  final String prix_total;
  const BookingDetailScreen({Key? key, required this.date_debut, required this.date_fin , required this.prix_total}) : super(key: key);

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
  List<String> cities = [];

  final List<String> _paymentMethods = ['Cash', 'Clique'];
  String? selectedCountry;
  String? selectedCity;
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
      final response = await http.get(
          Uri.parse("${Config.BASE_URL}/countries") );

      print("response :$response");
      if (response.statusCode == 200) {
        List<dynamic> countriesFromServer = json.decode(response.body);
        print("Countries from server: $countriesFromServer");
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
          Uri.parse("${Config.BASE_URL}/countries/$countryId/cities") );

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
      // Afficher un message d'erreur à l'utilisateur si nécessaire
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to open camera: $e")),
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
          onPressed: () {
            Navigator.pushNamed(context, '/PersonalInformationScreen');
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
              // Nouveaux champs ajoutés
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
                    decoration: InputDecoration(labelText: "اختر البلد", border: OutlineInputBorder(),),
                  );
                },
              ),
              SizedBox(height: 10),
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