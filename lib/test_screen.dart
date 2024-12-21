// import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
// import 'package:flutter/material.dart';

// void main() {
//   runApp(const MyTestApp());
// }

// class MyTestApp extends StatelessWidget {
//   const MyTestApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Curved Navigation Bar Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const CurvedNavigationMenu(),
//     );
//   }
// }

// class CurvedNavigationMenu extends StatefulWidget {
//   const CurvedNavigationMenu({super.key});

//   @override
//   _CurvedNavigationMenuState createState() => _CurvedNavigationMenuState();
// }

// class _CurvedNavigationMenuState extends State<CurvedNavigationMenu> {
//   int _selectedIndex = 0;

//   final List<Widget> _screens = [
//     const Center(child: Text('Home Screen', style: TextStyle(fontSize: 24))),
//     const Center(child: Text('Search Screen', style: TextStyle(fontSize: 24))),
//     const Center(child: Text('Profile Screen', style: TextStyle(fontSize: 24))),
//   ];

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Curved Navigation Bar'),
//       ),
//       body: _screens[_selectedIndex],
//       bottomNavigationBar: CurvedNavigationBar(
//         backgroundColor: Colors.white,
//         color: Colors.blueAccent,
//         animationDuration: const Duration(milliseconds: 300),
//         height: 60,
//         index: _selectedIndex,
//         onTap: _onItemTapped,
//         items: const [
//           CurvedNavigationBarItem(
//             child: Icon(Icons.home, color: Colors.white),
//             label: 'Home',
//           ),
//           CurvedNavigationBarItem(
//             child: Icon(Icons.search, color: Colors.white),
//             label: 'Search',
//           ),
//           CurvedNavigationBarItem(
//             child: Icon(Icons.person, color: Colors.white),
//             label: 'Profile',
//           ),
//         ],
//       ),
//     );
//   }
// }





// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';

// class MapButtonExample extends StatelessWidget {
//   // مختصات هدف
//   final double latitude = 34.5553; // عرض جغرافیایی
//   final double longitude = 69.2075;

//   const MapButtonExample({super.key}); // طول جغرافیایی

//   Future<void> _openGoogleMaps() async {
//     // لینک گوگل مپ با مختصات
//     final String googleMapsUrl =
//         "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";

//     if (await canLaunch(googleMapsUrl)) {
//       await launch(googleMapsUrl);
//     } else {
//       throw "Could not open Google Maps";
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("انتقال به گوگل مپ"),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: _openGoogleMaps,
//           child: const Text("نمایش موقعیت در Google Maps"),
//         ),
//       ),
//     );
//   }
// }

// void main() {
//   runApp(MaterialApp(
//     home: MapButtonExample(),
//   ));
// }
