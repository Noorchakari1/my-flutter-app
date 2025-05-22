import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/services/api_exception.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../shared/constants/app_constants.dart'; // Import AppConstants
import '../../../../shared/widgets/error_display.dart';
import '../../../../shared/widgets/info_card.dart';
import '../../../../shared/widgets/search_bar_widget.dart';
import '../../data/models/news_model.dart';
import '../../data/providers/news_provider.dart';
import '../../data/services/news_service.dart';
import 'news_detail_screen.dart';

class NewsScreen extends ConsumerStatefulWidget {
  const NewsScreen({super.key});

  @override
  ConsumerState<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends ConsumerState<NewsScreen> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  late TabController _tabController;
  // Remove the static list and define keys for localization
  final List<String> _categoryKeys = [
    'newsTabsAll',
    'newsTabsLatest',
  ];
  int _currentPage = 1;
  bool _hasMoreData = true;
  dynamic _error;

  // Search related variables
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchVisible = false;
  String _searchQuery = '';

  // Scroll to top button visibility
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    // Initialize TabController with the number of category keys
    _tabController = TabController(length: _categoryKeys.length, vsync: this);
    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFirstPage();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Helper function to get localized text
  String _getText(BuildContext context, String key) {
    final language = ref.watch(themeNotifierProvider).currentLanguage;
    Map<String, String> textMap;
    switch (language) {
      case 'pashto':
        textMap = AppConstants.pashtoText;
        break;
      case 'persian':
        textMap = AppConstants.persianText;
        break;
      default:
        textMap = AppConstants.englishText;
    }
    return textMap[key] ?? key; // Return key if translation not found
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    // Show scroll to top button when user has scrolled down enough
    setState(() {
      _showScrollToTop = currentScroll > 300; // Show button after scrolling 300px
    });

    // Load more when we reach 70% of the list
    if (maxScroll - currentScroll <= maxScroll * 0.3 && !_isLoadingMore && _hasMoreData) {
      _loadNextPage();
    }
  }

  Future<void> _loadFirstPage() async {
    // First check connectivity
    final isConnected = await ref.read(connectivityServiceProvider).checkConnectivity();
    if (!isConnected) {
      setState(() {
        _error = ApiException(
          message: _getText(context, 'noConnection'),
          code: 'no_connection',
        );
        _isLoadingMore = false;
      });
      return;
    }

    setState(() {
      _isLoadingMore = true;
      _currentPage = 1;
      _hasMoreData = true;
      _error = null;
    });

    try {
      // Get current language from theme provider
      final themeState = ref.read(themeNotifierProvider);
      final currentLanguage = themeState.currentLanguage;

      final response = await ref.read(newsServiceProvider).getNews(
        page: _currentPage,
        currentLanguage: currentLanguage,
      );

      if (mounted) {
        setState(() {
          ref.read(newsNotifierProvider.notifier).replaceItems(response.items);
          _hasMoreData = response.pagination.currentPage < response.pagination.totalPages;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _loadNextPage() async {
    if (_isLoadingMore || !_hasMoreData) return;

    // Check connectivity before loading more
    final isConnected = await ref.read(connectivityServiceProvider).checkConnectivity();
    if (!isConnected) {
      // Instead of showing a snackbar, just set error state
      setState(() {
        _error = ApiException(
          message: _getText(context, 'offline'),
          code: 'no_connection',
        );
        _isLoadingMore = false;
      });
      return;
    }

    setState(() {
      _isLoadingMore = true;
      _error = null; // Clear any previous errors
    });

    try {
      _currentPage++;
      // Get current language from theme provider
      final themeState = ref.read(themeNotifierProvider);
      final currentLanguage = themeState.currentLanguage;

      final response = await ref.read(newsServiceProvider).getNews(
        page: _currentPage,
        currentLanguage: currentLanguage,
      );

      final currentNews = ref.read(newsNotifierProvider).value ?? [];

      if (mounted) {
        setState(() {
          ref.read(newsNotifierProvider.notifier)
              .replaceItems([...currentNews, ...response.items]);
          _hasMoreData = response.pagination.currentPage < response.pagination.totalPages;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentPage--; // Revert page increment on error
          _isLoadingMore = false;
          _error = e; // Store the error for display
        });
      }
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _error = null; // Clear any errors when refreshing
    });
    _loadFirstPage();
    return Future.value();
  }

  // Toggle search visibility
  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (!_isSearchVisible) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  // Perform search
  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  // Clear search
  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
    });
  }

  // Filter news based on search query
  List<NewsItem> _filterNews(List<NewsItem> news, String query) {
    if (query.isEmpty) return news;

    final lowercaseQuery = query.toLowerCase();
    return news.where((item) =>
      (item.title != null && item.title!.toLowerCase().contains(lowercaseQuery))
    ).toList();
  }

  // Sort news by date (newest first)
  List<NewsItem> _sortNewsByDate(List<NewsItem> news) {
    // Make a copy to avoid modifying the original list
    final sortedNews = List<NewsItem>.from(news);

    // Sort the news by date, putting newest first
    sortedNews.sort((a, b) {
      if (a.date == null) return 1; // null dates go to the end
      if (b.date == null) return -1; // null dates go to the end

      // Compare dates (assuming format is sortable, typically ISO format)
      // Reverse comparison to get descending order (newest first)
      return b.date!.compareTo(a.date!); // Handle potential null dates
    });

    return sortedNews;
  }

  // Scroll to the top of the list
  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final newsState = ref.watch(newsNotifierProvider);
    final isConnected = ref.watch(isConnectedProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Determine text direction based on current language
    final isRTL = ref.watch(themeNotifierProvider).currentLanguage != 'english';
    final textDirection = isRTL ? TextDirection.rtl : TextDirection.ltr;

    // If we have a specific error from our loading attempts, show that first
    if (_error != null) {
      return Directionality(
        textDirection: textDirection,
        child: Scaffold(
          appBar: AppBar(
            title: Text(_getText(context, 'newsTitle')),
            backgroundColor: AppConstants.primaryColor,
            centerTitle: true,
          ),
          body: ErrorDisplay(
            error: _error,
            onRetry: _refreshData,
          ),
        ),
      );
    }

    // Show no connection message if disconnected
    if (!isConnected) {
      return Directionality(
        textDirection: textDirection,
        child: Scaffold(
          appBar: AppBar(
            title: Text(_getText(context, 'newsTitle')),
            backgroundColor: AppConstants.primaryColor,
            centerTitle: true,
          ),
          body: ErrorDisplay(
            error: ApiException(
              message: _getText(context, 'noConnection'),
              code: 'no_connection',
            ),
            onRetry: _refreshData,
          ),
        ),
      );
    }

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        // Add floating action button for scroll to top
        floatingActionButton: _showScrollToTop
            ? FloatingActionButton(
                onPressed: _scrollToTop,
                mini: true,
                backgroundColor: Theme.of(context).primaryColor,
                child: const Icon(
                  Icons.arrow_upward,
                  color: Colors.white,
                ),
              )
            : null,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                title: _isSearchVisible
                  ? SearchBarWidget(
                      hintText: _getText(context, 'searchNewsHint'),
                      onSearch: _performSearch,
                      onClear: _clearSearch,
                      controller: _searchController,
                      autofocus: true,
                      showBorder: false,
                      backgroundColor: Colors.transparent,
                      margin: EdgeInsets.zero,
                    )
                  : Text(
                      _getText(context, 'newsTitle'), // Localized title
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.white,
                      ),
                    ),
                centerTitle: true,
                floating: true,
                pinned: true,
                elevation: 0,
                backgroundColor: AppConstants.primaryColor,
                shadowColor: Colors.transparent,
                leading: _isSearchVisible
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: _toggleSearch,
                    )
                  : Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(51), // 0.2 opacity = 51/255
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          size: 20,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(50),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor,
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withAlpha(26), // 0.1 opacity = 26/255
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      padding: EdgeInsets.zero,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white.withAlpha(153), // 0.6 opacity = 153/255
                      indicatorColor: Colors.white,
                      indicatorWeight: 3,
                      indicatorSize: TabBarIndicatorSize.label,
                      // Generate tabs using localized keys
                      tabs: _categoryKeys.map((key) => Tab(
                        text: _getText(context, key),
                        height: 46,
                      )).toList(),
                      tabAlignment: TabAlignment.start,
                    ),
                  ),
                ),
                actions: [
                  if (_isSearchVisible && _searchController.text.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(51), // 0.2 opacity = 51/255
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.clear, size: 20, color: Colors.white),
                        tooltip: _getText(context, 'clearSearch'), // Localized tooltip
                        onPressed: _clearSearch,
                      ),
                    ),
                  if (!_isSearchVisible)
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      tooltip: _getText(context, 'search'),
                      onPressed: _toggleSearch,
                    ),
                ],
              ),
            ];
          },
          body: Container(
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Theme.of(context).scaffoldBackgroundColor
                  : Colors.grey.shade100,
            ),
            child: Column(
              children: [
                // Search results indicator
                if (_isSearchVisible && _searchQuery.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                    child: Row(
                      children: [
                        Text(
                          '${_getText(context, 'searchLabel')} "$_searchQuery"', // Localized label
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: _clearSearch, // Localized button text
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            visualDensity: VisualDensity.compact,
                          ),
                          child: Text(_getText(context, 'clearSearchButton')),
                        ),
                      ],
                    ),
                  ),
                // News TabBarView
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: List.generate(_categoryKeys.length, (tabIndex) {
                      return newsState.when(
                        data: (news) {
                          // Apply search filter if search query exists
                          final displayedNews = _searchQuery.isNotEmpty
                              ? _filterNews(news, _searchQuery)
                              : news;

                          if (displayedNews.isEmpty) {
                            return _searchQuery.isNotEmpty
                                ? _buildEmptySearchResults()
                                : _buildEmptyState();
                          }

                          // Sort all news by date (newest first)
                          final sortedNews = _sortNewsByDate(displayedNews);

                          // For "Latest News" tab, show only latest 10 news (unless searching)
                          // Use the key for comparison
                          if (_categoryKeys[tabIndex] == 'newsTabsLatest' && _searchQuery.isEmpty) {
                            final latestNews = sortedNews.take(10).toList();

                            return RefreshIndicator(
                              onRefresh: _refreshData,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(12),
                                itemCount: latestNews.length,
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final newsItem = latestNews[index];
                                  return _buildNewsCard(newsItem, index);
                                },
                              ),
                            );
                          }

                          return RefreshIndicator(
                            onRefresh: _refreshData,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(12),
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: sortedNews.length + (_hasMoreData && _searchQuery.isEmpty ? 1 : 0),
                              itemBuilder: (context, index) {
                                // Show loading indicator at the end (only when not searching)
                                if (index == sortedNews.length && _searchQuery.isEmpty) {
                                  return _buildLoadingMoreIndicator();
                                }

                                final newsItem = sortedNews[index];
                                return _buildNewsCard(newsItem, index);
                              },
                            ),
                          );
                        },
                        loading: () => _buildLoadingShimmer(),
                        error: (error, stackTrace) => ErrorDisplay(
                          error: error,
                          onRetry: _refreshData,
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.newspaper,
            size: 64,
            color: AppConstants.primaryColor.withAlpha(179), // 0.7 opacity = 179/255
          ),
          const SizedBox(height: 16),
          Text(
            _getText(context, 'noNews'),
            style: const TextStyle(
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView(
      padding: const EdgeInsets.all(12),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        // Add circular progress indicator at the top
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 30),
          alignment: Alignment.center,
          child: const CircularProgressIndicator(),
        ),
        // Regular news item shimmers
        ...List.generate(
          5,
          (index) => Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 110,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewsCard(NewsItem newsItem, int index) {
    final isRTL = ref.watch(themeNotifierProvider).currentLanguage != 'english';

    return InfoCard(
      title: newsItem.title ?? _getText(context, 'noTitle'),
      subtitle: newsItem.date ?? _getText(context, 'noDate'),
      imageUrl: newsItem.image,
      isRTL: isRTL,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => NewsDetailScreen(newsId: newsItem.id),
          ),
        );
      },
    );
  }


  // New method for empty search results with localized text
  Widget _buildEmptySearchResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppConstants.primaryColor.withAlpha(179), // 0.7 opacity = 179/255
          ),
          const SizedBox(height: 16),
          Text(
            _getText(context, 'emptySearchResult').replaceAll('{query}', _searchQuery),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          if (_searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: ElevatedButton(
                onPressed: _clearSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Text(_getText(context, 'clearSearchButton')),
              ),
            ),
        ],
      ),
    );
  }
}