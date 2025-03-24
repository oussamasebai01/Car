import 'package:car/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? institutionData;
  Map<String, dynamic>? financialMetrics;
  List<dynamic>? expenseBreakdown;
  List<dynamic>? maintenanceAlerts;
  bool isLoading = true;
  String errorMessage = '';
  File? _logoImage;

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    setState(() {
      isLoading = true;
    });
    await _fetchInstitutionData();
    await _fetchFinancialMetrics();
    await _fetchExpenseBreakdown();
    await _fetchMaintenanceAlerts();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchInstitutionData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    if (token == null) {
      setState(() => errorMessage = 'المستخدم غير مسجل الدخول');
      return;
    }

    final url = '${Config.BASE_URL}/current-institution';
    try {
      final response = await http.get(Uri.parse(url), headers: _authHeaders(token));
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        setState(() => institutionData = json.decode(response.body));
      } else {
        setState(() => errorMessage = _handleError(response.statusCode));
      }
    } catch (e) {
      setState(() => errorMessage = 'حدث خطأ: $e');
    }
  }

  Future<void> _fetchFinancialMetrics() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    if (token == null) return;

    final url = '${Config.BASE_URL}/institution-financial-metrics';
    try {
      final response = await http.get(Uri.parse(url), headers: _authHeaders(token));
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        setState(() => financialMetrics = json.decode(response.body));
      }
    } catch (e) {
      setState(() => errorMessage = 'خطأ في جلب المقاييس المالية: $e');
    }
  }

  Future<void> _fetchExpenseBreakdown() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    if (token == null) return;

    final url = '${Config.BASE_URL}/institution-expense-breakdown';
    try {
      final response = await http.get(Uri.parse(url), headers: _authHeaders(token));
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        setState(() => expenseBreakdown = json.decode(response.body));
      }
    } catch (e) {
      setState(() => errorMessage = 'خطأ في جلب تفاصيل المصروفات: $e');
    }
  }

  Future<void> _fetchMaintenanceAlerts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    if (token == null) return;

    final url = '${Config.BASE_URL}/institution-maintenance-alerts';
    try {
      final response = await http.get(Uri.parse(url), headers: _authHeaders(token));
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        setState(() => maintenanceAlerts = json.decode(response.body));
      }
    } catch (e) {
      setState(() => errorMessage = 'خطأ في جلب تنبيهات الصيانة: $e');
    }
  }

  Map<String, String> _authHeaders(String token) => {
    'Authorization': 'Bearer $token',
    'Accept': 'application/json',
  };

  String _handleError(int statusCode) {
    if (statusCode == 401) return 'غير مصرح به. يرجى تسجيل الدخول مرة أخرى.';
    return 'فشل في تحميل البيانات. يرجى المحاولة مرة أخرى لاحقًا.';
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      if (await file.length() > 2 * 1024 * 1024) {
        setState(() => errorMessage = 'حجم الصورة كبير جدًا. الحد الأقصى هو 2 ميجابايت.');
        return;
      }
      setState(() => _logoImage = file);
    }
  }

  Future<void> _uploadLogo() async {
    if (_logoImage == null) {
      setState(() => errorMessage = 'لم يتم اختيار صورة.');
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    if (token == null) return;

    final url = '${Config.BASE_URL}/logo-institution';
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(_authHeaders(token));
    request.files.add(await http.MultipartFile.fromPath('logo_image', _logoImage!.path));

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم تحديث الشعار بنجاح')),
        );
        await _fetchInstitutionData();
      } else {
        setState(() => errorMessage = 'حدث خطأ: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => errorMessage = 'حدث خطأ: $e');
    }
  }

  Future<void> _refreshPage() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
      _logoImage = null;
    });
    await _fetchAllData();
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
          ? Center(child: CircularProgressIndicator(color: Colors.green))
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage, style: TextStyle(color: Colors.red)))
          : RefreshIndicator(
        onRefresh: _refreshPage,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(),
              _buildFinancialMetrics(),
              _buildExpenseBreakdown(),
              _buildMaintenanceAlerts(),
              _buildInstitutionInfo(),
              _buildUsersSection(),
              _buildReviewsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      elevation: 8,
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFFFAFAFA),
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
                        ? Image.file(_logoImage!, width: 200, height: 200, fit: BoxFit.contain)
                        : (institutionData?['logo_image']?.isNotEmpty ?? false)
                        ? Image.network(institutionData!['logo_image'], width: 200, height: 200, fit: BoxFit.contain)
                        : Container(width: 200, height: 200, color: Colors.transparent),
                  ),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Icon(Icons.camera_alt, size: 28, color: Colors.green),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              institutionData?['name'] ?? 'اسم المؤسسة',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 5),
            Text(
              institutionData?['institution_number'] ?? 'رقم المؤسسة',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            SizedBox(height: 20),
            if (_logoImage != null)
              ElevatedButton(
                onPressed: _uploadLogo,
                child: Text('رفع الصورة'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialMetrics() {
    if (financialMetrics == null) return SizedBox.shrink();
    return Card(
      elevation: 8,
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المقاييس المالية', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
            SizedBox(height: 10),
            _buildMetricRow('إجمالي الإيرادات', '${financialMetrics!['totalRevenue']} \$'),
            _buildMetricRow('نمو الإيرادات', '${financialMetrics!['revenueGrowth']} %'),
            _buildMetricRow('إجمالي المصروفات', '${financialMetrics!['totalExpenses']} \$'),
            _buildMetricRow('تكاليف الصيانة', '${financialMetrics!['maintenanceCosts']} \$'),
            _buildMetricRow('إجمالي الربح', '${financialMetrics!['totalProfit']} \$', isProfit: true),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, {bool isProfit = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          Text(value, style: TextStyle(fontSize: 16, color: isProfit ? Colors.green : Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildExpenseBreakdown() {
    if (expenseBreakdown == null || expenseBreakdown!.isEmpty) return SizedBox.shrink();
    return Card(
      elevation: 8,
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('تفاصيل المصروفات', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
            SizedBox(height: 10),
            ...expenseBreakdown!.map((expense) => _buildExpenseRow(expense['category'], expense['amount'])).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseRow(String category, int amount) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(category, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          Text('$amount \$', style: TextStyle(fontSize: 16, color: Colors.redAccent)),
        ],
      ),
    );
  }

  Widget _buildMaintenanceAlerts() {
    if (maintenanceAlerts == null || maintenanceAlerts!.isEmpty) return SizedBox.shrink();
    return Card(
      elevation: 8,
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('تنبيهات الصيانة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
            SizedBox(height: 10),
            ...maintenanceAlerts!.map((alert) => _buildAlertCard(alert)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    Color urgencyColor = alert['urgency'] == 'low' ? Colors.orange : Colors.red;
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5),
      elevation: 2,
      child: ListTile(
        leading: Icon(Icons.warning, color: urgencyColor),
        title: Text('${alert['make']} ${alert['model']} - ${alert['maintenanceType']}', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('تاريخ الاستحقاق: ${alert['dueDate']} | المسافة الحالية: ${alert['currentMileage']}'),
        trailing: Text(alert['urgency'].toUpperCase(), style: TextStyle(color: urgencyColor, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildInstitutionInfo() {
    return Card(
      elevation: 8,
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('معلومات المؤسسة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _buildInfoRow('العنوان', institutionData?['address_en'] ?? 'غير متوفر'),
            _buildInfoRow('رقم الطوارئ', institutionData?['emergency_number'] ?? 'غير متوفر'),
            _buildInfoRow('عدد السيارات', '${institutionData?['institution_cars']?.length ?? '0'}'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, style: TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildUsersSection() {
    return Card(
      elevation: 8,
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المستخدم', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: institutionData?['users']?.length ?? 0,
              itemBuilder: (context, index) {
                var user = institutionData?['users'][index];
                return ListTile(
                  leading: CircleAvatar(child: Icon(Icons.person)),
                  title: Text(user['name'] ?? 'غير متوفر'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Card(
      elevation: 8,
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('التقييمات', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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