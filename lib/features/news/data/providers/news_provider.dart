import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/theme_provider.dart';
import '../models/news_model.dart';
import '../services/news_service.dart';

class NewsNotifier extends StateNotifier<AsyncValue<List<NewsItem>>> {
  final NewsService _newsService;
  final Ref _ref;
  int _currentPage = 1;
  bool _hasMore = true;

  NewsNotifier(this._newsService, this._ref) : super(const AsyncLoading());

  Future<void> loadInitial() async {
    state = const AsyncLoading();
    try {
      final currentLanguage = _ref.read(themeNotifierProvider).currentLanguage;
      final response = await _newsService.getNews(
        page: 1, 
        currentLanguage: currentLanguage
      );
      _currentPage = 1;
      _hasMore = response.pagination.currentPage < response.pagination.totalPages;
      state = AsyncData(response.items);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || state is AsyncLoading) return;
    
    final currentItems = state.value ?? [];
    state = const AsyncLoading<List<NewsItem>>();
    
    try {
      _currentPage++;
      final currentLanguage = _ref.read(themeNotifierProvider).currentLanguage;
      final response = await _newsService.getNews(
        page: _currentPage,
        currentLanguage: currentLanguage
      );
      _hasMore = response.pagination.currentPage < response.pagination.totalPages;
      
      state = AsyncData([...currentItems, ...response.items]);
    } catch (e, st) {
      _currentPage--; // Revert page increment on error
      state = AsyncError(e, st);
    }
  }

  // Add a method to replace items (for pagination)
  void replaceItems(List<NewsItem> items) {
    // If we're already in an error state, keep it
    if (state is AsyncError) return;
    
    // Otherwise replace the items
    state = AsyncData(items);
  }

  Future<void> refresh() async {
    _currentPage = 1;
    _hasMore = true;
    state = const AsyncLoading();
    
    try {
      final currentLanguage = _ref.read(themeNotifierProvider).currentLanguage;
      final response = await _newsService.getNews(
        page: 1,
        currentLanguage: currentLanguage
      );
      _hasMore = response.pagination.currentPage < response.pagination.totalPages;
      state = AsyncData(response.items);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
  
  // Search functionality - will try API search first, fallback to local search
  Future<void> searchNews(String query) async {
    if (query.isEmpty) {
      return refresh();
    }
    
    state = const AsyncLoading();
    
    try {
      // Try API search first
      final currentLanguage = _ref.read(themeNotifierProvider).currentLanguage;
      final response = await _newsService.searchNews(
        query,
        currentLanguage: currentLanguage
      );
      state = AsyncData(response.items);
    } catch (e) {
      // If API search fails, try local search
      try {
        final currentLanguage = _ref.read(themeNotifierProvider).currentLanguage;
        final currentState = await _newsService.getNews(currentLanguage: currentLanguage);
        final searchResults = await _newsService.searchNewsLocally(query, currentState.items);
        state = AsyncData(searchResults);
      } catch (e, st) {
        state = AsyncError(e, st);
      }
    }
  }
}

final newsNotifierProvider = StateNotifierProvider<NewsNotifier, AsyncValue<List<NewsItem>>>((ref) {
  final newsService = ref.read(newsServiceProvider);
  return NewsNotifier(newsService, ref)..loadInitial();
});

// Simple provider to fetch news data for a specific page
final newsDataProvider = FutureProvider.family<NewsResponse, int>((ref, page) {
  final newsService = ref.read(newsServiceProvider);
  final currentLanguage = ref.read(themeNotifierProvider).currentLanguage;
  return newsService.getNews(page: page, currentLanguage: currentLanguage);
});

// Provider for searching news
final newsSearchProvider = StateProvider<String>((ref) => '');

// Provider for the search results
final searchResultsProvider = FutureProvider<List<NewsItem>>((ref) {
  final searchQuery = ref.watch(newsSearchProvider);
  
  if (searchQuery.isEmpty) {
    // Return empty list if no search query
    return Future.value([]);
  }
  
  final newsService = ref.read(newsServiceProvider);
  final currentLanguage = ref.read(themeNotifierProvider).currentLanguage;
  
  // Try API search first, then fall back to local if needed
  return newsService.searchNews(searchQuery, currentLanguage: currentLanguage).then(
    (response) => response.items,
    onError: (error) async {
      // Fall back to local search
      final allNews = await newsService.getNews(currentLanguage: currentLanguage);
      return newsService.searchNewsLocally(searchQuery, allNews.items);
    }
  );
});

// Provider for fetching a specific news detail
final newsDetailProvider = FutureProvider.family<NewsDetail, int>((ref, newsId) {
  final newsService = ref.read(newsServiceProvider);
  final currentLanguage = ref.read(themeNotifierProvider).currentLanguage;
  return newsService.getNewsDetail(newsId, currentLanguage: currentLanguage);
}); 