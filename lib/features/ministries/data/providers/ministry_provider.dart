import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ministry_model.dart';
import '../services/ministry_service.dart';
import '../../../../core/providers/theme_provider.dart';

class MinistryNotifier extends StateNotifier<AsyncValue<List<MinistryItem>>> {
  final MinistryService _ministryService;
  final Ref _ref;
  int _currentPage = 1;
  bool _hasMore = true;

  MinistryNotifier(this._ministryService, this._ref) : super(const AsyncLoading());

  Future<void> loadInitial() async {
    state = const AsyncLoading();
    try {
      final currentLanguage = _ref.read(themeNotifierProvider).currentLanguage;
      final response = await _ministryService.getMinistries(
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
    state = const AsyncLoading<List<MinistryItem>>();
    
    try {
      _currentPage++;
      final currentLanguage = _ref.read(themeNotifierProvider).currentLanguage;
      final response = await _ministryService.getMinistries(
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

  // Method to replace items (for pagination)
  void replaceItems(List<MinistryItem> items) {
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
      final response = await _ministryService.getMinistries(
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
  Future<void> searchMinistries(String query) async {
    if (query.isEmpty) {
      return refresh();
    }
    
    state = const AsyncLoading();
    
    try {
      // Try API search first
      final currentLanguage = _ref.read(themeNotifierProvider).currentLanguage;
      final response = await _ministryService.searchMinistries(
        query,
        currentLanguage: currentLanguage
      );
      state = AsyncData(response.items);
    } catch (e) {
      // If API search fails, try local search
      try {
        final currentLanguage = _ref.read(themeNotifierProvider).currentLanguage;
        final currentState = await _ministryService.getMinistries(currentLanguage: currentLanguage);
        final searchResults = await _ministryService.searchMinistriesLocally(query, currentState.items);
        state = AsyncData(searchResults);
      } catch (e, st) {
        state = AsyncError(e, st);
      }
    }
  }
}

final ministryNotifierProvider = StateNotifierProvider<MinistryNotifier, AsyncValue<List<MinistryItem>>>((ref) {
  final ministryService = ref.read(ministryServiceProvider);
  return MinistryNotifier(ministryService, ref)..loadInitial();
});

// Simple provider to fetch ministry data for a specific page
final ministryDataProvider = FutureProvider.family<MinistryResponse, int>((ref, page) {
  final ministryService = ref.read(ministryServiceProvider);
  final currentLanguage = ref.read(themeNotifierProvider).currentLanguage;
  return ministryService.getMinistries(page: page, currentLanguage: currentLanguage);
});

// Provider for searching ministries
final ministrySearchProvider = StateProvider<String>((ref) => '');

// Provider for the search results
final ministrySearchResultsProvider = FutureProvider<List<MinistryItem>>((ref) {
  final searchQuery = ref.watch(ministrySearchProvider);
  
  if (searchQuery.isEmpty) {
    // Return empty list if no search query
    return Future.value([]);
  }
  
  final ministryService = ref.read(ministryServiceProvider);
  final currentLanguage = ref.read(themeNotifierProvider).currentLanguage;
  
  // Try API search first, then fall back to local if needed
  return ministryService.searchMinistries(searchQuery, currentLanguage: currentLanguage).then(
    (response) => response.items,
    onError: (error) async {
      // Fall back to local search
      final allMinistries = await ministryService.getMinistries(currentLanguage: currentLanguage);
      return ministryService.searchMinistriesLocally(searchQuery, allMinistries.items);
    }
  );
});

// Provider for fetching a specific ministry detail
final ministryDetailProvider = FutureProvider.family<MinistryItem, int>((ref, ministryId) {
  final ministryService = ref.read(ministryServiceProvider);
  final currentLanguage = ref.read(themeNotifierProvider).currentLanguage;
  return ministryService.getMinistryDetail(ministryId, currentLanguage: currentLanguage);
}); 