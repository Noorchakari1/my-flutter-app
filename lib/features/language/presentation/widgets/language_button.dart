import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _LanguageButtonState extends State<LanguageButton>
    with TickerProviderStateMixin {
  bool _isPressed = false;
  bool _isImageLoaded = false;
  late AnimationController _scaleController;
  late AnimationController _shimmerController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    _shimmerController.repeat();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

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

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _scaleController.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _scaleController.reverse();
    widget.onPressed();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive sizing based on available space
        final buttonWidth = constraints.maxWidth;
        final buttonHeight = constraints.maxHeight;
        final flagSize = (buttonWidth * 0.35).clamp(60.0, 90.0);
        final padding = (buttonWidth * 0.08).clamp(12.0, 20.0);

        return Semantics(
          label: 'Select ${widget.language} language',
          button: true,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: GestureDetector(
                  onTapDown: _handleTapDown,
                  onTapUp: _handleTapUp,
                  onTapCancel: _handleTapCancel,
                  child: Container(
                    width: buttonWidth,
                    height: buttonHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDarkMode
                            ? [
                                const Color(0xFF2A2A2A),
                                const Color(0xFF1E1E1E),
                              ]
                            : [
                                Colors.white,
                                const Color(0xFFFAFAFA),
                              ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode
                              ? Colors.black.withAlpha(102) // 0.4 opacity
                              : AppConstants.shadowColor.withAlpha(38), // 0.15 opacity
                          blurRadius: _isPressed ? 8 : 15,
                          spreadRadius: _isPressed ? 1 : 3,
                          offset: Offset(0, _isPressed ? 3 : 8),
                        ),
                        if (!isDarkMode)
                          BoxShadow(
                            color: Colors.white.withAlpha(128), // 0.5 opacity
                            blurRadius: 1,
                            spreadRadius: 0,
                            offset: const Offset(0, 1),
                          ),
                      ],
                      border: Border.all(
                        color: isDarkMode
                            ? Colors.white.withAlpha(26) // 0.1 opacity
                            : Colors.black.withAlpha(13), // 0.05 opacity
                        width: 0.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Material(
                        color: Colors.transparent,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Flag section with responsive sizing
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(
                                  padding,
                                  padding * 1.2,
                                  padding,
                                  padding * 0.8,
                                ),
                                child: Center(
                                  child: Container(
                                    width: flagSize,
                                    height: flagSize,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: isDarkMode
                                            ? [
                                                const Color(0xFF3A3A3A),
                                                const Color(0xFF2A2A2A),
                                              ]
                                            : [
                                                Colors.white,
                                                const Color(0xFFF5F5F5),
                                              ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isDarkMode
                                              ? Colors.black.withAlpha(102) // 0.4 opacity
                                              : Colors.black.withAlpha(38), // 0.15 opacity
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(3),
                                    child: ClipOval(
                                      child: Stack(
                                        children: [
                                          // Shimmer loading effect
                                          if (!_isImageLoaded)
                                            AnimatedBuilder(
                                              animation: _shimmerAnimation,
                                              builder: (context, child) {
                                                return Container(
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      begin: Alignment(-1.0 + _shimmerAnimation.value, 0.0),
                                                      end: Alignment(1.0 + _shimmerAnimation.value, 0.0),
                                                      colors: isDarkMode
                                                          ? [
                                                              Colors.grey.shade800,
                                                              Colors.grey.shade700,
                                                              Colors.grey.shade800,
                                                            ]
                                                          : [
                                                              Colors.grey.shade300,
                                                              Colors.grey.shade100,
                                                              Colors.grey.shade300,
                                                            ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          // Flag image
                                          Image.asset(
                                            widget.flagAsset,
                                            fit: BoxFit.cover,
                                            width: flagSize,
                                            height: flagSize,
                                            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                                              if (frame != null && !_isImageLoaded) {
                                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                                  if (mounted) {
                                                    setState(() => _isImageLoaded = true);
                                                    _shimmerController.stop();
                                                  }
                                                });
                                              }
                                              return child;
                                            },
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                decoration: BoxDecoration(
                                                  color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  Icons.flag,
                                                  color: isDarkMode ? Colors.white54 : Colors.black54,
                                                  size: flagSize * 0.4,
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Select language button at bottom
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    AppConstants.primaryColor,
                                    Color.fromARGB(
                                      AppConstants.primaryColor.a.toInt(),
                                      AppConstants.primaryColor.r.toInt(),
                                      AppConstants.primaryColor.g.toInt(),
                                      (AppConstants.primaryColor.b * 0.8).round(),
                                    ),
                                  ],
                                ),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppConstants.primaryColor.withAlpha(77), // 0.3 opacity
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: isSmallScreen ? 10 : 14,
                                horizontal: 8,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.white,
                                    size: isSmallScreen ? 16 : 18,
                                  ),
                                  SizedBox(width: isSmallScreen ? 6 : 8),
                                  Flexible(
                                    child: Text(
                                      _getSelectText,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isSmallScreen ? 12 : 14,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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
            },
          ),
        );
      },
    );
  }
}