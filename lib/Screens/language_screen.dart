import 'package:aop_sites/Screens/english_screen.dart';
import 'package:aop_sites/Screens/pashto_screen.dart';
import 'package:aop_sites/Screens/persian_screen.dart';
import 'package:aop_sites/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class AopApp extends StatelessWidget {
  const AopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LanguageScreen(),
    );
  }
}

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff1C88E5),
        title: const Text(
          'د چارو اداري لوی ریاست',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
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
        child: ListView(
          // mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                  height: 150,
                  width: 150,
                  child: Image.asset(
                    'assets/logo.png',
                    color: const Color(0xff1C007C),
                  )),
            ),

            Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: const Color(0xff4EABF6),
                  ),
                  child: const ListTile(
                    title: Text(
                      'مهرباني وکړئ خپله خوښه ژبه وټاکئ',
                      style: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    leading: Icon(
                      Icons.translate,
                      color: Color(0xffffffff),
                    ),
                    subtitle: Text(
                      'لطفا زبان مورد نظر خود را انتخاب نمایید',
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            MyCustomButton(
              title: 'پشتو', // Icon for Pashto
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const PashtoScreen(),
                ));
              },
            ),
            MyCustomButton(
              title: 'دری',
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const PersianScreen(),
                ));
              },
            ),
            // MyCustomButton(
            //   title: 'العربیه',
            //   icon: Icons.language,
            //   onPressed: () {},
            //   // Icon for Arabic
            //   // onPressed: () {
            //   //   Navigator.of(context).push(MaterialPageRoute(
            //   //     builder: (context) => const ArabicScreen(),
            //   //   ));
            //   // },
            // ),
            MyCustomButton(
              title: 'English',
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const EnglishScreen(),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}
