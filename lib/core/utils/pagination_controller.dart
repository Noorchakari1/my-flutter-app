import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/connectivity_service.dart';

/// A reusable controller for handling pagination in list views
class PaginationController {
  final ScrollController scrollController = ScrollController();
  final WidgetRef ref;
  
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  bool _showScrollToTop = false;
  
  // Callback functions
  final Future<bool> Function(int page) loadPageFunction;
  final VoidCallback? onScrollToTopVisibilityChanged;
  
  PaginationController({
    required this.ref,
    required this.loadPageFunction,
    this.onScrollToTopVisibilityChanged,
  }) {
    scrollController.addListener(_scrollListener);
  }
  
  /// Initialize the controller and load the first page
  Future<void> init() async {
    await loadFirstPage();
  }
  
  /// Dispose the controller
  void dispose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
  }
  
  /// Get the current page
  int get currentPage => _currentPage;
  
  /// Check if more data is being loaded
  bool get isLoadingMore => _isLoadingMore;
  
  /// Check if there is more data to load
  bool get hasMoreData => _hasMoreData;
  
  /// Check if the scroll to top button should be shown
  bool get showScrollToTop => _showScrollToTop;
  
  /// Scroll listener to handle pagination and scroll to top button visibility
  void _scrollListener() {
    if (!scrollController.hasClients) return;

    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;

    // Show scroll to top button when user has scrolled down enough
    final shouldShowScrollToTop = currentScroll > 300;
    if (_showScrollToTop != shouldShowScrollToTop) {
      _showScrollToTop = shouldShowScrollToTop;
      onScrollToTopVisibilityChanged?.call();
    }

    // Load more when we reach 70% of the list
    if (maxScroll - currentScroll <= maxScroll * 0.3 && !_isLoadingMore && _hasMoreData) {
      loadNextPage();
    }
  }
  
  /// Load the first page of data
  Future<bool> loadFirstPage() async {
    // First check connectivity
    final isConnected = await ref.read(connectivityServiceProvider).checkConnectivity();
    if (!isConnected) {
      _isLoadingMore = false;
      return false;
    }

    _isLoadingMore = true;
    _currentPage = 1;
    _hasMoreData = true;
    
    try {
      _hasMoreData = await loadPageFunction(_currentPage);
      _isLoadingMore = false;
      return true;
    } catch (e) {
      _isLoadingMore = false;
      return false;
    }
  }
  
  /// Load the next page of data
  Future<bool> loadNextPage() async {
    if (_isLoadingMore || !_hasMoreData) return false;

    // Check connectivity before loading more
    final isConnected = await ref.read(connectivityServiceProvider).checkConnectivity();
    if (!isConnected) {
      _isLoadingMore = false;
      return false;
    }

    _isLoadingMore = true;
    
    try {
      _currentPage++;
      final hasMore = await loadPageFunction(_currentPage);
      _hasMoreData = hasMore;
      _isLoadingMore = false;
      return true;
    } catch (e) {
      _currentPage--; // Revert page increment on error
      _isLoadingMore = false;
      return false;
    }
  }
  
  /// Refresh the data by loading the first page again
  Future<Future<bool>> refresh() async {
    return loadFirstPage();
  }
  
  /// Scroll to the top of the list
  void scrollToTop() {
    if (!scrollController.hasClients) return;
    
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
}
