import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/localization_helper.dart';

/// Base class for detail screens with common functionality
abstract class BaseDetailScreen<T> extends ConsumerWidget {
  final int itemId;
  
  const BaseDetailScreen({
    super.key,
    required this.itemId,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textDirection = LocalizationHelper.getTextDirection(ref);
    
    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        backgroundColor: isDarkMode ? Colors.black : Colors.grey.shade100,
        body: buildBody(context, ref, isDarkMode),
      ),
    );
  }
  
  /// Abstract methods to be implemented by subclasses
  Widget buildBody(BuildContext context, WidgetRef ref, bool isDarkMode);
  Widget buildLoadingState();
  Widget buildErrorState(BuildContext context, WidgetRef ref, dynamic error);
  
  /// Helper method to launch URL
  Future<void> launchURL(BuildContext context, String? url) async {
    // Implementation will be provided by subclasses
  }
  
  /// Helper method to make phone call
  Future<void> makePhoneCall(BuildContext context, String? phone) async {
    // Implementation will be provided by subclasses
  }
  
  /// Helper method to share content
  Future<void> shareContent(BuildContext context, String title, String content) async {
    // Implementation will be provided by subclasses
  }
}
