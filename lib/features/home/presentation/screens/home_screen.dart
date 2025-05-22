import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/routes.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/modern_bottom_nav_bar.dart';
import '../../../language/presentation/screens/feedback_screen.dart';
import '../../../language/presentation/screens/service_button_screen.dart';
import '../../../language/presentation/screens/web_view_screen.dart';
import '../../../language/presentation/widgets/app_header.dart';
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

    return Column(
      children: [
        AppHeader(
          title: _getText('headerTitle'),
          logoPath: AppConstants.logoPath,
          logoHeight: AppConstants.headerImageHeight,
          logoColor: Colors.white,
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
              vertical: AppConstants.defaultPadding * 2,
            ),
            child: Column(
              children: [
                // First section: News and Job Opportunities (2 items per row)
                Container(
                  margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding * 1.5),
                  height: 120, // Fixed height for the first row
                  child: GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: AppConstants.defaultPadding * 1.5,
                    crossAxisSpacing: AppConstants.defaultPadding * 1.5,
                    childAspectRatio: 1.5,
                    children: [
                      CustomButton(
                        title: _getText('newsNav'),
                        iconData: Icons.newspaper,
                        onPressed: () {
                          Navigator.of(context).pushNamed(Routes.news);
                        },
                      ),
                      CustomButton(
                        title: _getText('jobOpportunities'),
                        iconData: Icons.work,
                        onPressed: () {
                          // Functionality will be implemented later
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(_getText('comingSoon')),
                              duration: const Duration(seconds: 2),
                            ),
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
                    mainAxisSpacing: AppConstants.defaultPadding * 1.5,
                    crossAxisSpacing: AppConstants.defaultPadding * 1.5,
                    childAspectRatio: 1.0,
                    children: [
                      CustomButton(
                        title: _getText('ministries'),
                        iconData: Icons.account_balance,
                        onPressed: () {
                          Navigator.of(context).pushNamed(Routes.ministries);
                        },
                      ),
                      CustomButton(
                        title: _getText('independentDirectorates'),
                        iconData: Icons.business,
                        onPressed: () {
                          Navigator.of(context).pushNamed(Routes.independentDirectorates);
                        },
                      ),
                      CustomButton(
                        title: _getText('provinces'),
                        iconData: Icons.location_city,
                        onPressed: () {
                          Navigator.of(context).pushNamed(Routes.provinces);
                        },
                      ),
                      CustomButton(
                        title: _getText('publicServices'),
                        iconData: Icons.public,
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ServiceButtonScreen(
                              passportTitle: _getText('passportServices'),
                              passportURL: AppConstants.passportUrls[language]!,
                              language: language,
                            ),
                          ));
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
              title: _getText('welcome'),
            )
          : null,
      body: IndexedStack(
        index: _page,
        children: [
          _buildHomeContent(),
          _buildWebContent(),
          _buildFeedbackContent(),
        ],
      ),
      bottomNavigationBar: ModernBottomNavBar(
        currentIndex: _page,
        onTap: _onNavItemTapped,
        backgroundColor: AppConstants.primaryColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withAlpha(179),
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
        ],
      ),
    );
  }
}
