import 'package:aop_sites/Screens/web_view.dart';
import 'package:aop_sites/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class SrvBTNScreen extends StatelessWidget {
  final String passportURL;
  final String passportTitle;
  const SrvBTNScreen({
    super.key,
    required this.passportURL,
    required this.passportTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.blue.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MyCustomButton(
                title: passportTitle,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WebviewScreen(
                          url: passportURL,
                        ),
                      ));
                },
              ),
              // MyCustomButton(
              //   title: 'خدمات تذکره الکترونیک',
              //   onPressed: () {
              //     Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //           builder: (context) => const WebviewScreen(
              //             url:
              //                 'https://www.mcit.gov.af/index.php/dr/%D8%AF%D8%B1%D8%A8%D8%A7%D8%B1%D9%87-%D9%88%D8%B2%D8%A7%D8%B1%D8%AA',
              //           ),
              //         ));
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
