import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../core/services/api_exception.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/widgets/error_display.dart';
import '../../data/models/province_model.dart';
import '../../data/services/province_service.dart';
import '../../data/providers/province_provider.dart';
import 'province_detail_screen.dart';

class ProvincesScreen extends ConsumerStatefulWidget {
  const ProvincesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProvincesScreen> createState() => _ProvincesScreenState();
}

class _ProvincesScreenState extends ConsumerState<ProvincesScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
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
    _scrollController.addListener(_scrollListener);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFirstPage();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
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
      
      final response = await ref.read(provinceServiceProvider).getProvinces(
        page: _currentPage,
        currentLanguage: currentLanguage,
      );
      
      if (mounted) {
        setState(() {
          ref.read(provinceNotifierProvider.notifier).replaceItems(response.items);
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
      
      final response = await ref.read(provinceServiceProvider).getProvinces(
        page: _currentPage,
        currentLanguage: currentLanguage,
      );
      
      final currentProvinces = ref.read(provinceNotifierProvider).value ?? [];
      
      if (mounted) {
        setState(() {
          ref.read(provinceNotifierProvider.notifier)
              .replaceItems([...currentProvinces, ...response.items]);
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
        _refreshData();
      }
    });
  }
  
  // Perform search
  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
    
    if (query.isEmpty) {
      _refreshData();
    } else {
      ref.read(provinceNotifierProvider.notifier).searchProvinces(query);
    }
  }
  
  // Clear search
  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _refreshData();
    });
  }
  
  // Filter provinces based on search query
  List<ProvinceItem> _filterProvinces(List<ProvinceItem> provinces, String query) {
    if (query.isEmpty) return provinces;
    
    final lowercaseQuery = query.toLowerCase();
    return provinces.where((item) => 
      (item.title != null && item.title!.toLowerCase().contains(lowercaseQuery))
    ).toList();
  }
  
  // Helper function to strip HTML tags from content
  String _stripHtmlTags(String htmlString) {
    // Basic HTML tag removal for search purposes
    return htmlString
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
  }
  
  // Launch province website
  Future<void> _launchURL(String? url) async {
    if (url == null || url.isEmpty) return;
    
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Don't show snackbar for URL launch failures
      if (mounted) {
        setState(() {
          _error = ApiException(
            message: _getText(context, 'cannotOpenWebsite').replaceAll('{url}', url),
            code: 'url_launch_failed',
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provinceState = ref.watch(provinceNotifierProvider);
    final isConnected = ref.watch(isConnectedProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: _isSearchVisible
          ? _buildSearchField()
          : Text(_getText(context, 'provinces')),
        backgroundColor: AppConstants.primaryColor,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isSearchVisible ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: _buildBody(provinceState, isConnected),
      floatingActionButton: _showScrollToTop
        ? FloatingActionButton(
            backgroundColor: AppConstants.primaryColor,
            child: const Icon(Icons.arrow_upward),
            onPressed: () {
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            },
          )
        : null,
    );
  }
  
  Widget _buildBody(AsyncValue<List<ProvinceItem>> provinceState, bool isConnected) {
    // If we have a specific error from our loading attempts, show that first
    if (_error != null) {
      return ErrorDisplay(
        error: _error,
        onRetry: _refreshData,
      );
    }
    
    // Show no connection message if disconnected
    if (!isConnected) {
      return ErrorDisplay(
        error: ApiException(
          message: _getText(context, 'noConnection'),
          code: 'no_connection',
        ),
        onRetry: _refreshData,
      );
    }
    
    // Handle various states from the provider
    return provinceState.when(
      data: (provinces) {
        // Show search results if there's a search query
        final displayedProvinces = _searchQuery.isNotEmpty 
            ? _filterProvinces(provinces, _searchQuery) 
            : provinces;
            
        if (displayedProvinces.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: AppConstants.primaryColor.withOpacity(0.7),
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isNotEmpty
                    ? _getText(context, 'emptySearchResult').replaceAll('{query}', _searchQuery)
                    : _getText(context, 'noProvinces'),
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
        
        return RefreshIndicator(
          onRefresh: _refreshData,
          color: AppConstants.primaryColor,
          child: ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: displayedProvinces.length + (_isLoadingMore && _hasMoreData ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == displayedProvinces.length) {
                return _buildLoadingIndicator();
              }
              return _buildProvinceCard(displayedProvinces[index]);
            },
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => ErrorDisplay(
        error: error,
        onRetry: _refreshData,
      ),
    );
  }
  
  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }
  
  Widget _buildSearchField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).textTheme.bodyMedium?.color,
              size: 20,
            ),
            onPressed: _toggleSearch,
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: _getText(context, 'searchProvinces'),
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              textDirection: TextDirection.rtl,
              onChanged: _performSearch,
              autofocus: true,
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.clear,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                size: 20,
              ),
              onPressed: _clearSearch,
            ),
        ],
      ),
    );
  }
  
  Widget _buildProvinceCard(ProvinceItem province) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProvinceDetailScreen(
              provinceId: province.id,
              language: ref.read(themeNotifierProvider).currentLanguage,
            ),
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
              child: province.image != null && province.image!.isNotEmpty 
                ? CachedNetworkImage(
                    imageUrl: province.image!,
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
                        Icons.location_city,
                        size: 32,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : Container(
                    height: 110,
                    width: 110,
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.location_city,
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
                      province.title ?? _getText(context, 'province'),
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
                    // Show website link or phone if available
                    Row(
                      children: [
                        if (province.phone != null && province.phone!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDarkMode 
                                  ? Colors.blue.withOpacity(0.2) 
                                  : Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.phone, 
                                  size: 14, 
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  province.phone!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(width: 8),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _getText(context, 'viewDetails'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 12,
                                color: Colors.white,
                              ),
                            ],
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
} 