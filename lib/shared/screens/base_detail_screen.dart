import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/localization_helper.dart';
import '../widgets/scroll_to_top_button.dart';

/// Base class for detail screens with common functionality
abstract class BaseDetailScreen<T> extends ConsumerStatefulWidget {
  final int itemId;

  const BaseDetailScreen({
    super.key,
    required this.itemId,
  });

  @override
  BaseDetailScreenState<T, BaseDetailScreen<T>> createState();
}

abstract class BaseDetailScreenState<T, W extends BaseDetailScreen<T>> extends ConsumerState<W> {
  final ScrollController scrollController = ScrollController();
  bool showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    setState(() {
      showScrollToTop = scrollController.offset > 500;
    });
  }

  void scrollToTop() {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textDirection = LocalizationHelper.getTextDirection(ref);
    final isRTL = textDirection == TextDirection.rtl;

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        backgroundColor: isDarkMode ? Colors.black : Colors.grey.shade100,
        body: Stack(
          children: [
            buildBody(context, ref, isDarkMode),
            Positioned(
              right: isRTL ? null : 16,
              left: isRTL ? 16 : null,
              bottom: 16,
              child: ScrollToTopButton(
                visible: showScrollToTop,
                onPressed: scrollToTop,
                backgroundColor: Theme.of(context).primaryColor,
                iconColor: Colors.white,
              ),
            ),
          ],
        ),
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
