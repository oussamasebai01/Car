import 'package:car/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // استيراد حزمة http
import 'dart:convert';

import 'otpverify.dart'; // لترميز وفك ترميز JSON

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false; // لإظهار مؤشر التحميل

  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();

    // التحقق من صحة البريد الإلكتروني
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال بريد إلكتروني صحيح')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // إظهار مؤشر التحميل
    });

    try {
      // عنوان واجهة API
      const url = '${Config.BASE_URL}/password/send-otp';

      // بيانات الطلب
      final body = jsonEncode({'email': email});

      // إرسال طلب POST
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      // التحقق من حالة الاستجابة
      if (response.statusCode == 200) {
        // النجاح: الانتقال إلى شاشة التحقق من OTP
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم إرسال OTP إلى $email')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(email: email),
          ),
        );
      } else {
        // الخطأ: عرض رسالة الخطأ
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? 'فشل إرسال OTP')),
        );
      }
    } catch (e) {
      // إدارة أخطاء الشبكة أو الخادم
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false; // إخفاء مؤشر التحميل
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نسيت كلمة المرور'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'البريد الإلكتروني',
                border: OutlineInputBorder(),
                hintText: 'أدخل بريدك الإلكتروني',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _sendOtp, // تعطيل الزر أثناء التحميل
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // لون الخلفية أخضر
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white) // إظهار مؤشر التحميل
                  : const Text(
                'إرسال OTP',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}