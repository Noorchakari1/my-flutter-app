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

class PashtoScreen extends StatefulWidget {
  const PashtoScreen({super.key});

  @override
  State<PashtoScreen> createState() => _PashtoScreenState();
}

class _PashtoScreenState extends State<PashtoScreen> {
  int _page = 0;

  Widget _buildHomeContent() {
    return Column(
      children: [
        AppHeader(
          title: AppConstants.pashtoText['headerTitle']!,
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
                CustomButton(
                  title: AppConstants.pashtoText['aopWebsite']!,
                  iconData: Icons.web,
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => WebViewScreen(
                        url: AppConstants.aopUrls['pashto']!,
                        language: 'pashto',
                      ),
                    ));
                  },
                ),
                CustomButton(
                  title: 'د دولتي ادارو لیست',
                  iconData: Icons.departure_board,
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => WebViewScreen(
                        url: AppConstants.aopMinistryUrls['pashto']!,
                        language: 'pashto',
                      ),
                    ));
                  },
                ),
                CustomButton(
                  title: 'د عامه خدمتونه',
                  iconData: Icons.web,
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ServiceButtonScreen(
                        passportTitle:
                            AppConstants.pashtoText['passportServices']!,
                        passportURL: AppConstants.passportUrls['pashto']!,
                        language: 'pashto',
                      ),
                    ));
                  },
                ),
                CustomButton(
                  title: 'خبرونه',
                  iconData: Icons.newspaper,
                  onPressed: () {
                    Navigator.of(context).pushNamed(Routes.news);
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
      url: AppConstants.aopUrls['pashto']!,
      language: 'pashto',
      initialPage: _page,
      showBottomNav: false,
    );
  }

  Widget _buildFeedbackContent() {
    return FeedbackScreen(
      appbarTitle: AppConstants.pashtoText['contactUs']!,
      guidedText: AppConstants.pashtoText['feedbackGuide']!,
      whatsAppTitle: AppConstants.pashtoText['whatsapp']!,
      emailTitle: AppConstants.pashtoText['email']!,
      txtDir: TextDirection.rtl,
      formTitle: AppConstants.pashtoText['contactForm']!,
      url: AppConstants.aopFormUrls['pashto']!,
      language: 'pashto',
      showBottomNav: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _page == 0
          ? CustomAppBar(
              title: AppConstants.pashtoText['welcome']!,
            )
          : null,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _page,
        onTap: (index) {
          setState(() {
            _page = index;
          });
        },
        webUrl: AppConstants.aopUrls['pashto']!,
        textDirection: TextDirection.rtl,
        feedbackTitle: AppConstants.pashtoText['contactUs']!,
        feedbackText: AppConstants.pashtoText['feedbackGuide']!,
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