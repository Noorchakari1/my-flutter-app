import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/localization_helper.dart';

/// A reusable widget for displaying empty states in a consistent way
class EmptyStateWidget extends ConsumerWidget {
  final String? message;
  final String? subMessage;
  final IconData? icon;
  final double? iconSize;
  final Color? iconColor;
  final TextStyle? messageStyle;
  final TextStyle? subMessageStyle;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onActionPressed;
  final String? actionLabel;

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
                icon ?? Icons.search_off_rounded,
                size: iconSize ?? 64,
                color: iconColor ?? (isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              Text(
                message ?? LocalizationHelper.getText(ref, 'noResults'),
                style: messageStyle ?? TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade800,
                ),
                textAlign: TextAlign.center,
              ),
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
              if (onActionPressed != null && actionLabel != null) ...[
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: onActionPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
