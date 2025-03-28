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
import 'models/car_model.dart';

class BookingDetailScreen extends StatefulWidget {
  final String date_debut;
  final String date_fin;
  final String prix_total;
  final int id;
  final CarModel car ;
  const BookingDetailScreen({Key? key, required this.date_debut, required this.date_fin, required this.prix_total , required this.id, required this.car}) : super(key: key);

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

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Track validation errors for each field
  final Map<String, bool> _fieldErrors = {
    'national_id': false,
    'first_name': false,
    'middle_name': false,
    'last_name': false,
    'email': false,
    'phone_number': false,
    'whatsapp_number': false,
    'street': false,
    'building_number': false,
    'nearest_location': false,
    'country': false,
    'city': false,
    'payment_method': false,
    'license_image': false,
    'id_image': false,
  };

  // Check if all required fields are filled
  bool get _isFormValid {
    return _idController.text.isNotEmpty &&
        _firstNameController.text.isNotEmpty &&
        _fatherNameController.text.isNotEmpty &&
        _lastNameController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _whatsappController.text.isNotEmpty &&
        _streetController.text.isNotEmpty &&
        _buildingNumberController.text.isNotEmpty &&
        _nearestLocationController.text.isNotEmpty &&
        selectedCountry != null &&
        selectedCityId != null &&
        _paymentMethod != null &&
        _licenseImage != null ;
  }

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

      // Show a dialog to let the user choose between camera and gallery
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source == null) {
        // User canceled the dialog
        return;
      }

      // Pick the image
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          if (isLicense) {
            _licenseImage = image;
          } else {
            _idImage = image;
          }
          _fieldErrors['license_image'] = _licenseImage == null;
          _fieldErrors['id_image'] = _idImage == null;
        });
      }
    } catch (e) {
      print("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to pick image: $e")),
      );
    }
  }

  Future<void> _submitForm() async {
    // Validate the form
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    // Validate images
    if (_licenseImage == null ) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please upload both license and ID images')),
      );
      return;
    }

    final url = Uri.parse('${Config.BASE_URL}/add_client/${widget.id}');
    final request = http.MultipartRequest('POST', url);

    // Add text fields
    request.fields['national_id'] = _idController.text;
    request.fields['first_name'] = _firstNameController.text;
    request.fields['middle_name'] = _fatherNameController.text;
    request.fields['last_name'] = _lastNameController.text;
    request.fields['email'] = "ceo@bwaacademy.com";
    request.fields['phone_number'] = _phoneController.text;
    request.fields['whatsapp_number'] = _whatsappController.text;
    request.fields['city_id'] = selectedCityId.toString();
    request.fields['country_id'] = selectedCountry ?? '';
    request.fields['street'] = _streetController.text;
    request.fields['building_number'] = _buildingNumberController.text;
    request.fields['nearest_location'] = _nearestLocationController.text;
    request.fields['payment_method'] = _paymentMethod ?? '';
    if(withDriver==true){
      request.fields['total_price'] = (double.parse(widget.prix_total)+10.0).toString();
    }
    else{
      request.fields['total_price'] = widget.prix_total;
    }
    request.fields['rent_date'] = widget.date_debut;
    request.fields['return_date'] = widget.date_fin;

    // Add files
    if (_licenseImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'driver_license', // Nom du champ attendu par le backend
        _licenseImage!.path,
      ));
    }

    // if (_idImage != null) {
    //   request.files.add(await http.MultipartFile.fromPath(
    //     'id_picture', // Nom du champ attendu par le backend
    //     _idImage!.path,
    //   ));
    // }

    // print("files :$request.files.id_picture");
    print("files :$request.files.driver_license");
    print("fields : $request.fields");

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Client added successfully!')),
        );

        // Navigate to DashboardClient after successful submission
        Navigator.pushReplacementNamed(context, '/DashboardClient');
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
  String createCarImage(CarModel car, String angle, String color) {
    // Base API URL for generating car images
    final url = Uri.https("cdn.imagin.studio", "/getimage");

    // Destructure the necessary properties from the car object
    final manuYear = car.manu_year;
    final modelName = car.modelName; // Get the model name in English
    final manufacturerName = car.manufacturerName; // Get the manufacturer name

    // Append query parameters for the API request
    final params = {
      "customer": "img", // API key
      "zoomType": "relative", // Zoom type
      "paintdescription": color, // Example color
      "modelFamily": modelName.split(" ")[0], // First word of the model name
      "make": manufacturerName, // Car make
      "modelYear": "$manuYear", // Manufacturing year
      "angle": angle, // Car angle
      "width": "800",
    };

    // Return the constructed URL as a string
    return url.replace(queryParameters: params).toString();
  }

  @override
  void initState() {
    fetchedCountries = fetchCountries();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = createCarImage(widget.car, "03", widget.car.carColor);
    return Scaffold(
      bottomSheet: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        color: Colors.white,
        child: ElevatedButton(
          onPressed: _isFormValid ? _submitForm : null, // Disable button if form is not valid
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: FutureBuilder(
                    future: precacheImage(NetworkImage(imageUrl), context),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        // Si l'image est chargée, l'afficher
                        return Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 150, // Limite l'image à 40% de la carte
                        );
                      } else {
                        // Pendant le chargement, afficher un indicateur de progression
                        return Container(
                          height: 90,
                          color: Colors.grey[300],
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                    },
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Text('With Driver', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    if (withDriver) // Afficher "+10 JOD" uniquement si le switch est activé
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          '+10 JOD',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green, // Vous pouvez personnaliser la couleur
                          ),
                        ),
                      ),
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
                          _fieldErrors['country'] = value == null;
                        });

                        List<Map<String, dynamic>> fetchedCities = await fetchCities(value!);
                        setState(() {
                          cities = fetchedCities;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: "اختر البلد",
                        border: OutlineInputBorder(),
                        errorBorder: _fieldErrors['country'] ?? false
                            ? OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        )
                            : null,
                      ),
                      validator: (value) {
                        if (value == null) {
                          setState(() {
                            _fieldErrors['country'] = true;
                          });
                          return 'Please select a country';
                        }
                        setState(() {
                          _fieldErrors['country'] = false;
                        });
                        return null;
                      },
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
                        _fieldErrors['city'] = value == null;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "موقع الاستلام",
                      border: OutlineInputBorder(),
                      errorBorder: _fieldErrors['city'] ?? false
                          ? OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      )
                          : null,
                    ),
                    validator: (value) {
                      if (value == null) {
                        setState(() {
                          _fieldErrors['city'] = true;
                        });
                        return 'Please select a city';
                      }
                      setState(() {
                        _fieldErrors['city'] = false;
                      });
                      return null;
                    },
                  ),
                SizedBox(height: 10),
                _buildTextField('رقم الرخصة', _idController, isRequired: true, fieldKey: 'national_id'),
                SizedBox(height: 10),
                _buildTextField('الاسم الأول', _firstNameController, isRequired: true, fieldKey: 'first_name'),
                SizedBox(height: 10),
                _buildTextField('اسم الأب', _fatherNameController, isRequired: true, fieldKey: 'middle_name'),
                SizedBox(height: 10),
                _buildTextField('الاسم الأخير', _lastNameController, isRequired: true, fieldKey: 'last_name'),
                SizedBox(height: 10),
                _buildTextField('رقم الهاتف', _phoneController, isPhone: true, fieldKey: 'phone_number'),
                SizedBox(height: 10),
                _buildTextField('رقم واتساب', _whatsappController, isPhone: true, fieldKey: 'whatsapp_number'),
                SizedBox(height: 10),
                _buildTextField('الشارع', _streetController, isRequired: true, fieldKey: 'street'),
                SizedBox(height: 10),
                _buildTextField('رقم المبنى', _buildingNumberController, isRequired: true, fieldKey: 'building_number'),
                SizedBox(height: 10),
                _buildTextField('أقرب موقع', _nearestLocationController, isRequired: true, fieldKey: 'nearest_location'),
                SizedBox(height: 10),
                _buildImagePicker('رخصة القيادة', _licenseImage, true),
                SizedBox(height: 10),
                //_buildImagePicker('صورة الهوية أو جواز السفر', _idImage, false),
                SizedBox(height: 10),
                _buildDropdown('طريقة الدفع', _paymentMethod, _paymentMethods, (value) {
                  setState(() {
                    _paymentMethod = value;
                    _fieldErrors['payment_method'] = value == null;
                  });
                }),
                SizedBox(height: 80),
              ],
            ),
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
        errorBorder: _fieldErrors['payment_method'] ?? false
            ? OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        )
            : null,
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null) {
          setState(() {
            _fieldErrors['payment_method'] = true;
          });
          return 'Please select a payment method';
        }
        setState(() {
          _fieldErrors['payment_method'] = false;
        });
        return null;
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isRequired = false, bool isEmail = false, bool isPhone = false, required String fieldKey}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        errorBorder: _fieldErrors[fieldKey] ?? false
            ? OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        )
            : null,
      ),
      onChanged: (value) {
        setState(() {
          _fieldErrors[fieldKey] = value.isEmpty;
        });
      },
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          setState(() {
            _fieldErrors[fieldKey] = true;
          });
          return 'This field is required';
        }
        if (isEmail && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
          setState(() {
            _fieldErrors[fieldKey] = true;
          });
          return 'Please enter a valid email';
        }
        if (isPhone && !RegExp(r'^[0-9]{8,15}$').hasMatch(value!)) {
          setState(() {
            _fieldErrors[fieldKey] = true;
          });
          return 'Please enter a valid phone number';
        }
        setState(() {
          _fieldErrors[fieldKey] = false;
        });
        return null;
      },
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
              border: Border.all(color: _fieldErrors[isLicense ? 'license_image' : 'id_image'] ?? false ? Colors.red : Colors.grey),
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
        if (image != null) // Show image preview if an image is selected
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Image.file(
              File(image.path),
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            ),
          ),
      ],
    );
  }
}