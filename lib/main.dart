import 'package:car/screens/Auth/Singin.dart';
import 'package:car/screens/Auth/forgetpassword.dart';
import 'package:car/screens/Auth/otpverify.dart';
import 'package:car/screens/auth/Signup_screen.dart';
import 'package:car/screens/institutions/DashboardInstitution.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'dashboard_client.dart';
import 'on_bording_screen.dart';
import 'splash_screen.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: 'GO Cars',
          routes: {
            "/": (context) {
              return SplashScreen();
            },
            "/OnBordingScreen": (context) {
              // Replace with your actual onboarding screen widget
              return OnBordingScreen();
            },
            "/DashboardClient": (context) {
              // Replace with your actual onboarding screen widget
              return CarSearchPage();
            },
            "/singin": (context) {
              // Replace with your actual singin screen widget
              return SignInScreen();
            },
            "/verifyotp": (context) {
              // Replace with your actual OtpScreen screen widget
              return OtpScreen (email: '',);
            },
            "/forgetpassword": (context) {
              // Replace with your actual Forgot Password screen widget
              return ForgotPasswordScreen ();
            },
            "/SignUpScreen": (context) {
              // Replace with your actual Forgot Password screen widget
              return RegisterInstitutionScreen ();
            },
            "/dashboardinstitution": (context) {
              // Replace with your actual Dashboard Institution screen widget
              return DashboardInstitution ();
            },
          },
        );
      },
    );
  }
}

// Placeholder for the OnBordingScreen widget
