import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/theme_provider.dart';
import '../../core/services/language_service.dart';
import '../constants/app_constants.dart';

/// Shared top bar with accessible theme, saved-items, and language controls.
class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool showDrawer;
  final bool showThemeToggle;
  final bool showLanguageButton;
  final List<Widget>? actions;

  const CustomAppBar({super.key, required this.title, this.showBackButton = false, this.showDrawer = false, this.showThemeToggle = true, this.showLanguageButton = true, this.actions});

  String _text(String key, String language) {
    final text = switch (language) {'pashto' => AppConstants.pashtoText, 'persian' => AppConstants.persianText, _ => AppConstants.englishText};
    return text[key] ?? key;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(themeNotifierProvider);
    return AppBar(
      elevation: 0,
      backgroundColor: state.isGolden ? const Color(0xFF15120E) : AppConstants.primaryColor,
      leading: showBackButton ? BackButton(color: state.isGolden ? const Color(0xFFB08D57) : Colors.white) : showDrawer ? null : const SizedBox(),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: state.isGolden ? const Color(0xFFB08D57) : Colors.white)),
      centerTitle: true,
      actions: [
        if (actions != null) ...actions!,
        IconButton(icon: Icon(Icons.bookmark_outline, color: state.isGolden ? const Color(0xFFB08D57) : Colors.white), tooltip: _text('savedNews', state.currentLanguage), onPressed: () => Navigator.pushNamed(context, '/saved_news')),
        if (showLanguageButton)
          PopupMenuButton<String>(
            icon: Icon(Icons.language_outlined, color: state.isGolden ? const Color(0xFFB08D57) : Colors.white),
            tooltip: _text('changeLanguage', state.currentLanguage),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (language) => _selectLanguage(context, ref, language),
            itemBuilder: (_) => [
              _languageItem('pashto', AppConstants.pashtoFlagPath, 'پښتو', state.currentLanguage == 'pashto'),
              _languageItem('persian', AppConstants.persianFlagPath, 'دری', state.currentLanguage == 'persian'),
              _languageItem('english', AppConstants.englishFlagPath, 'English', state.currentLanguage == 'english'),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(value: 'more_languages', child: Row(children: [Icon(Icons.translate_outlined), SizedBox(width: 12), Text('More languages')])),
            ],
          ),
        if (showThemeToggle)
          PopupMenuButton<String>(
            icon: Icon(
              Icons.palette_outlined,
              color: state.isGolden ? const Color(0xFFB08D57) : Colors.white,
            ),
            tooltip: 'Choose theme',
            offset: const Offset(0, 44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            onSelected: (variant) => ref
                .read(themeNotifierProvider.notifier)
                .setThemeVariant(variant),
            itemBuilder: (_) => [
              _themeItem(
                'light',
                'Light',
                Icons.light_mode_outlined,
                state.themeVariant,
              ),
              _themeItem(
                'dark',
                'Dark',
                Icons.dark_mode_outlined,
                state.themeVariant,
              ),
              _themeItem(
                'golden',
                'Golden',
                Icons.workspace_premium_outlined,
                state.themeVariant,
              ),
            ],
          ),
        const SizedBox(width: 6),
      ],
    );
  }

  static PopupMenuItem<String> _languageItem(String value, String asset, String label, bool selected) => PopupMenuItem(
    value: value,
    child: Row(children: [
      ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.asset(asset, width: 26, height: 20, fit: BoxFit.cover)),
      const SizedBox(width: 12), Expanded(child: Text(label)), if (selected) const Icon(Icons.check_rounded, size: 18),
    ]),
  );

  static PopupMenuItem<String> _themeItem(
    String value,
    String label,
    IconData icon,
    String selected,
  ) => PopupMenuItem(
    value: value,
    height: 44,
    child: SizedBox(
      width: 142,
      child: Row(children: [
        Icon(icon, size: 20, color: value == 'golden' ? const Color(0xFFB08D57) : null),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
        if (selected == value) const Icon(Icons.check_rounded, size: 18),
      ]),
    ),
  );

  Future<void> _selectLanguage(BuildContext context, WidgetRef ref, String language) async {
    if (language == 'more_languages') {
      showModalBottomSheet<void>(context: context, showDragHandle: true, builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Additional languages', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          const Text('Pashto, Dari, and English are currently translated and supported by the official content services. More languages will appear here when verified translations are available.'),
        ]),
      ));
      return;
    }
    final route = switch (language) {'pashto' => AppConstants.pashtoRoute, 'persian' => AppConstants.persianRoute, _ => AppConstants.englishRoute};
    await LanguageService.setSelectedLanguage(language);
    await ref.read(themeNotifierProvider.notifier).setLanguage(language);
    if (context.mounted) Navigator.pushReplacementNamed(context, route);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * .9);
}
