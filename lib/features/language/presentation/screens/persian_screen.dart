import 'package:flutter/material.dart';

import '../../../../core/config/routes.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/modern_bottom_nav_bar.dart';
import '../widgets/app_header.dart';
import '../widgets/custom_button.dart';
import 'feedback_screen.dart';
import 'service_button_screen.dart';
import 'web_view_screen.dart';

class PersianScreen extends StatefulWidget {
  const PersianScreen({super.key});

  @override
  State<PersianScreen> createState() => _PersianScreenState();
}

class _PersianScreenState extends State<PersianScreen> {
  int _page = 0;

  Widget _buildHomeContent() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        AppHeader(
          title: AppConstants.persianText['headerTitle']!,
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
              crossAxisCount: 2,
              mainAxisSpacing: AppConstants.defaultPadding * 1.5,
              crossAxisSpacing: AppConstants.defaultPadding * 1.5,
              childAspectRatio: 1,
              children: [
                // CustomButton(
                //   title: AppConstants.persianText['aopWebsite']!,
                //   iconData: Icons.web,
                //   onPressed: () {
                //     Navigator.of(context).push(MaterialPageRoute(
                //       builder: (context) => WebViewScreen(
                //         url: AppConstants.aopUrls['persian']!,
                //         language: 'persian',
                //       ),
                //     ));
                //   },
                // ),
                CustomButton(
                  title: 'اخبار',
                  iconData: Icons.newspaper,
                  onPressed: () {
                    Navigator.of(context).pushNamed(Routes.news);
                  },
                ),
                CustomButton(
                  title: 'وزارت‌خانه‌ها',
                  iconData: Icons.account_balance,
                  onPressed: () {
                    Navigator.of(context).pushNamed(Routes.ministries);
                  },
                ),
                // CustomButton(
                //   title: 'لیست ادارات دولتی',
                //   iconData: Icons.departure_board,
                //   onPressed: () {
                //     Navigator.of(context).push(MaterialPageRoute(
                //       builder: (context) => WebViewScreen(
                //         url: AppConstants.aopMinistryUrls['persian']!,
                //         language: 'persian',
                //       ),
                //     ));
                //   },
                // ),
                CustomButton(
                  title: 'ادارات مستقل',
                  iconData: Icons.business,
                  onPressed: () {
                    Navigator.of(context).pushNamed(Routes.independentDirectorates);
                  },
                ),
                CustomButton(
                  title: 'ولایات',
                  iconData: Icons.location_city,
                  onPressed: () {
                    Navigator.of(context).pushNamed(Routes.provinces);
                  },
                ),
                CustomButton(
                  title: 'خدمات عامه',
                  iconData: Icons.web,
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ServiceButtonScreen(
                        passportTitle:
                            AppConstants.persianText['passportServices']!,
                        passportURL: AppConstants.passportUrls['persian']!,
                        language: 'persian',
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
      url: AppConstants.aopUrls['persian']!,
      language: 'persian',
      initialPage: _page,
      showBottomNav: false,
    );
  }

  Widget _buildFeedbackContent() {
    return FeedbackScreen(
      appbarTitle: AppConstants.persianText['contactUs']!,
      guidedText: AppConstants.persianText['feedbackGuide']!,
      whatsAppTitle: AppConstants.persianText['whatsapp']!,
      emailTitle: AppConstants.persianText['email']!,
      txtDir: TextDirection.rtl,
      formTitle: AppConstants.persianText['contactForm']!,
      url: AppConstants.aopFormUrls['persian']!,
      language: 'persian',
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
              title: AppConstants.persianText['welcome']!,
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
            label: 'خانه',
          ),
          BottomNavigationItem(
            icon: Icons.web,
            label: 'وبسایت',
          ),
          BottomNavigationItem(
            icon: Icons.feedback,
            label: 'تماس',
          ),
        ],
      ),
    );
  }
}
