import 'package:aop_sites/Screens/feedback_screen.dart';
import 'package:aop_sites/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'web_view.dart';

class ArabicScreen extends StatelessWidget {
  const ArabicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'مرحباً',
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
              title: 'المكتب الإداري لرئيس الوزراء',
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const WebviewScreen(
                          url: "https://aop.gov.af/pa",
                        )));
              },
            ),
            MyCustomButton(
                title: 'آراء/اقتراحات',
                onPressed: () {
                  // Add navigation or functionality here
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const FeedbackScreen(
                            appbarTitle: 'اتصل بنا.',
                            guidedText:
                                'يرجى النقر على أحد الخيارات أدناه ومشاركة أفكارك واقتراحاتك معنا.',
                            whatsAppTitle: 'واتسپ',
                            emailTitle: 'ایمیل',
                            txtDir: TextDirection.rtl,
                            formTitle: 'نموذج الاتصال',
                            url: 'https://aop.gov.af/dr/forms',
                          )));
                }),
          ],
        ),
      ),
    );
  }
}
