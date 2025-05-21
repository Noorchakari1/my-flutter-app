import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/utils/localization_helper.dart';
import '../../core/providers/theme_provider.dart';

/// Reusable card widget for displaying information with image
/// Modernized with enhanced visual design and subtle animations
/// Automatically adapts to the app's current language direction
class InfoCard extends ConsumerStatefulWidget {
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final VoidCallback onTap;
  final bool? isRTL; // Optional now - will be auto-detected if not provided

  const InfoCard({
    super.key,
    required this.title,
    this.subtitle,
    this.imageUrl,
    required this.onTap,
    this.isRTL,
  });

  @override
  ConsumerState<InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends ConsumerState<InfoCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
          onTap: widget.onTap,
          onTapDown: (_) {
            setState(() => _isPressed = true);
            _controller.forward();
          },
          onTapUp: (_) {
            setState(() => _isPressed = false);
            _controller.reverse();
          },
          onTapCancel: () {
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
              child: Row(
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
              fontSize: 16,
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
}
