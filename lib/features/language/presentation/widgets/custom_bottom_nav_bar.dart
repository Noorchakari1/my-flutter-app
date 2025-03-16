import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

import '../../../../shared/constants/app_constants.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final String webUrl;
  final TextDirection textDirection;
  final String feedbackTitle;
  final String feedbackText;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.webUrl,
    required this.textDirection,
    required this.feedbackTitle,
    required this.feedbackText,
  });

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      backgroundColor: Colors.transparent,
      color: AppConstants.primaryColor,
      buttonBackgroundColor: AppConstants.primaryColor,
      height: 60,
      index: currentIndex,
      items: const [
        Icon(Icons.home, size: 30, color: Colors.white),
        Icon(Icons.web, size: 30, color: Colors.white),
        Icon(Icons.feedback, size: 30, color: Colors.white),
      ],
      onTap: onTap,
    );
  }
} 