import 'package:car/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart'; // For picking images
import 'dart:io'; // For handling File

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? institutionData;
  bool isLoading = true;
  String errorMessage = '';
  File? _logoImage; // To store the selected image file

  @override
  void initState() {
    super.initState();
    _fetchInstitutionData();
  }

  Future<void> _fetchInstitutionData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) {
      setState(() {
        isLoading = false;
        errorMessage = 'المستخدم غير مسجل الدخول';
      });
      return;
    }

    final url = '${Config.BASE_URL}/current-institution';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}'); // Log the response body

      if (response.statusCode == 200) {
        // Check if the response body is not empty
        if (response.body.isNotEmpty) {
          try {
            final data = json.decode(response.body);
            setState(() {
              institutionData = data;
              isLoading = false;
            });
          } catch (e) {
            setState(() {
              isLoading = false;
              errorMessage = 'فشل في تحليل البيانات: $e';
            });
          }
        } else {
          setState(() {
            isLoading = false;
            errorMessage = 'لا توجد بيانات متاحة';
          });
        }
      } else if (response.statusCode == 401) {
        setState(() {
          isLoading = false;
          errorMessage = 'غير مصرح به. يرجى تسجيل الدخول مرة أخرى.';
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'فشل في تحميل البيانات. يرجى المحاولة مرة أخرى لاحقًا.';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'حدث خطأ: $e';
      });
    }
  }

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final fileSize = await file.length(); // File size in bytes

      if (fileSize > 2 * 1024 * 1024) { // Limit of 2 MB
        setState(() {
          errorMessage = 'حجم الصورة كبير جدًا. الحد الأقصى هو 2 ميجابايت.';
        });
        return;
      }

      setState(() {
        _logoImage = file;
      });
    }
  }

  Future<void> _uploadLogo() async {
    if (_logoImage == null) {
      setState(() {
        errorMessage = 'لم يتم اختيار صورة.';
      });
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) {
      setState(() {
        errorMessage = 'المستخدم غير مسجل الدخول';
      });
      return;
    }

    final url = '${Config.BASE_URL}/logo-institution';

    try {
      print('Attaching file: ${_logoImage!.path}');
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['Authorization'] = 'Bearer $token';

      request.files.add(await http.MultipartFile.fromPath('logo_image', _logoImage!.path));

      print('Sending request...');
      var response = await request.send();
      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم تحديث الشعار بنجاح')),
          );

          await _fetchInstitutionData();
        } catch (e) {
          setState(() {
            errorMessage = 'فشل في تحليل البيانات: $e';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل في تحليل البيانات: $e')),
          );
        }
      } else {
        setState(() {
          errorMessage = 'حدث خطأ: ${response.statusCode}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = 'حدث خطأ: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الملف الشخصي'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            _buildInstitutionInfo(),
            _buildUsersSection(),
            _buildReviewsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      elevation: 8, // Add elevation for shadow
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFFFAFAFA), // Very light gray background
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Center(
                    child: _logoImage != null
                        ? Image.file(
                      _logoImage!,
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain, // Don't crop
                    )
                        : (institutionData != null &&
                        institutionData!['logo_image'] != null &&
                        institutionData!['logo_image'].toString().isNotEmpty)
                        ? Image.network(
                      institutionData!['logo_image'],
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain, // Don't crop
                    )
                        : Container(
                      width: 200,
                      height: 200,
                      color: Colors.transparent, // Empty space
                    ),
                  ),
                  GestureDetector(
                    onTap: _pickImage, // Trigger image picker on tap
                    child: Icon(
                      Icons.camera_alt,
                      size: 28, // Bigger icon
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              institutionData?['name'] ?? 'اسم المؤسسة',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 5),
            Text(
              institutionData?['institution_number'] ?? 'رقم المؤسسة',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 20),
            // Add a button to upload the selected image
            if (_logoImage != null)
              ElevatedButton(
                onPressed: _uploadLogo, // Trigger upload on press
                child: Text('رفع الصورة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Method to build institution information section
  Widget _buildInstitutionInfo() {
    return Card(
      elevation: 8, // Add elevation for shadow
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'معلومات المؤسسة',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            _buildInfoRow('العنوان', institutionData?['address_en'] ?? 'غير متوفر'),
            _buildInfoRow('رقم الطوارئ', institutionData?['emergency_number'] ?? 'غير متوفر'),
            _buildInfoRow('عدد السيارات', '${institutionData?['institution_cars']?.length ?? '0'}'),
          ],
        ),
      ),
    );
  }

  // Method to build a single row of information
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // Method to build the users section
  Widget _buildUsersSection() {
    return Card(
      elevation: 8, // Add elevation for shadow
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'المستخدم',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: institutionData?['users']?.length ?? 0,
              itemBuilder: (context, index) {
                var user = institutionData?['users'][index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text(user['name'] ?? 'غير متوفر'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Method to build the reviews section
  Widget _buildReviewsSection() {
    return Card(
      elevation: 8, // Add elevation for shadow
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'التقييمات',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: institutionData?['institution_reviews']?.length ?? 0,
              itemBuilder: (context, index) {
                var review = institutionData?['institution_reviews'][index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    leading: Icon(Icons.star, color: Colors.amber),
                    title: Text('التقييم: ${review['rating'] ?? 'غير متوفر'}'),
                    subtitle: Text(review['comment'] ?? 'لا يوجد تعليق'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}