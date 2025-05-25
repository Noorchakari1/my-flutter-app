import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/url_config.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/utils/localization_helper.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/widgets/cached_image_widget.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../data/models/job_model.dart';
import '../../data/providers/job_provider.dart';

class JobDetailScreen extends ConsumerStatefulWidget {
  final String jobUuid;

  const JobDetailScreen({
    super.key,
    required this.jobUuid,
  });

  @override
  ConsumerState<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends ConsumerState<JobDetailScreen> {
  final ScrollController scrollController = ScrollController();
  bool showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    setState(() {
      showScrollToTop = scrollController.offset > 500;
    });
  }

  void scrollToTop() {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final jobDetailAsync = ref.watch(jobDetailProvider(widget.jobUuid));

    return Directionality(
      textDirection: LocalizationHelper.getTextDirection(ref),
      child: Scaffold(
        backgroundColor: isDarkMode ? Colors.black : Colors.grey.shade100,
        body: Stack(
          children: [
            jobDetailAsync.when(
              data: (job) => _buildJobDetail(context, ref, job, isDarkMode),
              loading: () => _buildLoadingState(),
              error: (error, stackTrace) => _buildErrorState(context, ref, error),
            ),
            Positioned(
              right: LocalizationHelper.isRTL(ref) ? null : 16,
              left: LocalizationHelper.isRTL(ref) ? 16 : null,
              bottom: 16,
              child: AnimatedOpacity(
                opacity: showScrollToTop ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: FloatingActionButton(
                  mini: true,
                  onPressed: showScrollToTop ? scrollToTop : null,
                  backgroundColor: AppConstants.primaryColor,
                  child: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const LoadingIndicator();
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, dynamic error) {
    return ErrorState(
      error: error,
      onRetry: () {
        ref.invalidate(jobDetailProvider(widget.jobUuid));
      },
    );
  }

  Widget _buildJobDetail(BuildContext context, WidgetRef ref, JobItem job, bool isDarkMode) {
    final currentLanguage = ref.read(themeNotifierProvider).currentLanguage;
    final title = job.getTitle(currentLanguage) ?? LocalizationHelper.getText(ref, 'jobOpportunity');
    final description = job.getDescription(currentLanguage);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(jobDetailProvider(widget.jobUuid));
        // Wait for the provider to complete the refresh
        await ref.read(jobDetailProvider(widget.jobUuid).future);
      },
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
        // App Bar
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          backgroundColor: isDarkMode ? Colors.black : AppConstants.primaryColor,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppConstants.primaryColor,
                    AppConstants.primaryColor.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Center(
                child: job.ministry?.logoPath != null && job.ministry!.logoPath!.isNotEmpty
                    ? Container(
                        padding: const EdgeInsets.all(16),
                        child: CachedImageWidget(
                          imageUrl: UrlConfig.buildLogoUrl(job.ministry!.logoPath),
                          width: 80,
                          height: 80,
                          borderRadius: BorderRadius.circular(12),
                          fit: BoxFit.contain,
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          errorWidget: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.work,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.work,
                        size: 80,
                        color: Colors.white,
                      ),
              ),
            ),
          ),
        ),

        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Job Info Card
                _buildJobInfoCard(job, ref, isDarkMode),

                const SizedBox(height: 16),

                // Job Description
                _buildDescriptionCard(description, ref, isDarkMode),

                const SizedBox(height: 16),

                // Action Buttons
                _buildActionButtons(job, ref, context),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
      ),
    );
  }

  Widget _buildJobInfoCard(JobItem job, WidgetRef ref, bool isDarkMode) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationHelper.getText(ref, 'jobInformation'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Add ministry information first if available
            if (job.ministry != null) ...[
              _buildInfoRow(
                LocalizationHelper.getText(ref, 'ministry'),
                job.ministry!.getTitle(ref.read(themeNotifierProvider).currentLanguage) ?? 'N/A',
                Icons.account_balance,
              ),
            ],

            if (job.type != null)
              _buildInfoRow(
                LocalizationHelper.getText(ref, 'jobType'),
                job.getLocalizedType(ref) ?? job.type!,
                Icons.work_outline,
              ),

            if (job.getFormattedAnnouncementDate(ref) != null)
              _buildInfoRow(
                LocalizationHelper.getText(ref, 'announcementDate'),
                job.getFormattedAnnouncementDate(ref)!,
                Icons.calendar_today,
              ),

            if (job.getFormattedEndDate(ref) != null)
              _buildInfoRow(
                LocalizationHelper.getText(ref, 'deadline'),
                job.getFormattedEndDate(ref)!,
                Icons.schedule,
                isDeadline: true,
                isExpired: !job.isActive,
              ),

            if (job.contractDuration != null)
              _buildInfoRow(
                LocalizationHelper.getText(ref, 'contractDuration'),
                job.contractDuration!,
                Icons.timer,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    bool isDeadline = false,
    bool isExpired = false,
  }) {
    Color? textColor;
    if (isDeadline && isExpired) {
      textColor = Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: textColor ?? AppConstants.primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinistryInfoRow(JobMinistry ministry, WidgetRef ref) {
    final currentLanguage = ref.read(themeNotifierProvider).currentLanguage;
    final ministryName = ministry.getTitle(currentLanguage) ?? 'N/A';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Ministry Logo
          if (ministry.logoPath != null && ministry.logoPath!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 12),
              child: CachedImageWidget(
                imageUrl: UrlConfig.buildLogoUrl(ministry.logoPath),
                width: 40,
                height: 40,
                borderRadius: BorderRadius.circular(8),
                fit: BoxFit.cover,
                errorWidget: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.account_balance,
                    color: AppConstants.primaryColor,
                    size: 20,
                  ),
                ),
              ),
            )
          else
            Container(
              margin: const EdgeInsets.only(right: 12),
              child: Icon(
                Icons.account_balance,
                size: 20,
                color: AppConstants.primaryColor,
              ),
            ),
          // Ministry Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocalizationHelper.getText(ref, 'ministry'),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  ministryName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(String? description, WidgetRef ref, bool isDarkMode) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationHelper.getText(ref, 'jobDescription'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (description != null && description.isNotEmpty)
              Html(
                data: description,
                style: {
                  "body": Style(
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                  ),
                  "table": Style(
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  "td": Style(
                    border: Border.all(color: Colors.grey.shade300),
                    padding: HtmlPaddings.all(8),
                  ),
                  "th": Style(
                    border: Border.all(color: Colors.grey.shade300),
                    padding: HtmlPaddings.all(8),
                    backgroundColor: Colors.grey.shade100,
                    fontWeight: FontWeight.bold,
                  ),
                },
                onLinkTap: (url, attributes, element) {
                  if (url != null) {
                    _launchURL(url);
                  }
                },
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      LocalizationHelper.getText(ref, 'noDescriptionAvailable'),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Debug Info: description = "$description"',
                      style: TextStyle(
                        color: Colors.red.shade600,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(JobItem job, WidgetRef ref, BuildContext context) {
    return Column(
      children: [
        if (job.applyLink != null && job.applyLink!.isNotEmpty)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _launchURL(job.applyLink!),
              icon: const Icon(Icons.open_in_new),
              label: Text(LocalizationHelper.getText(ref, 'applyNow')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _shareJob(job, ref),
            icon: const Icon(Icons.share),
            label: Text(LocalizationHelper.getText(ref, 'share')),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppConstants.primaryColor,
              side: const BorderSide(color: AppConstants.primaryColor),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _shareJob(JobItem job, WidgetRef ref) async {
    final currentLanguage = ref.read(themeNotifierProvider).currentLanguage;
    final title = job.getTitle(currentLanguage) ?? LocalizationHelper.getText(ref, 'jobOpportunity');
    final ministryName = job.ministry?.getTitle(currentLanguage);
    final localizedType = job.getLocalizedType(ref) ?? job.type ?? 'N/A';
    final solarHijriEndDate = job.getFormattedEndDate(ref) ?? 'N/A';

    final shareText = '''
$title

${ministryName != null ? '$ministryName\n' : ''}${LocalizationHelper.getText(ref, 'jobType')}: $localizedType
${LocalizationHelper.getText(ref, 'deadline')}: $solarHijriEndDate

${LocalizationHelper.getText(ref, 'sharedFromApp')}
''';

    try {
      await Share.share(shareText.trim());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LocalizationHelper.getText(ref, 'shareError')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
