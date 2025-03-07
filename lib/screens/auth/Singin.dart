import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:car/utils/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../dashboard_client.dart'; // Import SharedPreferences
class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false; // To show a loading indicator

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Function to call the login API
  Future<void> _login() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    // API endpoint
   const String apiUrl = '${Config.BASE_URL}/login';

    // Prepare the request body
    final Map<String, String> requestBody = {
      'email': _emailController.text,
      'password': _passwordController.text,
    };
print(requestBody);

    try {
      // Send POST request to the API
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );
print (response.headers);
      // Check the response status code
      if (response.statusCode == 200) {


        // Successful login
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('Login successful: $responseData');
        // Extract the token from the response
        final String token = responseData['access_token']; // Assurez-vous que la clé est correcte

        // Save the token to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        print(token);

        // Navigate to the home screen or perform other actions
       // Navigator.pushNamed(context, '/HomeScreen');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login success'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushNamed(context, '/dashboardinstitution');
      } else {
        // Handle errors
        final Map<String, dynamic> errorData = json.decode(response.body);
        print('Login failed: ${errorData['message']}');

        // Show error message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${errorData['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Handle network or server errors
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Sign In",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Icône de retour
          onPressed: () {
            // Navigation vers l'écran précédent
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CarSearchPage(),
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // App Logo at the Middle Top
              const SizedBox(height: 40),
              Center(
                child: Image.asset(
                  'assets/logo.png', // Replace with your app logo path
                  height: 100,
                  width: 100,
                ),
              ),
              const SizedBox(height: 40),

              // Email Field
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

              // Password Field
              const Text(
                "Password",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Enter your password",
                  prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Navigate to Forgot Password Screen
                    Navigator.pushNamed(context, '/forgetpassword');
                  },
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Sign-In Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login, // Disable button when loading
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white) // Show loading indicator
                      : const Text(
                    "Sign In",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
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
              "Don't have an account?",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 5),
            GestureDetector(
              onTap: () {
                // Navigate to SignUpScreen
                Navigator.pushNamed(context, '/SignUpScreen');
              },
              child: const Text(
                "Sign Up",
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
}