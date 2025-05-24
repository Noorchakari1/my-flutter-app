import 'package:aop_sites/core/utils/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/theme_provider.dart';
import '../../core/services/language_service.dart';
import '../constants/app_constants.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool showDrawer;
  final bool showThemeToggle;
  final bool showLanguageButton;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.showDrawer = false,
    this.showThemeToggle = true,
    this.showLanguageButton = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeNotifierProvider);
    final isDarkMode = themeState.isDarkMode;

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
          fontSize: 18,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      actions: [
        // Add custom actions first if provided
        if (actions != null) ...actions!,

        // Default bookmark action
        IconButton(
          icon: const Icon(
            Icons.bookmark_added,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/saved_news');
          },
        ),

        // Language button
        if (showLanguageButton)
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.language,
              color: Colors.white,
            ),
            tooltip: 'Change Language',
            onSelected: (String language) {
              // Store the route before async operations
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

              // Navigate first, then update language settings
              Navigator.pushReplacementNamed(context, route);

              // Update language settings after navigation
              LanguageService.setSelectedLanguage(language);
              ref.read(themeNotifierProvider.notifier).setLanguage(language);

              // Navigate with loading
              NavigationHelper.replaceWithLoading(
                context,
                destination: const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                ),
                loadingMessage: 'Changing language...',
              ).then((_) {
                // Navigate to the actual route after loading
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, route);
                }
              });
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

        // Theme toggle button
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
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * 0.8);
}