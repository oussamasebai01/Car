import 'package:car/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import the http package
import 'dart:convert'; // For JSON encoding/decoding

class OtpScreen extends StatefulWidget {
  final String email; // Email passed from the ForgotPasswordScreen
  const OtpScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false; // To show a loading indicator
  bool _isOtpValid = false; // To track if OTP is valid (6 digits)
  bool _isPasswordVisible = false; // To toggle password visibility

  void _validateOtp(String otp) {
    // Check if OTP is exactly 6 digits
    setState(() {
      _isOtpValid = otp.length == 6;
    });
  }

  Future<void> _changePassword() async {
    final otp = _otpController.text.trim();
    final password = _passwordController.text.trim();

    // Validate password
    if (password.isEmpty || password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 8 characters')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      // API endpoint
      const url = '${Config.BASE_URL}/password/change';
      print(widget.email);

      // Request body
      final body = jsonEncode({
        'email': widget.email,
        'otp': otp,
        'password': password,
      });

      // Make POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      // Log the raw response for debugging
      print('API Response: ${response.body}');

      // Check response status
      if (response.statusCode == 200) {
        // Try to decode the JSON response
        try {
          final responseData = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'] ?? 'Password changed successfully')),
          );

          // Navigate to the DashboardClient screen
          Navigator.pushReplacementNamed(context, '/singin');
        } catch (e) {
          // Handle JSON decoding errors
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to decode API response')),
          );
        }
      } else {
        // Handle non-200 responses
        try {
          final responseData = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'] ?? 'Failed to change password')),
          );
        } catch (e) {
          // Handle JSON decoding errors
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response.body}')),
          );
        }
      }
    } catch (e) {
      // Handle network or server errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP Verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Enter OTP',
                border: OutlineInputBorder(),
                hintText: '123456',
              ),
              onChanged: _validateOtp, // Validate OTP as the user types
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible, // Hide/show password
              enabled: _isOtpValid, // Enable only if OTP is valid
              decoration: InputDecoration(
                labelText: 'New Password',
                border: const OutlineInputBorder(),
                hintText: 'Enter your new password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible; // Toggle visibility
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isOtpValid && !_isLoading ? _changePassword : null, // Disable if OTP is invalid or loading
              style: ElevatedButton.styleFrom(
                side: const BorderSide(
                  color: Colors.green, // Green border color
                  width: 2.0, // Border width
                ),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white) // Show loading indicator
                  : const Text(
                'Change Password',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}