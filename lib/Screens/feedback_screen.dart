import 'package:aop_sites/Screens/web_view.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedbackScreen extends StatelessWidget {
  final String pageTitle;
  final String text;
  final String whatsAppTitle;
  final String emailTitle;
  final TextDirection txtdir;
  final String formTitle;
  final String url;

  const FeedbackScreen({
    super.key,
    required this.text,
    required this.whatsAppTitle,
    required this.emailTitle,
    required this.txtdir,
    required this.pageTitle,
    required this.formTitle,
    required this.url,
  });

  // Function to launch WhatsApp
  Future<void> _launchWhatsApp(String number) async {
    final uri = Uri.parse("https://wa.me/$number");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch WhatsApp URL: $uri');
      throw 'Could not launch WhatsApp';
    }
  }

  // Function to launch Email
  Future<void> _launchEmail(String email) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query:
          'subject=نظریات و پیشنهادات&body=سلام,', // Optional: subject and body
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch Email URL: $uri');
      throw 'Could not launch Email';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          pageTitle,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade400,
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
        child: Directionality(
          textDirection: txtdir,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Text
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // WhatsApp Contact
                GestureDetector(
                  onTap: () async {
                    try {
                      await _launchWhatsApp('0792436800');
                    } catch (e) {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('موفق به راه اندازی واستپ نشدیم: $e')),
                      );
                    }
                  },
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.message, color: Colors.green),
                      title: Text(
                        whatsAppTitle,
                        style: const TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text('0792436800'),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Email Contact
                GestureDetector(
                  onTap: () async {
                    try {
                      await _launchEmail('saad.basir786@gmail.com');
                    } catch (e) {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('موفق به راه اندازی ایمیل نشدیم: $e')),
                      );
                    }
                  },
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.email, color: Colors.red),
                      title: Text(
                        emailTitle,
                        style: const TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text('saad.basir786@gmail.com'),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Email Contact
                GestureDetector(
                  onTap: () {
                    // Add navigation or functionality here
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => WebviewScreen(
                              url: url,
                            )));
                  },
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.email, color: Colors.blue),
                      title: Text(
                        formTitle,
                        style: const TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
