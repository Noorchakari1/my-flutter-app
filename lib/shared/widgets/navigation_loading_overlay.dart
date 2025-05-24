import 'dart:ui';
import 'package:flutter/material.dart';

/// A reusable overlay widget that shows a loading indicator during navigation
/// Enhanced with modern glassmorphism effects and smooth animations
class NavigationLoadingOverlay extends StatefulWidget {
  final bool isVisible;
  final String? message;
  final Color? backgroundColor;
  final Color? indicatorColor;

  const NavigationLoadingOverlay({
    super.key,
    required this.isVisible,
    this.message,
    this.backgroundColor,
    this.indicatorColor,
  });

  @override
  State<NavigationLoadingOverlay> createState() => _NavigationLoadingOverlayState();
}

class _NavigationLoadingOverlayState extends State<NavigationLoadingOverlay>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for the loading indicator
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Fade animation for smooth appearance
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOut,
      ),
    );

    if (widget.isVisible) {
      _fadeController.forward();
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(NavigationLoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _fadeController.forward();
        _pulseController.repeat(reverse: true);
      } else {
        _fadeController.reverse();
        _pulseController.stop();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _fadeController]),
      builder: (context, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: widget.backgroundColor ??
              (isDarkMode
                ? Colors.black.withAlpha(128) // ~0.5 opacity
                : Colors.black.withAlpha(102)), // ~0.4 opacity
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      // Modern glassmorphism effect
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDarkMode
                            ? [
                                Colors.grey.shade900.withAlpha(240), // ~0.94 opacity
                                Colors.grey.shade800.withAlpha(230), // ~0.9 opacity
                              ]
                            : [
                                Colors.white.withAlpha(240), // ~0.94 opacity
                                Colors.white.withAlpha(230), // ~0.9 opacity
                              ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withAlpha(77), // ~0.3 opacity
                          blurRadius: 25,
                          spreadRadius: 0,
                          offset: const Offset(0, 12),
                        ),
                        BoxShadow(
                          color: isDarkMode
                              ? Colors.black.withAlpha(128) // ~0.5 opacity
                              : Colors.black.withAlpha(51), // ~0.2 opacity
                          blurRadius: 15,
                          spreadRadius: 0,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      border: Border.all(
                        color: isDarkMode
                            ? Colors.white.withAlpha(51) // ~0.2 opacity
                            : primaryColor.withAlpha(77), // ~0.3 opacity
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ScaleTransition(
                          scale: _pulseAnimation,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: primaryColor.withAlpha(26), // ~0.1 opacity
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: primaryColor.withAlpha(77), // ~0.3 opacity
                                width: 2,
                              ),
                            ),
                            child: SizedBox(
                              width: 36,
                              height: 36,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  widget.indicatorColor ?? primaryColor,
                                ),
                                strokeWidth: 3.5,
                                backgroundColor: isDarkMode
                                    ? Colors.grey.shade700.withAlpha(102) // ~0.4 opacity
                                    : Colors.grey.shade300.withAlpha(102), // ~0.4 opacity
                              ),
                            ),
                          ),
                        ),
                        if (widget.message != null) ...[
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              widget.message!,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode ? Colors.white : Colors.black87,
                                letterSpacing: 0.2,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
  }


}
