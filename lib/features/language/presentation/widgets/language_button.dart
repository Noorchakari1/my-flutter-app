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
            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(20),
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
            borderRadius: BorderRadius.circular(20),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: isDarkMode 
                              ? Colors.black.withOpacity(0.3)
                              : AppConstants.shadowColor.withOpacity(0.1),
                            blurRadius: 8,
                            spreadRadius: 2,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        widget.flagAsset,
                        height: 50,
                        width: 50,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.language,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : AppConstants.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 