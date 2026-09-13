import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/app_drawer.dart';
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
      appBar: CustomAppBar(title: widget.appbarTitle, showDrawer: true),
      drawer: const AppDrawer(),
      bottomNavigationBar: widget.showBottomNav ? ModernBottomNavBar(
        currentIndex: 2, // Always show the feedback tab as selected
        onTap: (index) {
          if (index != 2) {
            Navigator.pop(context);
          }
        },
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
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
                crossAxisCount: 3,
                mainAxisSpacing: AppConstants.defaultPadding * 1.5,
                crossAxisSpacing: AppConstants.defaultPadding * 1.5,
                // A square cell is shorter than CustomButton's icon, label,
                // and vertical padding. Give each of the three contact cards
                // enough height to prevent the bottom RenderFlex overflow.
                childAspectRatio: 0.78,
                children: [
                  CustomButton(
                    title: widget.whatsAppTitle,
                    iconData: Icons.chat,
                    onPressed: () async {
                      // Create WhatsApp URL with phone number
                      final Uri whatsappUrl =
                          Uri.parse("whatsapp://send?phone=+93744724357");

                      // Alternative URL for web or if app URL fails
                      final Uri whatsappWebUrl =
                          Uri.parse("https://wa.me/93744724357");

                      // Show loading indicator
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                widget.language == 'english'
                                    ? 'Opening WhatsApp...'
                                    : widget.language == 'persian'
                                        ? 'در حال باز کردن واتساپ...'
                                        : 'واټساپ پرانیستل...',
                              ),
                            ],
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );

                      try {
                        // Try to launch WhatsApp app first
                        final bool launched = await launchUrl(
                          whatsappUrl,
                          mode: LaunchMode.externalApplication,
                        );

                        // If app launch fails, try web version
                        if (!launched && context.mounted) {
                          await launchUrl(
                            whatsappWebUrl,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      } catch (e) {
                        // If both attempts fail, show error message
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                widget.language == 'english'
                                    ? 'Could not open WhatsApp. Please make sure WhatsApp is installed.'
                                    : widget.language == 'persian'
                                        ? 'نمی‌توان واتساپ را باز کرد. لطفاً مطمئن شوید که واتساپ نصب شده است.'
                                        : 'واټساپ نه شي پرانیستل کیدای. مهرباني وکړئ ډاډ ترلاسه کړئ چې واټساپ نصب شوی دی.',
                              ),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  CustomButton(
                    title: widget.emailTitle,
                    iconData: Icons.email,
                    onPressed: () async {
                      // Create email URL with subject and body
                      final Uri emailUrl = Uri.parse(
                        "mailto:info@aop.gov.af?subject=${Uri.encodeComponent(
                          widget.language == 'english'
                              ? 'Feedback from AOP App'
                              : widget.language == 'persian'
                                  ? 'بازخورد از برنامه ریاست عمومی اداره امور'
                                  : 'د چارو ادارې له اپلیکیشن څخه نظر',
                        )}"
                      );

                      // Show loading indicator
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                widget.language == 'english'
                                    ? 'Opening Email app...'
                                    : widget.language == 'persian'
                                        ? 'در حال باز کردن برنامه ایمیل...'
                                        : 'د بریښنالیک اپلیکیشن پرانیستل...',
                              ),
                            ],
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );

                      try {
                        // Force launch without checking canLaunchUrl
                        await launchUrl(
                          emailUrl,
                          mode: LaunchMode.externalApplication,
                        );
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                widget.language == 'english'
                                    ? 'Could not open email app. Please make sure you have an email app installed.'
                                    : widget.language == 'persian'
                                        ? 'نمی‌توان برنامه ایمیل را باز کرد. لطفاً مطمئن شوید که یک برنامه ایمیل نصب کرده‌اید.'
                                        : 'د بریښنالیک اپلیکیشن نه شي پرانیستل کیدای. مهرباني وکړئ ډاډ ترلاسه کړئ چې تاسو د بریښنالیک اپلیکیشن نصب کړی دی.',
                              ),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
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
