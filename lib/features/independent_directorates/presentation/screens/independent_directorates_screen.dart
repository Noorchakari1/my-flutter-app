import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/services/api_exception.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/widgets/error_display.dart';
import '../../../../shared/widgets/info_card.dart';
import '../../../../shared/widgets/search_bar_widget.dart';
import '../../data/models/independent_directorate_model.dart';
import '../../data/providers/independent_directorate_provider.dart';
import '../../data/services/independent_directorate_service.dart';
import 'independent_directorate_detail_screen.dart';

class IndependentDirectoratesScreen extends ConsumerStatefulWidget {
  const IndependentDirectoratesScreen({super.key});

  @override
  ConsumerState<IndependentDirectoratesScreen> createState() => _IndependentDirectoratesScreenState();
}

class _IndependentDirectoratesScreenState extends ConsumerState<IndependentDirectoratesScreen> {
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

      final response = await ref.read(independentDirectorateServiceProvider).getIndependentDirectorates(
        page: _currentPage,
        currentLanguage: currentLanguage,
      );

      if (mounted) {
        setState(() {
          ref.read(independentDirectorateNotifierProvider.notifier).replaceItems(response.items);
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

      final response = await ref.read(independentDirectorateServiceProvider).getIndependentDirectorates(
        page: _currentPage,
        currentLanguage: currentLanguage,
      );

      final currentDirectorates = ref.read(independentDirectorateNotifierProvider).value ?? [];

      if (mounted) {
        setState(() {
          ref.read(independentDirectorateNotifierProvider.notifier)
              .replaceItems([...currentDirectorates, ...response.items]);
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
        // Clear search
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
      ref.read(independentDirectorateNotifierProvider.notifier).searchDirectorates(query);
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

  // Filter directorates based on search query
  List<IndependentDirectorateItem> _filterDirectorates(List<IndependentDirectorateItem> directorates, String query) {
    if (query.isEmpty) return directorates;

    final lowercaseQuery = query.toLowerCase();
    return directorates.where((item) =>
      (item.title != null && item.title!.toLowerCase().contains(lowercaseQuery))
    ).toList();
  }

  // Helper function to strip HTML tags from content

  // Launch directorate website

  // Scroll to top

  @override
  Widget build(BuildContext context) {
    final directorateState = ref.watch(independentDirectorateNotifierProvider);
    final isConnected = ref.watch(isConnectedProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearchVisible
          ? _buildSearchField()
          : Text(_getText(context, 'independentDirectorates')),
        backgroundColor: AppConstants.primaryColor,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isSearchVisible ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: _buildBody(directorateState, isConnected),
      floatingActionButton: _showScrollToTop
        ? FloatingActionButton(
            backgroundColor: AppConstants.primaryColor,
            child: const Icon(Icons.arrow_upward, color: Colors.white),
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

  Widget _buildBody(AsyncValue<List<IndependentDirectorateItem>> directorateState, bool isConnected) {
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
    return directorateState.when(
      data: (directorates) {
        // Show search results if there's a search query
        final displayedDirectorates = _searchQuery.isNotEmpty
            ? _filterDirectorates(directorates, _searchQuery)
            : directorates;

        if (displayedDirectorates.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: AppConstants.primaryColor.withAlpha(179),
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isNotEmpty
                    ? _getText(context, 'emptySearchResult').replaceAll('{query}', _searchQuery)
                    : _getText(context, 'noDirectorates'),
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
            itemCount: displayedDirectorates.length + (_isLoadingMore && _hasMoreData ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == displayedDirectorates.length) {
                return _buildLoadingIndicator();
              }
              return _buildDirectorateCard(displayedDirectorates[index]);
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
            color: Colors.black.withAlpha(13),
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
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
            onPressed: _toggleSearch,
          ),
          Expanded(
            child: SearchBarWidget(
              hintText: _getText(context, 'searchDirectorates'),
              onSearch: _performSearch,
              onClear: _clearSearch,
              controller: _searchController,
              autofocus: true,
              showBorder: false,
              backgroundColor: Colors.transparent,
              margin: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectorateCard(IndependentDirectorateItem directorate) {
    final isRTL = ref.watch(themeNotifierProvider).currentLanguage != 'english';

    return InfoCard(
      title: directorate.title ?? _getText(context, 'directorate'),
      subtitle: directorate.phone,
      imageUrl: directorate.image,
      isRTL: isRTL,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => IndependentDirectorateDetailScreen(
              directorateId: directorate.id,
              language: ref.read(themeNotifierProvider).currentLanguage,
            ),
          ),
        );
      },
    );
  }
}
