import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/services/language_service.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../widgets/language_button.dart';

class LanguageScreen extends ConsumerStatefulWidget {
  final bool showBackButton;

  const LanguageScreen({
    super.key,
    this.showBackButton = false,
  });

  @override
  ConsumerState<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends ConsumerState<LanguageScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animations = List.generate(
      3,
      (index) => CurvedAnimation(
        parent: _controller,
        curve: Interval(
          index * 0.2,
          0.6 + index * 0.2,
          curve: Curves.easeOut,
        ),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleLanguageSelection(String route, String language) async {
    await LanguageService.setSelectedLanguage(language);
    if (!mounted) return;

    // Update theme notifier with new language
    await ref.read(themeNotifierProvider.notifier).setLanguage(language);

    if (!mounted) return;

    if (widget.showBackButton) {
      Navigator.pop(context);
    }
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeNotifierProvider).isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar:  CustomAppBar(
        title: AppConstants.pashtoText['headerTitle']!,
        showBackButton: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              // padding: const EdgeInsets.all(AppConstants.headerPadding),
                    padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode
                      ? Colors.black.withAlpha(77)
                      : AppConstants.shadowColor.withAlpha(51),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Hero(
                    tag: 'logo',
                    child: Image.asset(
                      AppConstants.logoPath,
                      height: AppConstants.headerImageHeight,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppConstants.defaultPadding * 1.5),
                   Text(
                    AppConstants.pashtoText['langGuide']!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                   Text(
                    AppConstants.persianText['langGuide']!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                   Text(
                    AppConstants.englishText['langGuide']!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultPadding,
                  vertical: AppConstants.defaultPadding * 2,
                ),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppConstants.defaultPadding * 1.5,
                  crossAxisSpacing: AppConstants.defaultPadding * 1.5,
                  childAspectRatio: 1,
                  children: [
                    ScaleTransition(
                      scale: _animations[0],
                      child: LanguageButton(
                        language: 'پشتو',
                        flagAsset: AppConstants.pashtoFlagPath,
                        onPressed: () => _handleLanguageSelection(AppConstants.pashtoRoute, 'pashto'),
                      ),
                    ),
                    ScaleTransition(
                      scale: _animations[1],
                      child: LanguageButton(
                        language: 'دری',
                        flagAsset: AppConstants.persianFlagPath,
                        onPressed: () => _handleLanguageSelection(AppConstants.persianRoute, 'persian'),
                      ),
                    ),
                    ScaleTransition(
                      scale: _animations[2],
                      child: LanguageButton(
                        language: 'English',
                        flagAsset: AppConstants.englishFlagPath,
                        onPressed: () => _handleLanguageSelection(AppConstants.englishRoute, 'english'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}