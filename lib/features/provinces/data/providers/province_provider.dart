import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/theme_provider.dart';
import '../models/province_model.dart';
import '../services/province_service.dart';

class ProvinceNotifier extends StateNotifier<AsyncValue<List<ProvinceItem>>> {
  final ProvinceService _provinceService;
  final Ref _ref;
  int _currentPage = 1;
  bool _hasMore = true;

  ProvinceNotifier(this._provinceService, this._ref) : super(const AsyncLoading());

  Future<void> loadInitial() async {
    state = const AsyncLoading();
    try {
      final currentLanguage = _ref.read(themeNotifierProvider).currentLanguage;
      final response = await _provinceService.getProvinces(
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
    state = const AsyncLoading<List<ProvinceItem>>();

    try {
      _currentPage++;
      final currentLanguage = _ref.read(themeNotifierProvider).currentLanguage;
      final response = await _provinceService.getProvinces(
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
  void replaceItems(List<ProvinceItem> items) {
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
      final response = await _provinceService.getProvinces(
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
  Future<void> searchProvinces(String query) async {
    if (query.isEmpty) {
      return refresh();
    }

    state = const AsyncLoading();

    try {
      // Try API search first
      final currentLanguage = _ref.read(themeNotifierProvider).currentLanguage;
      final response = await _provinceService.searchProvinces(
        query,
        currentLanguage: currentLanguage
      );
      state = AsyncData(response.items);
    } catch (e) {
      // If API search fails, try local search
      try {
        final currentLanguage = _ref.read(themeNotifierProvider).currentLanguage;
        final currentState = await _provinceService.getProvinces(currentLanguage: currentLanguage);
        final searchResults = _provinceService.searchProvincesLocally(query, currentState.items);
        state = AsyncData(searchResults);
      } catch (e, st) {
        state = AsyncError(e, st);
      }
    }
  }
}

final provinceNotifierProvider = StateNotifierProvider<ProvinceNotifier, AsyncValue<List<ProvinceItem>>>((ref) {
  final provinceService = ref.read(provinceServiceProvider);
  return ProvinceNotifier(provinceService, ref)..loadInitial();
});

// Simple provider to fetch province data for a specific page
final provinceDataProvider = FutureProvider.family<ProvinceResponse, int>((ref, page) {
  final provinceService = ref.read(provinceServiceProvider);
  final currentLanguage = ref.read(themeNotifierProvider).currentLanguage;
  return provinceService.getProvinces(page: page, currentLanguage: currentLanguage);
});

// Provider for searching provinces
final provinceSearchProvider = StateProvider<String>((ref) => '');

// Provider for the search results
final provinceSearchResultsProvider = FutureProvider<List<ProvinceItem>>((ref) {
  final searchQuery = ref.watch(provinceSearchProvider);

  if (searchQuery.isEmpty) {
    // Return empty list if no search query
    return Future.value([]);
  }

  final provinceService = ref.read(provinceServiceProvider);
  final currentLanguage = ref.read(themeNotifierProvider).currentLanguage;

  // Try API search first, then fall back to local if needed
  return provinceService.searchProvinces(searchQuery, currentLanguage: currentLanguage).then(
    (response) => response.items,
    onError: (error) async {
      // Fall back to local search
      final allProvinces = await provinceService.getProvinces(currentLanguage: currentLanguage);
      return provinceService.searchProvincesLocally(searchQuery, allProvinces.items);
    }
  );
});

// Provider for fetching a specific province detail
final provinceDetailProvider = FutureProvider.family<ProvinceItem, int>((ref, provinceId) {
  final provinceService = ref.read(provinceServiceProvider);
  final currentLanguage = ref.read(themeNotifierProvider).currentLanguage;
  return provinceService.getProvinceDetail(provinceId, currentLanguage: currentLanguage);
});