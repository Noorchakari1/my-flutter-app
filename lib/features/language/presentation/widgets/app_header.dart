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
    final isGolden = Theme.of(context).colorScheme.primary == const Color(0xFFB08D57);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24.0, 4.0, 24.0, 24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isGolden
              ? const [Color(0xFF252016), Color(0xFF15120E)]
              : const [Color(0xFF27118E), AppConstants.primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withAlpha(77)
                : AppConstants.shadowColor.withAlpha(51),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          if (logoPath != null)
            Hero(
              tag: 'logo',
              child: Image.asset(
                logoPath!,
                height: logoHeight ?? AppConstants.headerImageHeight,
                color: isGolden ? const Color(0xFFB08D57) : logoColor ?? Colors.white,
              ),
            ),
          const SizedBox(height: AppConstants.defaultPadding * 0.75),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isGolden ? const Color(0xFFF7F1E3) : Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
          if (additionalContent != null) ...additionalContent!,
        ],
      ),
    );
  }
}
