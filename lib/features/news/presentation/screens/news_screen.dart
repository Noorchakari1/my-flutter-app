import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../data/models/news_model.dart';
import '../../data/providers/news_provider.dart';
import '../../data/services/news_service.dart';
import 'package:flutter_html/flutter_html.dart';
import 'news_detail_screen.dart';

class NewsScreen extends ConsumerStatefulWidget {
  const NewsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends ConsumerState<NewsScreen> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  late TabController _tabController;
  final List<String> _categories = ['همه', 'سیاسی', 'اقتصادی', 'اجتماعی', 'فرهنگی'];
  int _currentPage = 1;
  bool _hasMoreData = true;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
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
    super.dispose();
  }
  
  void _scrollListener() {
    if (!_scrollController.hasClients) return;
    
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    
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
      final response = await ref.read(newsServiceProvider).getNews(page: _currentPage);
      
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
      final response = await ref.read(newsServiceProvider).getNews(page: _currentPage);
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

  @override
  Widget build(BuildContext context) {
    final newsState = ref.watch(newsNotifierProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: const Text(
                'اخبار', 
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
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
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
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: isDarkMode 
                        ? Colors.grey.shade400 
                        : Colors.grey.shade600,
                    indicatorColor: Theme.of(context).primaryColor,
                    indicatorWeight: 3,
                    indicatorSize: TabBarIndicatorSize.label,
                    tabs: _categories.map((category) => Tab(
                      text: category,
                    )).toList(),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('قابلیت جستجو به زودی اضافه خواهد شد')),
                    );
                  },
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
            child: TabBarView(
              controller: _tabController,
              children: List.generate(_categories.length, (tabIndex) {
                return newsState.when(
                  data: (news) {
                    if (news.isEmpty) {
                      return _buildEmptyState();
                    }
                    
                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      controller: _scrollController,
                      itemCount: news.length + (_hasMoreData ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Show loading indicator at the end
                        if (index == news.length) {
                          return _buildLoadingMoreIndicator();
                        }
                        
                        final newsItem = news[index];
                        // Display featured news (first item) differently
                        if (index == 0 && tabIndex == 0) {
                          return _buildFeaturedNewsCard(newsItem);
                        }
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
        // Featured news shimmer
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 200,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        ...List.generate(
          3,
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

  // Featured news card with larger image and prominent placement
  Widget _buildFeaturedNewsCard(NewsItem newsItem) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => NewsDetailScreen(newsId: newsItem.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.grey.shade900 
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  if (newsItem.image != null && newsItem.image!.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: newsItem.image!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.error_outline,
                          size: 32,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  else
                    Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
                  // Gradient overlay for better text readability
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Featured badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.white,
                            size: 12,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'خبر ویژه',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    newsItem.title ?? 'بدون عنوان',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                    textDirection: TextDirection.rtl,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          newsItem.type ?? 'عمومی',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        newsItem.date != null ? _formatDate(newsItem.date!) : 'تاریخ نامشخص',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          newsItem.date != null ? _formatDate(newsItem.date!) : 'تاریخ نامشخص',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            newsItem.type ?? 'عمومی',
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
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
} 