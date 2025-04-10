import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/news_model.dart';
import '../services/news_service.dart';

class NewsNotifier extends StateNotifier<AsyncValue<List<NewsItem>>> {
  final NewsService _newsService;
  int _currentPage = 1;
  bool _hasMore = true;

  NewsNotifier(this._newsService) : super(const AsyncLoading());

  Future<void> loadInitial() async {
    state = const AsyncLoading();
    try {
      final response = await _newsService.getNews(page: 1);
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
    state = AsyncLoading<List<NewsItem>>();
    
    try {
      _currentPage++;
      final response = await _newsService.getNews(page: _currentPage);
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
      final response = await _newsService.getNews(page: 1);
      _hasMore = response.pagination.currentPage < response.pagination.totalPages;
      state = AsyncData(response.items);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final newsNotifierProvider = StateNotifierProvider<NewsNotifier, AsyncValue<List<NewsItem>>>((ref) {
  final newsService = ref.read(newsServiceProvider);
  return NewsNotifier(newsService)..loadInitial();
});

// Simple provider to fetch news data for a specific page
final newsDataProvider = FutureProvider.family<NewsResponse, int>((ref, page) {
  final newsService = ref.read(newsServiceProvider);
  return newsService.getNews(page: page);
});

// Provider for fetching a specific news detail
final newsDetailProvider = FutureProvider.family<NewsDetail, int>((ref, newsId) {
  final newsService = ref.read(newsServiceProvider);
  return newsService.getNewsDetail(newsId);
}); 