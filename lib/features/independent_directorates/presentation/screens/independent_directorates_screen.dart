import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_exception.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/utils/localization_helper.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/screens/base_list_screen.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/info_card.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../data/models/independent_directorate_model.dart';
import '../../data/providers/independent_directorate_provider.dart';
import '../../data/services/independent_directorate_service.dart';
import 'independent_directorate_detail_screen.dart';

class IndependentDirectoratesScreen extends BaseListScreen<IndependentDirectorateItem> {
  const IndependentDirectoratesScreen({super.key});

  @override
  ConsumerState<IndependentDirectoratesScreen> createState() => _IndependentDirectoratesScreenState();
}

class _IndependentDirectoratesScreenState extends BaseListScreenState<IndependentDirectorateItem, IndependentDirectoratesScreen> {
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

      final response = await ref.read(independentDirectorateServiceProvider).getIndependentDirectorates(
        page: currentPage,
        currentLanguage: currentLanguage,
      );

      if (mounted) {
        setState(() {
          ref.read(independentDirectorateNotifierProvider.notifier).replaceItems(response.items);
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

      final response = await ref.read(independentDirectorateServiceProvider).getIndependentDirectorates(
        page: currentPage,
        currentLanguage: currentLanguage,
      );

      final currentDirectorates = ref.read(independentDirectorateNotifierProvider).value ?? [];

      if (mounted) {
        setState(() {
          ref.read(independentDirectorateNotifierProvider.notifier)
              .replaceItems([...currentDirectorates, ...response.items]);
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
    return LocalizationHelper.getText(ref, 'searchDirectorates');
  }

  @override
  String getScreenTitle() {
    return LocalizationHelper.getText(ref, 'independentDirectorates');
  }

  // Filter directorates based on search query
  List<IndependentDirectorateItem> _filterDirectorates(List<IndependentDirectorateItem> directorates, String query) {
    if (query.isEmpty) return directorates;

    final lowercaseQuery = query.toLowerCase();
    return directorates.where((item) =>
      (item.title != null && item.title!.toLowerCase().contains(lowercaseQuery))
    ).toList();
  }

  @override
  Widget buildItemCard(IndependentDirectorateItem directorate) {
    final isRTL = LocalizationHelper.isRTL(ref);

    return InfoCard(
      title: directorate.title ?? LocalizationHelper.getText(ref, 'directorate'),
      subtitle: directorate.phone,
      imageUrl: directorate.image,
      isRTL: isRTL,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => IndependentDirectorateDetailScreen(
              directorateId: directorate.id,
              language: LocalizationHelper.getCurrentLanguage(ref),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget buildListView(List<IndependentDirectorateItem> items) {
    // Filter directorates based on search query
    final displayedDirectorates = _searchQuery.isNotEmpty
        ? _filterDirectorates(items, _searchQuery)
        : items;

    if (displayedDirectorates.isEmpty) {
      return buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: loadInitialData,
      color: AppConstants.primaryColor,
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: displayedDirectorates.length + (isLoadingMore && hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == displayedDirectorates.length) {
            return _buildLoadingIndicator();
          }
          return buildItemCard(displayedDirectorates[index]);
        },
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

  @override
  Widget buildEmptyState() {
    return EmptyStateWidget(
      icon: _searchQuery.isNotEmpty ? Icons.search_off : Icons.account_balance_outlined,
      message: _searchQuery.isNotEmpty
        ? LocalizationHelper.getText(ref, 'emptySearchResult').replaceAll('{query}', _searchQuery)
        : LocalizationHelper.getText(ref, 'noDirectorates'),
      subMessage: _searchQuery.isNotEmpty
        ? LocalizationHelper.getText(ref, 'emptySearchSuggestion')
        : LocalizationHelper.getText(ref, 'directorateComingSoon'),
      actionLabel: _searchQuery.isNotEmpty ? LocalizationHelper.getText(ref, 'clearSearchButton') : null,
      onActionPressed: _searchQuery.isNotEmpty
        ? () {
            searchController.clear();
            onSearchChanged('');
          }
        : null,
      iconColor: AppConstants.primaryColor.withAlpha(179),
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
    final directorateState = ref.watch(independentDirectorateNotifierProvider);
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
    return directorateState.when(
      data: (directorates) => buildListView(directorates),
      loading: () => buildLoadingState(),
      error: (error, stackTrace) => buildErrorState(error),
    );
  }
}
