import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/url_config.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/utils/localization_helper.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/screens/base_list_screen.dart';

import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state.dart';

import '../../../../shared/widgets/loading_indicator.dart';
import '../../data/models/job_model.dart';
import '../../data/providers/job_provider.dart';
import 'job_detail_screen.dart';

class JobOpportunitiesScreen extends BaseListScreen<JobItem> {
  const JobOpportunitiesScreen({super.key});

  @override
  ConsumerState<JobOpportunitiesScreen> createState() => _JobOpportunitiesScreenState();
}

class _JobOpportunitiesScreenState extends BaseListScreenState<JobItem, JobOpportunitiesScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadInitialData();
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

  @override
  Widget buildBody() {
    final jobsAsync = ref.watch(jobNotifierProvider);
    final isConnected = ref.watch(isConnectedProvider);

    if (!isConnected) {
      return _buildNoConnectionState();
    }

    return jobsAsync.when(
      data: (jobs) => buildListView(jobs),
      loading: () => buildLoadingState(),
      error: (error, stackTrace) => buildErrorState(error),
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
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => JobDetailScreen(jobUuid: job.uuid),
              ),
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
              color: job.isActive 
                  ? Colors.green.shade600 
                  : Colors.red.shade600,
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
}
