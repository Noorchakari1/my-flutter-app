import 'package:aop_sites/Screens/english_screen.dart';
import 'package:aop_sites/Screens/pashto_screen.dart';
import 'package:aop_sites/Screens/persian_screen.dart';
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
    return Container(
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
          // const MyTextView(
          //   text: 'لطفا زبان مورد نظر را انتخاب نمایید',
          // ),

          Directionality(
            textDirection: TextDirection.rtl,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Color(0xff4EABF6),
                ),
                child: ListTile(
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
    );
  }
}

// // class MyTextView extends StatelessWidget {
//   final String text;
//   const MyTextView({super.key, required this.text});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
//       child: Card(
//         color: const Color(0xff4EABF6),
//         elevation: 4,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8.0),
//         ),
//         child: Row(
//           children: [
//             Icon(Icons.hearing),
//             Padding(
//               padding: const EdgeInsets.all(24.0),
//               child: Text(
//                 text,
//                 style: const TextStyle(
//                   fontSize: 16.0,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class MyCustomButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final IconData? icon; // Optional icon

  const MyCustomButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.icon, // Icon parameter
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.blue.shade600,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            elevation: 5,
          ),
          onPressed: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white),
                const SizedBox(width: 8), // Space between icon and text
              ],
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
