import 'package:aop_sites/Screens/feedback_screen.dart';
import 'package:aop_sites/Screens/srv_btn_screen.dart';
import 'package:aop_sites/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'web_view.dart';

class EnglishScreen extends StatelessWidget {
  const EnglishScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ٌWelcome',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xff42A5F5),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.blue.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MyCustomButton(
              title: 'AOP WebSite',
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const WebviewScreen(
                          url: "https://aop.gov.af/en",
                        )));
              },
            ),
            MyCustomButton(
              title: 'List of government agencies',
              onPressed: () {
                // Add navigation or functionality here
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const WebviewScreen(
                        url: 'https://aop.gov.af/en/government/ministries')));
              },
            ),
            MyCustomButton(
                title: 'Public government services',
                onPressed: () {
                  // Add navigation or functionality here
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const SrvBTNScreen(
                            passportTitle: 'Passport services',
                            passportURL: 'https://passport.moi.gov.af/pa/',
                          )));
                }),
            MyCustomButton(
                title: 'Comments/Suggestions',
                onPressed: () {
                  // Add navigation or functionality here
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const FeedbackScreen(
                            pageTitle: 'Contact us',
                            text:
                                'Please click on one of the options below and share your feedback and suggestions with us',
                            whatsAppTitle: 'WhatsApp',
                            emailTitle: "email",
                            txtdir: TextDirection.ltr,
                            formTitle: 'Contact form',
                            url: 'https://aop.gov.af/en/forms',
                          )));
                }),
          ],
        ),
      ),
    );
  }
}
