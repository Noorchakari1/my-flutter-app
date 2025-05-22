import 'package:aop_sites/features/ministries/data/services/ministry_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_exception.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/utils/localization_helper.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/screens/base_list_screen.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/info_card.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../data/models/ministry_model.dart';
import '../../data/providers/ministry_provider.dart';
import 'ministry_detail_screen_new.dart';

class MinistriesScreenNew extends BaseListScreen<MinistryItem> {
  const MinistriesScreenNew({super.key});

  @override
  ConsumerState<MinistriesScreenNew> createState() => _MinistriesScreenNewState();
}

class _MinistriesScreenNewState extends BaseListScreenState<MinistryItem, MinistriesScreenNew> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  @override
  Future<void> loadInitialData() async {
    // First check connectivity
    final isConnected = await ref.read(connectivityServiceProvider).checkConnectivity();
    if (!isConnected) {
      setState(() {
        error = ApiException(
          message: LocalizationHelper.getText(ref, 'noConnection'),
          code: 'no_connection',
        );
        isLoadingMore = false;
      });
      return;
    }

    setState(() {
      isLoadingMore = true;
      currentPage = 1;
      hasMoreData = true;
      error = null;
    });

    try {
      // Get current language from theme provider
      final currentLanguage = LocalizationHelper.getCurrentLanguage(ref);

      final response = await ref.read(ministryServiceProvider).getMinistries(
        page: currentPage,
        currentLanguage: currentLanguage,
      );

      if (mounted) {
        setState(() {
          ref.read(ministryNotifierProvider.notifier).replaceItems(response.items);
          hasMoreData = response.pagination.currentPage < response.pagination.totalPages;
          isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e;
          isLoadingMore = false;
        });
      }
    }
  }

  @override
  Future<void> loadMoreData() async {
    if (isLoadingMore || !hasMoreData) return;

    // Check connectivity before loading more
    final isConnected = await ref.read(connectivityServiceProvider).checkConnectivity();
    if (!isConnected) {
      setState(() {
        error = ApiException(
          message: LocalizationHelper.getText(ref, 'offline'),
          code: 'no_connection',
        );
        isLoadingMore = false;
      });
      return;
    }

    setState(() {
      isLoadingMore = true;
      error = null; // Clear any previous errors
    });

    try {
      currentPage++;
      // Get current language from theme provider
      final currentLanguage = LocalizationHelper.getCurrentLanguage(ref);

      final response = await ref.read(ministryServiceProvider).getMinistries(
        page: currentPage,
        currentLanguage: currentLanguage,
      );

      final currentMinistries = ref.read(ministryNotifierProvider).value ?? [];

      if (mounted) {
        setState(() {
          ref.read(ministryNotifierProvider.notifier)
              .replaceItems([...currentMinistries, ...response.items]);
          hasMoreData = response.pagination.currentPage < response.pagination.totalPages;
          isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          currentPage--; // Revert page increment on error
          isLoadingMore = false;
          error = e; // Store the error for display
        });
      }
    }
  }

  @override
  void onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  String getSearchHintText() {
    return LocalizationHelper.getText(ref, 'searchMinistries');
  }

  @override
  String getScreenTitle() {
    return LocalizationHelper.getText(ref, 'ministries');
  }

  @override
  Widget buildItemCard(MinistryItem ministry) {
    final isRTL = LocalizationHelper.isRTL(ref);

    return InfoCard(
      title: ministry.title ?? LocalizationHelper.getText(ref, 'ministry'),
      subtitle: ministry.phone,
      imageUrl: ministry.image,
      isRTL: isRTL,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MinistryDetailScreen(itemId: ministry.id),
          ),
        );
      },
    );
  }

  @override
  Widget buildListView(List<MinistryItem> items) {
    // Filter ministries based on search query
    final displayedMinistries = _searchQuery.isNotEmpty
        ? _filterMinistries(items, _searchQuery)
        : items;

    if (displayedMinistries.isEmpty) {
      return buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: loadInitialData,
      color: AppConstants.primaryColor,
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: displayedMinistries.length + (isLoadingMore && hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == displayedMinistries.length) {
            return _buildLoadingIndicator();
          }
          return buildItemCard(displayedMinistries[index]);
        },
      ),
    );
  }

  // Filter ministries based on search query
  List<MinistryItem> _filterMinistries(List<MinistryItem> ministries, String query) {
    if (query.isEmpty) return ministries;

    final lowercaseQuery = query.toLowerCase();
    return ministries.where((item) =>
      (item.title != null && item.title!.toLowerCase().contains(lowercaseQuery))
    ).toList();
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }

  @override
  Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isNotEmpty ? Icons.search_off : Icons.account_balance_outlined,
            size: 64,
            color: AppConstants.primaryColor.withAlpha(179), // ~0.7 opacity
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
              ? LocalizationHelper.getText(ref, 'emptySearchResult').replaceAll('{query}', _searchQuery)
              : LocalizationHelper.getText(ref, 'noMinistries'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          if (_searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: ElevatedButton(
                onPressed: () {
                  searchController.clear();
                  onSearchChanged('');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Text(LocalizationHelper.getText(ref, 'clearSearchButton')),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget buildErrorState(dynamic error) {
    return ErrorState(
      error: error,
      onRetry: loadInitialData,
    );
  }

  @override
  Widget buildLoadingState() {
    return const LoadingIndicator(
      itemCount: 5,
      height: 110,
      showImage: true,
      showSubtitle: true,
      isGrid: false,
      borderRadius: 12,
    );
  }

  @override
  Widget buildBody() {
    final ministryState = ref.watch(ministryNotifierProvider);
    final isConnected = ref.watch(isConnectedProvider);

    // If we have a specific error from our loading attempts, show that first
    if (error != null) {
      return buildErrorState(error);
    }

    // Show no connection message if disconnected
    if (!isConnected) {
      return buildErrorState(ApiException(
        message: LocalizationHelper.getText(ref, 'noConnection'),
        code: 'no_connection',
      ));
    }

    // Handle various states from the provider
    return ministryState.when(
      data: (ministries) => buildListView(ministries),
      loading: () => buildLoadingState(),
      error: (error, stackTrace) => buildErrorState(error),
    );
  }
}
