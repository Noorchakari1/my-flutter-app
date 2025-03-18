import 'package:flutter/material.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../widgets/app_header.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_bottom_nav_bar.dart';
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
              crossAxisCount: 2,
              mainAxisSpacing: AppConstants.defaultPadding * 1.5,
              crossAxisSpacing: AppConstants.defaultPadding * 1.5,
              childAspectRatio: 1,
              children: [
                CustomButton(
                  title: 'AOP Website',
                  iconData: Icons.web,
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => WebViewScreen(
                        url: AppConstants.aopUrls['english']!,
                        language: 'english',
                      ),
                    ));
                  },
                ),
                CustomButton(
                  title: 'Government Agencies',
                  iconData: Icons.departure_board,
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => WebViewScreen(
                        url: AppConstants.aopMinistryUrls['english']!,
                        language: 'english',
                      ),
                    ));
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
    );
  }

  Widget _buildFeedbackContent() {
    return FeedbackScreen(
      appbarTitle: 'Contact Us',
      guidedText: 'How would you like to contact us?',
      whatsAppTitle: 'WhatsApp',
      emailTitle: 'Email',
      txtDir: TextDirection.ltr,
      formTitle: 'Contact Form',
      url: AppConstants.aopFormUrls['english']!,
      language: 'english',
      showBottomNav: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _page == 0
          ?  CustomAppBar(
              title: AppConstants.englishText['welcome']!,
            )
          : null,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _page,
        onTap: (index) {
          setState(() {
            _page = index;
          });
        },
        webUrl: AppConstants.aopUrls['english']!,
        textDirection: TextDirection.ltr,
        feedbackTitle: 'Contact Us',
        feedbackText: 'How would you like to contact us?',
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
