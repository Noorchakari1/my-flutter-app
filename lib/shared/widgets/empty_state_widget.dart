import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/localization_helper.dart';
import '../constants/app_constants.dart';

/// A reusable widget for displaying empty states in a consistent way
/// with enhanced visual appeal and animations
class EmptyStateWidget extends ConsumerWidget {
  /// Main message to display
  final String? message;

  /// Optional secondary message with additional context
  final String? subMessage;

  /// Icon to display above the message
  final IconData? icon;

  /// Size of the icon
  final double? iconSize;

  /// Color of the icon
  final Color? iconColor;

  /// Style for the main message text
  final TextStyle? messageStyle;

  /// Style for the sub-message text
  final TextStyle? subMessageStyle;

  /// Padding around the entire widget
  final EdgeInsetsGeometry? padding;

  /// Callback when the action button is pressed
  final VoidCallback? onActionPressed;

  /// Label for the action button
  final String? actionLabel;

  /// Whether to show a subtle animation
  final bool animate;

  /// Optional image asset path to display instead of an icon
  final String? imagePath;

  /// Height of the image if provided
  final double? imageHeight;

  /// Width of the image if provided
  final double? imageWidth;

  const EmptyStateWidget({
    super.key,
    this.message,
    this.subMessage,
    this.icon,
    this.iconSize,
    this.iconColor,
    this.messageStyle,
    this.subMessageStyle,
    this.padding,
    this.onActionPressed,
    this.actionLabel,
    this.animate = true,
    this.imagePath,
    this.imageHeight,
    this.imageWidth,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final isRTL = LocalizationHelper.isRTL(ref);

    // Build the content that will be animated if animation is enabled
    Widget content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Show either image or icon
        if (imagePath != null) ...[
          Image.asset(
            imagePath!,
            height: imageHeight ?? 120,
            width: imageWidth,
          ),
        ] else ...[
          Icon(
            icon ?? Icons.search_off_rounded,
            size: iconSize ?? 64,
            color: iconColor ?? (isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),
          ),
        ],
        const SizedBox(height: 16),
        // Main message
        Text(
          message ?? LocalizationHelper.getText(ref, 'noResults'),
          style: messageStyle ?? TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade800,
          ),
          textAlign: TextAlign.center,
        ),
        // Optional sub-message
        if (subMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            subMessage!,
            style: subMessageStyle ?? TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        // Optional action button
        if (onActionPressed != null && actionLabel != null) ...[
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onActionPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(actionLabel!),
          ),
        ],
      ],
    );

    // Apply animation if enabled
    if (animate) {
      content = AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: content,
      );
    }

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Center(
        child: Padding(
          padding: padding ?? const EdgeInsets.all(24),
          child: content,
        ),
      ),
    );
  }
}
