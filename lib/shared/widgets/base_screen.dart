import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/localization_helper.dart';
import 'custom_app_bar.dart';
import 'scroll_to_top_button.dart';

/// A base screen widget that can be extended by other screens
/// Provides common functionality like app bar, scroll to top button, etc.
class BaseScreen extends ConsumerStatefulWidget {
  final String title;
  final Widget body;
  final bool showAppBar;
  final bool showBackButton;
  final bool showScrollToTopButton;
  final bool showDrawer;
  final bool showThemeToggle;
  final bool showLanguageButton;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final ScrollController? scrollController;
  final VoidCallback? onRefresh;
  final bool enablePullToRefresh;
  final List<Widget>? actions;

  const BaseScreen({
    super.key,
    required this.title,
    required this.body,
    this.showAppBar = true,
    this.showBackButton = false,
    this.showScrollToTopButton = true,
    this.showDrawer = false,
    this.showThemeToggle = true,
    this.showLanguageButton = true,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.scrollController,
    this.onRefresh,
    this.enablePullToRefresh = false,
    this.actions,
  });

  @override
  ConsumerState<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends ConsumerState<BaseScreen> {
  late ScrollController _scrollController;
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_scrollListener);
    }
    super.dispose();
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;

    final currentScroll = _scrollController.position.pixels;
    final shouldShowScrollToTop = currentScroll > 300;

    if (_showScrollToTop != shouldShowScrollToTop) {
      setState(() {
        _showScrollToTop = shouldShowScrollToTop;
      });
    }
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) return;

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRTL = LocalizationHelper.isRTL(ref);

    Widget content = widget.body;

    // Wrap with pull-to-refresh if enabled
    if (widget.enablePullToRefresh && widget.onRefresh != null) {
      content = RefreshIndicator(
        onRefresh: () async {
          widget.onRefresh?.call();
        },
        color: theme.primaryColor,
        child: content,
      );
    }

    // Add scroll to top button if enabled
    if (widget.showScrollToTopButton) {
      content = Stack(
        children: [
          content,
          Positioned(
            right: isRTL ? null : 16,
            left: isRTL ? 16 : null,
            bottom: 16,
            child: ScrollToTopButton(
              visible: _showScrollToTop,
              onPressed: _scrollToTop,
              backgroundColor: theme.primaryColor,
              iconColor: Colors.white,
              size: ScrollToTopButton.standardSize,
            ),
          ),
        ],
      );
    }

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: widget.backgroundColor ?? theme.scaffoldBackgroundColor,
        appBar: widget.showAppBar
            ? CustomAppBar(
                title: widget.title,
                showBackButton: widget.showBackButton,
                showDrawer: widget.showDrawer,
                showThemeToggle: widget.showThemeToggle,
                showLanguageButton: widget.showLanguageButton,
                actions: widget.actions,
              )
            : null,
        body: content,
        floatingActionButton: widget.floatingActionButton,
        bottomNavigationBar: widget.bottomNavigationBar,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        extendBody: widget.bottomNavigationBar != null,
        extendBodyBehindAppBar: false,
      ),
    );
  }
}
