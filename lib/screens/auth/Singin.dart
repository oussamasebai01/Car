import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:car/utils/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../dashboard_client.dart'; // استيراد SharedPreferences

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false; // لإظهار مؤشر التحميل

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // دالة لاستدعاء واجهة تسجيل الدخول
  Future<void> _login() async {
    setState(() {
      _isLoading = true; // إظهار مؤشر التحميل
    });

    // عنوان واجهة تسجيل الدخول
    const String apiUrl = '${Config.BASE_URL}/login';

    // إعداد بيانات الطلب
    final Map<String, String> requestBody = {
      'phone_number': _emailController.text,
      'password': _passwordController.text,
    };
    print(requestBody);

    try {
      // إرسال طلب POST إلى الواجهة
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );
      print(response.headers);

      // التحقق من رمز حالة الاستجابة
      if (response.statusCode == 200) {
        // تسجيل الدخول ناجح
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('تم تسجيل الدخول بنجاح: $responseData');
        // استخراج الرمز من الاستجابة
        final String token = responseData['access_token'];
        final int _id = responseData['user']['id'];

        // حفظ الرمز في SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setInt('id', _id);
        print('id dans prefs: $_id');
        print(token);

        // الانتقال إلى الشاشة الرئيسية أو تنفيذ إجراءات أخرى
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تسجيل الدخول بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushNamed(context, '/dashboardinstitution');
      } else {
        // التعامل مع الأخطاء
        final Map<String, dynamic> errorData = json.decode(response.body);
        print('فشل تسجيل الدخول: ${errorData['message']}');

        // عرض رسالة الخطأ للمستخدم
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تسجيل الدخول: ${errorData['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // التعامل مع أخطاء الشبكة أو الخادم
      print('خطأ: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ. يرجى المحاولة مرة أخرى لاحقًا.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false; // إخفاء مؤشر التحميل
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
          "تسجيل الدخول",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // زر الرجوع
          onPressed: () {
            // الانتقال إلى الشاشة السابقة
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
              // شعار التطبيق في الأعلى
              const SizedBox(height: 40),
              Center(
                child: Image.asset(
                  'assets/logo.png', // استبدل بمسار شعار التطبيق
                  height: 100,
                  width: 100,
                ),
              ),
              const SizedBox(height: 40),

              // حقل البريد الإلكتروني
              const Text(
                "البريد الإلكتروني",
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
                  hintText: "رقم الهاتف",
                  prefixIcon: const Icon(Icons.email, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // حقل كلمة المرور
              const Text(
                "كلمة المرور",
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
                  hintText: "أدخل كلمة المرور",
                  prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // نسيت كلمة المرور
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // الانتقال إلى شاشة نسيت كلمة المرور
                    Navigator.pushNamed(context, '/forgetpassword');
                  },
                  child: const Text(
                    "نسيت كلمة المرور؟",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // زر تسجيل الدخول
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login, // تعطيل الزر أثناء التحميل
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white) // إظهار مؤشر التحميل
                      : const Text(
                    "تسجيل الدخول",
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
              "ليس لديك حساب؟",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 5),
            GestureDetector(
              onTap: () {
                // الانتقال إلى شاشة التسجيل
                Navigator.pushNamed(context, '/SignUpScreen');
              },
              child: const Text(
                "إنشاء حساب",
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