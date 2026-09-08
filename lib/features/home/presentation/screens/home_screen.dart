import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/routes.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/utils/navigation_helper.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/draggable_ai_assistant.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/modern_bottom_nav_bar.dart';
import '../widgets/home_updates_carousel.dart';
import '../../../language/presentation/screens/feedback_screen.dart';
import '../../../language/presentation/screens/service_button_screen.dart';
import '../../../language/presentation/screens/web_view_screen.dart';
import '../../../language/presentation/widgets/custom_button.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _page = 0;

  // Helper function to get localized text
  String _getText(String key) {
    final language = ref.watch(themeNotifierProvider).currentLanguage;
    Map<String, String> textMap;
    switch (language) {
      case 'pashto':
        textMap = AppConstants.pashtoText;
        break;
      case 'persian':
        textMap = AppConstants.persianText;
        break;
      default:
        textMap = AppConstants.englishText;
    }
    return textMap[key] ?? key; // Return key if translation not found
  }

  Widget _buildHomeContent() {
    final language = ref.watch(themeNotifierProvider).currentLanguage;
    const gridGap = 12.0;

    return Column(
      children: [
        HomeUpdatesCarousel(language: language),
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              children: [
                // First section: News and Job Opportunities (2 items per row)
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  // The previous height was shorter than the grid tiles,
                  // clipping the lower edge of the News and Jobs cards.
                  height: 128,
                  child: GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: gridGap,
                    crossAxisSpacing: gridGap,
                    childAspectRatio: 1.55,
                    children: [
                      CustomButton(
                        title: _getText('newsNav'),
                        iconData: Icons.newspaper,
                        onPressed: () {
                          NavigationHelper.navigateToRouteWithLoading(
                            context,
                            routeName: Routes.news,
                            loadingMessage: _getText('loading'),
                          );
                        },
                      ),
                      CustomButton(
                        title: _getText('jobOpportunities'),
                        iconData: Icons.work,
                        onPressed: () {
                          NavigationHelper.navigateToRouteWithLoading(
                            context,
                            routeName: Routes.jobOpportunities,
                            loadingMessage: _getText('loading'),
                          );

                        },
                      ),
                    ],
                  ),
                ),

                // Second section: Remaining menu items (3 items per row)
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 3,
                    mainAxisSpacing: gridGap,
                    crossAxisSpacing: gridGap,
                    childAspectRatio: .96,
                    children: [
                      CustomButton(
                        title: _getText('ministries'),
                        iconData: Icons.account_balance,
                        onPressed: () {
                          NavigationHelper.navigateToRouteWithLoading(
                            context,
                            routeName: Routes.ministries,
                            loadingMessage: _getText('loading'),
                          );
                        },
                      ),
                      CustomButton(
                        title: _getText('independentDirectorates'),
                        iconData: Icons.business,
                        onPressed: () {
                          NavigationHelper.navigateToRouteWithLoading(
                            context,
                            routeName: Routes.independentDirectorates,
                            loadingMessage: _getText('loading'),
                          );
                        },
                      ),
                      CustomButton(
                        title: _getText('provinces'),
                        iconData: Icons.location_city,
                        onPressed: () {
                          NavigationHelper.navigateToRouteWithLoading(
                            context,
                            routeName: Routes.provinces,
                            loadingMessage: _getText('loading'),
                          );
                        },
                      ),
                      CustomButton(
                        title: _getText('publicServices'),
                        iconData: Icons.public,
                        onPressed: () {
                          NavigationHelper.navigateWithLoading(
                            context,
                            destination: ServiceButtonScreen(
                              passportTitle: _getText('passportServices'),
                              passportURL: AppConstants.passportUrls[language]!,
                              language: language,
                            ),
                            loadingMessage: _getText('loading'),
                          );
                        },
                      ),
                      CustomButton(
                        title: _getText('qiblaCompass'),
                        iconData: Icons.explore,
                        onPressed: () {
                          NavigationHelper.navigateToRouteWithLoading(
                            context,
                            routeName: Routes.qibla,
                            loadingMessage: _getText('loading'),
                          );
                        },
                      ),
                      CustomButton(
                        title: _getText('weather'),
                        iconData: Icons.cloud,
                        onPressed: () {
                          NavigationHelper.navigateToRouteWithLoading(
                            context,
                            routeName: Routes.weather,
                            loadingMessage: _getText('loading'),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWebContent() {
    final language = ref.watch(themeNotifierProvider).currentLanguage;
    return WebViewScreen(
      url: AppConstants.aopUrls[language]!,
      language: language,
      initialPage: _page,
      showBottomNav: false,
      showAppBar: false,
    );
  }

  Widget _buildFeedbackContent() {
    final language = ref.watch(themeNotifierProvider).currentLanguage;
    final isRTL = language == 'persian' || language == 'pashto';

    return FeedbackScreen(
      appbarTitle: _getText('contactUs'),
      guidedText: _getText('feedbackGuide'),
      whatsAppTitle: _getText('whatsapp'),
      emailTitle: _getText('email'),
      txtDir: isRTL ? TextDirection.rtl : TextDirection.ltr,
      formTitle: _getText('contactForm'),
      url: AppConstants.aopFormUrls[language]!,
      language: language,
      showBottomNav: false,
    );
  }

  Widget _buildSettingsContent() {
    final theme = Theme.of(context);
    final themeState = ref.watch(themeNotifierProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 96),
        children: [
          Text(
            _getText('settings'),
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Personalize how the app looks and feels.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.palette_outlined, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Text('Appearance', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Choose your preferred color theme.', style: theme.textTheme.bodySmall),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _themeChoice('light', 'Light', Icons.light_mode_outlined, themeState.themeVariant),
                      _themeChoice('dark', 'Dark', Icons.dark_mode_outlined, themeState.themeVariant),
                      _themeChoice('golden', 'Golden', Icons.workspace_premium_outlined, themeState.themeVariant),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _themeChoice(String variant, String label, IconData icon, String selectedVariant) {
    return ChoiceChip(
      label: Text(label),
      avatar: Icon(icon, size: 18),
      selected: selectedVariant == variant,
      onSelected: (_) => ref.read(themeNotifierProvider.notifier).setThemeVariant(variant),
    );
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _page = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _page == 0
          ? CustomAppBar(
              title: '',
              showDrawer: true,
            )
          : null,
      drawer: const AppDrawer(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          IndexedStack(
            index: _page,
            children: [
              _buildHomeContent(),
              _buildWebContent(),
              _buildFeedbackContent(),
              _buildSettingsContent(),
            ],
          ),
          const DraggableAiAssistant(),
        ],
      ),
      bottomNavigationBar: ModernBottomNavBar(
        currentIndex: _page,
        onTap: _onNavItemTapped,
        backgroundColor: ref.watch(themeNotifierProvider).isGolden ? const Color(0xFF15120E) : Theme.of(context).colorScheme.primary,
        selectedItemColor: ref.watch(themeNotifierProvider).isGolden ? const Color(0xFFB08D57) : Colors.white,
        unselectedItemColor: ref.watch(themeNotifierProvider).isGolden ? const Color(0xFFF7F1E3).withAlpha(170) : Colors.white.withAlpha(179),
        elevation: 8.0,
        iconSize: 24.0,
        height: 60.0,
        items: [
          BottomNavigationItem(
            icon: Icons.home,
            label: _getText('home'),
          ),
          BottomNavigationItem(
            icon: Icons.web,
            label: _getText('websiteNav'),
          ),
          BottomNavigationItem(
            icon: Icons.feedback,
            label: _getText('contactNav'),
          ),
          BottomNavigationItem(
            icon: Icons.settings_outlined,
            label: _getText('settings'),
          ),
        ],
      ),
    );
  }
}
