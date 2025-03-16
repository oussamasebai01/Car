import 'package:car/screens/auth/Singin.dart';
import 'package:car/utils/config.dart';
import 'package:car/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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

  // متغيرات لنوع المؤسسة
  String? _selectedOrgType; // القيمة المحددة في DropdownButton
  final List<Map<String, dynamic>> _orgTypes = [
    {'label': 'خاصة', 'value': '1'},
    {'label': 'سياحية', 'value': '2'},
  ];

  Future<void> _submitForm() async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Config.BASE_URL}/register-institution'), // استبدل بالعنوان الصحيح
      );

      // إضافة الحقول النصية
      request.fields['orgName'] = _orgNameController.text;
      request.fields['orgNumber'] = _orgNumberController.text;
      request.fields['orgType'] = _selectedOrgType ?? '1'; // القيمة الافتراضية إذا لم يتم التحديد
      request.fields['name'] = _nameController.text;
      request.fields['number'] = _numberController.text;
      request.fields['email'] = _emailController.text;
      request.fields['password'] = _passwordController.text;
      request.fields['institutionTypeId'] = _selectedOrgType ?? '1';

      // إرسال الطلب
      var response = await request.send();

      if (response.statusCode == 200) {
        // عرض AlertDialog في حالة النجاح
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return OTPVerificationPopup(phoneNumber:_numberController.text);
          },
        );
      } else {
        // خطأ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء التسجيل')),
        );
      }
    } catch (e) {
      // إدارة أخطاء الاتصال
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في الاتصال: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('تسجيل مؤسسة',
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
                "اسم المؤسسة",
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
                  hintText: "اسم المؤسسة",
                  prefixIcon: const Icon(Icons.business, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'رقم المؤسسة',
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
                  hintText: 'رقم المؤسسة',
                  prefixIcon: const Icon(Icons.numbers, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'نوع المؤسسة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              // Dropdown لنوع المؤسسة
              _buildOrgTypeDropdown(),
              const SizedBox(height: 20),
              const Text(
                'الاسم الكامل',
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
                  hintText: 'الاسم الكامل',
                  prefixIcon: const Icon(Icons.person, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'رقم الهاتف',
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
                  hintText: 'رقم الهاتف',
                  prefixIcon: const Icon(Icons.phone, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
                  hintText: "أدخل بريدك الإلكتروني",
                  prefixIcon: const Icon(Icons.email, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: "كلمة المرور",
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
                  onPressed: _submitForm, // تعطيل الزر أثناء التحميل
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "تسجيل",
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
              "لديك حساب بالفعل؟",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 5),
            GestureDetector(
              onTap: () {
                // الانتقال إلى شاشة تسجيل الدخول
                Navigator.pushNamed(context, '/singin');
              },
              child: const Text(
                "تسجيل الدخول",
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


  // دالة لبناء DropdownButton
  Widget _buildOrgTypeDropdown() {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<String>(
        value: _selectedOrgType,
        decoration: InputDecoration(
          labelText: 'نوع المؤسسة',
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
            return 'الرجاء تحديد نوع المؤسسة';
          }
          return null;
        },
      ),
    );
  }
}
class OTPVerificationPopup extends StatefulWidget {
  final String phoneNumber;

  OTPVerificationPopup({required this.phoneNumber});

  @override
  _OTPVerificationPopupState createState() => _OTPVerificationPopupState();
}

class _OTPVerificationPopupState extends State<OTPVerificationPopup> {
  final List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());

  Future<void> _verifyOTP() async {
    String otp = _otpControllers.map((controller) => controller.text).join();

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/verify-otp'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'phone_number': widget.phoneNumber,
        'otp': otp,
      }),
    );

    if (response.statusCode == 200) {
      // OTP vérifié avec succès
      Navigator.of(context).pop(); // Fermer la popup
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP vérifié. En attente de l\'approbation de l\'administrateur.')),
      );
      // Naviguer vers une nouvelle page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SignInScreen()),
      );
    } else if (response.statusCode == 400 || response.statusCode == 401) {
      // Afficher un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP ou numéro de téléphone invalide.')),
      );
    } else {
      // Gérer d'autres erreurs
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Une erreur s\'est produite. Veuillez réessayer.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Vérification OTP"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Veuillez entrer le code OTP reçu"),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (index) {
              return SizedBox(
                width: 40,
                child: TextField(
                  controller: _otpControllers[index],
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    counterText: "",
                    border: OutlineInputBorder(),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _verifyOTP,
            child: Text("Vérifier"),
          ),
        ],
      ),
    );
  }
}
