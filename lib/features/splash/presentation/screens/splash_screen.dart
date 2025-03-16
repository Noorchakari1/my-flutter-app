import 'package:flutter/material.dart';

import '../../../../core/services/language_service.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../language/presentation/screens/language_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLanguage();
  }

  Future<void> _checkLanguage() async {
    await Future.delayed(const Duration(seconds: 2)); // Show splash for 2 seconds
    if (!mounted) return;

    final selectedLanguage = await LanguageService.getSelectedLanguage();
    if (!mounted) return;

    if (selectedLanguage == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LanguageScreen()),
      );
    } else {
      String route;
      switch (selectedLanguage) {
        case 'pashto':
          route = AppConstants.pashtoRoute;
          break;
        case 'persian':
          route = AppConstants.persianRoute;
          break;
        case 'english':
          route = AppConstants.englishRoute;
          break;
        default:
          route = AppConstants.languageRoute;
      }
      Navigator.pushReplacementNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryColor,
      body: Center(
        child: Hero(
          tag: 'logo',
          child: Image.asset(
            AppConstants.logoPath,
            height: AppConstants.headerImageHeight * 1.5,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
} 