import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/url_config.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/utils/localization_helper.dart';
import '../../../../core/utils/navigation_helper.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/screens/base_list_screen.dart';

import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/scroll_to_top_button.dart';
import '../../data/models/job_model.dart';
import '../../data/providers/job_provider.dart';
import 'job_detail_screen.dart';

class JobOpportunitiesScreen extends BaseListScreen<JobItem> {
  const JobOpportunitiesScreen({super.key});

  @override
  ConsumerState<JobOpportunitiesScreen> createState() => _JobOpportunitiesScreenState();
}

class _JobOpportunitiesScreenState extends BaseListScreenState<JobItem, JobOpportunitiesScreen> with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  late TabController _tabController;
  final List<String> _categoryKeys = [
    'newJobs',
    'expiringJobs',
    'expiredJobs',
  ];

  // Filter state
  String? _selectedDepartmentId;
  String? _selectedDepartmentName;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categoryKeys.length, vsync: this);
    loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Future<void> loadInitialData() async {
    final notifier = ref.read(jobNotifierProvider.notifier);
    await notifier.loadInitial();
  }

  @override
  Future<void> loadMoreData() async {
    // Job API doesn't support pagination, so we don't need to load more data
    setState(() {
      isLoadingMore = false;
      hasMoreData = false;
    });
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

  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(jobNotifierProvider);
    final isConnected = ref.watch(isConnectedProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final appBarColor = Theme.of(context).appBarTheme.backgroundColor;
    final appBarForeground = Theme.of(context).appBarTheme.titleTextStyle?.color ?? Colors.white;

    // Determine text direction based on current language
    final isRTL = ref.watch(themeNotifierProvider).currentLanguage != 'english';
    final textDirection = isRTL ? TextDirection.rtl : TextDirection.ltr;

    // Show no connection message if disconnected
    if (!isConnected) {
      return Directionality(
        textDirection: textDirection,
        child: Scaffold(
          appBar: AppBar(
            title: Text(_getText(context, 'jobOpportunities')),
            backgroundColor: appBarColor,
            centerTitle: true,
          ),
          body: _buildNoConnectionState(),
        ),
      );
    }

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        // Add scroll to top button using the shared widget
        floatingActionButton: ScrollToTopButton(
          onPressed: scrollToTop,
          visible: showScrollToTop,
          backgroundColor: Theme.of(context).colorScheme.primary,
          iconColor: Theme.of(context).colorScheme.onPrimary,
          size: ScrollToTopButton.standardSize,
          elevation: 4,
        ),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                title: isSearchVisible
                  ? buildSearchField()
                  : Text(
                      _getText(context, 'jobOpportunities'), // Localized title
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: appBarForeground,
                      ),
                    ),
                centerTitle: true,
                floating: true,
                pinned: true,
                elevation: 0,
                backgroundColor: appBarColor,
                shadowColor: Colors.transparent,
                leading: isSearchVisible
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: toggleSearch,
                    )
                  : null, // Let Flutter handle the default back button automatically
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(50),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: appBarColor,
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withAlpha(26), // 0.1 opacity = 26/255
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      padding: EdgeInsets.zero,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                      labelColor: appBarForeground,
                      unselectedLabelColor: appBarForeground.withAlpha(153), // 0.6 opacity = 153/255
                      indicatorColor: appBarForeground,
                      indicatorWeight: 3,
                      indicatorSize: TabBarIndicatorSize.label,
                      // Generate tabs using localized keys
                      tabs: _categoryKeys.map((key) => Tab(
                        text: _getText(context, key),
                        height: 46,
                      )).toList(),
                      tabAlignment: TabAlignment.start,
                    ),
                  ),
                ),
                actions: [
                  if (isSearchVisible && searchController.text.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(51), // 0.2 opacity = 51/255
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.clear, size: 20, color: Colors.white),
                        tooltip: _getText(context, 'clearSearch'), // Localized tooltip
                        onPressed: () => onSearchChanged(''),
                      ),
                    ),
                  if (!isSearchVisible) ...[
                    IconButton(
                      icon: const Icon(Icons.filter_list, color: Colors.white),
                      tooltip: _getText(context, 'filter'),
                      onPressed: _showFilterModal,
                    ),
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      tooltip: _getText(context, 'searchJobs'),
                      onPressed: toggleSearch,
                    ),
                  ],
                ],
              ),
            ];
          },
          body: Container(
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Theme.of(context).scaffoldBackgroundColor
                  : Colors.grey.shade100,
            ),
            child: Column(
              children: [
                // Search results indicator
                if (isSearchVisible && _searchQuery.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                    child: Row(
                      children: [
                        Text(
                          '${_getText(context, 'searchLabel')} "$_searchQuery"', // Localized label
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => onSearchChanged(''), // Clear search
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            visualDensity: VisualDensity.compact,
                          ),
                          child: Text(_getText(context, 'clearSearchButton')),
                        ),
                      ],
                    ),
                  ),
                // Department filter indicator
                if (_selectedDepartmentId != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.filter_list,
                          size: 16,
                          color: AppConstants.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${_getText(context, 'filterByDepartment')}: $_selectedDepartmentName',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedDepartmentId = null;
                              _selectedDepartmentName = null;
                            });
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            visualDensity: VisualDensity.compact,
                          ),
                          child: Text(_getText(context, 'clearFilter')),
                        ),
                      ],
                    ),
                  ),
                // Jobs TabBarView
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: List.generate(_categoryKeys.length, (tabIndex) {
                      return jobsAsync.when(
                        data: (jobs) {
                          // Apply search filter if search query exists
                          final displayedJobs = _searchQuery.isNotEmpty
                              ? _filterJobs(jobs, _searchQuery)
                              : _categorizeJobsForTab(jobs, tabIndex);

                          if (displayedJobs.isEmpty) {
                            return _searchQuery.isNotEmpty
                                ? _buildEmptySearchResults()
                                : _buildEmptyStateForTab(_categoryKeys[tabIndex]);
                          }

                          return RefreshIndicator(
                            onRefresh: loadInitialData,
                            color: AppConstants.primaryColor,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(12),
                              controller: scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: displayedJobs.length,
                              itemBuilder: (context, index) {
                                final job = displayedJobs[index];
                                return buildItemCard(job);
                              },
                            ),
                          );
                        },
                        loading: () => buildLoadingState(),
                        error: (error, stackTrace) => buildErrorState(error),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget buildBody() {
    // This method is no longer used since we override build()
    return Container();
  }

  // Filter jobs based on search query and department filter
  List<JobItem> _filterJobs(List<JobItem> jobs, String query) {
    List<JobItem> filteredJobs = jobs;

    // Apply department filter first if selected
    if (_selectedDepartmentId != null) {
      filteredJobs = filteredJobs.where((job) =>
        job.ministry?.id.toString() == _selectedDepartmentId).toList();
    }

    // Apply search filter if query exists
    if (query.isNotEmpty) {
      final lowercaseQuery = query.toLowerCase();
      filteredJobs = filteredJobs.where((job) {
        final currentLanguage = ref.read(themeNotifierProvider).currentLanguage;
        final title = job.getTitle(currentLanguage)?.toLowerCase() ?? '';
        final description = job.getDescription(currentLanguage)?.toLowerCase() ?? '';
        final ministryName = job.ministry?.getTitle(currentLanguage)?.toLowerCase() ?? '';

        return title.contains(lowercaseQuery) ||
               description.contains(lowercaseQuery) ||
               ministryName.contains(lowercaseQuery);
      }).toList();
    }

    return filteredJobs;
  }

  // Categorize jobs for specific tab
  List<JobItem> _categorizeJobsForTab(List<JobItem> jobs, int tabIndex) {
    // Apply department filter first if selected
    List<JobItem> filteredJobs = jobs;
    if (_selectedDepartmentId != null) {
      filteredJobs = jobs.where((job) =>
        job.ministry?.id.toString() == _selectedDepartmentId).toList();
    }

    final categorizedJobs = _categorizeJobs(filteredJobs);

    switch (tabIndex) {
      case 0: // New Posts
        return categorizedJobs['new']!;
      case 1: // Expiring Posts
        return categorizedJobs['expiring']!;
      case 2: // Expired Posts
        return categorizedJobs['expired']!;
      default:
        return [];
    }
  }

  // Show filter modal
  void _showFilterModal() {
    final jobsAsync = ref.read(jobNotifierProvider);

    jobsAsync.whenData((jobs) {
      // Get unique departments from jobs
      final departments = <String, String>{};
      for (final job in jobs) {
        if (job.ministry != null) {
          final currentLanguage = ref.read(themeNotifierProvider).currentLanguage;
          final ministryName = job.ministry!.getTitle(currentLanguage);
          if (ministryName != null && ministryName.isNotEmpty) {
            departments[job.ministry!.id.toString()] = ministryName;
          }
        }
      }

      _showDepartmentFilterBottomSheet(departments);
    });
  }

  // Show department filter bottom sheet
  void _showDepartmentFilterBottomSheet(Map<String, String> departments) {
    final isRTL = ref.read(themeNotifierProvider).currentLanguage != 'english';
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final jobsAsync = ref.read(jobNotifierProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Directionality(
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey.shade900 : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            maxChildSize: 0.9,
            minChildSize: 0.3,
            expand: false,
            builder: (context, scrollController) {
              return Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.filter_list,
                          color: AppConstants.primaryColor,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getText(context, 'filterByDepartment'),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        if (_selectedDepartmentId != null)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedDepartmentId = null;
                                _selectedDepartmentName = null;
                              });
                              Navigator.pop(context);
                            },
                            child: Text(_getText(context, 'clearFilter')),
                          ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Department list
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: [
                        // All departments option
                        jobsAsync.when(
                          data: (jobs) => _buildDepartmentOption(
                            null,
                            _getText(context, 'allDepartments'),
                            isDarkMode,
                            jobs.length,
                            activeCount: jobs.where((job) => job.isActive).length,
                            expiredCount: jobs.where((job) => !job.isActive).length,
                          ),
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                        const Divider(height: 1),
                        // Individual departments
                        ...departments.entries.map((entry) {
                          return jobsAsync.when(
                            data: (jobs) {
                              final departmentJobs = jobs.where((job) =>
                                job.ministry?.id.toString() == entry.key).toList();
                              final activeCount = departmentJobs.where((job) => job.isActive).length;
                              final expiredCount = departmentJobs.length - activeCount;

                              return _buildDepartmentOption(
                                entry.key,
                                entry.value,
                                isDarkMode,
                                departmentJobs.length,
                                activeCount: activeCount,
                                expiredCount: expiredCount,
                              );
                            },
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // Build department option widget
  Widget _buildDepartmentOption(
    String? departmentId,
    String departmentName,
    bool isDarkMode,
    int totalJobs, {
    int? activeCount,
    int? expiredCount,
  }) {
    final isSelected = _selectedDepartmentId == departmentId;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedDepartmentId = departmentId;
          _selectedDepartmentName = departmentName;
        });
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
            ? AppConstants.primaryColor.withAlpha(26) // ~0.1 opacity
            : Colors.transparent,
        ),
        child: Row(
          children: [
            // Selection indicator
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                    ? AppConstants.primaryColor
                    : Colors.grey.shade400,
                  width: 2,
                ),
                color: isSelected ? AppConstants.primaryColor : Colors.transparent,
              ),
              child: isSelected
                ? const Icon(
                    Icons.check,
                    size: 12,
                    color: Colors.white,
                  )
                : null,
            ),
            const SizedBox(width: 12),
            // Department info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    departmentName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (activeCount != null && expiredCount != null)
                    Text(
                      '${_getText(context, 'activeJobs')}: $activeCount • ${_getText(context, 'expiredJobs')}: $expiredCount',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    )
                  else
                    Text(
                      '$totalJobs ${_getText(context, 'jobOpportunities').toLowerCase()}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                ],
              ),
            ),
            // Job count badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withAlpha(26), // ~0.1 opacity
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                totalJobs.toString(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build empty search results widget
  Widget _buildEmptySearchResults() {
    String subMessage = _getText(context, 'emptySearchSuggestion');
    if (_selectedDepartmentId != null) {
      subMessage = '${_getText(context, 'filterByDepartment')}: $_selectedDepartmentName\n$subMessage';
    }

    return EmptyStateWidget(
      icon: Icons.search_off,
      message: _getText(context, 'emptySearchResult').replaceAll('{query}', _searchQuery),
      subMessage: subMessage,
      actionLabel: _getText(context, 'clearSearchButton'),
      onActionPressed: () => onSearchChanged(''),
      iconColor: AppConstants.primaryColor.withAlpha(179),
    );
  }

  Widget _buildNoConnectionState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            LocalizationHelper.getText(ref, 'noInternetConnection'),
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: loadInitialData,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text(LocalizationHelper.getText(ref, 'retry')),
          ),
        ],
      ),
    );
  }

  @override
  void onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });

    if (query.isEmpty) {
      loadInitialData();
    } else {
      final notifier = ref.read(jobNotifierProvider.notifier);
      notifier.search(query);
    }
  }

  @override
  String getSearchHintText() {
    return LocalizationHelper.getText(ref, 'searchJobs');
  }

  @override
  String getScreenTitle() {
    return LocalizationHelper.getText(ref, 'jobOpportunities');
  }

  @override
  Widget buildItemCard(JobItem job) {
    final currentLanguage = ref.read(themeNotifierProvider).currentLanguage;
    final isRTL = LocalizationHelper.isRTL(ref);

    final title = job.getTitle(currentLanguage) ?? LocalizationHelper.getText(ref, 'jobOpportunity');

    // Get ministry logo URL if available
    final imageUrl = job.ministry?.logoPath != null && job.ministry!.logoPath!.isNotEmpty
        ? UrlConfig.buildLogoUrl(job.ministry!.logoPath)
        : null;

    return _buildJobCard(job, title, imageUrl, isRTL);
  }

  Widget _buildJobCard(JobItem job, String title, String? imageUrl, bool isRTL) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    // Card colors based on theme
    final cardColor = isDarkMode ? Colors.grey.shade900 : Colors.white;
    final shadowColor = isDarkMode
        ? Colors.black.withAlpha(51) // ~0.2 opacity
        : Colors.black.withAlpha(20); // ~0.08 opacity

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 12,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            NavigationHelper.navigateWithLoading(
              context,
              destination: JobDetailScreen(jobUuid: job.uuid),
              loadingMessage: LocalizationHelper.getText(ref, 'loading'),
              loadingDuration: const Duration(milliseconds: 500),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Row(
              children: [
                if (imageUrl != null)
                  _buildJobImage(imageUrl, isDarkMode),
                Expanded(
                  child: _buildJobContent(job, title, isDarkMode, isRTL),
                ),
                _buildJobArrow(isDarkMode, primaryColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJobImage(String imageUrl, bool isDarkMode) {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
          child: Center(
            child: Icon(
              Icons.business,
              size: 32,
              color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJobContent(JobItem job, String title, bool isDarkMode, bool isRTL) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
              letterSpacing: 0.1,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDarkMode
                      ? Colors.grey.shade800.withAlpha(128) // ~0.5 opacity
                      : Colors.grey.shade200.withAlpha(204), // ~0.8 opacity
                  width: 0.5,
                ),
              ),
            ),
            child: _buildJobSubtitleWidget(job, isDarkMode),
          ),
        ],
      ),
    );
  }

  Widget _buildJobSubtitleWidget(JobItem job, bool isDarkMode) {
    final currentLanguage = ref.read(themeNotifierProvider).currentLanguage;
    final parts = <String>[];

    // Add ministry name first if available
    if (job.ministry != null) {
      final ministryName = job.ministry!.getTitle(currentLanguage);
      if (ministryName != null && ministryName.isNotEmpty) {
        parts.add(ministryName);
      }
    }

    if (job.type != null) {
      final localizedType = job.getLocalizedType(ref);
      if (localizedType != null && localizedType.isNotEmpty) {
        parts.add(localizedType);
      }
    }

    final solarHijriEndDate = job.getFormattedEndDate(ref);

    // Get job status to determine expiration date color
    final jobStatus = _getJobStatus(job);
    Color expirationDateColor;
    
    switch (jobStatus) {
      case 'new':
        expirationDateColor = Colors.green.shade600;
        break;
      case 'expired':
        expirationDateColor = Colors.red.shade600;
        break;
      case 'expiring':
        expirationDateColor = Colors.orange.shade600;
        break;
      default:
        expirationDateColor = job.isActive
            ? Colors.green.shade600
            : Colors.red.shade600;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (parts.isNotEmpty)
          Text(
            parts.join(' • '),
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        if (solarHijriEndDate != null) ...[
          if (parts.isNotEmpty) const SizedBox(height: 4),
          Text(
            solarHijriEndDate,
            style: TextStyle(
              fontSize: 14,
              color: expirationDateColor,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildJobArrow(bool isDarkMode, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  @override
  Widget buildListView(List<JobItem> items) {
    // Filter jobs based on search query
    final displayedJobs = _searchQuery.isNotEmpty
        ? items // Search is already handled in the provider
        : items;

    if (displayedJobs.isEmpty) {
      return buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: loadInitialData,
      color: AppConstants.primaryColor,
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: displayedJobs.length,
        itemBuilder: (context, index) {
          return buildItemCard(displayedJobs[index]);
        },
      ),
    );
  }

  @override
  Widget buildEmptyState() {
    return EmptyStateWidget(
      icon: Icons.work_off,
      message: LocalizationHelper.getText(ref, 'noJobsFound'),
      subMessage: LocalizationHelper.getText(ref, 'noJobsFoundDescription'),
      onActionPressed: loadInitialData,
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
    return const LoadingIndicator();
  }



  Map<String, List<JobItem>> _categorizeJobs(List<JobItem> jobs) {
    final now = DateTime.now();
    final newJobs = <JobItem>[];
    final expiringJobs = <JobItem>[];
    final expiredJobs = <JobItem>[];

    for (final job in jobs) {
      // First check if job is expired based on end date
      bool isExpired = false;
      if (job.endDate != null) {
        try {
          final endDate = DateTime.parse(job.endDate!);
          isExpired = endDate.isBefore(now);
        } catch (e) {
          // If end date parsing fails, assume not expired
          isExpired = false;
        }
      }

      if (isExpired) {
        // Job has passed its closing date
        expiredJobs.add(job);
        continue;
      }

      // For active jobs, categorize based on announcement date
      if (job.announcementDate != null) {
        try {
          final announcementDate = DateTime.parse(job.announcementDate!);
          final daysSinceAnnouncement = now.difference(announcementDate).inDays;

          if (daysSinceAnnouncement <= 7) {
            // New: Announced 7 days ago or less
            newJobs.add(job);
          } else {
            // Expiring: Announced more than 7 days ago but not yet expired
            expiringJobs.add(job);
          }
        } catch (e) {
          // If announcement date parsing fails, consider it as new
          newJobs.add(job);
        }
      } else {
        // If no announcement date, consider it as new
        newJobs.add(job);
      }
    }

    return {
      'new': newJobs,
      'expiring': expiringJobs,
      'expired': expiredJobs,
    };
  }

  // Determine job status based on dates
  String _getJobStatus(JobItem job) {
    final now = DateTime.now();
    
    // First check if job is expired based on end date
    if (job.endDate != null) {
      try {
        final endDate = DateTime.parse(job.endDate!);
        if (endDate.isBefore(now)) {
          return 'expired';
        }
      } catch (e) {
        // If end date parsing fails, continue with other checks
      }
    }

    // For active jobs, categorize based on announcement date
    if (job.announcementDate != null) {
      try {
        final announcementDate = DateTime.parse(job.announcementDate!);
        final daysSinceAnnouncement = now.difference(announcementDate).inDays;

        if (daysSinceAnnouncement <= 7) {
          return 'new';
        } else {
          return 'expiring';
        }
      } catch (e) {
        // If announcement date parsing fails, consider it as new
        return 'new';
      }
    }

    // If no announcement date, consider it as new
    return 'new';
  }





  Widget _buildEmptyStateForTab(String tabKey) {
    String message;
    String subMessage;
    IconData icon;

    // Check if department filter is active
    if (_selectedDepartmentId != null) {
      message = LocalizationHelper.getText(ref, 'noJobsInDepartment');
      subMessage = '${LocalizationHelper.getText(ref, 'filterByDepartment')}: $_selectedDepartmentName';
      icon = Icons.filter_list_off;
    } else {
      switch (tabKey) {
        case 'newJobs':
          message = LocalizationHelper.getText(ref, 'noNewJobsFound');
          subMessage = LocalizationHelper.getText(ref, 'noNewJobsFoundDescription');
          icon = Icons.new_releases_outlined;
          break;
        case 'expiringJobs':
          message = LocalizationHelper.getText(ref, 'noExpiringJobsFound');
          subMessage = LocalizationHelper.getText(ref, 'noExpiringJobsFoundDescription');
          icon = Icons.schedule_outlined;
          break;
        case 'expiredJobs':
          message = LocalizationHelper.getText(ref, 'noExpiredJobsFound');
          subMessage = LocalizationHelper.getText(ref, 'noExpiredJobsFoundDescription');
          icon = Icons.event_busy_outlined;
          break;
        default:
          message = LocalizationHelper.getText(ref, 'noJobsFound');
          subMessage = LocalizationHelper.getText(ref, 'noJobsFoundDescription');
          icon = Icons.work_off;
      }
    }

    return EmptyStateWidget(
      icon: icon,
      message: message,
      subMessage: subMessage,
      actionLabel: _selectedDepartmentId != null
        ? LocalizationHelper.getText(ref, 'clearFilter')
        : null,
      onActionPressed: _selectedDepartmentId != null
        ? () {
            setState(() {
              _selectedDepartmentId = null;
              _selectedDepartmentName = null;
            });
          }
        : loadInitialData,
    );
  }
}
