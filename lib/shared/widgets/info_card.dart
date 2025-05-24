import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/services/loading_manager.dart';
import '../../core/utils/localization_helper.dart';

/// Reusable card widget for displaying information with image
/// Modernized with enhanced visual design and subtle animations
/// Automatically adapts to the app's current language direction
class InfoCard extends ConsumerStatefulWidget {
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final VoidCallback onTap;
  final bool? isRTL; // Optional now - will be auto-detected if not provided
  final bool showLoadingOnTap; // Whether to show loading indicator when tapped

  const InfoCard({
    super.key,
    required this.title,
    this.subtitle,
    this.imageUrl,
    required this.onTap,
    this.isRTL,
    this.showLoadingOnTap = true, // Default to true for better UX
  });

  @override
  ConsumerState<InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends ConsumerState<InfoCard> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _loadingController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  bool _isPressed = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Loading animation controller for sophisticated loading effects
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Pulsing animation for the loading indicator
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _loadingController,
        curve: Curves.easeInOut,
      ),
    );

    // Fade animation for smooth appearance
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _loadingController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (!widget.showLoadingOnTap) {
      widget.onTap();
      return;
    }

    // Check if global loading is already active
    final loadingManager = LoadingManager.instance;
    if (loadingManager.isGlobalLoading) {
      // If global loading is active, just execute the tap without showing overlay
      widget.onTap();
      return;
    }

    setState(() => _isLoading = true);

    // Start the loading animation with repeat
    _loadingController.repeat(reverse: true);

    // Add a small delay to show the loading state
    await Future.delayed(const Duration(milliseconds: 100));

    widget.onTap();

    // Reset loading state after a short delay
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      _loadingController.stop();
      _loadingController.reset();
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    // Determine if the layout should be RTL based on the current language
    // Use the provided isRTL value if available, otherwise auto-detect
    final isRTL = widget.isRTL ?? LocalizationHelper.isRTL(ref);

    // Card colors based on theme
    final cardColor = isDarkMode
        ? Colors.grey.shade900
        : Colors.white;
    final shadowColor = isDarkMode
        ? Colors.black.withAlpha(51) // ~0.2 opacity
        : Colors.black.withAlpha(20); // ~0.08 opacity
    final highlightColor = primaryColor.withAlpha(13); // ~0.05 opacity

    // Create a Directionality widget to enforce the correct text direction
    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: GestureDetector(
          onTap: _isLoading ? null : _handleTap,
          onTapDown: _isLoading ? null : (_) {
            setState(() => _isPressed = true);
            _controller.forward();
          },
          onTapUp: _isLoading ? null : (_) {
            setState(() => _isPressed = false);
            _controller.reverse();
          },
          onTapCancel: _isLoading ? null : () {
            setState(() => _isPressed = false);
            _controller.reverse();
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 12,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: _isPressed
                    ? primaryColor.withAlpha(77) // ~0.3 opacity
                    : Colors.transparent,
                width: 1.5,
              ),
              gradient: _isPressed ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  highlightColor,
                  cardColor,
                ],
              ) : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Row(
                    // No need to set textDirection here as it's handled by the parent Directionality widget
                    children: [
                      if (widget.imageUrl != null)
                        _buildImage(isDarkMode, primaryColor, isRTL),
                      Expanded(
                        child: _buildContent(isDarkMode, theme, isRTL),
                      ),
                      _buildArrow(isDarkMode, primaryColor, isRTL),
                    ],
                  ),
                  if (_isLoading)
                    _buildLoadingOverlay(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(bool isDarkMode, Color primaryColor, bool isRTL) {
    // Since we're using Directionality, we can simplify the border logic
    // In RTL mode, the image will be on the right side, so we need a left border
    // In LTR mode, the image will be on the left side, so we need a right border
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        border: Border(
          // In RTL mode, this will be the left side of the image (since it's on the right)
          // In LTR mode, this will be the right side of the image (since it's on the left)
          right: BorderSide(
            color: isDarkMode
                ? Colors.grey.shade800
                : Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: CachedNetworkImage(
        imageUrl: widget.imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
          highlightColor: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade100,
          child: Container(
            color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
          child: Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              size: 32,
              color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(bool isDarkMode, ThemeData theme, bool isRTL) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        // Always align to start since we're using Directionality widget
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
              letterSpacing: 0.1,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            // No need to set textAlign as it's handled by the parent Directionality widget
          ),
          if (widget.subtitle != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.only(top: 6),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDarkMode
                        ? Colors.grey.shade800.withAlpha(128) // ~0.5 opacity
                        : Colors.grey.shade200.withAlpha(204), // ~0.8 opacity
                    width: 0.5,
                  ),
                ),
              ),
              child: Text(
                widget.subtitle!,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                // No need to set textAlign as it's handled by the parent Directionality widget
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildArrow(bool isDarkMode, Color primaryColor, bool isRTL) {
    // In RTL mode, we use arrow_back_ios_rounded, in LTR mode we use arrow_forward_ios_rounded
    // But since we're using Directionality, we can just use arrow_forward_ios_rounded
    // and let the Directionality widget handle the direction
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: _isPressed
              ? primaryColor.withAlpha(26) // ~0.1 opacity
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: _isPressed
                ? primaryColor
                : (isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return AnimatedBuilder(
      animation: _loadingController,
      builder: (context, child) {
        return Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
              child: Container(
                decoration: BoxDecoration(
                  // Modern glassmorphism effect
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDarkMode
                        ? [
                            Colors.black.withAlpha(128), // ~0.5 opacity
                            Colors.black.withAlpha(102), // ~0.4 opacity
                          ]
                        : [
                            Colors.white.withAlpha(128), // ~0.5 opacity
                            Colors.black.withAlpha(77),  // ~0.3 opacity
                          ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.white.withAlpha(26) // ~0.1 opacity
                        : Colors.white.withAlpha(51), // ~0.2 opacity
                    width: 0.5,
                  ),
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.grey.shade900.withAlpha(230) // ~0.9 opacity
                            : Colors.white.withAlpha(230), // ~0.9 opacity
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withAlpha(51), // ~0.2 opacity
                            blurRadius: 20,
                            spreadRadius: 0,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: isDarkMode
                                ? Colors.black.withAlpha(77) // ~0.3 opacity
                                : Colors.black.withAlpha(26), // ~0.1 opacity
                            blurRadius: 10,
                            spreadRadius: 0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: primaryColor.withAlpha(51), // ~0.2 opacity
                          width: 1,
                        ),
                      ),
                      child: ScaleTransition(
                        scale: _pulseAnimation,
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                            strokeWidth: 3,
                            backgroundColor: isDarkMode
                                ? Colors.grey.shade700.withAlpha(77) // ~0.3 opacity
                                : Colors.grey.shade300.withAlpha(77), // ~0.3 opacity
                          ),
                        ),
                      ),
                    ),
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
