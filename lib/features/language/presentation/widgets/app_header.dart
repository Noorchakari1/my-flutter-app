import 'package:flutter/material.dart';
import '../../../../shared/constants/app_constants.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final String? logoPath;
  final double? logoHeight;
  final Color? logoColor;
  final List<Widget>? additionalContent;

  const AppHeader({
    super.key,
    required this.title,
    this.logoPath,
    this.logoHeight,
    this.logoColor,
    this.additionalContent,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      // padding: const EdgeInsets.all(AppConstants.headerPadding),
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withAlpha(77)
                : AppConstants.shadowColor.withAlpha(51),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 5),
          if (logoPath != null)
            Hero(
              tag: 'logo',
              child: Image.asset(
                logoPath!,
                height: logoHeight ?? AppConstants.headerImageHeight,
                color: logoColor ?? Colors.white,
              ),
            ),
          const SizedBox(height: AppConstants.defaultPadding * 0.5),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          if (additionalContent != null) ...additionalContent!,
        ],
      ),
    );
  }
} 