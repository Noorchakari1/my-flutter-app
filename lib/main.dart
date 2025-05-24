import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/routes.dart';
import 'core/providers/theme_provider.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/language_service.dart';
import 'core/services/theme_service.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'shared/constants/app_constants.dart';
import 'shared/widgets/network_error_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await LanguageService.init();
  await ThemeService.init();

  // Run app with error handling
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize connectivity service (will start listening for connectivity changes)
    ref.watch(connectivityServiceProvider);

    final themeState = ref.watch(themeNotifierProvider);
    final isRTL = themeState.currentLanguage == 'persian' ||
                  themeState.currentLanguage == 'pashto';

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ref.read(themeNotifierProvider.notifier).theme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('fa'),
        Locale('ps'),
      ],
      locale: isRTL ? const Locale('fa') : const Locale('en'),
      home: const SplashScreen(),
      onGenerateRoute: Routes.generateRoute,
      builder: (context, child) {
        return NetworkErrorOverlay(
          child: Directionality(
            textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
            child: child!,
          ),
        );
      },
    );
  }
}
