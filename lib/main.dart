import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/routes.dart';
import 'core/providers/theme_provider.dart';
import 'core/services/language_service.dart';
import 'core/services/theme_service.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'shared/constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LanguageService.init();
  await ThemeService.init();
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
        return Directionality(
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },
    );
  }
}
