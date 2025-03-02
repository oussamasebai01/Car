import 'dart:async';

import 'package:flutter/material.dart';
import 'package:car/utils/constant.dart';
import 'package:sizer/sizer.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Timer(Duration(seconds: 3), () {
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacementNamed(context, '/OnBordingScreen');
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 8.7.h,
              child: Image.asset(splashImage),
            ),
            heightSpace10,
            Text(
              'Rental Car',
              style: splashTextsp,
            )
          ],
        ),
      ),
    );
  }
}
