import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    final title = job.getTitle(currentLanguage) ?? LocalizationHelper.getText(ref, 'jobOpportunity');
    final subtitle = _buildJobSubtitle(job);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => JobDetailScreen(jobUuid: job.uuid),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_buildJobStatusChip(job) != null)
                    _buildJobStatusChip(job)!,
                ],
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _buildJobSubtitle(JobItem job) {
    final parts = <String>[];
    final currentLanguage = ref.read(themeNotifierProvider).currentLanguage;

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
    if (solarHijriEndDate != null) {
      parts.add(solarHijriEndDate);
    }

    return parts.join(' • ');
  }

  Widget? _buildJobStatusChip(JobItem job) {
    if (job.status == null) return null;

    Color chipColor;
    Color textColor;

    switch (job.status!.toLowerCase()) {
      case 'published':
        chipColor = job.isActive ? Colors.green.shade100 : Colors.orange.shade100;
        textColor = job.isActive ? Colors.green.shade800 : Colors.orange.shade800;
        break;
      case 'draft':
        chipColor = Colors.grey.shade100;
        textColor = Colors.grey.shade800;
        break;
      case 'archived':
        chipColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        break;
      default:
        chipColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        job.isActive ? LocalizationHelper.getText(ref, 'active') : LocalizationHelper.getText(ref, 'expired'),
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
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
