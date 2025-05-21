import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/localization_helper.dart';

/// A reusable widget for displaying errors in a consistent way
class CustomErrorWidget extends ConsumerWidget {
  final String? message;
  final VoidCallback onRetry;
  final bool showRetryButton;
  final IconData? icon;
  final double? iconSize;
  final Color? iconColor;
  final TextStyle? messageStyle;
  final TextStyle? buttonTextStyle;
  final EdgeInsetsGeometry? padding;

  const CustomErrorWidget({
    super.key,
    this.message,
    required this.onRetry,
    this.showRetryButton = true,
    this.icon,
    this.iconSize,
    this.iconColor,
    this.messageStyle,
    this.buttonTextStyle,
    this.padding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final isRTL = LocalizationHelper.isRTL(ref);
    
    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Center(
        child: Padding(
          padding: padding ?? const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon ?? Icons.error_outline,
                size: iconSize ?? 64,
                color: iconColor ?? (isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              Text(
                message ?? LocalizationHelper.getText(ref, 'errorOccurred'),
                style: messageStyle ?? TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              if (showRetryButton) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: Text(
                    LocalizationHelper.getText(ref, 'retry'),
                    style: buttonTextStyle,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
