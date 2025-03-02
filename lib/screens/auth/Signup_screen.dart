import 'package:car/screens/auth/Singin.dart';
import 'package:car/utils/config.dart';
import 'package:car/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class RegisterInstitutionScreen extends StatefulWidget {
  @override
  _RegisterInstitutionScreenState createState() =>
      _RegisterInstitutionScreenState();
}

class _RegisterInstitutionScreenState extends State<RegisterInstitutionScreen> {
  final TextEditingController _orgNameController = TextEditingController();
  final TextEditingController _orgNumberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Variables pour le type d'institution
  String? _selectedOrgType; // Valeur sélectionnée dans la DropdownButton
  final List<Map<String, dynamic>> _orgTypes = [
    {'label': 'Private', 'value': '1'},
    {'label': 'Tourism', 'value': '2'},
  ];

  Future<void> _submitForm() async {
      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('${Config.BASE_URL}/register-institution'), // Remplacez par l'URL correcte
        );

        // Ajouter les champs texte
        request.fields['orgName'] = _orgNameController.text;
        request.fields['orgNumber'] = _orgNumberController.text;
        request.fields['orgType'] = _selectedOrgType ?? '1'; // Valeur par défaut si non sélectionné
        request.fields['name'] = _nameController.text;
        request.fields['number'] = _numberController.text;
        request.fields['email'] = _emailController.text;
        request.fields['password'] = _passwordController.text;
        request.fields['institutionTypeId'] = _selectedOrgType ?? '1';



        // Envoyer la requête
        var response = await request.send();

        if (response.statusCode == 200) {
          // Afficher une AlertDialog en cas de succès
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Inscription réussie !'),
                content: Text(
                    'Votre inscription est en cours de traitement. Un e-mail et un message WhatsApp de confirmation seront envoyés bientôt.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      // Naviguer vers /DashboardClient
                      Navigator.pushReplacementNamed(context, '/DashboardClient');
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          // Erreur
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de l\'inscription')),
          );
        }
      } catch (e) {
        // Gestion des erreurs de connexion
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de connexion : $e')),
        );
      }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: true,
        title:const Text('Inscription Institution',
          style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(height: 20),
                const Text(
                  "Nom de l\'institution",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _orgNameController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: "'Nom de l\'institution",
                    prefixIcon: const Icon(Icons.business, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Numéro de l\'institution',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _orgNumberController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: 'Numéro de l\'institution',
                    prefixIcon: const Icon(Icons.numbers, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'type d institution',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                // Dropdown pour le type d'institution
                _buildOrgTypeDropdown(),
                const SizedBox(height: 20),
                const Text(
                  'Nom complet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _nameController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: 'Nom complet',
                    prefixIcon: const Icon(Icons.person, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Numéro de téléphone',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _numberController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: 'Numéro de téléphone',
                    prefixIcon: const Icon(Icons.phone, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Email",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "Enter your email",
                    prefixIcon: const Icon(Icons.email, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Mot de passe",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: "Mot de passe",
                    prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm, // Disable button when loading
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Register",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                heightSpace20,
              ],
            ),
           ),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Already have an account?",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 5),
                GestureDetector(
                  onTap: () {
                    // Navigate to SignUpScreen
                    Navigator.pushNamed(context, '/singin');
                  },
                  child: const Text(
                    "Sign In",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

  }



  // Méthode pour construire la DropdownButton
  Widget _buildOrgTypeDropdown() {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<String>(
        value: _selectedOrgType,
        decoration: InputDecoration(
          labelText: 'Type d\'institution',
          prefixIcon: Icon(Icons.category, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        items: _orgTypes.map((orgType) {
          return DropdownMenuItem<String>(
            value: orgType['value'],
            child: Text(orgType['label']),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedOrgType = value;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Veuillez sélectionner un type d\'institution';
          }
          return null;
        },
      ),
    );
  }
}