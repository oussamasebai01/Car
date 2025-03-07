import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:car/utils/constant.dart';
import 'package:sizer/sizer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBordingScreen extends StatefulWidget {
  const OnBordingScreen({Key? key}) : super(key: key);

  @override
  State<OnBordingScreen> createState() => _OnBordingScreenState();
}

class _OnBordingScreenState extends State<OnBordingScreen> {
  int pageIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: bodyMethod(context),
    );
  }

  SafeArea bodyMethod(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: 93.5.h,
        width: 80.h,
        child: Column(
          children: [
            SizedBox(
              height: 78.6.h,
              child: PageView(
                controller: _pageController,
                onPageChanged: (value) {
                  setState(() => pageIndex = value);
                },
                children: [
                  intro1(),
                  intro2(),
                  intro3(),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: pageIndex != 2
                  ? () {
                _pageController.animateToPage(pageIndex + 1,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.fastLinearToSlowEaseIn);
              }
                  : () {
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pushReplacementNamed(
                    context, '/DashboardClient');
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: primaryColor,
              ),
              child: Text(
                pageIndex == 2 ? "ابدأ الآن" : "التالي",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (pageIndex != 2) {
                  _pageController.animateToPage(2,
                      duration: Duration(milliseconds: 1500),
                      curve: Curves.fastLinearToSlowEaseIn);
                }
              },
              child: Text(
                pageIndex != 2 ? "تخطي" : '',
                style: dustyGrayMedium12sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget intro1() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: 80.w,
          height: 45.h,
          child: Image.asset("assets/images/intro_screen/intro_screen1.png"),
        ),
        Column(
          children: [
            AutoSizeText(
              "مرحبًا بك في تطبيق GO Sayara",
              style: blackSemiBold17sp,
              maxLines: 1,
            ),
            heightSpace5,
            SizedBox(
              width: 90.w,
              child: AutoSizeText(
                "يمكنك استئجار العديد من السيارات بسهولة من خلال تطبيق GO Sayara.",
                style: dustyGrayMedium12sp,
                textAlign: TextAlign.center,
                maxLines: 5,
              ),
            ),
            heightSpace10,
            SmoothPageIndicator(
              controller: _pageController,
              count: 3,
              effect: ScrollingDotsEffect(
                dotColor: nobel,
                activeDotColor: primaryColor,
                dotHeight: .75.h,
                dotWidth: .75.h,
                activeDotScale: .25.h,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget intro2() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: 80.w,
          height: 45.h,
          child: Image.asset(introImage2),
        ),
        Column(
          children: [
            AutoSizeText(
              "تمتع بخيارات متعددة",
              style: blackSemiBold17sp,
              maxLines: 1,
            ),
            heightSpace5,
            SizedBox(
              width: 90.w,
              child: AutoSizeText(
                "نضمن لك العثور على السيارة التي تناسب احتياجاتك بكل سهولة.",
                style: dustyGrayMedium12sp,
                textAlign: TextAlign.center,
                maxLines: 5,
              ),
            ),
            heightSpace10,
            SmoothPageIndicator(
              controller: _pageController,
              count: 3,
              effect: ScrollingDotsEffect(
                dotColor: nobel,
                activeDotColor: primaryColor,
                dotHeight: .75.h,
                dotWidth: .75.h,
                activeDotScale: .25.h,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget intro3() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: 80.w,
          height: 45.h,
          child: Image.asset(introImage3),
        ),
        Column(
          children: [
            AutoSizeText(
              "احجز بكل ثقة",
              style: blackSemiBold17sp,
              maxLines: 1,
            ),
            heightSpace5,
            SizedBox(
              width: 90.w,
              child: AutoSizeText(
                "استمتع بخدمة موثوقة وآمنة لاستئجار السيارات.",
                style: dustyGrayMedium12sp,
                textAlign: TextAlign.center,
                maxLines: 5,
              ),
            ),
            heightSpace10,
            SmoothPageIndicator(
              controller: _pageController,
              count: 3,
              effect: ScrollingDotsEffect(
                dotColor: nobel,
                activeDotColor: primaryColor,
                dotHeight: .75.h,
                dotWidth: .75.h,
                activeDotScale: .25.h,
              ),
            ),
          ],
        ),
      ],
    );
  }
}