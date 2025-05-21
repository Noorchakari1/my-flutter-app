import 'package:flutter/material.dart';
import '../../../../core/config/routes.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/modern_bottom_nav_bar.dart';
import '../widgets/app_header.dart';
import '../widgets/custom_button.dart';
import '../widgets/service_button.dart';
import 'web_view_screen.dart';
import 'service_button_screen.dart';
import 'feedback_screen.dart';

class EnglishScreen extends StatefulWidget {
  const EnglishScreen({super.key});

  @override
  State<EnglishScreen> createState() => _EnglishScreenState();
}

class _EnglishScreenState extends State<EnglishScreen> {
  int _page = 0;

  Widget _buildHomeContent() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
         AppHeader(
          title: AppConstants.englishText['headerTitle']!,
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
            child: GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: AppConstants.defaultPadding * 1.5,
              crossAxisSpacing: AppConstants.defaultPadding * 1.5,
              childAspectRatio: 1,
              children: [
                // CustomButton(
                //   title: 'AOP Website',
                //   iconData: Icons.web,
                //   onPressed: () {
                //     Navigator.of(context).push(MaterialPageRoute(
                //       builder: (context) => WebViewScreen(
                //         url: AppConstants.aopUrls['english']!,
                //         language: 'english',
                //       ),
                //     ));
                //   },
                // ),
                                CustomButton(
                  title: 'News',
                  iconData: Icons.newspaper,
                  onPressed: () {
                    Navigator.of(context).pushNamed(Routes.news);
                  },
                ),
                CustomButton(
                  title: 'Ministries',
                  iconData: Icons.account_balance,
                  onPressed: () {
                    Navigator.of(context).pushNamed(Routes.ministries);
                  },
                ),
                // CustomButton(
                //   title: 'Gov Agencies',
                //   iconData: Icons.departure_board,
                //   onPressed: () {
                //     Navigator.of(context).push(MaterialPageRoute(
                //       builder: (context) => WebViewScreen(
                //         url: AppConstants.aopMinistryUrls['english']!,
                //         language: 'english',
                //       ),
                //     ));
                //   },
                // ),
                CustomButton(
                  title: 'Independent Directorates',
                  iconData: Icons.business,
                  onPressed: () {
                    Navigator.of(context).pushNamed(Routes.independentDirectorates);
                  },
                ),
                CustomButton(
                  title: 'Provinces',
                  iconData: Icons.location_city,
                  onPressed: () {
                    Navigator.of(context).pushNamed(Routes.provinces);
                  },
                ),
                CustomButton(
                  title: 'Public Services',
                  iconData: Icons.public,
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ServiceButtonScreen(
                        passportTitle: 'Passport Services',
                        passportURL: AppConstants.passportUrls['english']!,
                        language: 'english',
                      ),
                    ));
                  },
                ),

              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWebContent() {
    return WebViewScreen(
      url: AppConstants.aopUrls['english']!,
      language: 'english',
      initialPage: _page,
      showBottomNav: false,
      showAppBar: false,
    );
  }

  Widget _buildFeedbackContent() {
    return FeedbackScreen(
      appbarTitle: 'Contact Us',
      guidedText: 'Please share your comments/complaints with us',
      whatsAppTitle: 'WhatsApp',
      emailTitle: 'Email',
      txtDir: TextDirection.ltr,
      formTitle: 'Contact Form',
      url: AppConstants.aopFormUrls['english']!,
      language: 'english',
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
              title: AppConstants.englishText['welcome']!,
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
        items: const [
          BottomNavigationItem(
            icon: Icons.home,
            label: 'Home',
          ),
          BottomNavigationItem(
            icon: Icons.web,
            label: 'Website',
          ),
          BottomNavigationItem(
            icon: Icons.feedback,
            label: 'Contact',
          ),
        ],
      ),
    );
  }
}
