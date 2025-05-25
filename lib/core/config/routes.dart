import 'package:aop_sites/features/news/presentation/screens/news_screen.dart';
import 'package:aop_sites/features/news/presentation/screens/saved_news_screen.dart';
import 'package:flutter/material.dart';

import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/independent_directorates/presentation/screens/independent_directorates_screen.dart';
import '../../features/job_opportunities/presentation/screens/job_opportunities_screen.dart';
import '../../features/language/presentation/screens/feedback_screen.dart';
import '../../features/language/presentation/screens/language_screen.dart';
import '../../features/language/presentation/screens/service_button_screen.dart';
import '../../features/language/presentation/screens/web_view_screen.dart';
import '../../features/ministries/presentation/screens/ministries_screen_new.dart';
import '../../features/provinces/presentation/screens/provinces_screen.dart';
import '../../shared/constants/app_constants.dart';

/// Application routes configuration
class Routes {
  const Routes._();

  // Route names
  static const String home = '/';
  static const String language = '/language';
  static const String english = '/english';
  static const String persian = '/persian';
  static const String pashto = '/pashto';
  static const String feedback = '/feedback';
  static const String webView = '/web-view';
  static const String service = '/service';
  static const String news = '/news';
  static const String savedNews = '/saved_news';
  static const String ministries = '/ministries';
  static const String independentDirectorates = '/independent-directorates';
  static const String provinces = '/provinces';
  static const String jobOpportunities = '/job-opportunities';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppConstants.homeRoute:
      case AppConstants.languageRoute:
        return MaterialPageRoute(
          builder: (_) => const LanguageScreen(),
        );
      case AppConstants.pashtoRoute:
      case AppConstants.persianRoute:
      case AppConstants.englishRoute:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );
      case news:
        return MaterialPageRoute(
          builder: (_) => const NewsScreen(),
        );
      case savedNews:
        return MaterialPageRoute(
          builder: (_) => const SavedNewsScreen(),
        );
      case ministries:
        return MaterialPageRoute(
          builder: (_) => const MinistriesScreenNew(),
        );
      case independentDirectorates:
        return MaterialPageRoute(
          builder: (_) => const IndependentDirectoratesScreen(),
        );
      case provinces:
        return MaterialPageRoute(
          builder: (_) => const ProvincesScreen(),
        );
      case jobOpportunities:
        return MaterialPageRoute(
          builder: (_) => const JobOpportunitiesScreen(),
        );
      case AppConstants.webViewRoute:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => WebViewScreen(
            url: args['url'] as String,
            language: args['language'] as String,
            showBottomNav: args['showBottomNav'] as bool? ?? true,
          ),
        );
      case AppConstants.serviceRoute:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ServiceButtonScreen(
            language: args['language'] as String,
            passportTitle: args['passportTitle'] as String,
            passportURL: args['passportURL'] as String,
          ),
        );
      case AppConstants.feedbackRoute:
        final args = settings.arguments as Map<String, dynamic>?;
        final language = args?['language'] as String? ?? 'persian';
        final languageText = language == 'persian'
            ? AppConstants.persianText
            : language == 'pashto'
                ? AppConstants.pashtoText
                : AppConstants.englishText;
        return MaterialPageRoute(
          builder: (_) => FeedbackScreen(
            appbarTitle: languageText['contactUs']!,
            guidedText: languageText['feedbackGuide']!,
            whatsAppTitle: languageText['whatsapp']!,
            emailTitle: languageText['email']!,
            txtDir: language == 'english' ? TextDirection.ltr : TextDirection.rtl,
            formTitle: languageText['contactForm']!,
            url: AppConstants.aopFormUrls[language]!,
            language: language,
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const NotFoundPage(),
        );
    }
  }
}

/// 404 Page for undefined routes
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
      ),
      body: const Center(
        child: Text(
          '404 - Page Not Found',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}