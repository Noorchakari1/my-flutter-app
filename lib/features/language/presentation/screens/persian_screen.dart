import 'package:flutter/material.dart';

import '../../../../core/config/routes.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../widgets/app_header.dart';
import '../widgets/custom_bottom_nav_bar.dart';
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
                  title: 'لیست ادارات دولتی',
                  iconData: Icons.departure_board,
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => WebViewScreen(
                        url: AppConstants.aopMinistryUrls['persian']!,
                        language: 'persian',
                      ),
                    ));
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
                CustomButton(
                  title: 'وزارت‌خانه‌ها',
                  iconData: Icons.account_balance,
                  onPressed: () {
                    Navigator.of(context).pushNamed(Routes.ministries);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _page == 0
          ? CustomAppBar(
              title: AppConstants.persianText['welcome']!,
            )
          : null,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _page,
        onTap: (index) {
          if (index == 1) {
            Navigator.of(context).pushNamed(Routes.news);
          } else {
            setState(() {
              _page = index;
            });
          }
        },
        webUrl: AppConstants.aopUrls['persian']!,
        textDirection: TextDirection.rtl,
        feedbackTitle: AppConstants.persianText['contactUs']!,
        feedbackText: AppConstants.persianText['feedbackGuide']!,
      ),
      body: IndexedStack(
        index: _page,
        children: [
          _buildHomeContent(),
          _buildWebContent(),
          _buildFeedbackContent(),
        ],
      ),
    );
  }
}
