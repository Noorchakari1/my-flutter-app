import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/theme_provider.dart';
import '../../features/language/presentation/screens/language_screen.dart';
import '../constants/app_constants.dart';
import '../../core/services/language_service.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool showDrawer;
  final bool showThemeToggle;
  final bool showLanguageButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.showDrawer = false,
    this.showThemeToggle = true,
    this.showLanguageButton = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeNotifierProvider);
    final isDarkMode = themeState.isDarkMode;
    final currentLanguage = themeState.currentLanguage;

    return AppBar(
      elevation: 0,
      backgroundColor: AppConstants.primaryColor,
      leading: showBackButton 
        ? const BackButton(color: Colors.white)
        : showDrawer 
          ? null // Let Scaffold handle drawer icon
          : const SizedBox(),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      actions: [
        if (showLanguageButton)
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.language,
              color: Colors.white,
            ),
            tooltip: 'Change Language',
            onSelected: (String language) async {
              await LanguageService.setSelectedLanguage(language);
              await ref.read(themeNotifierProvider.notifier).setLanguage(language);
              
              // Navigate to the appropriate route based on language
              String route;
              switch (language) {
                case 'pashto':
                  route = AppConstants.pashtoRoute;
                  break;
                case 'persian':
                  route = AppConstants.persianRoute;
                  break;
                case 'english':
                default:
                  route = AppConstants.englishRoute;
                  break;
              }
              
              Navigator.pushReplacementNamed(context, route);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'pashto',
                child: Row(
                  children: [
                    Image.asset(
                      AppConstants.pashtoFlagPath,
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(width: 10),
                    const Text('پشتو'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'persian',
                child: Row(
                  children: [
                    Image.asset(
                      AppConstants.persianFlagPath,
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(width: 10),
                    const Text('دری'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'english',
                child: Row(
                  children: [
                    Image.asset(
                      AppConstants.englishFlagPath,
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(width: 10),
                    const Text('English'),
                  ],
                ),
              ),
            ],
          ),
        if (showThemeToggle)
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
            ),
            onPressed: () {
              ref.read(themeNotifierProvider.notifier).toggleTheme();
            },
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 