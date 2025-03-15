import 'package:car/screens/Auth/Singin.dart';
import 'package:car/screens/Auth/forgetpassword.dart';
import 'package:car/screens/Auth/otpverify.dart';
import 'package:car/screens/auth/Signup_screen.dart';
import 'package:car/screens/institutions/BookingList.dart';
import 'package:car/screens/institutions/CanceledList.dart';
import 'package:car/screens/institutions/DashboardInstitution.dart';
import 'package:car/screens/institutions/FinishedList.dart';
import 'package:car/screens/institutions/Profile.dart';
import 'package:car/screens/institutions/bookingRequest.dart';
import 'package:car/screens/institutions/my_car/car_liste.dart';
import 'package:car/screens/institutions/rejectedList.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dashboard_client.dart';
import 'on_bording_screen.dart';
import 'splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Ajouter cette importation

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeNotifications(); // Initialiser les notifications
  runApp(const MyApp());
}

Future<void> initializeNotifications() async {
  await AwesomeNotifications().initialize(
    null, // Chemin de l'icône (laisser null pour utiliser l'icône par défaut)
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic Notifications',
        channelDescription: 'Channel for basic notifications',
        importance: NotificationImportance.High,
        defaultColor: Colors.blue,
        ledColor: Colors.white,
      ),
    ],
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _notificationService.initSocket(); // Initialiser le socket
    requestNotificationPermission(); // Demander la permission pour les notifications
    showSavedNotifications(); // Afficher les notifications enregistrées
  }
  Future<void> showSavedNotifications() async {
    List<String> savedNotifications = await _notificationService.getSavedNotifications();

    for (String message in savedNotifications) {
      _notificationService.showNotification('Notification hors ligne', message);
    }

    await _notificationService.clearNotifications(); // Supprimer les notifications après affichage
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: 'GO Cars',
          routes: {
            "/": (context) {
              return SplashScreen(); // Remplacer la NotificationScreen
            },
            "/OnBordingScreen": (context) {
              return OnBordingScreen();
            },
            "/DashboardClient": (context) {
              return CarSearchPage();
            },
            "/singin": (context) {
              return SignInScreen();
            },
            "/verifyotp": (context) {
              return OtpScreen(email: '');
            },
            "/forgetpassword": (context) {
              return ForgotPasswordScreen();
            },
            "/SignUpScreen": (context) {
              return RegisterInstitutionScreen();
            },
            "/dashboardinstitution": (context) {
              return DashboardInstitution();
            },
            "/car_liste": (context) {
              return MyBookingScreen();
            },
            "/booking-request": (context) {
              return BookingRequestScreen();
            },
            "/rejected_list": (context) {
              return RejectedScreen();
            },
            "/finished_bookings": (context) {
              return FinishedScreen();
            },
            "/cancelled_list": (context) {
              return CanceledListScreen();
            },
            "/booking_list": (context) {
              return BookingListScreen();
            },
            "/profile": (context) {
              return ProfileScreen();
            },
          },
        );
      },
    );
  }
}


class NotificationService {
  late IO.Socket socket;

  void initSocket() async {
    final prefs = await SharedPreferences.getInstance();
    final storedInstitutionId = prefs.getInt('id');

    socket = IO.io('http://10.0.2.2:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.on('notification', (data) async {
      if (data is Map<String, dynamic>) {
        final receivedInstitutionId = data['institution_id'];
        final String message = data['message'].toString();

        int? institutionId = receivedInstitutionId is int
            ? receivedInstitutionId
            : int.tryParse(receivedInstitutionId.toString());

        if (storedInstitutionId != null &&
            institutionId != null &&
            institutionId == storedInstitutionId) {
          // Enregistrer la notification dans SharedPreferences
          await saveNotification(message);
          showNotification('Nouvelle notification', message);
        }
      }
    });

    socket.onConnect((_) {
      print('Connected to Socket.IO server');
    });

    socket.onDisconnect((_) {
      print('Disconnected from Socket.IO server');
    });
  }

  Future<void> saveNotification(String message) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> notifications =
        prefs.getStringList('notifications') ?? []; // Récupérer les anciennes notifications
    notifications.add(message); // Ajouter la nouvelle notification
    await prefs.setStringList('notifications', notifications); // Sauvegarder la liste mise à jour
  }


  Future<List<String>> getSavedNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('notifications') ?? [];
  }

  Future<void> clearNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notifications'); // Supprimer toutes les notifications
  }

  void showNotification(String title, String message) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'basic_channel',
        title: title,
        body: message,
      ),
    );
  }
}

void requestNotificationPermission() async {
  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    await AwesomeNotifications().requestPermissionToSendNotifications();
  }
}

