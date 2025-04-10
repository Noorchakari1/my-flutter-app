import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../data/models/news_model.dart';
import '../../data/providers/news_provider.dart';
import '../../data/services/news_service.dart';
import 'package:flutter_html/flutter_html.dart';
import 'news_detail_screen.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../shared/constants/app_constants.dart'; // Import AppConstants

class NewsScreen extends ConsumerStatefulWidget {
  const NewsScreen({Key? key}) : super(key: key);

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
    'newsTabsSocial',
    'newsTabsEconomic',
    'newsTabsPolitical',
    'newsTabsCultural'
  ];
  int _currentPage = 1;
  bool _hasMoreData = true;
  
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
    setState(() {
      _isLoadingMore = true;
      _currentPage = 1;
      _hasMoreData = true;
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
          _isLoadingMore = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در بارگیری اخبار: ${e.toString()}')),
        );
      }
    }
  }
  
  Future<void> _loadNextPage() async {
    if (_isLoadingMore || !_hasMoreData) return;
    
    setState(() {
      _isLoadingMore = true;
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
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در بارگیری اخبار بیشتر: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _refreshData() async {
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
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
                ? TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: _getText(context, 'searchNewsHint'), // Localized hint
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    onChanged: _performSearch,
                    autofocus: true,
                  )
                : Text(
                    _getText(context, 'newsTitle'), // Localized title
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
              centerTitle: true,
              floating: true,
              pinned: true,
              elevation: 0,
              backgroundColor: isDarkMode 
                  ? Theme.of(context).appBarTheme.backgroundColor 
                  : Colors.white,
              shadowColor: Colors.transparent,
              leading: _isSearchVisible
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _toggleSearch,
                  )
                : null,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: isDarkMode 
                        ? Theme.of(context).appBarTheme.backgroundColor 
                        : Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: isDarkMode 
                            ? Colors.grey.shade800 
                            : Colors.grey.shade200,
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      padding: EdgeInsets.zero,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                      labelColor: Theme.of(context).primaryColor,
                      unselectedLabelColor: isDarkMode 
                          ? Colors.grey.shade400 
                          : Colors.grey.shade600,
                      indicatorColor: Theme.of(context).primaryColor,
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
              ),
              actions: [
                if (_isSearchVisible && _searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: _getText(context, 'clearSearch'), // Localized tooltip
                    onPressed: _clearSearch,
                  ),
                IconButton(
                  icon: Icon(_isSearchVisible ? Icons.search_off : Icons.search),
                  tooltip: _getText(context, 'searchNewsHint'), // Localized tooltip
                  onPressed: _toggleSearch,
                ),
              ],
            ),
          ];
        },
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode 
                  ? Theme.of(context).scaffoldBackgroundColor 
                  : Colors.grey.shade100,
            ),
            child: Column(
              children: [
                // Prominent search button (only visible when search is not active)
                if (!_isSearchVisible)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: _toggleSearch,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                              size: 18,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _getText(context, 'searchNewsHint'), // Localized hint
                              style: TextStyle(
                                fontSize: 14,
                                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
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
                          onPressed: _clearSearch,
                          child: Text(_getText(context, 'clearSearchButton')), // Localized button text
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            visualDensity: VisualDensity.compact,
                          ),
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
                            
                            return ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: latestNews.length,
                              itemBuilder: (context, index) {
                                final newsItem = latestNews[index];
                                return _buildNewsCard(newsItem, index);
                              },
                            ); 
                          }
                          
                          return ListView.builder(
                            padding: const EdgeInsets.all(12),
                            controller: _scrollController,
                            itemCount: sortedNews.length + (_hasMoreData && _searchQuery.isEmpty ? 1 : 0),
                            itemBuilder: (context, index) {
                              // Show loading indicator at the end (only when not searching)
                              if (index == sortedNews.length && _searchQuery.isEmpty) {
                                return _buildLoadingMoreIndicator();
                              }
                              
                              final newsItem = sortedNews[index];
                              return _buildNewsCard(newsItem, index);
                            },
                          );
                        },
                        loading: () => _buildLoadingShimmer(),
                        error: (error, stackTrace) => _buildErrorState(error),
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
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'هیچ خبری وجود ندارد',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'به زودی خبرهای جدید اضافه خواهند شد',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'خطا در بارگیری اخبار',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
            label: const Text('تلاش مجدد'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => NewsDetailScreen(newsId: newsItem.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: newsItem.image != null && newsItem.image!.isNotEmpty 
                ? CachedNetworkImage(
                    imageUrl: newsItem.image!,
                    height: 110,
                    width: 110,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        color: Colors.white,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(
                        Icons.error_outline,
                        size: 24,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : Container(
                    height: 110,
                    width: 110,
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      size: 32,
                      color: Colors.grey,
                    ),
                  ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      newsItem.title ?? 'بدون عنوان',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                      textDirection: TextDirection.rtl,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      newsItem.date ?? 'تاریخ نامشخص',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatDate(String date) {
    // Format date string if needed
    return date;
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
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _getText(context, 'emptySearchResult').replaceAll('{query}', _searchQuery), // Localized text with query
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _getText(context, 'emptySearchSuggestion'), // Localized suggestion
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _clearSearch,
            child: Text(_getText(context, 'clearSearchButton')), // Localized button text
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }
} 