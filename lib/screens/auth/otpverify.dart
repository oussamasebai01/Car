import 'package:car/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // استيراد حزمة http
import 'dart:convert'; // لترميز وفك ترميز JSON

class OtpScreen extends StatefulWidget {
  final String email; // البريد الإلكتروني الممرر من شاشة ForgotPasswordScreen
  const OtpScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false; // لإظهار مؤشر التحميل
  bool _isOtpValid = false; // لتتبع ما إذا كان OTP صالحًا (6 أرقام)
  bool _isPasswordVisible = false; // لإظهار أو إخفاء كلمة المرور

  void _validateOtp(String otp) {
    // التحقق من أن OTP يتكون من 6 أرقام بالضبط
    setState(() {
      _isOtpValid = otp.length == 6;
    });
  }

  Future<void> _changePassword() async {
    final otp = _otpController.text.trim();
    final password = _passwordController.text.trim();

    // التحقق من صحة كلمة المرور
    if (password.isEmpty || password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب أن تكون كلمة المرور مكونة من 8 أحرف على الأقل')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // إظهار مؤشر التحميل
    });

    try {
      // عنوان واجهة API
      const url = '${Config.BASE_URL}/password/change';
      print(widget.email);

      // بيانات الطلب
      final body = jsonEncode({
        'email': widget.email,
        'otp': otp,
        'password': password,
      });

      // إرسال طلب POST
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      // طباعة الاستجابة الخام لأغراض التصحيح
      print('استجابة API: ${response.body}');

      // التحقق من حالة الاستجابة
      if (response.statusCode == 200) {
        // محاولة فك ترميز الاستجابة JSON
        try {
          final responseData = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'] ?? 'تم تغيير كلمة المرور بنجاح')),
          );

          // الانتقال إلى شاشة DashboardClient
          Navigator.pushReplacementNamed(context, '/singin');
        } catch (e) {
          // التعامل مع أخطاء فك ترميز JSON
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('فشل في فك ترميز استجابة API')),
          );
        }
      } else {
        // التعامل مع الاستجابات غير الناجحة (غير 200)
        try {
          final responseData = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'] ?? 'فشل في تغيير كلمة المرور')),
          );
        } catch (e) {
          // التعامل مع أخطاء فك ترميز JSON
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ: ${response.body}')),
          );
        }
      }
    } catch (e) {
      // التعامل مع أخطاء الشبكة أو الخادم
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في الشبكة: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false; // إخفاء مؤشر التحميل
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
        title: const Text('التحقق من OTP'),
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
                labelText: 'أدخل OTP',
                border: OutlineInputBorder(),
                hintText: '123456',
              ),
              onChanged: _validateOtp, // التحقق من OTP أثناء الكتابة
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible, // إظهار أو إخفاء كلمة المرور
              enabled: _isOtpValid, // التفعيل فقط إذا كان OTP صالحًا
              decoration: InputDecoration(
                labelText: 'كلمة المرور الجديدة',
                border: const OutlineInputBorder(),
                hintText: 'أدخل كلمة المرور الجديدة',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible; // تبديل الإظهار
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isOtpValid && !_isLoading ? _changePassword : null, // التعطيل إذا كان OTP غير صالح أو أثناء التحميل
              style: ElevatedButton.styleFrom(
                side: const BorderSide(
                  color: Colors.green, // لون الحدود أخضر
                  width: 2.0, // عرض الحدود
                ),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white) // إظهار مؤشر التحميل
                  : const Text(
                'تغيير كلمة المرور',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}