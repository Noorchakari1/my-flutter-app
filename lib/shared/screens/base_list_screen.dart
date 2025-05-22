import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/localization_helper.dart';
import '../../shared/constants/app_constants.dart';
import '../../shared/widgets/search_bar_widget.dart';

/// Base class for list screens with common functionality
abstract class BaseListScreen<T> extends ConsumerStatefulWidget {
  const BaseListScreen({super.key});
}

/// Base state class for list screens
abstract class BaseListScreenState<T, W extends BaseListScreen<T>> extends ConsumerState<W> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();
  bool isSearchVisible = false;
  bool showScrollToTop = false;
  bool isLoadingMore = false;
  bool hasMoreData = true;
  int currentPage = 1;
  dynamic error;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_scrollListener);
    loadInitialData();
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    setState(() {
      showScrollToTop = scrollController.offset > 500;
    });

    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200 &&
        !isLoadingMore &&
        hasMoreData) {
      loadMoreData();
    }
  }

  void toggleSearch() {
    setState(() {
      isSearchVisible = !isSearchVisible;
      if (!isSearchVisible) {
        searchController.clear();
        onSearchChanged('');
      }
    });
  }

  Widget buildSearchField() {
    return SearchBarWidget(
      hintText: getSearchHintText(),
      onSearch: onSearchChanged,
      onClear: () => onSearchChanged(''),
      controller: searchController,
      autofocus: true,
      showBorder: false,
      backgroundColor: Colors.transparent,
      margin: EdgeInsets.zero,
      textColor: Colors.white,
      hintTextColor: Colors.white.withAlpha(179), // 0.7 opacity = 179/255
      iconColor: Colors.white,
    );
  }

  void scrollToTop() {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  /// Abstract methods to be implemented by subclasses
  Future<void> loadInitialData();
  Future<void> loadMoreData();
  void onSearchChanged(String query);
  String getSearchHintText();
  String getScreenTitle();
  Widget buildItemCard(T item);
  Widget buildListView(List<T> items);
  Widget buildEmptyState();
  Widget buildErrorState(dynamic error);
  Widget buildLoadingState();

  @override
  Widget build(BuildContext context) {
    final isRTL = LocalizationHelper.isRTL(ref);

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: isSearchVisible
            ? buildSearchField()
            : Text(getScreenTitle()),
          backgroundColor: AppConstants.primaryColor,
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(isSearchVisible ? Icons.close : Icons.search),
              onPressed: toggleSearch,
            ),
          ],
        ),
        body: buildBody(),
        floatingActionButton: showScrollToTop
          ? FloatingActionButton(
              backgroundColor: AppConstants.primaryColor,
              onPressed: scrollToTop,
              child: const Icon(Icons.arrow_upward, color: Colors.white),
            )
          : null,
      ),
    );
  }

  /// Build the body of the screen
  Widget buildBody();
}
