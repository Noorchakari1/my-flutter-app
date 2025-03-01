import 'package:aop_sites/Screens/feedback_screen.dart';
import 'package:aop_sites/Screens/srv_btn_screen.dart';
import 'package:aop_sites/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'web_view.dart';

class PashtoScreen extends StatelessWidget {
  const PashtoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ښه راغلاست',
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
                title: 'د چارو اداري وب سایت',
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const WebviewScreen(
                            url: "https://aop.gov.af/pa",
                          )));
                }),
            MyCustomButton(
              title: 'د حکومتی اداراتو لیست',
              onPressed: () {
                // Add navigation or functionality here
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const WebviewScreen(
                        url: 'https://aop.gov.af/pa/government/ministries')));
              },
            ),
            MyCustomButton(
                title: 'د دولت عامه خدمتونه',
                onPressed: () {
                  // Add navigation or functionality here
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const SrvBTNScreen(
                            passportTitle: 'د پاسپورټ خدمتونه',
                            passportURL: 'https://passport.moi.gov.af/pa/',
                          )));
                }),
            MyCustomButton(
                title: 'نظریات/وړاندیزونه',
                onPressed: () {
                  // Add navigation or functionality here
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const FeedbackScreen(
                            appbarTitle: 'موږ سره اړیکه ونیسئ',
                            guidedText:
                                'مهرباني وکړئ لاندې یو انتخاب باندې کلیک وکړئ او خپل نظرونه او وړاندیزونه موږ سره شریک کړئ.',
                            whatsAppTitle: "واتسپ",
                            emailTitle: "ایمیل",
                            txtDir: TextDirection.rtl,
                            formTitle: 'د اړیکو فورمه',
                            url: 'https://aop.gov.af/pa/forms',
                          )));
                }),
          ],
        ),
      ),
    );
  }
}
