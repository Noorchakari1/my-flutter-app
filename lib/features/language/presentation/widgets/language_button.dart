import 'package:flutter/material.dart';
import '../../../../shared/constants/app_constants.dart';

class LanguageButton extends StatefulWidget {
  final String language;
  final String flagAsset;
  final VoidCallback onPressed;

  const LanguageButton({
    super.key,
    required this.language,
    required this.flagAsset,
    required this.onPressed,
  });

  @override
  State<LanguageButton> createState() => _LanguageButtonState();
}

class _LanguageButtonState extends State<LanguageButton> {
  bool _isPressed = false;

  // Get the appropriate "select" text based on language
  String get _getSelectText {
    switch (widget.language) {
      case 'English':
        return 'Select Language';
      case 'پشتو':
        return 'ژبه وټاکئ';
      case 'دری':
        return 'انتخاب زبان';
      default:
        return 'انتخاب زبان';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()
          ..scale(_isPressed ? 0.95 : 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isDarkMode 
                  ? Colors.black.withOpacity(0.3)
                  : AppConstants.shadowColor.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: _isPressed ? 1 : 2,
                offset: Offset(0, _isPressed ? 2 : 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Flag section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDarkMode ? const Color(0xFF3A3A3A) : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: isDarkMode 
                              ? Colors.black.withOpacity(0.3)
                              : Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(2),
                      child: ClipOval(
                        child: Image.asset(
                          widget.flagAsset,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  
                  // Select language button at bottom
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppConstants.primaryColor,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getSelectText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 