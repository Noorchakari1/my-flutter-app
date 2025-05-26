import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html/dom.dart' as html_dom;
import 'package:html/parser.dart' as html_parser;
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
import '../../data/services/job_apply_service.dart';

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
          centerTitle: true,
          backgroundColor: isDarkMode ? Colors.black : AppConstants.primaryColor,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            title: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
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
              _buildParsedContent(description, ref, isDarkMode)
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 48,
                      color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      LocalizationHelper.getText(ref, 'noDescriptionAvailable'),
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                        fontSize: 14,
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

  Widget _buildParsedContent(String htmlContent, WidgetRef ref, bool isDarkMode) {
    final document = html_parser.parse(htmlContent);
    final tables = document.querySelectorAll('table');
    
    if (tables.isEmpty) {
      // No tables found, render as HTML
      return _buildHtmlContent(htmlContent, isDarkMode);
    }
    
    // Extract content and build hybrid layout
    return _buildHybridContent(document, tables, ref, isDarkMode);
  }

  Widget _buildHtmlContent(String htmlContent, bool isDarkMode) {
    return Html(
      data: htmlContent,
      style: {
        "body": Style(
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
          fontSize: FontSize(14),
          lineHeight: const LineHeight(1.5),
        ),
        "p": Style(
          margin: Margins.only(bottom: 12),
          fontSize: FontSize(14),
          lineHeight: const LineHeight(1.5),
        ),
        "div": Style(
          margin: Margins.only(bottom: 8),
        ),
        "ul, ol": Style(
          margin: Margins.only(left: 16, bottom: 12),
        ),
        "li": Style(
          margin: Margins.only(bottom: 4),
          fontSize: FontSize(14),
        ),
        "h1, h2, h3, h4, h5, h6": Style(
          fontWeight: FontWeight.bold,
          margin: Margins.only(top: 16, bottom: 8),
        ),
        "strong, b": Style(
          fontWeight: FontWeight.bold,
        ),
        "em, i": Style(
          fontStyle: FontStyle.italic,
        ),
      },
      onLinkTap: (url, attributes, element) {
        if (url != null) {
          _launchURL(url);
        }
      },
    );
  }

  Widget _buildHybridContent(html_dom.Document document, List<html_dom.Element> tables, WidgetRef ref, bool isDarkMode) {
    final List<Widget> contentWidgets = [];
    
    // Get all content before the first table
    final beforeTableContent = _getContentBeforeElement(document.body!, tables.first);
    if (beforeTableContent.isNotEmpty) {
      contentWidgets.add(_buildHtmlContent(beforeTableContent, isDarkMode));
      contentWidgets.add(const SizedBox(height: 16));
    }
    
    // Process each table and content between tables
    for (int i = 0; i < tables.length; i++) {
      final table = tables[i];
      
      // Add the table widget
      contentWidgets.add(_buildCustomTable(table, isDarkMode, ref));
      
      if (i < tables.length - 1) {
        // Get content between this table and the next
        final betweenContent = _getContentBetweenElements(document.body!, table, tables[i + 1]);
        if (betweenContent.isNotEmpty) {
          contentWidgets.add(const SizedBox(height: 16));
          contentWidgets.add(_buildHtmlContent(betweenContent, isDarkMode));
          contentWidgets.add(const SizedBox(height: 16));
        } else {
          contentWidgets.add(const SizedBox(height: 16));
        }
      }
    }
    
    // Get content after the last table
    final afterTableContent = _getContentAfterElement(document.body!, tables.last);
    if (afterTableContent.isNotEmpty) {
      contentWidgets.add(const SizedBox(height: 16));
      contentWidgets.add(_buildHtmlContent(afterTableContent, isDarkMode));
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: contentWidgets,
    );
  }

  Widget _buildCustomTable(html_dom.Element tableElement, bool isDarkMode, WidgetRef ref) {
    final rows = tableElement.querySelectorAll('tr');
    if (rows.isEmpty) return const SizedBox.shrink();
    
    // Extract table data
    final List<List<String>> tableData = [];
    bool hasHeader = false;
    
    for (int i = 0; i < rows.length; i++) {
      final row = rows[i];
      final cells = row.querySelectorAll('td, th');
      
      if (cells.isNotEmpty) {
        // Check if this row contains header cells
        if (i == 0 && row.querySelectorAll('th').isNotEmpty) {
          hasHeader = true;
        }
        
        final List<String> rowData = cells.map((cell) => cell.text.trim()).toList();
        tableData.add(rowData);
      }
    }
    
    if (tableData.isEmpty) return const SizedBox.shrink();
    
    // Determine text direction based on language
    final isRTL = LocalizationHelper.isRTL(ref);
    
    // Reverse column order for RTL languages to maintain logical reading order
    final processedTableData = isRTL 
        ? tableData.map((row) => row.reversed.toList()).toList()
        : tableData;
    
    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade300,
            width: 1,
          ),
          // Add subtle gradient for RTL tables
          gradient: isRTL ? LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [
              (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50).withValues(alpha: 0.1),
              Colors.transparent,
            ],
          ) : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: hasHeader ? 56 : 0,
              dataRowMinHeight: 48,
              dataRowMaxHeight: 48,
              horizontalMargin: 16,
              columnSpacing: 20,
              headingRowColor: WidgetStateProperty.all(
                isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50,
              ),
              border: TableBorder.all(
                color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade300,
                width: 1,
              ),
              columns: _buildTableColumns(processedTableData.first, hasHeader, isDarkMode, isRTL),
              rows: _buildTableRows(
                hasHeader ? processedTableData.skip(1).toList() : processedTableData,
                isDarkMode,
                isRTL,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<DataColumn> _buildTableColumns(List<String> headerData, bool hasHeader, bool isDarkMode, bool isRTL) {
    return headerData.asMap().entries.map((entry) {
      return DataColumn(
        label: Expanded(
          child: Text(
            hasHeader ? entry.value : (isRTL ? 'ستون ${entry.key + 1}' : 'Column ${entry.key + 1}'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
            textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }).toList();
  }

  List<DataRow> _buildTableRows(List<List<String>> rowsData, bool isDarkMode, bool isRTL) {
    return rowsData.asMap().entries.map((rowEntry) {
      return DataRow(
        color: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (rowEntry.key.isEven) {
              return isDarkMode 
                ? Colors.grey.shade900.withValues(alpha: 0.3)
                : Colors.grey.shade50.withValues(alpha: 0.5);
            }
            return null;
          },
        ),
        cells: rowEntry.value.map((cellData) {
          return DataCell(
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Text(
                cellData.isNotEmpty ? cellData : '-',
                style: TextStyle(
                  fontSize: 13,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
                textAlign: TextAlign.center,
                textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          );
        }).toList(),
      );
    }).toList();
  }

  String _getContentBeforeElement(html_dom.Element parent, html_dom.Element target) {
    final children = parent.children;
    final targetIndex = children.indexOf(target);
    if (targetIndex <= 0) return '';
    
    final beforeElements = children.take(targetIndex);
    return beforeElements.map((e) => e.outerHtml).join('');
  }

  String _getContentBetweenElements(html_dom.Element parent, html_dom.Element start, html_dom.Element end) {
    final children = parent.children;
    final startIndex = children.indexOf(start);
    final endIndex = children.indexOf(end);
    
    if (startIndex == -1 || endIndex == -1 || endIndex <= startIndex + 1) return '';
    
    final betweenElements = children.skip(startIndex + 1).take(endIndex - startIndex - 1);
    return betweenElements.map((e) => e.outerHtml).join('');
  }

  String _getContentAfterElement(html_dom.Element parent, html_dom.Element target) {
    final children = parent.children;
    final targetIndex = children.indexOf(target);
    if (targetIndex == -1 || targetIndex >= children.length - 1) return '';
    
    final afterElements = children.skip(targetIndex + 1);
    return afterElements.map((e) => e.outerHtml).join('');
  }

  Widget _buildActionButtons(JobItem job, WidgetRef ref, BuildContext context) {

    // Check if we have apply link to determine layout
    final hasApplyLink = job.applyLink != null && job.applyLink!.trim().isNotEmpty;
    
    if (hasApplyLink) {
      // Show both buttons side by side
      return Row(
        children: [
          // Apply Button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _handleApplyToJob(job, context, ref),
              icon: Icon(JobApplyService.getApplyButtonIcon(job.applyLinkType)),
              label: Text(_getApplyButtonText(job, ref)),
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

          const SizedBox(width: 12),

          // Share Button
          Expanded(
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
    } else {
      // Show test buttons and share button when no apply link
      return Column(
        children: [
          // Test URL Launcher Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await JobApplyService.testUrlLauncher();
                if (mounted && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('URL Launcher Test: ${result ? 'SUCCESS' : 'FAILED'}'),
                      backgroundColor: result ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.web),
              label: const Text('Test URL Launcher'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Test Email Launcher Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await JobApplyService.testEmailLauncher();
                if (mounted && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Email Launcher Test: ${result ? 'SUCCESS' : 'FAILED'}'),
                      backgroundColor: result ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.email),
              label: const Text('Test Email Launcher'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Share Button (full width)
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
  }

  /// Handle applying to a job with enhanced functionality
  Future<void> _handleApplyToJob(JobItem job, BuildContext context, WidgetRef ref) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Text('Opening ${job.applyLinkType == ApplyLinkType.email ? 'email client' : 'browser'}...'),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      final result = await JobApplyService.applyToJob(job);
      
      if (mounted && context.mounted) {
        // Clear any existing snackbars
        ScaffoldMessenger.of(context).clearSnackBars();
        
        if (result.success) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_getLocalizedSuccessMessage(result.linkType, ref)),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          // Show detailed error message with debug info
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_getLocalizedErrorMessage(result.linkType, ref)),
                  const SizedBox(height: 4),
                  Text(
                    'Debug: ${result.message}',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                  Text(
                    'Link: "${job.applyLink}"',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: LocalizationHelper.getText(ref, 'retry'),
                textColor: Colors.white,
                onPressed: () => _handleApplyToJob(job, context, ref),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${LocalizationHelper.getText(ref, 'generalError')}: ${e.toString()}'),
                const SizedBox(height: 4),
                Text(
                  'Original link: "${job.applyLink}"',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
                Text(
                  'Formatted link: "${job.formattedApplyLink}"',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  /// Get localized apply button text based on link type
  String _getApplyButtonText(JobItem job, WidgetRef ref) {
    switch (job.applyLinkType) {
      case ApplyLinkType.email:
        return LocalizationHelper.getText(ref, 'applyViaEmail');
      case ApplyLinkType.webUrl:
        return LocalizationHelper.getText(ref, 'applyOnline');
      case ApplyLinkType.none:
        return LocalizationHelper.getText(ref, 'applyNow');
    }
  }

  /// Get localized success message based on link type
  String _getLocalizedSuccessMessage(ApplyLinkType linkType, WidgetRef ref) {
    switch (linkType) {
      case ApplyLinkType.email:
        return LocalizationHelper.getText(ref, 'emailClientOpened');
      case ApplyLinkType.webUrl:
        return LocalizationHelper.getText(ref, 'browserOpened');
      case ApplyLinkType.none:
        return LocalizationHelper.getText(ref, 'linkOpened');
    }
  }

  /// Get localized error message based on link type
  String _getLocalizedErrorMessage(ApplyLinkType linkType, WidgetRef ref) {
    switch (linkType) {
      case ApplyLinkType.email:
        return LocalizationHelper.getText(ref, 'emailClientError');
      case ApplyLinkType.webUrl:
        return LocalizationHelper.getText(ref, 'browserError');
      case ApplyLinkType.none:
        return LocalizationHelper.getText(ref, 'linkError');
    }
  }

  /// Legacy method for backward compatibility
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
      if (mounted && context.mounted) {
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
