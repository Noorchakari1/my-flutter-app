import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../data/models/news_model.dart';
import '../../data/providers/news_provider.dart';
import '../../data/providers/saved_news_provider.dart';

class NewsDetailScreen extends ConsumerWidget {
  final int newsId;

  const NewsDetailScreen({
    super.key,
    required this.newsId,
  });

  // Helper function to get localized text
  String _getText(BuildContext context, WidgetRef ref, String key) {
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

  // Helper method to strip HTML tags from text
  String _stripHtmlTags(String htmlString) {
    // Simple regex to remove HTML tags
    final RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    String result = htmlString.replaceAll(exp, '');

    // Replace common HTML entities
    result = result.replaceAll('&nbsp;', ' ')
                  .replaceAll('&amp;', '&')
                  .replaceAll('&lt;', '<')
                  .replaceAll('&gt;', '>')
                  .replaceAll('&quot;', '"')
                  .replaceAll('&#39;', "'");

    // Trim extra whitespace
    result = result.replaceAll(RegExp(r'\s+'), ' ').trim();

    return result;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsDetailAsync = ref.watch(newsDetailProvider(newsId));
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Determine text direction based on current language
    final isRTL = ref.watch(themeNotifierProvider).currentLanguage != 'english';
    final textDirection = isRTL ? TextDirection.rtl : TextDirection.ltr;

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        body: newsDetailAsync.when(
          data: (newsDetail) => _buildNewsDetailView(context, ref, newsDetail),
          loading: () => _buildLoadingView(),
          error: (error, stackTrace) => _buildErrorView(context, error, ref),
        ),
      ),
    );
  }

  Widget _buildNewsDetailView(BuildContext context, WidgetRef ref, NewsDetail newsDetail) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildAppBar(context, ref, newsDetail),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title card with shadow
              Container(
                margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13), // 0.05 opacity = 13/255
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      newsDetail.title ?? _getText(context, ref, 'noTitle'),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildMetadataRow(context, newsDetail),
                  ],
                ),
              ),

              // Content with modern styling
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13), // 0.05 opacity = 13/255
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: SelectionArea(
                  child: Html(
                    data: newsDetail.description ?? '',
                    style: {
                      "body": Style(
                        fontSize: FontSize(16),
                        lineHeight: const LineHeight(1.8),
                        direction: ref.watch(themeNotifierProvider).currentLanguage != 'english' ?
                          TextDirection.rtl : TextDirection.ltr,
                        textAlign: TextAlign.justify,
                        color: isDarkMode ? Colors.grey.shade300 : Colors.black87,
                      ),
                      "p": Style(
                        margin: Margins.only(bottom: 20),
                      ),
                      "h1, h2, h3, h4, h5, h6": Style(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      "a": Style(
                        color: Theme.of(context).primaryColor,
                        textDecoration: TextDecoration.none,
                      ),
                      "img": Style(
                        margin: Margins.all(8),
                      ),
                    },
                  ),
                ),
              ),

              if (newsDetail.gallery != null && newsDetail.gallery!.isNotEmpty) ...[
                _buildGallery(context, ref, newsDetail),
              ],

              // Action buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      context,
                      ref,
                      icon: Icons.share,
                      label: _getText(context, ref, 'share'),
                      onTap: () {
                        // Share both title and description
                        final title = newsDetail.title ?? _getText(context, ref, 'newsItem');
                        final description = _stripHtmlTags(newsDetail.description ?? '');
                        Share.share('$title\n\n$description\n\n${_getText(context, ref, 'viewFullNews')}');
                      },
                    ),
                    // Use a Consumer to rebuild when savedNewsProvider changes
                    Consumer(
                      builder: (context, ref, child) {
                        final savedNewsList = ref.watch(savedNewsProvider);
                        final isSaved = savedNewsList.any((news) => news.id == newsDetail.id);

                        return _buildActionButton(
                          context,
                          ref,
                          icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
                          label: _getText(context, ref, 'save'),
                          isActive: isSaved,
                          onTap: () {
                            ref.read(savedNewsProvider.notifier).toggleSaveNews(newsDetail);
                            // Get the updated state after toggling
                            final updatedIsSaved = ref.read(savedNewsProvider).any((news) => news.id == newsDetail.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(updatedIsSaved
                                  ? _getText(context, ref, 'newsSaved')
                                  : _getText(context, ref, 'newsUnsaved')),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    // _buildActionButton(
                    //   context,
                    //   ref,
                    //   icon: Icons.text_increase,
                    //   label: _getText(context, ref, 'changeTextSize'),
                    //   onTap: () {
                    //     ScaffoldMessenger.of(context).showSnackBar(
                    //       SnackBar(content: Text(_getText(context, ref, 'comingSoon'))),
                    //     );
                    //   },
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context, WidgetRef ref, NewsDetail newsDetail) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Image with gradient overlay
            if (newsDetail.image != null && newsDetail.image!.isNotEmpty)
              CachedNetworkImage(
                imageUrl: newsDetail.image!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(color: Colors.white),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  ),
                ),
              )
            else
              Container(
                color: Colors.grey.shade200,
                child: const Center(
                  child: Icon(Icons.image_not_supported_outlined, size: 48, color: Colors.grey),
                ),
              ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withAlpha(179), // Using withAlpha instead of withOpacity
                  ],
                  stops: const [0.7, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(102), // Using withAlpha instead of withOpacity
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.share, size: 20),
          ),
          onPressed: () {
            // Share both title and description
            final title = newsDetail.title ?? _getText(context, ref, 'newsItem');
            final description = _stripHtmlTags(newsDetail.description ?? '');
            Share.share('$title\n\n$description\n\n${_getText(context, ref, 'viewFullNews')}');
          },
        ),
        // Add bookmark button to app bar
        Consumer(
          builder: (context, ref, child) {
            final savedNewsList = ref.watch(savedNewsProvider);
            final isSaved = savedNewsList.any((news) => news.id == newsDetail.id);

            return IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(102), // Using withAlpha instead of withOpacity
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                  size: 20,
                  color: isSaved ? Theme.of(context).colorScheme.secondary : Colors.white,
                ),
              ),
              onPressed: () {
                ref.read(savedNewsProvider.notifier).toggleSaveNews(newsDetail);
                final updatedIsSaved = ref.read(savedNewsProvider).any((news) => news.id == newsDetail.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(updatedIsSaved
                      ? _getText(context, ref, 'newsSaved')
                      : _getText(context, ref, 'newsUnsaved')),
                  ),
                );
              },
            );
          },
        ),
      ],
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(102), // Using withAlpha instead of withOpacity
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  Widget _buildMetadataRow(BuildContext context, NewsDetail newsDetail) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        // Date with card style
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.grey.shade800
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 14,
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700
              ),
              const SizedBox(width: 6),
              Text(
                newsDetail.date ?? 'تاریخ نامشخص',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Views with card style
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.grey.shade800
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.remove_red_eye,
                size: 14,
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700
              ),
              const SizedBox(width: 6),
              Text(
                '${newsDetail.views ?? 0}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGallery(BuildContext context, WidgetRef ref, NewsDetail newsDetail) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final galleryImages = newsDetail.gallery ?? [];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13), // Using withAlpha instead of withOpacity
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.photo_library,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _getText(context, ref, 'imageGallery'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const Spacer(),
              Text(
                _getText(context, ref, 'imageCount').replaceAll('{count}', '${galleryImages.length}'),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: galleryImages.isEmpty
                ? Center(
                    child: Text(
                      _getText(context, ref, 'noImages'),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: galleryImages.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(26), // Using withAlpha instead of withOpacity
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: GestureDetector(
                            onTap: () {
                              // Show full screen gallery
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(_getText(context, ref, 'fullscreenComingSoon'))),
                              );
                            },
                            child: CachedNetworkImage(
                              imageUrl: galleryImages[index],
                              width: 180,
                              height: 140,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: Container(color: Colors.white),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.error, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13), // Using withAlpha instead of withOpacity
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isActive
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).primaryColor,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive
                  ? Theme.of(context).colorScheme.secondary
                  : (isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          expandedHeight: 300,
          pinned: true,
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add circular progress indicator in the center
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 40, bottom: 30),
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: LoadingIndicator(
                  itemCount: 3,
                  height: 150,
                  showImage: false,
                  showSubtitle: true,
                  isGrid: false,
                  borderRadius: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView(BuildContext context, Object error, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26), // Using withAlpha instead of withOpacity
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red.shade300,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _getText(context, ref, 'errorLoadingNews'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error.toString(),
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.refresh(newsDetailProvider(newsId)),
              icon: const Icon(Icons.refresh),
              label: Text(_getText(context, ref, 'tryAgain')),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(_getText(context, ref, 'goBack')),
            ),
          ],
        ),
      ),
    );
  }
}