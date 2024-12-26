import 'package:aop_sites/Screens/feedback_screen.dart';
import 'package:aop_sites/Screens/srv_btn_screen.dart';
import 'package:aop_sites/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'web_view.dart';

class PersianScreen extends StatelessWidget {
  const PersianScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'خوش آمدید',
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
              title: 'وب سایت اداره امور',
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const WebviewScreen(
                          url: "https://aop.gov.af/dr",
                        )));
              },
            ),
            MyCustomButton(
              title: 'لیست ادارات دولتی افغانستان',
              onPressed: () {
                // Add navigation or functionality here
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const WebviewScreen(
                        url: 'https://aop.gov.af/dr/government/ministries')));
              },
            ),
            MyCustomButton(
                title: 'خدمات عمومی دولتی',
                onPressed: () {
                  // Add navigation or functionality here
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const SrvBTNScreen(
                            passportTitle: 'خدمات پاسپورت',
                            passportURL: 'https://passport.moi.gov.af/da/',
                          )));
                }),
            MyCustomButton(
                title: 'نظریات/پیشنهادات',
                onPressed: () {
                  // Add navigation or functionality here
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const FeedbackScreen(
                            pageTitle: 'ارتباط با ما',
                            text:
                                'لطفا روی یکی از گزینه های پایین کلیک نموده، نظریات و پیشنهادات را با ما شریک سازید',
                            whatsAppTitle: 'واتسپ',
                            emailTitle: 'ایمیل',
                            txtdir: TextDirection.rtl,
                            formTitle: 'فورم تماس',
                            url: 'https://aop.gov.af/dr/forms',
                          )));
                })
          ],
        ),
      ),
    );
  }
}
