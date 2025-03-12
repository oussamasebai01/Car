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

  void initSocket() {
    socket = IO.io('http://10.0.2.2:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    // Écouter les notifications générales
    socket.on('notification', (data) {
      print('Notification received: $data');
      showNotification('Notification', data); // Afficher la notification
    });

    // Écouter l'événement "welcome" et afficher une notification
    socket.on('welcome', (data) {
      print('Welcome message received: $data');
      showNotification('Bienvenue', data); // Afficher la notification
    });

    // Écouter la connexion
    socket.onConnect((_) {
      print('Connected to Socket.IO server');
    });

    // Écouter la déconnexion
    socket.onDisconnect((_) {
      print('Disconnected from Socket.IO server');
    });
  }

  void showNotification(String title, String message) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000), // ID unique
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
