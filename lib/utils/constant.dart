import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

//Colors
const primaryColor = Color(0xff0D782E);
const combination = Color(0xffffc901);
const shadowPrimary = Color(0xff095A22);
const ratingColor = Color(0xffD18C23);
const dividerColor = Color(0xffD9D9D9);
const Color black = Colors.black;
const Color grey = Colors.grey;
const Color white = Colors.white;
const Color amber = Colors.amber;
const Color transparent = Colors.transparent;
const Color nobel = Color(0xffB7B7B7);
const Color dustyGray = Color(0xff949494);
const Color pinputShadow = Color(0xff8D8D8D);
const Color antiFlashWhite = Color(0xffF0F0F0);
const Color red = Color(0xffFF0000);
// const Color colorForShadow = Color.fromRGBO(0, 0, 0, 0.25);
Color colorForShadow = Color(0xff000000).withOpacity(.25);

//Height & Width Spaces
const double fixPadding = 10.0;
const SizedBox heightSpace2 = SizedBox(height: 2);
const SizedBox widthSpace2 = SizedBox(width: 2);
const SizedBox widthSpace5 = SizedBox(width: 5);
const SizedBox heightSpace5 = SizedBox(height: 5);
const SizedBox widthSpace10 = SizedBox(width: fixPadding);
const SizedBox heightSpace10 = SizedBox(height: fixPadding);
const SizedBox widthSpace12 = SizedBox(width: fixPadding + 2);
const SizedBox heightSpace12 = SizedBox(height: fixPadding + 2);
const SizedBox widthSpace15 = SizedBox(width: 15);
const SizedBox heightSpace15 = SizedBox(height: 15);
const SizedBox widthSpace20 = SizedBox(width: 20);
const SizedBox heightSpace20 = SizedBox(height: 20);
const SizedBox heightSpace25 = SizedBox(height: 25);
const SizedBox widthSpace30 = SizedBox(width: 30);
const SizedBox heightSpace30 = SizedBox(height: 30);
const SizedBox heightSpace40 = SizedBox(height: 40);
const SizedBox heightSpace50 = SizedBox(height: 50);
const SizedBox heightSpace70 = SizedBox(height: 70);
const SizedBox heightSpace100 = SizedBox(height: 100);

//intro images
const splashImage = 'assets/images/splash_image.png';
const introImage1 = 'assets/images/intro_screen/intro_screen1.png';
const introImage2 = 'assets/images/intro_screen/intro_screen2.png';
const introImage3 = 'assets/images/intro_screen/intro_screen3.png';
//sign-in images
const googleIcon = 'assets/images/social_icons/google.png';
const facebookIcon = 'assets/images/social_icons/facebook.png';
const creditCard = 'assets/images/social_icons/credit_card.png';
const payPal = 'assets/images/social_icons/paypal.png';
const googlePay = 'assets/images/social_icons/google_pay.png';
const cashPaid = 'assets/images/social_icons/cod.png';
const sucessfull = 'assets/images/home_images/successfull.png';
const filterIcon = 'assets/images/home_images/filterIcon.png';
//textfield images
const textfieldPhone = 'assets/images/text_field_icons/textfield_phone.png';
const textfieldProfile = 'assets/images/text_field_icons/textfield_profile.png';
const textfieldEmail = 'assets/images/text_field_icons/textfield_email.png';
const calender = 'assets/images/text_field_icons/calendar.png';
const textfieldNote = 'assets/images/text_field_icons/textfield_note.png';
//bottom_navigation
const bottomHome = 'assets/images/bottom_navigation/bottom_navigation_home.svg';
const bottomSearch =
    'assets/images/bottom_navigation/bottom_navigation_search.svg';
const bottomFavourite =
    'assets/images/bottom_navigation/bottom_navigation_favourite.svg';
const bottomProfile =
    'assets/images/bottom_navigation/bottom_navigation_profile.svg';
//home_screen
const tagCar = 'assets/images/home_images/tag_car.png';
const tagBackground = 'assets/images/home_images/tagBackground.png';
const homeGrid1 = 'assets/images/home_images/home_grid1.png';
const homeGrid2 = 'assets/images/home_images/home_grid2.png';
const homeGrid3 = 'assets/images/home_images/home_grid3.png';
const homeGrid4 = 'assets/images/home_images/home_grid4.png';
const emptyNotification = 'assets/images/home_images/empty_notification.png';
//car_detail
const carDetailMain = 'assets/images/car_detail/car_detail_main.png';
const renterProfile = 'assets/images/car_detail/rentor_profile.png';
const renterMessage = 'assets/images/car_detail/rentor_message.png';
const renterCall = 'assets/images/car_detail/rentor_call.png';
const feature1 = 'assets/images/car_detail/feature_1.png';
const feature2 = 'assets/images/car_detail/feature_2.png';
const feature3 = 'assets/images/car_detail/feature_3.png';
const feature4 = 'assets/images/car_detail/feature_4.png';
const feature5 = 'assets/images/car_detail/feature_5.png';
const feature6 = 'assets/images/car_detail/feature_6.png';
const moreImageCar1 = 'assets/images/car_detail/more_image_car1.png';
const moreImageCar2 = 'assets/images/car_detail/more_image_car2.png';
const moreImageCar3 = 'assets/images/car_detail/more_image_car3.png';
const moreImageCar4 = 'assets/images/car_detail/more_image_car4.png';
//profile_screen
const profilePic = 'assets/images/profile/profile_pic.png';
const profile1 = 'assets/images/profile/profile_1.png';
const profile2 = 'assets/images/profile/profile_2.png';
const profile3 = 'assets/images/profile/profile_3.png';
const profile4 = 'assets/images/profile/profile_4.png';
const profile5 = 'assets/images/profile/profile_5.png';
const profile6 = 'assets/images/profile/profile_6.png';
const profile7 = 'assets/images/profile/profile_7.png';
const profile8 = 'assets/images/profile/profile_8.png';
//edit_profile
const blueCamera = 'assets/images/profile/blue_camera.png';
const greenGalary = 'assets/images/profile/green_galary.png';
const redBin = 'assets/images/profile/red_bin.png';
//my_booking
const myBooking = 'assets/images/profile/my_booking.png';
//setting
const setting1 = 'assets/images/profile/setting_1.png';
const setting2 = 'assets/images/profile/setting_2.png';
//customer_support
const customerSupport = 'assets/images/profile/customer_support.png';
const support1 = 'assets/images/profile/support_1.png';
const support2 = 'assets/images/profile/support_2.png';

//TextStyles
TextStyle dustyGrayMedium16sp = TextStyle(
  fontSize: 16.sp,
  color: dustyGray,
  fontWeight: FontWeight.w500,
  fontFamily: 'Poppins',
);
TextStyle dustyGrayMedium14sp = TextStyle(
  fontSize: 14.sp,
  color: dustyGray,
  fontWeight: FontWeight.w500,
  fontFamily: 'Poppins',
);
TextStyle dustyGrayMedium13sp = TextStyle(
  fontSize: 13.sp,
  color: dustyGray,
  fontWeight: FontWeight.w500,
  fontFamily: 'Poppins',
);
TextStyle dustyGraySemiBold13sp = TextStyle(
  fontSize: 13.sp,
  color: dustyGray,
  fontWeight: FontWeight.w600,
  fontFamily: 'Poppins',
);
TextStyle dustyGraySemiBold11sp = TextStyle(
  fontSize: 11.sp,
  color: dustyGray,
  fontWeight: FontWeight.w600,
  fontFamily: 'Poppins',
);

TextStyle greenMedium12sp = TextStyle(
  fontSize: 12.sp,
  color: primaryColor,
  fontWeight: FontWeight.w500,
  fontFamily: 'Poppins',
);
TextStyle greenMedium11sp = TextStyle(
  fontSize: 11.sp,
  color: primaryColor,
  fontWeight: FontWeight.w500,
  fontFamily: 'Poppins',
);
TextStyle greenMedium10sp = TextStyle(
  fontSize: 10.sp,
  color: primaryColor,
  fontWeight: FontWeight.w500,
  fontFamily: 'Poppins',
);
TextStyle greenSemiBold11sp = TextStyle(
  fontSize: 11.sp,
  color: primaryColor,
  fontWeight: FontWeight.w600,
  fontFamily: 'Poppins',
);
TextStyle greenSemiBold10sp = TextStyle(
  fontSize: 10.sp,
  color: primaryColor,
  fontWeight: FontWeight.w600,
  fontFamily: 'Poppins',
);
TextStyle greenSemiBold13sp = TextStyle(
  fontSize: 13.sp,
  color: primaryColor,
  fontWeight: FontWeight.w600,
  fontFamily: 'Poppins',
);
TextStyle greenSemiBold16sp = TextStyle(
  fontSize: 16.sp,
  color: primaryColor,
  fontWeight: FontWeight.w600,
  fontFamily: 'Poppins',
);
TextStyle greenSemiBold12sp = TextStyle(
  fontSize: 12.sp,
  color: primaryColor,
  fontWeight: FontWeight.w600,
  fontFamily: 'Poppins',
);
TextStyle greenMedium13sp = TextStyle(
  fontSize: 13.sp,
  color: primaryColor,
  fontWeight: FontWeight.w500,
  fontFamily: 'Poppins',
);
TextStyle nobel11sp = TextStyle(
  fontSize: 11.sp,
  color: nobel,
  fontWeight: FontWeight.w500,
  fontFamily: 'Poppins',
);

TextStyle splashTextsp = TextStyle(
  fontSize: 35.sp,
  color: white,
  fontWeight: FontWeight.w600,
  fontFamily: 'Rubik',
  fontStyle: FontStyle.normal,
);

TextStyle whiteBold13sp = TextStyle(
  fontSize: 13.sp,
  color: white,
  fontWeight: FontWeight.bold,
  fontFamily: 'Poppins',
);
TextStyle whiteSemiBold13sp = TextStyle(
  fontSize: 12.5.sp,
  color: white,
  fontWeight: FontWeight.w600,
  fontFamily: 'Poppins',
);
TextStyle whiteExtraBold13sp = TextStyle(
  fontSize: 12.5.sp,
  color: white,
  fontWeight: FontWeight.w800,
  fontFamily: 'Poppins',
);
TextStyle whiteSemiBold12sp = TextStyle(
  fontSize: 12.sp,
  color: white,
  fontWeight: FontWeight.w600,
  fontFamily: 'Poppins',
);
TextStyle whiteSemiBold11sp = TextStyle(
  fontSize: 11.sp,
  color: white,
  fontWeight: FontWeight.w600,
  fontFamily: 'Poppins',
);
TextStyle whiteBoldItalic14sp = TextStyle(
  fontSize: 14.sp,
  color: white,
  fontWeight: FontWeight.bold,
  fontStyle: FontStyle.italic,
  fontFamily: 'Poppins',
);

TextStyle primaryNormalTextsp = TextStyle(
  fontSize: 12.sp,
  color: black,
  fontWeight: FontWeight.w500,
  fontFamily: 'Poppins',
);
TextStyle primarySemiBoldTextsp = TextStyle(
  fontSize: 13.sp,
  color: black,
  fontWeight: FontWeight.w600,
  fontFamily: 'Poppins',
);

TextStyle appBarTitleStyle = TextStyle(
  fontSize: 13.sp,
  color: black,
  fontWeight: FontWeight.w600,
  fontFamily: 'Poppins',
);
TextStyle blackSemiBold17sp = TextStyle(
  fontSize: 17.sp,
  color: black,
  fontWeight: FontWeight.w600,
  fontFamily: 'Poppins',
);
TextStyle blackSemiBold15sp = TextStyle(
  fontSize: 15.sp,
  color: black,
  fontWeight: FontWeight.w600,
  fontFamily: 'Poppins',
);
TextStyle blackSemiBold13sp = TextStyle(
  fontSize: 12.7.sp,
  color: black,
  fontWeight: FontWeight.w600,
  fontFamily: 'Poppins',
);
TextStyle blackSemiBold12sp = TextStyle(
  fontSize: 12.sp,
  color: black,
  fontWeight: FontWeight.w600,
  fontFamily: 'Poppins',
);
TextStyle blackSemiBold11sp = TextStyle(
  fontSize: 11.5.sp,
  color: black,
  fontWeight: FontWeight.w600,
  fontFamily: 'Poppins',
);
TextStyle blackMedium14sp = TextStyle(
  fontSize: 14.sp,
  color: black,
  fontWeight: FontWeight.w500,
  fontFamily: 'Poppins',
);
TextStyle blackMedium12sp = TextStyle(
  fontSize: 12.sp,
  color: black,
  fontWeight: FontWeight.w500,
  fontFamily: 'Poppins',
);
TextStyle redMedium12sp = TextStyle(
  fontSize: 12.sp,
  color: red,
  fontWeight: FontWeight.w500,
  fontFamily: 'Poppins',
);
TextStyle blackMedium10sph = TextStyle(
  fontSize: 10.5.sp,
  color: black,
  fontWeight: FontWeight.w500,
  fontFamily: 'Poppins',
);
TextStyle blackMedium10sp = TextStyle(
  fontSize: 10.sp,
  color: black,
  fontWeight: FontWeight.w500,
  fontFamily: 'Poppins',
);
TextStyle blackMedium9sp = TextStyle(
  fontSize: 9.sp,
  color: black,
  fontWeight: FontWeight.w500,
  fontFamily: 'Poppins',
);
TextStyle blackMedium11sp = TextStyle(
  fontSize: 11.sp,
  color: black,
  fontWeight: FontWeight.w500,
  fontFamily: 'Poppins',
);
TextStyle blackMedium13sp = TextStyle(
  fontSize: 13.sp,
  color: black,
  fontWeight: FontWeight.w500,
  fontFamily: 'Poppins',
);
TextStyle blackBold12sp = TextStyle(
  fontSize: 12.sp,
  color: black,
  fontWeight: FontWeight.w700,
  fontFamily: 'Poppins',
);
TextStyle dustyGrayMedium12sp = TextStyle(
  fontSize: 12.sp,
  color: dustyGray,
  fontWeight: FontWeight.w500,
  fontFamily: 'Poppins',
);
TextStyle dustyGrayMedium9sp = TextStyle(
  fontSize: 9.sp,
  color: dustyGray,
  fontWeight: FontWeight.w500,
  fontFamily: 'Poppins',
);
TextStyle dustyGrayMedium11sp = TextStyle(
  fontSize: 11.sp,
  color: dustyGray,
  fontWeight: FontWeight.w500,
  fontFamily: 'Poppins',
);
TextStyle dustyGrayMedium10sph = TextStyle(
  fontSize: 10.5.sp,
  color: dustyGray,
  fontWeight: FontWeight.w500,
  fontFamily: 'Poppins',
);
TextStyle dustyGrayMedium10sp = TextStyle(
  fontSize: 10.sp,
  color: dustyGray,
  fontWeight: FontWeight.w500,
  fontFamily: 'Poppins',
);
TextStyle whiteMedium11sp = TextStyle(
  fontSize: 11.sp,
  color: white,
  fontWeight: FontWeight.w500,
  fontFamily: 'Poppins',
);
TextStyle whiteMedium9sp = TextStyle(
  fontSize: 9.sp,
  color: white,
  fontWeight: FontWeight.w500,
  fontFamily: 'Poppins',
);
TextStyle whiteBold14sp = TextStyle(
  fontSize: 14.sp,
  color: white,
  fontWeight: FontWeight.w700,
  fontFamily: 'Poppins',
);

const TextStyle uniCode1 = TextStyle(fontSize: 25);
const TextStyle uniCode2 = TextStyle(fontSize: 20);
