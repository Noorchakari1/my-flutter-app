import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/independent_directorate_model.dart';
import '../services/independent_directorate_service.dart';
import '../../../../core/providers/theme_provider.dart';

class IndependentDirectorateNotifier extends StateNotifier<AsyncValue<List<IndependentDirectorateItem>>> {
  final IndependentDirectorateService _directorateService;
  final Ref _ref;
  int _currentPage = 1;
  bool _hasMore = true;

  IndependentDirectorateNotifier(this._directorateService, this._ref) : super(const AsyncLoading());

  Future<void> loadInitial() async {
    state = const AsyncLoading();
    try {
      final currentLanguage = _ref.read(themeNotifierProvider).currentLanguage;
      final response = await _directorateService.getIndependentDirectorates(
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
    state = AsyncLoading<List<IndependentDirectorateItem>>();
    
    try {
      _currentPage++;
      final currentLanguage = _ref.read(themeNotifierProvider).currentLanguage;
      final response = await _directorateService.getIndependentDirectorates(
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
  void replaceItems(List<IndependentDirectorateItem> items) {
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
      final response = await _directorateService.getIndependentDirectorates(
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
  Future<void> searchDirectorates(String query) async {
    if (query.isEmpty) {
      return refresh();
    }
    
    state = const AsyncLoading();
    
    try {
      // Try API search first
      final currentLanguage = _ref.read(themeNotifierProvider).currentLanguage;
      final response = await _directorateService.searchIndependentDirectorates(
        query,
        currentLanguage: currentLanguage
      );
      state = AsyncData(response.items);
    } catch (e) {
      // If API search fails, try local search
      try {
        final currentLanguage = _ref.read(themeNotifierProvider).currentLanguage;
        final currentState = await _directorateService.getIndependentDirectorates(currentLanguage: currentLanguage);
        final searchResults = await _directorateService.searchIndependentDirectoratesLocally(query, currentState.items);
        state = AsyncData(searchResults);
      } catch (e, st) {
        state = AsyncError(e, st);
      }
    }
  }
}

final independentDirectorateNotifierProvider = StateNotifierProvider<IndependentDirectorateNotifier, AsyncValue<List<IndependentDirectorateItem>>>((ref) {
  final directorateService = ref.read(independentDirectorateServiceProvider);
  return IndependentDirectorateNotifier(directorateService, ref)..loadInitial();
});

// Simple provider to fetch directorate data for a specific page
final independentDirectorateDataProvider = FutureProvider.family<IndependentDirectorateResponse, int>((ref, page) {
  final directorateService = ref.read(independentDirectorateServiceProvider);
  final currentLanguage = ref.read(themeNotifierProvider).currentLanguage;
  return directorateService.getIndependentDirectorates(page: page, currentLanguage: currentLanguage);
});

// Provider for searching directorates
final independentDirectorateSearchProvider = StateProvider<String>((ref) => '');

// Provider for the search results
final independentDirectorateSearchResultsProvider = FutureProvider<List<IndependentDirectorateItem>>((ref) {
  final searchQuery = ref.watch(independentDirectorateSearchProvider);
  
  if (searchQuery.isEmpty) {
    // Return empty list if no search query
    return Future.value([]);
  }
  
  final directorateService = ref.read(independentDirectorateServiceProvider);
  final currentLanguage = ref.read(themeNotifierProvider).currentLanguage;
  
  // Try API search first, then fall back to local if needed
  return directorateService.searchIndependentDirectorates(searchQuery, currentLanguage: currentLanguage).then(
    (response) => response.items,
    onError: (error) async {
      // Fall back to local search
      final allDirectorates = await directorateService.getIndependentDirectorates(currentLanguage: currentLanguage);
      return directorateService.searchIndependentDirectoratesLocally(searchQuery, allDirectorates.items);
    }
  );
});

// Provider for fetching a specific directorate detail
final independentDirectorateDetailProvider = FutureProvider.family<IndependentDirectorateItem, int>((ref, directorateId) {
  final directorateService = ref.read(independentDirectorateServiceProvider);
  final currentLanguage = ref.read(themeNotifierProvider).currentLanguage;
  return directorateService.getIndependentDirectorateDetail(directorateId, currentLanguage: currentLanguage);
}); 