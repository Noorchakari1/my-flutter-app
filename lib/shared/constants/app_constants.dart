import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'AOP';

  // Colors
  static const Color primaryColor = Color(0xff1B047C);
  static const Color backgroundColor = Colors.white;
  static const Color shadowColor = Colors.black;

  // Dimensions
  static const double defaultPadding = 16.0;
  static const double headerPadding = 20.0;
  static const double headerImageHeight = 100.0;

  // API URLs
  static const String baseUrl = 'https://qiblafinder.withgoogle.com/intl';

  // Asset paths
  static const String logoPath = 'assets/logo.png';
  static const String profilePath = 'assets/profile.png';
  static const String aopPath = 'assets/aop.png';

  // Language flags
  static const String persianFlagPath = 'assets/flags/persian.png';
  static const String englishFlagPath = 'assets/flags/english.png';
  static const String pashtoFlagPath = 'assets/flags/pashto.png';

  // Route names
  static const String homeRoute = '/';
  static const String languageRoute = '/language';
  static const String webViewRoute = '/webview';
  static const String pashtoRoute = '/pashto';
  static const String persianRoute = '/persian';
  static const String englishRoute = '/english';
  static const String settingsRoute = '/settings';
  static const String serviceRoute = '/service';
  static const String feedbackRoute = '/feedback';

  // Styles
  static const TextStyle headerTitleStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle appBarTitleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static final BoxDecoration headerDecoration = BoxDecoration(
    color: primaryColor,
    boxShadow: [
      BoxShadow(
        color: shadowColor.withOpacity(0.2),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // URLs
  static const Map<String, String> aopUrls = {
    'persian': 'https://aop.gov.af/dr',
    'pashto': 'https://aop.gov.af/pa',
    'english': 'https://aop.gov.af/en',
  };

  static const Map<String, String> aopVideosUrls = {
    'persian': 'https://aop.gov.af/dr/videos',
    'pashto': 'https://aop.gov.af/dr/pictures',
    'english': 'https://aop.gov.af/en/videos',
  };

  static const Map<String, String> aopMinistryUrls = {
    'persian': 'https://aop.gov.af/dr/government/ministries',
    'pashto': 'https://aop.gov.af/pa/government/ministries',
    'english': 'https://aop.gov.af/en/government/ministries',
  };

  static const Map<String, String> passportUrls = {
    'persian': 'https://passport.moi.gov.af/da',
    'pashto': 'https://passport.moi.gov.af/pa',
    'english': 'https://passport.moi.gov.af/pa',
  };

  static const Map<String, String> aopFormUrls = {
    'persian': 'https://aop.gov.af/dr/forms',
    'pashto': 'https://aop.gov.af/pa/forms',
    'english': 'https://aop.gov.af/en/forms',
  };

  // Persian Text
  static const Map<String, String> persianText = {
    'videos': 'ویدیوها',
    'welcome': 'خوش آمدید',
    'headerTitle': 'ریاست عمومی اداره امور',
    'aopWebsite': 'وبسایت اداره امور',
    'agencyList': 'لیست وزارت خانه ها',
    'publicServices': 'خدمات عامه',
    'passportServices': 'خدمات پاسپورت',
    'changeLanguage': 'تغییر زبان',
    'comments': 'نظریات',
    'contactUs': 'تماس با ما',
    'feedbackGuide': 'لطفاً نظریات خود را با ما شریک سازید',
    'whatsapp': 'واتساپ',
    'email': 'ایمیل',
    'contactForm': 'فورم تماس',
  };

  // Pashto Text
  static const Map<String, String> pashtoText = {
    'videos': 'ویډیوګانې',
    'welcome': 'ښه راغلاست',
    'headerTitle': 'د چارو ادارې  لوی ریاست',
    'aopWebsite': 'د چارو ادارې ویب پاڼه',
    'agencyList': 'د وزارتونو لیست',
    'publicServices': 'عامه خدمتونه',
    'passportServices': 'د پاسپورت خدمتونه',
    'changeLanguage': 'د ژبې بدلول',
    'comments': 'نظرونه',
    'contactUs': 'له موږ سره اړیکه',
    'feedbackGuide': 'مهرباني وکړئ خپل نظرونه له موږ سره شریک کړئ',
    'whatsapp': 'واټساپ',
    'email': 'بریښنالیک',
    'contactForm': 'د اړیکې فورم',
  };

  // English Screen Text
  // static const Map<String, String> englishText = {
  //   'welcome': 'Welcome',
  //   'headerTitle': 'Welcome to Administrative Office of the President',
  //   'changeLanguage': 'Change Language',
  //   'comments': 'Comments/Suggestions',
  //   'contactUs': 'Contact Us',
  //   'feedbackGuide': 'Please click on one of the options below to share your comments and suggestions with us',
  //   'whatsapp': 'WhatsApp',
  //   'email': 'Email',
  //   'contactForm': 'Contact Form',
  //   'aopWebsite': 'AOP Website',
  //   'agencyList': 'List of Afghan Government Agencies',
  //   'publicServices': 'Public Government Services',
  //   'passportServices': 'Passport Services',
  // };

  static const Map<String, String> englishText = {
    'videos': 'Videos',
    'welcome': 'Welcome',
    'headerTitle': 'General Directorate of Administration.',
    'aopWebsite': 'Office of the Prime Minister',
    'agencyList': 'Ministry List',
    'publicServices': 'Public Services',
    'passportServices': 'Passport Services',
    'changeLanguage': 'Change Language',
    'comments': 'Comments',
    'contactUs': 'Contact Us',
    'feedbackGuide': 'Please share your feedback with us',
    'whatsapp': 'WhatsApp',
    'email': 'Email',
    'contactForm': 'Contact Form',
  };
}
