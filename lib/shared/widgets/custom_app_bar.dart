import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/theme_provider.dart';
import '../../features/language/presentation/screens/language_screen.dart';
import '../constants/app_constants.dart';

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
          IconButton(
            icon: const Icon(
              Icons.language,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LanguageScreen(showBackButton: true)),
              );
            },
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