import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../core/utils/localization_helper.dart';
import '../../../../shared/constants/app_constants.dart';
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

    return CustomScrollView(
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
              child: const Center(
                child: Icon(
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
                if (description != null && description.isNotEmpty)
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

            if (job.type != null)
              _buildInfoRow(
                LocalizationHelper.getText(ref, 'jobType'),
                job.type!,
                Icons.work_outline,
              ),

            if (job.status != null)
              _buildInfoRow(
                LocalizationHelper.getText(ref, 'status'),
                job.status!,
                Icons.info_outline,
              ),

            if (job.formattedAnnouncementDate != null)
              _buildInfoRow(
                LocalizationHelper.getText(ref, 'announcementDate'),
                job.formattedAnnouncementDate!,
                Icons.calendar_today,
              ),

            if (job.formattedEndDate != null)
              _buildInfoRow(
                LocalizationHelper.getText(ref, 'deadline'),
                job.formattedEndDate!,
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

  Widget _buildDescriptionCard(String description, WidgetRef ref, bool isDarkMode) {
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

    final shareText = '''
$title

${LocalizationHelper.getText(ref, 'jobType')}: ${job.type ?? 'N/A'}
${LocalizationHelper.getText(ref, 'deadline')}: ${job.formattedEndDate ?? 'N/A'}
${LocalizationHelper.getText(ref, 'status')}: ${job.status ?? 'N/A'}

${LocalizationHelper.getText(ref, 'sharedFromApp')}
''';

    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Share: $shareText')),
    );
  }
}
