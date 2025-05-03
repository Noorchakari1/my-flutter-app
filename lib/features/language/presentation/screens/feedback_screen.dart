import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/modern_bottom_nav_bar.dart';
import '../widgets/app_header.dart';
import '../widgets/custom_button.dart';
import 'web_view_screen.dart';

class FeedbackScreen extends StatefulWidget {
  final String appbarTitle;
  final String guidedText;
  final String whatsAppTitle;
  final String emailTitle;
  final TextDirection txtDir;
  final String formTitle;
  final String url;
  final String language;
  final bool showBottomNav;

  const FeedbackScreen({
    super.key,
    required this.appbarTitle,
    required this.guidedText,
    required this.whatsAppTitle,
    required this.emailTitle,
    required this.txtDir,
    required this.formTitle,
    required this.url,
    required this.language,
    this.showBottomNav = true,
  });

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(title: widget.appbarTitle, showBackButton: false),
      bottomNavigationBar: widget.showBottomNav ? ModernBottomNavBar(
        currentIndex: 2, // Always show the feedback tab as selected
        onTap: (index) {
          if (index != 2) {
            Navigator.pop(context);
          }
        },
        backgroundColor: AppConstants.primaryColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withAlpha(179),
        elevation: 8.0,
        iconSize: 24.0,
        height: 60.0,
        items: [
          BottomNavigationItem(
            icon: Icons.home,
            label: widget.language == 'english'
                ? 'Home'
                : widget.language == 'persian'
                    ? 'خانه'
                    : 'کور',
          ),
          BottomNavigationItem(
            icon: Icons.web,
            label: widget.language == 'english'
                ? 'Website'
                : widget.language == 'persian'
                    ? 'وبسایت'
                    : 'ویبسایټ',
          ),
          BottomNavigationItem(
            icon: Icons.feedback,
            label: widget.language == 'english'
                ? 'Contact'
                : widget.language == 'persian'
                    ? 'تماس'
                    : 'اړیکه',
          ),
        ],
      ) : null,
      body: Column(
        children: [
          AppHeader(
            title: widget.guidedText,
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
                    title: widget.whatsAppTitle,
                    iconData: Icons.chat,
                    onPressed: () async {
                      final Uri whatsappUrl =
                          Uri.parse("whatsapp://send?phone=+93744724357");
                      if (await canLaunchUrl(whatsappUrl)) {
                        await launchUrl(whatsappUrl);
                      }
                    },
                  ),
                  CustomButton(
                    title: widget.emailTitle,
                    iconData: Icons.email,
                    onPressed: () async {
                      final Uri emailUrl = Uri.parse("mailto:info@aop.gov.af");
                      if (await canLaunchUrl(emailUrl)) {
                        await launchUrl(emailUrl);
                      }
                    },
                  ),
                  CustomButton(
                    title: widget.formTitle,
                    iconData: Icons.forum,
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => WebViewScreen(
                          url: widget.url,
                          language: widget.language,
                          showBottomNav: false,
                        ),
                      ));
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
