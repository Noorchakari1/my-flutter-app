import 'package:flutter/material.dart';

/// A reusable button that scrolls to the top of a list
/// Standard size is 56.0 for consistency across the app
class ScrollToTopButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool visible;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final Duration? animationDuration;

  /// Standard size for scroll to top buttons across the app
  static const double standardSize = 56.0;

  const ScrollToTopButton({
    super.key,
    required this.onPressed,
    required this.visible,
    this.backgroundColor,
    this.iconColor,
    this.size,
    this.margin,
    this.elevation,
    this.animationDuration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: animationDuration ?? const Duration(milliseconds: 300),
      child: AnimatedContainer(
        duration: animationDuration ?? const Duration(milliseconds: 300),
        margin: margin ?? const EdgeInsets.all(16),
        height: visible ? (size ?? standardSize) : 0,
        width: visible ? (size ?? standardSize) : 0,
        child: visible
            ? FloatingActionButton(
                onPressed: onPressed,
                backgroundColor: backgroundColor ??
                  (isDarkMode ? Colors.grey.shade800 : Colors.white),
                elevation: elevation ?? 4,
                mini: size != null && size! < standardSize,
                child: Icon(
                  Icons.arrow_upward,
                  color: iconColor ??
                    (isDarkMode ? Colors.white : theme.primaryColor),
                ),
              )
            : const SizedBox(),
      ),
    );
  }
}
