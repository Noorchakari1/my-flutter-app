import 'package:flutter/material.dart';

/// Application-wide constants
///
/// This class contains all the constant values used throughout the application.
/// It is organized into different sections for better maintainability.
class AppConstants {
  const AppConstants._();

  /// API URLs
  static const String baseUrl = 'https://aop.gov.af';
  
  /// Language-specific URLs
  static const Map<String, String> urls = {
    'persian': '$baseUrl/dr',
    'pashto': '$baseUrl/ps',
    'english': '$baseUrl/en',
  };

  /// Ministry URLs for different languages
  static const Map<String, String> ministryUrls = {
    'persian': '$baseUrl/dr/government/ministries',
    'pashto': '$baseUrl/ps/government/ministries',
    'english': '$baseUrl/en/government/ministries',
  };

  /// Form URLs for different languages
  static const Map<String, String> formUrls = {
    'persian': '$baseUrl/dr/forms',
    'pashto': '$baseUrl/ps/forms',
    'english': '$baseUrl/en/forms',
  };

  /// Passport service URLs
  static const Map<String, String> passportUrls = {
    'persian': 'https://passport.moi.gov.af/da/',
    'pashto': 'https://passport.moi.gov.af/ps/',
    'english': 'https://passport.moi.gov.af/en/',
  };

  /// Theme Colors
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color backgroundColor = Color(0xFFF5F6FA);
  static const Color shadowColor = Colors.black;

  /// Layout Dimensions
  static const double headerImageHeight = 80.0;
  static const double defaultPadding = 16.0;
  static const double headerPadding = 20.0;
  static const double navBarHeight = 60.0;

  /// Text Styles
  static const TextStyle appBarTitleStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 22,
    color: Colors.white,
  );

  static const TextStyle headerTitleStyle = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  /// Decorations
  static final BoxDecoration headerDecoration = BoxDecoration(
    color: primaryColor,
    borderRadius: const BorderRadius.only(
      bottomLeft: Radius.circular(30),
      bottomRight: Radius.circular(30),
    ),
    boxShadow: [
      BoxShadow(
        color: shadowColor.withOpacity(0.1),
        blurRadius: 10,
        spreadRadius: 0,
        offset: const Offset(0, 2),
      ),
    ],
  );

  /// Localization Text Maps
  static const Map<String, Map<String, String>> localizedText = {
    'persian': _persianText,
    'pashto': _pashtoText,
    'english': _englishText,
  };

  /// Persian Text Constants
  static const Map<String, String> _persianText = {
    'welcome': 'خوش آمدید',
    'headerTitle': 'به اداره امور خوش آمدید',
    'changeLanguage': 'تغییر زبان',
    'comments': 'نظریات/پیشنهادات',
    'contactUs': 'ارتباط با ما',
    'feedbackGuide': 'لطفا روی یکی از گزینه های پایین کلیک نموده، نظریات و پیشنهادات را با ما شریک سازید',
    'whatsapp': 'واتسپ',
    'email': 'ایمیل',
    'contactForm': 'فورم تماس',
    'aopWebsite': 'وب سایت اداره امور',
    'agencyList': 'لیست ادارات دولتی افغانستان',
    'publicServices': 'خدمات عمومی دولتی',
    'passportServices': 'خدمات پاسپورت',
  };

  /// Pashto Text Constants
  static const Map<String, String> _pashtoText = {
    'welcome': 'ښه راغلاست',
    'headerTitle': 'د چارو ادارې ته ښه راغلاست',
    'changeLanguage': 'د ژبې بدلول',
    'comments': 'نظرونه/وړاندیزونه',
    'contactUs': 'له موږ سره اړیکه',
    'feedbackGuide': 'مهرباني وکړئ د لاندې اختیارونو څخه یو غوره کړئ او خپل نظرونه او وړاندیزونه له موږ سره شریک کړئ',
    'whatsapp': 'واټساپ',
    'email': 'بریښنالیک',
    'contactForm': 'د اړیکې فورمه',
    'aopWebsite': 'د چارو ادارې ویب پاڼه',
    'agencyList': 'د افغانستان د دولتي ادارو لیست',
    'publicServices': 'عامه دولتي خدمتونه',
    'passportServices': 'د پاسپورټ خدمتونه',
  };

  /// English Text Constants
  static const Map<String, String> _englishText = {
    'welcome': 'Welcome',
    'headerTitle': 'Welcome to Administrative Office of the President',
    'changeLanguage': 'Change Language',
    'comments': 'Comments/Suggestions',
    'contactUs': 'Contact Us',
    'feedbackGuide': 'Please click on one of the options below to share your comments and suggestions with us',
    'whatsapp': 'WhatsApp',
    'email': 'Email',
    'contactForm': 'Contact Form',
    'aopWebsite': 'AOP Website',
    'agencyList': 'List of Afghan Government Agencies',
    'publicServices': 'Public Government Services',
    'passportServices': 'Passport Services',
  };
} 